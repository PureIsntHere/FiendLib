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
