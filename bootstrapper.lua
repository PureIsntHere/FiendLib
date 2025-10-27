local VERSION = "2.6.21"
local repoBase = "https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/"

print(string.format("[Fiend] Loading v%s...", VERSION))

-- Key validation function (uses configurable options)
local function ValidateKey(inputKey, keySystemOptions)
    if not keySystemOptions or not keySystemOptions.Enabled then
        return true -- Key system disabled, allow access
    end

    -- Use custom validation function if provided
    if keySystemOptions.ValidateKey and typeof(keySystemOptions.ValidateKey) == "function" then
        local success, result = pcall(keySystemOptions.ValidateKey, inputKey)
        return success and result == true
    end

    -- Fallback to simple key comparison
    if keySystemOptions.Key and typeof(keySystemOptions.Key) == "string" then
        return inputKey == keySystemOptions.Key
    end

    return false
end

local FiendModules = {}
_G.FiendModules = FiendModules

local Bootstrapper = {}

-- Simple key prompt (before full library loads)
function Bootstrapper:ShowKeyPrompt(keySystemOptions)
    if not keySystemOptions or not keySystemOptions.Enabled then
        return true
    end

    print("[Fiend] Key system enabled - requesting access key...")

    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")

    -- Create overlay (using clean theme colors)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FiendKeyPrompt"
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = game:GetService("CoreGui")

    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(8, 8, 10) -- Background
    overlay.BackgroundTransparency = 1
    overlay.Parent = screenGui

    -- Create card (using clean theme colors)
    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.fromOffset(400, 220)
    card.Position = UDim2.new(0.5, -200, 0.5, -110)
    card.BackgroundColor3 = Color3.fromRGB(14, 14, 18) -- Background2
    card.BorderSizePixel = 0
    card.Parent = overlay

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6) -- Standard rounding
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(96, 98, 104) -- Border
    stroke.Thickness = 1
    stroke.Parent = card

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = card

    -- Title (using clean theme colors)
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 24)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = keySystemOptions.Title or "Library Access"
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(230, 230, 232) -- TextColor
    title.Parent = card

    -- Hint (using clean theme colors)
    local hint = Instance.new("TextLabel")
    hint.Name = "Hint"
    hint.Size = UDim2.new(1, 0, 0, 36)
    hint.Position = UDim2.new(0, 0, 0, 28)
    hint.BackgroundTransparency = 1
    hint.Text = keySystemOptions.Hint or "Enter the access key to continue."
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 14
    hint.TextColor3 = Color3.fromRGB(170, 174, 182) -- SubTextColor
    hint.TextWrapped = true
    hint.Parent = card

    -- Input box (using clean theme colors)
    local input = Instance.new("TextBox")
    input.Name = "KeyInput"
    input.Size = UDim2.new(1, 0, 0, 36)
    input.Position = UDim2.new(0, 0, 0, 68)
    input.BackgroundColor3 = Color3.fromRGB(8, 8, 10) -- Background
    input.Text = ""
    input.PlaceholderText = "Enter key here"
    input.Font = Enum.Font.Gotham
    input.TextSize = 16
    input.TextColor3 = Color3.fromRGB(230, 230, 232) -- TextColor
    input.ClearTextOnFocus = false
    input.Parent = card

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6) -- Standard rounding
    inputCorner.Parent = input

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Color3.fromRGB(96, 98, 104) -- Border
    inputStroke.Thickness = 1
    inputStroke.Parent = input

    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 8)
    inputPadding.PaddingRight = UDim.new(0, 8)
    inputPadding.Parent = input

    -- Error message (using clean theme colors)
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Name = "Error"
    errorLabel.Size = UDim2.new(1, 0, 0, 20)
    errorLabel.Position = UDim2.new(0, 0, 0, 108)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.TextSize = 14
    errorLabel.TextColor3 = Color3.fromRGB(255, 200, 120) -- Warning
    errorLabel.Parent = card

    -- Submit button (using clean theme colors)
    local submitBtn = Instance.new("TextButton")
    submitBtn.Name = "Submit"
    submitBtn.Size = UDim2.new(1, 0, 0, 36)
    submitBtn.Position = UDim2.new(0, 0, 1, -36)
    submitBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 224) -- Accent
    submitBtn.Text = "Submit"
    submitBtn.Font = Enum.Font.GothamSemibold
    submitBtn.TextSize = 16
    submitBtn.TextColor3 = Color3.fromRGB(8, 8, 10) -- Background (contrast)
    submitBtn.AutoButtonColor = false
    submitBtn.Parent = card

    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 6) -- Standard rounding
    submitCorner.Parent = submitBtn

    -- Animation (clean styling)
    overlay.BackgroundTransparency = 1
    card.Position = UDim2.new(0.5, -200, 0.5, -90)

    local fadeIn = TweenService:Create(overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.6 -- Semi-transparent overlay
    })

    local slideIn = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -200, 0.5, -110)
    })

    fadeIn:Play()
    slideIn:Play()

    -- Submit handler
    local function handleSubmit()
        local inputText = input.Text
        local isValid = ValidateKey(inputText, keySystemOptions)

        if isValid then
            -- Success - call success callback and close
            if keySystemOptions.OnSuccess then
                keySystemOptions.OnSuccess()
            end

            local fadeOut = TweenService:Create(overlay, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            })

            local slideOut = TweenService:Create(card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -200, 0.5, -90)
            })

            fadeOut:Play()
            slideOut:Play()

            task.delay(0.16, function()
                screenGui:Destroy()
            end)

            return true
        else
            -- Invalid key - error message and attempts are handled in the main loop
            -- Shake animation
            local originalPos = card.Position
            local shakeTween = TweenService:Create(card, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = originalPos + UDim2.fromOffset(8, 0)
            })

            shakeTween:Play()
            task.delay(0.1, function()
                TweenService:Create(card, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = originalPos
                }):Play()
            end)

            return false
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
    local escConnection
    escConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Escape then
            escConnection:Disconnect()
            if keySystemOptions.OnFail then
                keySystemOptions.OnFail()
            end
            screenGui:Destroy()
        end
    end)

    -- Focus input
    task.wait(0.3)
    input:CaptureFocus()

    -- Handle multiple attempts
    local attempts = 0
    local maxAttempts = keySystemOptions.MaxAttempts or 3

    while attempts < maxAttempts do
        attempts = attempts + 1

        -- Wait for validation
        local isValid = false
        local validationComplete = false

        local submitConnection = submitBtn.MouseButton1Click:Connect(function()
            isValid = handleSubmit()
            validationComplete = true
        end)

        local focusConnection = input.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                isValid = handleSubmit()
                validationComplete = true
            end
        end)

        -- Wait for user input
        while not validationComplete do
            task.wait()
        end

        -- Cleanup connections
        submitConnection:Disconnect()
        focusConnection:Disconnect()

        if isValid then
            escConnection:Disconnect()
            return true
        end

        -- Update error message for remaining attempts
        if attempts < maxAttempts then
            errorLabel.Text = string.format("Invalid key. %d/%d attempts used.", attempts, maxAttempts)
        end
    end

    -- Max attempts reached
    errorLabel.Text = "Maximum attempts exceeded"

    task.delay(1, function()
        escConnection:Disconnect()
        if keySystemOptions.OnFail then
            keySystemOptions.OnFail()
        end
        screenGui:Destroy()
    end)

    return false
end

-- Fetch a module from GitHub with executor-specific HTTP calls
function Bootstrapper:FetchModule(path)
    local url = repoBase .. path
    
    -- Try executor-specific HTTP calls first
    local function tryExecutorHTTP()
        -- Try to find executor HTTP function without direct _G access
        local env = getfenv and getfenv() or _G
        local httpFuncs = {"httpget", "http_request", "request", "http.request"}
        
        for i = 1, #httpFuncs do
            local funcName = httpFuncs[i]
            local ok, func = pcall(function()
                return env[funcName]
            end)
            
            if ok and func and typeof(func) == "function" then
                local success, result
                
                -- httpget(url: string): string - most common executor format
                if funcName == "httpget" then
                    success, result = pcall(func, url)
                    if success and result and type(result) == "string" then
                        return result
                    end
                -- Other formats use table parameters
                else
                    success, result = pcall(func, {
                        Url = url,
                        Method = "GET"
                    })
                    
                    if success and result and result.Body then
                        return result.Body
                    elseif success and type(result) == "string" then
                        return result
                    end
                end
            end
        end
        return nil
    end
    
    -- Try executor-specific HTTP first
    local executorResult = tryExecutorHTTP()
    if executorResult and executorResult ~= "" then
        return executorResult
    end
    
    -- Fallback to game:HttpGet as last resort
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and result and result ~= "" then
        return result
    else
        warn(string.format("[Fiend] Failed to fetch: %s", path))
        return nil
    end
end

-- Execute a module with its dependencies available via FiendModules
function Bootstrapper:ExecuteModule(path, code)
    print(string.format("[Fiend] Executing: %s", path))
    
    local fn = loadstring(code)
    if not fn then
        error("Failed to load module: " .. path)
    end
    
    -- Track modules currently being executed to prevent infinite recursion
    self._executing = self._executing or {}
    
    -- Create a proxy FiendModules that can lazy-load missing dependencies
    local function createFiendModulesProxy()
        return setmetatable({}, {
            __index = function(self, key)
                local value = _G.FiendModules[key]
                if value ~= nil then
                    return value
                end
                -- Try to lazy-load from bootstrapper if it exists and not already executing
                if self._bootstrapper and self._bootstrapper._moduleInfo then
                    local moduleInfo = self._bootstrapper._moduleInfo[key]
                    if moduleInfo and not _G.FiendModules[key] and not self._bootstrapper._executing[moduleInfo.path] then
                        self._bootstrapper._executing[moduleInfo.path] = true
                        local result = self._bootstrapper:ExecuteModule(moduleInfo.path, moduleInfo.code)
                        _G.FiendModules[key] = result
                        self._bootstrapper._executing[moduleInfo.path] = nil
                        return result
                    end
                end
                return nil
            end
        })
    end
    
    local proxy = createFiendModulesProxy()
    proxy._bootstrapper = self
    proxy._moduleInfo = self._moduleInfo
    
    -- Safely set environment using getfenv if available
    local envFunc = nil
    pcall(function()
        local env = getfenv and getfenv() or _G
        envFunc = env["setfenv"]
    end)
    
    -- Create the environment with essential globals
    local moduleEnv = setmetatable({
        FiendModules = proxy,
        -- Roblox globals
        game = game,
        workspace = workspace,
        Color3 = Color3,
        ColorSequence = ColorSequence,
        ColorSequenceKeypoint = ColorSequenceKeypoint,
        NumberSequence = NumberSequence,
        NumberSequenceKeypoint = NumberSequenceKeypoint,
        NumberRange = NumberRange,
        UDim2 = UDim2,
        UDim = UDim,
        Enum = Enum,
        Instance = Instance,
        Vector2 = Vector2,
        Vector3 = Vector3,
        CFrame = CFrame,
        TweenInfo = TweenInfo,
        task = task,
        -- Essential functions
        print = print,
        warn = warn,
        error = error,
        type = type,
        typeof = typeof,
        tostring = tostring,
        tonumber = tonumber,
        pairs = pairs,
        ipairs = ipairs,
        pcall = pcall,
        setmetatable = setmetatable,
        getmetatable = getmetatable,
        _G = _G,
        coroutine = coroutine,
        table = table,
        string = string,
        math = math,
        os = os,
        spawn = spawn,
    }, {__index = _G})
    
    -- Safely get getfenv/setfenv functions without iterating _G
    local getfenvFunc, setfenvFunc = nil, nil
    pcall(function()
        local env = getfenv and getfenv() or _G
        if env["getfenv"] and typeof(env["getfenv"]) == "function" then
            getfenvFunc = env["getfenv"]
        end
        if env["setfenv"] and typeof(env["setfenv"]) == "function" then
            setfenvFunc = env["setfenv"]
        end
    end)
    
    if getfenvFunc then moduleEnv.getfenv = getfenvFunc end
    if setfenvFunc then moduleEnv.setfenv = setfenvFunc end
    
    -- Apply environment if setfenv is available
    if setfenvFunc then
        setfenvFunc(fn, moduleEnv)
    end
    
    local success, result = pcall(fn)
    
    if not success then
        error("Failed to execute module " .. path .. ": " .. tostring(result))
    end
    
    if result == nil then
        error(string.format("Module %s returned nil!", path))
    end
    
    print(string.format("[Fiend] ✓ Module %s returned: %s", path, type(result)))
    return result
end

-- Create and show splash screen (retro-futuristic themed)
function Bootstrapper:CreateSplash(splashOptions)
    splashOptions = splashOptions or {}
    if splashOptions.Enabled == false then
        return -- Skip splash screen if disabled
    end

    -- Create retro-futuristic splash screen
    local sg = Instance.new("ScreenGui")
    sg.Name = "FiendSplash"
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.DisplayOrder = 9999
    sg.Parent = game:GetService("CoreGui")

    -- Main container with clean styling
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Position = UDim2.fromScale(0.5, 0.5)
    container.Size = UDim2.fromOffset(420, 280)
    container.BackgroundColor3 = Color3.fromRGB(14, 14, 18) -- Background2
    container.BorderSizePixel = 0
    container.Parent = sg

    -- Standard corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container

    -- Standard border
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(96, 98, 104) -- Border
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = container

    -- Add grid pattern background (only for retro-futuristic theme)
    if splashOptions.ShowGridPattern then
        local gridPattern = Instance.new("Frame")
        gridPattern.Name = "GridPattern"
        gridPattern.Size = UDim2.fromScale(1, 1)
        gridPattern.BackgroundTransparency = 1
        gridPattern.Parent = container

        -- Create grid lines
        for i = 0, 12 do
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 0, i * 24)
            line.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
            line.BackgroundTransparency = 0.8
            line.BorderSizePixel = 0
            line.Parent = gridPattern
        end

        for i = 0, 20 do
            local line = Instance.new("Frame")
            line.Size = UDim2.new(0, 1, 1, 0)
            line.Position = UDim2.new(0, i * 24, 0, 0)
            line.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
            line.BackgroundTransparency = 0.8
            line.BorderSizePixel = 0
            line.Parent = gridPattern
        end
    end

    -- Title (clean styling)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -20, 0, 32)
    titleLabel.Position = UDim2.fromOffset(10, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = splashOptions.Title or ("FIEND v" .. VERSION)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 28
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 232) -- TextColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = container

    -- Subtitle (clean styling)
    local subTitleLabel = Instance.new("TextLabel")
    subTitleLabel.Name = "SubTitleLabel"
    subTitleLabel.Size = UDim2.new(1, -20, 0, 20)
    subTitleLabel.Position = UDim2.fromOffset(10, 55)
    subTitleLabel.BackgroundTransparency = 1
    subTitleLabel.Text = splashOptions.SubTitle or "Loading UI Library..."
    subTitleLabel.Font = Enum.Font.Gotham
    subTitleLabel.TextSize = 14
    subTitleLabel.TextColor3 = Color3.fromRGB(170, 174, 182) -- SubTextColor
    subTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subTitleLabel.TextYAlignment = Enum.TextYAlignment.Center
    subTitleLabel.Parent = container

    -- Status label (clean styling)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.fromOffset(10, 200)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Initializing..."
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 14
    statusLabel.TextColor3 = Color3.fromRGB(230, 230, 232) -- TextColor
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Center
    statusLabel.Parent = container

    -- Progress container (clean styling)
    local progressContainer = Instance.new("Frame")
    progressContainer.Name = "ProgressContainer"
    progressContainer.Size = UDim2.new(1, -20, 0, 8)
    progressContainer.Position = UDim2.fromOffset(10, 230)
    progressContainer.BackgroundColor3 = Color3.fromRGB(8, 8, 10) -- Background
    progressContainer.BorderSizePixel = 0
    progressContainer.Parent = container

    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 4)
    progressCorner.Parent = progressContainer

    local progressBorder = Instance.new("UIStroke")
    progressBorder.Color = Color3.fromRGB(96, 98, 104) -- Border
    progressBorder.Thickness = 1
    progressBorder.Parent = progressContainer

    -- Progress fill (clean styling)
    local progressFill = Instance.new("Frame")
    progressFill.Name = "Fill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.Position = UDim2.fromScale(0, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(220, 220, 224) -- Accent
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressContainer

    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(0, 4)
    progressFillCorner.Parent = progressFill

    -- Decorative elements (only for retro-futuristic theme)
    if splashOptions.ShowDecorations then
        -- Top accent line
        local topAccent = Instance.new("Frame")
        topAccent.Size = UDim2.new(1, 0, 0, 2)
        topAccent.Position = UDim2.new(0, 0, 0, 0)
        topAccent.BackgroundColor3 = Color3.fromRGB(220, 220, 224) -- Accent
        topAccent.BorderSizePixel = 0
        topAccent.Parent = container

        -- Bottom accent line
        local bottomAccent = Instance.new("Frame")
        bottomAccent.Size = UDim2.new(1, 0, 0, 2)
        bottomAccent.Position = UDim2.new(0, 0, 1, -2)
        bottomAccent.BackgroundColor3 = Color3.fromRGB(220, 220, 224) -- Accent
        bottomAccent.BorderSizePixel = 0
        bottomAccent.Parent = container
    end

    self._splashGui = sg
    self._splashContainer = container
    self._splashTitle = titleLabel
    self._splashSubTitle = subTitleLabel
    self._splashStatus = statusLabel
    self._splashProgress = progressFill
end

function Bootstrapper:UpdateSplash(text, progress)
    if self._splashStatus then
        self._splashStatus.Text = text or "Loading..."
    end
    if self._splashProgress then
        self._splashProgress.Size = UDim2.new(progress, 0, 1, 0)
    end
end

function Bootstrapper:HideSplash()
    if self._splashGui then
        -- Simple fade out using a frame overlay
        local container = self._splashGui:FindFirstChild("Container")
        if container then
            local overlay = Instance.new("Frame")
            overlay.Name = "Overlay"
            overlay.Size = UDim2.new(1, 0, 1, 0)
            overlay.BackgroundColor3 = Color3.fromRGB(8, 8, 10) -- Background
            overlay.BackgroundTransparency = 0
            overlay.ZIndex = 999
            overlay.Parent = self._splashGui
            
            local fadeOut = game:GetService("TweenService"):Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            fadeOut:Play()
            fadeOut.Completed:Wait()
        end
        task.wait(0.1)
        self._splashGui:Destroy()
    end
end

-- Load all modules in dependency order
function Bootstrapper:LoadModules(keySystemOptions, splashOptions)
    -- Check key system before loading anything
    local keyValid = self:ShowKeyPrompt(keySystemOptions)
    if not keyValid then
        -- This error will be caught by Bootstrap function
        error("[Fiend] Access denied - library loading blocked")
    end

    -- Show splash screen
    self:CreateSplash(splashOptions)
    self:UpdateSplash("Initializing Fiend UI Library...", 0)
    
    local modules = {
        {path = "lib/util.lua", name = "Util"},
        {path = "lib/base_element.lua", name = "BaseElement"},
        {path = "lib/theme.lua", name = "Theme"},
        {path = "lib/tween.lua", name = "Tween"},
        {path = "lib/fx.lua", name = "FX"},
        {path = "lib/behaviors.lua", name = "Behaviors"},
        {path = "lib/safety.lua", name = "Safety"},
        {path = "lib/keysystem.lua", name = "KeySystem"},
        {path = "lib/config.lua", name = "Config"},
        {path = "lib/theme_manager.lua", name = "ThemeManager"},
        {path = "components/button.lua", name = "Button"},
        {path = "components/toggle.lua", name = "Toggle"},
        {path = "components/slider.lua", name = "Slider"},
        {path = "components/dropdown.lua", name = "Dropdown"},
        {path = "components/textinput.lua", name = "TextInput"},
        {path = "components/group.lua", name = "Group"},
        {path = "components/tab.lua", name = "Tab"},
        {path = "components/dock.lua", name = "Dock"},
        {path = "components/window.lua", name = "Window"},
        {path = "components/keybind.lua", name = "Keybind"},
        {path = "components/notify.lua", name = "Notify"},
        {path = "components/announce.lua", name = "Announce"},
    }
    
    local totalModules = #modules + 1 -- +1 for init.lua
    
    print("[Fiend] Loading modules")
    
    -- First pass: Fetch all module code
    self._moduleInfo = {}
    for i, moduleInfo in ipairs(modules) do
        self:UpdateSplash("Fetching " .. moduleInfo.name .. "...", i / totalModules)
        local code = self:FetchModule(moduleInfo.path)
        if code then
            print(string.format("[Fiend] - Loaded: %s", moduleInfo.path))
            moduleInfo.code = code
            self._moduleInfo[moduleInfo.name] = moduleInfo
        else
            error("Failed to load module: " .. moduleInfo.path)
        end
    end
    
    -- Second pass: Execute all modules (order doesn't matter now - lazy loading handles dependencies)
    self._executing = {}
    local execIndex = 1
    for _, moduleInfo in ipairs(modules) do
        if not FiendModules[moduleInfo.name] then
            local progressPercent = (#modules + execIndex - 1) / totalModules
            self:UpdateSplash("Initializing " .. moduleInfo.name .. "...", progressPercent)
            self._executing[moduleInfo.path] = true
            local result = self:ExecuteModule(moduleInfo.path, moduleInfo.code)
            FiendModules[moduleInfo.name] = result
            self._executing[moduleInfo.path] = nil
            execIndex = execIndex + 1
        end
    end
    
    print("[Fiend] All modules loaded.")
    
    -- Now load init.lua which uses FiendModules
    self:UpdateSplash("Finalizing library", (totalModules - 1) / totalModules)
    local initCode = self:FetchModule("init.lua")
    if not initCode then
        error("Failed to load init.lua")
    end
    
    local Fiend = self:ExecuteModule("init.lua", initCode)
    
    if not Fiend then
        error("Failed to initialize Fiend")
    end
    
    print(string.format("[Fiend] - Bootstrap v%s complete!", VERSION))
    
    -- Hide splash screen
    self:UpdateSplash("Complete.", 1)
    task.wait(0.5)
    self:HideSplash()
    
    return Fiend
end

-- Bootstrap entry point
function Bootstrapper:Bootstrap(options)
    options = options or {}
    local keySystemOptions = options.KeySystem
    local splashOptions = options.SplashScreen

    local bootstrapper = self
    local success, result = pcall(function()
        return bootstrapper:LoadModules(keySystemOptions, splashOptions)
    end)

    if not success then
        -- Check if it's a key system denial
        if string.find(result, "Access denied") then
            print("[Fiend] Key system: Access denied - library not loaded")
            return nil
        end
        warn("[Fiend] Bootstrap failed:", result)
        return nil
    end

    return result
end

return Bootstrapper