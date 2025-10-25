-- Fiend/components/dropdown.lua
-- Dropdown row: full-width button opens a popover list on the float layer.

local UserInputService = game:GetService("UserInputService")

local Util    = require(script.Parent.Parent.lib.util)
local Theme   = require(script.Parent.Parent.lib.theme)
local Safety  = require(script.Parent.Parent.lib.safety)

local Dropdown = {}

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

local function buildPopover(theme, anchorBtn, items, onPick)
	local p = padPx(theme)
	local cr = corner(theme)

	local layer = Safety.GetFloatLayer()
	layer.Visible = true

	-- Popover shell
	local pop = Util.Create("Frame", {
		Name = "DropdownPopover",
		Parent = layer,
		BackgroundColor3 = theme.Background2 or theme.Background or Color3.fromRGB(18,20,25),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(math.max(220, anchorBtn.AbsoluteSize.X), math.min(200, (#items * 28) + p * 2)),
		ZIndex = 700,
	})
	Util:Roundify(pop, cr)
	Util:Stroke(pop, theme.Border or Color3.fromRGB(38,44,58), 1)
	Util:Pad(pop, UDim.new(0, p))

	-- Position below the button (stay on-screen)
	local function place()
		local screen = layer.AbsoluteSize
		local pos = anchorBtn.AbsolutePosition
		local x = math.clamp(pos.X, 8, math.max(8, screen.X - pop.AbsoluteSize.X - 8))
		local y = math.clamp(pos.Y + anchorBtn.AbsoluteSize.Y + 6, 8, math.max(8, screen.Y - pop.AbsoluteSize.Y - 8))
		pop.Position = UDim2.fromOffset(x, y)
	end
	place()

	-- Scrolling holder
	local sc = Util.Create("ScrollingFrame", {
		Name = "List",
		Parent = pop,
		BackgroundTransparency = 1,
		ScrollBarThickness = 4,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, (#items * 28)),
	})
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 6)
	list.Parent = sc

	-- Build options
	for _, item in ipairs(items) do
		local text = tostring(item)
		local btn = Util.Create("TextButton", {
			Name = "Option",
			Parent = sc,
			Text = text,
			Font = theme.Font or Enum.Font.Gotham,
			TextSize = 16,
			TextColor3 = theme.Foreground or theme.TextColor or Color3.fromRGB(235,239,244),
			AutoButtonColor = false,
			BackgroundColor3 = theme.Background or Color3.fromRGB(10,11,14),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 28),
		})
		Util:Roundify(btn, cr)
		Util:Stroke(btn, theme.Border or Color3.fromRGB(38,44,58), 1)

		btn.MouseEnter:Connect(function()
			Util.Tween(btn, { BackgroundColor3 = theme.Background2 or Color3.fromRGB(18,20,25) }, 0.12)
		end)
		btn.MouseLeave:Connect(function()
			Util.Tween(btn, { BackgroundColor3 = theme.Background or Color3.fromRGB(10,11,14) }, 0.12)
		end)
		btn.MouseButton1Click:Connect(function()
			if typeof(onPick) == "function" then
				onPick(text)
			end
			pop:Destroy()
		end)
	end

	-- Close on ESC / outside click
	local escConn, outConn
	escConn = UserInputService.InputBegan:Connect(function(i, gp)
		if gp then return end
		if i.KeyCode == Enum.KeyCode.Escape then
			if escConn then escConn:Disconnect() end
			if outConn then outConn:Disconnect() end
			pop:Destroy()
		end
	end)
	outConn = UserInputService.InputBegan:Connect(function(i, gp)
		if gp then return end
		-- crude outside check
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			local mpos = UserInputService:GetMouseLocation()
			local x, y = mpos.X, mpos.Y
			local abs = pop.AbsolutePosition
			local siz = pop.AbsoluteSize
			local inside = (x >= abs.X and x <= abs.X + siz.X and y >= abs.Y and y <= abs.Y + siz.Y)
			if not inside then
				if escConn then escConn:Disconnect() end
				if outConn then outConn:Disconnect() end
				pop:Destroy()
			end
		end
	end)

	return pop
end

-- Public API:
-- Dropdown.new(tab, labelText, list, defaultValue, callback(value)) -> { Get, SetList }
function Dropdown.new(tabOrGroup, labelText, list, defaultValue, callback)
	list = list or {}
	local window = tabOrGroup.Window or (tabOrGroup.Tab and tabOrGroup.Tab.Window)
	local theme  = (window and window.Theme) or Theme
	local container = tabOrGroup.Content or tabOrGroup.Container
	local p      = padPx(theme)
	local cr     = corner(theme)

	-- Row
	local row = Util.Create("Frame", {
		Name = "DropdownRow",
		Parent = container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36),
	})

	-- Button (shows current value)
	local value = defaultValue or (list[1] and tostring(list[1])) or ""
	local btn = Util.Create("TextButton", {
		Name = "DropdownButton",
		Parent = row,
		Text = (labelText and (tostring(labelText) .. ": ") or "") .. tostring(value),
		Font = theme.Font or Enum.Font.Gotham,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = theme.Foreground or theme.TextColor or Color3.fromRGB(235,239,244),
		AutoButtonColor = false,
		BackgroundColor3 = theme.Background2 or theme.Background or Color3.fromRGB(18,20,25),
		BorderSizePixel = 0,
		Size = UDim2.new(1, -(p * 2), 1, 0),
		Position = UDim2.new(0, p, 0, 0),
	})
	Util:Roundify(btn, cr)
	Util:Stroke(btn, theme.Border or Color3.fromRGB(38,44,58), 1)

	local function setValue(v, fire)
		value = tostring(v or "")
		btn.Text = (labelText and (tostring(labelText) .. ": ") or "") .. value
		if fire and typeof(callback) == "function" then
			task.spawn(callback, value)
		end
	end

	btn.MouseButton1Click:Connect(function()
		-- open popover with current list
		buildPopover(theme, btn, list, function(picked)
			setValue(picked, true)
		end)
	end)

	-- Hover effect
	btn.MouseEnter:Connect(function()
		Util.Tween(btn, { BackgroundColor3 = theme.Background or Color3.fromRGB(10,11,14) }, 0.15)
	end)
	btn.MouseLeave:Connect(function()
		Util.Tween(btn, { BackgroundColor3 = theme.Background2 or Color3.fromRGB(18,20,25) }, 0.15)
	end)

	-- public surface
	local api = {
		Get = function() return value end,
		SetList = function(newList)
			list = newList or {}
		end,
	}
	return api
end

return Dropdown
