-- Fiend UI Library - Executor Version
-- Simple, standalone version for executor usage
-- Usage: local Fiend = loadstring(game:HttpGet('https://raw.githubusercontent.com/PureIsntHere/FiendLib/ExecutorVersion/Fiend.lua'))()

local repo = 'https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/'

-- Load all dependencies and build the library
local Library = {}

print("🔨 Loading Fiend UI Library...")

-- Load in dependency order
local UtilModule = loadstring(game:HttpGet(repo .. 'lib/util.lua'))()
local ThemeModule = loadstring(game:HttpGet(repo .. 'lib/theme.lua'))()
local TweenModule = loadstring(game:HttpGet(repo .. 'lib/tween.lua'))()
local FXModule = loadstring(game:HttpGet(repo .. 'lib/fx.lua'))()
local BehaviorsModule = loadstring(game:HttpGet(repo .. 'lib/behaviors.lua'))()
local SafetyModule = loadstring(game:HttpGet(repo .. 'lib/safety.lua'))()
local KeySystemModule = loadstring(game:HttpGet(repo .. 'lib/keysystem.lua'))()
local BindsModule = loadstring(game:HttpGet(repo .. 'lib/binds.lua'))()
local ConfigModule = loadstring(game:HttpGet(repo .. 'lib/config.lua'))()
local BaseElementModule = loadstring(game:HttpGet(repo .. 'lib/base_element.lua'))()
local ThemeManagerModule = loadstring(game:HttpGet(repo .. 'lib/theme_manager.lua'))()

print("✅ Core modules loaded")

-- Load components
local ButtonComponent = loadstring(game:HttpGet(repo .. 'components/button.lua'))()
local ToggleComponent = loadstring(game:HttpGet(repo .. 'components/toggle.lua'))()
local SliderComponent = loadstring(game:HttpGet(repo .. 'components/slider.lua'))()
local DropdownComponent = loadstring(game:HttpGet(repo .. 'components/dropdown.lua'))()
local TextInputComponent = loadstring(game:HttpGet(repo .. 'components/textinput.lua'))()
local GroupComponent = loadstring(game:HttpGet(repo .. 'components/group.lua'))()
local TabComponent = loadstring(game:HttpGet(repo .. 'components/tab.lua'))()
local DockComponent = loadstring(game:HttpGet(repo .. 'components/dock.lua'))()
local KeybindComponent = loadstring(game:HttpGet(repo .. 'components/keybind.lua'))()
local NotifyComponent = loadstring(game:HttpGet(repo .. 'components/notify.lua'))()
local AnnounceComponent = loadstring(game:HttpGet(repo .. 'components/announce.lua'))()
local WindowComponent = loadstring(game:HttpGet(repo .. 'components/window.lua'))()

print("✅ Components loaded")

-- Create the library object
Library.Version = "1.0.0"
Library.Theme = ThemeModule
Library.Binds = BindsModule
Library.Config = ConfigModule
Library.ThemeManager = ThemeManagerModule

-- Store global instance
getgenv().FiendInstance = Library

-- CreateWindow function
function Library:CreateWindow(opts)
    opts = opts or {}
    
    -- Handle theme name resolution
    if opts.Theme and type(opts.Theme) == "string" then
        if self.ThemeManager and self.ThemeManager.GetTheme then
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
    
    local window = WindowComponent.new(opts)
    
    -- Initialize ThemeManager
    if self.ThemeManager and self.ThemeManager.SetLibrary then
        self.ThemeManager:SetLibrary(self)
    end
    
    return window
end

-- SetTheme function
function Library:SetTheme(newTheme)
    if type(newTheme) == "string" then
        if self.ThemeManager and self.ThemeManager.GetTheme then
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
        for k, v in pairs(newTheme) do
            self.Theme[k] = v
        end
        self:RefreshAllElements()
    end
end

-- Refresh all elements
function Library:RefreshAllElements()
    if self._trackedElements then
        for _, element in ipairs(self._trackedElements) do
            if element and element.RefreshTheme then
                element:RefreshTheme()
            end
        end
    end
end

-- Track element
function Library:_trackElement(element)
    if not self._trackedElements then
        self._trackedElements = {}
    end
    table.insert(self._trackedElements, element)
end

-- Untrack element
function Library:_untrackElement(element)
    if self._trackedElements then
        for i, e in ipairs(self._trackedElements) do
            if e == element then
                table.remove(self._trackedElements, i)
                break
            end
        end
    end
end

-- Create notification
function Library:CreateNotification()
    return NotifyComponent.new(self.Theme)
end

-- Create announcement
function Library:CreateAnnouncement()
    return AnnounceComponent.new(self.Theme)
end

-- Serialization helpers
function Library:SerializeConfig()
    if self.Config and self.Config.Serialize then
        return self.Config:Serialize()
    end
    return "{}"
end

function Library:DeserializeConfig(json)
    if self.Config and self.Config.Deserialize then
        return self.Config:Deserialize(json)
    end
    return false
end

print("✅ Fiend UI Library loaded successfully!")
print("📊 Version:", Library.Version)

return Library

