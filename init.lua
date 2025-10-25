-- Fiend/init.lua
-- Public entrypoint for the Fiend UI Library (dual-mode)

-- Detect environment and set up require
local require = require
local script = script

-- In executor environment, these will be set by the loader
if not script then
    script = { Parent = { Parent = {} } }
    require = _G.FiendRequire or require
end

-- Try to detect if we're in Studio or Executor
local isStudio = game:GetService("RunService"):IsStudio()

-- Load core dependencies based on environment
local Theme, Binds, Config, Window

if isStudio then
    -- Studio mode: use normal requires
    Theme  = require(script.Parent.lib.theme)
    Binds  = require(script.Parent.lib.binds)
    Config = require(script.Parent.lib.config)
    Window = require(script.Parent.components.window)
else
    -- Executor mode: use custom require
    Theme  = require("lib/theme")
    Binds  = require("lib/binds")
    Config = require("lib/config")
    Window = require("components/window")
end

local Fiend = {
    Version = "0.1.0",
    Theme   = Theme,
    Binds   = Binds,
    Config  = Config,
    _isStudio = isStudio,
}

-- Create a new top-level window
function Fiend:CreateWindow(opts)
    opts = opts or {}
    return Window.new(opts)
end

-- Optional: apply a different theme object at runtime
function Fiend:SetTheme(newTheme)
    if type(newTheme) == "table" then
        for k, v in pairs(newTheme) do
            self.Theme[k] = v
        end
    end
end

-- Convenience passthroughs for serialization
function Fiend:SerializeConfig()
    if self.Config and self.Config.Serialize then
        return self.Config:Serialize()
    end
    return "{}"
end

function Fiend:DeserializeConfig(json)
    if self.Config and self.Config.Deserialize then
        return self.Config:Deserialize(json)
    end
    return false
end

return Fiend