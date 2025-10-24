local Tween = require(script.Parent.tween)
local Run   = game:GetService("RunService")

local Fx = {}

-- Soft “breathing” stroke (toggle by passing theme.EnablePulseStroke)
function Fx.PulseStroke(stroke, theme)
	if not theme.EnablePulseStroke then return end
	task.spawn(function()
		while stroke.Parent do
			Tween(stroke, {Transparency = 0.35}, 1.0, Enum.EasingStyle.Sine)
			task.wait(1.0)
			Tween(stroke, {Transparency = 0.65}, 1.0, Enum.EasingStyle.Sine)
			task.wait(1.0)
		end
	end)
end

-- Inset L-brackets; returns a handle so we can Destroy() later
function Fx.AddCornerBrackets(frame, theme)
	if not theme.EnableBrackets then return {Destroy=function() end} end

	local holder = Instance.new("Frame")
	holder.Name = "Fx_Brackets"
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromScale(1,1)
	holder.ZIndex = (frame.ZIndex or 1) + 1
	holder.Parent = frame

	local inset, len = 6, 10
	local function corner(ax, ay)
		local g = Instance.new("Frame")
		g.BackgroundTransparency = 1
		g.Size = UDim2.fromOffset(len+inset, len+inset)
		g.AnchorPoint = Vector2.new(ax, ay)
		g.Position = UDim2.new(ax, ax==0 and inset or -inset, ay, ay==0 and inset or -inset)
		g.Parent = holder

		local h = Instance.new("Frame"); h.BorderSizePixel = 0; h.BackgroundColor3 = theme.Foreground
		h.Size = UDim2.new(0, len, 0, 1)
		h.Position = UDim2.new(ax==0 and 0 or 1, ax==0 and 0 or -len, ay==0 and 0 or 1, ay==0 and 0 or -1)
		h.Parent = g

		local v = Instance.new("Frame"); v.BorderSizePixel = 0; v.BackgroundColor3 = theme.Foreground
		v.Size = UDim2.new(0, 1, 0, len)
		v.Position = UDim2.new(ax==0 and 0 or 1, ax==0 and 0 or -1, ay==0 and 0 or 1, ay==0 and 0 or -len)
		v.Parent = g
	end
	corner(0,0); corner(1,0); corner(0,1); corner(1,1)

	return { Destroy = function() if holder then holder:Destroy() end end }
end

-- Vertical scanline; cfg = {speed:number}
function Fx.AttachScanlines(parent, theme, cfg)
	if not theme.EnableScanlines then return {Destroy=function() end} end

	local overlay = Instance.new("Frame")
	overlay.Name = "Fx_Scan"
	overlay.BackgroundTransparency = 1
	overlay.Size = UDim2.fromScale(1,1)
	overlay.ZIndex = (parent.ZIndex or 1) + 1
	overlay.ClipsDescendants = true
	overlay.Parent = parent

	local bar = Instance.new("Frame")
	bar.Name = "ScanBar"
	bar.Size = UDim2.new(1,0,0,2)
	bar.BackgroundColor3 = theme.Foreground
	bar.BackgroundTransparency = 0.85
	bar.BorderSizePixel = 0
	bar.Parent = overlay

	local speed = (cfg and cfg.speed) or 110
	local running = true

	task.spawn(function()
		while running and overlay.Parent do
			local h = overlay.AbsoluteSize.Y
			local startY, endY = -6, h + 6
			local dist = endY - startY
			local duration = dist / speed
			bar.Position = UDim2.new(0,0,0,startY)
			Tween(bar, {Position = UDim2.new(0,0,0,endY)}, duration, Enum.EasingStyle.Linear)
			task.wait(duration + 0.02)
		end
	end)

	return {
		Destroy = function() running = false; if overlay then overlay:Destroy() end end
	}
end

-- Top sweep under TitleBar; cfg = {speed:number, glowWidth:number, baseAlpha:number, glowAlpha:number}
function Fx.AttachTopSweep(root, titleBar, theme, cfg)
	local holder = Instance.new("Frame")
	holder.Name = "Fx_TopSweep"
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(1,0,0,2)
	holder.ZIndex = (root.ZIndex or 1) + 2
	holder.ClipsDescendants = true
	holder.Parent = root

	local base = Instance.new("Frame")
	base.Name = "Base"
	base.BackgroundColor3 = theme.Foreground
	base.BackgroundTransparency = (cfg and cfg.baseAlpha) or 0.7
	base.BorderSizePixel = 0
	base.Size = UDim2.new(1,0,0,1)
	base.Position = UDim2.fromOffset(0, 0)
	base.Parent = holder

	local glow = Instance.new("Frame")
	glow.Name = "Glow"
	glow.BackgroundColor3 = theme.Foreground
	glow.BackgroundTransparency = (cfg and cfg.glowAlpha) or 0.35
	glow.BorderSizePixel = 0
	glow.Size = UDim2.fromOffset((cfg and cfg.glowWidth) or 160, 2)
	glow.Parent = holder

	local speed = (cfg and cfg.speed) or 140
	local running = true

	local function align()
		holder.Position = UDim2.fromOffset(0, titleBar.AbsoluteSize.Y)
	end
	align()
	local c1 = titleBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(align)

	task.spawn(function()
		local last = os.clock()
		local x = -glow.AbsoluteSize.X - 24
		while running and holder.Parent do
			local now = os.clock(); local dt = now - last; last = now
			x = x + speed * dt
			local width = holder.AbsoluteSize.X
			if x > width + 24 then x = -glow.AbsoluteSize.X - 24 end
			glow.Position = UDim2.fromOffset(math.floor(x+0.5), 0)
			Run.Heartbeat:Wait()
		end
	end)

	return {
		Destroy = function() running = false; if c1 then c1:Disconnect() end; if holder then holder:Destroy() end end
	}
end

return Fx