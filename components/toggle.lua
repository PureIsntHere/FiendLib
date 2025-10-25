-- Fiend/components/toggle.lua

local Util   = require(script.Parent.Parent.lib.util)
local Theme  = require(script.Parent.Parent.lib.theme)
local Base   = require(script.Parent.Parent.lib.base_element)

local Toggle = {}

local function padPx(theme)
	if theme.Pad and typeof(theme.Pad) == "UDim" then return theme.Pad.Offset end
	if typeof(theme.Padding) == "number" then return theme.Padding end
	return 8
end
local function corner(theme)
	if theme.Corner and typeof(theme.Corner) == "UDim" then return theme.Corner end
	if typeof(theme.Rounding) == "number" then return UDim.new(0, theme.Rounding) end
	return UDim.new(0, 8)
end

local function makeLabel(parent, theme, text, p)
	local lbl = Util.Create("TextLabel", {
		Parent = parent, BackgroundTransparency = 1,
		Text = tostring(text or ""), Font = theme.Font or Enum.Font.Gotham,
		TextSize = 16, TextColor3 = theme.Foreground or theme.TextColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -(76 + p*2), 1, 0), Position = UDim2.new(0, p, 0, 0),
	})
	return lbl
end

function Toggle.new(tabOrGroup, text, default, callback)
	local w = tabOrGroup.Window or (tabOrGroup.Tab and tabOrGroup.Tab.Window)
	local theme = (w and w.Theme) or Theme
	local container = tabOrGroup.Content or tabOrGroup.Container
	local p, cr = padPx(theme), corner(theme)

	local row = Util.Create("Frame", {
		Parent = container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36),
	})

	local label = makeLabel(row, theme, text, p)

	local track = Util.Create("Frame", {
		Parent = row, BackgroundColor3 = theme.Background2 or theme.Background,
		BorderSizePixel = 0, Size = UDim2.new(0, 56, 0, 26),
		Position = UDim2.new(1, -(56 + p), 0.5, -13),
	})
	Util:Roundify(track, cr)
	Util:Stroke(track, theme.Border, 1)

	local knob = Util.Create("Frame", {
		Parent = track, BackgroundColor3 = theme.Accent, BorderSizePixel = 0,
		Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 2, 0, 2),
	})
	Util:Roundify(knob, cr)

	local on = default and true or false
	local function apply(v, animate)
		on = v and true or false
		local x = on and (56 - 24) or 2
		if animate then
			Util.Tween(knob, { Position = UDim2.new(0, x, 0, 2) }, 0.12)
			Util.Tween(track, { BackgroundColor3 = on and (theme.AccentDim or theme.Accent) or (theme.Background2 or theme.Background) }, 0.12)
		else
			knob.Position = UDim2.new(0, x, 0, 2)
			track.BackgroundColor3 = on and (theme.AccentDim or theme.Accent) or (theme.Background2 or theme.Background)
		end
	end
	apply(on, false)

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			apply(not on, true)
			if typeof(callback) == "function" then task.spawn(callback, on) end
		end
	end)

	local self = Base.new({ Name = "Toggle", Text = text or "", Callback = callback })
	self.Root = row
	function self:SetValue(v, fire) apply(v, true); if fire and callback then task.spawn(callback, on) end end
	function self:GetValue() return on end
	function self:SetText(t) label.Text = tostring(t or "") end
	function self:SetVisible(v) row.Visible = v and true or false end
	function self:Destroy() if row then row:Destroy() end end

	return self
end

return Toggle
