# Fiend UI Library

A Roblox UI Library

## What you can do

* Create windows with multiple tabs and groups
* Use different themes with runtime switching
* Add toggles, buttons, sliders, dropdowns, and text inputs
* Set up custom keybinds with toggle/hold/press modes
* Show notifications and announcements
* Automatically save and load configurations
* Organize UI with automatic group layout
* Modify Components during runtime
* Create / Remove components during runtime

## Download

Load the bootstrapper

```lua
local Bootstrapper = loadstring(game:HttpGet('https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/bootstrapper.lua'))()
local Fiend = Bootstrapper:Bootstrap()
```

## Key System

Fiend includes an optional keysystem

note: No content is created before the key is passed for security. This will also cause errors if you try to reference gui components before the key is passed.

### Basic Setup

```lua
local Bootstrapper = loadstring(game:HttpGet('https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/bootstrapper.lua'))()
local Fiend = Bootstrapper:Bootstrap({
    KeySystem = {
        Enabled = true,
        Key = "YourSecretKey123",
        Title = "Your Script Access",
        Hint = "Enter the access key to use this script",
        MaxAttempts = 3,
        OnSuccess = function()
            print("Access granted!")
        end,
        OnFail = function()
            print("Access denied!")
        end
    }
})
```

### Advanced Validation

For more advanced key systems

```lua
local Fiend = Bootstrapper:Bootstrap({
    KeySystem = {
        Enabled = true,
        Title = "Premium Access",
        Hint = "Enter your license key",
        MaxAttempts = 1,
        ValidateKey = function(inputKey)
            -- Custom validation logic with executor-specific HTTP
            local function fetchWithExecutor(url)
                local env = getfenv and getfenv() or _G
                local httpFuncs = {"httpget", "http_request", "request", "http.request"}
                
                for i = 1, #httpFuncs do
                    local func = env[httpFuncs[i]]
                    if func and typeof(func) == "function" then
                        if httpFuncs[i] == "httpget" then
                            -- httpget(url: string): string - most common executor format
                            local success, result = pcall(func, url)
                            if success and result and type(result) == "string" then
                                return result
                            end
                        else
                            local success, result = pcall(func, {Url = url, Method = "GET"})
                            if success and result then
                                return result.Body or result
                            end
                        end
                    end
                end
                -- Fallback to game:HttpGet
                return game:HttpGet(url)
            end
            
            local success, response = pcall(function()
                return fetchWithExecutor("https://your-api.com/validate?key=" .. inputKey)
            end)
            return success and response == "valid"
        end,
        OnSuccess = function()
            print("License verified!")
        end
    }
})
```

### Custom Splash Screen

Customize the loading screen that appears while the library initializes:

```lua
local Fiend = Bootstrapper:Bootstrap({
    SplashScreen = {
        Enabled = true,
        Title = "My Script v2.0",
        SubTitle = "Loading Features...",
        ShowProgress = true
        -- Grid patterns and glow effects are disabled by default
        -- ShowGridPattern = true,    -- Enable retro-futuristic grid background
        -- ShowGlowEffects = true,    -- Add glowing effects
        -- ShowDecorations = true     -- Show accent lines
    }
})
```

**Splash Screen Options:**
- `Enabled` - Show splash screen (default: true)
- `Title` - Main title text
- `SubTitle` - Subtitle text
- `ShowProgress` - Show loading progress bar (default: false)
- `ShowGridPattern` - Display grid background (default: false)
- `ShowGlowEffects` - Add glowing effects to text and progress (default: false)
- `ShowDecorations` - Show accent lines and decorative elements (default: false)

**Note:** The default is clean black and white. To use other themes use theme_manager.lua.

## Quick start

The typical use case is creating a window with tabs and controls:

```lua
local Bootstrapper = loadstring(game:HttpGet('https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/bootstrapper.lua'))()
local Fiend = Bootstrapper:Bootstrap()

local window = Fiend:CreateWindow({
    Title = "My Script",
    SubTitle = "Features"
})

local main = window:AddTab("Main")

-- Add components directly to tab
main:AddToggle("Enable Feature", false, function(value)
    print("Feature:", value)
end)

main:AddSlider("Speed", 1, 100, 50, function(value)
    print("Speed:", value)
end)

main:AddButton("Activate", function()
    print("Activated!")
end)

-- Or use groups to organize
local farmGroup = main:AddGroup({Name = "Farming", Size = Vector2.new(0.5, 1)})
farmGroup:AddToggle("Auto Farm", false, function(value)
    print("Auto farm:", value)
end)
```

This creates a window with a toggle, slider, and button.

## Themes

The library includes 14 built-in themes: Default, Tokyo Night, Mint, Jester, Fatality, Ubuntu, Quartz, BBot, Nord, Dracula, October, Retro Futurism, Solarized Dark, Monokai.

Switch themes at runtime using the ThemeManager:

```lua
Fiend.ThemeManager:SetLibrary(Fiend)
Fiend.ThemeManager:ApplyTheme("Tokyo Night")
```

## Components

Components can be added directly to tabs or organized in groups. Groups are optional and useful for organizing multiple controls.

**Adding to a tab directly:**
```lua
local tab = window:AddTab("Main")

tab:AddToggle("Enable Feature", false, function(value)
    print("Feature:", value)
end)

tab:AddButton("Activate", function()
    print("Activated!")
end)
```

**Using groups for organization:**

```lua
-- Group with full control
local group = tab:AddGroup({
    Name = "Features",
    Size = Vector2.new(0.5, 1),      -- Width and height (1 = full)
    Position = Vector2.new(0, 0)     -- Grid position (optional)
})

-- Simple group (full size)
local simpleGroup = tab:AddGroup("Settings")
```

### Available Components

**AddToggle** - Boolean switches
```lua
group:AddToggle("Auto Farm", false, function(value)
    print("Toggle:", value)
end)
```

**AddButton** - Action buttons
```lua
group:AddButton("Start Farm", function()
    print("Farm started!")
end)
```

**AddSlider** - Value sliders
```lua
group:AddSlider("Speed", 1, 100, 50, function(value)
    print("Speed:", value)
end)
-- Parameters: text, min, max, default, callback
```

**AddDropdown** - Selection dropdowns
```lua
group:AddDropdown("Mode", {"Instant", "Normal", "Safe"}, 1, function(selected)
    print("Mode:", selected)
end)
-- Parameters: label, options array, default index, callback
```

**AddTextInput** - Text input fields
```lua
group:AddTextInput("Username", "Enter username", "", function(value)
    print("Username:", value)
end)
-- Parameters: label, placeholder, default value, callback
```

**AddKeybind** - Custom keybinds
```lua
group:AddKeybind("Farm Key", Enum.KeyCode.F, function(value, mode)
    print("Key:", value, "Mode:", mode)
end)
-- Parameters: label, default key, callback
```

### Groups (Optional)

Groups are containers that help organize your UI. They automatically scale elements to fit the available space. When multiple groups exist in a tab, they split the available space automatically.

```lua
-- Two groups side-by-side
local leftGroup = tab:AddGroup({Name = "Left", Size = Vector2.new(0.5, 1)})
local rightGroup = tab:AddGroup({Name = "Right", Size = Vector2.new(0.5, 1), Position = Vector2.new(0.5, 0)})

-- Four groups in a 2x2 grid
local topLeft = tab:AddGroup({Name = "Top Left", Size = Vector2.new(0.5, 0.5)})
local topRight = tab:AddGroup({Name = "Top Right", Size = Vector2.new(0.5, 0.5), Position = Vector2.new(0.5, 0)})
local bottomLeft = tab:AddGroup({Name = "Bottom Left", Size = Vector2.new(0.5, 0.5), Position = Vector2.new(0, 0.5)})
local bottomRight = tab:AddGroup({Name = "Bottom Right", Size = Vector2.new(0.5, 0.5), Position = Vector2.new(0.5, 0.5)})
```

Element sizes automatically scale based on group size to prevent collisions.

## Advanced Usage

### Window Options

When creating a window, you can customize the appearance:

```lua
local window = Fiend:CreateWindow({
    Title = "My Script",
    SubTitle = "Description here",
    Theme = "Tokyo Night",  -- Optional theme
    AutoShow = true         -- Optional auto-show (default true)
})
```

### Tabs

Tabs organize your UI. Multiple tabs create a tab bar at the top:

```lua
local tab1 = window:AddTab("Main")
local tab2 = window:AddTab("Settings")  
local tab3 = window:AddTab("About")
```

### Notifications

Show in-game notifications:

```lua
local notify = Fiend:CreateNotification()
notify:AttachTo(window.Shell)
notify:Push("Hello World!", 5)  -- Message and duration in seconds
```

### Announcements

Display full-screen announcements:

```lua
_G.FiendModules.Announce.Show(window, {
    Title = "Important",
    Message = "This is an announcement",
    Buttons = {
        {Text = "OK", Primary = true},
        {Text = "Cancel", Primary = false}
    }
})
```

### Window Controls

Control your window programmatically:

```lua
window:Toggle()      -- Show/hide
window:Hide()        -- Hide
window:Show()        -- Show
window:Destroy()     -- Remove window
```

## Configuration

The config system automatically saves and loads your settings:

```lua
local Config = FiendModules.Config
local config = Config.new({
    folder = "MyConfigs",
    filename = "settings.json"
})

config:Set("AutoFarm", true)
config:Set("FarmSpeed", 50)
config:Save()
```

See [test.lua](test.lua) for a complete working example.

## Documentation

### Basic usage

* [Getting Started](#quick-start) - Create your first window
* [Window Options](#components) - Customize window appearance
* [Theme Management](#themes) - Switch themes dynamically
* [Config System](#configuration) - Save user settings

### Advanced features

* Groups and tabs with automatic layout
* Notifications and announcements
* Keybind system with multiple modes
* Element scaling in groups

## Building (Optional)

If you need a single-file build, use the build script:

```bash
cd ExecutorVersion
python build.py
```

This generates a standalone `Fiend_Built.lua` file.

## License

MIT License - feel free to use in your projects
