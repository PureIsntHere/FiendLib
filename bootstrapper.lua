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
        
        -- Try to find the module with different path variations
        local moduleCode = self._modules[path]
        
        -- If not found, try alternative paths
        if not moduleCode then
            -- Try removing .lua extension
            local pathNoExt = path:gsub("%.lua$", "")
            moduleCode = self._modules[pathNoExt]
            
            -- Try adding .lua extension
            if not moduleCode then
                moduleCode = self._modules[path .. ".lua"]
            end
            
            -- Try lib/ prefix
            if not moduleCode and not path:match("^lib/") then
                moduleCode = self._modules["lib/" .. path]
            end
            
            -- Try components/ prefix
            if not moduleCode and not path:match("^components/") then
                moduleCode = self._modules["components/" .. path]
            end
        end
        
        if not moduleCode then
            local availableModules = {}
            for k in pairs(self._modules) do
                table.insert(availableModules, k)
            end
            error("Module not found: " .. path .. "\nAvailable modules: " .. table.concat(availableModules, ", "))
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
        "lib/keysystem.lua",
        "lib/theme_manager.lua",
        
        -- Main init file
        "init.lua",
        
        -- Components
        "components/button.lua",
        "components/toggle.lua",
        "components/slider.lua",
        "components/dropdown.lua",
        "components/textinput.lua",
        "components/group.lua",
        "components/tab.lua",
        "components/window.lua",
        "components/keybind.lua",
        "components/notify.lua",
        "components/announce.lua",
        "components/dock.lua",
        "components/splash.lua",
    }
    
    local totalModules = #modulePaths
    local loadedModules = 0
    
    self:SetStatus("Loading core modules...")
    
    -- Set up global require function BEFORE loading modules
    if not self._isStudio then
        _G.FiendRequire = self:CreateRequire()
    end
    
    -- Load modules
    for i, path in ipairs(modulePaths) do
        local moduleName = path:gsub("%.lua$", "")
        local filename = path:match("([^/]+)$")
        
        if self._isStudio then
            -- In Studio, just count modules as loaded (they're already available)
            loadedModules = loadedModules + 1
            self:UpdateProgress(loadedModules, totalModules, filename)
        else
            -- In executor, fetch from remote
            self:SetStatus(string.format("Fetching %s...", filename))
            
            local moduleCode = self:FetchModule(path)
            if moduleCode then
                -- Store with multiple keys for flexible lookup
                self._modules[moduleName] = moduleCode        -- "init"
                self._modules[path] = moduleCode              -- "init.lua"
                
                -- Also store without extension and with path variations
                local nameOnly = path:match("([^/]+)$")       -- Just filename
                self._modules[nameOnly] = moduleCode           -- Just "init"
                
                -- For components and lib files, store accessible keys
                if path:match("^lib/") then
                    local libName = path:gsub("^lib/", "")
                    local libNameNoExt = libName:gsub("%.lua$", "")
                    self._modules[libNameNoExt] = moduleCode
                    self._modules["lib/" .. libNameNoExt] = moduleCode
                end
                
                if path:match("^components/") then
                    local compName = path:gsub("^components/", "")
                    local compNameNoExt = compName:gsub("%.lua$", "")
                    self._modules[compNameNoExt] = moduleCode
                    self._modules["components/" .. compNameNoExt] = moduleCode
                end
                
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
    
    -- Load and return the main module
    local mainModule
    if self._isStudio then
        -- In Studio, create the Fiend library directly instead of requiring init.lua
        local Theme = require(script.Parent.lib.theme)
        local Binds = require(script.Parent.lib.binds)
        local Config = require(script.Parent.lib.config)
        local Window = require(script.Parent.components.window)
        local ThemeManager = require(script.Parent.lib.theme_manager)
        local FX = require(script.Parent.lib.fx)
        
        mainModule = {
            Version = "0.1.0",
            Theme = Theme,
            Binds = Binds,
            Config = Config,
            ThemeManager = ThemeManager,
            FX = FX,
            _isStudio = true,
        }
        
        -- Add methods
        function mainModule:CreateWindow(opts)
            opts = opts or {}
            
            -- Handle theme name resolution
            if opts.Theme and type(opts.Theme) == "string" then
                if self.ThemeManager then
                    local themeData = self.ThemeManager:GetTheme(opts.Theme)
                    if themeData then
                        opts.Theme = themeData
                    else
                        warn("[Fiend] Theme not found:", opts.Theme, "- using default theme")
                        opts.Theme = nil
                    end
                else
                    warn("[Fiend] ThemeManager not available - using default theme")
                    opts.Theme = nil
                end
            end
            
            local window = Window.new(opts)
            
            -- Initialize ThemeManager with the window
            if self.ThemeManager then
                self.ThemeManager:SetLibrary(self)
            end
            
            return window
        end
        
        function mainModule:SetTheme(newTheme)
            if type(newTheme) == "table" then
                for k, v in pairs(newTheme) do
                    self.Theme[k] = v
                end
                self:RefreshAllElements()
            end
        end
        
        function mainModule:RefreshAllElements()
            if self._trackedElements then
                for _, element in ipairs(self._trackedElements) do
                    if element and element.RefreshTheme then
                        element:RefreshTheme()
                    end
                end
                print("[Fiend] Refreshed", #self._trackedElements, "elements with current theme")
            end
        end
        
        function mainModule:_trackElement(element)
            if not self._trackedElements then
                self._trackedElements = {}
            end
            table.insert(self._trackedElements, element)
        end
        
        function mainModule:_untrackElement(element)
            if self._trackedElements then
                for i, e in ipairs(self._trackedElements) do
                    if e == element then
                        table.remove(self._trackedElements, i)
                        break
                    end
                end
            end
        end
        
        -- Set global instance for element tracking
        _G.FiendInstance = mainModule
    else
        -- Try both "init" and "init.lua" as keys
        local mainModuleCode = self._modules["init"] or self._modules["init.lua"]
        if not mainModuleCode then
            local availableModules = {}
            for k in pairs(self._modules) do
                table.insert(availableModules, k)
            end
            error("Failed to load Fiend init module. Available modules: " .. table.concat(availableModules, ", "))
        end
        
        local env = setmetatable({}, {__index = _G})
        env.require = self:CreateRequire()
        env.script = { Parent = { Parent = {} } }
        
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
        
        -- Add methods that depend on loaded modules
        function mainModule:CreateWindow(opts)
            opts = opts or {}
            
            -- Handle theme name resolution
            if opts.Theme and type(opts.Theme) == "string" then
                if self.ThemeManager then
                    local themeData = self.ThemeManager:GetTheme(opts.Theme)
                    if themeData then
                        opts.Theme = themeData
                    else
                        warn("[Fiend] Theme not found:", opts.Theme, "- using default theme")
                        opts.Theme = nil
                    end
                else
                    warn("[Fiend] ThemeManager not available - using default theme")
                    opts.Theme = nil
                end
            end
            
            -- Get Window module
            local Window = _G.FiendRequire("components/window")
            local window = Window.new(opts)
            
            -- Initialize ThemeManager with the window
            if self.ThemeManager then
                self.ThemeManager:SetLibrary(self)
            end
            
            return window
        end
        
        function mainModule:CreateNotification()
            local Notify = _G.FiendRequire("components/notify")
            return Notify.new(self.Theme)
        end
        
        function mainModule:CreateAnnouncement()
            local Announce = _G.FiendRequire("components/announce")
            return Announce.new(self.Theme)
        end
        
        function mainModule:SetTheme(theme)
            if type(theme) == "string" then
                local themeData = self.ThemeManager:GetTheme(theme)
                if themeData then
                    self.Theme = themeData
                    self:RefreshAllElements()
                end
            elseif type(theme) == "table" then
                for k, v in pairs(theme) do
                    self.Theme[k] = v
                end
                self:RefreshAllElements()
            end
        end
        
        function mainModule:RefreshAllElements()
            if self._trackedElements then
                for _, element in ipairs(self._trackedElements) do
                    if element and element.RefreshTheme then
                        element:RefreshTheme()
                    end
                end
            end
        end
        
        function mainModule:_trackElement(element)
            if not self._trackedElements then
                self._trackedElements = {}
            end
            table.insert(self._trackedElements, element)
        end
        
        function mainModule:_untrackElement(element)
            if self._trackedElements then
                for i, e in ipairs(self._trackedElements) do
                    if e == element then
                        table.remove(self._trackedElements, i)
                        break
                    end
                end
            end
        end
        
        -- Set global instance for element tracking
        _G.FiendInstance = mainModule
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
