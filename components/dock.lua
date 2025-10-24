-- Fiend/components/dock
local Utils   = require(script.Parent.Parent.lib.utils)
local Safety  = require(script.Parent.Parent.lib.safety)
local Tween   = require(script.Parent.Parent.lib.tween)

local Dock = {}
Dock.__index = Dock

local function R(prefix)
	prefix = prefix or "Node"
	if Safety and Safety.RandomChildName then
		return Safety.RandomChildName(prefix)
	end
	return string.format("%s_%06d", prefix, math.random(0, 999999))
end

function Dock.new(window)
	local theme = window.Theme

	local rail = Instance.new("Frame")
	rail.Name = R("Dock")
	rail.BackgroundColor3 = theme.Background
	rail.BackgroundTransparency = 0.12
	rail.Size = UDim2.new(0, 46, 1, -46)  
	rail.Position = UDim2.new(0, -46, 0, 46) 
	rail.Visible = false
	rail.ZIndex = 4
	rail.Parent = window.Root

	Utils:Stroke(rail, theme.Foreground, 1, 0.7)
	local corner = Instance.new("UICorner"); corner.CornerRadius = theme.Corner; corner.Parent = rail

	local pad = Instance.new("UIPadding")
	pad.PaddingTop    = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft   = UDim.new(0, 5)
	pad.PaddingRight  = UDim.new(0, 5)
	pad.Parent = rail

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = rail

	local self = setmetatable({
		Window   = window,
		Rail     = rail,
		Buttons  = {},
		_selected = nil,
		_tooltips = {},
		_pad      = pad,
	}, Dock)

	return self
end

local function makeTooltip(parent, theme, text)
	local tip = Instance.new("TextLabel")
	tip.Name = "Tip"
	tip.BackgroundColor3 = Color3.fromRGB(30,30,34)
	tip.BackgroundTransparency = 0.04
	tip.TextColor3 = Color3.fromRGB(235,235,240)
	tip.Font = theme.Font
	tip.TextSize = 14
	tip.TextXAlignment = Enum.TextXAlignment.Left
	tip.Text = "  "..(text or "").."  "
	tip.AutomaticSize = Enum.AutomaticSize.XY
	tip.Visible = false
	tip.ZIndex = 1000
	tip.Parent = parent

	local c = Instance.new("UICorner"); c.CornerRadius = theme.Corner; c.Parent = tip
	Utils:Stroke(tip, theme.Foreground, 1, 0.35)

	return tip
end

function Dock:_makeButton(tab)
	local theme = self.Window.Theme
	local label = tab.Name or "Tab"
	local icon  = tab.Icon or "●"

	local b = Instance.new("TextButton")
	b.Name = "Ico_"..(tab.Id or tostring(math.random(1,1e6)))
	b.AutoButtonColor = false
	b.BackgroundColor3 = theme.Background
	b.BackgroundTransparency = 0.3
	b.Size = UDim2.fromOffset(36, 36)
	b.Text = icon
	b.TextColor3 = theme.Foreground
	b.TextSize = 16
	b.Font = theme.Font
	b.ZIndex = 5
	b.Parent = self.Rail

	local c = Instance.new("UICorner"); c.CornerRadius = theme.Corner; c.Parent = b
	Utils:Stroke(b, theme.Foreground, 1, 0.75)

	local tip = makeTooltip(self.Rail, theme, label)
	self._tooltips[b] = tip

	local function placeTip()
		-- Clamp inside rail with respect to UIPadding and tooltip height
		local top   = (self._pad and self._pad.PaddingTop.Offset or 0)
		local bot   = (self._pad and self._pad.PaddingBottom.Offset or 0)
		local maxY  = math.max(0, self.Rail.AbsoluteSize.Y - (tip.AbsoluteSize.Y + bot))
		local y     = b.AbsolutePosition.Y - self.Rail.AbsolutePosition.Y
		y = math.clamp(y, top, maxY)
		tip.Position = UDim2.fromOffset(self.Rail.AbsoluteSize.X + 6, y)
	end

	b.MouseEnter:Connect(function()
		Tween(b, {BackgroundTransparency = 0.15}, 0.08)
		placeTip()
		tip.Visible = true
		tip.BackgroundTransparency = 0.25; tip.TextTransparency = 0.25
		Tween(tip, {BackgroundTransparency = 0.04, TextTransparency = 0}, 0.08)
	end)
	b.MouseLeave:Connect(function()
		Tween(b, {BackgroundTransparency = (self._selected == b) and 0.05 or 0.3}, 0.08)
		Tween(tip, {BackgroundTransparency = 0.25, TextTransparency = 0.25}, 0.08)
		task.delay(0.08, function() if tip then tip.Visible = false end end)
	end)

	b.Activated:Connect(function()
		self:Select(tab, b)
		self.Window:_switchTo(tab)
	end)

	self.Buttons[tab] = b
end

function Dock:AddTab(tab) self:_makeButton(tab) end

function Dock:Select(tab, btn)
	for _, b in pairs(self.Buttons) do
		if b ~= btn then Tween(b, {BackgroundTransparency = 0.3}, 0.08) end
	end
	self._selected = btn
	Tween(btn, {BackgroundTransparency = 0.05}, 0.08)
end

function Dock:SetVisible(v)
	if v == self.Rail.Visible then return end
	self.Rail.Visible = true
	if v then
		Tween(self.Rail, {Position = UDim2.new(0,0,0,46)}, 0.18, Enum.EasingStyle.Quad)
	else
		Tween(self.Rail, {Position = UDim2.new(0,-46,0,46)}, 0.18, Enum.EasingStyle.Quad)
		task.delay(0.18, function() if self.Rail then self.Rail.Visible = false end end)
	end
end

return Dock
