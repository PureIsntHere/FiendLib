-- Fiend/components/slider.lua

local UIS    = game:GetService("UserInputService")
local Util   = require(script.Parent.Parent.lib.util)
local Theme  = require(script.Parent.Parent.lib.theme)

local Slider = {}

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
	return Util.Create("TextLabel", {
		Parent = parent, BackgroundTransparency = 1, Text = tostring(text or ""),
		Font = theme.Font or Enum.Font.Gotham, TextSize = 16,
		TextColor3 = theme.Foreground or theme.TextColor, TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -(p*2), 0, 18), Position = UDim2.new(0, p, 0, 0),
	})
end
local function makeValueLabel(parent, theme)
	return Util.Create("TextLabel", {
		Parent = parent, BackgroundTransparency = 1, Text = "",
		Font = theme.FontMono or Enum.Font.Code, TextSize = 14,
		TextColor3 = theme.SubTextColor, TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(1, -10, 0, 18), Position = UDim2.new(0, 0, 0, 18),
	})
end

function Slider.new(tabOrGroup, text, min, max, default, callback)
	local w = tabOrGroup.Window or (tabOrGroup.Tab and tabOrGroup.Tab.Window)
	local theme = (w and w.Theme) or Theme
	local container = tabOrGroup.Content or tabOrGroup.Container
	local p, cr    = padPx(theme), corner(theme)

	local row = Util.Create("Frame", { Parent = container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 58) })
	local label = makeLabel(row, theme, text, p)
	local valueLbl = makeValueLabel(row, theme)

	min = tonumber(min) or 0
	max = tonumber(max) or 100
	default = tonumber(default) or min

	local bar = Util.Create("Frame", {
		Parent = row, BackgroundColor3 = theme.Background2 or theme.Background, BorderSizePixel = 0,
		Size = UDim2.new(1, -(p*2), 0, 10), Position = UDim2.new(0, p, 0, 38),
	})
	Util:Roundify(bar, cr)
	Util:Stroke(bar, theme.Border, 1)

	local fill = Util.Create("Frame", {
		Parent = bar, BackgroundColor3 = theme.Accent, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0),
	})
	Util:Roundify(fill, cr)

	local current = default
	local function set(v, fire)
		current = math.clamp(math.floor(tonumber(v) or min), min, max)
		local pct = (current - min) / math.max(1, (max - min))
		fill.Size = UDim2.new(pct, 0, 1, 0)
		valueLbl.Text = tostring(current)
		if fire and typeof(callback) == "function" then task.spawn(callback, current) end
	end
	set(default, false)

	local dragging = false
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			local abs = bar.AbsolutePosition.X
			local w = math.max(1, bar.AbsoluteSize.X)
			local function update()
				local mx = UIS:GetMouseLocation().X
				local pct = math.clamp((mx - abs) / w, 0, 1)
				set(min + pct * (max - min), true)
			end
			update()
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local abs = bar.AbsolutePosition.X
			local w = math.max(1, bar.AbsoluteSize.X)
			local mx = UIS:GetMouseLocation().X
			local pct = math.clamp((mx - abs) / w, 0, 1)
			set(min + pct * (max - min), true)
		end
	end)

	return {
		Get = function() return current end,
		Set = function(v, fire) set(v, fire) end,
	}
end

return Slider
