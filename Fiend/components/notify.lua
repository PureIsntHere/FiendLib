-- Fiend/components/notify (single-root toast stack, resilient to missing Safety.RandomChildName)

local Tween  = require(script.Parent.Parent.lib.tween)
local Safety = require(script.Parent.Parent.lib.safety)

local Notify = {}
Notify.__index = Notify

-- Fallback random name helper if Safety.RandomChildName isn't present yet
local function R(prefix)
	prefix = prefix or "Node"
	if Safety and Safety.RandomChildName then
		return Safety.RandomChildName(prefix)
	end
	return string.format("%s_%06d", prefix, math.random(0, 999999))
end

local function defaultTheme()
	return {
		Background = Color3.fromRGB(16,16,18),
		Foreground = Color3.fromRGB(225,225,230),
		Corner     = UDim.new(0,8),
		Font       = Enum.Font.GothamMedium,
	}
end

function Notify.new(theme)
	theme = theme or defaultTheme()
	local root = Safety.GetRoot()

	local stack = Instance.new("Frame")
	stack.Name = R("Toast")
	stack.BackgroundTransparency = 1
	stack.Size = UDim2.new(0, 320, 1, -20)
	stack.Position = UDim2.new(1, -340, 0, 10)
	stack.ZIndex = 220
	stack.Parent = root

	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0,8)
	layout.Parent = stack

	return setmetatable({Stack = stack, Theme = theme}, Notify)
end

function Notify:Push(text, duration)
	duration = duration or 3
	local theme = self.Theme or defaultTheme()

	local f = Instance.new("Frame")
	f.Name = R("ToastItem")
	f.BackgroundColor3 = theme.Background
	f.BackgroundTransparency = 0.15
	f.Size = UDim2.new(1,0,0,32)
	f.Parent = self.Stack

	local c = Instance.new("UICorner")
	c.CornerRadius = theme.Corner
	c.Parent = f

	local s = Instance.new("UIStroke")
	s.Color = theme.Foreground
	s.Transparency = 0.6
	s.Parent = f

	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = theme.Font
	l.TextColor3 = theme.Foreground
	l.TextSize = 14
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Text = text
	l.Size = UDim2.fromScale(1,1)
	l.Parent = f

	f.BackgroundTransparency = 1; s.Transparency = 1
	Tween(f, {BackgroundTransparency=0.15}, 0.2)
	Tween(s, {Transparency=0.6}, 0.2)

	task.delay(duration, function()
		Tween(f, {BackgroundTransparency=1}, 0.2)
		Tween(s, {Transparency=1}, 0.2)
		task.wait(0.22)
		f:Destroy()
	end)
end

return Notify
