-- Fiend/components/button.lua
-- Full-width action button row (safe against nil theme fields).

local TweenService = game:GetService("TweenService")

local Util       = require(script.Parent.Parent.lib.util)
local Theme      = require(script.Parent.Parent.lib.theme)
local Base       = require(script.Parent.Parent.lib.base_element)

local Button = {}

local function padPx(theme)
	if theme.Pad and typeof(theme.Pad) == "UDim" then
		return theme.Pad.Offset
	end
	if typeof(theme.Padding) == "number" then
		return theme.Padding
	end
	return 8
end

local function corner(theme)
	if theme.Corner and typeof(theme.Corner) == "UDim" then
		return theme.Corner
	end
	if typeof(theme.Rounding) == "number" then
		return UDim.new(0, theme.Rounding)
	end
	return UDim.new(0, 8)
end

function Button.new(tabOrGroup, text, callback)
	local window = tabOrGroup.Window or (tabOrGroup.Tab and tabOrGroup.Tab.Window)
	local theme  = (window and window.Theme) or Theme
	local container = tabOrGroup.Content or tabOrGroup.Container
	local p      = padPx(theme)
	local cr     = corner(theme)

	-- Row container
	local row = Util.Create("Frame", {
		Name = "ButtonRow",
		Parent = container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36),
	})

	-- Actual button
	local btn = Util.Create("TextButton", {
		Name = "Button",
		Parent = row,
		Text = tostring(text or "Button"),
		Font = theme.Font or Enum.Font.Gotham,
		TextSize = 16,
		TextColor3 = theme.Foreground or theme.TextColor or Color3.fromRGB(235,239,244),
		AutoButtonColor = false,
		BackgroundColor3 = theme.Background2 or theme.Background or Color3.fromRGB(18,20,25),
		BorderSizePixel = 0,
		Size = UDim2.new(1, -(p * 2), 1, 0),
		Position = UDim2.new(0, p, 0, 0),
	})
	Util:Roundify(btn, cr)
	Util:Stroke(btn, theme.Border or Color3.fromRGB(38,44,58), 1)

	btn.MouseEnter:Connect(function()
		Util.Tween(btn, { BackgroundColor3 = theme.Background or Color3.fromRGB(10,11,14) }, 0.15)
	end)
	btn.MouseLeave:Connect(function()
		Util.Tween(btn, { BackgroundColor3 = theme.Background2 or Color3.fromRGB(18,20,25) }, 0.15)
	end)
	btn.MouseButton1Click:Connect(function()
		if typeof(callback) == "function" then
			task.spawn(callback)
		end
	end)

	-- BaseElement wrapper (so SetCallback / SetText etc. work)
	local self = Base.new({
		Name = "Button",
		Text = text or "Button",
		Callback = callback,
	})
	self.Root = row

	function self:SetText(t)
		btn.Text = tostring(t or "")
	end

	function self:SetCallback(fn)
		self.Callback = fn
	end

	function self:SetVisible(v)
		row.Visible = v and true or false
	end

	function self:Destroy()
		if row then row:Destroy() end
	end

	return self
end

return Button
