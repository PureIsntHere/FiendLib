local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Util = FiendModules.Util
local Theme = FiendModules.Theme
local Safety = FiendModules.Safety

local Announce = {}

local function getPadPx(theme)
	if theme.Pad and typeof(theme.Pad) == "UDim" then
		return theme.Pad.Offset
	end
	if typeof(theme.Padding) == "number" then
		return theme.Padding
	end
	return 8
end

local function getCorner(theme)
	if theme.Corner and typeof(theme.Corner) == "UDim" then
		return theme.Corner
	end
	if typeof(theme.Rounding) == "number" then
		return UDim.new(0, theme.Rounding)
	end
	return UDim.new(0, 8)
end

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

-- opts = {
--   Title: string,
--   Message: string,
--   RichText: boolean?,
--   Buttons: { { Text = "Got it", Primary = true, Callback = fn }, ... }?
-- }
function Announce.Show(window, opts)
	opts = opts or {}

	local theme = (window and window.Theme) or Theme
	local padPx = getPadPx(theme)
	local corner = getCorner(theme)

	-- Float layer so it appears above everything
	local layer = Safety.GetFloatLayer()
	layer.Visible = true

	-- Overlay
	local overlay = Util.Create("Frame", {
		Name = "Fiend_AnnounceOverlay",
		Parent = layer,
		BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		ZIndex = 600,
	})

	-- Card
	local cw, ch = 520, 280
	local card = Util.Create("Frame", {
		Name = "Card",
		Parent = overlay,
		BackgroundColor3 = theme.Background2 or theme.Background or Color3.fromRGB(20,22,26),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(cw, ch),
		Position = UDim2.new(0.5, -cw/2, 0.5, -ch/2 + 8),
		ZIndex = 601,
	})
	Util:Roundify(card, corner)
	Util:Stroke(card, theme.Border or Color3.fromRGB(42,48,60), 1)
	Util:Pad(card, UDim.new(0, padPx))

	-- Title bar-ish header
	local header = Util.Create("TextLabel", {
		Name = "Title",
		Parent = card,
		BackgroundTransparency = 1,
		Text = tostring(opts.Title or "Announcement"),
		Font = theme.FontMono or Enum.Font.Code,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = theme.Foreground or theme.TextColor or Color3.fromRGB(235,239,244),
		Size = UDim2.new(1, 0, 0, 24),
		ZIndex = 602,
	})

	local hr = Util.Create("Frame", {
		Name = "Rule",
		Parent = card,
		BackgroundColor3 = theme.Border or Color3.fromRGB(42,48,60),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 24 + math.floor(padPx*0.5)),
		ZIndex = 602,
	})

	-- Message body
	local body = Util.Create("TextLabel", {
		Name = "Body",
		Parent = card,
		BackgroundTransparency = 1,
		Text = tostring(opts.Message or ""),
		RichText = opts.RichText == true,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Font = theme.Font or Enum.Font.Gotham,
		TextSize = 16,
		TextColor3 = theme.Foreground or theme.TextColor or Color3.fromRGB(235,239,244),
		Size = UDim2.new(1, 0, 1, -(24 + math.floor(padPx*0.5) + 48 + padPx)), -- safe math
		Position = UDim2.new(0, 0, 0, 24 + math.floor(padPx*0.5) + 8),
		ZIndex = 602,
	})

	-- Buttons row
	local btnRow = Util.Create("Frame", {
		Name = "Buttons",
		Parent = card,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 1, -(36 + padPx)),
		ZIndex = 602,
	})
	local uiList = Instance.new("UIListLayout")
	uiList.FillDirection = Enum.FillDirection.Horizontal
	uiList.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiList.Padding = UDim.new(0, 8)
	uiList.Parent = btnRow

	local function close()
		tween(overlay, theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
		tween(card, theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, -cw/2, 0.5, -ch/2 + 8) })
		task.delay(0.16, function()
			overlay:Destroy()
		end)
	end

	-- Build buttons (default: one "Got it" button)
	local buttons = opts.Buttons
	if not buttons or #buttons == 0 then
		buttons = { { Text = "Got it", Primary = true } }
	end

	for _, b in ipairs(buttons) do
		local btn = Util.Create("TextButton", {
			Name = "Button",
			Parent = btnRow,
			Text = tostring(b.Text or "OK"),
			Font = theme.Font or Enum.Font.Gotham,
			TextSize = 16,
			TextColor3 = theme.Foreground or theme.TextColor or Color3.fromRGB(235,239,244),
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = b.Primary and (theme.Accent or Color3.fromRGB(86,140,255)) or (theme.Background or Color3.fromRGB(12,12,14)),
			Size = UDim2.new(0, 120, 1, 0),
			ZIndex = 603,
		})
		Util:Roundify(btn, corner)
		Util:Stroke(btn, theme.Border or Color3.fromRGB(42,48,60), b.Primary and 0 or 1)

		btn.MouseEnter:Connect(function()
			if not b.Primary then
				Util.Tween(btn, {BackgroundColor3 = theme.Background2 or Color3.fromRGB(20,22,26)}, 0.15)
			else
				Util.Tween(btn, {BackgroundColor3 = theme.AccentDim or Color3.fromRGB(54,90,190)}, 0.15)
			end
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = b.Primary and (theme.Accent or Color3.fromRGB(86,140,255)) or (theme.Background or Color3.fromRGB(12,12,14))
		end)

		btn.MouseButton1Click:Connect(function()
			if typeof(b.Callback) == "function" then
				task.spawn(b.Callback)
			end
			close()
		end)
	end

	-- Enter animation
	tween(overlay, theme.TweenLong or TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.35 })
	tween(card, theme.TweenLong or TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, -cw/2, 0.5, -ch/2) })

	-- ESC to close
	local escConn
	escConn = UserInputService.InputBegan:Connect(function(i, gp)
		if gp then return end
		if i.KeyCode == Enum.KeyCode.Escape then
			if escConn then escConn:Disconnect() end
			close()
		end
	end)

	return overlay
end

return Announce