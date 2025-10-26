-- Simple Executor Test Script for Fiend UI Library
-- This script demonstrates the core functionality in an executor environment
-- Loads the library from GitHub for executors without ReplicatedStorage access
--
-- USAGE INSTRUCTIONS:
-- 1. The script will automatically load from the GitHub repository
-- 2. Repository: https://github.com/PureIsntHere/FiendLib
-- 3. Run this script in your executor - it will load the library remotely
--
-- ALTERNATIVE: If you have the library files locally, you can modify the loadLibrary()
-- function to load from a different source (pastebin, raw file hosting, etc.)

print("🚀 Starting Fiend UI Library Executor Test...")

-- Load the library from GitHub
local function loadLibrary()
    -- Method 1: Try loading from GitHub
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/bootstrapper.lua"))()
    end)
    
    if success and result then
        print("✅ Loaded from GitHub")
        return result:Bootstrap()
    else
        print("⚠️ GitHub loading failed:", result)
    end
    
    -- Method 2: Try loading from ReplicatedStorage (fallback for executors that do have it)
    local success2, result2 = pcall(function()
        local Bootstrapper = require(game:GetService("ReplicatedStorage").Fiend.bootstrapper)
        return Bootstrapper:Bootstrap()
    end)
    
    if success2 and result2 then
        print("✅ Loaded from ReplicatedStorage")
        return result2
    else
        print("⚠️ ReplicatedStorage loading failed:", result2)
    end
    
    -- Method 3: Try loading from a pastebin or other source
    -- Uncomment and modify the URL below if you want to use an alternative source
    --[[
    local success3, result3 = pcall(function()
        return loadstring(game:HttpGet("https://pastebin.com/raw/YOUR_PASTEBIN_ID"))()
    end)
    
    if success3 and result3 then
        print("✅ Loaded from alternative source")
        return result3:Bootstrap()
    else
        print("⚠️ Alternative source loading failed:", result3)
    end
    --]]
    
    print("❌ All loading methods failed!")
    return nil
end

local Fiend = loadLibrary()

if not Fiend then
    print("❌ Failed to load Fiend UI Library!")
    return
end

print("✅ Fiend UI Library loaded successfully!")
print("📊 Version:", Fiend.Version or "Unknown")

-- Create a window with dock and theme system
local window = Fiend:CreateWindow({
    Title = "Executor Test",
    Subtitle = "Simple Test Script",
    Theme = "Tokyo Night",
    DockMode = "DockOnly",
    Size = UDim2.new(0, 500, 0, 400),
    Position = UDim2.new(0.5, -250, 0.5, -200)
})

if not window then
    print("❌ Failed to create window!")
    return
end

print("✅ Window created successfully!")

-- Create notification system
local notify = Fiend:CreateNotification()
notify:AttachTo(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))

-- Create announcement system
local announce = Fiend:CreateAnnouncement()
announce:AttachTo(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))

-- Create tabs
local mainTab = window:AddTab("Main")
local themeTab = window:AddTab("Themes")
local testTab = window:AddTab("Test")

-- Main tab content
local mainGroup = mainTab:AddGroup("Basic Components")

-- Add a toggle
local toggle = mainGroup:AddToggle("Test Toggle", false, function(value)
    print("🔄 Toggle value:", value)
    notify:Push("Toggle changed to: " .. tostring(value))
end)

-- Add a button
local button = mainGroup:AddButton("Test Button", function()
    print("🔘 Button clicked!")
    notify:Push("Button was clicked!")
end)

-- Add a slider
local slider = mainGroup:AddSlider("Test Slider", 0, 100, 50, function(value)
    print("📊 Slider value:", value)
end)

-- Add a text input
local textInput = mainGroup:AddTextInput("Test Input", "Type something...", function(value)
    print("📝 Input value:", value)
    notify:Push("Input: " .. tostring(value))
end)

-- Add a dropdown
local dropdown = mainGroup:AddDropdown("Test Dropdown", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(value)
    print("📋 Dropdown value:", value)
    notify:Push("Selected: " .. tostring(value))
end)

-- Theme tab content
local themeGroup = themeTab:AddGroup("Theme Controls")

-- Add theme buttons
local themes = {"Default", "Tokyo Night", "Mint", "Dracula", "Nord", "Jester", "October", "Retro Futurism"}
for _, themeName in ipairs(themes) do
    themeGroup:AddButton(themeName, function()
        Fiend:SetTheme(themeName)
        notify:Push("Theme changed to: " .. themeName)
        print("🎨 Theme changed to:", themeName)
    end)
end

-- Test tab content
local testGroup = testTab:AddGroup("Test Functions")

-- Test instant updates
testGroup:AddButton("Test Instant Updates", function()
    -- Test instant color changes
    toggle:SetTrackColor(Color3.fromRGB(255, 100, 100), false)
    button:SetBackgroundColor(Color3.fromRGB(100, 255, 100), false)
    slider:SetFillColor(Color3.fromRGB(100, 100, 255), false)
    
    notify:Push("Applied instant color changes!")
    print("🎨 Applied instant color changes")
end)

-- Test animated updates
testGroup:AddButton("Test Animated Updates", function()
    -- Test animated color changes
    toggle:SetTrackColor(Color3.fromRGB(255, 255, 100), true)
    button:SetBackgroundColor(Color3.fromRGB(255, 100, 255), true)
    slider:SetFillColor(Color3.fromRGB(100, 255, 255), true)
    
    notify:Push("Applied animated color changes!")
    print("🎬 Applied animated color changes")
end)

-- Test notifications
testGroup:AddButton("Test Notifications", function()
    notify:Push("This is a test notification!")
    notify:Push("Another notification!", 3)
    notify:Push("Third notification!", 5)
    print("📢 Sent test notifications")
end)

-- Test announcements
testGroup:AddButton("Test Announcements", function()
    announce:Show("Test Announcement", "This is a test announcement!", 3)
    print("📢 Sent test announcement")
end)

-- Test keybinds
local keybindGroup = testTab:AddGroup("Keybind Tests")

local keybind1 = keybindGroup:AddKeybind("Test Keybind 1", Enum.KeyCode.F1, "Toggle", function(value)
    print("⌨️ Keybind 1:", value)
    notify:Push("Keybind 1: " .. tostring(value))
end)

local keybind2 = keybindGroup:AddKeybind("Test Keybind 2", Enum.KeyCode.F2, "Hold", function(value)
    print("⌨️ Keybind 2:", value)
    notify:Push("Keybind 2: " .. tostring(value))
end)

-- Show completion message
notify:Push("Executor test loaded successfully!", 5)
announce:Show("Test Complete", "Fiend UI Library executor test is ready!", 3)

print("🎉 Executor test completed successfully!")
print("📋 Available features:")
print("   • Theme system with " .. #themes .. " themes")
print("   • All UI components (Toggle, Button, Slider, Input, Dropdown)")
print("   • Notification and announcement systems")
print("   • Keybind system")
print("   • Instant and animated property updates")
print("   • Dock navigation")
print("")
print("🎮 Try the different tabs and features!")
print("")
print("📝 NOTES:")
print("   • If the library failed to load, check your internet connection")
print("   • Loading from: https://github.com/PureIsntHere/FiendLib")
print("   • The script will try multiple loading methods automatically")
print("   • For private repositories or offline use, consider using pastebin")
