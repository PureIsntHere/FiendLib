-- Fiend/components/button
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

local Button = {}
Button.__index = Button

function Button.new(tab, text, callback)
	local theme = tab.Theme
	local parent = tab.Container

	-- row
	local row = Instance.new("Frame")
	row.Name = R("Row")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1,0,0,32)
	row.ZIndex = 6
	row.Parent = parent
	Utils:HList(row, theme.Pad)

	-- label (left)
	local lbl = Utils:Label({ Text = text or "Button", Parent = row, Theme = theme })
	lbl.Size = UDim2.new(1, -140, 1, 0)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 6

	-- button (right)
	local btn = Instance.new("TextButton")
	btn.Name = R("Btn")
	btn.AutoButtonColor = false
	btn.Text = "EXECUTE"
	btn.Font = theme.Font
	btn.TextSize = 14
	btn.TextColor3 = theme.Foreground
	btn.BackgroundColor3 = theme.Background
	btn.BackgroundTransparency = 0.15
	btn.Size = UDim2.fromOffset(120, 28)
	btn.ZIndex = 7
	btn.Parent = row

	local c = Instance.new("UICorner"); c.CornerRadius = theme.Corner; c.Parent = btn
	local s = Utils:Stroke(btn, theme.Foreground, 1, 0.7)

	btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.05}, 0.08) end)
	btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0.15}, 0.08) end)
	btn.Activated:Connect(function() if callback then task.spawn(callback) end end)

	return setmetatable({ Row=row, Button=btn, Label=lbl }, Button)
end

return Button
