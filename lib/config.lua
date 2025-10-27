-- Fiend/lib/config.lua
-- File-based config manager for Fiend UI Library
-- Supports both Studio (using DataStoreService) and Executor (using file functions)

local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

local Config = {}
Config.__index = Config

-- Check if we're in an executor environment
local function isExecutor()
    -- Safely check for executor file functions without detection
    local hasReadFile, hasWriteFile, hasIsFile = false, false, false
    
    -- Try to get file functions without iterating over _G
    local fileFuncNames = {"readfile", "writefile", "isfile"}
    local env = (function()
        local f = function() end
        return getfenv and getfenv(f) or _G
    end)()
    
    pcall(function()
        for i = 1, #fileFuncNames do
            local funcName = fileFuncNames[i]
            local func = env[funcName]
            if func and typeof(func) == "function" then
                if funcName == "readfile" then hasReadFile = true
                elseif funcName == "writefile" then hasWriteFile = true
                elseif funcName == "isfile" then hasIsFile = true
                end
            end
        end
    end)
    
    -- If we have the file functions OR if we're not in Studio, assume executor
    local inStudio = pcall(function() return game:GetService("RunService"):IsStudio() end)
    
    return (hasReadFile and hasWriteFile) or (not inStudio and hasIsFile)
end

-- Check if we're in Studio
local function isStudio()
    return game:GetService("RunService"):IsStudio()
end

function Config.new(options)
    local self = setmetatable({}, Config)
    
    -- Configuration options
    local opts = options or {}
    self._configFolder = opts.folder or "FiendConfigs"
    self._configFile = opts.filename or "settings.json"
    self._configName = opts.name or "FiendConfig"
    
    -- Build full path
    self._fullPath = self._configFolder .. "/" .. self._configFile
    
    -- Data storage
    self._data = {}
    self._isExecutor = isExecutor()
    self._isStudio = isStudio()
    
    -- Auto-load existing config
    self:Load()
    
    return self
end

-- Set a config value
function Config:Set(key, value)
    self._data[key] = value
end

-- Get a config value
function Config:Get(key, default)
    local val = self._data[key]
    if val == nil then
        return default
    end
    return val
end

-- Remove a key
function Config:Remove(key)
    self._data[key] = nil
end

-- Return all config data
function Config:GetAll()
    return self._data
end

-- Serialize to JSON
function Config:Serialize(pretty)
    local success, encoded = pcall(function()
        if pretty then
            return HttpService:JSONEncode(self._data, Enum.HttpContentType.ApplicationJson)
        else
            return HttpService:JSONEncode(self._data)
        end
    end)
    return success and encoded or "{}"
end

-- Deserialize from JSON
function Config:Deserialize(json)
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    if success and type(decoded) == "table" then
        self._data = decoded
        return true
    end
    return false
end

-- Save config to file
function Config:Save()
    if self._isExecutor then
        return self:_saveToFile()
    elseif self._isStudio then
        return self:_saveToDataStore()
    else
        warn("[Fiend/Config] No save method available in this environment")
        return false
    end
end

-- Load config from file
function Config:Load()
    if self._isExecutor then
        return self:_loadFromFile()
    elseif self._isStudio then
        return self:_loadFromDataStore()
    else
        warn("[Fiend/Config] No load method available in this environment")
        return false
    end
end

-- Executor file operations
function Config:_saveToFile()
    if not self._isExecutor then
        return false
    end
    
    -- Safely get writefile function without iterating _G
    local writeFileFunc = nil
    pcall(function()
        local env = getfenv and getfenv() or _G
        local func = env["writefile"]
        if func and typeof(func) == "function" then
            writeFileFunc = func
        end
    end)
    
    if not writeFileFunc then
        warn("[Fiend/Config] writefile not available")
        return false
    end
    
    local success, result = pcall(function()
        local json = self:Serialize(true) -- Pretty print for readability
        
        -- Try to create folder if isfile exists
        local isFileFunc, makeFolderFunc = nil, nil
        pcall(function()
            local env = getfenv and getfenv() or _G
            if env["isfile"] and typeof(env["isfile"]) == "function" then
                isFileFunc = env["isfile"]
            end
            if env["makefolder"] and typeof(env["makefolder"]) == "function" then
                makeFolderFunc = env["makefolder"]
            end
        end)
        
        if isFileFunc then
            pcall(function()
                if not isFileFunc(self._configFolder) then
                    if makeFolderFunc then
                        makeFolderFunc(self._configFolder)
                    end
                end
            end)
        end
        
        writeFileFunc(self._fullPath, json)
        return true
    end)
    
    if success then
        print("[Fiend/Config] Saved config to:", self._fullPath)
        return true
    else
        warn("[Fiend/Config] Failed to save config:", result)
        return false
    end
end

function Config:_loadFromFile()
    if not self._isExecutor then
        return false
    end
    
    -- Safely get readfile and isfile functions without iterating _G
    local readFileFunc, isFileFunc = nil, nil
    pcall(function()
        local env = getfenv and getfenv() or _G
        if env["readfile"] and typeof(env["readfile"]) == "function" then
            readFileFunc = env["readfile"]
        end
        if env["isfile"] and typeof(env["isfile"]) == "function" then
            isFileFunc = env["isfile"]
        end
    end)
    
    if not readFileFunc then
        warn("[Fiend/Config] readfile not available")
        return false
    end
    
    local success, result = pcall(function()
        if isFileFunc and not isFileFunc(self._fullPath) then
            print("[Fiend/Config] Config file not found:", self._fullPath)
            return false
        end
        
        local content = readFileFunc(self._fullPath)
        if content then
            return self:Deserialize(content)
        end
        return false
    end)
    
    if success and result then
        print("[Fiend/Config] Loaded config from:", self._fullPath)
        return true
    else
        if result then
            warn("[Fiend/Config] Failed to load config:", result)
        end
        return false
    end
end

-- Studio DataStore operations
function Config:_saveToDataStore()
    if not self._isStudio then
        return false
    end
    
    local success, result = pcall(function()
        local dataStore = DataStoreService:GetDataStore("FiendConfig_" .. self._configName)
        local json = self:Serialize()
        dataStore:SetAsync("config", json)
        return true
    end)
    
    if success then
        print("[Fiend/Config] Saved config to DataStore:", self._configName)
        return true
    else
        warn("[Fiend/Config] Failed to save to DataStore:", result)
        return false
    end
end

function Config:_loadFromDataStore()
    if not self._isStudio then
        return false
    end
    
    local success, result = pcall(function()
        local dataStore = DataStoreService:GetDataStore("FiendConfig_" .. self._configName)
        local json = dataStore:GetAsync("config")
        if json then
            return self:Deserialize(json)
        end
        return false
    end)
    
    if success and result then
        print("[Fiend/Config] Loaded config from DataStore:", self._configName)
        return true
    else
        if result then
            warn("[Fiend/Config] Failed to load from DataStore:", result)
        end
        return false
    end
end

-- Auto-save functionality
function Config:EnableAutoSave(interval)
    if self._autoSaveConnection then
        self._autoSaveConnection:Disconnect()
    end
    
    if interval and interval > 0 then
        self._autoSaveConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if self._needsSave then
                self:Save()
                self._needsSave = false
            end
        end)
        
        -- Mark for save when values change
        local originalSet = self.Set
        self.Set = function(self, key, value)
            originalSet(self, key, value)
            self._needsSave = true
        end
    end
end

function Config:DisableAutoSave()
    if self._autoSaveConnection then
        self._autoSaveConnection:Disconnect()
        self._autoSaveConnection = nil
    end
end

-- Backup and restore
function Config:CreateBackup()
    if self._isExecutor then
        local writeFileFunc = nil
        pcall(function()
            local env = getfenv and getfenv() or _G
            local func = env["writefile"]
            if func and typeof(func) == "function" then
                writeFileFunc = func
            end
        end)
        
        if writeFileFunc then
            local backupPath = self._configFolder .. "/" .. self._configFile .. ".backup"
            local json = self:Serialize(true)
            writeFileFunc(backupPath, json)
            print("[Fiend/Config] Created backup:", backupPath)
            return true
        end
    end
    return false
end

function Config:RestoreFromBackup()
    if self._isExecutor then
        local readFileFunc, isFileFunc = nil, nil
        pcall(function()
            local env = getfenv and getfenv() or _G
            if env["readfile"] and typeof(env["readfile"]) == "function" then
                readFileFunc = env["readfile"]
            end
            if env["isfile"] and typeof(env["isfile"]) == "function" then
                isFileFunc = env["isfile"]
            end
        end)
        
        if readFileFunc and isFileFunc then
            local backupPath = self._configFolder .. "/" .. self._configFile .. ".backup"
            if isFileFunc(backupPath) then
                local content = readFileFunc(backupPath)
                if content then
                    self:Deserialize(content)
                    self:Save()
                    print("[Fiend/Config] Restored from backup:", backupPath)
                    return true
                end
            end
        end
    end
    return false
end

-- Clear all config data
function Config:Clear()
    table.clear(self._data)
end

-- Get config info
function Config:GetInfo()
    return {
        folder = self._configFolder,
        filename = self._configFile,
        fullPath = self._fullPath,
        isExecutor = self._isExecutor,
        isStudio = self._isStudio,
        dataCount = #self._data
    }
end

-- Debug print
function Config:Print()
    print("[Fiend/Config] Current data:")
    for k, v in pairs(self._data) do
        print("   ", k, "=", v)
    end
    print("[Fiend/Config] Info:", self:GetInfo())
end

-- Legacy clipboard methods (for backward compatibility)
function Config:CopyToClipboard()
    if typeof(setclipboard) == "function" then
        local json = self:Serialize()
        setclipboard(json)
        return true
    end
    return false
end

function Config:LoadFromClipboard()
    if typeof(getclipboard) == "function" then
        local raw = getclipboard()
        if raw then
            return self:Deserialize(raw)
        end
    end
    return false
end

return Config