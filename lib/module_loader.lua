-- Fiend/lib/module_loader.lua
-- Dual-mode module system for Studio and Executor environments

local ModuleLoader = {}
ModuleLoader._cache = {}
ModuleLoader._modules = {}
ModuleLoader._isStudio = game:GetService("RunService"):IsStudio()

-- Register a module (for loadstring mode)
function ModuleLoader:Register(path, moduleFunc)
    self._modules[path] = moduleFunc
end

-- Custom require that works in both environments
function ModuleLoader:Require(path)
    -- Check cache first
    if self._cache[path] then
        return self._cache[path]
    end
    
    -- Studio mode: use normal require
    if self._isStudio then
        local success, module = pcall(function()
            -- Convert path like "lib/theme" to script.Parent.lib.theme
            local parts = string.split(path, "/")
            local current = script.Parent.Parent -- Adjust based on where this file is
            
            for i, part in ipairs(parts) do
                if part ~= "" then
                    current = current[part]
                end
            end
            
            return require(current)
        end)
        
        if success then
            self._cache[path] = module
            return module
        else
            error("Failed to require module in Studio: " .. path)
        end
    else
        -- Executor mode: use registered modules
        local moduleFunc = self._modules[path]
        if not moduleFunc then
            error("Module not found: " .. path)
        end
        
        -- Execute and cache
        local module = moduleFunc()
        self._cache[path] = module
        return module
    end
end

-- Create a require proxy for modules
function ModuleLoader:CreateRequire()
    return function(path)
        -- Handle different path formats
        if typeof(path) == "Instance" then
            -- Studio mode with Instance paths
            return require(path)
        elseif type(path) == "string" then
            -- Our custom path format
            return self:Require(path)
        else
            error("Invalid require path: " .. tostring(path))
        end
    end
end

return ModuleLoader