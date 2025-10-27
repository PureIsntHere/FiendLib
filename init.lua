-- Fiend/init.lua
-- Public entrypoint for the Fiend UI Library (Executor-only)

-- Load core dependencies from FiendModules
local Theme = FiendModules.Theme
local Config = FiendModules.Config
local Window = FiendModules.Window
local ThemeManager = FiendModules.ThemeManager

-- Safety check - make sure we got valid objects
if not Theme then
    error("[Fiend] Failed to load Theme module")
end
if not Config then
    error("[Fiend] Failed to load Config module")
end
if not Window then
    error("[Fiend] Failed to load Window module")
end

local Fiend = {
    Version = "0.1.0",
    Theme   = Theme,
    Config  = Config,
    ThemeManager = ThemeManager,
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
    if type(newTheme) == "string" then
        -- Theme name provided, use ThemeManager
        if self.ThemeManager then
            local themeData = self.ThemeManager:GetTheme(newTheme)
            if themeData then
                for k, v in pairs(themeData) do
                    self.Theme[k] = v
                end
                self:RefreshAllElements()
                print("[Fiend] Applied theme:", newTheme)
            else
                warn("[Fiend] Theme not found:", newTheme)
            end
        else
            warn("[Fiend] ThemeManager not available")
        end
    elseif type(newTheme) == "table" then
        -- Theme table provided
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

-- Create notification system
function Fiend:CreateNotification()
    local Notify = FiendModules.Notify
    return Notify.new(self.Theme)
end

-- Create announcement system
function Fiend:CreateAnnouncement()
    local Announce = FiendModules.Announce
    return Announce.new(self.Theme)
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