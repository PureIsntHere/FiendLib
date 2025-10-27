-- Fiend/components/keybind.lua
-- Unified Keybind Component - Uses the new KeySystem for robust key management

local Util = FiendModules.Util
local Theme = FiendModules.Theme
local KeySystem = FiendModules.KeySystem
local BaseElement = FiendModules.BaseElement

local Keybind = {}
Keybind.__index = Keybind

export type KeybindOptions = {
    Label: string,
    DefaultKey: Enum.KeyCode?,
    DefaultMode: string?,
    Callback: ((boolean?) -> ())?,
    Enabled: boolean?,
    Id: string?
}

function Keybind.new(tabOrGroup, options: KeybindOptions | string, defaultKeyCode: Enum.KeyCode?, defaultMode: string?, callback: ((boolean?) -> ())?)
    -- Handle both new options format and legacy format
    local opts: KeybindOptions
    if typeof(options) == "string" then
        -- Legacy format: Keybind.new(tabOrGroup, labelText, defaultKeyCode, defaultMode, callback)
        opts = {
            Label = options,
            DefaultKey = defaultKeyCode,
            DefaultMode = defaultMode,
            Callback = callback,
            Enabled = true
        }
    else
        -- New format: Keybind.new(tabOrGroup, options)
        opts = options or {}
    end
    
    local theme = opts.Theme or tabOrGroup.Theme or Theme
    local keySystem = tabOrGroup.Window and tabOrGroup.Window.KeySystem or (tabOrGroup.Tab and tabOrGroup.Tab.Window and tabOrGroup.Tab.Window.KeySystem) or KeySystem.new()
    
    -- Create main frame
    local frame = Util.Create("Frame", {
        Name = "KeybindFrame",
        Parent = tabOrGroup.Content or tabOrGroup.Container,
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 2
    })
    
    Util.CreateUICorner(frame, theme.Corner)
    Util.CreateUIStroke(frame, theme.Foreground, 1, 0.7)
    Util.CreateUIPadding(frame, theme.Pad)
    
    -- Label
    local label = Util.Create("TextLabel", {
        Name = "Label",
        Parent = frame,
        BackgroundTransparency = 1,
        Text = opts.Label,
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 232, 236),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -160, 1, 0),
        ZIndex = 3
    })
    
    -- Key button
    local keyBtn = Util.Create("TextButton", {
        Name = "KeyButton",
        Parent = frame,
        AutoButtonColor = false,
        Text = (opts.DefaultKey and opts.DefaultKey.Name) or "None",
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 232, 236),
        BackgroundColor3 = theme.Background,
        Size = UDim2.fromOffset(90, 22),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        ZIndex = 3
    })
    
    Util.CreateUICorner(keyBtn, theme.Corner)
    Util.CreateUIStroke(keyBtn, theme.Foreground, 1, 0.6)
    
    -- Mode button
    local modeBtn = Util.Create("TextButton", {
        Name = "ModeButton",
        Parent = frame,
        AutoButtonColor = false,
        Text = opts.DefaultMode or "Hold",
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 232, 236),
        BackgroundColor3 = theme.Background,
        Size = UDim2.fromOffset(60, 22),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8 - 96, 0.5, 0),
        ZIndex = 3
    })
    
    Util.CreateUICorner(modeBtn, theme.Corner)
    Util.CreateUIStroke(modeBtn, theme.Foreground, 1, 0.6)
    
    -- Create the keybind instance
    local self = setmetatable({
        Instance = frame,
        Root = frame,
        _keySystem = keySystem,
        _name = opts.Label,
        _currentKey = opts.DefaultKey,
        _currentMode = opts.DefaultMode or "Hold",
        _callback = opts.Callback,
        _enabled = opts.Enabled ~= false,
        _id = opts.Id or opts.Label,
        _theme = theme,
        _label = label,
        _keyBtn = keyBtn,
        _modeBtn = modeBtn
    }, Keybind)
    
    -- Inherit from BaseElement
    setmetatable(self, {__index = BaseElement})
    
    -- Initialize BaseElement
    BaseElement.new(self, {
        Theme = theme,
        Root = frame
    })
    
    -- Register with keysystem
    if opts.DefaultKey then
        keySystem:RegisterBind(opts.Label, opts.DefaultKey, opts.DefaultMode or "Hold", opts.Callback, opts.Id)
    end
    
    -- Auto-register with Fiend for theme tracking
    if _G.FiendInstance and _G.FiendInstance._trackElement then
        _G.FiendInstance:_trackElement(self)
    end
    
    -- Key button click handler
    keyBtn.MouseButton1Click:Connect(function()
        if not self._enabled then return end
        
        keyBtn.Text = "..."
        
        -- Get current theme for accent color
        local currentTheme = self._theme
        if _G.FiendInstance and _G.FiendInstance.Theme then
            currentTheme = _G.FiendInstance.Theme
        end
        
        keyBtn.TextColor3 = currentTheme.Accent or Color3.fromRGB(91, 135, 255)
        
        -- Start key capture
        keySystem:StartKeyCapture(function(capturedKey)
            self:SetKey(capturedKey)
            keyBtn.TextColor3 = currentTheme.Foreground or currentTheme.TextColor or Color3.fromRGB(230, 232, 236)
        end)
    end)
    
    -- Mode button click handler
    local modes = {"Hold", "Toggle", "Press", "Always"}
    modeBtn.MouseButton1Click:Connect(function()
        if not self._enabled then return end
        
        local currentIndex = table.find(modes, self._currentMode) or 1
        local nextIndex = (currentIndex % #modes) + 1
        local nextMode = modes[nextIndex]
        
        self:SetMode(nextMode)
    end)
    
    -- Refresh theme for this keybind
    function self:RefreshTheme()
        -- Get current theme from library
        local currentTheme = self._theme
        if _G.FiendInstance and _G.FiendInstance.Theme then
            currentTheme = _G.FiendInstance.Theme
        end
        
        if currentTheme then
            -- Update main frame
            if self.Root then
                self.Root.BackgroundColor3 = currentTheme.Background
                self.Root.BackgroundTransparency = 0.15
                
                -- Update border
                local stroke = self.Root:FindFirstChild("UIStroke")
                if stroke then
                    stroke.Color = currentTheme.Border
                    stroke.Thickness = currentTheme.LineThickness or 1
                end
                
                -- Update corner radius
                local corner = self.Root:FindFirstChild("UICorner")
                if corner then
                    corner.CornerRadius = currentTheme.Corner or UDim.new(0, 6)
                end
            end
            
            -- Update label
            if self._label then
                self._label.TextColor3 = currentTheme.Foreground or currentTheme.TextColor
                self._label.Font = currentTheme.Font or Enum.Font.Gotham
            end
            
            -- Update key button
            if self._keyBtn then
                self._keyBtn.TextColor3 = currentTheme.Foreground or currentTheme.TextColor
                self._keyBtn.BackgroundColor3 = currentTheme.Background
                self._keyBtn.Font = currentTheme.Font or Enum.Font.Gotham
                
                -- Update key button border
                local keyStroke = self._keyBtn:FindFirstChild("UIStroke")
                if keyStroke then
                    keyStroke.Color = currentTheme.Border
                    keyStroke.Thickness = currentTheme.LineThickness or 1
                end
                
                -- Update key button corner
                local keyCorner = self._keyBtn:FindFirstChild("UICorner")
                if keyCorner then
                    keyCorner.CornerRadius = currentTheme.Corner or UDim.new(0, 6)
                end
            end
            
            -- Update mode button
            if self._modeBtn then
                self._modeBtn.TextColor3 = currentTheme.Foreground or currentTheme.TextColor
                self._modeBtn.BackgroundColor3 = currentTheme.Background
                self._modeBtn.Font = currentTheme.Font or Enum.Font.Gotham
                
                -- Update mode button border
                local modeStroke = self._modeBtn:FindFirstChild("UIStroke")
                if modeStroke then
                    modeStroke.Color = currentTheme.Border
                    modeStroke.Thickness = currentTheme.LineThickness or 1
                end
                
                -- Update mode button corner
                local modeCorner = self._modeBtn:FindFirstChild("UICorner")
                if modeCorner then
                    modeCorner.CornerRadius = currentTheme.Corner or UDim.new(0, 6)
                end
            end
            
            -- Update stored theme reference
            self._theme = currentTheme
        end
    end
    
    -- Apply initial theme
    self:RefreshTheme()
    
    return self
end


-- Set the key for this keybind
function Keybind:SetKey(keyCode: Enum.KeyCode)
    if not keyCode then return end
    
    self._currentKey = keyCode
    
    -- Update button text
    local keyBtn = self.Instance:FindFirstChild("KeyButton")
    if keyBtn then
        keyBtn.Text = keyCode.Name
    end
    
    -- Update keysystem
    self._keySystem:SetBindKey(self._name, keyCode)
end

-- Set the mode for this keybind
function Keybind:SetMode(mode: string)
    if not table.find({"Hold", "Toggle", "Press", "Always"}, mode) then
        warn("[Keybind] Invalid mode:", mode)
        return
    end
    
    self._currentMode = mode
    
    -- Update button text
    local modeBtn = self.Instance:FindFirstChild("ModeButton")
    if modeBtn then
        modeBtn.Text = mode
    end
    
    -- Update keysystem
    self._keySystem:SetBindType(self._name, mode)
end

-- Set the callback for this keybind
function Keybind:SetCallback(callback: ((boolean?) -> ())?)
    self._callback = callback
    
    -- Update keysystem
    if self._currentKey then
        self._keySystem:RegisterBind(self._name, self._currentKey, self._currentMode, callback, self._id)
    end
end

-- Enable/disable this keybind
function Keybind:SetEnabled(enabled: boolean)
    self._enabled = enabled
    self._keySystem:SetBindEnabled(self._name, enabled)
    
    -- Update visual state
    local keyBtn = self.Instance:FindFirstChild("KeyButton")
    local modeBtn = self.Instance:FindFirstChild("ModeButton")
    
    if keyBtn then
        keyBtn.TextTransparency = enabled and 0 or 0.5
    end
    if modeBtn then
        modeBtn.TextTransparency = enabled and 0 or 0.5
    end
end

-- Get current key
function Keybind:GetKey(): Enum.KeyCode?
    return self._currentKey
end

-- Get current mode
function Keybind:GetMode(): string
    return self._currentMode
end

-- Get current state
function Keybind:GetState(): boolean
    return self._keySystem:GetBindState(self._name)
end

-- Get enabled state
function Keybind:IsEnabled(): boolean
    return self._enabled
end

-- Destroy the keybind
function Keybind:Destroy()
    if self._keySystem and self._name then
        self._keySystem:UnregisterBind(self._name)
    end
    
    if self.Instance then
        self.Instance:Destroy()
    end
end

return Keybind