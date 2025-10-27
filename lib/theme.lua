-- Fiend/lib/theme.lua
-- RETRO_HUD: monochrome wireframe HUD, thin strokes, pill tabs.

local Theme = {
	-- Clean black and white theme (default)
	Background      = Color3.fromRGB(8, 8, 10),       -- Dark gray background
	Background2     = Color3.fromRGB(14, 14, 18),     -- Slightly lighter gray
	Background3     = Color3.fromRGB(20, 20, 24),     -- Even lighter for grids
	TextColor       = Color3.fromRGB(240, 242, 248),  -- Bright white text
	SubTextColor    = Color3.fromRGB(170, 174, 182),  -- Muted gray

	-- Clean accent colors (neutral grays)
	Accent          = Color3.fromRGB(220, 220, 224),  -- Light gray accent
	AccentDim       = Color3.fromRGB(170, 174, 182),  -- Dim gray
	Border          = Color3.fromRGB(96, 98, 104),    -- Medium gray border

	-- Status colors (neutral)
	Success         = Color3.fromRGB(180, 220, 200),  -- Soft green
	Warning         = Color3.fromRGB(255, 220, 120),  -- Soft yellow

	-- Clean geometry
	Rounding        = 6,                              -- Standard rounding
	Padding         = 6,
	LineThickness   = 1,

	-- Typography
	Font            = Enum.Font.Gotham,
	FontMono        = Enum.Font.Code,

	-- Standard tweens
	TweenShort      = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TweenMedium     = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TweenLong       = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	-- Standard effects (optional)
	EnableScanlines = false,
	EnableTopSweep  = false,
	EnableBrackets  = false,
	EnableGridBG    = false,
	EnableGlow      = false,                          -- Disabled by default
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

-- Tab styling hints (clean design)
Theme.Tab = {
	PillHeight = 22,
	Uppercase  = true,
	ActiveFill = Theme.Background,
	IdleFill   = Theme.Background2,
	IdleText   = Theme.SubTextColor,
	ActiveText = Theme.TextColor,
	Border     = Theme.Border,
}

return Theme
