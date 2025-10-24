-- Fiend/components/dropdown
local Tween   = require(script.Parent.Parent.lib.tween)
local Utils   = require(script.Parent.Parent.lib.utils)
local Safety  = require(script.Parent.Parent.lib.safety)
local UIS     = game:GetService("UserInputService")

local function R(prefix)
	prefix = prefix or "Node"
	if Safety and Safety.RandomChildName then
		return Safety.RandomChildName(prefix)
	end
	return string.format("%s_%06d", prefix, math.random(0, 999999))
end

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(tab, text, list, default, callback)
	local theme = tab.Theme
	local parent = tab.Container
	list = list or {}
	default = default or list[1]

	local row = Instance.new("Frame")
	row.Name = R("Row")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1,0,0,32)
	row.ZIndex = 20
	row.Parent = parent
	Utils:HList(row, theme.Pad)

	local lbl = Utils:Label({ Text = text or "Dropdown", Parent = row, Theme = theme })
	lbl.Size = UDim2.new(1, -160, 1, 0)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 20

	local btn = Instance.new("TextButton")
	btn.AutoButtonColor = false
	btn.Text = tostring(default)
	btn.Font = theme.Font
	btn.TextSize = 14
	btn.TextColor3 = theme.Foreground
	btn.BackgroundColor3 = theme.Background
	btn.BackgroundTransparency = 0.15
	btn.Size = UDim2.fromOffset(150, 28)
	btn.ZIndex = 21
	btn.Parent = row
	local bc = Instance.new("UICorner"); bc.CornerRadius = theme.Corner; bc.Parent = btn
	local bs = Utils:Stroke(btn, theme.Foreground, 1, 0.7)

	local layer = tab.Window.FloatLayer
	local pop = Instance.new("Frame")
	pop.Name = R("Drop")
	pop.BackgroundColor3 = theme.Background
	pop.BackgroundTransparency = 0.05
	pop.Visible = false
	pop.ZIndex = 200
	pop.Parent = layer
	local pc = Instance.new("UICorner"); pc.CornerRadius = theme.Corner; pc.Parent = pop
	local ps = Utils:Stroke(pop, theme.Foreground, 1, 0.6)

	local listFrame = Instance.new("ScrollingFrame")
	listFrame.BackgroundTransparency = 1
	listFrame.BorderSizePixel = 0
	listFrame.ScrollBarThickness = 2
	listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	listFrame.CanvasSize = UDim2.new()
	listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listFrame.Size = UDim2.new(1, -6, 1, -6)
	listFrame.Position = UDim2.fromOffset(3,3)
	listFrame.ZIndex = 201
	listFrame.Parent = pop

	local function placePopover()
		local abs = btn.AbsolutePosition
		local size = btn.AbsoluteSize
		local maxH = 180
		pop.Size = UDim2.fromOffset(math.max(size.X, 150), maxH)
		pop.Position = UDim2.fromOffset(abs.X, abs.Y + size.Y + 4)
	end

	local function fill(newList)
		-- clear items
		for _,child in ipairs(listFrame:GetChildren()) do
			child:Destroy()
		end
		-- re-create layout AFTER clearing (previous one was destroyed)
		local l = Instance.new("UIListLayout")
		l.Parent = listFrame
		l.Padding = UDim.new(0,6)

		for _,opt in ipairs(newList) do
			local item = Instance.new("TextButton")
			item.AutoButtonColor = false
			item.Text = tostring(opt)
			item.Font = theme.Font
			item.TextSize = 14
			item.TextColor3 = theme.Foreground
			item.BackgroundColor3 = theme.Background
			item.BackgroundTransparency = 0.15
			item.Size = UDim2.new(1, -6, 0, 28)
			item.ZIndex = 202
			item.Parent = listFrame
			local ic = Instance.new("UICorner"); ic.CornerRadius = theme.Corner; ic.Parent = item
			local is = Utils:Stroke(item, theme.Foreground, 1, 0.7)

			item.MouseEnter:Connect(function() Tween(item, {BackgroundTransparency = 0.05}, 0.08) end)
			item.MouseLeave:Connect(function() Tween(item, {BackgroundTransparency = 0.15}, 0.08) end)
			item.Activated:Connect(function()
				btn.Text = item.Text
				pop.Visible = false
				if callback then task.spawn(callback, item.Text) end
			end)
		end
	end

	fill(list)

	btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.05}, 0.08) end)
	btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0.15}, 0.08) end)
	btn.Activated:Connect(function()
		placePopover()
		pop.Visible = not pop.Visible
	end)

	-- close on outside click / ESC
	UIS.InputBegan:Connect(function(i,gpe)
		if gpe then return end
		if i.KeyCode == Enum.KeyCode.Escape and pop.Visible then pop.Visible = false end
		if i.UserInputType == Enum.UserInputType.MouseButton1 and pop.Visible then
			local p = i.Position
			local inside = (p.X >= pop.AbsolutePosition.X and p.X <= pop.AbsolutePosition.X + pop.AbsoluteSize.X
				and p.Y >= pop.AbsolutePosition.Y and p.Y <= pop.AbsolutePosition.Y + pop.AbsoluteSize.Y)
			local inBtn = (p.X >= btn.AbsolutePosition.X and p.X <= btn.AbsolutePosition.X + btn.AbsoluteSize.X
				and p.Y >= btn.AbsolutePosition.Y and p.Y <= btn.AbsolutePosition.Y + btn.AbsoluteSize.Y)
			if not inside and not inBtn then pop.Visible = false end
		end
	end)

	return setmetatable({
		Row=row, Button=btn, Popover=pop,
		SetList = function(_, new) list = new; fill(list) end,
		Get = function() return btn.Text end
	}, Dropdown)
end

return Dropdown
