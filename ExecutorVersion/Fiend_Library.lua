--[[
    Fiend UI Library - Executor Version
    Self-contained single-file library
    
    Usage in executor:
    local Fiend = loadstring(game:HttpGet('https://raw.githubusercontent.com/PureIsntHere/FiendLib/ExecutorVersion/Fiend_Library.lua'))()
    
    Then use it:
    local window = Fiend:CreateWindow({Title = "My Script", Theme = "Tokyo Night"})
]]

local repo = 'https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/'

-- Module storage
local Modules = {}
local Cache = {}

-- Load a single module
local function fetchModule(path)
    local success, content = pcall(function()
        return game:HttpGet(repo .. path)
    end)
    if success and content then
        return content
    end
    return nil
end

-- Create require function
local function createRequire()
    return function(path)
        -- Check cache
        if Cache[path] then
            return Cache[path]
        end
        
        -- Try various path formats
        local moduleCode = Modules[path]
        if not moduleCode then
            moduleCode = Modules[path:gsub("%.lua$", "")]
        end
        if not moduleCode and not path:match("^lib/") then
            moduleCode = Modules["lib/" .. path:gsub("%.lua$", "")]
        end
        if not moduleCode and not path:match("^components/") then
            moduleCode = Modules["components/" .. path:gsub("%.lua$", "")]
        end
        
        if not moduleCode then
            local available = {}
            for k in pairs(Modules) do
                table.insert(available, k)
                if #available > 20 then break end
            end
            error("Module not found: " .. tostring(path) .. "\nAvailable: " .. table.concat(available, ", "))
        end
        
        -- Create environment
        local env = {}
        for k, v in pairs(getfenv(0)) do
            env[k] = v
        end
        env.game = game
        env.require = createRequire()
        env.script = { Parent = { Parent = {} } }
        
        -- Execute module
        local fn, err = loadstring(moduleCode)
        if not fn then
            error("Failed to parse module: " .. tostring(err))
        end
        
        setfenv(fn, env)
        local success, result = pcall(fn)
        if not success then
            error("Failed to execute module " .. path .. ": " .. tostring(result))
        end
        
        if not result then
            error("Module " .. path .. " returned nil")
        end
        
        Cache[path] = result
        return result
    end
end

-- Fetch all modules
print("🔨 Loading Fiend UI Library...")

local moduleList = {
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
    "init.lua",
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
}

-- Load all files
for _, path in ipairs(moduleList) do
    local content = fetchModule(path)
    if content then
        -- Store with multiple keys for flexible lookup
        local nameWithoutExt = path:gsub("%.lua$", "")
        local nameOnly = path:match("([^/]+)$"):gsub("%.lua$", "")
        
        Modules[path] = content
        Modules[nameWithoutExt] = content
        Modules[nameOnly] = content
        
        if path:match("^lib/") then
            local libName = nameWithoutExt:gsub("^lib/", "")
            Modules["lib/" .. libName] = content
            Modules[libName] = content
        elseif path:match("^components/") then
            local compName = nameWithoutExt:gsub("^components/", "")
            Modules["components/" .. compName] = content
            Modules[compName] = content
        end
    else
        warn("⚠️ Failed to load:", path)
    end
end

print("✅ All modules loaded")

-- Set up require
local require = createRequire()

-- Store modules and require globally
getgenv().FiendModules = Modules
getgenv().FiendRequire = require

-- Set up script mock
local scriptMock = {Parent = {Parent = {}}}

print("✅ Module system initialized")

-- Execute init module
local Fiend = require("init")

if not Fiend then
    error("Failed to load Fiend library - init module returned nil")
end

print("✅ Fiend UI Library ready!")
print("📊 Version:", Fiend.Version or "Unknown")

-- Cleanup (optional)
getgenv().FiendModules = nil
getgenv().FiendRequire = nil

return Fiend

