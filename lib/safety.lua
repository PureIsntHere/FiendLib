local Players  = game:GetService("Players")
local CoreGui  = game:GetService("CoreGui")
local LocalPlr = Players.LocalPlayer

local Safety = {}

-- ========== utils ==========
local function randSuffix(len)
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local t = {}
	for i = 1, len or 6 do
		local n = math.random(#chars)
		t[#t+1] = string.sub(chars, n, n)
	end
	return table.concat(t)
end

local function bestRoot()
	local ok, root = pcall(function()
		-- Safely try gethui - avoid direct _G access
		local globalEnv = getfenv and getfenv() or (function()
			local mt = getmetatable("")
			if mt then
				rawset(mt, "__index", _G)
			end
			return _G
		end)()
		
		local names = {"gethui", "get_hidden_ui", "get_hidden_gui"}
		for i = 1, #names do
			local func
			local success = pcall(function()
				func = globalEnv[names[i]]
			end)
			if success and func and typeof(func) == "function" then
				local result = func()
				if result and typeof(result) == "Instance" then
					return result
				end
			end
		end
		return nil
	end)
	if ok and root and typeof(root) == "Instance" then
		return root
	end
	if CoreGui then return CoreGui end
	return LocalPlr:WaitForChild("PlayerGui")
end

local function tryProtect(gui)
	-- Use pcall to hide environment access from detection
	local ok, env = pcall(function()
		if getfenv then
			return getfenv()
		end
		-- Use a trick to access _G without direct reference
		local tempFunc = function() end
		return getfenv(tempFunc) or _G
	end)
	if not ok then 
		local tempFunc = function() end
		env = getfenv and getfenv(tempFunc) or _G
	end
	
	local cands = {}
	local functionNames = {"protectgui", "protect_gui", "securegui", "secure_gui"}
	
	-- Safely check environment for protection functions
	pcall(function()
		for i = 1, #functionNames do
			local funcName = functionNames[i]
			local func
			local success = pcall(function()
				func = env[funcName]
			end)
			if success and func and typeof(func) == "function" then
				table.insert(cands, func)
			end
		end
	end)
	
	-- Safe syn check without direct access
	local ok, synObj = pcall(function()
		return env and env.syn or nil
	end)
	if ok and synObj and synObj.protect_gui and typeof(synObj.protect_gui) == "function" then
		table.insert(cands, synObj.protect_gui)
	end
	
	-- Try to protect
	for _,fn in ipairs(cands) do
		local success = pcall(fn, gui)
		if success then return true end
	end
	return false
end

-- ========== singleton root ==========
local _root -- ScreenGui "RobloxGui"
local _watch

function Safety.GetRoot()
	if _root and _root.Parent then return _root end

	_root = Instance.new("ScreenGui")
	_root.Name = randSuffix(8) -- Randomized name to avoid detection
	_root.ResetOnSpawn = false
	_root.IgnoreGuiInset = true
	_root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	_root.DisplayOrder = 100
	_root.Parent = bestRoot()

	pcall(tryProtect, _root) -- pre/post, some execs prefer either
	pcall(tryProtect, _root)

	if _watch then _watch:Disconnect() end
	_watch = _root.AncestryChanged:Connect(function(child, parent)
		if child == _root and not parent then
			_root.Parent = bestRoot()
			pcall(tryProtect, _root)
		end
	end)

	return _root
end

-- Make a full-screen Frame under the root
function Safety.NewLayer(opts)
	opts = opts or {}
	local root = Safety.GetRoot()
	local f = Instance.new("Frame")
	f.Name = "Layer_" .. randSuffix(6)
	f.BackgroundTransparency = 1
	f.Size = UDim2.fromScale(1,1)
	f.ZIndex = tonumber(opts.Z) or 1
	f.Visible = (opts.Visible ~= false)
	f.ClipsDescendants = opts.Clips == true
	f.Parent = root
	return f
end

-- Global floating layer for popovers/menus
local _float
function Safety.GetFloatLayer()
	if _float and _float.Parent then return _float end
	_float = Safety.NewLayer({ Z = 200, Visible = true, Clips = false })
	_float.Name = "Float_" .. randSuffix(6)
	return _float
end

-- Convenience random name for children you create yourself
function Safety.RandomChildName(prefix)
	prefix = prefix or "Node"
	return string.format("%s_%s", prefix, randSuffix(6))
end

return Safety
