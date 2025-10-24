-- Fiend/components/toggle
local Tween  = require(script.Parent.Parent.lib.tween)
local Utils  = require(script.Parent.Parent.lib.utils)
local Safety = require(script.Parent.Parent.lib.safety)

local function R(prefix)
	prefix = prefix or "Node"
	if Safety and Safety.RandomChildName then
		return Safety.RandomChildName(prefix)
	end
	return string.format("%s_%06d", prefix, math.random(0, 999999))
end

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(tab, text, default, callback)
	local theme = tab.Theme
	local parent = tab.Container
	default = default == true

	local row = Instance.new("Frame")
	row.Name = R("Row")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1,0,0,32)
	row.ZIndex = 6
	row.Parent = parent
	Utils:HList(row, theme.Pad)

	local lbl = Utils:Label({ Text = text or "Toggle", Parent = row, Theme = theme })
	lbl.Size = UDim2.new(1, -90, 1, 0)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 6

	-- switch
	local sw = Instance.new("TextButton")
	sw.AutoButtonColor = false
	sw.Text = ""
	sw.BackgroundColor3 = theme.Background
	sw.BackgroundTransparency = 0.15
	sw.Size = UDim2.fromOffset(54, 24)
	sw.ZIndex = 7
	sw.Parent = row
	local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 12); sc.Parent = sw
	local ss = Utils:Stroke(sw, theme.Foreground, 1, 0.7)

	local knob = Instance.new("Frame")
	knob.BackgroundColor3 = theme.Foreground
	knob.Size = UDim2.fromOffset(20, 20)
	knob.Position = UDim2.fromOffset(default and 32 or 4, 2)
	knob.ZIndex = 8
	knob.Parent = sw
	local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob

	local value = default
	local function set(v, silent)
		value = v and true or false
		Tween(knob, {Position = UDim2.fromOffset(value and 32 or 4, 2)}, 0.12, Enum.EasingStyle.Quad)
		if not silent and callback then task.spawn(callback, value) end
	end

	sw.Activated:Connect(function() set(not value) end)
	set(default, true)

	return setmetatable({ Row=row, Switch=sw, Knob=knob, Label=lbl, Get=function() return value end, Set=set }, Toggle)
end

return Toggle
