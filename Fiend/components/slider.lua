-- Fiend/components/slider
local Tween  = require(script.Parent.Parent.lib.tween)
local Utils  = require(script.Parent.Parent.lib.utils)
local Safety = require(script.Parent.Parent.lib.safety)
local UIS    = game:GetService("UserInputService")

local function R(prefix)
	prefix = prefix or "Node"
	if Safety and Safety.RandomChildName then
		return Safety.RandomChildName(prefix)
	end
	return string.format("%s_%06d", prefix, math.random(0, 999999))
end

local Slider = {}
Slider.__index = Slider

function Slider.new(tab, text, min, max, default, callback)
	local theme = tab.Theme
	local parent = tab.Container
	min, max = tonumber(min) or 0, tonumber(max) or 100
	default = math.clamp(tonumber(default) or min, min, max)

	local row = Instance.new("Frame")
	row.Name = R("Row")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1,0,0,40)
	row.ZIndex = 6
	row.Parent = parent

	Utils:VList(row, 6)

	local top = Instance.new("Frame")
	top.BackgroundTransparency = 1
	top.Size = UDim2.new(1,0,0,18)
	top.ZIndex = 6
	top.Parent = row
	Utils:HList(top, theme.Pad)

	local lbl = Utils:Label({ Text = string.format("%s  (%d)", text or "Slider", default), Parent = top, Theme = theme })
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local bar = Instance.new("Frame")
	bar.Name = R("Bar")
	bar.BackgroundColor3 = theme.Background
	bar.BackgroundTransparency = 0.2
	bar.Size = UDim2.new(1,0,0,12)
	bar.ZIndex = 7
	bar.Parent = row
	local bc = Instance.new("UICorner"); bc.CornerRadius = theme.Corner; bc.Parent = bar
	local bs = Utils:Stroke(bar, theme.Foreground, 1, 0.8)

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = theme.Foreground
	fill.BackgroundTransparency = 0.2
	fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
	fill.ZIndex = 8
	fill.Parent = bar
	local fc = Instance.new("UICorner"); fc.CornerRadius = theme.Corner; fc.Parent = fill

	local dragging = false
	local value = default

	local function setFromX(x, silent)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
		value = math.floor(min + rel*(max-min) + 0.5)
		fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
		lbl.Text = string.format("%s  (%d)", text or "Slider", value)
		if not silent and callback then task.spawn(callback, value) end
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			setFromX(input.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromX(input.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	return setmetatable({ Row=row, Bar=bar, Fill=fill, Label=lbl, Get=function() return value end }, Slider)
end

return Slider