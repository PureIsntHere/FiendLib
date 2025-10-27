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
        Background = Color3.fromRGB(2, 2, 4),              -- Deep dark blue-black
        Background2 = Color3.fromRGB(8, 8, 12),           -- Slightly lighter dark blue
        Background3 = Color3.fromRGB(15, 15, 20),         -- For grids
        TextColor = Color3.fromRGB(240, 242, 248),        -- Bright white text
        SubTextColor = Color3.fromRGB(140, 144, 156),     -- Muted cyan-gray

        -- Bright cyan accents (retro-futuristic)
        Accent = Color3.fromRGB(0, 255, 255),             -- Bright cyan
        AccentDim = Color3.fromRGB(0, 180, 180),          -- Dimmer cyan
        Border = Color3.fromRGB(0, 200, 200),             -- Cyan border

        -- Status colors
        Success = Color3.fromRGB(0, 255, 180),            -- Bright green-cyan
        Warning = Color3.fromRGB(255, 255, 0),            -- Bright yellow

        -- Retro-futuristic geometry
        Rounding = 2,                                     -- Sharper, more angular
        Padding = 8,
        LineThickness = 1,

        -- Typography
        Font = Enum.Font.Gotham,
        FontMono = Enum.Font.Code,

        -- Enhanced retro effects
        EnableScanlines = true,
        EnableTopSweep = true,
        EnableBrackets = true,
        EnableGridBG = true,
        EnableGlow = true,                                -- Glowing effects

        -- Retro-futuristic styling
        GridColor = Color3.fromRGB(0, 120, 120),          -- Grid line color
        GlowColor = Color3.fromRGB(0, 255, 255),          -- Glow effect color

        -- Window theming
        Window = {
            Background = Color3.fromRGB(2, 2, 4),
            TitleText = Color3.fromRGB(0, 255, 255),      -- Bright cyan
            SubtitleText = Color3.fromRGB(140, 144, 156),
            Border = Color3.fromRGB(0, 200, 200),
            CornerBrackets = Color3.fromRGB(0, 255, 255),
        },

        -- Tab theming
        Tab = {
            IdleFill = Color3.fromRGB(4, 4, 8),
            ActiveFill = Color3.fromRGB(2, 2, 4),
            IdleText = Color3.fromRGB(100, 120, 140),
            ActiveText = Color3.fromRGB(0, 255, 255),     -- Bright cyan
            Border = Color3.fromRGB(0, 200, 200),
            PillHeight = 24,
            Uppercase = true,
        },

        -- Grid theming
        Grid = {
            Background = Color3.fromRGB(15, 15, 20),
            Border = Color3.fromRGB(0, 200, 200),
            LineColor = Color3.fromRGB(0, 120, 120),
        },

        -- Dock theming
        Dock = {
            Background = Color3.fromRGB(8, 8, 12),
            Border = Color3.fromRGB(0, 200, 200),
            ButtonIdleFill = Color3.fromRGB(2, 2, 4),
            ButtonActiveFill = Color3.fromRGB(8, 8, 12),
            ButtonIdleText = Color3.fromRGB(100, 120, 140),
            ButtonActiveText = Color3.fromRGB(0, 255, 255),
            ButtonIdleBorder = Color3.fromRGB(0, 200, 200),
            ButtonActiveBorder = Color3.fromRGB(0, 255, 255),
            ButtonSize = 44,
        },

        -- FX theming
        FX = {
            -- Pulse effect
            PulseBase = 0.4,                              -- Visible for retro
            PulseAmp = 0.6,                               -- Strong pulse
            PulseHz = 2.0,                                -- Fast, futuristic

            -- Corner brackets
            CornerBrackets = Color3.fromRGB(0, 255, 255),
            CornerBracketThickness = 1,

            -- Scanlines
            ScanlineColor = Color3.fromRGB(0, 255, 255),
            ScanlineTransparency = 0.8,
            ScanlineSpeed = 80,

            -- Top sweep
            TopSweepColor = Color3.fromRGB(0, 255, 255),
            TopSweepThickness = 2,
            TopSweepSpeed = 240,
            TopSweepGap = 16,
            TopSweepLength = 80,

            -- Grid
            GridColor = Color3.fromRGB(0, 120, 120),
            GridAlpha = 0.08,
            GridGap = 12,
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
