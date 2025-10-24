local Tween     = require(script.Parent.Parent.lib.tween)
local Utils     = require(script.Parent.Parent.lib.utils)
local Fx        = require(script.Parent.Parent.lib.fx)
local Behaviors = require(script.Parent.Parent.lib.behaviors)
local Safety    = require(script.Parent.Parent.lib.safety)
local UIS       = game:GetService("UserInputService")

local Announce = {}
local _queue, _showing = {}, false

local function R(prefix)
	prefix = prefix or "Node"
	if Safety and Safety.RandomChildName then
		return Safety.RandomChildName(prefix)
	end
	return string.format("%s_%06d", prefix, math.random(0, 999999))
end

local function defaultTheme()
	return {
		Background = Color3.fromRGB(14,14,16),
		Foreground = Color3.fromRGB(235,235,240),
		Muted      = Color3.fromRGB(140,140,150),
		BaseTransparency   = 0.05,
		StrokeTransparency = 0.6,
		Corner     = UDim.new(0,8),
		Pad        = 10,
		Font       = Enum.Font.GothamMedium,
		EnableBrackets   = true,
		EnableScanlines  = true,
		EnablePulseStroke= true,
	}
end

local function showOnce(theme, opts, done)
	local root = Safety.GetRoot()

	local overlay = Instance.new("Frame")
	overlay.Name = R("Ann")
	overlay.Size = UDim2.fromScale(1,1)
	overlay.BackgroundColor3 = Color3.new(0,0,0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 240
	overlay.Active = true
	overlay.Parent = root
	Tween(overlay, {BackgroundTransparency = 0.25}, 0.2)

	local shell = Instance.new("Frame")
	shell.Name = R("AnnShell")
	shell.Size = UDim2.fromOffset(560, 260)
	shell.AnchorPoint = Vector2.new(0.5,0.5)
	shell.Position = UDim2.fromScale(0.5,0.53)
	shell.BackgroundColor3 = theme.Background
	shell.BackgroundTransparency = 0.15
	shell.ZIndex = 241
	shell.Parent = overlay
	Utils:Roundify(shell, theme.Corner)
	local stroke = Utils:Stroke(shell, theme.Foreground, 1.2, theme.StrokeTransparency)
	if theme.EnablePulseStroke then Fx.PulseStroke(stroke, theme) end

	local clip = Instance.new("Frame")
	clip.Name = R("Clip")
	clip.BackgroundTransparency = 1
	clip.Size = UDim2.fromScale(1,1)
	clip.ClipsDescendants = true
	clip.Parent = shell
	Utils:Roundify(clip, theme.Corner)

	local scale = Instance.new("UIScale"); scale.Scale = 0.9; scale.Parent = shell
	Tween(scale, {Scale = 1}, 0.22, Enum.EasingStyle.Quad)
	Tween(shell, {Position = UDim2.fromScale(0.5,0.5), BackgroundTransparency = 0.05}, 0.22)

	local header = Instance.new("Frame")
	header.Name = R("Header")
	header.Size = UDim2.new(1,0,0,34)
	header.BackgroundColor3 = theme.Background
	header.BackgroundTransparency = 0.15
	header.Parent = clip
	Utils:Stroke(header, theme.Foreground, 1, 0.8)
	Utils:Pad(header, theme.Pad)
	Utils:HList(header, 8)

	local title = Utils:Label({Text = opts.Title or "ANNOUNCEMENT", Parent = header, Theme = theme})
	title.TextSize = 16; title.Size = UDim2.new(1,-40,1,0)

	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "✕"; closeBtn.AutoButtonColor = false
	closeBtn.Font = theme.Font; closeBtn.TextSize = 16; closeBtn.TextColor3 = theme.Foreground
	closeBtn.BackgroundTransparency = 1
	closeBtn.Size = UDim2.fromOffset(24,24)
	closeBtn.AnchorPoint = Vector2.new(1,0.5)
	closeBtn.Position = UDim2.new(1,-6,0.5,0)
	closeBtn.Parent = header

	Behaviors.MakeDraggable(header, shell)

	local fx = {}
	if theme.EnableBrackets ~= false then fx.brk = Fx.AddCornerBrackets(shell, theme) end
	if theme.EnableScanlines ~= false then fx.scan = Fx.AttachScanlines(clip, theme, {speed=(opts.Fx and opts.Fx.ScanSpeed) or 110}) end
	fx.sweep = Fx.AttachTopSweep(clip, header, theme, {
		speed     = (opts.Fx and opts.Fx.TopSweepSpeed) or 140,
		glowWidth = (opts.Fx and opts.Fx.TopSweepGlow)  or 160,
		baseAlpha = 0.7, glowAlpha = 0.35
	})

	local body = Instance.new("Frame")
	body.Name = R("Body")
	body.BackgroundTransparency = 1
	body.Position = UDim2.new(0,0,0,42)
	body.Size = UDim2.new(1,0,1,-100)
	body.Parent = clip
	Utils:Pad(body, theme.Pad)

	local msg = Instance.new("TextLabel")
	msg.BackgroundTransparency = 1
	msg.Size = UDim2.new(1, -theme.Pad*2, 1, -theme.Pad*2)
	msg.Position = UDim2.fromOffset(theme.Pad, theme.Pad)
	msg.Font = theme.Font
	msg.Text = opts.Message or ""
	msg.TextColor3 = theme.Foreground
	msg.TextSize = 16
	msg.TextWrapped = true
	msg.RichText = opts.RichText == true
	msg.TextXAlignment = Enum.TextXAlignment.Left
	msg.TextYAlignment = Enum.TextYAlignment.Top
	msg.Parent = body

	local row = Instance.new("Frame")
	row.Name = R("Buttons")
	row.BackgroundTransparency = 1
	row.AnchorPoint = Vector2.new(0.5,1)
	row.Position = UDim2.new(0.5,0,1,-10)
	row.Size = UDim2.new(1,-20,0,36)
	row.Parent = clip

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.Padding = UDim.new(0,8)
	layout.Parent = row

	local buttons = opts.Buttons
	if not buttons or #buttons == 0 then buttons = { {Text="Close"} } end

	local function mk(def)
		local b = Instance.new("TextButton")
		b.AutoButtonColor = false
		b.Text = def.Text or "OK"
		b.Font = theme.Font; b.TextSize = 14; b.TextColor3 = theme.Foreground
		b.Size = UDim2.fromOffset(110, 32)
		b.BackgroundColor3 = theme.Background
		b.BackgroundTransparency = def.Primary and 0.05 or 0.15
		b.Parent = row
		Utils:Roundify(b, theme.Corner); Utils:Stroke(b, theme.Foreground, 1, 0.6)
		b.MouseEnter:Connect(function() Tween(b, {BackgroundTransparency = def.Primary and 0 or 0.05}, 0.08) end)
		b.MouseLeave:Connect(function() Tween(b, {BackgroundTransparency = def.Primary and 0.05 or 0.15}, 0.08) end)
		return b
	end

	for _,def in ipairs(buttons) do
		local b = mk(def)
		b.Activated:Connect(function()
			if def.Callback then task.spawn(def.Callback) end
			local endScale = Instance.new("UIScale"); endScale.Scale = 1; endScale.Parent = shell
			Tween(endScale, {Scale = 0.96}, 0.18, Enum.EasingStyle.Quad)
			Tween(shell, {Position = UDim2.fromScale(0.5,0.53), BackgroundTransparency = 0.25}, 0.18)
			Tween(overlay, {BackgroundTransparency = 1}, 0.18)
			task.delay(0.19, function()
				for _,h in pairs(fx) do if h and h.Destroy then h:Destroy() end end
				overlay:Destroy()
				done()
			end)
		end)
	end

	closeBtn.Activated:Connect(function()
		local first = row:FindFirstChildWhichIsA("TextButton")
		if first then first.Activated:Fire() end
	end)

	local esc; esc = UIS.InputBegan:Connect(function(i,gpe)
		if gpe then return end
		if i.KeyCode == Enum.KeyCode.Escape then
			esc:Disconnect()
			local first = row:FindFirstChildWhichIsA("TextButton")
			if first then first.Activated:Fire() end
		end
	end)

	if typeof(opts.Duration) == "number" and opts.Duration > 0 then
		task.delay(opts.Duration, function()
			if overlay.Parent then
				local first = row:FindFirstChildWhichIsA("TextButton")
				if first then first.Activated:Fire() end
			end
		end)
	end
end

function Announce.Show(themeOrWindow, opts)
	local theme = defaultTheme()
	if typeof(themeOrWindow) == "table" then
		if themeOrWindow.Theme and themeOrWindow.Gui then
			for k,v in pairs(themeOrWindow.Theme) do theme[k] = v end
		else
			for k,v in pairs(themeOrWindow) do theme[k] = v end
		end
	end
	opts = opts or { Message = "Hello." }

	table.insert(_queue, {theme=theme, opts=opts})
	if _showing then return end
	_showing = true

	task.spawn(function()
		while #_queue > 0 do
			local item = table.remove(_queue, 1)
			local done = false
			showOnce(item.theme, item.opts, function() done = true end)
			repeat task.wait(0.05) until done
		end
		_showing = false
	end)
end

return Announce
