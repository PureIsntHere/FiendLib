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
        
        -- Try with lib/ prefix
        if not moduleCode and not path:match("^lib/") then
            moduleCode = Modules["lib/" .. path:gsub("%.lua$", "")]
        end
        
        -- Try with components/ prefix
        if not moduleCode and not path:match("^components/") then
            moduleCode = Modules["components/" .. path:gsub("%.lua$", "")]
        end
        
        if not moduleCode then
            -- Debug: show what we're looking for
            print("[DEBUG] Failed to find module:", path)
            print("[DEBUG] Trying common variations...")
            local variations = {path, path:gsub("%.lua$", ""), "lib/" .. path:gsub("%.lua$", "")}
            for _, v in ipairs(variations) do
                print("  Checking:", v, Modules[v] and "✓" or "✗")
            end
            
            local available = {}
            local count = 0
            for k in pairs(Modules) do
                table.insert(available, k)
                count = count + 1
                if count > 10 then break end
            end
            error("Module not found: " .. tostring(path) .. "\nFirst 10 available: " .. table.concat(available, ", "))
        end
        
        -- Create environment with all globals
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
            error("Failed to execute module " .. path .. ": " .. tostring(result))
        end
        
        if not result then
            error("Module " .. path .. " did not return a value")
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
        -- Store with multiple keys for flexible lookup
        local nameWithoutExt = path:gsub("%.lua$", "")
        local nameOnly = path:match("([^/]+)$"):gsub("%.lua$", "")
        
        Modules[path] = content
        Modules[nameWithoutExt] = content
        Modules[nameOnly] = content
        
        -- For lib and components, add additional lookup keys
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
        warn("Failed to load:", path)
    end
end

print("✅ All modules loaded (" .. #moduleList .. " files)")

-- Set up global require BEFORE we try to use it
local require = createRequire()

-- Create base environment for executing modules
local baseEnv = {}
for k, v in pairs(_G) do
    baseEnv[k] = v
end
baseEnv.game = game
baseEnv.workspace = workspace
baseEnv.require = require

-- Store the base environment
_G.FiendBaseEnv = baseEnv

print("✅ Module system initialized")

-- Now execute init
local Fiend = require("init")

print("✅ Fiend UI Library loaded successfully!")
print("📊 Version:", Fiend.Version)

return Fiend

