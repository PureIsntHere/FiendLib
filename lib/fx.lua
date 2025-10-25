-- Fiend/lib/fx.lua
-- Retro-futurist FX: corner brackets (old style), pulse line, continuous scanlines, top sweep, subtle grid.

local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Util = require(script.Parent.util)

local FX = {}

----------------------------------------------------------------------
-- PULSE (old feel): soft, slow sinusoidal pulse on a UIStroke.
----------------------------------------------------------------------
function FX.PulseStroke(stroke: UIStroke, theme)
	if not stroke then return { Destroy = function() end } end
	local baseT = math.clamp((theme and theme.PulseBase or 0.45), 0, 1)
	local amp   = math.clamp((theme and theme.PulseAmp  or 0.35), 0, 1)
	local freq  = (theme and theme.PulseHz) or 1.6

	local alive, t = true, 0
	local conn = RunService.RenderStepped:Connect(function(dt)
		if not alive or not stroke.Parent then return end
		t += dt * freq * math.pi * 2
		local s = (math.sin(t) + 1) * 0.5
		stroke.Transparency = baseT + amp * s
	end)

	return {
		Destroy = function()
			alive = false
			if conn then conn:Disconnect() end
			if stroke then stroke.Transparency = baseT end
		end,
	}
end

----------------------------------------------------------------------
-- CORNER BRACKETS (old look): crisp “L” corners that meet perfectly.
----------------------------------------------------------------------
function FX.AddCornerBrackets(frame: Frame, theme)
	if not frame then return { Destroy = function() end } end

	local t        = math.max(1, (theme and theme.LineThickness) or 1)
	local rounding = (theme and theme.Rounding) or 0
	local color    = (theme and theme.Border) or Color3.fromRGB(96,98,104)

	-- Draw just inside the shell stroke; overlap by 2px so seams never show.
	local inset      = t
	local joinFudge  = 2
	local armBase    = math.max(10, rounding > 0 and math.floor(rounding * 0.9) or 10)

	local group = Instance.new("Folder")
	group.Name = "CornerBrackets"
	group.Parent = frame

	local parts = {}
	local function clear()
		for _,p in ipairs(parts) do p:Destroy() end
		table.clear(parts)
	end

	local function corner(ax, ay)
		local arm = armBase
		local g = Instance.new("Frame")
		g.BackgroundTransparency = 1
		g.AnchorPoint = Vector2.new(ax, ay)
		g.Position = UDim2.new(ax, (ax==1) and -inset or inset, ay, (ay==1) and -inset or inset)
		g.Size = UDim2.fromOffset(arm, arm)
		g.ZIndex = (frame.ZIndex or 1) + 2
		g.Parent = group

		local h = Instance.new("Frame")
		h.Name = "H"
		h.BackgroundColor3 = color
		h.BorderSizePixel = 0
		h.Size = UDim2.new(0, arm + joinFudge, 0, t)
		h.Position = UDim2.new(0, (ax==1) and -arm - joinFudge or 0,
			(ay==1) and 1 or 0, (ay==1) and -t or 0)
		h.Parent = g

		local v = Instance.new("Frame")
		v.Name = "V"
		v.BackgroundColor3 = color
		v.BorderSizePixel = 0
		v.Size = UDim2.new(0, t, 0, arm + joinFudge)
		v.Position = UDim2.new((ax==1) and 1 or 0, (ax==1) and -t or 0,
			0, (ay==1) and -arm - joinFudge or 0)
		v.Parent = g

		table.insert(parts, g)
	end

	local function draw()
		clear()
		corner(0,0); corner(1,0); corner(0,1); corner(1,1)
	end

	draw()
	local c = frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(draw)

	return {
		Destroy = function()
			if c then c:Disconnect() end
			if group then group:Destroy() end
		end,
	}
end

----------------------------------------------------------------------
-- SCANLINES (vertical scanline effect)
----------------------------------------------------------------------
function FX.AttachScanlines(parent: GuiObject, theme, cfg)
	if not parent then return { Destroy = function() end } end
	cfg = cfg or {}
	
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
	bar.BackgroundColor3 = theme.Foreground or Color3.fromRGB(230, 230, 232)
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
			TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
				Position = UDim2.new(0,0,0,endY)
			}):Play()
			
			task.wait(duration + 0.02)
		end
	end)
	
	return { 
		Destroy = function() 
			running = false
			if overlay then overlay:Destroy() end 
		end 
	}
end

----------------------------------------------------------------------
-- TOP SWEEP (single bar, wrap-around, scaling-aware, pixel-snapped)
----------------------------------------------------------------------
function FX.AttachTopSweep(parent: GuiObject, titleBar: GuiObject?, theme, cfg)
	if not parent then return { Destroy = function() end } end
	cfg = cfg or {}

	-- Remove an older instance if one exists (prevents accidental doubles)
	local old = parent:FindFirstChild("TopSweepHolder")
	if old then old:Destroy() end

	local color     = (theme and theme.Accent) or Color3.fromRGB(220,220,224)
	local thickness = math.max(1, tonumber(cfg.thickness) or 2)
	local speed     = tonumber(cfg.speed)  or 180       -- px/sec along the X axis
	local gap       = tonumber(cfg.gap)    or 24        -- virtual gap before the bar re-enters
	local lengthPx  = tonumber(cfg.length) or 120       -- default bar length
	local pixelSnap = (cfg.pixelSnap ~= false)

	local holder = Instance.new("Frame")
	holder.Name = "TopSweepHolder"
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel = 0
	holder.ClipsDescendants = true
	holder.ZIndex = (parent.ZIndex or 1) + 2
	holder.Parent = parent

	-- align along the bottom of titlebar (or parent's top if no titlebar)
	local function alignHolder()
		local ref = titleBar or parent
		if not (ref and ref.Parent) then return end
		local w  = ref.AbsoluteSize.X
		local x0 = ref.AbsolutePosition.X - parent.AbsolutePosition.X
		local y0 = (ref == titleBar)
			and (ref.AbsolutePosition.Y - parent.AbsolutePosition.Y + ref.AbsoluteSize.Y - thickness)
			or 0
		holder.Position = UDim2.new(0, x0, 0, y0)
		holder.Size     = UDim2.new(0, w, 0, thickness)
	end
	alignHolder()

	local bar = Instance.new("Frame")
	bar.Name = "Sweep"
	bar.BackgroundColor3 = color
	bar.BorderSizePixel = 0
	bar.BackgroundTransparency = 0
	bar.Size = UDim2.new(0, lengthPx, 1, 0)
	bar.Parent = holder

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(color)
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.00, 1.0),
		NumberSequenceKeypoint.new(0.08, 0.0),
		NumberSequenceKeypoint.new(0.92, 0.0),
		NumberSequenceKeypoint.new(1.00, 1.0),
	})
	grad.Parent = bar

	local alive = true
	local t0 = os.clock()

	local function step()
		if not alive or not bar.Parent then return end
		local W = math.max(0, holder.AbsoluteSize.X)
		local L = math.clamp(lengthPx, 24, math.max(24, math.floor(W * 0.35)))
		if pixelSnap then L = math.floor(L + 0.5) end
		if bar.Size.X.Offset ~= L then
			bar.Size = UDim2.new(0, L, 1, 0)
		end

		local t  = os.clock() - t0
		local C  = W + gap + L
		if C <= 0 then return end
		local x  = (t * speed) % C - L
		if pixelSnap then x = math.floor(x + 0.5) end
		bar.Position = UDim2.new(0, x, 0, 0)
	end

	local connRS = RunService.RenderStepped:Connect(step)

	local c1 = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(alignHolder)
	local c2 = titleBar and titleBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(alignHolder)
	local c3 = parent:GetPropertyChangedSignal("AbsolutePosition"):Connect(alignHolder)
	local c4 = titleBar and titleBar:GetPropertyChangedSignal("AbsolutePosition"):Connect(alignHolder)

	return {
		Destroy = function()
			alive = false
			if connRS then connRS:Disconnect() end
			if c1 then c1:Disconnect() end
			if c2 then c2:Disconnect() end
			if c3 then c3:Disconnect() end
			if c4 then c4:Disconnect() end
			if holder then holder:Destroy() end
		end,
	}
end

----------------------------------------------------------------------
-- Subtle GRID
----------------------------------------------------------------------
function FX.AttachGrid(parent: GuiObject, theme, opts)
	if not parent then return { Destroy = function() end } end
	opts = opts or {}
	local gap   = tonumber(opts.gap)   or 16
	local alpha = math.clamp(tonumber(opts.alpha) or 0.06, 0, 1)
	local color = (theme and theme.Border) or Color3.fromRGB(96,98,104)

	local holder = Instance.new("Frame")
	holder.Name = "RetroGrid"
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromScale(1,1)
	holder.ZIndex = (parent.ZIndex or 1) + 1
	holder.Parent = parent

	local verts = Instance.new("Frame"); verts.BackgroundTransparency = 1; verts.Size = UDim2.fromScale(1,1); verts.Parent = holder
	local horiz = Instance.new("Frame"); horiz.BackgroundTransparency = 1; horiz.Size = UDim2.fromScale(1,1); horiz.Parent = holder

	local vlines, hlines = {}, {}
	local function rebuild()
		for _,l in ipairs(vlines) do l:Destroy() end; vlines = {}
		for _,l in ipairs(hlines) do l:Destroy() end; hlines = {}

		local w,h = parent.AbsoluteSize.X, parent.AbsoluteSize.Y
		if w <= 0 or h <= 0 then return end
		for x=0,w,gap do
			local ln = Instance.new("Frame")
			ln.BackgroundColor3 = color; ln.BackgroundTransparency = 1 - alpha
			ln.BorderSizePixel = 0; ln.Size = UDim2.new(0,1,1,0); ln.Position = UDim2.new(0,x,0,0)
			ln.Parent = verts; table.insert(vlines, ln)
		end
		for y=0,h,gap do
			local ln = Instance.new("Frame")
			ln.BackgroundColor3 = color; ln.BackgroundTransparency = 1 - alpha
			ln.BorderSizePixel = 0; ln.Size = UDim2.new(1,0,0,1); ln.Position = UDim2.new(0,0,0,y)
			ln.Parent = horiz; table.insert(hlines, ln)
		end
	end
	rebuild()
	local c = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(rebuild)
	return { Destroy = function() if c then c:Disconnect() end; if holder then holder:Destroy() end end }
end

return FX
