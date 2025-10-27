-- Fiend/lib/util.lua
-- Core utility functions used across FiendLib.

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Util = {}

--[[------------------------------------------------------------
	Instance Helpers
------------------------------------------------------------]]
function Util.Create(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

function Util.CreateUIStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

function Util.CreateUICorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or UDim.new(0, 8)
	c.Parent = parent
	return c
end

function Util.CreateUIPadding(parent, pad)
	local p = Instance.new("UIPadding")
	p.PaddingTop = pad or UDim.new(0, 8)
	p.PaddingBottom = p.PaddingTop
	p.PaddingLeft = p.PaddingTop
	p.PaddingRight = p.PaddingTop
	p.Parent = parent
	return p
end

function Util:Roundify(obj: Instance, radius: UDim?)
	-- default to 8px if not provided
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or UDim.new(0, 8)
	corner.Parent = obj
	return corner
end

-- === Compatibility shims expected by older components/behaviors ===

-- Colon-call wrapper for a border stroke: Util:Stroke(parent, color, thickness)
function Util:Stroke(parent: Instance, color: Color3?, thickness: number?)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(42, 48, 60)
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

-- Colon-call wrapper for rounded corners: Util:Roundify(parent, radiusUDim)
function Util:Roundify(parent: Instance, radius: UDim?)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or UDim.new(0, 8)
	c.Parent = parent
	return c
end

-- Colon-call wrapper for padding: Util:Pad(parent, padUDim)
function Util:Pad(parent: Instance, pad: UDim?)
	local p = Instance.new("UIPadding")
	local v = pad or UDim.new(0, 8)
	p.PaddingTop = v
	p.PaddingBottom = v
	p.PaddingLeft = v
	p.PaddingRight = v
	p.Parent = parent
	return p
end

--[[------------------------------------------------------------
	Tween Helpers
------------------------------------------------------------]]
function Util.Tween(obj, infoOrProps, propsOrDuration, style, dir)
	-- Usage 1: Util.Tween(obj, TweenInfo.new(...), {PropertyTable})
	if typeof(infoOrProps) == "TweenInfo" then
		local info = infoOrProps
		local props = propsOrDuration or {}
		local t = TweenService:Create(obj, info, props)
		t:Play()
		return t
	end
	-- Usage 2: Util.Tween(obj, {PropertyTable}, duration?, style?, dir?)
	local props = infoOrProps or {}
	local duration = propsOrDuration or 0.25
	local ti = TweenInfo.new(duration, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, ti, props)
	t:Play()
	return t
end

function Util.TweenShort(obj, props)
	return Util.Tween(obj, props, 0.15)
end

function Util.TweenMedium(obj, props)
	return Util.Tween(obj, props, 0.25)
end

function Util.TweenLong(obj, props)
	return Util.Tween(obj, props, 0.35)
end

--[[------------------------------------------------------------
	GUI Protection / Hierarchy
------------------------------------------------------------]]
function Util.ProtectGui(gui)
	local root = gethui and gethui()
		or (syn and syn.protect_gui and game:GetService("CoreGui"))
		or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	gui.Parent = root
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		elseif protectgui then
			protectgui(gui)
		end
	end)
	return gui
end

function Util.RandomString(len)
	local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local out = {}
	for i = 1, len or 8 do
		table.insert(out, string.sub(charset, math.random(1, #charset), math.random(1, #charset)))
	end
	return table.concat(out)
end

--[[------------------------------------------------------------
	Color / Math
------------------------------------------------------------]]
function Util.ColorToHex(color)
	return string.format("#%02X%02X%02X",
		math.floor(color.R * 255),
		math.floor(color.G * 255),
		math.floor(color.B * 255))
end

function Util.HexToColor(hex)
	hex = hex:gsub("#","")
	return Color3.fromRGB(
		tonumber(hex:sub(1,2),16),
		tonumber(hex:sub(3,4),16),
		tonumber(hex:sub(5,6),16)
	)
end

function Util.Clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

--[[------------------------------------------------------------
	JSON & Safe Execution
------------------------------------------------------------]]
function Util.EncodeJSON(tbl)
	return HttpService:JSONEncode(tbl)
end

function Util.DecodeJSON(str)
	local ok, res = pcall(function() return HttpService:JSONDecode(str) end)
	return ok and res or nil
end

function Util.SafeCall(fn, ...)
	if not fn then return end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[Fiend/Util] Callback Error:", err)
	end
end

--[[------------------------------------------------------------
	Misc
------------------------------------------------------------]]
function Util.FormatNumber(n)
	local left, num, right = string.match(tostring(n), "^([^%d]*%d)(%d*)(.-)$")
	return left .. (num:reverse():gsub("(%d%d%d)","%1,"):reverse()) .. right
end

function Util.WaitForChildOfClass(parent, class)
	for _, c in ipairs(parent:GetChildren()) do
		if c:IsA(class) then return c end
	end
	local inst
	parent.ChildAdded:Wait(function(ch)
		if ch:IsA(class) then inst = ch end
	end)
	return inst
end

return Util
