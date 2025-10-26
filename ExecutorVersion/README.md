# Fiend UI Library - Executor Version

This folder contains a simplified version of Fiend designed specifically for executor usage, similar to how Linoria works.

## Problem

The main Fiend library uses `require()` for dependencies. In executors, this doesn't work without a complex bootstrapper. The executor version solves this.

## Solution

The executor version should either:

### Option 1: Single Unified File (Recommended)
Create one large file that contains all the code inline, with no `require()` calls.

### Option 2: Simplified Module System  
Each file is modified to not use `require()`, instead receiving dependencies as parameters.

### Option 3: Build System
Use a build script that concatenates and minifies all files into one.

## Current Status

- `Fiend.lua` - Simple direct loading (won't work due to require issues)
- `Fiend_Library.lua` - Module-based loader (attempts to set up require system)

## Recommended Approach

Create a build script that:
1. Reads all source files in order
2. Inlines dependencies (replaces require() calls with actual code)
3. Outputs a single self-contained file
4. This file can be loaded in one line like Linoria

## Example Usage (when complete)

```lua
-- One line to load
local Fiend = loadstring(game:HttpGet('https://raw.githubusercontent.com/PureIsntHere/FiendLib/ExecutorVersion/Fiend.lua'))()

-- Use it immediately
local window = Fiend:CreateWindow({
    Title = "My Script",
    Theme = "Tokyo Night"
})

local tab = window:AddTab("Main")
local group = tab:AddGroup("Controls")

group:AddToggle("Enable", false, function(value)
    print("Toggle:", value)
end)
```

## Next Steps

1. Create a build script to combine all files
2. Or modify component files to not use require()
3. Or create simplified executor-specific versions

