-- Fiend UI Library - Executor Standalone Loader
-- Simple loader similar to Linoria's approach
-- Usage in executor: 
-- local Fiend = loadstring(game:HttpGet('https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/Fiend_Standalone.lua'))()

local repo = 'https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/'

-- Module storage
local Modules = {}
local Cache = {}

-- Load all module files
local function fetchModule(path)
    local success, content = pcall(function()
        return game:HttpGet(repo .. path)
    end)
    return success and content
end

-- Create require function
local function createRequire()
    return function(path)
        -- Check cache first
        if Cache[path] then
            return Cache[path]
        end
        
        -- Try various path formats
        local moduleCode = Modules[path] 
        if not moduleCode then
            moduleCode = Modules[path:gsub("%.lua$", "")]
        end
        
        if not moduleCode then
            error("Module not found: " .. tostring(path))
        end
        
        -- Create environment
        local env = {}
        for k, v in pairs(_G) do
            env[k] = v
        end
        env.game = game
        env.workspace = workspace
        env.script = { Parent = { Parent = {} } }
        env.require = createRequire() -- Allow nested requires
        
        -- Execute module
        local fn, err = loadstring(moduleCode)
        if not fn then
            error("Failed to parse module: " .. tostring(err))
        end
        
        setfenv(fn, env)
        local success, result = pcall(fn)
        if not success then
            error("Failed to execute module: " .. tostring(result))
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

-- Load all modules into memory
for _, path in ipairs(moduleList) do
    local content = fetchModule(path)
    if content then
        Modules[path] = content
        Modules[path:gsub("%.lua$", "")] = content -- Also store without extension
    else
        warn("Failed to load:", path)
    end
end

print("✅ All modules loaded")

-- Set up global require
local require = createRequire()
_G.require = require

-- Now execute init
local Fiend = require("init.lua")

print("✅ Fiend UI Library loaded successfully!")
print("📊 Version:", Fiend.Version)

return Fiend

