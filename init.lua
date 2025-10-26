-- Fiend/init.lua
-- Public entrypoint for the Fiend UI Library (dual-mode)

-- Detect environment and set up require
local require = require
local script = script

-- In executor environment, these will be set by the loader
-- Check if script exists (it won't in executor mode)
local hasScript = script ~= nil

if not hasScript then
    -- Set up executor environment
    script = { Parent = { Parent = {} } }
    -- require is already set by the bootstrapper's env
end

-- Try to detect if we're in Studio or Executor
local isStudio = game:GetService("RunService"):IsStudio()

-- Load core dependencies based on environment
local Theme, Binds, Config, Window, ThemeManager

if isStudio or hasScript then
    -- Studio mode: use normal requires
    Theme  = require(script.Parent.lib.theme)
    Binds  = require(script.Parent.lib.binds)
    Config  = require(script.Parent.lib.config)
    Window = require(script.Parent.components.window)
    ThemeManager = require(script.Parent.lib.theme_manager)
else
    -- Executor mode: use custom require
    Theme  = require("lib/theme")
    Binds  = require("lib/binds")
    Config = require("lib/config")
    Window = require("components/window")
    ThemeManager = require("lib/theme_manager")
end

local Fiend = {
    Version = "0.1.0",
    Theme   = Theme,
    Binds   = Binds,
    Config  = Config,
    ThemeManager = ThemeManager,
    _isStudio = isStudio,
}

-- Set global instance for element tracking
_G.FiendInstance = Fiend

-- Create a new top-level window
function Fiend:CreateWindow(opts)
    opts = opts or {}
    
    -- Handle theme name resolution
    if opts.Theme and type(opts.Theme) == "string" then
        if self.ThemeManager then
            local themeData = self.ThemeManager:GetTheme(opts.Theme)
            if themeData then
                opts.Theme = themeData
            else
                warn("[Fiend] Theme not found:", opts.Theme, "- using default theme")
                opts.Theme = nil -- Will use default theme
            end
        else
            warn("[Fiend] ThemeManager not available - using default theme")
            opts.Theme = nil -- Will use default theme
        end
    end
    
    local window = Window.new(opts)
    
    -- Initialize ThemeManager with the window
    if self.ThemeManager then
        self.ThemeManager:SetLibrary(self)
    end
    
    return window
end

-- Optional: apply a different theme object at runtime
function Fiend:SetTheme(newTheme)
    if type(newTheme) == "table" then
        for k, v in pairs(newTheme) do
            self.Theme[k] = v
        end
        -- Refresh all existing elements
        self:RefreshAllElements()
    end
end

-- Refresh all UI elements with current theme
function Fiend:RefreshAllElements()
    if self._trackedElements then
        for _, element in ipairs(self._trackedElements) do
            if element and element.RefreshTheme then
                element:RefreshTheme()
            end
        end
        print("[Fiend] Refreshed", #self._trackedElements, "elements with current theme")
    end
end

-- Create a new theme-aware element tracker
function Fiend:_trackElement(element)
    if not self._trackedElements then
        self._trackedElements = {}
    end
    table.insert(self._trackedElements, element)
end

-- Remove element from tracking
function Fiend:_untrackElement(element)
    if self._trackedElements then
        for i, tracked in ipairs(self._trackedElements) do
            if tracked == element then
                table.remove(self._trackedElements, i)
                break
            end
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