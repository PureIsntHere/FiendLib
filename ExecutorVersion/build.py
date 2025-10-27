#!/usr/bin/env python3
"""
Fiend UI Library - Builder for Executor Version
Builds a single self-contained file from source files
"""

import os
import re
from pathlib import Path

# Configuration
SOURCE_DIR = Path('../')  # Go up one level to the main directory
OUTPUT_FILE = 'Fiend_Built.lua'
REPO_URL = 'https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/'

# Module files in dependency order
MODULE_ORDER = [
    # Core libs
    'lib/util.lua',
    'lib/base_element.lua',
    'lib/theme.lua',
    'lib/tween.lua',
    'lib/fx.lua',
    'lib/behaviors.lua',
    'lib/binds.lua',
    'lib/config.lua',
    'lib/safety.lua',
    'lib/keysystem.lua',
    'lib/theme_manager.lua',
    # Main init
    'init.lua',
    # Components
    'components/button.lua',
    'components/toggle.lua',
    'components/slider.lua',
    'components/dropdown.lua',
    'components/textinput.lua',
    'components/group.lua',
    'components/tab.lua',
    'components/window.lua',
    'components/keybind.lua',
    'components/notify.lua',
    'components/announce.lua',
    'components/dock.lua',
]

def read_file(path):
    """Read a source file"""
    full_path = SOURCE_DIR / path
    if full_path.exists():
        return full_path.read_text(encoding='utf-8')
    print(f"Warning: File not found: {path}")
    return None

def build_single_file():
    """Build a single self-contained file"""
    
    print("🔨 Building Fiend Executor Version...")
    print(f"📂 Source: {SOURCE_DIR}")
    print(f"📄 Output: {OUTPUT_FILE}")
    
    output = []
    output.append("--[[")
    output.append("    Fiend UI Library - Executor Version (Built)")
    output.append("    Auto-generated single-file version for executor usage")
    output.append("")
    output.append("    Usage:")
    output.append("    local Fiend = loadstring(game:HttpGet('https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/Fiend_Built.lua'))()")
    output.append("")
    output.append("    Then use it:")
    output.append("    local window = Fiend:CreateWindow({Title = 'My Script', Theme = 'Tokyo Night'})")
    output.append("]]")
    output.append("")
    output.append("local repo = 'https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/'")
    output.append("")
    output.append("-- Module storage and cache")
    output.append("local Modules = {}")
    output.append("local Cache = {}")
    output.append("")
    output.append("-- Create smart script mock")
    output.append("local function createScriptMock()")
    output.append("    local libModules = {")
    output.append("        util = 'util',")
    output.append("        keysystem = 'keysystem',")
    output.append("        theme = 'theme',")
    output.append("        behaviors = 'behaviors',")
    output.append("        fx = 'fx',")
    output.append("        safety = 'safety',")
    output.append("        config = 'config',")
    output.append("        base_element = 'base_element',")
    output.append("        tween = 'tween',")
    output.append("        binds = 'binds',")
    output.append("        theme_manager = 'theme_manager',")
    output.append("    }")
    output.append("    local componentModules = {")
    output.append("        button = 'components/button',")
    output.append("        toggle = 'components/toggle',")
    output.append("        slider = 'components/slider',")
    output.append("        dropdown = 'components/dropdown',")
    output.append("        textinput = 'components/textinput',")
    output.append("        keybind = 'components/keybind',")
    output.append("        group = 'components/group',")
    output.append("        tab = 'components/tab',")
    output.append("        window = 'components/window',")
    output.append("        dock = 'components/dock',")
    output.append("        announce = 'components/announce',")
    output.append("        notify = 'components/notify',")
    output.append("    }")
    output.append("    local libFolder = {}")
    output.append("    local componentsFolder = {}")
    output.append("    for name, path in pairs(libModules) do")
    output.append("        libFolder[name] = setmetatable({Name = name, RequirePath = path}, {__index = function() return path end})")
    output.append("    end")
    output.append("    for name, path in pairs(componentModules) do")
    output.append("        componentsFolder[name] = setmetatable({Name = name, RequirePath = path}, {__index = function() return path end})")
    output.append("    end")
    output.append("    local parentParent = {lib = libFolder, components = componentsFolder}")
    output.append("    local parent = {Parent = parentParent}")
    output.append("    for name, path in pairs(componentModules) do")
    output.append("        parent[name] = componentsFolder[name]")
    output.append("    end")
    output.append("    return {Parent = parent}")
    output.append("end")
    output.append("")
    output.append("-- Create require function")
    output.append("local function createRequire()")
    output.append("    return function(path)")
    output.append("        if path == nil then")
    output.append("            error('Require called with nil path')")
    output.append("        end")
    output.append("        -- Handle non-string paths (like script.Parent.module)")
    output.append("        if type(path) ~= 'string' then")
    output.append("            if path and path.Name then")
    output.append("                if path.RequirePath then")
    output.append("                    path = path.RequirePath")
    output.append("                else")
    output.append("                    path = path.Name:gsub('%.lua$', '')")
    output.append("                end")
    output.append("            else")
    output.append("                error('Executor require only supports string paths, got: ' .. type(path))")
    output.append("            end")
    output.append("        end")
    output.append("        if Cache[path] then return Cache[path] end")
    output.append("        local moduleCode = Modules[path]")
    output.append("        if not moduleCode then")
    output.append("            moduleCode = Modules[path:gsub('%.lua$', '')]")
    output.append("        end")
    output.append("        if not moduleCode then")
    output.append("            error('Module not found: ' .. tostring(path))")
    output.append("        end")
    output.append("        local env = setmetatable({")
    output.append("            game = game,")
    output.append("            workspace = workspace,")
    output.append("            Color3 = Color3,")
    output.append("            UDim2 = UDim2,")
    output.append("            UDim = UDim,")
    output.append("            Enum = Enum,")
    output.append("            Instance = Instance,")
    output.append("            Vector2 = Vector2,")
    output.append("            Vector3 = Vector3,")
    output.append("            TweenInfo = TweenInfo,")
    output.append("            script = createScriptMock(),")
    output.append("            require = createRequire()")
    output.append("        }, {__index = _G})")
    output.append("        local fn, err = loadstring(moduleCode)")
    output.append("        if not fn then error('Failed to parse: ' .. tostring(err)) end")
    output.append("        setfenv(fn, env)")
    output.append("        local success, result = pcall(fn)")
    output.append("        if not success then error('Failed to execute: ' .. tostring(result)) end")
    output.append("        Cache[path] = result")
    output.append("        return result")
    output.append("    end")
    output.append("end")
    output.append("")
    output.append("print('🔨 Loading Fiend UI Library...')")
    output.append("")
    
    # Load modules
    for module_path in MODULE_ORDER:
        code = read_file(module_path)
        if code:
            # Use long string delimiters to avoid escaping issues
            # Find number of equals that won't conflict
            equals_count = 0
            while True:
                open_tag = f"[{'=' * equals_count}["
                close_tag = f"]{'=' * equals_count}]"
                if open_tag in code or close_tag in code:
                    equals_count += 1
                else:
                    break
            
            delimiter = '=' * equals_count
            opener = f'[{delimiter}['
            closer = f']{delimiter}]'
            
            # Store with multiple keys
            name_without_ext = module_path.replace('.lua', '')
            name_only = os.path.basename(module_path).replace('.lua', '')
            
            output.append(f"-- Module: {module_path}")
            if len(code.strip()) == 0:
                output.append(f"Modules['{module_path}'] = ''")
            else:
                output.append(f"Modules['{module_path}'] = {opener}")
                output.append(code)
                output.append(closer)
            output.append(f"Modules['{name_without_ext}'] = Modules['{module_path}']")
            output.append(f"Modules['{name_only}'] = Modules['{module_path}']")
            output.append("")
            print(f"✅ Loaded: {module_path}")
        else:
            print(f"❌ Failed: {module_path}")
    
    output.append("print('✅ All modules loaded')")
    output.append("")
    output.append("-- Set up require and execute init")
    output.append("local require = createRequire()")
    output.append("")
    output.append("local Fiend = require('init')")
    output.append("")
    output.append("print('✅ Fiend UI Library ready!')")
    output.append("print('📊 Version:', Fiend.Version or 'Unknown')")
    output.append("")
    output.append("return Fiend")
    
    # Write output
    output_path = Path(OUTPUT_FILE)
    output_path.write_text('\n'.join(output), encoding='utf-8')
    
    file_size = output_path.stat().st_size / 1024  # KB
    print(f"")
    print(f"✅ Build complete!")
    print(f"📄 Output: {OUTPUT_FILE}")
    print(f"📦 Size: {file_size:.2f} KB")

if __name__ == '__main__':
    try:
        build_single_file()
    except Exception as e:
        print(f"❌ Build failed: {e}")
        import traceback
        traceback.print_exc()

