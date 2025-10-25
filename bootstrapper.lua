-- Fiend/bootstrapper.lua
-- Enhanced bootstrapper with splash screen and progress tracking

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local repoBase = "https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/"

local Bootstrapper = {}
Bootstrapper._modules = {}
Bootstrapper._cache = {}
Bootstrapper._splash = nil
Bootstrapper._isStudio = RunService:IsStudio()

-- Load splash screen component
local function loadSplashComponent()
    if Bootstrapper._isStudio then
        -- In Studio, require normally
        local success, splash = pcall(function()
            return require(script.Parent.components.splash)
        end)
        if success then
            return splash
        else
            warn("[Fiend/Bootstrapper] Failed to load splash component:", splash)
            return nil
        end
    else
        -- In executor, load from remote
        local splashCode = Bootstrapper:FetchModule("components/splash.lua")
        if splashCode then
            local env = setmetatable({}, {__index = _G})
            env.require = Bootstrapper:CreateRequire()
            env.script = { Parent = { Parent = {} } }
            
            local fn, err = loadstring(splashCode)
            if fn then
                setfenv(fn, env)
                local success, result = pcall(fn)
                if success then
                    return result
                end
            end
        end
        return nil
    end
end

-- Custom require function for executor environment
function Bootstrapper:CreateRequire()
    return function(path)
        if type(path) ~= "string" then
            error("Executor require only supports string paths")
        end
        
        if self._cache[path] then
            return self._cache[path]
        end
        
        local moduleCode = self._modules[path]
        if not moduleCode then
            error("Module not found: " .. path)
        end
        
        local env = setmetatable({}, {__index = _G})
        env.require = self:CreateRequire()
        env.script = { Parent = { Parent = {} } }
        
        local fn, err = loadstring(moduleCode)
        if not fn then
            error("Failed to load module " .. path .. ": " .. tostring(err))
        end
        
        setfenv(fn, env)
        local success, result = pcall(fn)
        if not success then
            error("Failed to execute module " .. path .. ": " .. tostring(result))
        end
        
        self._cache[path] = result
        return result
    end
end

-- Fetch a module from remote (executor only)
function Bootstrapper:FetchModule(path)
    if self._isStudio then
        return nil -- Not needed in Studio
    end
    
    local url = repoBase .. path
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and result then
        return result
    end
    
    warn("[Fiend/Bootstrapper] Failed to fetch module:", path)
    return nil
end

-- Initialize splash screen
function Bootstrapper:InitializeSplash()
    if self._splash then return end
    
    local SplashClass = loadSplashComponent()
    if SplashClass then
        self._splash = SplashClass.new()
        self._splash:Show()
        self._splash:SetStatus("Initializing Fiend Library...")
    else
        -- Fallback: create a simple progress UI if splash component isn't available
        warn("[Fiend/Bootstrapper] Splash component not available, using fallback")
        self:_createFallbackProgressUI()
    end
end

-- Update splash progress
function Bootstrapper:UpdateProgress(current, total, filename)
    if self._splash then
        self._splash:SetProgress(current, total, filename)
    elseif self._fallbackGUI then
        self:_updateFallbackProgress(current, total, filename)
    end
end

-- Set splash status
function Bootstrapper:SetStatus(text)
    if self._splash then
        self._splash:SetStatus(text)
    elseif self._fallbackLabel then
        self._fallbackLabel.Text = text
    end
end

-- Complete splash screen
function Bootstrapper:CompleteSplash()
    if self._splash then
        self._splash:Complete()
        self._splash = nil
    elseif self._fallbackGUI then
        self:_completeFallbackProgress()
    end
end

-- Create fallback progress UI (simple version)
function Bootstrapper:_createFallbackProgressUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "FiendBootstrapFallback"
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.DisplayOrder = 9999
    sg.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.Size = UDim2.fromOffset(340, 100)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 24)
    label.Position = UDim2.fromOffset(10, 10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = "Loading FiendLib..."
    label.Font = Enum.Font.Code
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 0, 6)
    bar.Position = UDim2.new(0, 10, 1, -20)
    bar.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 3)
    corner2.Parent = bar
    
    self._fallbackGUI = sg
    self._fallbackLabel = label
    self._fallbackBar = bar
end

-- Update fallback progress
function Bootstrapper:_updateFallbackProgress(current, total, filename)
    if self._fallbackLabel and self._fallbackBar then
        local percent = total > 0 and (current / total) or 0
        self._fallbackLabel.Text = filename and ("Loading " .. filename .. " (" .. current .. "/" .. total .. ")") or ("Progress: " .. math.floor(percent * 100) .. "%")
        TweenService:Create(self._fallbackBar, TweenInfo.new(0.15), {Size = UDim2.new(percent, -20, 0, 6)}):Play()
    end
end

-- Complete fallback progress
function Bootstrapper:_completeFallbackProgress()
    if self._fallbackGUI then
        self._fallbackGUI:Destroy()
        self._fallbackGUI = nil
        self._fallbackLabel = nil
        self._fallbackBar = nil
    end
end

-- Load all modules with progress tracking
function Bootstrapper:LoadModules()
    self:InitializeSplash()
    
    -- Define all modules to load in order
    local modulePaths = {
        -- Core libraries (load order matters!)
        "lib/util.lua",
        "lib/base_element.lua",
        "lib/theme.lua",
        "lib/tween.lua",
        "lib/fx.lua",
        "lib/behaviors.lua",
        "lib/binds.lua",
        "lib/config.lua",
        "lib/safety.lua",
        "lib/keygate.lua",
        
        -- Components
        "components/button.lua",
        "components/toggle.lua",
        "components/slider.lua",
        "components/dropdown.lua",
        "components/textinput.lua",
        "components/tab.lua",
        "components/window.lua",
        "components/keybind.lua",
        "components/notify.lua",
        "components/announce.lua",
        "components/dock.lua",
        "components/showcase.lua",
        
        -- Main entry point
        "init.lua",
    }
    
    local totalModules = #modulePaths
    local loadedModules = 0
    
    self:SetStatus("Loading core modules...")
    
    -- Load modules
    for i, path in ipairs(modulePaths) do
        local moduleName = path:gsub("%.lua$", "")
        local filename = path:match("([^/]+)$")
        
        if self._isStudio then
            -- In Studio, modules are already available
            loadedModules = loadedModules + 1
            self:UpdateProgress(loadedModules, totalModules, filename)
        else
            -- In executor, fetch from remote
            self:SetStatus(string.format("Fetching %s...", filename))
            
            local moduleCode = self:FetchModule(path)
            if moduleCode then
                self._modules[moduleName] = moduleCode
                loadedModules = loadedModules + 1
                self:UpdateProgress(loadedModules, totalModules, filename)
                
                -- Small delay to show progress
                task.wait(0.05)
            else
                warn("[Fiend/Bootstrapper] Failed to load module:", path)
            end
        end
    end
    
    self:SetStatus("Initializing library...")
    
    -- Set up global require function for executor environment
    if not self._isStudio then
        _G.FiendRequire = self:CreateRequire()
    end
    
    -- Load and return the main module
    local mainModule
    if self._isStudio then
        mainModule = require(script.Parent.init)
    else
        local mainModuleCode = self._modules["init"]
        if not mainModuleCode then
            error("Failed to load Fiend init module")
        end
        
        local env = setmetatable({}, {__index = _G})
        env.require = _G.FiendRequire
        env.script = nil
        
        local fn, err = loadstring(mainModuleCode)
        if not fn then
            error("Failed to parse init module: " .. tostring(err))
        end
        
        setfenv(fn, env)
        local success, result = pcall(fn)
        if not success then
            error("Failed to execute init module: " .. tostring(result))
        end
        
        mainModule = result
    end
    
    -- Store in global for easy access
    local globalEnv = getgenv and getgenv() or _G
    globalEnv.Fiend = mainModule
    
    self:CompleteSplash()
    
    return mainModule
end

-- Quick load function for testing individual modules
function Bootstrapper:LoadModule(path)
    if self._isStudio then
        return nil -- Not needed in Studio
    end
    
    local moduleCode = self:FetchModule(path)
    if moduleCode then
        local modulePath = path:gsub("%.lua$", "")
        self._modules[modulePath] = moduleCode
        return self:CreateRequire()(modulePath)
    end
    return nil
end

-- Main bootstrap function
function Bootstrapper:Bootstrap()
    local success, result = pcall(function()
        return self:LoadModules()
    end)
    
    if not success then
        warn("[Fiend/Bootstrapper] Bootstrap failed:", result)
        if self._splash then
            self._splash:SetStatus("Bootstrap failed: " .. tostring(result))
            task.wait(2)
            self:CompleteSplash()
        end
        return nil
    end
    
    return result
end

return Bootstrapper
