local Tween     = require(script.Parent.tween)
local Utils     = require(script.Parent.utils)
local Fx        = require(script.Parent.fx)
local Behaviors = require(script.Parent.behaviors)
local Safety    = require(script.Parent.safety)

local KeyGate = {}

local function R(prefix)
	prefix = prefix or "Node"
	if Safety and Safety.RandomChildName then
		return Safety.RandomChildName(prefix)
	end
	return string.format("%s_%06d", prefix, math.random(0, 999999))
end

function KeyGate.Show(guiIgnored, theme, cfg, onAccept)
	cfg = cfg or {}
	local root = Safety.GetRoot()

	local overlay = Instance.new("Frame")
	overlay.Name = R("Gate")
	overlay.Size = UDim2.fromScale(1,1)
	overlay.BackgroundColor3 = Color3.new(0,0,0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 240
	overlay.Active = true
	overlay.Parent = root
	Tween(overlay, {BackgroundTransparency = 0.25}, 0.25)

	local shell = Instance.new("Frame")
	shell.Name = R("KeyShell")
	shell.Size = UDim2.fromOffset(380, 200)
	shell.Position = UDim2.fromScale(0.5, 0.53)
	shell.AnchorPoint = Vector2.new(0.5, 0.5)
	shell.BackgroundColor3 = theme.Background
	shell.BackgroundTransparency = 0.15
	shell.ZIndex = 241
	shell.Parent = overlay
	Utils:Roundify(shell, theme.Corner)
	local stroke = Utils:Stroke(shell, theme.Foreground, 1, 0.6)
	if theme.EnablePulseStroke ~= false then Fx.PulseStroke(stroke, theme) end

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
	header.Size = UDim2.new(1,0,0,28)
	header.BackgroundColor3 = theme.Background
	header.BackgroundTransparency = 0.15
	header.Parent = clip
	Utils:Stroke(header, theme.Foreground, 1, 0.8)
	Utils:Pad(header, theme.Pad)
	Utils:HList(header, 8)

	local title = Utils:Label({Text = cfg.Title or "ACCESS REQUIRED", Parent = header, Theme = theme})
	title.TextSize = 16; title.Size = UDim2.new(1,-40,1,0)
	Behaviors.MakeDraggable(header, shell)

	local fx = {}
	if theme.EnableBrackets ~= false then fx.brk = Fx.AddCornerBrackets(shell, theme) end
	if theme.EnableScanlines ~= false then fx.scan = Fx.AttachScanlines(clip, theme, {speed = (cfg.Fx and cfg.Fx.ScanSpeed) or 110}) end
	fx.sweep = Fx.AttachTopSweep(clip, header, theme, {
		speed     = (cfg.Fx and cfg.Fx.TopSweepSpeed) or 140,
		glowWidth = (cfg.Fx and cfg.Fx.TopSweepGlow)  or 160,
		baseAlpha = 0.7, glowAlpha = 0.35
	})

	local hint = Utils:Label({Text = cfg.Hint or "Enter your Archfiend key to unlock access.", Parent = clip, Theme = theme})
	hint.TextColor3 = theme.Muted; hint.Position = UDim2.new(0, theme.Pad, 0, 36)
	hint.Size = UDim2.new(1, -theme.Pad*2, 0, 18)

	local row = Instance.new("Frame")
	row.Name = R("Row")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1,-theme.Pad*2,0,32)
	row.Position = UDim2.new(0, theme.Pad, 0, 68)
	row.Parent = clip
	Utils:HList(row, theme.Pad)

	local box = Instance.new("TextBox")
	box.ClearTextOnFocus = false; box.PlaceholderText = "Enter key…"; box.Text = ""
	box.Font = theme.Font; box.TextSize = 14; box.TextColor3 = theme.Foreground
	box.BackgroundColor3 = theme.Background; box.BackgroundTransparency = 0.15
	box.Size = UDim2.new(1, -120 - theme.Pad, 1, 0); box.Parent = row
	Utils:Roundify(box, theme.Corner); Utils:Stroke(box, theme.Foreground, 1, 0.7); Utils:Pad(box, 6)

	local submit = Instance.new("TextButton")
	submit.AutoButtonColor = false; submit.Text = "UNLOCK"
	submit.Font = theme.Font; submit.TextSize = 14; submit.TextColor3 = theme.Foreground
	submit.BackgroundColor3 = theme.Background; submit.BackgroundTransparency = 0.15
	submit.Size = UDim2.fromOffset(100, 32); submit.Parent = row
	Utils:Roundify(submit, theme.Corner); Utils:Stroke(submit, theme.Foreground, 1, 0.7)

	local msg = Utils:Label({Text = "", Parent = clip, Theme = theme})
	msg.TextColor3 = Color3.fromRGB(255,140,140)
	msg.Position = UDim2.new(0, theme.Pad, 0, 108)
	msg.Size = UDim2.new(1, -theme.Pad*2, 0, 18)

	local function destroyFx()
		for _,h in pairs(fx) do if h and h.Destroy then h:Destroy() end end
	end
	local function close()
		local endScale = Instance.new("UIScale"); endScale.Scale = 1; endScale.Parent = shell
		Tween(endScale, {Scale = 0.96}, 0.18, Enum.EasingStyle.Quad)
		Tween(shell, {Position = UDim2.fromScale(0.5,0.53), BackgroundTransparency = 0.25}, 0.18)
		Tween(overlay, {BackgroundTransparency = 1}, 0.18)
		task.delay(0.19, function() destroyFx(); overlay:Destroy() end)
	end

	local function tryAccept()
		if box.Text == tostring(cfg.Key) then
			close(); onAccept()
		else
			msg.Text = "Invalid key. Try again."
			local p = shell.Position
			local function n(dx) shell.Position = p + UDim2.fromOffset(dx,0); task.wait(0.03) end
			n(-6); n(6); n(-4); n(4); shell.Position = p
		end
	end

	submit.Activated:Connect(tryAccept)
	box.FocusLost:Connect(function(enter) if enter then tryAccept() end end)

	return { Destroy = function() destroyFx(); overlay:Destroy() end }
end

return KeyGate