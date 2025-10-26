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

# Cache for loaded modules
loaded_modules = {}

def read_file(path):
    """Read a source file"""
    full_path = SOURCE_DIR / path
    if full_path.exists():
        return full_path.read_text(encoding='utf-8')
    print(f"Warning: File not found: {path}")
    return None

def extract_requires(code):
    """Extract all require() calls from code"""
    requires = []
    # Match: require(script.Parent....) or require("path")
    patterns = [
        r"require\(([^)]+)\)",  # require(...)
        r'require\("([^"]+)"\)',  # require("path")
        r"require\('([^']+)'\)",  # require('path')
        r'require\s*=\s*require\(([^)]+)\)',  # require = require(...)
    ]
    
    for pattern in patterns:
        matches = re.findall(pattern, code)
        requires.extend(matches)
    
    return requires

def resolve_path(path):
    """Resolve a require path to a file path"""
    # Clean up the path
    path = path.strip().strip('"').strip("'")
    
    # Remove script.Parent references
    path = path.replace('script.Parent.lib.', 'lib/')
    path = path.replace('script.Parent.components.', 'components/')
    path = path.replace('script.Parent.', '')
    path = path.replace('Parent.Parent.', '')
    
    # Convert dots to slashes
    if '.' in path and not '/' in path:
        path = path.replace('.', '/')
    
    # Ensure .lua extension
    if not path.endswith('.lua'):
        path += '.lua'
    
    return path

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
    output.append("    local Fiend = loadstring(game:HttpGet('https://raw.githubusercontent.com/PureIsntHere/FiendLib/ExecutorVersion/Fiend_Built.lua'))()")
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
    output.append("-- Create require function")
    output.append("local function createRequire()")
    output.append("    return function(path)")
    output.append("        if Cache[path] then return Cache[path] end")
    output.append("        local moduleCode = Modules[path]")
    output.append("        if not moduleCode then")
    output.append("            moduleCode = Modules[path:gsub('%.lua$', '')]")
    output.append("        end")
    output.append("        if not moduleCode then")
    output.append("            error('Module not found: ' .. tostring(path))")
    output.append("        end")
    output.append("        local env = getfenv(0)")
    output.append("        env.require = createRequire()")
    output.append("        env.game = game")
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
    output.append("getgenv().FiendRequire = require")
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

