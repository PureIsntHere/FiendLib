--[[
    Fiend UI Library - Executor Version (Built)
    Auto-generated single-file version for executor usage

    Usage:
    local Fiend = loadstring(game:HttpGet('https://raw.githubusercontent.com/PureIsntHere/FiendLib/ExecutorVersion/Fiend_Built.lua'))()

    Then use it:
    local window = Fiend:CreateWindow({Title = 'My Script', Theme = 'Tokyo Night'})
]]

local repo = 'https://raw.githubusercontent.com/PureIsntHere/FiendLib/main/'

-- Module storage and cache
local Modules = {}
local Cache = {}

-- Create require function
local function createRequire()
    return function(path)
        if Cache[path] then return Cache[path] end
        local moduleCode = Modules[path]
        if not moduleCode then
            moduleCode = Modules[path:gsub('%.lua$', '')]
        end
        if not moduleCode then
            error('Module not found: ' .. tostring(path))
        end
        local env = getfenv(0)
        env.require = createRequire()
        env.game = game
        local fn, err = loadstring(moduleCode)
        if not fn then error('Failed to parse: ' .. tostring(err)) end
        setfenv(fn, env)
        local success, result = pcall(fn)
        if not success then error('Failed to execute: ' .. tostring(result)) end
        Cache[path] = result
        return result
    end
end

print('🔨 Loading Fiend UI Library...')

-- Module: lib/util.lua
Modules['lib/util.lua'] = [=[
-- Fiend/lib/util.lua
-- Core utility functions used across FiendLib.

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Util = {}

--[[------------------------------------------------------------
	Instance Helpers
------------------------------------------------------------]]
function Util.Create(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

function Util.CreateUIStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

function Util.CreateUICorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or UDim.new(0, 8)
	c.Parent = parent
	return c
end

function Util.CreateUIPadding(parent, pad)
	local p = Instance.new("UIPadding")
	p.PaddingTop = pad or UDim.new(0, 8)
	p.PaddingBottom = p.PaddingTop
	p.PaddingLeft = p.PaddingTop
	p.PaddingRight = p.PaddingTop
	p.Parent = parent
	return p
end

function Util:Roundify(obj: Instance, radius: UDim?)
	-- default to 8px if not provided
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or UDim.new(0, 8)
	corner.Parent = obj
	return corner
end

-- === Compatibility shims expected by older components/behaviors ===

-- Colon-call wrapper for a border stroke: Util:Stroke(parent, color, thickness)
function Util:Stroke(parent: Instance, color: Color3?, thickness: number?)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(42, 48, 60)
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

-- Colon-call wrapper for rounded corners: Util:Roundify(parent, radiusUDim)
function Util:Roundify(parent: Instance, radius: UDim?)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or UDim.new(0, 8)
	c.Parent = parent
	return c
end

-- Colon-call wrapper for padding: Util:Pad(parent, padUDim)
function Util:Pad(parent: Instance, pad: UDim?)
	local p = Instance.new("UIPadding")
	local v = pad or UDim.new(0, 8)
	p.PaddingTop = v
	p.PaddingBottom = v
	p.PaddingLeft = v
	p.PaddingRight = v
	p.Parent = parent
	return p
end

--[[------------------------------------------------------------
	Tween Helpers
------------------------------------------------------------]]
function Util.Tween(obj, infoOrProps, propsOrDuration, style, dir)
	-- Usage 1: Util.Tween(obj, TweenInfo.new(...), {PropertyTable})
	if typeof(infoOrProps) == "TweenInfo" then
		local info = infoOrProps
		local props = propsOrDuration or {}
		local t = TweenService:Create(obj, info, props)
		t:Play()
		return t
	end
	-- Usage 2: Util.Tween(obj, {PropertyTable}, duration?, style?, dir?)
	local props = infoOrProps or {}
	local duration = propsOrDuration or 0.25
	local ti = TweenInfo.new(duration, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, ti, props)
	t:Play()
	return t
end

function Util.TweenShort(obj, props)
	return Util.Tween(obj, props, 0.15)
end

function Util.TweenMedium(obj, props)
	return Util.Tween(obj, props, 0.25)
end

function Util.TweenLong(obj, props)
	return Util.Tween(obj, props, 0.35)
end

--[[------------------------------------------------------------
	GUI Protection / Hierarchy
------------------------------------------------------------]]
function Util.ProtectGui(gui)
	local root = gethui and gethui()
		or (syn and syn.protect_gui and game:GetService("CoreGui"))
		or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	gui.Parent = root
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		elseif protectgui then
			protectgui(gui)
		end
	end)
	return gui
end

function Util.RandomString(len)
	local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local out = {}
	for i = 1, len or 8 do
		table.insert(out, string.sub(charset, math.random(1, #charset), math.random(1, #charset)))
	end
	return table.concat(out)
end

--[[------------------------------------------------------------
	Color / Math
------------------------------------------------------------]]
function Util.ColorToHex(color)
	return string.format("#%02X%02X%02X",
		math.floor(color.R * 255),
		math.floor(color.G * 255),
		math.floor(color.B * 255))
end

function Util.HexToColor(hex)
	hex = hex:gsub("#","")
	return Color3.fromRGB(
		tonumber(hex:sub(1,2),16),
		tonumber(hex:sub(3,4),16),
		tonumber(hex:sub(5,6),16)
	)
end

function Util.Clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

--[[------------------------------------------------------------
	JSON & Safe Execution
------------------------------------------------------------]]
function Util.EncodeJSON(tbl)
	return HttpService:JSONEncode(tbl)
end

function Util.DecodeJSON(str)
	local ok, res = pcall(function() return HttpService:JSONDecode(str) end)
	return ok and res or nil
end

function Util.SafeCall(fn, ...)
	if not fn then return end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[Fiend/Util] Callback Error:", err)
	end
end

--[[------------------------------------------------------------
	Misc
------------------------------------------------------------]]
function Util.FormatNumber(n)
	local left, num, right = string.match(tostring(n), "^([^%d]*%d)(%d*)(.-)$")
	return left .. (num:reverse():gsub("(%d%d%d)","%1,"):reverse()) .. right
end

function Util.WaitForChildOfClass(parent, class)
	for _, c in ipairs(parent:GetChildren()) do
		if c:IsA(class) then return c end
	end
	local inst
	parent.ChildAdded:Wait(function(ch)
		if ch:IsA(class) then inst = ch end
	end)
	return inst
end

return Util

]=]
Modules['lib/util'] = Modules['lib/util.lua']
Modules['util'] = Modules['lib/util.lua']

-- Module: lib/base_element.lua
Modules['lib/base_element.lua'] = [[
-- Fiend/lib/base_element.lua
-- Shared base class for all UI elements.
-- Provides unified runtime property control and callbacks.

local BaseElement = {}
BaseElement.__index = BaseElement

export type Element = typeof(setmetatable({}, BaseElement)) & {
	Name: string?,
	Text: string?,
	Value: any?,
	Callback: ((any) -> ())?,
	Visible: boolean?,
	Tooltip: string?,
	Root: Instance?,
	_label: Instance?,
	_theme: table?,
}

-- Constructor
function BaseElement.new(opts)
	local self = setmetatable({}, BaseElement)
	self.Name = opts.Name or "Element"
	self.Text = opts.Text or self.Name
	self.Value = opts.Default
	self.Callback = opts.Callback
	self.Visible = true
	self.Tooltip = opts.Tooltip
	self.Root = opts.Root or nil
	self._label = opts.Label or nil
	self._theme = opts.Theme or {}
	
	-- Auto-register with Fiend if available
	if _G.FiendInstance and _G.FiendInstance._trackElement then
		_G.FiendInstance:_trackElement(self)
	end
	
	return self
end

-- Called by subclasses when the value changes
function BaseElement:_trigger(value)
	self.Value = value
	if typeof(self.Callback) == "function" then
		task.spawn(self.Callback, value)
	end
end

-- Change the displayed label text
function BaseElement:SetText(text)
	self.Text = text
	if self._label then
		self._label.Text = text
	end
end

-- Change callback function
function BaseElement:SetCallback(fn)
	self.Callback = fn
end

-- Set visibility of the element
function BaseElement:SetVisible(state)
	self.Visible = state
	if self.Root then
		self.Root.Visible = state
	end
end

-- Change internal value and (optionally) fire callback
function BaseElement:SetValue(value, fire)
	self.Value = value
	if fire ~= false then
		self:_trigger(value)
	end
end

-- Return current value
function BaseElement:GetValue()
	return self.Value
end

-- Set a tooltip (if supported by theme)
function BaseElement:SetTooltip(text)
	self.Tooltip = text
	if self.Root and self.Root:FindFirstChild("Tooltip") then
		self.Root.Tooltip.Text = text
	end
end

-- Apply theme overrides at runtime
function BaseElement:ApplyTheme(theme)
	self._theme = theme
	if self.Root and theme then
		if theme.Background then
			self.Root.BackgroundColor3 = theme.Background
		end
		if theme.TextColor then
			if self._label then
				self._label.TextColor3 = theme.TextColor
			end
		end
	end
end

-- Instant property update without animation
function BaseElement:UpdateProperty(property, value, animate)
	if not self.Root then return end
	
	if animate == false then
		-- Instant update
		self.Root[property] = value
	elseif animate == true then
		-- Animated update using default tween
		local Util = require(script.Parent.util)
		Util.Tween(self.Root, {[property] = value}, 0.15)
	else
		-- Default behavior - instant update
		self.Root[property] = value
	end
end

-- Update multiple properties at once
function BaseElement:UpdateProperties(properties, animate)
	if not self.Root then return end
	
	if animate == false then
		-- Instant update
		for property, value in pairs(properties) do
			self.Root[property] = value
		end
	elseif animate == true then
		-- Animated update using default tween
		local Util = require(script.Parent.util)
		Util.Tween(self.Root, properties, 0.15)
	else
		-- Default behavior - instant update
		for property, value in pairs(properties) do
			self.Root[property] = value
		end
	end
end

-- Refresh element appearance based on current theme
function BaseElement:RefreshTheme()
	-- Get current theme from library
	local currentTheme = self._theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		currentTheme = _G.FiendInstance.Theme
	end
	
	if not currentTheme then return end
	
	-- Update root element properties
	if self.Root then
		if currentTheme.Background then
			self.Root.BackgroundColor3 = currentTheme.Background
		end
		if currentTheme.TextColor then
			-- Only set TextColor3 on objects that support it (TextLabel, TextButton, etc.)
			if self.Root:IsA("GuiObject") and (self.Root:IsA("TextLabel") or self.Root:IsA("TextButton") or self.Root:IsA("TextBox")) then
				self.Root.TextColor3 = currentTheme.TextColor
			end
		end
		if currentTheme.Font then
			-- Only set Font on objects that support it (TextLabel, TextButton, etc.)
			if self.Root:IsA("GuiObject") and (self.Root:IsA("TextLabel") or self.Root:IsA("TextButton") or self.Root:IsA("TextBox")) then
				self.Root.Font = currentTheme.Font
			end
		end
		
		-- Update border if exists
		local stroke = self.Root:FindFirstChild("UIStroke")
		if stroke then
			if currentTheme.Border then
				stroke.Color = currentTheme.Border
			end
			if currentTheme.LineThickness then
				stroke.Thickness = currentTheme.LineThickness
			end
		end
		
		-- Update corner radius if exists
		local corner = self.Root:FindFirstChild("UICorner")
		if corner and currentTheme.Corner then
			corner.CornerRadius = currentTheme.Corner
		end
	end
	
	-- Update label if exists
	if self._label then
		if currentTheme.TextColor then
			self._label.TextColor3 = currentTheme.TextColor
		end
		if currentTheme.Font then
			self._label.Font = currentTheme.Font
		end
	end
	
	-- Update stored theme reference
	self._theme = currentTheme
end

-- Destroy element cleanly
function BaseElement:Destroy()
	if self.Root and self.Root.Destroy then
		self.Root:Destroy()
	end
	for k in pairs(self) do
		self[k] = nil
	end
	setmetatable(self, nil)
end

return BaseElement

]]
Modules['lib/base_element'] = Modules['lib/base_element.lua']
Modules['base_element'] = Modules['lib/base_element.lua']

-- Module: lib/theme.lua
Modules['lib/theme.lua'] = [[
-- Fiend/lib/theme.lua
-- RETRO_HUD: monochrome wireframe HUD, thin strokes, pill tabs.

local Theme = {
	-- Monochrome canvas
	Background      = Color3.fromRGB(8, 8, 10),
	Background2     = Color3.fromRGB(14, 14, 18),
	TextColor       = Color3.fromRGB(230, 230, 232),
	SubTextColor    = Color3.fromRGB(170, 174, 182),

	-- Lines and accents (wireframe look)
	Accent          = Color3.fromRGB(220, 220, 224),
	AccentDim       = Color3.fromRGB(170, 174, 182),
	Border          = Color3.fromRGB(96, 98, 104),

	Success         = Color3.fromRGB(200, 240, 210),
	Warning         = Color3.fromRGB(255, 200, 120),

	-- Geometry
	Rounding        = 6,
	Padding         = 6,
	LineThickness   = 1,

	-- Typography
	Font            = Enum.Font.Gotham,
	FontMono        = Enum.Font.Code,

	-- Tweens
	TweenShort      = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TweenMedium     = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TweenLong       = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	-- Retro FX toggles
	EnableScanlines = true,
	EnableTopSweep  = true,
	EnableBrackets  = true,
	EnableGridBG    = true,
}

function Theme:Apply(obj, variant)
	if not obj then return end
	if variant == "Label" then
		obj.BackgroundTransparency = 1
		obj.Font = self.Font
		obj.TextColor3 = self.TextColor
	elseif variant == "SubLabel" then
		obj.BackgroundTransparency = 1
		obj.Font = self.Font
		obj.TextColor3 = self.SubTextColor
	elseif variant == "Container" then
		obj.BackgroundColor3 = self.Background
		obj.BorderSizePixel = 0
	elseif variant == "Input" or variant == "Button" then
		obj.BackgroundColor3 = self.Background2
		obj.BorderSizePixel = 0
		obj.Font = self.Font
		obj.TextColor3 = self.TextColor
	end
end

-- Aliases used in components
Theme.Foreground = Theme.TextColor
Theme.Corner     = UDim.new(0, Theme.Rounding)
Theme.Pad        = UDim.new(0, Theme.Padding)

-- Tab styling hints (used by components/tab.lua)
Theme.Tab = {
	PillHeight = 22,
	Uppercase  = true,
	ActiveFill = Theme.Background,
	IdleFill   = Theme.Background2,
	IdleText   = Theme.SubTextColor,
	ActiveText = Theme.TextColor,
}

return Theme

]]
Modules['lib/theme'] = Modules['lib/theme.lua']
Modules['theme'] = Modules['lib/theme.lua']

-- Module: lib/tween.lua
Modules['lib/tween.lua'] = [[
local TweenService = game:GetService("TweenService")

local function t(obj : Instance, props : {[string]: any}, duration : number?, easing : Enum.EasingStyle?, dir : Enum.EasingDirection?)
	local info = TweenInfo.new(duration or 0.25, easing or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

return t

]]
Modules['lib/tween'] = Modules['lib/tween.lua']
Modules['tween'] = Modules['lib/tween.lua']

-- Module: lib/fx.lua
Modules['lib/fx.lua'] = [[
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
	local baseT = math.clamp((theme and theme.FX and theme.FX.PulseBase) or 0.45, 0, 1)
	local amp   = math.clamp((theme and theme.FX and theme.FX.PulseAmp) or 0.35, 0, 1)
	local freq  = (theme and theme.FX and theme.FX.PulseHz) or 1.6

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

	local t        = math.max(1, (theme and theme.FX and theme.FX.CornerBracketThickness) or (theme and theme.LineThickness) or 1)
	local rounding = (theme and theme.Rounding) or 0
	local color    = (theme and theme.FX and theme.FX.CornerBrackets) or (theme and theme.Border) or Color3.fromRGB(96,98,104)

	-- Draw just inside the shell stroke; overlap by 2px so seams never show.
	local inset      = t
	local joinFudge  = 1  -- Reduced from 2 to 1
	local armBase    = math.max(8, rounding > 0 and math.floor(rounding * 0.7) or 8)  -- Reduced from 10 to 8, and from 0.9 to 0.7

	local group = Instance.new("Folder")
	group.Name = "CornerBrackets"
	group.Parent = frame

	local parts = {}
	local function clear()
		for _,p in ipairs(parts) do p:Destroy() end
		table.clear(parts)
	end

	local function createCornerBracket(cornerX, cornerY)
		local arm = armBase
		local container = Instance.new("Frame")
		container.BackgroundTransparency = 1
		container.Size = UDim2.fromOffset(arm, arm)
		container.ZIndex = (frame.ZIndex or 1) + 2
		container.Parent = group
		
		-- Position the container at the corner
		if cornerX == 0 and cornerY == 0 then
			-- Top-left corner
			container.Position = UDim2.new(0, inset, 0, inset)
			container.AnchorPoint = Vector2.new(0, 0)
		elseif cornerX == 1 and cornerY == 0 then
			-- Top-right corner
			container.Position = UDim2.new(1, -inset, 0, inset)
			container.AnchorPoint = Vector2.new(1, 0)
		elseif cornerX == 0 and cornerY == 1 then
			-- Bottom-left corner
			container.Position = UDim2.new(0, inset, 1, -inset)
			container.AnchorPoint = Vector2.new(0, 1)
		elseif cornerX == 1 and cornerY == 1 then
			-- Bottom-right corner
			container.Position = UDim2.new(1, -inset, 1, -inset)
			container.AnchorPoint = Vector2.new(1, 1)
		end

		-- Create horizontal line
		local horizontal = Instance.new("Frame")
		horizontal.Name = "Horizontal"
		horizontal.BackgroundColor3 = color
		horizontal.BorderSizePixel = 0
		horizontal.Size = UDim2.new(0, arm + joinFudge, 0, t)
		horizontal.ZIndex = container.ZIndex + 1
		horizontal.Parent = container
		
		-- Position horizontal line
		if cornerY == 0 then
			-- Top corners - horizontal line at top
			horizontal.Position = UDim2.new(0, 0, 0, 0)
		else
			-- Bottom corners - horizontal line at bottom
			horizontal.Position = UDim2.new(0, 0, 1, -t)
		end

		-- Create vertical line
		local vertical = Instance.new("Frame")
		vertical.Name = "Vertical"
		vertical.BackgroundColor3 = color
		vertical.BorderSizePixel = 0
		vertical.Size = UDim2.new(0, t, 0, arm + joinFudge)
		vertical.ZIndex = container.ZIndex + 1
		vertical.Parent = container
		
		-- Position vertical line
		if cornerX == 0 then
			-- Left corners - vertical line at left
			vertical.Position = UDim2.new(0, 0, 0, 0)
		else
			-- Right corners - vertical line at right
			vertical.Position = UDim2.new(1, -t, 0, 0)
		end

		table.insert(parts, container)
	end

	local function draw()
		clear()
		createCornerBracket(0, 0) -- Top-left
		createCornerBracket(1, 0) -- Top-right
		createCornerBracket(0, 1) -- Bottom-left
		createCornerBracket(1, 1) -- Bottom-right
	end

	draw()
	local connection = frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(draw)

	return {
		Destroy = function()
			if connection then connection:Disconnect() end
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
	bar.BackgroundColor3 = (theme and theme.FX and theme.FX.ScanlineColor) or (theme and theme.Foreground) or Color3.fromRGB(230, 230, 232)
	bar.BackgroundTransparency = (theme and theme.FX and theme.FX.ScanlineTransparency) or 0.85
	bar.BorderSizePixel = 0
	bar.Parent = overlay

	local speed = (cfg and cfg.speed) or (theme and theme.FX and theme.FX.ScanlineSpeed) or 110
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

	local color     = (theme and theme.FX and theme.FX.TopSweepColor) or (theme and theme.Accent) or Color3.fromRGB(220,220,224)
	local thickness = math.max(1, tonumber(cfg.thickness) or (theme and theme.FX and theme.FX.TopSweepThickness) or 2)
	local speed     = tonumber(cfg.speed) or (theme and theme.FX and theme.FX.TopSweepSpeed) or 180
	local gap       = tonumber(cfg.gap) or (theme and theme.FX and theme.FX.TopSweepGap) or 24
	local lengthPx  = tonumber(cfg.length) or (theme and theme.FX and theme.FX.TopSweepLength) or 120
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
	local gap   = tonumber(opts.gap) or (theme and theme.FX and theme.FX.GridGap) or 16
	local alpha = math.clamp(tonumber(opts.alpha) or (theme and theme.FX and theme.FX.GridAlpha) or 0.06, 0, 1)
	local color = (theme and theme.FX and theme.FX.GridColor) or (theme and theme.Border) or Color3.fromRGB(96,98,104)

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

]]
Modules['lib/fx'] = Modules['lib/fx.lua']
Modules['fx'] = Modules['lib/fx.lua']

-- Module: lib/behaviors.lua
Modules['lib/behaviors.lua'] = [[
local Util = require(script.Parent.util)

local Behaviors = {}

function Behaviors.MakeDraggable(handle, targetFrame, cutoff)
	-- Enhanced dragging function inspired by LinoriaLib
	local UIS = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local Mouse = LocalPlayer:GetMouse()
	
	-- Make the handle active for input
	handle.Active = true
	
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Check if click is within cutoff area (for title bars, etc.)
			local objPos = Vector2.new(
				Mouse.X - handle.AbsolutePosition.X,
				Mouse.Y - handle.AbsolutePosition.Y
			)
			
			-- If cutoff is specified and click is below it, don't drag
			if cutoff and objPos.Y > cutoff then
				return
			end
			
			-- Store the initial mouse offset from the frame's position
			local initialMousePos = Vector2.new(Mouse.X, Mouse.Y)
			local initialFramePos = targetFrame.Position
			
			-- Start dragging loop
			local dragConnection
			dragConnection = RunService.RenderStepped:Connect(function()
				if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
					dragConnection:Disconnect()
					return
				end
				
				-- Calculate the mouse movement delta
				local currentMousePos = Vector2.new(Mouse.X, Mouse.Y)
				local mouseDelta = currentMousePos - initialMousePos
				
				-- Apply the delta to the initial frame position
				local newPosition = UDim2.new(
					initialFramePos.X.Scale,
					initialFramePos.X.Offset + mouseDelta.X,
					initialFramePos.Y.Scale,
					initialFramePos.Y.Offset + mouseDelta.Y
				)
				
				-- Apply the new position
				targetFrame.Position = newPosition
			end)
		end
	end)
end

function Behaviors.AddResizeGrip(shell, theme, minSize, maxSize)
	local UIS = game:GetService("UserInputService")

	local grip = Instance.new("Frame")
	grip.Name = "ResizeGrip"
	grip.Size = UDim2.fromOffset(16,16)
	grip.AnchorPoint = Vector2.new(1,1)
	grip.Position = UDim2.new(1,-4,1,-4)
	grip.BackgroundColor3 = theme.Background
	grip.BackgroundTransparency = 0.2
	grip.ZIndex = (shell.ZIndex or 1) + 4
	grip.Parent = shell
	Util:Roundify(grip, UDim.new(0,4))
	Util:Stroke(grip, theme.Foreground, 1, 0.6)

	for i=0,2 do
		local line = Instance.new("Frame")
		line.BackgroundColor3 = theme.Foreground
		line.BorderSizePixel = 0
		line.AnchorPoint = Vector2.new(1,1)
		line.Size = UDim2.fromOffset(10 - (i*3), 1)
		line.Position = UDim2.new(1,-2,1,-(2 + i*4))
		line.Rotation = 45
		line.ZIndex = (grip.ZIndex or 1) + 1
		line.Parent = grip
	end

	local resizing, startMouse, startSize = false, nil, nil
	grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			startMouse = input.Position
			startSize  = shell.AbsoluteSize
			local c; c = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
					if c then c:Disconnect() end
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if not resizing or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local d = input.Position - startMouse
		local nx = math.clamp(startSize.X + d.X, minSize.X, maxSize.X)
		local ny = math.clamp(startSize.Y + d.Y, minSize.Y, maxSize.Y)
		shell.Size = UDim2.fromOffset(nx, ny)
	end)

	return grip
end

return Behaviors

]]
Modules['lib/behaviors'] = Modules['lib/behaviors.lua']
Modules['behaviors'] = Modules['lib/behaviors.lua']

-- Module: lib/binds.lua
Modules['lib/binds.lua'] = [[
-- Fiend/lib/binds.lua
-- Legacy compatibility layer for the old binds system
-- This now delegates to the new KeySystem for consistency

local KeySystem = require(script.Parent.keysystem)

local Binds = {}
Binds.__index = Binds

export type BindType = "Toggle" | "Hold" | "Press"

function Binds.new()
	local self = setmetatable({}, Binds)
	
	-- Create a new keysystem instance for this binds instance
	self._keySystem = KeySystem.new({
		Theme = nil,
		GlobalKeyCapture = true,
		DebugMode = false
	})
	
	return self
end

-- Register or overwrite a bind
function Binds:Register(name:string, keyCode:Enum.KeyCode, bindType:BindType?, callback:(...any)->()?, id:string?)
	if not name or not keyCode then
		error("[Fiend/Binds] Missing bind name or keyCode")
	end
	
	-- Convert legacy bind types to new format
	local newType = bindType
	if bindType == "Press" then
		newType = "Press"
	elseif bindType == "Hold" then
		newType = "Hold"
	else
		newType = "Toggle"
	end
	
	self._keySystem:RegisterBind(name, keyCode, newType, callback, id)
end

function Binds:Unregister(name:string)
	self._keySystem:UnregisterBind(name)
end

function Binds:Get(name:string)
	return self._keySystem:GetBind(name)
end

function Binds:GetState(name:string):boolean
	return self._keySystem:GetBindState(name)
end

function Binds:SetState(name:string, value:boolean)
	-- Legacy method - not directly supported in new system
	warn("[Fiend/Binds] SetState is deprecated. Use the new KeySystem API.")
end

-- === Added for components/keybind.lua compatibility ===
function Binds:SetKey(name:string, keyCode:Enum.KeyCode)
	self._keySystem:SetBindKey(name, keyCode)
end

function Binds:SetMode(name:string, mode:BindType)
	-- Convert legacy mode names
	local newMode = mode
	if mode == "Always" then
		newMode = "Always"
	elseif mode == "Hold" then
		newMode = "Hold"
	elseif mode == "Press" then
		newMode = "Press"
	else
		newMode = "Toggle"
	end
	
	self._keySystem:SetBindType(name, newMode)
end
-- ================================================

function Binds:GetAll()
	return self._keySystem:GetAllBinds()
end

function Binds:Destroy()
	self._keySystem:Destroy()
end

return Binds.new()

]]
Modules['lib/binds'] = Modules['lib/binds.lua']
Modules['binds'] = Modules['lib/binds.lua']

-- Module: lib/config.lua
Modules['lib/config.lua'] = [[
-- Fiend/lib/config.lua
-- File-based config manager for Fiend UI Library
-- Supports both Studio (using DataStoreService) and Executor (using file functions)

local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

local Config = {}
Config.__index = Config

-- Check if we're in an executor environment
local function isExecutor()
    return typeof(readfile) == "function" and typeof(writefile) == "function"
end

-- Check if we're in Studio
local function isStudio()
    return game:GetService("RunService"):IsStudio()
end

function Config.new(options)
    local self = setmetatable({}, Config)
    
    -- Configuration options
    local opts = options or {}
    self._configFolder = opts.folder or "FiendConfigs"
    self._configFile = opts.filename or "settings.json"
    self._configName = opts.name or "FiendConfig"
    
    -- Build full path
    self._fullPath = self._configFolder .. "/" .. self._configFile
    
    -- Data storage
    self._data = {}
    self._isExecutor = isExecutor()
    self._isStudio = isStudio()
    
    -- Auto-load existing config
    self:Load()
    
    return self
end

-- Set a config value
function Config:Set(key, value)
    self._data[key] = value
end

-- Get a config value
function Config:Get(key, default)
    local val = self._data[key]
    if val == nil then
        return default
    end
    return val
end

-- Remove a key
function Config:Remove(key)
    self._data[key] = nil
end

-- Return all config data
function Config:GetAll()
    return self._data
end

-- Serialize to JSON
function Config:Serialize(pretty)
    local success, encoded = pcall(function()
        if pretty then
            return HttpService:JSONEncode(self._data, Enum.HttpContentType.ApplicationJson)
        else
            return HttpService:JSONEncode(self._data)
        end
    end)
    return success and encoded or "{}"
end

-- Deserialize from JSON
function Config:Deserialize(json)
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    if success and type(decoded) == "table" then
        self._data = decoded
        return true
    end
    return false
end

-- Save config to file
function Config:Save()
    if self._isExecutor then
        return self:_saveToFile()
    elseif self._isStudio then
        return self:_saveToDataStore()
    else
        warn("[Fiend/Config] No save method available in this environment")
        return false
    end
end

-- Load config from file
function Config:Load()
    if self._isExecutor then
        return self:_loadFromFile()
    elseif self._isStudio then
        return self:_loadFromDataStore()
    else
        warn("[Fiend/Config] No load method available in this environment")
        return false
    end
end

-- Executor file operations
function Config:_saveToFile()
    if not self._isExecutor then
        return false
    end
    
    local success, result = pcall(function()
        local json = self:Serialize(true) -- Pretty print for readability
        
        -- Create folder if it doesn't exist
        if not isfile(self._configFolder) then
            writefile(self._configFolder .. "/.gitkeep", "") -- Create folder
        end
        
        writefile(self._fullPath, json)
        return true
    end)
    
    if success then
        print("[Fiend/Config] Saved config to:", self._fullPath)
        return true
    else
        warn("[Fiend/Config] Failed to save config:", result)
        return false
    end
end

function Config:_loadFromFile()
    if not self._isExecutor then
        return false
    end
    
    local success, result = pcall(function()
        if not isfile(self._fullPath) then
            print("[Fiend/Config] Config file not found:", self._fullPath)
            return false
        end
        
        local content = readfile(self._fullPath)
        if content then
            return self:Deserialize(content)
        end
        return false
    end)
    
    if success and result then
        print("[Fiend/Config] Loaded config from:", self._fullPath)
        return true
    else
        if result then
            warn("[Fiend/Config] Failed to load config:", result)
        end
        return false
    end
end

-- Studio DataStore operations
function Config:_saveToDataStore()
    if not self._isStudio then
        return false
    end
    
    local success, result = pcall(function()
        local dataStore = DataStoreService:GetDataStore("FiendConfig_" .. self._configName)
        local json = self:Serialize()
        dataStore:SetAsync("config", json)
        return true
    end)
    
    if success then
        print("[Fiend/Config] Saved config to DataStore:", self._configName)
        return true
    else
        warn("[Fiend/Config] Failed to save to DataStore:", result)
        return false
    end
end

function Config:_loadFromDataStore()
    if not self._isStudio then
        return false
    end
    
    local success, result = pcall(function()
        local dataStore = DataStoreService:GetDataStore("FiendConfig_" .. self._configName)
        local json = dataStore:GetAsync("config")
        if json then
            return self:Deserialize(json)
        end
        return false
    end)
    
    if success and result then
        print("[Fiend/Config] Loaded config from DataStore:", self._configName)
        return true
    else
        if result then
            warn("[Fiend/Config] Failed to load from DataStore:", result)
        end
        return false
    end
end

-- Auto-save functionality
function Config:EnableAutoSave(interval)
    if self._autoSaveConnection then
        self._autoSaveConnection:Disconnect()
    end
    
    if interval and interval > 0 then
        self._autoSaveConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if self._needsSave then
                self:Save()
                self._needsSave = false
            end
        end)
        
        -- Mark for save when values change
        local originalSet = self.Set
        self.Set = function(self, key, value)
            originalSet(self, key, value)
            self._needsSave = true
        end
    end
end

function Config:DisableAutoSave()
    if self._autoSaveConnection then
        self._autoSaveConnection:Disconnect()
        self._autoSaveConnection = nil
    end
end

-- Backup and restore
function Config:CreateBackup()
    if self._isExecutor then
        local backupPath = self._configFolder .. "/" .. self._configFile .. ".backup"
        local json = self:Serialize(true)
        writefile(backupPath, json)
        print("[Fiend/Config] Created backup:", backupPath)
        return true
    end
    return false
end

function Config:RestoreFromBackup()
    if self._isExecutor then
        local backupPath = self._configFolder .. "/" .. self._configFile .. ".backup"
        if isfile(backupPath) then
            local content = readfile(backupPath)
            if content then
                self:Deserialize(content)
                self:Save()
                print("[Fiend/Config] Restored from backup:", backupPath)
                return true
            end
        end
    end
    return false
end

-- Clear all config data
function Config:Clear()
    table.clear(self._data)
end

-- Get config info
function Config:GetInfo()
    return {
        folder = self._configFolder,
        filename = self._configFile,
        fullPath = self._fullPath,
        isExecutor = self._isExecutor,
        isStudio = self._isStudio,
        dataCount = #self._data
    }
end

-- Debug print
function Config:Print()
    print("[Fiend/Config] Current data:")
    for k, v in pairs(self._data) do
        print("   ", k, "=", v)
    end
    print("[Fiend/Config] Info:", self:GetInfo())
end

-- Legacy clipboard methods (for backward compatibility)
function Config:CopyToClipboard()
    if typeof(setclipboard) == "function" then
        local json = self:Serialize()
        setclipboard(json)
        return true
    end
    return false
end

function Config:LoadFromClipboard()
    if typeof(getclipboard) == "function" then
        local raw = getclipboard()
        if raw then
            return self:Deserialize(raw)
        end
    end
    return false
end

return Config
]]
Modules['lib/config'] = Modules['lib/config.lua']
Modules['config'] = Modules['lib/config.lua']

-- Module: lib/safety.lua
Modules['lib/safety.lua'] = [[
local Players  = game:GetService("Players")
local CoreGui  = game:GetService("CoreGui")
local LocalPlr = Players.LocalPlayer

local Safety = {}

-- ========== utils ==========
local function randSuffix(len)
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local t = {}
	for i = 1, len or 6 do
		local n = math.random(#chars)
		t[#t+1] = string.sub(chars, n, n)
	end
	return table.concat(t)
end

local function bestRoot()
	local ok, root = pcall(function()
		if gethui then return gethui() end
		if get_hidden_ui then return get_hidden_ui() end
		if get_hidden_gui then return get_hidden_gui() end
		return nil
	end)
	if ok and root and typeof(root) == "Instance" then
		return root
	end
	if CoreGui then return CoreGui end
	return LocalPlr:WaitForChild("PlayerGui")
end

local function tryProtect(gui)
	local env = getfenv and getfenv() or _G
	local cands = {
		rawget(env, "protectgui"),
		rawget(env, "protect_gui"),
		rawget(_G, "protectgui"),
		rawget(_G, "protect_gui"),
		(syn and syn.protect_gui),
		(securegui),
		(secure_gui),
	}
	for _,fn in ipairs(cands) do
		if typeof(fn) == "function" then
			if pcall(fn, gui) then return true end
		end
	end
	return false
end

-- ========== singleton root ==========
local _root -- ScreenGui "RobloxGui"
local _watch

function Safety.GetRoot()
	if _root and _root.Parent then return _root end

	_root = Instance.new("ScreenGui")
	_root.Name = "RobloxGui" -- exact top-level name
	_root.ResetOnSpawn = false
	_root.IgnoreGuiInset = true
	_root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	_root.DisplayOrder = 100
	_root.Parent = bestRoot()

	pcall(tryProtect, _root) -- pre/post, some execs prefer either
	pcall(tryProtect, _root)

	if _watch then _watch:Disconnect() end
	_watch = _root.AncestryChanged:Connect(function(child, parent)
		if child == _root and not parent then
			_root.Parent = bestRoot()
			pcall(tryProtect, _root)
		end
	end)

	return _root
end

-- Make a full-screen Frame under the root
function Safety.NewLayer(opts)
	opts = opts or {}
	local root = Safety.GetRoot()
	local f = Instance.new("Frame")
	f.Name = "Layer_" .. randSuffix(6)
	f.BackgroundTransparency = 1
	f.Size = UDim2.fromScale(1,1)
	f.ZIndex = tonumber(opts.Z) or 1
	f.Visible = (opts.Visible ~= false)
	f.ClipsDescendants = opts.Clips == true
	f.Parent = root
	return f
end

-- Global floating layer for popovers/menus
local _float
function Safety.GetFloatLayer()
	if _float and _float.Parent then return _float end
	_float = Safety.NewLayer({ Z = 200, Visible = true, Clips = false })
	_float.Name = "Float_" .. randSuffix(6)
	return _float
end

-- Convenience random name for children you create yourself
function Safety.RandomChildName(prefix)
	prefix = prefix or "Node"
	return string.format("%s_%s", prefix, randSuffix(6))
end

return Safety

]]
Modules['lib/safety'] = Modules['lib/safety.lua']
Modules['safety'] = Modules['lib/safety.lua']

-- Module: lib/keysystem.lua
Modules['lib/keysystem.lua'] = [[
-- Fiend/lib/keysystem.lua
-- Unified Key System - Robust, secure, and consistent key management
-- Replaces the fragmented KeySystem, KeyGate, and keybind implementations

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Util = require(script.Parent.util)
local Theme = require(script.Parent.theme)
local Safety = require(script.Parent.safety)

local KeySystem = {}
KeySystem.__index = KeySystem

-- Types
export type KeyBindType = "Toggle" | "Hold" | "Press" | "Always"
export type KeyValidationResult = "valid" | "invalid" | "error"

export type KeyBind = {
    Name: string,
    KeyCode: Enum.KeyCode,
    Type: KeyBindType,
    Callback: ((boolean?) -> ())?,
    Enabled: boolean,
    Id: string?
}

export type KeyPromptOptions = {
    Title: string?,
    Hint: string?,
    Key: string?,
    Check: ((string) -> boolean)?,
    OnSuccess: (() -> ())?,
    OnFail: (() -> ())?,
    Theme: any?,
    Persistent: boolean?,
    MaxAttempts: number?
}

export type KeySystemOptions = {
    Theme: any?,
    GlobalKeyCapture: boolean?,
    DebugMode: boolean?
}

function KeySystem.new(options: KeySystemOptions?)
    local self = setmetatable({}, KeySystem)
    
    options = options or {}
    self._theme = options.Theme or Theme
    self._globalKeyCapture = options.GlobalKeyCapture ~= false
    self._debugMode = options.DebugMode or false
    
    -- State management
    self._binds = {} -- [name] = KeyBind
    self._activeStates = {} -- [name] = boolean
    self._connections = {}
    self._keyCaptureActive = false
    self._captureCallback = nil
    self._attempts = {} -- [promptId] = attemptCount
    
    -- Initialize global key handling
    if self._globalKeyCapture then
        self:_setupGlobalKeyHandling()
    end
    
    return self
end

-- Private: Setup global key handling
function KeySystem:_setupGlobalKeyHandling()
    local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        
        self:_handleKeyPress(input.KeyCode, true)
    end)
    
    local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        
        self:_handleKeyPress(input.KeyCode, false)
    end)
    
    table.insert(self._connections, inputBeganConn)
    table.insert(self._connections, inputEndedConn)
end

-- Private: Handle key press/release
function KeySystem:_handleKeyPress(keyCode: Enum.KeyCode, pressed: boolean)
    -- Handle key capture mode first
    if self._keyCaptureActive and self._captureCallback then
        if pressed then
            self._keyCaptureActive = false
            self._captureCallback(keyCode)
            self._captureCallback = nil
        end
        return
    end
    
    -- Handle registered binds
    for name, bind in pairs(self._binds) do
        if bind.KeyCode == keyCode and bind.Enabled then
            if bind.Type == "Toggle" and pressed then
                local newState = not self._activeStates[name]
                self._activeStates[name] = newState
                if bind.Callback and typeof(bind.Callback) == "function" then
                    task.spawn(bind.Callback, newState)
                end
                self:_debugLog("Toggle bind '%s' changed to %s", name, tostring(newState))
            elseif bind.Type == "Hold" then
                if pressed then
                    self._activeStates[name] = true
                    if bind.Callback and typeof(bind.Callback) == "function" then
                        task.spawn(bind.Callback, true)
                    end
                    self:_debugLog("Hold bind '%s' activated", name)
                else
                    self._activeStates[name] = false
                    if bind.Callback and typeof(bind.Callback) == "function" then
                        task.spawn(bind.Callback, false)
                    end
                    self:_debugLog("Hold bind '%s' deactivated", name)
                end
            elseif bind.Type == "Press" and pressed then
                if bind.Callback and typeof(bind.Callback) == "function" then
                    task.spawn(bind.Callback)
                end
                self:_debugLog("Press bind '%s' triggered", name)
            elseif bind.Type == "Always" and pressed then
                if bind.Callback and typeof(bind.Callback) == "function" then
                    task.spawn(bind.Callback, true)
                end
                self:_debugLog("Always bind '%s' triggered", name)
            end
        end
    end
end

-- Private: Debug logging
function KeySystem:_debugLog(format: string, ...)
    if self._debugMode then
        print(string.format("[KeySystem] " .. format, ...))
    end
end

-- Public: Register a key bind
function KeySystem:RegisterBind(name: string, keyCode: Enum.KeyCode, bindType: KeyBindType?, callback: ((boolean?) -> ())?, id: string?)
    if not name or not keyCode then
        error("[KeySystem] RegisterBind requires name and keyCode")
    end
    
    bindType = bindType or "Toggle"
    if not table.find({"Toggle", "Hold", "Press", "Always"}, bindType) then
        warn("[KeySystem] Invalid bind type '" .. tostring(bindType) .. "', defaulting to Toggle")
        bindType = "Toggle"
    end
    
    self._binds[name] = {
        Name = name,
        KeyCode = keyCode,
        Type = bindType,
        Callback = callback,
        Enabled = true,
        Id = id or name
    }
    
    self._activeStates[name] = false
    self:_debugLog("Registered bind '%s' with key %s (type: %s)", name, keyCode.Name, bindType)
end

-- Public: Unregister a key bind
function KeySystem:UnregisterBind(name: string)
    if self._binds[name] then
        self._binds[name] = nil
        self._activeStates[name] = nil
        self:_debugLog("Unregistered bind '%s'", name)
    end
end

-- Public: Update bind key
function KeySystem:SetBindKey(name: string, keyCode: Enum.KeyCode)
    local bind = self._binds[name]
    if bind then
        bind.KeyCode = keyCode
        self:_debugLog("Updated bind '%s' key to %s", name, keyCode.Name)
    end
end

-- Public: Update bind type
function KeySystem:SetBindType(name: string, bindType: KeyBindType)
    local bind = self._binds[name]
    if bind and table.find({"Toggle", "Hold", "Press", "Always"}, bindType) then
        bind.Type = bindType
        self._activeStates[name] = false -- Reset state
        self:_debugLog("Updated bind '%s' type to %s", name, bindType)
    end
end

-- Public: Enable/disable bind
function KeySystem:SetBindEnabled(name: string, enabled: boolean)
    local bind = self._binds[name]
    if bind then
        bind.Enabled = enabled
        self:_debugLog("Set bind '%s' enabled to %s", name, tostring(enabled))
    end
end

-- Public: Get bind state
function KeySystem:GetBindState(name: string): boolean
    return self._activeStates[name] or false
end

-- Public: Get bind info
function KeySystem:GetBind(name: string): KeyBind?
    return self._binds[name]
end

-- Public: Get all binds
function KeySystem:GetAllBinds(): {[string]: KeyBind}
    return self._binds
end

-- Public: Start key capture mode
function KeySystem:StartKeyCapture(callback: (Enum.KeyCode) -> ())
    if self._keyCaptureActive then
        warn("[KeySystem] Key capture already active")
        return
    end
    
    self._keyCaptureActive = true
    self._captureCallback = callback
    self:_debugLog("Started key capture mode")
end

-- Public: Stop key capture mode
function KeySystem:StopKeyCapture()
    self._keyCaptureActive = false
    self._captureCallback = nil
    self:_debugLog("Stopped key capture mode")
end

-- Public: Show key prompt dialog
function KeySystem:ShowPrompt(options: KeyPromptOptions?)
    options = options or {}
    
    local promptId = tostring(math.random(100000, 999999))
    self._attempts[promptId] = 0
    
    local theme = options.Theme or self._theme
    local maxAttempts = options.MaxAttempts or 3
    
    -- Create overlay
    local floatLayer = Safety.GetFloatLayer()
    floatLayer.Visible = true
    
    local overlay = Util.Create("Frame", {
        Name = "Fiend_KeyPrompt_" .. promptId,
        Parent = floatLayer,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 500,
        Active = true
    })
    
    -- Create card
    local cardWidth, cardHeight = 400, 220
    local card = Util.Create("Frame", {
        Name = "Card",
        Parent = overlay,
        BackgroundColor3 = theme.Background2 or theme.Background or Color3.fromRGB(24, 26, 30),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(cardWidth, cardHeight),
        Position = UDim2.new(0.5, -cardWidth/2, 0.5, -cardHeight/2),
        BackgroundTransparency = 0,
        ZIndex = 501
    })
    
    Util.CreateUICorner(card, theme.Corner or UDim.new(0, 8))
    Util.CreateUIStroke(card, theme.Border or Color3.fromRGB(42, 48, 60), 1)
    Util.CreateUIPadding(card, theme.Pad or UDim.new(0, 12))
    
    -- Title
    local title = Util.Create("TextLabel", {
        Name = "Title",
        Parent = card,
        BackgroundTransparency = 1,
        Text = options.Title or "Access Required",
        Font = theme.Font or Enum.Font.GothamSemibold,
        TextSize = 18,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 232, 236),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 24),
        ZIndex = 502
    })
    
    -- Hint
    local hint = Util.Create("TextLabel", {
        Name = "Hint",
        Parent = card,
        BackgroundTransparency = 1,
        Text = options.Hint or "Enter your access key to continue.",
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.SubTextColor or Color3.fromRGB(170, 176, 186),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 28),
        ZIndex = 502
    })
    
    -- Input box
    local input = Util.Create("TextBox", {
        Name = "KeyInput",
        Parent = card,
        BackgroundColor3 = theme.Background or Color3.fromRGB(12, 12, 14),
        Text = "",
        PlaceholderText = "Enter key here",
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 16,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 232, 236),
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 68),
        ZIndex = 502
    })
    
    Util.CreateUICorner(input, theme.Corner or UDim.new(0, 6))
    Util.CreateUIStroke(input, theme.Border or Color3.fromRGB(42, 48, 60), 1)
    Util.CreateUIPadding(input, UDim.new(0, 8))
    
    -- Error message
    local errorLabel = Util.Create("TextLabel", {
        Name = "Error",
        Parent = card,
        BackgroundTransparency = 1,
        Text = "",
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.Warning or Color3.fromRGB(255, 176, 67),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 108),
        ZIndex = 502
    })
    
    -- Submit button
    local submitBtn = Util.Create("TextButton", {
        Name = "Submit",
        Parent = card,
        Text = "Submit",
        Font = theme.Font or Enum.Font.GothamSemibold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = theme.Accent or Color3.fromRGB(91, 135, 255),
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 1, -36),
        ZIndex = 502
    })
    
    Util.CreateUICorner(submitBtn, theme.Corner or UDim.new(0, 6))
    
    -- Animation
    overlay.BackgroundTransparency = 1
    card.Position = UDim2.new(0.5, -cardWidth/2, 0.5, -cardHeight/2 + 20)
    
    local fadeInTween = TweenService:Create(overlay, 
        theme.TweenLong or TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.4}
    )
    
    local slideInTween = TweenService:Create(card,
        theme.TweenLong or TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -cardWidth/2, 0.5, -cardHeight/2)}
    )
    
    fadeInTween:Play()
    slideInTween:Play()
    
    -- Validation function
    local function validateKey(inputText: string): KeyValidationResult
        self._attempts[promptId] = (self._attempts[promptId] or 0) + 1
        
        if options.Check and typeof(options.Check) == "function" then
            local success, result = pcall(options.Check, inputText)
            if not success then
                self:_debugLog("Key validation error: %s", tostring(result))
                return "error"
            end
            return result and "valid" or "invalid"
        elseif options.Key and typeof(options.Key) == "string" then
            return inputText == options.Key and "valid" or "invalid"
        end
        
        return "invalid"
    end
    
    -- Close function
    local function closePrompt(success: boolean)
        local fadeOutTween = TweenService:Create(overlay,
            theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}
        )
        
        local slideOutTween = TweenService:Create(card,
            theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(0.5, -cardWidth/2, 0.5, -cardHeight/2 + 20)}
        )
        
        fadeOutTween:Play()
        slideOutTween:Play()
        
        task.delay(0.16, function()
            overlay:Destroy()
            self._attempts[promptId] = nil
            
            if success and options.OnSuccess then
                task.spawn(options.OnSuccess)
            elseif not success and options.OnFail then
                task.spawn(options.OnFail)
            end
        end)
    end
    
    -- Error function
    local function showError(message: string)
        errorLabel.Text = message
        
        -- Shake animation
        local originalPos = card.Position
        local shakeTween = TweenService:Create(card,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = originalPos + UDim2.fromOffset(8, 0)}
        )
        
        shakeTween:Play()
        task.delay(0.1, function()
            TweenService:Create(card,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = originalPos}
            ):Play()
        end)
    end
    
    -- Submit handler
    local function handleSubmit()
        local inputText = input.Text or ""
        local validation = validateKey(inputText)
        
        if validation == "valid" then
            closePrompt(true)
        elseif validation == "error" then
            showError("Validation error occurred")
        else
            local attempts = self._attempts[promptId] or 0
            if attempts >= maxAttempts then
                showError("Maximum attempts exceeded")
                task.delay(1, function() closePrompt(false) end)
            else
                showError(string.format("Invalid key. %d/%d attempts used.", attempts, maxAttempts))
            end
        end
    end
    
    -- Event connections
    submitBtn.MouseButton1Click:Connect(handleSubmit)
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            handleSubmit()
        end
    end)
    
    -- ESC key handler
    local escConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Escape then
            escConnection:Disconnect()
            closePrompt(false)
        end
    end)
    
    -- Focus input
    task.wait(0.3)
    input:CaptureFocus()
    
    return {
        Destroy = function()
            escConnection:Disconnect()
            overlay:Destroy()
            self._attempts[promptId] = nil
        end
    }
end

-- Public: Validate key with custom logic
function KeySystem:ValidateKey(key: string, validator: (string) -> boolean): boolean
    if not validator or typeof(validator) ~= "function" then
        return false
    end
    
    local success, result = pcall(validator, key)
    return success and result == true
end

-- Public: Check if key capture is active
function KeySystem:IsKeyCaptureActive(): boolean
    return self._keyCaptureActive
end

-- Public: Get attempt count for a prompt
function KeySystem:GetAttemptCount(promptId: string): number
    return self._attempts[promptId] or 0
end

-- Public: Clear all attempts
function KeySystem:ClearAttempts()
    table.clear(self._attempts)
end

-- Public: Destroy the keysystem
function KeySystem:Destroy()
    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end
    
    table.clear(self._binds)
    table.clear(self._activeStates)
    table.clear(self._attempts)
    
    self._keyCaptureActive = false
    self._captureCallback = nil
    
    self:_debugLog("KeySystem destroyed")
end

return KeySystem

]]
Modules['lib/keysystem'] = Modules['lib/keysystem.lua']
Modules['keysystem'] = Modules['lib/keysystem.lua']

-- Module: lib/theme_manager.lua
Modules['lib/theme_manager.lua'] = [[
-- Fiend/lib/theme_manager.lua
-- Advanced theme management system with preset themes and custom theme support

local HttpService = game:GetService("HttpService")
local ThemeManager = {}

-- Theme storage folder
ThemeManager.Folder = "FiendThemes"

-- Built-in themes with modern color palettes
ThemeManager.BuiltInThemes = {
    -- Default theme
    ["Default"] = {
        Background = Color3.fromRGB(8, 8, 10),
        Background2 = Color3.fromRGB(14, 14, 18),
        Background3 = Color3.fromRGB(20, 20, 24), -- For grids and subtle backgrounds
        TextColor = Color3.fromRGB(230, 230, 232),
        SubTextColor = Color3.fromRGB(170, 174, 182),
        Accent = Color3.fromRGB(220, 220, 224),
        AccentDim = Color3.fromRGB(170, 174, 182),
        Border = Color3.fromRGB(96, 98, 104),
        Success = Color3.fromRGB(200, 240, 210),
        Warning = Color3.fromRGB(255, 200, 120),
        Rounding = 6,
        Padding = 6,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(8, 8, 10),
            TitleText = Color3.fromRGB(230, 230, 232),
            SubtitleText = Color3.fromRGB(170, 174, 182),
            Border = Color3.fromRGB(96, 98, 104),
            CornerBrackets = Color3.fromRGB(220, 220, 224),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(14, 14, 18),
            ActiveFill = Color3.fromRGB(8, 8, 10),
            IdleText = Color3.fromRGB(170, 174, 182),
            ActiveText = Color3.fromRGB(230, 230, 232),
            Border = Color3.fromRGB(96, 98, 104),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(20, 20, 24),
            Border = Color3.fromRGB(96, 98, 104),
            LineColor = Color3.fromRGB(40, 42, 48),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(14, 14, 18),
            Border = Color3.fromRGB(96, 98, 104),
            ButtonIdleFill = Color3.fromRGB(8, 8, 10),
            ButtonActiveFill = Color3.fromRGB(14, 14, 18),
            ButtonIdleText = Color3.fromRGB(170, 174, 182),
            ButtonActiveText = Color3.fromRGB(230, 230, 232),
            ButtonIdleBorder = Color3.fromRGB(96, 98, 104),
            ButtonActiveBorder = Color3.fromRGB(220, 220, 224),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.45,        -- Base transparency for pulse effect
            PulseAmp = 0.35,         -- Amplitude of pulse effect
            PulseHz = 1.6,           -- Frequency of pulse effect
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(220, 220, 224),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(230, 230, 232),
            ScanlineTransparency = 0.85,
            ScanlineSpeed = 60,       -- pixels per second
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(220, 220, 224),
            TopSweepThickness = 2,
            TopSweepSpeed = 180,      -- pixels per second
            TopSweepGap = 24,         -- gap before bar re-enters
            TopSweepLength = 120,     -- bar length in pixels
            
            -- Grid
            GridColor = Color3.fromRGB(96, 98, 104),
            GridAlpha = 0.06,
            GridGap = 16,            -- grid spacing in pixels
        },
    },
    
    -- Modern themes inspired by LinoriaLib
    ["Tokyo Night"] = {
        Background = Color3.fromRGB(25, 25, 37),
        Background2 = Color3.fromRGB(22, 22, 31),
        Background3 = Color3.fromRGB(18, 18, 25), -- For grids
        TextColor = Color3.fromRGB(192, 202, 245),
        SubTextColor = Color3.fromRGB(103, 89, 179),
        Accent = Color3.fromRGB(103, 89, 179),
        AccentDim = Color3.fromRGB(73, 69, 149),
        Border = Color3.fromRGB(50, 50, 50),
        Success = Color3.fromRGB(103, 89, 179),
        Warning = Color3.fromRGB(255, 159, 67),
        Rounding = 8,
        Padding = 8,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(25, 25, 37),
            TitleText = Color3.fromRGB(192, 202, 245),
            SubtitleText = Color3.fromRGB(103, 89, 179),
            Border = Color3.fromRGB(50, 50, 50),
            CornerBrackets = Color3.fromRGB(103, 89, 179),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(22, 22, 31),
            ActiveFill = Color3.fromRGB(25, 25, 37),
            IdleText = Color3.fromRGB(103, 89, 179),
            ActiveText = Color3.fromRGB(192, 202, 245),
            Border = Color3.fromRGB(50, 50, 50),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(18, 18, 25),
            Border = Color3.fromRGB(50, 50, 50),
            LineColor = Color3.fromRGB(35, 35, 45),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(22, 22, 31),
            Border = Color3.fromRGB(50, 50, 50),
            ButtonIdleFill = Color3.fromRGB(25, 25, 37),
            ButtonActiveFill = Color3.fromRGB(22, 22, 31),
            ButtonIdleText = Color3.fromRGB(103, 89, 179),
            ButtonActiveText = Color3.fromRGB(192, 202, 245),
            ButtonIdleBorder = Color3.fromRGB(50, 50, 50),
            ButtonActiveBorder = Color3.fromRGB(103, 89, 179),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.4,         -- Slightly more visible
            PulseAmp = 0.4,          -- Stronger pulse
            PulseHz = 1.8,           -- Slightly faster
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(103, 89, 179),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(192, 202, 245),
            ScanlineTransparency = 0.8,
            ScanlineSpeed = 70,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(103, 89, 179),
            TopSweepThickness = 2,
            TopSweepSpeed = 200,
            TopSweepGap = 20,
            TopSweepLength = 100,
            
            -- Grid
            GridColor = Color3.fromRGB(50, 50, 50),
            GridAlpha = 0.08,
            GridGap = 14,
        },
    },
    
    ["Mint"] = {
        Background = Color3.fromRGB(36, 36, 36),
        Background2 = Color3.fromRGB(28, 28, 28),
        Background3 = Color3.fromRGB(22, 22, 22), -- For grids
        TextColor = Color3.fromRGB(255, 255, 255),
        SubTextColor = Color3.fromRGB(61, 180, 136),
        Accent = Color3.fromRGB(61, 180, 136),
        AccentDim = Color3.fromRGB(41, 160, 116),
        Border = Color3.fromRGB(55, 55, 55),
        Success = Color3.fromRGB(61, 180, 136),
        Warning = Color3.fromRGB(255, 193, 7),
        Rounding = 6,
        Padding = 6,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(36, 36, 36),
            TitleText = Color3.fromRGB(255, 255, 255),
            SubtitleText = Color3.fromRGB(61, 180, 136),
            Border = Color3.fromRGB(55, 55, 55),
            CornerBrackets = Color3.fromRGB(61, 180, 136),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(28, 28, 28),
            ActiveFill = Color3.fromRGB(36, 36, 36),
            IdleText = Color3.fromRGB(61, 180, 136),
            ActiveText = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(55, 55, 55),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(22, 22, 22),
            Border = Color3.fromRGB(55, 55, 55),
            LineColor = Color3.fromRGB(40, 40, 40),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(28, 28, 28),
            Border = Color3.fromRGB(55, 55, 55),
            ButtonIdleFill = Color3.fromRGB(36, 36, 36),
            ButtonActiveFill = Color3.fromRGB(28, 28, 28),
            ButtonIdleText = Color3.fromRGB(61, 180, 136),
            ButtonActiveText = Color3.fromRGB(255, 255, 255),
            ButtonIdleBorder = Color3.fromRGB(55, 55, 55),
            ButtonActiveBorder = Color3.fromRGB(61, 180, 136),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.5,         -- More subtle
            PulseAmp = 0.3,          -- Gentler pulse
            PulseHz = 1.4,           -- Slower, more relaxed
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(61, 180, 136),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(255, 255, 255),
            ScanlineTransparency = 0.9,
            ScanlineSpeed = 50,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(61, 180, 136),
            TopSweepThickness = 2,
            TopSweepSpeed = 160,
            TopSweepGap = 28,
            TopSweepLength = 140,
            
            -- Grid
            GridColor = Color3.fromRGB(55, 55, 55),
            GridAlpha = 0.05,
            GridGap = 18,
        },
    },
    
    ["Jester"] = {
        Background = Color3.fromRGB(36, 36, 36),
        Background2 = Color3.fromRGB(28, 28, 28),
        Background3 = Color3.fromRGB(22, 22, 22), -- For grids
        TextColor = Color3.fromRGB(255, 255, 255),
        SubTextColor = Color3.fromRGB(219, 68, 103),
        Accent = Color3.fromRGB(219, 68, 103),
        AccentDim = Color3.fromRGB(199, 48, 83),
        Border = Color3.fromRGB(55, 55, 55),
        Success = Color3.fromRGB(219, 68, 103),
        Warning = Color3.fromRGB(255, 193, 7),
        Rounding = 6,
        Padding = 6,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(36, 36, 36),
            TitleText = Color3.fromRGB(255, 255, 255),
            SubtitleText = Color3.fromRGB(219, 68, 103),
            Border = Color3.fromRGB(55, 55, 55),
            CornerBrackets = Color3.fromRGB(219, 68, 103),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(28, 28, 28),
            ActiveFill = Color3.fromRGB(36, 36, 36),
            IdleText = Color3.fromRGB(219, 68, 103),
            ActiveText = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(55, 55, 55),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(22, 22, 22),
            Border = Color3.fromRGB(55, 55, 55),
            LineColor = Color3.fromRGB(40, 40, 40),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(28, 28, 28),
            Border = Color3.fromRGB(55, 55, 55),
            ButtonIdleFill = Color3.fromRGB(36, 36, 36),
            ButtonActiveFill = Color3.fromRGB(28, 28, 28),
            ButtonIdleText = Color3.fromRGB(219, 68, 103),
            ButtonActiveText = Color3.fromRGB(255, 255, 255),
            ButtonIdleBorder = Color3.fromRGB(55, 55, 55),
            ButtonActiveBorder = Color3.fromRGB(219, 68, 103),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.4,         -- More visible for bold theme
            PulseAmp = 0.5,          -- Strong pulse
            PulseHz = 2.0,           -- Fast, energetic
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(219, 68, 103),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(255, 255, 255),
            ScanlineTransparency = 0.8,
            ScanlineSpeed = 80,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(219, 68, 103),
            TopSweepThickness = 2,
            TopSweepSpeed = 220,
            TopSweepGap = 18,
            TopSweepLength = 90,
            
            -- Grid
            GridColor = Color3.fromRGB(55, 55, 55),
            GridAlpha = 0.07,
            GridGap = 15,
        },
    },
    
    ["Fatality"] = {
        Background = Color3.fromRGB(30, 24, 66),
        Background2 = Color3.fromRGB(25, 19, 53),
        Background3 = Color3.fromRGB(20, 14, 40), -- For grids
        TextColor = Color3.fromRGB(255, 255, 255),
        SubTextColor = Color3.fromRGB(197, 7, 84),
        Accent = Color3.fromRGB(197, 7, 84),
        AccentDim = Color3.fromRGB(177, 0, 64),
        Border = Color3.fromRGB(60, 53, 93),
        Success = Color3.fromRGB(197, 7, 84),
        Warning = Color3.fromRGB(255, 193, 7),
        Rounding = 8,
        Padding = 8,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(30, 24, 66),
            TitleText = Color3.fromRGB(255, 255, 255),
            SubtitleText = Color3.fromRGB(197, 7, 84),
            Border = Color3.fromRGB(60, 53, 93),
            CornerBrackets = Color3.fromRGB(197, 7, 84),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(25, 19, 53),
            ActiveFill = Color3.fromRGB(30, 24, 66),
            IdleText = Color3.fromRGB(197, 7, 84),
            ActiveText = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(60, 53, 93),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(20, 14, 40),
            Border = Color3.fromRGB(60, 53, 93),
            LineColor = Color3.fromRGB(35, 28, 55),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(25, 19, 53),
            Border = Color3.fromRGB(60, 53, 93),
            ButtonIdleFill = Color3.fromRGB(30, 24, 66),
            ButtonActiveFill = Color3.fromRGB(25, 19, 53),
            ButtonIdleText = Color3.fromRGB(197, 7, 84),
            ButtonActiveText = Color3.fromRGB(255, 255, 255),
            ButtonIdleBorder = Color3.fromRGB(60, 53, 93),
            ButtonActiveBorder = Color3.fromRGB(197, 7, 84),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.35,        -- Very visible for gaming theme
            PulseAmp = 0.6,          -- Strong pulse
            PulseHz = 2.2,           -- Fast, intense
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(197, 7, 84),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(255, 255, 255),
            ScanlineTransparency = 0.75,
            ScanlineSpeed = 90,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(197, 7, 84),
            TopSweepThickness = 2,
            TopSweepSpeed = 240,
            TopSweepGap = 16,
            TopSweepLength = 80,
            
            -- Grid
            GridColor = Color3.fromRGB(60, 53, 93),
            GridAlpha = 0.09,
            GridGap = 12,
        },
    },
    
    ["Ubuntu"] = {
        Background = Color3.fromRGB(62, 62, 62),
        Background2 = Color3.fromRGB(50, 50, 50),
        Background3 = Color3.fromRGB(40, 40, 40), -- For grids
        TextColor = Color3.fromRGB(255, 255, 255),
        SubTextColor = Color3.fromRGB(226, 88, 30),
        Accent = Color3.fromRGB(226, 88, 30),
        AccentDim = Color3.fromRGB(206, 68, 10),
        Border = Color3.fromRGB(25, 25, 25),
        Success = Color3.fromRGB(226, 88, 30),
        Warning = Color3.fromRGB(255, 193, 7),
        Rounding = 6,
        Padding = 6,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(62, 62, 62),
            TitleText = Color3.fromRGB(255, 255, 255),
            SubtitleText = Color3.fromRGB(226, 88, 30),
            Border = Color3.fromRGB(25, 25, 25),
            CornerBrackets = Color3.fromRGB(226, 88, 30),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(50, 50, 50),
            ActiveFill = Color3.fromRGB(62, 62, 62),
            IdleText = Color3.fromRGB(226, 88, 30),
            ActiveText = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(25, 25, 25),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(40, 40, 40),
            Border = Color3.fromRGB(25, 25, 25),
            LineColor = Color3.fromRGB(55, 55, 55),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(50, 50, 50),
            Border = Color3.fromRGB(25, 25, 25),
            ButtonIdleFill = Color3.fromRGB(62, 62, 62),
            ButtonActiveFill = Color3.fromRGB(50, 50, 50),
            ButtonIdleText = Color3.fromRGB(226, 88, 30),
            ButtonActiveText = Color3.fromRGB(255, 255, 255),
            ButtonIdleBorder = Color3.fromRGB(25, 25, 25),
            ButtonActiveBorder = Color3.fromRGB(226, 88, 30),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.45,        -- Moderate visibility
            PulseAmp = 0.4,          -- Moderate pulse
            PulseHz = 1.6,           -- Standard speed
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(226, 88, 30),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(255, 255, 255),
            ScanlineTransparency = 0.85,
            ScanlineSpeed = 60,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(226, 88, 30),
            TopSweepThickness = 2,
            TopSweepSpeed = 180,
            TopSweepGap = 24,
            TopSweepLength = 120,
            
            -- Grid
            GridColor = Color3.fromRGB(25, 25, 25),
            GridAlpha = 0.06,
            GridGap = 16,
        },
    },
    
    ["Quartz"] = {
        Background = Color3.fromRGB(35, 35, 48),
        Background2 = Color3.fromRGB(29, 27, 38),
        Background3 = Color3.fromRGB(23, 21, 30), -- For grids
        TextColor = Color3.fromRGB(255, 255, 255),
        SubTextColor = Color3.fromRGB(66, 110, 135),
        Accent = Color3.fromRGB(66, 110, 135),
        AccentDim = Color3.fromRGB(46, 90, 115),
        Border = Color3.fromRGB(39, 35, 47),
        Success = Color3.fromRGB(66, 110, 135),
        Warning = Color3.fromRGB(255, 193, 7),
        Rounding = 8,
        Padding = 8,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(35, 35, 48),
            TitleText = Color3.fromRGB(255, 255, 255),
            SubtitleText = Color3.fromRGB(66, 110, 135),
            Border = Color3.fromRGB(39, 35, 47),
            CornerBrackets = Color3.fromRGB(66, 110, 135),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(29, 27, 38),
            ActiveFill = Color3.fromRGB(35, 35, 48),
            IdleText = Color3.fromRGB(66, 110, 135),
            ActiveText = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(39, 35, 47),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(23, 21, 30),
            Border = Color3.fromRGB(39, 35, 47),
            LineColor = Color3.fromRGB(45, 41, 55),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(29, 27, 38),
            Border = Color3.fromRGB(39, 35, 47),
            ButtonIdleFill = Color3.fromRGB(35, 35, 48),
            ButtonActiveFill = Color3.fromRGB(29, 27, 38),
            ButtonIdleText = Color3.fromRGB(66, 110, 135),
            ButtonActiveText = Color3.fromRGB(255, 255, 255),
            ButtonIdleBorder = Color3.fromRGB(39, 35, 47),
            ButtonActiveBorder = Color3.fromRGB(66, 110, 135),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.4,         -- Professional look
            PulseAmp = 0.35,         -- Subtle pulse
            PulseHz = 1.5,           -- Calm, professional
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(66, 110, 135),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(255, 255, 255),
            ScanlineTransparency = 0.9,
            ScanlineSpeed = 50,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(66, 110, 135),
            TopSweepThickness = 2,
            TopSweepSpeed = 160,
            TopSweepGap = 28,
            TopSweepLength = 140,
            
            -- Grid
            GridColor = Color3.fromRGB(39, 35, 47),
            GridAlpha = 0.05,
            GridGap = 18,
        },
    },
    
    ["BBot"] = {
        Background = Color3.fromRGB(30, 30, 30),
        Background2 = Color3.fromRGB(35, 35, 35),
        Background3 = Color3.fromRGB(25, 25, 25), -- For grids
        TextColor = Color3.fromRGB(255, 255, 255),
        SubTextColor = Color3.fromRGB(126, 72, 163),
        Accent = Color3.fromRGB(126, 72, 163),
        AccentDim = Color3.fromRGB(106, 52, 143),
        Border = Color3.fromRGB(20, 20, 20),
        Success = Color3.fromRGB(126, 72, 163),
        Warning = Color3.fromRGB(255, 193, 7),
        Rounding = 6,
        Padding = 6,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(30, 30, 30),
            TitleText = Color3.fromRGB(255, 255, 255),
            SubtitleText = Color3.fromRGB(126, 72, 163),
            Border = Color3.fromRGB(20, 20, 20),
            CornerBrackets = Color3.fromRGB(126, 72, 163),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(35, 35, 35),
            ActiveFill = Color3.fromRGB(30, 30, 30),
            IdleText = Color3.fromRGB(126, 72, 163),
            ActiveText = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(20, 20, 20),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(25, 25, 25),
            Border = Color3.fromRGB(20, 20, 20),
            LineColor = Color3.fromRGB(40, 40, 40),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(35, 35, 35),
            Border = Color3.fromRGB(20, 20, 20),
            ButtonIdleFill = Color3.fromRGB(30, 30, 30),
            ButtonActiveFill = Color3.fromRGB(35, 35, 35),
            ButtonIdleText = Color3.fromRGB(126, 72, 163),
            ButtonActiveText = Color3.fromRGB(255, 255, 255),
            ButtonIdleBorder = Color3.fromRGB(20, 20, 20),
            ButtonActiveBorder = Color3.fromRGB(126, 72, 163),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.4,         -- Bot-like precision
            PulseAmp = 0.45,         -- Mechanical pulse
            PulseHz = 1.8,           -- Systematic rhythm
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(126, 72, 163),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(255, 255, 255),
            ScanlineTransparency = 0.8,
            ScanlineSpeed = 70,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(126, 72, 163),
            TopSweepThickness = 2,
            TopSweepSpeed = 200,
            TopSweepGap = 20,
            TopSweepLength = 100,
            
            -- Grid
            GridColor = Color3.fromRGB(20, 20, 20),
            GridAlpha = 0.08,
            GridGap = 14,
        },
    },
    
    -- Custom requested themes
    ["Retro Futurism"] = {
        Background = Color3.fromRGB(0, 0, 0),
        Background2 = Color3.fromRGB(20, 20, 20),
        Background3 = Color3.fromRGB(10, 10, 10), -- For grids
        TextColor = Color3.fromRGB(255, 255, 255),
        SubTextColor = Color3.fromRGB(200, 200, 200),
        Accent = Color3.fromRGB(255, 255, 255),
        AccentDim = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(100, 100, 100),
        Success = Color3.fromRGB(255, 255, 255),
        Warning = Color3.fromRGB(255, 255, 0),
        Rounding = 4,
        Padding = 8,
        LineThickness = 2,
        Font = Enum.Font.Code,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(0, 0, 0),
            TitleText = Color3.fromRGB(255, 255, 255),
            SubtitleText = Color3.fromRGB(200, 200, 200),
            Border = Color3.fromRGB(100, 100, 100),
            CornerBrackets = Color3.fromRGB(255, 255, 255),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(20, 20, 20),
            ActiveFill = Color3.fromRGB(0, 0, 0),
            IdleText = Color3.fromRGB(200, 200, 200),
            ActiveText = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(100, 100, 100),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(10, 10, 10),
            Border = Color3.fromRGB(100, 100, 100),
            LineColor = Color3.fromRGB(30, 30, 30),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(20, 20, 20),
            Border = Color3.fromRGB(100, 100, 100),
            ButtonIdleFill = Color3.fromRGB(0, 0, 0),
            ButtonActiveFill = Color3.fromRGB(20, 20, 20),
            ButtonIdleText = Color3.fromRGB(200, 200, 200),
            ButtonActiveText = Color3.fromRGB(255, 255, 255),
            ButtonIdleBorder = Color3.fromRGB(100, 100, 100),
            ButtonActiveBorder = Color3.fromRGB(255, 255, 255),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.3,         -- Very visible for retro
            PulseAmp = 0.7,           -- Strong pulse
            PulseHz = 2.5,            -- Fast, futuristic
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(255, 255, 255),
            CornerBracketThickness = 2,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(255, 255, 255),
            ScanlineTransparency = 0.7,
            ScanlineSpeed = 100,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(255, 255, 255),
            TopSweepThickness = 2,
            TopSweepSpeed = 280,
            TopSweepGap = 14,
            TopSweepLength = 70,
            
            -- Grid
            GridColor = Color3.fromRGB(100, 100, 100),
            GridAlpha = 0.1,
            GridGap = 10,
        },
    },
    
    ["October"] = {
        Background = Color3.fromRGB(20, 8, 8),
        Background2 = Color3.fromRGB(30, 15, 15),
        Background3 = Color3.fromRGB(15, 5, 5), -- For grids
        TextColor = Color3.fromRGB(255, 200, 100),
        SubTextColor = Color3.fromRGB(255, 140, 60),
        Accent = Color3.fromRGB(255, 100, 0),
        AccentDim = Color3.fromRGB(200, 80, 0),
        Border = Color3.fromRGB(80, 40, 20),
        Success = Color3.fromRGB(255, 100, 0),
        Warning = Color3.fromRGB(255, 200, 0),
        Rounding = 8,
        Padding = 8,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(20, 8, 8),
            TitleText = Color3.fromRGB(255, 200, 100),
            SubtitleText = Color3.fromRGB(255, 140, 60),
            Border = Color3.fromRGB(80, 40, 20),
            CornerBrackets = Color3.fromRGB(255, 100, 0),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(30, 15, 15),
            ActiveFill = Color3.fromRGB(20, 8, 8),
            IdleText = Color3.fromRGB(255, 140, 60),
            ActiveText = Color3.fromRGB(255, 200, 100),
            Border = Color3.fromRGB(80, 40, 20),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(15, 5, 5),
            Border = Color3.fromRGB(80, 40, 20),
            LineColor = Color3.fromRGB(40, 20, 10),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(30, 15, 15),
            Border = Color3.fromRGB(80, 40, 20),
            ButtonIdleFill = Color3.fromRGB(20, 8, 8),
            ButtonActiveFill = Color3.fromRGB(30, 15, 15),
            ButtonIdleText = Color3.fromRGB(255, 140, 60),
            ButtonActiveText = Color3.fromRGB(255, 200, 100),
            ButtonIdleBorder = Color3.fromRGB(80, 40, 20),
            ButtonActiveBorder = Color3.fromRGB(255, 100, 0),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.4,         -- Warm, cozy feel
            PulseAmp = 0.4,           -- Gentle pulse
            PulseHz = 1.3,            -- Slow, autumn rhythm
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(255, 100, 0),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(255, 200, 100),
            ScanlineTransparency = 0.85,
            ScanlineSpeed = 45,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(255, 100, 0),
            TopSweepThickness = 2,
            TopSweepSpeed = 140,
            TopSweepGap = 30,
            TopSweepLength = 150,
            
            -- Grid
            GridColor = Color3.fromRGB(80, 40, 20),
            GridAlpha = 0.06,
            GridGap = 20,
        },
        
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
    },
    
    -- Additional modern themes
    ["Nord"] = {
        Background = Color3.fromRGB(46, 52, 64),
        Background2 = Color3.fromRGB(59, 66, 82),
        Background3 = Color3.fromRGB(67, 76, 94), -- For grids
        TextColor = Color3.fromRGB(236, 239, 244),
        SubTextColor = Color3.fromRGB(129, 161, 193),
        Accent = Color3.fromRGB(129, 161, 193),
        AccentDim = Color3.fromRGB(109, 141, 173),
        Border = Color3.fromRGB(76, 86, 106),
        Success = Color3.fromRGB(163, 190, 140),
        Warning = Color3.fromRGB(235, 203, 139),
        Rounding = 6,
        Padding = 6,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(46, 52, 64),
            TitleText = Color3.fromRGB(236, 239, 244),
            SubtitleText = Color3.fromRGB(129, 161, 193),
            Border = Color3.fromRGB(76, 86, 106),
            CornerBrackets = Color3.fromRGB(129, 161, 193),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(59, 66, 82),
            ActiveFill = Color3.fromRGB(46, 52, 64),
            IdleText = Color3.fromRGB(129, 161, 193),
            ActiveText = Color3.fromRGB(236, 239, 244),
            Border = Color3.fromRGB(76, 86, 106),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(67, 76, 94),
            Border = Color3.fromRGB(76, 86, 106),
            LineColor = Color3.fromRGB(88, 96, 112),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(59, 66, 82),
            Border = Color3.fromRGB(76, 86, 106),
            ButtonIdleFill = Color3.fromRGB(46, 52, 64),
            ButtonActiveFill = Color3.fromRGB(59, 66, 82),
            ButtonIdleText = Color3.fromRGB(129, 161, 193),
            ButtonActiveText = Color3.fromRGB(236, 239, 244),
            ButtonIdleBorder = Color3.fromRGB(76, 86, 106),
            ButtonActiveBorder = Color3.fromRGB(129, 161, 193),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.4,         -- Arctic pulse
            PulseAmp = 0.4,          -- Moderate pulse
            PulseHz = 1.8,           -- Steady rhythm
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(129, 161, 193),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(236, 239, 244),
            ScanlineTransparency = 0.85,
            ScanlineSpeed = 70,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(129, 161, 193),
            TopSweepThickness = 2,
            TopSweepSpeed = 200,
            TopSweepGap = 22,
            TopSweepLength = 100,
            
            -- Grid
            GridColor = Color3.fromRGB(76, 86, 106),
            GridAlpha = 0.06,
            GridGap = 16,
        },
    },
    
    ["Dracula"] = {
        Background = Color3.fromRGB(40, 42, 54),
        Background2 = Color3.fromRGB(68, 71, 90),
        Background3 = Color3.fromRGB(50, 53, 70), -- For grids
        TextColor = Color3.fromRGB(248, 248, 242),
        SubTextColor = Color3.fromRGB(139, 233, 253),
        Accent = Color3.fromRGB(139, 233, 253),
        AccentDim = Color3.fromRGB(119, 213, 233),
        Border = Color3.fromRGB(98, 114, 164),
        Success = Color3.fromRGB(80, 250, 123),
        Warning = Color3.fromRGB(255, 184, 108),
        Rounding = 6,
        Padding = 6,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(40, 42, 54),
            TitleText = Color3.fromRGB(248, 248, 242),
            SubtitleText = Color3.fromRGB(139, 233, 253),
            Border = Color3.fromRGB(98, 114, 164),
            CornerBrackets = Color3.fromRGB(139, 233, 253),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(68, 71, 90),
            ActiveFill = Color3.fromRGB(40, 42, 54),
            IdleText = Color3.fromRGB(139, 233, 253),
            ActiveText = Color3.fromRGB(248, 248, 242),
            Border = Color3.fromRGB(98, 114, 164),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(50, 53, 70),
            Border = Color3.fromRGB(98, 114, 164),
            LineColor = Color3.fromRGB(80, 85, 102),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(68, 71, 90),
            Border = Color3.fromRGB(98, 114, 164),
            ButtonIdleFill = Color3.fromRGB(40, 42, 54),
            ButtonActiveFill = Color3.fromRGB(68, 71, 90),
            ButtonIdleText = Color3.fromRGB(139, 233, 253),
            ButtonActiveText = Color3.fromRGB(248, 248, 242),
            ButtonIdleBorder = Color3.fromRGB(98, 114, 164),
            ButtonActiveBorder = Color3.fromRGB(139, 233, 253),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.45,        -- Dracula pulse
            PulseAmp = 0.35,         -- Subtle pulse
            PulseHz = 1.5,           -- Mysterious rhythm
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(139, 233, 253),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(248, 248, 242),
            ScanlineTransparency = 0.85,
            ScanlineSpeed = 65,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(139, 233, 253),
            TopSweepThickness = 2,
            TopSweepSpeed = 190,
            TopSweepGap = 25,
            TopSweepLength = 110,
            
            -- Grid
            GridColor = Color3.fromRGB(98, 114, 164),
            GridAlpha = 0.06,
            GridGap = 16,
        },
    },
    
    ["Solarized Dark"] = {
        Background = Color3.fromRGB(0, 43, 54),
        Background2 = Color3.fromRGB(7, 54, 66),
        Background3 = Color3.fromRGB(14, 65, 78), -- For grids
        TextColor = Color3.fromRGB(131, 148, 150),
        SubTextColor = Color3.fromRGB(38, 139, 210),
        Accent = Color3.fromRGB(38, 139, 210),
        AccentDim = Color3.fromRGB(18, 119, 190),
        Border = Color3.fromRGB(88, 110, 117),
        Success = Color3.fromRGB(133, 153, 0),
        Warning = Color3.fromRGB(181, 137, 0),
        Rounding = 6,
        Padding = 6,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(0, 43, 54),
            TitleText = Color3.fromRGB(131, 148, 150),
            SubtitleText = Color3.fromRGB(38, 139, 210),
            Border = Color3.fromRGB(88, 110, 117),
            CornerBrackets = Color3.fromRGB(38, 139, 210),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(7, 54, 66),
            ActiveFill = Color3.fromRGB(0, 43, 54),
            IdleText = Color3.fromRGB(38, 139, 210),
            ActiveText = Color3.fromRGB(131, 148, 150),
            Border = Color3.fromRGB(88, 110, 117),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(14, 65, 78),
            Border = Color3.fromRGB(88, 110, 117),
            LineColor = Color3.fromRGB(42, 161, 152),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(7, 54, 66),
            Border = Color3.fromRGB(88, 110, 117),
            ButtonIdleFill = Color3.fromRGB(0, 43, 54),
            ButtonActiveFill = Color3.fromRGB(7, 54, 66),
            ButtonIdleText = Color3.fromRGB(38, 139, 210),
            ButtonActiveText = Color3.fromRGB(131, 148, 150),
            ButtonIdleBorder = Color3.fromRGB(88, 110, 117),
            ButtonActiveBorder = Color3.fromRGB(38, 139, 210),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.4,         -- Solarized pulse
            PulseAmp = 0.3,          -- Gentle pulse
            PulseHz = 1.4,           -- Calm rhythm
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(38, 139, 210),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(131, 148, 150),
            ScanlineTransparency = 0.9,
            ScanlineSpeed = 60,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(38, 139, 210),
            TopSweepThickness = 2,
            TopSweepSpeed = 180,
            TopSweepGap = 26,
            TopSweepLength = 120,
            
            -- Grid
            GridColor = Color3.fromRGB(88, 110, 117),
            GridAlpha = 0.05,
            GridGap = 18,
        },
    },
    
    ["Monokai"] = {
        Background = Color3.fromRGB(39, 40, 34),
        Background2 = Color3.fromRGB(46, 46, 40),
        Background3 = Color3.fromRGB(53, 54, 48), -- For grids
        TextColor = Color3.fromRGB(248, 248, 242),
        SubTextColor = Color3.fromRGB(174, 129, 255),
        Accent = Color3.fromRGB(174, 129, 255),
        AccentDim = Color3.fromRGB(154, 109, 235),
        Border = Color3.fromRGB(117, 113, 94),
        Success = Color3.fromRGB(166, 226, 46),
        Warning = Color3.fromRGB(230, 219, 116),
        Rounding = 6,
        Padding = 6,
        LineThickness = 1,
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        
        -- Window theming
        Window = {
            Background = Color3.fromRGB(39, 40, 34),
            TitleText = Color3.fromRGB(248, 248, 242),
            SubtitleText = Color3.fromRGB(174, 129, 255),
            Border = Color3.fromRGB(117, 113, 94),
            CornerBrackets = Color3.fromRGB(174, 129, 255),
        },
        
        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(46, 46, 40),
            ActiveFill = Color3.fromRGB(39, 40, 34),
            IdleText = Color3.fromRGB(174, 129, 255),
            ActiveText = Color3.fromRGB(248, 248, 242),
            Border = Color3.fromRGB(117, 113, 94),
            PillHeight = 22,
            Uppercase = false,
        },
        
        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(53, 54, 48),
            Border = Color3.fromRGB(117, 113, 94),
            LineColor = Color3.fromRGB(102, 217, 239),
        },
        
        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(46, 46, 40),
            Border = Color3.fromRGB(117, 113, 94),
            ButtonIdleFill = Color3.fromRGB(39, 40, 34),
            ButtonActiveFill = Color3.fromRGB(46, 46, 40),
            ButtonIdleText = Color3.fromRGB(174, 129, 255),
            ButtonActiveText = Color3.fromRGB(248, 248, 242),
            ButtonIdleBorder = Color3.fromRGB(117, 113, 94),
            ButtonActiveBorder = Color3.fromRGB(174, 129, 255),
            ButtonSize = 44,
        },
        
        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.4,         -- Monokai pulse
            PulseAmp = 0.35,         -- Moderate pulse
            PulseHz = 1.6,           -- Coding rhythm
            
            -- Corner brackets
            CornerBrackets = Color3.fromRGB(174, 129, 255),
            CornerBracketThickness = 1,
            
            -- Scanlines
            ScanlineColor = Color3.fromRGB(248, 248, 242),
            ScanlineTransparency = 0.85,
            ScanlineSpeed = 70,
            
            -- Top sweep
            TopSweepColor = Color3.fromRGB(174, 129, 255),
            TopSweepThickness = 2,
            TopSweepSpeed = 200,
            TopSweepGap = 22,
            TopSweepLength = 100,
            
            -- Grid
            GridColor = Color3.fromRGB(117, 113, 94),
            GridAlpha = 0.06,
            GridGap = 16,
        },
    },
}

-- Current library reference
ThemeManager.Library = nil

-- Apply a theme to the library
function ThemeManager:ApplyTheme(themeName)
    local theme = self.BuiltInThemes[themeName]
    if not theme then
        warn("[ThemeManager] Theme not found:", themeName)
        return false
    end
    
    if not self.Library then
        warn("[ThemeManager] Library not set. Call ThemeManager:SetLibrary() first.")
        return false
    end
    
    -- Apply theme to library
    for key, value in pairs(theme) do
        self.Library.Theme[key] = value
    end
    
    -- Update aliases
    self.Library.Theme.Foreground = self.Library.Theme.TextColor
    self.Library.Theme.Corner = UDim.new(0, self.Library.Theme.Rounding)
    self.Library.Theme.Pad = UDim.new(0, self.Library.Theme.Padding)
    
    -- Refresh all elements
    self.Library:RefreshAllElements()
    
    print("[ThemeManager] Applied theme:", themeName)
    return true
end

-- Set the library reference
function ThemeManager:SetLibrary(library)
    self.Library = library
end

-- Get all available theme names
function ThemeManager:GetThemeNames()
    local names = {}
    for name, _ in pairs(self.BuiltInThemes) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

-- Get theme data
function ThemeManager:GetTheme(themeName)
    return self.BuiltInThemes[themeName]
end

-- Create a theme selector UI
function ThemeManager:CreateThemeSelector(tab)
    if not self.Library then
        warn("[ThemeManager] Library not set. Call ThemeManager:SetLibrary() first.")
        return nil
    end
    
    local themeNames = self:GetThemeNames()
    
    -- Add theme selector dropdown
    local dropdown = tab:AddDropdown("Theme Selector", themeNames, "Default", function(selectedTheme)
        self:ApplyTheme(selectedTheme)
    end)
    
    -- Add theme preview buttons
    tab:AddButton("Preview Themes", function()
        print("Available themes:")
        for _, name in ipairs(themeNames) do
            print("  - " .. name)
        end
    end)
    
    -- Add random theme button
    tab:AddButton("Random Theme", function()
        local randomTheme = themeNames[math.random(1, #themeNames)]
        self:ApplyTheme(randomTheme)
        print("Applied random theme:", randomTheme)
    end)
    
    return dropdown
end

-- Create a comprehensive theme manager UI
function ThemeManager:CreateThemeManager(tab)
    if not self.Library then
        warn("[ThemeManager] Library not set. Call ThemeManager:SetLibrary() first.")
        return nil
    end
    
    local themeNames = self:GetThemeNames()
    
    -- Theme selector
    local themeDropdown = tab:AddDropdown("Select Theme", themeNames, "Default", function(selectedTheme)
        self:ApplyTheme(selectedTheme)
    end)
    
    -- Theme categories
    tab:AddButton("Modern Themes", function()
        local modernThemes = {"Tokyo Night", "Mint", "Jester", "Fatality", "Ubuntu", "Quartz", "BBot"}
        local randomTheme = modernThemes[math.random(1, #modernThemes)]
        self:ApplyTheme(randomTheme)
        print("Applied modern theme:", randomTheme)
    end)
    
    tab:AddButton("Classic Themes", function()
        local classicThemes = {"Default", "Nord", "Dracula", "Solarized Dark", "Monokai"}
        local randomTheme = classicThemes[math.random(1, #classicThemes)]
        self:ApplyTheme(randomTheme)
        print("Applied classic theme:", randomTheme)
    end)
    
    tab:AddButton("Special Themes", function()
        local specialThemes = {"Retro Futurism", "October"}
        local randomTheme = specialThemes[math.random(1, #specialThemes)]
        self:ApplyTheme(randomTheme)
        print("Applied special theme:", randomTheme)
    end)
    
    -- Theme info
    tab:AddButton("Theme Info", function()
        local currentTheme = "Default" -- This would need to be tracked
        local theme = self:GetTheme(currentTheme)
        if theme then
            print("Current theme:", currentTheme)
            print("Background:", theme.Background)
            print("Accent:", theme.Accent)
            print("Text Color:", theme.TextColor)
        end
    end)
    
    return themeDropdown
end

-- Load default theme
function ThemeManager:LoadDefault()
    self:ApplyTheme("Default")
end

-- Get theme count
function ThemeManager:GetThemeCount()
    local count = 0
    for _ in pairs(self.BuiltInThemes) do
        count = count + 1
    end
    return count
end

-- List all themes with descriptions
function ThemeManager:ListThemes()
    local themes = {
        ["Default"] = "Original Fiend theme - Dark monochrome",
        ["Tokyo Night"] = "Modern dark theme with purple accents",
        ["Mint"] = "Clean green theme with modern aesthetics",
        ["Jester"] = "Bold red theme with high contrast",
        ["Fatality"] = "Deep purple theme with gaming vibes",
        ["Ubuntu"] = "Orange theme inspired by Ubuntu Linux",
        ["Quartz"] = "Blue-gray theme with professional look",
        ["BBot"] = "Purple theme with bot-like aesthetics",
        ["Retro Futurism"] = "Black and white retro-futuristic theme",
        ["October"] = "Halloween-inspired orange and black theme",
        ["Nord"] = "Arctic-inspired blue theme",
        ["Dracula"] = "Dark theme with cyan accents",
        ["Solarized Dark"] = "Eye-friendly dark theme with blue accents",
        ["Monokai"] = "Popular coding theme with purple accents",
    }
    
    print("Available themes:")
    for name, description in pairs(themes) do
        print(string.format("  %-20s - %s", name, description))
    end
end

return ThemeManager

]]
Modules['lib/theme_manager'] = Modules['lib/theme_manager.lua']
Modules['theme_manager'] = Modules['lib/theme_manager.lua']

-- Module: init.lua
Modules['init.lua'] = [[
-- Fiend/init.lua
-- Public entrypoint for the Fiend UI Library (dual-mode)

-- Detect environment and set up require
local require = require
local script = script

-- In executor environment, these will be set by the loader
-- Check if script exists (it won't in executor mode)
local hasScript = script ~= nil

if not hasScript then
    -- Set up executor environment
    script = { Parent = { Parent = {} } }
    -- require is already set by the bootstrapper's env
end

-- Try to detect if we're in Studio or Executor
local isStudio = game:GetService("RunService"):IsStudio()

-- Load core dependencies based on environment
local Theme, Binds, Config, Window, ThemeManager

-- Determine which require function to use
local customRequire = require
if isStudio and hasScript then
    -- Studio mode: use normal requires
    Theme  = require(script.Parent.lib.theme)
    Binds  = require(script.Parent.lib.binds)
    Config  = require(script.Parent.lib.config)
    Window = require(script.Parent.components.window)
    ThemeManager = require(script.Parent.lib.theme_manager)
else
    -- Executor mode: use custom require (passed in via environment)
    Theme  = require("lib/theme")
    Binds  = require("lib/binds")
    Config = require("lib/config")
    Window = require("components/window")
    ThemeManager = require("lib/theme_manager")
end

-- Safety check - make sure we got valid objects
if not Theme then
    error("[Fiend] Failed to load Theme module")
end
if not Binds then
    error("[Fiend] Failed to load Binds module")
end
if not Config then
    error("[Fiend] Failed to load Config module")
end
if not Window then
    error("[Fiend] Failed to load Window module")
end

local Fiend = {
    Version = "0.1.0",
    Theme   = Theme,
    Binds   = Binds,
    Config  = Config,
    ThemeManager = ThemeManager,
    _isStudio = isStudio,
}

-- Set global instance for element tracking
_G.FiendInstance = Fiend

-- Create a new top-level window
function Fiend:CreateWindow(opts)
    opts = opts or {}
    
    -- Handle theme name resolution
    if opts.Theme and type(opts.Theme) == "string" then
        if self.ThemeManager then
            local themeData = self.ThemeManager:GetTheme(opts.Theme)
            if themeData then
                opts.Theme = themeData
            else
                warn("[Fiend] Theme not found:", opts.Theme, "- using default theme")
                opts.Theme = nil -- Will use default theme
            end
        else
            warn("[Fiend] ThemeManager not available - using default theme")
            opts.Theme = nil -- Will use default theme
        end
    end
    
    local window = Window.new(opts)
    
    -- Initialize ThemeManager with the window
    if self.ThemeManager then
        self.ThemeManager:SetLibrary(self)
    end
    
    return window
end

-- Optional: apply a different theme object at runtime
function Fiend:SetTheme(newTheme)
    if type(newTheme) == "string" then
        -- Theme name provided, use ThemeManager
        if self.ThemeManager then
            local themeData = self.ThemeManager:GetTheme(newTheme)
            if themeData then
                for k, v in pairs(themeData) do
                    self.Theme[k] = v
                end
                self:RefreshAllElements()
                print("[Fiend] Applied theme:", newTheme)
            else
                warn("[Fiend] Theme not found:", newTheme)
            end
        else
            warn("[Fiend] ThemeManager not available")
        end
    elseif type(newTheme) == "table" then
        -- Theme table provided
        for k, v in pairs(newTheme) do
            self.Theme[k] = v
        end
        -- Refresh all existing elements
        self:RefreshAllElements()
    end
end

-- Refresh all UI elements with current theme
function Fiend:RefreshAllElements()
    if self._trackedElements then
        for _, element in ipairs(self._trackedElements) do
            if element and element.RefreshTheme then
                element:RefreshTheme()
            end
        end
        print("[Fiend] Refreshed", #self._trackedElements, "elements with current theme")
    end
end

-- Create a new theme-aware element tracker
function Fiend:_trackElement(element)
    if not self._trackedElements then
        self._trackedElements = {}
    end
    table.insert(self._trackedElements, element)
end

-- Remove element from tracking
function Fiend:_untrackElement(element)
    if self._trackedElements then
        for i, tracked in ipairs(self._trackedElements) do
            if tracked == element then
                table.remove(self._trackedElements, i)
                break
            end
        end
    end
end

-- Create notification system
function Fiend:CreateNotification()
    local Notify
    if hasScript then
        Notify = require(script.Parent.components.notify)
    else
        Notify = require("components/notify")
    end
    return Notify.new(self.Theme)
end

-- Create announcement system
function Fiend:CreateAnnouncement()
    local Announce
    if hasScript then
        Announce = require(script.Parent.components.announce)
    else
        Announce = require("components/announce")
    end
    return Announce.new(self.Theme)
end

-- Convenience passthroughs for serialization
function Fiend:SerializeConfig()
    if self.Config and self.Config.Serialize then
        return self.Config:Serialize()
    end
    return "{}"
end

function Fiend:DeserializeConfig(json)
    if self.Config and self.Config.Deserialize then
        return self.Config:Deserialize(json)
    end
    return false
end

return Fiend
]]
Modules['init'] = Modules['init.lua']
Modules['init'] = Modules['init.lua']

-- Module: components/button.lua
Modules['components/button.lua'] = [[
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
		Theme = theme,
	})
	self.Root = row
	self._button = btn
	self._theme = theme
	
	
	-- Ensure BaseElement methods are available
	setmetatable(self, {__index = Base})

	function self:SetText(t)
		btn.Text = tostring(t or "")
	end

	function self:SetCallback(fn)
		self.Callback = fn
	end

	function self:SetVisible(v)
		row.Visible = v and true or false
	end
	
	-- Instant color updates
	function self:SetBackgroundColor(color, animate)
		if animate == false then
			btn.BackgroundColor3 = color
		elseif animate == true then
			Util.Tween(btn, {BackgroundColor3 = color}, 0.15)
		else
			btn.BackgroundColor3 = color
		end
	end
	
	function self:SetTextColor(color, animate)
		if animate == false then
			btn.TextColor3 = color
		elseif animate == true then
			Util.Tween(btn, {TextColor3 = color}, 0.15)
		else
			btn.TextColor3 = color
		end
	end
	
	function self:SetBorderColor(color, animate)
		local stroke = btn:FindFirstChild("UIStroke")
		if stroke then
			if animate == false then
				stroke.Color = color
			elseif animate == true then
				Util.Tween(stroke, {Color = color}, 0.15)
			else
				stroke.Color = color
			end
		end
	end
	
	function self:RefreshTheme()
		-- Get current theme from library
		local currentTheme = self._theme
		if _G.FiendInstance and _G.FiendInstance.Theme then
			currentTheme = _G.FiendInstance.Theme
		end
		
		if currentTheme then
			-- Update button colors
			self:SetBackgroundColor(currentTheme.Background2 or currentTheme.Background or Color3.fromRGB(18,20,25), false)
			self:SetTextColor(currentTheme.Foreground or currentTheme.TextColor, false)
			self:SetBorderColor(currentTheme.Border, false)
			
			-- Update button border thickness
			local stroke = btn:FindFirstChild("UIStroke")
			if stroke then
				stroke.Thickness = currentTheme.LineThickness or 1
			end
			
			-- Update corner radius
			local corner = btn:FindFirstChild("UICorner")
			if corner then
				corner.CornerRadius = currentTheme.Corner or UDim.new(0, 6)
			end
			
			-- Update font
			btn.Font = currentTheme.Font or Enum.Font.Gotham
			
			-- Update stored theme reference
			self._theme = currentTheme
		end
	end
	

	function self:Destroy()
		if row then row:Destroy() end
	end

	return self
end

return Button

]]
Modules['components/button'] = Modules['components/button.lua']
Modules['button'] = Modules['components/button.lua']

-- Module: components/toggle.lua
Modules['components/toggle.lua'] = [[
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
	local function getCurrentTheme()
		if _G.FiendInstance and _G.FiendInstance.Theme then
			return _G.FiendInstance.Theme
		end
		return theme
	end
	
	local function apply(v, animate)
		on = v and true or false
		local x = on and (56 - 24) or 2
		local currentTheme = getCurrentTheme()
		local trackColor = on and (currentTheme.AccentDim or currentTheme.Accent) or (currentTheme.Background2 or currentTheme.Background)
		
		if animate then
			Util.Tween(knob, { Position = UDim2.new(0, x, 0, 2) }, 0.12)
			Util.Tween(track, { BackgroundColor3 = trackColor }, 0.12)
		else
			knob.Position = UDim2.new(0, x, 0, 2)
			track.BackgroundColor3 = trackColor
		end
	end
	apply(on, false)
	
	-- Create a variable to store the apply function reference
	local applyRef = apply
	
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			applyRef(not on, true)
			if typeof(callback) == "function" then task.spawn(callback, on) end
		end
	end)

	local self = Base.new({ Name = "Toggle", Text = text or "", Callback = callback, Theme = theme })
	self.Root = row
	self._track = track
	self._knob = knob
	self._label = label
	self._theme = theme
	self._on = on  -- Store toggle state in self for RefreshTheme access
	
	-- Update apply function to also update self._on
	local originalApply = applyRef
	applyRef = function(v, animate)
		originalApply(v, animate)
		self._on = on  -- Update stored state
	end
	
	-- Ensure BaseElement methods are available
	setmetatable(self, {__index = Base})
	
	function self:SetValue(v, fire, animate) 
		applyRef(v, animate ~= false); 
		if fire and callback then task.spawn(callback, self._on) end 
	end
	function self:GetValue() return self._on end
	function self:SetText(t) label.Text = tostring(t or "") end
	function self:SetVisible(v) row.Visible = v and true or false end
	
	-- Instant color updates
	function self:SetTrackColor(color, animate)
		if animate == false then
			track.BackgroundColor3 = color
		elseif animate == true then
			Util.Tween(track, {BackgroundColor3 = color}, 0.12)
		else
			track.BackgroundColor3 = color
		end
	end
	
	function self:SetKnobColor(color, animate)
		if animate == false then
			knob.BackgroundColor3 = color
		elseif animate == true then
			Util.Tween(knob, {BackgroundColor3 = color}, 0.12)
		else
			knob.BackgroundColor3 = color
		end
	end
	
	function self:SetTextColor(color, animate)
		if animate == false then
			label.TextColor3 = color
		elseif animate == true then
			Util.Tween(label, {TextColor3 = color}, 0.12)
		else
			label.TextColor3 = color
		end
	end
	
	function self:RefreshTheme()
		-- Get current theme from library
		local currentTheme = self._theme
		if _G.FiendInstance and _G.FiendInstance.Theme then
			currentTheme = _G.FiendInstance.Theme
		end
		
		if currentTheme then
			-- Update track colors
			self:SetTrackColor(self._on and (currentTheme.AccentDim or currentTheme.Accent) or (currentTheme.Background2 or currentTheme.Background), false)
			self:SetKnobColor(currentTheme.Accent, false)
			self:SetTextColor(currentTheme.Foreground or currentTheme.TextColor, false)
			
			-- Update track border
			local trackStroke = track:FindFirstChild("UIStroke")
			if trackStroke then
				trackStroke.Color = currentTheme.Border
				trackStroke.Thickness = currentTheme.LineThickness or 1
			end
			
			-- Update corner radius
			local trackCorner = track:FindFirstChild("UICorner")
			if trackCorner then
				trackCorner.CornerRadius = currentTheme.Corner or UDim.new(0, 6)
			end
			
			local knobCorner = knob:FindFirstChild("UICorner")
			if knobCorner then
				knobCorner.CornerRadius = currentTheme.Corner or UDim.new(0, 6)
			end
			
			-- Update stored theme reference
			self._theme = currentTheme
		end
	end
	
	function self:Destroy() if row then row:Destroy() end end
	
	-- Apply initial theme
	self:RefreshTheme()
	
	-- Auto-register with Fiend for theme tracking
	if _G.FiendInstance and _G.FiendInstance._trackElement then
		_G.FiendInstance:_trackElement(self)
	end

	return self
end

return Toggle

]]
Modules['components/toggle'] = Modules['components/toggle.lua']
Modules['toggle'] = Modules['components/toggle.lua']

-- Module: components/slider.lua
Modules['components/slider.lua'] = [[
-- Fiend/components/slider.lua

local UIS    = game:GetService("UserInputService")
local Util   = require(script.Parent.Parent.lib.util)
local Theme  = require(script.Parent.Parent.lib.theme)
local BaseElement = require(script.Parent.Parent.lib.base_element)

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

	-- Create the slider instance
	local self = setmetatable({
		Root = row,
		_theme = theme,
		_label = label,
		_valueLbl = valueLbl,
		_bar = bar,
		_fill = fill,
		_min = min,
		_max = max,
		_current = current,
		_callback = callback,
		_set = set
	}, Slider)
	
	-- Inherit from BaseElement
	setmetatable(self, {__index = BaseElement})
	
	-- Initialize BaseElement
	BaseElement.new(self, {
		Theme = theme,
		Root = row
	})
	
	-- Refresh theme for this slider
	function self:RefreshTheme()
	-- Get current theme from library
	local currentTheme = self._theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		currentTheme = _G.FiendInstance.Theme
	end
	
	print("[Slider] RefreshTheme called - Theme:", currentTheme and "Available" or "Missing")
	if currentTheme then
		print("[Slider] Accent color:", currentTheme.Accent)
		print("[Slider] SubTextColor:", currentTheme.SubTextColor)
	end
	
	if currentTheme then
		-- Update label
		if self._label then
			self._label.TextColor3 = currentTheme.Foreground or currentTheme.TextColor
			self._label.Font = currentTheme.Font or Enum.Font.Gotham
		end
		
		-- Update value label
		if self._valueLbl then
			local valueColor = currentTheme.SubTextColor or currentTheme.TextColor or currentTheme.Foreground or Color3.fromRGB(170, 174, 182)
			self._valueLbl.TextColor3 = valueColor
			self._valueLbl.Font = currentTheme.FontMono or currentTheme.Font or Enum.Font.Code
			print("[Slider] Updated value text color to:", valueColor)
		end
		
		-- Update bar
		if self._bar then
			self._bar.BackgroundColor3 = currentTheme.Background2 or currentTheme.Background
			
			-- Update bar border
			local stroke = self._bar:FindFirstChild("UIStroke")
			if stroke then
				stroke.Color = currentTheme.Border
				stroke.Thickness = currentTheme.LineThickness or 1
			end
			
			-- Update bar corner radius
			local corner = self._bar:FindFirstChild("UICorner")
			if corner then
				corner.CornerRadius = currentTheme.Corner or UDim.new(0, 8)
			end
		end
		
		-- Update fill
		if self._fill then
			local fillColor = currentTheme.Accent or currentTheme.AccentDim or currentTheme.TextColor or currentTheme.Foreground or Color3.fromRGB(220, 220, 224)
			self._fill.BackgroundColor3 = fillColor
			print("[Slider] Updated fill color to:", fillColor)
			
			-- Update fill corner radius
			local corner = self._fill:FindFirstChild("UICorner")
			if corner then
				corner.CornerRadius = currentTheme.Corner or UDim.new(0, 8)
			end
		end
		
		-- Update stored theme reference
		self._theme = currentTheme
	end
	end
	
	-- Auto-register with Fiend for theme tracking
	if _G.FiendInstance and _G.FiendInstance._trackElement then
		_G.FiendInstance:_trackElement(self)
	end
	
	return self
end

-- Get current value
function Slider:Get()
	return self._current
end

-- Set value
function Slider:Set(value, fire)
	if self._set then
		self._set(value, fire)
	end
end

return Slider

]]
Modules['components/slider'] = Modules['components/slider.lua']
Modules['slider'] = Modules['components/slider.lua']

-- Module: components/dropdown.lua
Modules['components/dropdown.lua'] = [[
-- Fiend/components/dropdown.lua
-- Dropdown row: full-width button opens a popover list on the float layer.

local UserInputService = game:GetService("UserInputService")

local Util    = require(script.Parent.Parent.lib.util)
local Theme   = require(script.Parent.Parent.lib.theme)
local Safety  = require(script.Parent.Parent.lib.safety)
local BaseElement = require(script.Parent.Parent.lib.base_element)

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
		Size = UDim2.fromOffset(math.max(220, anchorBtn.AbsoluteSize.X), math.min(300, (#items * 28) + p * 2 + (6 * math.max(0, #items - 1)))),
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
		CanvasSize = UDim2.new(0, 0, 0, (#items * 28) + (6 * math.max(0, #items - 1))),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
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
		-- Get current theme from library
		local currentTheme = theme
		if _G.FiendInstance and _G.FiendInstance.Theme then
			currentTheme = _G.FiendInstance.Theme
		end
		
		-- open popover with current theme
		buildPopover(currentTheme, btn, list, function(picked)
			setValue(picked, true)
		end)
	end)

	-- Hover effect

	-- Create the dropdown instance
	local self = setmetatable({
		Root = row,
		_theme = theme,
		_btn = btn,
		_value = value,
		_list = list,
		_callback = callback,
		_setValue = setValue
	}, Dropdown)
	
	
	-- Inherit from BaseElement
	setmetatable(self, {__index = BaseElement})
	
	-- Initialize BaseElement
	BaseElement.new(self, {
		Theme = theme,
		Root = row
	})
	
	-- Refresh theme for this dropdown
	function self:RefreshTheme()
	-- Get current theme from library
	local currentTheme = self._theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		currentTheme = _G.FiendInstance.Theme
	end
	
	if currentTheme then
		-- Update button
		if self._btn then
			self._btn.TextColor3 = currentTheme.Foreground or currentTheme.TextColor
			self._btn.Font = currentTheme.Font or Enum.Font.Gotham
			-- Update background
			self._btn.BackgroundColor3 = currentTheme.Background2 or currentTheme.Background or Color3.fromRGB(18,20,25)
			
			-- Update button border
			local stroke = self._btn:FindFirstChild("UIStroke")
			if stroke then
				stroke.Color = currentTheme.Border
				stroke.Thickness = currentTheme.LineThickness or 1
			end
			
			-- Update button corner radius
			local corner = self._btn:FindFirstChild("UICorner")
			if corner then
				corner.CornerRadius = currentTheme.Corner or UDim.new(0, 8)
			end
		end
		
		-- Update stored theme reference
		self._theme = currentTheme
	end
	end
	
	-- Apply initial theme
	self:RefreshTheme()
	
	-- Auto-register with Fiend for theme tracking
	if _G.FiendInstance and _G.FiendInstance._trackElement then
		_G.FiendInstance:_trackElement(self)
	end
	
	return self
end

-- Get current value
function Dropdown:Get()
	return self._value
end

-- Set list
function Dropdown:SetList(newList)
	self._list = newList or {}
end

return Dropdown

]]
Modules['components/dropdown'] = Modules['components/dropdown.lua']
Modules['dropdown'] = Modules['components/dropdown.lua']

-- Module: components/textinput.lua
Modules['components/textinput.lua'] = [[
-- Fiend/components/textinput.lua
-- Text input component with retro wireframe styling

local Util = require(script.Parent.Parent.lib.util)
local Theme = require(script.Parent.Parent.lib.theme)
local Tween = require(script.Parent.Parent.lib.tween)

local TextInput = {}
TextInput.__index = TextInput

function TextInput.new(tabOrGroup, labelText, placeholderText, defaultValue, callback)
    local self = setmetatable({}, TextInput)
    
    self.Tab = tabOrGroup
    self.LabelText = labelText or "Text Input"
    self.PlaceholderText = placeholderText or "Enter text..."
    self.Value = defaultValue or ""
    self.Callback = callback
    self.Theme = tabOrGroup.Theme or Theme
    
    -- Auto-register with Fiend if available
    if _G.FiendInstance and _G.FiendInstance._trackElement then
        _G.FiendInstance:_trackElement(self)
    end
    
    self._frame = nil
    self._textBox = nil
    self._label = nil
    self._isFocused = false
    
    self:_createUI()
    self:_setupEvents()
    
    return self
end

function TextInput:_createUI()
    local theme = self.Theme
    local p = theme.Padding or 6
    
    -- Row container (like button component)
    local row = Instance.new("Frame")
    row.Name = "TextInputRow"
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, 0, 0, 36)
    row.Parent = self.Tab.Content or self.Tab.Container
    
    -- Main container frame (with proper padding like button)
    self._frame = Instance.new("Frame")
    self._frame.Name = "TextInput_" .. self.LabelText:gsub("%s+", "_")
    self._frame.BackgroundColor3 = theme.Background2
    self._frame.BackgroundTransparency = 0.15
    self._frame.Size = UDim2.new(1, -(p * 2), 1, 0)
    self._frame.Position = UDim2.new(0, p, 0, 0)
    self._frame.ZIndex = 2
    self._frame.Parent = row
    
    -- Use Util functions for consistent styling
    Util:Roundify(self._frame, UDim.new(0, theme.Rounding))
    Util:Stroke(self._frame, theme.Border, theme.LineThickness, 0.3)
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, theme.Padding)
    padding.PaddingBottom = UDim.new(0, theme.Padding)
    padding.PaddingLeft = UDim.new(0, theme.Padding)
    padding.PaddingRight = UDim.new(0, theme.Padding)
    padding.Parent = self._frame
    
    -- Label
    self._label = Instance.new("TextLabel")
    self._label.Name = "Label"
    self._label.Size = UDim2.new(1, -100, 1, 0)
    self._label.Position = UDim2.new(0, 0, 0, 0)
    self._label.BackgroundTransparency = 1
    self._label.Text = self.LabelText
    self._label.Font = theme.Font
    self._label.TextSize = 14
    self._label.TextColor3 = theme.TextColor
    self._label.TextXAlignment = Enum.TextXAlignment.Left
    self._label.TextYAlignment = Enum.TextYAlignment.Center
    self._label.Parent = self._frame
    
    -- Text input box
    self._textBox = Instance.new("TextBox")
    self._textBox.Name = "TextBox"
    self._textBox.Size = UDim2.new(0, 80, 0, 22)
    self._textBox.Position = UDim2.new(1, -85, 0.5, -11)
    self._textBox.BackgroundColor3 = theme.Background
    self._textBox.BackgroundTransparency = 0
    self._textBox.BorderSizePixel = 0
    self._textBox.Font = theme.Font
    self._textBox.TextSize = 12
    self._textBox.TextColor3 = theme.TextColor
    self._textBox.PlaceholderText = self.PlaceholderText
    self._textBox.PlaceholderColor3 = theme.SubTextColor
    self._textBox.Text = self.Value
    self._textBox.TextXAlignment = Enum.TextXAlignment.Left
    self._textBox.TextYAlignment = Enum.TextYAlignment.Center
    self._textBox.ClearTextOnFocus = false
    self._textBox.Parent = self._frame
    
    -- Use Util functions for consistent styling
    Util:Roundify(self._textBox, UDim.new(0, 4))
    Util:Stroke(self._textBox, theme.Border, 1, 0.5)
    
    -- Text box padding
    local textBoxPadding = Instance.new("UIPadding")
    textBoxPadding.PaddingLeft = UDim.new(0, 6)
    textBoxPadding.PaddingRight = UDim.new(0, 6)
    textBoxPadding.Parent = self._textBox
    
    -- Refresh theme for this text input
    function self:RefreshTheme()
        -- Get current theme from library
        local currentTheme = self.Theme
        if _G.FiendInstance and _G.FiendInstance.Theme then
            currentTheme = _G.FiendInstance.Theme
        end
        
        if currentTheme then
            -- Update text box colors
            self:SetBackgroundColor(currentTheme.Background, false)
            self:SetTextColor(currentTheme.TextColor, false)
            self:SetPlaceholderColor(currentTheme.SubTextColor, false)
            self:SetBorderColor(currentTheme.Border, false)
            
            -- Update text box border thickness
            local stroke = self._textBox:FindFirstChild("UIStroke")
            if stroke then
                stroke.Thickness = currentTheme.LineThickness or 1
            end
            
            -- Update text box corner radius
            local corner = self._textBox:FindFirstChild("UICorner")
            if corner then
                corner.CornerRadius = currentTheme.Corner or UDim.new(0, 4)
            end
            
            -- Update label colors
            if self._label then
                self._label.TextColor3 = currentTheme.TextColor
                self._label.Font = currentTheme.Font
            end
            
            -- Update frame background
            if self._frame then
                self._frame.BackgroundColor3 = currentTheme.Background2 or currentTheme.Background
                
                -- Update frame border
                local frameStroke = self._frame:FindFirstChild("UIStroke")
                if frameStroke then
                    frameStroke.Color = currentTheme.Border
                    frameStroke.Thickness = currentTheme.LineThickness or 1
                end
                
                -- Update frame corner radius
                local frameCorner = self._frame:FindFirstChild("UICorner")
                if frameCorner then
                    frameCorner.CornerRadius = currentTheme.Corner or UDim.new(0, 8)
                end
            end
            
            -- Update stored theme reference
            self.Theme = currentTheme
        end
    end
    
    -- Apply initial theme
    self:RefreshTheme()
end

function TextInput:_setupEvents()
    -- Focus events
    self._textBox.Focused:Connect(function()
        self._isFocused = true
        self:_onFocusChanged(true)
    end)
    
    self._textBox.FocusLost:Connect(function()
        self._isFocused = false
        self:_onFocusChanged(false)
    end)
    
    -- Text changed event
    self._textBox:GetPropertyChangedSignal("Text"):Connect(function()
        self.Value = self._textBox.Text
        if self.Callback then
            self.Callback(self.Value)
        end
    end)
end

function TextInput:_onFocusChanged(focused)
    local theme = self.Theme
    
    if focused then
        -- Focused state - brighter border
        Tween(self._textBox.UIStroke, {Color = theme.Accent, Transparency = 0}, 0.15)
        Tween(self._textBox, {BackgroundColor3 = theme.Background2}, 0.15)
    else
        -- Unfocused state - dimmer border
        Tween(self._textBox.UIStroke, {Color = theme.Border, Transparency = 0.5}, 0.15)
        Tween(self._textBox, {BackgroundColor3 = theme.Background}, 0.15)
    end
end

-- Public methods
function TextInput:SetValue(value)
    self.Value = value or ""
    self._textBox.Text = self.Value
end

function TextInput:GetValue()
    return self.Value
end

function TextInput:SetPlaceholder(text)
    self.PlaceholderText = text or ""
    self._textBox.PlaceholderText = self.PlaceholderText
end

function TextInput:SetCallback(callback)
    self.Callback = callback
end

function TextInput:SetEnabled(enabled)
    self._textBox.TextEditable = enabled
    self._textBox.Active = enabled
end

function TextInput:Focus()
    self._textBox:CaptureFocus()
end

-- Instant color updates
function TextInput:SetBackgroundColor(color, animate)
    if animate == false then
        self._textBox.BackgroundColor3 = color
    elseif animate == true then
        Tween(self._textBox, {BackgroundColor3 = color}, 0.15)
    else
        self._textBox.BackgroundColor3 = color
    end
end

function TextInput:SetTextColor(color, animate)
    if animate == false then
        self._textBox.TextColor3 = color
    elseif animate == true then
        Tween(self._textBox, {TextColor3 = color}, 0.15)
    else
        self._textBox.TextColor3 = color
    end
end

function TextInput:SetPlaceholderColor(color, animate)
    if animate == false then
        self._textBox.PlaceholderColor3 = color
    elseif animate == true then
        Tween(self._textBox, {PlaceholderColor3 = color}, 0.15)
    else
        self._textBox.PlaceholderColor3 = color
    end
end

function TextInput:SetBorderColor(color, animate)
    local stroke = self._textBox:FindFirstChild("UIStroke")
    if stroke then
        if animate == false then
            stroke.Color = color
        elseif animate == true then
            Tween(stroke, {Color = color}, 0.15)
        else
            stroke.Color = color
        end
    end
end


-- Add BaseElement-compatible methods
function TextInput:UpdateProperty(property, value, animate)
    if not self._textBox then return end
    
    if animate == false then
        -- Instant update
        self._textBox[property] = value
    elseif animate == true then
        -- Animated update using default tween
        Tween(self._textBox, {[property] = value}, 0.15)
    else
        -- Default behavior - instant update
        self._textBox[property] = value
    end
end

function TextInput:UpdateProperties(properties, animate)
    if not self._textBox then return end
    
    if animate == false then
        -- Instant update
        for property, value in pairs(properties) do
            self._textBox[property] = value
        end
    elseif animate == true then
        -- Animated update using default tween
        Tween(self._textBox, properties, 0.15)
    else
        -- Default behavior - instant update
        for property, value in pairs(properties) do
            self._textBox[property] = value
        end
    end
end

function TextInput:Destroy()
    if self._frame then
        self._frame:Destroy()
        self._frame = nil
    end
end

return TextInput

]]
Modules['components/textinput'] = Modules['components/textinput.lua']
Modules['textinput'] = Modules['components/textinput.lua']

-- Module: components/group.lua
Modules['components/group.lua'] = [[
-- Fiend/components/group.lua
-- Group component for organizing elements within tabs
-- Supports automatic space division based on number of groups

local Util = require(script.Parent.Parent.lib.util)
local Theme = require(script.Parent.Parent.lib.theme)
local BaseElement = require(script.Parent.Parent.lib.base_element)

local Group = {}
Group.__index = Group

export type GroupOptions = {
    Name: string,
    Size: Vector2?, -- {width, height} in grid units (1 = full width/height)
    Position: Vector2?, -- {x, y} grid position
    Theme: any?
}

function Group.new(tab, options: GroupOptions | string)
    -- Handle both new options format and legacy string format
    local opts: GroupOptions
    if typeof(options) == "string" then
        -- Legacy format: Group.new(tab, "Group Name")
        opts = {
            Name = options,
            Size = Vector2.new(1, 1), -- Default to full size
            Position = Vector2.new(0, 0) -- Default to top-left
        }
    else
        -- New format: Group.new(tab, options)
        opts = options or {}
        opts.Name = opts.Name or "Group"
        opts.Size = opts.Size or Vector2.new(1, 1)
        opts.Position = opts.Position or Vector2.new(0, 0)
    end
    
    local theme = opts.Theme or tab.Theme or Theme
    
    -- Create group container
    local groupFrame = Util.Create("Frame", {
        Name = "Group_" .. opts.Name,
        Parent = tab.Container,
        BackgroundColor3 = theme.Background2 or Color3.fromRGB(14, 14, 18),
        BackgroundTransparency = 1, -- Completely transparent
        BorderSizePixel = 0,
        Size = UDim2.new(opts.Size.X, 0, opts.Size.Y, 0),
        Position = UDim2.new(opts.Position.X, 0, opts.Position.Y, 0),
        ZIndex = 2
    })
    
    -- Add rounded corners and border
    Util.CreateUICorner(groupFrame, theme.Corner or UDim.new(0, 6))
    Util.CreateUIStroke(groupFrame, theme.Border or Color3.fromRGB(96, 98, 104), 1, 0.6)
    
    -- Add padding
    Util.CreateUIPadding(groupFrame, theme.Pad or UDim.new(0, 8))
    
    -- Create group header
    local header = Util.Create("Frame", {
        Name = "Header",
        Parent = groupFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        ZIndex = 3
    })
    
    -- Group title
    local title = Util.Create("TextLabel", {
        Name = "Title",
        Parent = header,
        BackgroundTransparency = 1,
        Text = opts.Name,
        Font = theme.FontMono or Enum.Font.Code,
        TextSize = 14,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 230, 232),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 4
    })
    
    -- Create content area
    local content = Util.Create("Frame", {
        Name = "Content",
        Parent = groupFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -24),
        Position = UDim2.new(0, 0, 0, 24),
        ZIndex = 3
    })
    
    -- Add vertical list layout for elements
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = content
    
    -- Create the group instance
    local self = setmetatable({
        Instance = groupFrame,
        Root = groupFrame,
        Tab = tab,
        Name = opts.Name,
        Content = content,
        Header = header,
        Title = title,
        Theme = theme,
        Size = opts.Size,
        Position = opts.Position,
        Elements = {}
    }, Group)
    
    -- Inherit from BaseElement (preserve Group methods)
    local groupMetatable = {__index = Group}
    local baseMetatable = {__index = BaseElement}
    setmetatable(self, groupMetatable)
    setmetatable(Group, baseMetatable)
    
    -- Initialize BaseElement
    BaseElement.new(self, {
        Theme = theme,
        Root = groupFrame
    })
    
    -- Auto-register with Fiend for theme tracking
    if _G.FiendInstance and _G.FiendInstance._trackElement then
        _G.FiendInstance:_trackElement(self)
    end
    
    -- Note: Group is added to tab.Groups by the tab's AddGroup method
    -- This prevents double-addition and ensures proper initialization order
    
    return self
end

-- Refresh theme for this group
function Group:RefreshTheme()
    -- Get current theme from library
    local currentTheme = self.Theme
    if _G.FiendInstance and _G.FiendInstance.Theme then
        currentTheme = _G.FiendInstance.Theme
    end
    
    if currentTheme then
        -- Update group frame
        if self.Root then
            self.Root.BackgroundColor3 = currentTheme.Background2 or currentTheme.Background
            
            -- Update border
            local stroke = self.Root:FindFirstChild("UIStroke")
            if stroke then
                stroke.Color = currentTheme.Border
                stroke.Thickness = currentTheme.LineThickness or 1
            end
            
            -- Update corner radius
            local corner = self.Root:FindFirstChild("UICorner")
            if corner then
                corner.CornerRadius = currentTheme.Corner or UDim.new(0, 6)
            end
        end
        
        -- Update title
        if self.Title then
            self.Title.TextColor3 = currentTheme.Foreground or currentTheme.TextColor
            self.Title.Font = currentTheme.FontMono or Enum.Font.Code
        end
        
        -- Update stored theme reference
        self.Theme = currentTheme
        
        -- Refresh all child elements
        for _, element in ipairs(self.Elements) do
            if element.RefreshTheme then
                element:RefreshTheme()
            end
        end
    end
end

-- Add elements to the group
function Group:AddButton(text, callback)
    local Button = require(script.Parent.button)
    local button = Button.new(self, text, callback)
    table.insert(self.Elements, button)
    return button
end

function Group:AddToggle(text, default, callback)
    local Toggle = require(script.Parent.toggle)
    local toggle = Toggle.new(self, text, default, callback)
    table.insert(self.Elements, toggle)
    return toggle
end

function Group:AddSlider(text, min, max, default, callback)
    local Slider = require(script.Parent.slider)
    local slider = Slider.new(self, text, min, max, default, callback)
    table.insert(self.Elements, slider)
    return slider
end

function Group:AddDropdown(label, list, default, callback)
    local Dropdown = require(script.Parent.dropdown)
    local dropdown = Dropdown.new(self, label, list, default, callback)
    table.insert(self.Elements, dropdown)
    return dropdown
end

function Group:AddTextInput(label, placeholder, default, callback)
    local TextInput = require(script.Parent.textinput)
    local textInput = TextInput.new(self, label, placeholder, default, callback)
    table.insert(self.Elements, textInput)
    return textInput
end

function Group:AddKeybind(label, keyCode, callback)
    local Keybind = require(script.Parent.keybind)
    local keybind = Keybind.new(self, {
        Label = label,
        DefaultKey = keyCode,
        DefaultMode = "Hold",
        Callback = callback,
        Enabled = true
    })
    table.insert(self.Elements, keybind)
    return keybind
end

-- Set group size and position
function Group:SetSize(size: Vector2)
	self.Size = size
	self.Instance.Size = UDim2.new(size.X, 0, size.Y, 0)
	self.Tab:_updateGroupLayout()
end

function Group:SetPosition(position: Vector2)
	self.Position = position
	self.Instance.Position = UDim2.new(position.X, 0, position.Y, 0)
	self.Tab:_updateGroupLayout()
end

-- Internal methods that don't trigger layout updates
function Group:_setSizeInternal(size: Vector2)
	self.Size = size
	self.Instance.Size = UDim2.new(size.X, 0, size.Y, 0)
end

function Group:_setPositionInternal(position: Vector2)
	self.Position = position
	self.Instance.Position = UDim2.new(position.X, 0, position.Y, 0)
end

-- Set group title
function Group:SetTitle(title: string)
    self.Name = title
    self.Title.Text = title
end

-- Show/hide group
function Group:SetVisible(visible: boolean)
    self.Instance.Visible = visible
end

-- Get group info
function Group:GetSize(): Vector2
    return self.Size
end

function Group:GetPosition(): Vector2
    return self.Position
end

function Group:GetElements()
    return self.Elements
end

-- Destroy group
function Group:Destroy()
    -- Remove from tab's group list
    if self.Tab and self.Tab.Groups then
        for i, group in ipairs(self.Tab.Groups) do
            if group == self then
                table.remove(self.Tab.Groups, i)
                break
            end
        end
    end
    
    -- Destroy all elements
    for _, element in ipairs(self.Elements) do
        if element.Destroy then
            element:Destroy()
        elseif element.Instance then
            element.Instance:Destroy()
        end
    end
    
    -- Destroy the group frame
    if self.Instance then
        self.Instance:Destroy()
    end
end

return Group

]]
Modules['components/group'] = Modules['components/group.lua']
Modules['group'] = Modules['components/group.lua']

-- Module: components/tab.lua
Modules['components/tab.lua'] = [[
-- Fiend/components/tab.lua
-- Pill tabs (top bar) + vertical scrolling content.

local Util     = require(script.Parent.Parent.lib.util)
local Button   = require(script.Parent.button)
local Toggle   = require(script.Parent.toggle)
local Slider   = require(script.Parent.slider)
local Dropdown = require(script.Parent.dropdown)
local TextInput = require(script.Parent.textinput)
local Notify    = require(script.Parent.notify)
local Group     = require(script.Parent.group)

local Tab = {}
Tab.__index = Tab

function Tab.new(window, name, icon)
	local self = setmetatable({}, Tab)
	self.Window    = window
	self.Name      = name
	self.Icon      = icon or ""
	self.Container = nil
	self.Groups    = {} -- Array of groups
	self.DefaultGroup = nil -- Default group for elements not assigned to specific groups

	local theme = window.Theme
	local bar   = window.TabsBar
	local pillH = (theme.Tab and theme.Tab.PillHeight or 22)
	local upper = (theme.Tab and theme.Tab.Uppercase) and string.upper(self.Name) or self.Name

	-- top pill
	local btn = Util.Create("TextButton", {
		Name = "Tab_"..upper,
		Parent = bar,
		Text = (self.Icon ~= "" and (self.Icon.." ") or "") .. upper,
		Font = theme.FontMono or Enum.Font.Code,
		TextSize = 14,
		TextColor3 = (theme.Tab and theme.Tab.IdleText) or theme.SubTextColor,
		AutoButtonColor = false,
		BackgroundColor3 = (theme.Tab and theme.Tab.IdleFill) or theme.Background2,
		BorderSizePixel = 0,
		Size = UDim2.new(0, math.max(70, upper:len()*7 + 24), 0, pillH),
		ZIndex = 4,
	})
	Util:Roundify(btn, theme.Corner)
	local stroke = Util:Stroke(btn, (theme.Tab and theme.Tab.Border) or theme.Border, theme.LineThickness)

	-- content
	local sc = Instance.new("ScrollingFrame")
	sc.Name = "TabContainer_"..self.Name
	sc.Parent = window.Container
	sc.BackgroundTransparency = 1
	sc.BorderSizePixel = 0
	sc.Size = UDim2.new(1, 0, 1, 0)
	sc.Visible = false
	sc.ScrollingDirection = Enum.ScrollingDirection.Y
	sc.ScrollBarThickness = 4
	sc.AutomaticCanvasSize = Enum.AutomaticSize.None -- Changed from Y to None for groups
	sc.CanvasSize = UDim2.new(1, 0, 1, 0) -- Fixed canvas size for groups
	sc.ClipsDescendants = true
	sc.ZIndex = 3

	local paddingPx = theme.Padding or 6
	local pad = Instance.new("UIPadding")
	pad.PaddingTop    = UDim.new(0, paddingPx)
	pad.PaddingBottom = UDim.new(0, paddingPx)
	pad.PaddingLeft   = UDim.new(0, paddingPx)
	pad.PaddingRight  = UDim.new(0, paddingPx)
	pad.Parent = sc

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Left
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = sc

	self.Container = sc
	self.ListLayout = list -- Store reference to list layout
	self.Icon      = icon or ""
	
	-- Add resize listener to update group layout when window resizes
	local resizeConnection
	resizeConnection = sc:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if #self.Groups > 0 then
			self:_updateGroupLayout()
		end
	end)
	
	-- Store connection for cleanup
	self._resizeConnection = resizeConnection

	local function setActive(active)
		if active then
			btn.TextColor3 = (theme.Tab and theme.Tab.ActiveText) or theme.TextColor
			btn.BackgroundColor3 = (theme.Tab and theme.Tab.ActiveFill) or theme.Background
			if stroke then stroke.Color = theme.Accent end
		else
			btn.TextColor3 = (theme.Tab and theme.Tab.IdleText) or theme.SubTextColor
			btn.BackgroundColor3 = (theme.Tab and theme.Tab.IdleFill) or theme.Background2
			if stroke then stroke.Color = theme.Border end
		end
	end

	btn.MouseEnter:Connect(function()
		if sc.Visible then return end
		Util.Tween(btn, { BackgroundColor3 = theme.Background }, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		if sc.Visible then return end
		Util.Tween(btn, { BackgroundColor3 = (theme.Tab and theme.Tab.IdleFill) or theme.Background2 }, 0.12)
	end)
	btn.MouseButton1Click:Connect(function()
		window:ShowTab(self.Name)
	end)

	function self:Show() sc.Visible = true; setActive(true) end
	function self:Hide() sc.Visible = false; setActive(false) end

	-- helpers
	function self:AddButton(text, callback)              return Button.new(self, text, callback) end
	function self:AddToggle(text, default, callback)     return Toggle.new(self, text, default, callback) end
	function self:AddSlider(text, min, max, default, cb) return Slider.new(self, text, min, max, default, cb) end
	function self:AddDropdown(label, list, def, cb)      return Dropdown.new(self, label, list, def, cb) end
	function self:AddTextInput(label, placeholder, default, callback) return TextInput.new(self, label, placeholder, default, callback) end
	function self:AddKeybind(label, keyCode, callback)    
		local Keybind = require(script.Parent.keybind)
		return Keybind.new(self, {
			Label = label,
			DefaultKey = keyCode,
			DefaultMode = "Hold",
			Callback = callback,
			Enabled = true
		})
	end
	
	function self:AddNotify(message, type)
		-- Create a simple notification that works with our tab structure
		local notify = Notify.new(self.Window.Theme)
		notify:AttachTo(self.Window.Root)
		notify:Push(message, 3)
		return notify
	end

	-- Group management methods
	function self:AddGroup(options)
		local group = Group.new(self, options)
		
		-- Add group to tab's group list
		if not self.Groups then
			self.Groups = {}
		end
		table.insert(self.Groups, group)
		
		-- If this is the first group, make it the default
		if #self.Groups == 1 then
			self.DefaultGroup = group
			-- Disable automatic sizing and list layout for groups
			self.Container.AutomaticCanvasSize = Enum.AutomaticSize.None
			self.Container.CanvasSize = UDim2.new(1, 0, 1, 0)
			-- Remove the list layout when using groups
			if self.ListLayout then
				self.ListLayout.Parent = nil
			end
		end
		
		-- Update layout immediately (scale-based positioning works right away)
		self:_updateGroupLayout()
		
		return group
	end
	
	function self:GetGroup(name)
		for _, group in ipairs(self.Groups) do
			if group.Name == name then
				return group
			end
		end
		return nil
	end
	
	function self:GetDefaultGroup()
		return self.DefaultGroup
	end
	
	-- Space division logic
	function self:_updateGroupLayout()
		local groupCount = #self.Groups
		if groupCount == 0 then return end
		
		-- Calculate grid layout based on number of groups
		local cols, rows = self:_calculateGridLayout(groupCount)
		
		-- Calculate cell size as scale (0-1)
		local cellWidth = 1 / cols
		local cellHeight = 1 / rows
		
		-- Debug logging
		print(string.format("[Group Layout] Groups: %d, Grid: %dx%d, Cell Scale: %.2fx%.2f", 
			groupCount, cols, rows, cellWidth, cellHeight))
		
		-- Position groups in grid using scale-based positioning
		for i, group in ipairs(self.Groups) do
			local col = (i - 1) % cols
			local row = math.floor((i - 1) / cols)
			
			-- Calculate position as scale (0-1)
			local x = col * cellWidth
			local y = row * cellHeight
			
			-- Debug logging
			print(string.format("[Group Layout] Group %d: col=%d, row=%d, pos=(%.2f,%.2f), size=(%.2f,%.2f)", 
				i, col, row, x, y, cellWidth, cellHeight))
			
			-- Set size and position using scale values
			group:_setSizeInternal(Vector2.new(cellWidth, cellHeight))
			group:_setPositionInternal(Vector2.new(x, y))
		end
	end
	
	function self:_calculateGridLayout(count)
		-- Determine optimal grid layout based on count
		if count == 1 then
			return 1, 1
		elseif count == 2 then
			return 2, 1 -- Side by side
		elseif count == 3 then
			return 2, 2 -- 2 smaller, 1 larger (2x2 grid, skip one)
		elseif count == 4 then
			return 2, 2 -- 2x2 grid
		elseif count <= 6 then
			return 3, 2 -- 3x2 grid
		elseif count <= 9 then
			return 3, 3 -- 3x3 grid
		else
			-- For more than 9 groups, use a larger grid
			local cols = math.ceil(math.sqrt(count))
			local rows = math.ceil(count / cols)
			return cols, rows
		end
	end
	
	-- Override element addition methods to use default group if no group specified
	local originalAddButton = self.AddButton
	local originalAddToggle = self.AddToggle
	local originalAddSlider = self.AddSlider
	local originalAddDropdown = self.AddDropdown
	local originalAddTextInput = self.AddTextInput
	local originalAddKeybind = self.AddKeybind
	
	function self:AddButton(text, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddButton(text, callback)
		else
			return originalAddButton(self, text, callback)
		end
	end
	
	function self:AddToggle(text, default, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddToggle(text, default, callback)
		else
			return originalAddToggle(self, text, default, callback)
		end
	end
	
	function self:AddSlider(text, min, max, default, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddSlider(text, min, max, default, callback)
		else
			return originalAddSlider(self, text, min, max, default, callback)
		end
	end
	
	function self:AddDropdown(label, list, default, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddDropdown(label, list, default, callback)
		else
			return originalAddDropdown(self, label, list, default, callback)
		end
	end
	
	function self:AddTextInput(label, placeholder, default, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddTextInput(label, placeholder, default, callback)
		else
			return originalAddTextInput(self, label, placeholder, default, callback)
		end
	end
	
	function self:AddKeybind(label, keyCode, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddKeybind(label, keyCode, callback)
		else
			return originalAddKeybind(self, label, keyCode, callback)
		end
	end
	
	-- Auto-register with Fiend for theme tracking
	if _G.FiendInstance and _G.FiendInstance._trackElement then
		_G.FiendInstance:_trackElement(self)
	end

	return self
end

-- Cleanup method
function Tab:Destroy()
	if self._resizeConnection then
		self._resizeConnection:Disconnect()
		self._resizeConnection = nil
	end
	
	-- Destroy all groups
	for _, group in ipairs(self.Groups) do
		if group.Destroy then
			group:Destroy()
		end
	end
	
	-- Clear groups array
	table.clear(self.Groups)
	self.DefaultGroup = nil
	
	-- Re-enable list layout for traditional elements
	if self.ListLayout then
		self.ListLayout.Parent = self.Container
	end
	if self.Container then
		self.Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
		self.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
	end
end

function Tab:RefreshTheme()
	-- Get current theme from library
	local currentTheme = self.Window.Theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		currentTheme = _G.FiendInstance.Theme
	end
	
	if currentTheme then
		-- Update stored theme reference
		self.Window.Theme = currentTheme
		
		-- Update tab button
		if self.Button then
			local btn = self.Button
			local isActive = (self.Window.ActiveTab == self)
			
			if isActive then
				btn.TextColor3 = (currentTheme.Tab and currentTheme.Tab.ActiveText) or currentTheme.TextColor
				btn.BackgroundColor3 = (currentTheme.Tab and currentTheme.Tab.ActiveFill) or currentTheme.Background
			else
				btn.TextColor3 = (currentTheme.Tab and currentTheme.Tab.IdleText) or currentTheme.SubTextColor
				btn.BackgroundColor3 = (currentTheme.Tab and currentTheme.Tab.IdleFill) or currentTheme.Background2
			end
			
			-- Update border
			local stroke = btn:FindFirstChild("UIStroke")
			if stroke then
				stroke.Color = (currentTheme.Tab and currentTheme.Tab.Border) or currentTheme.Border
				stroke.Thickness = currentTheme.LineThickness or 1
			end
		end
		
		-- Update container background
		if self.Container then
			self.Container.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background
		end
	end
end

return Tab

]]
Modules['components/tab'] = Modules['components/tab.lua']
Modules['tab'] = Modules['components/tab.lua']

-- Module: components/window.lua
Modules['components/window.lua'] = [[
-- Fiend/components/window.lua
-- Window manager with dock modes, scrollable top tabs, and rock-solid layout.

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Util      = require(script.Parent.Parent.lib.util)
local Theme     = require(script.Parent.Parent.lib.theme)
local Safety    = require(script.Parent.Parent.lib.safety)
local Behaviors = require(script.Parent.Parent.lib.behaviors)
local FX        = require(script.Parent.Parent.lib.fx)

local Dock      = require(script.Parent.dock)
local KeySystem = require(script.Parent.Parent.lib.keysystem)

local Window = {}
Window.__index = Window

export type DockMode = "DockOnly" | "SizeDependent" | "AlwaysOff" | "Both"

local TITLEBAR_H = 36

local function getDockWidth(self)
	local rail = self._dock and self._dock.Rail
	if rail and rail.Visible then
		return math.max(56, rail.AbsoluteSize.X)
	end
	return 0
end

local function decideVisibility(self)
	local w = self.Shell and self.Shell.AbsoluteSize.X or self.Width
	local threshold = self.ResponsiveThreshold or 640
	local mode = self.DockMode

	if mode == "DockOnly"   then return true,  false end
	if mode == "AlwaysOff"  then return false, true  end
	if mode == "Both"       then return true,  true  end
	-- SizeDependent
	return (w < threshold), (w >= threshold)
end

local function realign(self)
	if not self.Shell then return end

	local showDock, showTopbar = decideVisibility(self)
	self._showDock, self._showTopbar = showDock, showTopbar

	-- Dock rail
	if self._dock then
		self._dock:SetVisible(showDock)
		self._dock:AnchorToShell(self.Shell, TITLEBAR_H, self.Theme.Padding)
	end

	-- top tabs bar
	local pillH   = (self.Theme.Tab and self.Theme.Tab.PillHeight or 22)
	local tabsRow = showTopbar and (pillH + 8) or 0
	local leftPad = self.Theme.Padding + (showDock and getDockWidth(self) or 0)

	self.TabsBar.Visible = showTopbar
	if self.TabsBar.Visible then
		self.TabsBar.Position = UDim2.new(0, leftPad, 0, TITLEBAR_H + self.Theme.Padding)
		self.TabsBar.Size     = UDim2.new(1, -(leftPad + self.Theme.Padding), 0, tabsRow)
	end

	local topOffset = TITLEBAR_H + self.Theme.Padding + tabsRow

	if not self.Container then
		self.Container = Util.Create("Frame", {
			Name = "Container",
			Parent = self.Shell,
			BackgroundColor3 = (self.Theme.Window and self.Theme.Window.Background) or self.Theme.Background,
			BorderSizePixel  = 0,
			Position = UDim2.new(0, leftPad, 0, topOffset),
			Size     = UDim2.new(1, -(leftPad + self.Theme.Padding), 1, -(topOffset + self.Theme.Padding)),
			ZIndex   = 2,
		})
		Util.CreateUICorner(self.Container, self.Theme.Corner)
		Util.CreateUIStroke(self.Container, self.Theme.Border, self.Theme.LineThickness)
		if self.Theme.EnableGridBG then
			self.GridBG = FX.AttachGrid(self.Container, self.Theme, { gap = 16, alpha = 0.06 })
		end
		if self.Theme.EnableBrackets then
			self.BracketsContainer = FX.AddCornerBrackets(self.Container, self.Theme)
		end
	else
		self.Container.Position = UDim2.new(0, leftPad, 0, topOffset)
		self.Container.Size     = UDim2.new(1, -(leftPad + self.Theme.Padding), 1, -(topOffset + self.Theme.Padding))
	end
end

local function build_shell(self)
	self.Root = Safety.GetRoot()
	self.FloatLayer = Safety.GetFloatLayer()

	-- Shell
	self.Shell = Util.Create("Frame", {
		Name = "Fiend_Shell",
		Parent = self.Root,
		BackgroundColor3 = self.Theme.Background,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(self.Width, self.Height),
		Position = UDim2.new(0, 48, 0, 48),
		ZIndex = 1,
	})
	Util.CreateUICorner(self.Shell, self.Theme.Corner)
	Util.CreateUIStroke(self.Shell, self.Theme.Border, self.Theme.LineThickness)

	-- Titlebar
	self.TitleBar = Util.Create("Frame", {
		Name = "TitleBar",
		Parent = self.Shell,
		BackgroundColor3 = (self.Theme.Window and self.Theme.Window.Background) or self.Theme.Background2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, TITLEBAR_H),
		ZIndex = 2,
	})
	Util.CreateUIStroke(self.TitleBar, (self.Theme.Window and self.Theme.Window.Border) or self.Theme.Border, self.Theme.LineThickness)

	Util.Create("TextLabel", {
		Name = "Title",
		Parent = self.TitleBar,
		BackgroundTransparency = 1,
		Font = self.Theme.FontMono or Enum.Font.Code,
		Text = string.format("%s  —  %s", self.Title, self.SubTitle or ""),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 16,
		TextColor3 = (self.Theme.Window and self.Theme.Window.TitleText) or self.Theme.Foreground,
		Size = UDim2.new(1, -64, 1, 0),
		Position = UDim2.new(0, self.Theme.Padding, 0, 0),
	})

	local minBtn = Util.Create("TextButton", {
		Name = "Min",
		Parent = self.TitleBar,
		Text = "—",
		Font = self.Theme.FontMono or Enum.Font.Code,
		TextSize = 18,
		TextColor3 = (self.Theme.Window and self.Theme.Window.TitleText) or self.Theme.Foreground,
		BackgroundColor3 = (self.Theme.Window and self.Theme.Window.Background) or self.Theme.Background2,
		BackgroundTransparency = 0.8,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 36, 1, 0),
		Position = UDim2.new(1, -36, 0, 0),
	})
	Util.CreateUICorner(minBtn, self.Theme.Corner)
	
	-- Add hover effects to make the button more visible
	minBtn.MouseEnter:Connect(function()
		Util.Tween(minBtn, {
			BackgroundTransparency = 0.3,
			TextColor3 = self.Theme.Accent
		}, 0.15)
	end)
	
	minBtn.MouseLeave:Connect(function()
		Util.Tween(minBtn, {
			BackgroundTransparency = 0.8,
			TextColor3 = self.Theme.Foreground
		}, 0.15)
	end)
	minBtn.MouseButton1Click:Connect(function()
		if self.Minimized then
			self:Restore()
		else
			self:Minimize()
		end
	end)

	-- FX
	if self.Theme.EnableTopSweep then
		self.TopSweepHandle = FX.AttachTopSweep(self.Shell, self.TitleBar, self.Theme, {speed=180, length=120, gap=24})
	end
	if self.Theme.EnableScanlines then
		self.ScanlinesHandle = FX.AttachScanlines(self.Shell, self.Theme, {speed=110})
	end
	if self.Theme.EnableBrackets then
		self.BracketsShell = FX.AddCornerBrackets(self.Shell, self.Theme)
	end

	-- Dock
	self._dock = Dock.new(self)               -- creates rail & buttons holder
	self._dock:AnchorToShell(self.Shell, TITLEBAR_H, self.Theme.Padding)

	-- Tabs bar (horizontal, scrollable)
	self.TabsBar = Instance.new("ScrollingFrame")
	self.TabsBar.Name = "TabsBar"
	self.TabsBar.Parent = self.Shell
	self.TabsBar.BackgroundTransparency = 1
	self.TabsBar.BorderSizePixel = 0
	self.TabsBar.ZIndex = 3
	self.TabsBar.ClipsDescendants = false -- Allow tab borders to show properly
	self.TabsBar.ScrollBarThickness = 0
	self.TabsBar.ScrollingDirection = Enum.ScrollingDirection.X
	self.TabsBar.AutomaticCanvasSize = Enum.AutomaticSize.X

	local tl = Instance.new("UIListLayout")
	tl.FillDirection = Enum.FillDirection.Horizontal
	tl.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tl.SortOrder = Enum.SortOrder.LayoutOrder
	tl.Padding = UDim.new(0, 8) -- Increased padding for better border visibility
	tl.Parent = self.TabsBar
	
	-- Add padding to prevent border clipping
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.PaddingTop = UDim.new(0, 2)
	padding.PaddingBottom = UDim.new(0, 2)
	padding.Parent = self.TabsBar

	-- wire updates
	self._realignConn1 = self.Shell:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() realign(self) end)
	if self._dock and self._dock.Rail then
		self._realignConn2 = self._dock.Rail:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() realign(self) end)
		self._realignConn3 = self._dock.Rail:GetPropertyChangedSignal("Visible"):Connect(function() realign(self) end)
	end

	realign(self)

	-- drag + resize
	Behaviors.MakeDraggable(self.TitleBar, self.Shell, TITLEBAR_H)
	Behaviors.AddResizeGrip(self.Shell, self.Theme, self.MinSize, self.MaxSize)

	-- ready callbacks
	-- Don't set Visible = true here - let the caller control visibility
	for _, fn in ipairs(self._readyQueue) do task.spawn(fn, self) end
	table.clear(self._readyQueue)
end

function Window.new(opts)
	opts = opts or {}
	local self = setmetatable({}, Window)

	self.Title      = opts.Title or "ARCHFIEND"
	self.SubTitle   = opts.SubTitle or ""
	self.Width      = math.clamp(tonumber(opts.Width) or 760, 540, 1600)
	self.Height     = math.clamp(tonumber(opts.Height) or 480, 360, 1200)
	self.MinSize    = opts.MinSize or Vector2.new(540, 360)
	self.MaxSize    = opts.MaxSize or Vector2.new(1920, 1200)
	self.DockMode   = (opts.DockMode :: DockMode) or "SizeDependent"
	self.ResponsiveThreshold = tonumber(opts.ResponsiveThreshold) or 640
	-- Merge theme properly
	local mergedTheme = {}
	for k, v in pairs(Theme) do
		mergedTheme[k] = v
	end
	if opts.Theme then
		for k, v in pairs(opts.Theme) do
			mergedTheme[k] = v
		end
	end
	self.Theme = mergedTheme
	self.Visible    = false
	self.Minimized  = false
	self.Tabs       = {}
	self.ActiveTab  = nil
	self._readyQueue= {}
	self._minimizeBox = nil

	-- Initialize keysystem
	self.KeySystem = KeySystem.new({
		Theme = self.Theme,
		GlobalKeyCapture = true,
		DebugMode = false
	})

	-- key gate - SECURITY: Only build shell after key validation
	local ks = opts.KeySystem
	if ks and ks.Enabled then
		-- Don't build shell until key is validated
		self.KeySystem:ShowPrompt({
			Title     = ks.Title or (self.Title .. "  —  Showcase"),
			Hint      = ks.Hint or "Enter your access key to continue.",
			Key       = ks.Key,
			Check     = ks.Check,
			OnSuccess = function() 
				build_shell(self)
				-- Make sure the window is visible after key validation
				self.Visible = true
				if self.Shell then
					self.Shell.Visible = true
				end
			end,
			OnFail    = ks.OnFail,
			Theme     = self.Theme,
			MaxAttempts = ks.MaxAttempts or 3
		})
	else
		build_shell(self)
		-- Set visible for non-key system windows
		self.Visible = true
		if self.Shell then
			self.Shell.Visible = true
		end
	end
	
	-- Auto-register with Fiend for theme tracking
	if _G.FiendInstance and _G.FiendInstance._trackElement then
		_G.FiendInstance:_trackElement(self)
	end

	return self
end

function Window:OnReady(fn)
	if self.Visible then task.spawn(fn, self) else table.insert(self._readyQueue, fn) end
end

function Window:SetVisible(b)
	self.Visible = (b and true or false)
	if self.Shell then self.Shell.Visible = self.Visible end
end

function Window:AddTab(name, icon)
	-- create pill + content via tab module
	local Tab = require(script.Parent.tab)
	local t = Tab.new(self, name, icon)
	table.insert(self.Tabs, t)

	-- mirror to dock
	if self._dock then self._dock:SyncFromTabs(self) end

	-- show the first tab by default
	if not self.ActiveTab then self:ShowTab(name) end

	realign(self)
	return t
end

function Window:ShowTab(name)
	for _, t in ipairs(self.Tabs) do t:Hide() end
	for _, t in ipairs(self.Tabs) do
		if t.Name == name then t:Show(); self.ActiveTab = t; break end
	end
	-- update dock selection highlight
	if self._dock then self._dock:Highlight(name) end
end

function Window:SetFxEnabled(effectName, enabled)
	if effectName == "Scanlines" then
		if enabled and not self.ScanlinesHandle then
			self.ScanlinesHandle = FX.AttachScanlinesTween(self.Shell, self.Theme, {speed=0.45})
		elseif not enabled and self.ScanlinesHandle then
			self.ScanlinesHandle.Destroy(); self.ScanlinesHandle = nil
		end
	elseif effectName == "TopSweep" then
		if enabled and not self.TopSweepHandle then
			self.TopSweepHandle = FX.AttachTopSweep(self.Shell, self.TitleBar, self.Theme, {speed=180, length=120, gap=24})
		elseif not enabled and self.TopSweepHandle then
			self.TopSweepHandle.Destroy(); self.TopSweepHandle = nil
		end
	end
end

function Window:Minimize()
	if self.Minimized or not self.Shell then return end
	
	self.Minimized = true
	self.Visible = false
	
	-- Hide the main shell
	self.Shell.Visible = false
	
	-- Create minimize box
	self:_createMinimizeBox()
end

function Window:Restore()
	if not self.Minimized then return end
	
	self.Minimized = false
	self.Visible = true
	
	-- Show the main shell
	self.Shell.Visible = true
	
	-- Destroy minimize box
	if self._minimizeBox then
		self._minimizeBox:Destroy()
		self._minimizeBox = nil
	end
	
	-- Bring to front by increasing ZIndex
	if self.Shell then 
		self.Shell.ZIndex = self.Shell.ZIndex + 1
	end
end

function Window:_createMinimizeBox()
	if self._minimizeBox then return end
	
	-- Create the minimize box GUI
	local sg = Instance.new("ScreenGui")
	sg.Name = "FiendMinimizeBox_" .. self.Title
	sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
	sg.DisplayOrder = 1000
	sg.Parent = self.Root
	
	-- Create the minimize box button
	local box = Instance.new("TextButton")
	box.Name = "MinimizeBox"
	box.Size = UDim2.fromOffset(60, 40)
	box.BackgroundColor3 = self.Theme.Background2
	box.BorderSizePixel = 0
	box.AutoButtonColor = false
	box.Text = ""
	box.Parent = sg
	
	-- Position the box near the original window position
	local originalPos = self.Shell.Position
	box.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 20, originalPos.Y.Scale, originalPos.Y.Offset + 20)
	
	-- Apply styling
	Util.CreateUICorner(box, self.Theme.Corner)
	Util.CreateUIStroke(box, self.Theme.Border, self.Theme.LineThickness)
	
	-- Add the "</A/>" logo
	local logo = Instance.new("TextLabel")
	logo.Name = "Logo"
	logo.Size = UDim2.fromScale(1, 1)
	logo.BackgroundTransparency = 1
	logo.Text = "</A/>"
	logo.Font = self.Theme.FontMono or Enum.Font.Code
	logo.TextSize = 16
	logo.TextColor3 = self.Theme.TextColor
	logo.TextXAlignment = Enum.TextXAlignment.Center
	logo.TextYAlignment = Enum.TextYAlignment.Center
	logo.Parent = box
	
	-- Enhanced dragging with click detection
	local isDragging = false
	local dragStartPos = nil
	local dragThreshold = 5 -- pixels
	
	-- Handle mouse down to track drag start
	box.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
			dragStartPos = input.Position
		end
	end)
	
	-- Handle mouse move to detect dragging
	box.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragStartPos then
			local currentPos = input.Position
			local distance = math.sqrt((currentPos.X - dragStartPos.X)^2 + (currentPos.Y - dragStartPos.Y)^2)
			
			if distance > dragThreshold then
				isDragging = true
			end
		end
	end)
	
	-- Handle mouse up to restore only if not dragging
	box.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not isDragging then
				self:Restore()
			end
			isDragging = false
			dragStartPos = nil
		end
	end)
	
	-- Use the enhanced dragging function
	Behaviors.MakeDraggable(box, box)
	
	-- Hover effects
	box.MouseEnter:Connect(function()
		Util.Tween(box, {BackgroundColor3 = self.Theme.Background}, 0.15)
	end)
	box.MouseLeave:Connect(function()
		Util.Tween(box, {BackgroundColor3 = self.Theme.Background2}, 0.15)
	end)
	
	self._minimizeBox = sg
end

function Window:Toggle()
	self:SetVisible(not self.Visible)
end

function Window:RefreshTheme()
	-- Get current theme from library
	local currentTheme = self.Theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		currentTheme = _G.FiendInstance.Theme
	end
	
	if currentTheme then
		-- Update stored theme reference
		self.Theme = currentTheme
		
		-- Update shell background and border
		if self.Shell then
			self.Shell.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background
			local shellStroke = self.Shell:FindFirstChild("UIStroke")
			if shellStroke then
				shellStroke.Color = (currentTheme.Window and currentTheme.Window.Border) or currentTheme.Border
				shellStroke.Thickness = currentTheme.LineThickness or 1
			end
		end
		
		-- Update title bar
		if self.TitleBar then
			self.TitleBar.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background2
			local titleBarStroke = self.TitleBar:FindFirstChild("UIStroke")
			if titleBarStroke then
				titleBarStroke.Color = (currentTheme.Window and currentTheme.Window.Border) or currentTheme.Border
				titleBarStroke.Thickness = currentTheme.LineThickness or 1
			end
			
			-- Update title text
			local titleLabel = self.TitleBar:FindFirstChild("Title")
			if titleLabel then
				titleLabel.TextColor3 = (currentTheme.Window and currentTheme.Window.TitleText) or currentTheme.Foreground
			end
			
			-- Update minimize button
			local minBtn = self.TitleBar:FindFirstChild("Min")
			if minBtn then
				minBtn.TextColor3 = (currentTheme.Window and currentTheme.Window.TitleText) or currentTheme.Foreground
				minBtn.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background2
			end
		end
		
		-- Update container
		if self.Container then
			self.Container.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background
			local containerStroke = self.Container:FindFirstChild("UIStroke")
			if containerStroke then
				containerStroke.Color = (currentTheme.Window and currentTheme.Window.Border) or currentTheme.Border
				containerStroke.Thickness = currentTheme.LineThickness or 1
			end
		end
		
		-- Update tabs bar
		if self.TabsBar then
			self.TabsBar.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background
		end
		
		-- Update all tabs
		for _, tab in ipairs(self.Tabs) do
			if tab.RefreshTheme then
				tab:RefreshTheme()
			end
		end
		
		-- Update dock
		if self._dock and self._dock.RefreshTheme then
			self._dock:RefreshTheme()
		end
		
		-- Refresh FX effects with new theme
		self:RefreshFX()
	end
end

-- Refresh all FX effects with current theme
function Window:RefreshFX()
	local currentTheme = self.Theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		currentTheme = _G.FiendInstance.Theme
	end
	
	if not currentTheme then return end
	
	-- Destroy existing FX effects
	if self.ScanlinesHandle then
		self.ScanlinesHandle:Destroy()
		self.ScanlinesHandle = nil
	end
	
	if self.TopSweepHandle then
		self.TopSweepHandle:Destroy()
		self.TopSweepHandle = nil
	end
	
	if self.GridBG then
		self.GridBG:Destroy()
		self.GridBG = nil
	end
	
	if self.BracketsShell then
		self.BracketsShell:Destroy()
		self.BracketsShell = nil
	end
	
	if self.BracketsContainer then
		self.BracketsContainer:Destroy()
		self.BracketsContainer = nil
	end
	
	-- Recreate FX effects with new theme
	if self.Shell and self.TitleBar then
		-- Top sweep
		self.TopSweepHandle = FX.AttachTopSweep(self.Shell, self.TitleBar, currentTheme, {
			speed = (currentTheme.FX and currentTheme.FX.TopSweepSpeed) or 180,
			length = (currentTheme.FX and currentTheme.FX.TopSweepLength) or 120,
			gap = (currentTheme.FX and currentTheme.FX.TopSweepGap) or 24,
			thickness = (currentTheme.FX and currentTheme.FX.TopSweepThickness) or 2
		})
		
		-- Scanlines
		self.ScanlinesHandle = FX.AttachScanlines(self.Shell, currentTheme, {
			speed = (currentTheme.FX and currentTheme.FX.ScanlineSpeed) or 110
		})
		
		-- Corner brackets on shell
		self.BracketsShell = FX.AddCornerBrackets(self.Shell, currentTheme)
	end
	
	if self.Container then
		-- Grid background
		self.GridBG = FX.AttachGrid(self.Container, currentTheme, {
			gap = (currentTheme.FX and currentTheme.FX.GridGap) or 16,
			alpha = (currentTheme.FX and currentTheme.FX.GridAlpha) or 0.06
		})
		
		-- Corner brackets on container
		self.BracketsContainer = FX.AddCornerBrackets(self.Container, currentTheme)
	end
	
	print("[Window] FX effects refreshed with theme:", currentTheme.FX and "FX properties available" or "No FX properties")
end

function Window:Destroy()
	if self._minimizeBox then
		self._minimizeBox:Destroy()
		self._minimizeBox = nil
	end
	if self._realignConn1 then self._realignConn1:Disconnect() end
	if self._realignConn2 then self._realignConn2:Disconnect() end
	if self._realignConn3 then self._realignConn3:Disconnect() end
	if self._dock then self._dock:Destroy() end
	if self.ScanlinesHandle then self.ScanlinesHandle.Destroy() end
	if self.TopSweepHandle then self.TopSweepHandle.Destroy() end
	if self.BracketsShell then self.BracketsShell.Destroy() end
	if self.BracketsContainer then self.BracketsContainer.Destroy() end
	if self.GridBG then self.GridBG.Destroy() end
	if self.Shell then self.Shell:Destroy() end
	self.Visible = false
end

return Window

]]
Modules['components/window'] = Modules['components/window.lua']
Modules['window'] = Modules['components/window.lua']

-- Module: components/keybind.lua
Modules['components/keybind.lua'] = [[
-- Fiend/components/keybind.lua
-- Unified Keybind Component - Uses the new KeySystem for robust key management

local Util = require(script.Parent.Parent.lib.util)
local Theme = require(script.Parent.Parent.lib.theme)
local KeySystem = require(script.Parent.Parent.lib.keysystem)
local BaseElement = require(script.Parent.Parent.lib.base_element)

local Keybind = {}
Keybind.__index = Keybind

export type KeybindOptions = {
    Label: string,
    DefaultKey: Enum.KeyCode?,
    DefaultMode: string?,
    Callback: ((boolean?) -> ())?,
    Enabled: boolean?,
    Id: string?
}

function Keybind.new(tabOrGroup, options: KeybindOptions | string, defaultKeyCode: Enum.KeyCode?, defaultMode: string?, callback: ((boolean?) -> ())?)
    -- Handle both new options format and legacy format
    local opts: KeybindOptions
    if typeof(options) == "string" then
        -- Legacy format: Keybind.new(tabOrGroup, labelText, defaultKeyCode, defaultMode, callback)
        opts = {
            Label = options,
            DefaultKey = defaultKeyCode,
            DefaultMode = defaultMode,
            Callback = callback,
            Enabled = true
        }
    else
        -- New format: Keybind.new(tabOrGroup, options)
        opts = options or {}
    end
    
    local theme = opts.Theme or tabOrGroup.Theme or Theme
    local keySystem = tabOrGroup.Window and tabOrGroup.Window.KeySystem or (tabOrGroup.Tab and tabOrGroup.Tab.Window and tabOrGroup.Tab.Window.KeySystem) or KeySystem.new()
    
    -- Create main frame
    local frame = Util.Create("Frame", {
        Name = "KeybindFrame",
        Parent = tabOrGroup.Content or tabOrGroup.Container,
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 2
    })
    
    Util.CreateUICorner(frame, theme.Corner)
    Util.CreateUIStroke(frame, theme.Foreground, 1, 0.7)
    Util.CreateUIPadding(frame, theme.Pad)
    
    -- Label
    local label = Util.Create("TextLabel", {
        Name = "Label",
        Parent = frame,
        BackgroundTransparency = 1,
        Text = opts.Label,
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 232, 236),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -160, 1, 0),
        ZIndex = 3
    })
    
    -- Key button
    local keyBtn = Util.Create("TextButton", {
        Name = "KeyButton",
        Parent = frame,
        AutoButtonColor = false,
        Text = (opts.DefaultKey and opts.DefaultKey.Name) or "None",
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 232, 236),
        BackgroundColor3 = theme.Background,
        Size = UDim2.fromOffset(90, 22),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        ZIndex = 3
    })
    
    Util.CreateUICorner(keyBtn, theme.Corner)
    Util.CreateUIStroke(keyBtn, theme.Foreground, 1, 0.6)
    
    -- Mode button
    local modeBtn = Util.Create("TextButton", {
        Name = "ModeButton",
        Parent = frame,
        AutoButtonColor = false,
        Text = opts.DefaultMode or "Hold",
        Font = theme.Font or Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 232, 236),
        BackgroundColor3 = theme.Background,
        Size = UDim2.fromOffset(60, 22),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8 - 96, 0.5, 0),
        ZIndex = 3
    })
    
    Util.CreateUICorner(modeBtn, theme.Corner)
    Util.CreateUIStroke(modeBtn, theme.Foreground, 1, 0.6)
    
    -- Create the keybind instance
    local self = setmetatable({
        Instance = frame,
        Root = frame,
        _keySystem = keySystem,
        _name = opts.Label,
        _currentKey = opts.DefaultKey,
        _currentMode = opts.DefaultMode or "Hold",
        _callback = opts.Callback,
        _enabled = opts.Enabled ~= false,
        _id = opts.Id or opts.Label,
        _theme = theme,
        _label = label,
        _keyBtn = keyBtn,
        _modeBtn = modeBtn
    }, Keybind)
    
    -- Inherit from BaseElement
    setmetatable(self, {__index = BaseElement})
    
    -- Initialize BaseElement
    BaseElement.new(self, {
        Theme = theme,
        Root = frame
    })
    
    -- Register with keysystem
    if opts.DefaultKey then
        keySystem:RegisterBind(opts.Label, opts.DefaultKey, opts.DefaultMode or "Hold", opts.Callback, opts.Id)
    end
    
    -- Auto-register with Fiend for theme tracking
    if _G.FiendInstance and _G.FiendInstance._trackElement then
        _G.FiendInstance:_trackElement(self)
    end
    
    -- Key button click handler
    keyBtn.MouseButton1Click:Connect(function()
        if not self._enabled then return end
        
        keyBtn.Text = "..."
        
        -- Get current theme for accent color
        local currentTheme = self._theme
        if _G.FiendInstance and _G.FiendInstance.Theme then
            currentTheme = _G.FiendInstance.Theme
        end
        
        keyBtn.TextColor3 = currentTheme.Accent or Color3.fromRGB(91, 135, 255)
        
        -- Start key capture
        keySystem:StartKeyCapture(function(capturedKey)
            self:SetKey(capturedKey)
            keyBtn.TextColor3 = currentTheme.Foreground or currentTheme.TextColor or Color3.fromRGB(230, 232, 236)
        end)
    end)
    
    -- Mode button click handler
    local modes = {"Hold", "Toggle", "Press", "Always"}
    modeBtn.MouseButton1Click:Connect(function()
        if not self._enabled then return end
        
        local currentIndex = table.find(modes, self._currentMode) or 1
        local nextIndex = (currentIndex % #modes) + 1
        local nextMode = modes[nextIndex]
        
        self:SetMode(nextMode)
    end)
    
    -- Refresh theme for this keybind
    function self:RefreshTheme()
        -- Get current theme from library
        local currentTheme = self._theme
        if _G.FiendInstance and _G.FiendInstance.Theme then
            currentTheme = _G.FiendInstance.Theme
        end
        
        if currentTheme then
            -- Update main frame
            if self.Root then
                self.Root.BackgroundColor3 = currentTheme.Background
                self.Root.BackgroundTransparency = 0.15
                
                -- Update border
                local stroke = self.Root:FindFirstChild("UIStroke")
                if stroke then
                    stroke.Color = currentTheme.Border
                    stroke.Thickness = currentTheme.LineThickness or 1
                end
                
                -- Update corner radius
                local corner = self.Root:FindFirstChild("UICorner")
                if corner then
                    corner.CornerRadius = currentTheme.Corner or UDim.new(0, 6)
                end
            end
            
            -- Update label
            if self._label then
                self._label.TextColor3 = currentTheme.Foreground or currentTheme.TextColor
                self._label.Font = currentTheme.Font or Enum.Font.Gotham
            end
            
            -- Update key button
            if self._keyBtn then
                self._keyBtn.TextColor3 = currentTheme.Foreground or currentTheme.TextColor
                self._keyBtn.BackgroundColor3 = currentTheme.Background
                self._keyBtn.Font = currentTheme.Font or Enum.Font.Gotham
                
                -- Update key button border
                local keyStroke = self._keyBtn:FindFirstChild("UIStroke")
                if keyStroke then
                    keyStroke.Color = currentTheme.Border
                    keyStroke.Thickness = currentTheme.LineThickness or 1
                end
                
                -- Update key button corner
                local keyCorner = self._keyBtn:FindFirstChild("UICorner")
                if keyCorner then
                    keyCorner.CornerRadius = currentTheme.Corner or UDim.new(0, 6)
                end
            end
            
            -- Update mode button
            if self._modeBtn then
                self._modeBtn.TextColor3 = currentTheme.Foreground or currentTheme.TextColor
                self._modeBtn.BackgroundColor3 = currentTheme.Background
                self._modeBtn.Font = currentTheme.Font or Enum.Font.Gotham
                
                -- Update mode button border
                local modeStroke = self._modeBtn:FindFirstChild("UIStroke")
                if modeStroke then
                    modeStroke.Color = currentTheme.Border
                    modeStroke.Thickness = currentTheme.LineThickness or 1
                end
                
                -- Update mode button corner
                local modeCorner = self._modeBtn:FindFirstChild("UICorner")
                if modeCorner then
                    modeCorner.CornerRadius = currentTheme.Corner or UDim.new(0, 6)
                end
            end
            
            -- Update stored theme reference
            self._theme = currentTheme
        end
    end
    
    -- Apply initial theme
    self:RefreshTheme()
    
    return self
end


-- Set the key for this keybind
function Keybind:SetKey(keyCode: Enum.KeyCode)
    if not keyCode then return end
    
    self._currentKey = keyCode
    
    -- Update button text
    local keyBtn = self.Instance:FindFirstChild("KeyButton")
    if keyBtn then
        keyBtn.Text = keyCode.Name
    end
    
    -- Update keysystem
    self._keySystem:SetBindKey(self._name, keyCode)
end

-- Set the mode for this keybind
function Keybind:SetMode(mode: string)
    if not table.find({"Hold", "Toggle", "Press", "Always"}, mode) then
        warn("[Keybind] Invalid mode:", mode)
        return
    end
    
    self._currentMode = mode
    
    -- Update button text
    local modeBtn = self.Instance:FindFirstChild("ModeButton")
    if modeBtn then
        modeBtn.Text = mode
    end
    
    -- Update keysystem
    self._keySystem:SetBindType(self._name, mode)
end

-- Set the callback for this keybind
function Keybind:SetCallback(callback: ((boolean?) -> ())?)
    self._callback = callback
    
    -- Update keysystem
    if self._currentKey then
        self._keySystem:RegisterBind(self._name, self._currentKey, self._currentMode, callback, self._id)
    end
end

-- Enable/disable this keybind
function Keybind:SetEnabled(enabled: boolean)
    self._enabled = enabled
    self._keySystem:SetBindEnabled(self._name, enabled)
    
    -- Update visual state
    local keyBtn = self.Instance:FindFirstChild("KeyButton")
    local modeBtn = self.Instance:FindFirstChild("ModeButton")
    
    if keyBtn then
        keyBtn.TextTransparency = enabled and 0 or 0.5
    end
    if modeBtn then
        modeBtn.TextTransparency = enabled and 0 or 0.5
    end
end

-- Get current key
function Keybind:GetKey(): Enum.KeyCode?
    return self._currentKey
end

-- Get current mode
function Keybind:GetMode(): string
    return self._currentMode
end

-- Get current state
function Keybind:GetState(): boolean
    return self._keySystem:GetBindState(self._name)
end

-- Get enabled state
function Keybind:IsEnabled(): boolean
    return self._enabled
end

-- Destroy the keybind
function Keybind:Destroy()
    if self._keySystem and self._name then
        self._keySystem:UnregisterBind(self._name)
    end
    
    if self.Instance then
        self.Instance:Destroy()
    end
end

return Keybind
]]
Modules['components/keybind'] = Modules['components/keybind.lua']
Modules['keybind'] = Modules['components/keybind.lua']

-- Module: components/notify.lua
Modules['components/notify.lua'] = [[
-- Fiend/components/notify.lua

local Util   = require(script.Parent.Parent.lib.util)
local Theme  = require(script.Parent.Parent.lib.theme)

local Notify = {}
Notify.__index = Notify

local function padPx(theme)
	if theme.Pad and typeof(theme.Pad) == "UDim" then return theme.Pad.Offset end
	if typeof(theme.Padding) == "number" then return theme.Padding end
	return 8
end

function Notify.new(theme)
	local self = setmetatable({}, Notify)
	self.Theme = theme or Theme
	self.Gui = nil
	self.Holder = nil
	return self
end

function Notify:AttachTo(parent)
	if self.Gui then self.Gui:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name = "Fiend_Notify"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parent
	self.Gui = gui

	local hold = Instance.new("Frame")
	hold.BackgroundTransparency = 1
	hold.Size = UDim2.fromScale(1,1)
	hold.Parent = gui

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.HorizontalAlignment = Enum.HorizontalAlignment.Right
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.Padding = UDim.new(0, 6)
	list.Parent = hold

	self.Holder = hold
end

function Notify:Push(text, duration)
	if not self.Holder then return end
	duration = tonumber(duration) or 2

	-- Get current theme from library
	local theme = self.Theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		theme = _G.FiendInstance.Theme
	end
	
	local p = padPx(theme)

	local toast = Instance.new("Frame")
	toast.BackgroundColor3 = theme.Background2 or theme.Background
	toast.BorderSizePixel = 0
	toast.Size = UDim2.new(0, 400, 0, 48)
	toast.AnchorPoint = Vector2.new(1, 1)
	toast.Position = UDim2.new(1, -p, 1, -p)
	toast.Parent = self.Holder

	Util:Roundify(toast, theme.Corner or UDim.new(0, theme.Rounding or 8))
	Util:Stroke(toast, theme.Border, 1)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = theme.Font or Enum.Font.Gotham
	label.TextSize = 16
	label.TextColor3 = theme.Foreground or theme.TextColor
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = tostring(text or "")
	label.Size = UDim2.new(1, - (p*2), 1, 0)
	label.Position = UDim2.new(0, p, 0, 0)
	label.Parent = toast

	-- enter
	toast.BackgroundTransparency = 1
	label.TextTransparency = 1
	Util.Tween(toast, theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
	Util.Tween(label, theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })

	-- leave
	task.delay(duration, function()
		Util.Tween(label, theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })
		local t = Util.Tween(toast, theme.TweenShort or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
		t.Completed:Wait()
		if toast then toast:Destroy() end
	end)
end

return Notify

]]
Modules['components/notify'] = Modules['components/notify.lua']
Modules['notify'] = Modules['components/notify.lua']

-- Module: components/announce.lua
Modules['components/announce.lua'] = [[
-- Fiend/components/announce.lua
-- Retro modal announcement dialog (safe against nil theme fields).

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Util   = require(script.Parent.Parent.lib.util)
local Theme  = require(script.Parent.Parent.lib.theme)
local Safety = require(script.Parent.Parent.lib.safety)

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

]]
Modules['components/announce'] = Modules['components/announce.lua']
Modules['announce'] = Modules['components/announce.lua']

-- Module: components/dock.lua
Modules['components/dock.lua'] = [[
-- Fiend/components/dock.lua
-- Side dock rail that mirrors tabs as icon buttons.
-- Square buttons, even spacing when tall; scrolls when short.

local Util = require(script.Parent.Parent.lib.util)

local Dock = {}
Dock.__index = Dock

function Dock.new(window)
	local self = setmetatable({}, Dock)
	self.Window       = window
	self._buttons     = {}
	self.ButtonSize   = 44     -- square
	self.MinGap       = 8
	self.MaxGap       = 36
	self.EdgePad      = 8

	local rail = Instance.new("Frame")
	rail.Name = "DockRail"
	rail.BackgroundColor3 = (window.Theme.Dock and window.Theme.Dock.Background) or window.Theme.Background2
	rail.BorderSizePixel  = 0
	rail.Size             = UDim2.new(0, 56, 1, 0)
	rail.Visible          = false
	rail.ZIndex           = 3
	rail.ClipsDescendants = true
	self.Rail = rail

	Util.CreateUICorner(rail, window.Theme.Corner)
	Util.CreateUIStroke(rail, (window.Theme.Dock and window.Theme.Dock.Border) or window.Theme.Border, window.Theme.LineThickness)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "ButtonsScroll"
	scroll.Parent = rail
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Size = UDim2.fromScale(1,1)
	scroll.ScrollBarThickness = 4
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0,0,0,0)
	scroll.ClipsDescendants = true
	self.Scroll = scroll

	local pad = Instance.new("UIPadding")
	pad.PaddingTop    = UDim.new(0, self.EdgePad)
	pad.PaddingBottom = UDim.new(0, self.EdgePad)
	pad.PaddingLeft   = UDim.new(0, 6)
	pad.PaddingRight  = UDim.new(0, 6)
	pad.Parent = scroll
	self.Padding = pad

	local list = Instance.new("UIListLayout")
	list.FillDirection        = Enum.FillDirection.Vertical
	list.HorizontalAlignment  = Enum.HorizontalAlignment.Center
	list.VerticalAlignment    = Enum.VerticalAlignment.Top
	list.SortOrder            = Enum.SortOrder.LayoutOrder
	list.Padding              = UDim.new(0, self.MinGap)
	list.Parent = scroll
	self.List = list

	rail.Parent = window.Shell
	self._szConn = rail:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:_reflow() end)
	return self
end

function Dock:AnchorToShell(shell, titlebarHeight, pad)
	if not self.Rail or not shell then return end
	self.Rail.Parent   = shell
	self.Rail.Position = UDim2.new(0, pad, 0, titlebarHeight + pad)
	self.Rail.Size     = UDim2.new(0, self.Rail.Size.X.Offset, 1, -(titlebarHeight + pad*2))
	self:_reflow()
end

function Dock:SetVisible(b)
	if self.Rail then self.Rail.Visible = (b and true or false) end
end

function Dock:Destroy()
	if self._szConn then self._szConn:Disconnect() end
	if self.Rail then self.Rail:Destroy() end
	self._buttons = {}
end

function Dock:SyncFromTabs(window)
	if not (self.Rail and self.Scroll) then return end
	for _, pack in pairs(self._buttons) do
		if pack.Button then pack.Button:Destroy() end
	end
	self._buttons = {}

	for _, tab in ipairs(window.Tabs) do
		local ico = (tab.Icon and tostring(tab.Icon) ~= "" and tab.Icon) or "•"

		local btn = Instance.new("TextButton")
		btn.Name = "DockTab_"..tab.Name
		btn.Parent = self.Scroll
		btn.Size = UDim2.new(0, self.ButtonSize, 0, self.ButtonSize)
		btn.AutoButtonColor = false
		btn.Text = ico
		btn.TextSize = 18
		btn.Font = window.Theme.FontMono or Enum.Font.Code
		btn.TextColor3 = (window.Theme.Dock and window.Theme.Dock.ButtonIdleText) or window.Theme.SubTextColor
		btn.BackgroundColor3 = (window.Theme.Dock and window.Theme.Dock.ButtonIdleFill) or window.Theme.Background
		btn.BorderSizePixel = 0
		btn.ZIndex = 4

		Util.CreateUICorner(btn, window.Theme.Corner)
		local stroke = Util.CreateUIStroke(btn, (window.Theme.Dock and window.Theme.Dock.ButtonIdleBorder) or window.Theme.Border, window.Theme.LineThickness)

		btn.MouseButton1Click:Connect(function()
			window:ShowTab(tab.Name)
		end)

		self._buttons[tab.Name] = { Button = btn, Stroke = stroke }
	end

	self:_reflow()
	self:Highlight(window.ActiveTab and window.ActiveTab.Name)
	
	-- Auto-register with Fiend for theme tracking
	if _G.FiendInstance and _G.FiendInstance._trackElement then
		_G.FiendInstance:_trackElement(self)
	end
	
	return self
end

function Dock:Highlight(tabName)
	-- Get current theme from library
	local currentTheme = self.Window.Theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		currentTheme = _G.FiendInstance.Theme
	end
	
	for name, pack in pairs(self._buttons) do
		local selected = (name == tabName)
		if pack.Button then
			pack.Button.TextColor3 = selected and 
				((currentTheme.Dock and currentTheme.Dock.ButtonActiveText) or currentTheme.TextColor) or 
				((currentTheme.Dock and currentTheme.Dock.ButtonIdleText) or currentTheme.SubTextColor)
			pack.Button.BackgroundColor3 = selected and 
				((currentTheme.Dock and currentTheme.Dock.ButtonActiveFill) or currentTheme.Background2) or 
				((currentTheme.Dock and currentTheme.Dock.ButtonIdleFill) or currentTheme.Background)
		end
		if pack.Stroke then
			pack.Stroke.Color = selected and 
				((currentTheme.Dock and currentTheme.Dock.ButtonActiveBorder) or currentTheme.Accent) or 
				((currentTheme.Dock and currentTheme.Dock.ButtonIdleBorder) or currentTheme.Border)
		end
	end
end

-- Even distribution when tall; enable scroll when short.
function Dock:_reflow()
	if not (self.Rail and self.Scroll and self.List and self.Padding) then return end
	local n = 0
	for _, ch in ipairs(self.Scroll:GetChildren()) do
		if ch:IsA("TextButton") then n += 1 end
	end
	if n == 0 then
		self.Scroll.ScrollingEnabled = false
		return
	end

	local railH  = self.Rail.AbsoluteSize.Y
	local minPad = self.EdgePad
	local minGap = self.MinGap
	local btnH   = self.ButtonSize

	local minTotal = (n * btnH) + ((n - 1) * minGap) + (minPad * 2)

	if railH >= minTotal then
		local free = railH - (n * btnH)
		local gap  = math.clamp(math.floor(free / (n + 1)), minGap, self.MaxGap)
		self.Padding.PaddingTop    = UDim.new(0, gap)
		self.Padding.PaddingBottom = UDim.new(0, gap)
		self.List.Padding          = UDim.new(0, gap)
		self.Scroll.ScrollingEnabled = false
	else
		self.Padding.PaddingTop    = UDim.new(0, minPad)
		self.Padding.PaddingBottom = UDim.new(0, minPad)
		self.List.Padding          = UDim.new(0, minGap)
		self.Scroll.ScrollingEnabled = true
		self.Scroll.CanvasPosition = Vector2.new(0,0)
	end
end

-- Refresh dock theme when theme changes
function Dock:RefreshTheme()
	-- Debounce multiple calls
	if self._refreshing then
		return
	end
	self._refreshing = true
	
	-- Get current theme from library
	local currentTheme = self.Window.Theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		currentTheme = _G.FiendInstance.Theme
	end
	
	print("[Dock] RefreshTheme called - Theme:", currentTheme and (currentTheme.Dock and "Dock theme available" or "No dock theme") or "No theme")
	
	if currentTheme then
		-- Update rail background and border
		if self.Rail then
			local newBgColor = (currentTheme.Dock and currentTheme.Dock.Background) or currentTheme.Background2
			self.Rail.BackgroundColor3 = newBgColor
			print("[Dock] Updated rail background to:", newBgColor)
			
			local railStroke = self.Rail:FindFirstChild("UIStroke")
			if railStroke then
				local newBorderColor = (currentTheme.Dock and currentTheme.Dock.Border) or currentTheme.Border
				railStroke.Color = newBorderColor
				railStroke.Thickness = currentTheme.LineThickness or 1
				print("[Dock] Updated rail border to:", newBorderColor)
			end
		end
		
		-- Update all dock buttons
		for name, pack in pairs(self._buttons) do
			if pack.Button then
				local isActive = (self.Window.ActiveTab and self.Window.ActiveTab.Name == name)
				
				if isActive then
					pack.Button.TextColor3 = (currentTheme.Dock and currentTheme.Dock.ButtonActiveText) or currentTheme.TextColor
					pack.Button.BackgroundColor3 = (currentTheme.Dock and currentTheme.Dock.ButtonActiveFill) or currentTheme.Background2
				else
					pack.Button.TextColor3 = (currentTheme.Dock and currentTheme.Dock.ButtonIdleText) or currentTheme.SubTextColor
					pack.Button.BackgroundColor3 = (currentTheme.Dock and currentTheme.Dock.ButtonIdleFill) or currentTheme.Background
				end
				
				-- Update button border
				if pack.Stroke then
					if isActive then
						pack.Stroke.Color = (currentTheme.Dock and currentTheme.Dock.ButtonActiveBorder) or currentTheme.Accent
					else
						pack.Stroke.Color = (currentTheme.Dock and currentTheme.Dock.ButtonIdleBorder) or currentTheme.Border
					end
					pack.Stroke.Thickness = currentTheme.LineThickness or 1
				end
				
				print("[Dock] Updated button", name, "- Active:", isActive, "- Text:", pack.Button.TextColor3, "- BG:", pack.Button.BackgroundColor3)
			end
		end
		
		print("[Dock] RefreshTheme completed successfully")
	else
		print("[Dock] RefreshTheme failed - no theme available")
	end
	
	-- Clear debounce flag after a short delay
	task.wait(0.01)
	self._refreshing = false
end

return Dock

]]
Modules['components/dock'] = Modules['components/dock.lua']
Modules['dock'] = Modules['components/dock.lua']

print('✅ All modules loaded')

-- Set up require and execute init
local require = createRequire()
getgenv().FiendRequire = require

local Fiend = require('init')

print('✅ Fiend UI Library ready!')
print('📊 Version:', Fiend.Version or 'Unknown')

return Fiend