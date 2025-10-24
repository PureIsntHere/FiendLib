--!strict
return {
	Background = Color3.fromRGB(0,0,0),
	Foreground = Color3.fromRGB(255,255,255),
	Accent     = Color3.fromRGB(215,215,215),
	Muted      = Color3.fromRGB(130,130,130),

	StrokeTransparency = 0.25,
	BaseTransparency   = 0.05,

	Font   = Enum.Font.Code,
	Corner = UDim.new(0,6),
	Pad    = 8,

	OpenTween  = 0.25,
	HoverTween = 0.15,

	-- Subtle FX controls
	FX = {
		ScanlinesTransparency = 0.93, -- 0 = solid, 1 = invisible
		ScanlinesSpeed        = 0.75, -- seconds to sweep
		BorderPulseLow        = 0.45,
		BorderPulseHigh       = 0.25,
		BorderPulsePeriod     = 2.0,  -- seconds
		ShowCornerBrackets    = true,
	}
}
