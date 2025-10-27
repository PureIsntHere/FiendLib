-- Fiend/components/notify.lua

local Util = FiendModules.Util
local Theme = FiendModules.Theme

local Notify = {}
Notify.__index = Notify

local function padPx(theme)
	if theme.Pad and typeof(theme.Pad) == "UDim" then return theme.Pad.Offset end
	if typeof(theme.Padding) == "number" then return theme.Padding end
	return 8
end

function Notify.new(theme)
	local self = setmetatable({}, Notify)
	self.Theme = theme or Theme
	self.Gui = nil
	self.Holder = nil
	return self
end

function Notify:AttachTo(parent)
	if self.Gui then self.Gui:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name = "Fiend_Notify"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parent
	self.Gui = gui

	local hold = Instance.new("Frame")
	hold.BackgroundTransparency = 1
	hold.Size = UDim2.fromScale(1,1)
	hold.Parent = gui

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.HorizontalAlignment = Enum.HorizontalAlignment.Right
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.Padding = UDim.new(0, 6)
	list.Parent = hold

	self.Holder = hold
end

function Notify:Push(text, duration)
	if not self.Holder then return end
	duration = tonumber(duration) or 2

	-- Get current theme from library
	local theme = self.Theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		theme = _G.FiendInstance.Theme
	end
	
	local p = padPx(theme)

	local toast = Instance.new("Frame")
	toast.BackgroundColor3 = theme.Background2 or theme.Background
	toast.BorderSizePixel = 0
	toast.Size = UDim2.new(0, 400, 0, 48)
	toast.AnchorPoint = Vector2.new(1, 1)
	toast.Position = UDim2.new(1, -p, 1, -p)
	toast.Parent = self.Holder

	Util:Roundify(toast, theme.Corner or UDim.new(0, theme.Rounding or 8))
	Util:Stroke(toast, theme.Border, 1)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = theme.Font or Enum.Font.Gotham
	label.TextSize = 16
	label.TextColor3 = theme.Foreground or theme.TextColor
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = tostring(text or "")
	label.Size = UDim2.new(1, - (p*2), 1, 0)
	label.Position = UDim2.new(0, p, 0, 0)
	label.Parent = toast

	-- enter
	toast.BackgroundTransparency = 1
	label.TextTransparency = 1
	Util.Tween(toast, theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
	Util.Tween(label, theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })

	-- leave
	task.delay(duration, function()
		Util.Tween(label, theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })
		local t = Util.Tween(toast, theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
		t.Completed:Wait()
		if toast then toast:Destroy() end
	end)
end

return Notify
