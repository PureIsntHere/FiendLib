-- Fiend/lib/keysystem.lua
-- Unified Key System - Robust, secure, and consistent key management
-- Replaces the fragmented KeySystem, KeyGate, and keybind implementations

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Executor-only: use FiendModules
local Util = FiendModules.Util
local Theme = FiendModules.Theme
local Safety = FiendModules.Safety

local KeySystem = {}
KeySystem.__index = KeySystem

-- Types
export type KeyBindType = "Toggle" | "Hold" | "Press" | "Always"
export type KeyValidationResult = "valid" | "invalid" | "error"

export type KeyBind = {
    Name: string,
    KeyCode: Enum.KeyCode,
    Type: KeyBindType,
    Callback: ((boolean?) -> ())?,
    Enabled: boolean,
    Id: string?
}

export type KeyPromptOptions = {
    Title: string?,
    Hint: string?,
    Key: string?,
    Check: ((string) -> boolean)?,
    OnSuccess: (() -> ())?,
    OnFail: (() -> ())?,
    Theme: any?,
    Persistent: boolean?,
    MaxAttempts: number?
}

export type KeySystemOptions = {
    Theme: any?,
    GlobalKeyCapture: boolean?,
    DebugMode: boolean?
}

function KeySystem.new(options: KeySystemOptions?)
    local self = setmetatable({}, KeySystem)
    
    options = options or {}
    self._theme = options.Theme or Theme
    self._globalKeyCapture = options.GlobalKeyCapture ~= false
    self._debugMode = options.DebugMode or false
    
    -- State management
    self._binds = {} -- [name] = KeyBind
    self._activeStates = {} -- [name] = boolean
    self._connections = {}
    self._keyCaptureActive = false
    self._captureCallback = nil
    self._attempts = {} -- [promptId] = attemptCount
    
    -- Initialize global key handling
    if self._globalKeyCapture then
        self:_setupGlobalKeyHandling()
    end
    
    return self
end

-- Private: Setup global key handling
function KeySystem:_setupGlobalKeyHandling()
    local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        
        self:_handleKeyPress(input.KeyCode, true)
    end)
    
    local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        
        self:_handleKeyPress(input.KeyCode, false)
    end)
    
    table.insert(self._connections, inputBeganConn)
    table.insert(self._connections, inputEndedConn)
end

-- Private: Handle key press/release
function KeySystem:_handleKeyPress(keyCode: Enum.KeyCode, pressed: boolean)
    -- Handle key capture mode first
    if self._keyCaptureActive and self._captureCallback then
        if pressed then
            self._keyCaptureActive = false
            self._captureCallback(keyCode)
            self._captureCallback = nil
        end
        return
    end
    
    -- Handle registered binds
    for name, bind in pairs(self._binds) do
        if bind.KeyCode == keyCode and bind.Enabled then
            if bind.Type == "Toggle" and pressed then
                local newState = not self._activeStates[name]
                self._activeStates[name] = newState
                if bind.Callback and typeof(bind.Callback) == "function" then
                    task.spawn(bind.Callback, newState)
                end
                self:_debugLog("Toggle bind '%s' changed to %s", name, tostring(newState))
            elseif bind.Type == "Hold" then
                if pressed then
                    self._activeStates[name] = true
                    if bind.Callback and typeof(bind.Callback) == "function" then
                        task.spawn(bind.Callback, true)
                    end
                    self:_debugLog("Hold bind '%s' activated", name)
                else
                    self._activeStates[name] = false
                    if bind.Callback and typeof(bind.Callback) == "function" then
                        task.spawn(bind.Callback, false)
                    end
                    self:_debugLog("Hold bind '%s' deactivated", name)
                end
            elseif bind.Type == "Press" and pressed then
                if bind.Callback and typeof(bind.Callback) == "function" then
                    task.spawn(bind.Callback)
                end
                self:_debugLog("Press bind '%s' triggered", name)
            elseif bind.Type == "Always" and pressed then
                if bind.Callback and typeof(bind.Callback) == "function" then
                    task.spawn(bind.Callback, true)
                end
                self:_debugLog("Always bind '%s' triggered", name)
            end
        end
    end
end

-- Private: Debug logging
function KeySystem:_debugLog(format: string, ...)
    if self._debugMode then
        print(string.format("[KeySystem] " .. format, ...))
    end
end

-- Public: Register a key bind
function KeySystem:RegisterBind(name: string, keyCode: Enum.KeyCode, bindType: KeyBindType?, callback: ((boolean?) -> ())?, id: string?)
    if not name or not keyCode then
        error("[KeySystem] RegisterBind requires name and keyCode")
    end
    
    bindType = bindType or "Toggle"
    if not table.find({"Toggle", "Hold", "Press", "Always"}, bindType) then
        warn("[KeySystem] Invalid bind type '" .. tostring(bindType) .. "', defaulting to Toggle")
        bindType = "Toggle"
    end
    
    self._binds[name] = {
        Name = name,
        KeyCode = keyCode,
        Type = bindType,
        Callback = callback,
        Enabled = true,
        Id = id or name
    }
    
    self._activeStates[name] = false
    self:_debugLog("Registered bind '%s' with key %s (type: %s)", name, keyCode.Name, bindType)
end

-- Public: Unregister a key bind
function KeySystem:UnregisterBind(name: string)
    if self._binds[name] then
        self._binds[name] = nil
        self._activeStates[name] = nil
        self:_debugLog("Unregistered bind '%s'", name)
    end
end

-- Public: Update bind key
function KeySystem:SetBindKey(name: string, keyCode: Enum.KeyCode)
    local bind = self._binds[name]
    if bind then
        bind.KeyCode = keyCode
        self:_debugLog("Updated bind '%s' key to %s", name, keyCode.Name)
    end
end

-- Public: Update bind type
function KeySystem:SetBindType(name: string, bindType: KeyBindType)
    local bind = self._binds[name]
    if bind and table.find({"Toggle", "Hold", "Press", "Always"}, bindType) then
        bind.Type = bindType
        self._activeStates[name] = false -- Reset state
        self:_debugLog("Updated bind '%s' type to %s", name, bindType)
    end
end

-- Public: Enable/disable bind
function KeySystem:SetBindEnabled(name: string, enabled: boolean)
    local bind = self._binds[name]
    if bind then
        bind.Enabled = enabled
        self:_debugLog("Set bind '%s' enabled to %s", name, tostring(enabled))
    end
end

-- Public: Get bind state
function KeySystem:GetBindState(name: string): boolean
    return self._activeStates[name] or false
end

-- Public: Get bind info
function KeySystem:GetBind(name: string): KeyBind?
    return self._binds[name]
end

-- Public: Get all binds
function KeySystem:GetAllBinds(): {[string]: KeyBind}
    return self._binds
end

-- Public: Start key capture mode
function KeySystem:StartKeyCapture(callback: (Enum.KeyCode) -> ())
    if self._keyCaptureActive then
        warn("[KeySystem] Key capture already active")
        return
    end
    
    self._keyCaptureActive = true
    self._captureCallback = callback
    self:_debugLog("Started key capture mode")
end

-- Public: Stop key capture mode
function KeySystem:StopKeyCapture()
    self._keyCaptureActive = false
    self._captureCallback = nil
    self:_debugLog("Stopped key capture mode")
end

-- Public: Show key prompt dialog
function KeySystem:ShowPrompt(options: KeyPromptOptions?)
    options = options or {}
    
    local promptId = tostring(math.random(100000, 999999))
    self._attempts[promptId] = 0
    
    local theme = options.Theme or self._theme
    local maxAttempts = options.MaxAttempts or 3
    
    -- Create overlay
    local floatLayer = Safety.GetFloatLayer()
    floatLayer.Visible = true
    
    local overlay = Util.Create("Frame", {
        Name = "Fiend_KeyPrompt_" .. promptId,
        Parent = floatLayer,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 500,
        Active = true
    })
    
    -- Create card
    local cardWidth, cardHeight = 400, 220
    local card = Util.Create("Frame", {
        Name = "Card",
        Parent = overlay,
        BackgroundColor3 = theme.Background2 or theme.Background or Color3.fromRGB(24, 26, 30),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(cardWidth, cardHeight),
        Position = UDim2.new(0.5, -cardWidth/2, 0.5, -cardHeight/2),
        BackgroundTransparency = 0,
        ZIndex = 501
    })
    
    Util.CreateUICorner(card, theme.Corner or UDim.new(0, 8))
    Util.CreateUIStroke(card, theme.Border or Color3.fromRGB(42, 48, 60), 1)
    Util.CreateUIPadding(card, theme.Pad or UDim.new(0, 12))
    
    -- Title
    local title = Util.Create("TextLabel", {
        Name = "Title",
        Parent = card,
        BackgroundTransparency = 1,
        Text = options.Title or "Access Required",
        Font = theme.Font or Enum.Font.GothamSemibold,
        TextSize = 18,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 232, 236),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 24),
        ZIndex = 502
    })
    
    -- Hint
    local hint = Util.Create("TextLabel", {
        Name = "Hint",
        Parent = card,
        BackgroundTransparency = 1,
        Text = options.Hint or "Enter your access key to continue.",
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.SubTextColor or Color3.fromRGB(170, 176, 186),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 28),
        ZIndex = 502
    })
    
    -- Input box
    local input = Util.Create("TextBox", {
        Name = "KeyInput",
        Parent = card,
        BackgroundColor3 = theme.Background or Color3.fromRGB(12, 12, 14),
        Text = "",
        PlaceholderText = "Enter key here",
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 16,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 232, 236),
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 68),
        ZIndex = 502
    })
    
    Util.CreateUICorner(input, theme.Corner or UDim.new(0, 6))
    Util.CreateUIStroke(input, theme.Border or Color3.fromRGB(42, 48, 60), 1)
    Util.CreateUIPadding(input, UDim.new(0, 8))
    
    -- Error message
    local errorLabel = Util.Create("TextLabel", {
        Name = "Error",
        Parent = card,
        BackgroundTransparency = 1,
        Text = "",
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.Warning or Color3.fromRGB(255, 176, 67),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 108),
        ZIndex = 502
    })
    
    -- Submit button
    local submitBtn = Util.Create("TextButton", {
        Name = "Submit",
        Parent = card,
        Text = "Submit",
        Font = theme.Font or Enum.Font.GothamSemibold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = theme.Accent or Color3.fromRGB(91, 135, 255),
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 1, -36),
        ZIndex = 502
    })
    
    Util.CreateUICorner(submitBtn, theme.Corner or UDim.new(0, 6))
    
    -- Animation
    overlay.BackgroundTransparency = 1
    card.Position = UDim2.new(0.5, -cardWidth/2, 0.5, -cardHeight/2 + 20)
    
    local fadeInTween = TweenService:Create(overlay, 
        theme.TweenLong or TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.4}
    )
    
    local slideInTween = TweenService:Create(card,
        theme.TweenLong or TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -cardWidth/2, 0.5, -cardHeight/2)}
    )
    
    fadeInTween:Play()
    slideInTween:Play()
    
    -- Validation function
    local function validateKey(inputText: string): KeyValidationResult
        self._attempts[promptId] = (self._attempts[promptId] or 0) + 1
        
        if options.Check and typeof(options.Check) == "function" then
            local success, result = pcall(options.Check, inputText)
            if not success then
                self:_debugLog("Key validation error: %s", tostring(result))
                return "error"
            end
            return result and "valid" or "invalid"
        elseif options.Key and typeof(options.Key) == "string" then
            return inputText == options.Key and "valid" or "invalid"
        end
        
        return "invalid"
    end
    
    -- Close function
    local function closePrompt(success: boolean)
        local fadeOutTween = TweenService:Create(overlay,
            theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}
        )
        
        local slideOutTween = TweenService:Create(card,
            theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(0.5, -cardWidth/2, 0.5, -cardHeight/2 + 20)}
        )
        
        fadeOutTween:Play()
        slideOutTween:Play()
        
        task.delay(0.16, function()
            overlay:Destroy()
            self._attempts[promptId] = nil
            
            if success and options.OnSuccess then
                task.spawn(options.OnSuccess)
            elseif not success and options.OnFail then
                task.spawn(options.OnFail)
            end
        end)
    end
    
    -- Error function
    local function showError(message: string)
        errorLabel.Text = message
        
        -- Shake animation
        local originalPos = card.Position
        local shakeTween = TweenService:Create(card,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = originalPos + UDim2.fromOffset(8, 0)}
        )
        
        shakeTween:Play()
        task.delay(0.1, function()
            TweenService:Create(card,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = originalPos}
            ):Play()
        end)
    end
    
    -- Submit handler
    local function handleSubmit()
        local inputText = input.Text or ""
        local validation = validateKey(inputText)
        
        if validation == "valid" then
            closePrompt(true)
        elseif validation == "error" then
            showError("Validation error occurred")
        else
            local attempts = self._attempts[promptId] or 0
            if attempts >= maxAttempts then
                showError("Maximum attempts exceeded")
                task.delay(1, function() closePrompt(false) end)
            else
                showError(string.format("Invalid key. %d/%d attempts used.", attempts, maxAttempts))
            end
        end
    end
    
    -- Event connections
    submitBtn.MouseButton1Click:Connect(handleSubmit)
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            handleSubmit()
        end
    end)
    
    -- ESC key handler
    local escConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Escape then
            escConnection:Disconnect()
            closePrompt(false)
        end
    end)
    
    -- Focus input
    task.wait(0.3)
    input:CaptureFocus()
    
    return {
        Destroy = function()
            escConnection:Disconnect()
            overlay:Destroy()
            self._attempts[promptId] = nil
        end
    }
end

-- Public: Validate key with custom logic
function KeySystem:ValidateKey(key: string, validator: (string) -> boolean): boolean
    if not validator or typeof(validator) ~= "function" then
        return false
    end
    
    local success, result = pcall(validator, key)
    return success and result == true
end

-- Public: Check if key capture is active
function KeySystem:IsKeyCaptureActive(): boolean
    return self._keyCaptureActive
end

-- Public: Get attempt count for a prompt
function KeySystem:GetAttemptCount(promptId: string): number
    return self._attempts[promptId] or 0
end

-- Public: Clear all attempts
function KeySystem:ClearAttempts()
    table.clear(self._attempts)
end

-- Public: Destroy the keysystem
function KeySystem:Destroy()
    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end
    
    table.clear(self._binds)
    table.clear(self._activeStates)
    table.clear(self._attempts)
    
    self._keyCaptureActive = false
    self._captureCallback = nil
    
    self:_debugLog("KeySystem destroyed")
end

return KeySystem
