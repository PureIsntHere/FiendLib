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
		if gethui then return gethui() end
		if get_hidden_ui then return get_hidden_ui() end
		if get_hidden_gui then return get_hidden_gui() end
		return nil
	end)
	if ok and root and typeof(root) == "Instance" then
		return root
	end
	if CoreGui then return CoreGui end
	return LocalPlr:WaitForChild("PlayerGui")
end

local function tryProtect(gui)
	local env = getfenv and getfenv() or _G
	local cands = {
		rawget(env, "protectgui"),
		rawget(env, "protect_gui"),
		rawget(_G, "protectgui"),
		rawget(_G, "protect_gui"),
		(syn and syn.protect_gui),
		(securegui),
		(secure_gui),
	}
	for _,fn in ipairs(cands) do
		if typeof(fn) == "function" then
			if pcall(fn, gui) then return true end
		end
	end
	return false
end

-- ========== singleton root ==========
local _root -- ScreenGui "RobloxGui"
local _watch

function Safety.GetRoot()
	if _root and _root.Parent then return _root end

	_root = Instance.new("ScreenGui")
	_root.Name = "RobloxGui" -- exact top-level name
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
