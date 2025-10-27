-- Fiend/components/toggle.lua

local Util = FiendModules.Util
local Theme = FiendModules.Theme
local Base = FiendModules.BaseElement

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
	
	-- Get scaled size if this is in a group
	local rowSize = UDim2.new(1, 0, 0, 36)
	local useScaledSize = false
	if tabOrGroup.GetScaledElementSize then
		rowSize = tabOrGroup:GetScaledElementSize(1, 36)
		useScaledSize = true
	end

	local row = Util.Create("Frame", {
		Parent = container, BackgroundTransparency = 1, Size = rowSize,
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
	
	function self:Destroy()
		if row then row:Destroy() end
		if self._resizeConnection then
			self._resizeConnection:Disconnect()
		end
	end
	
	-- Add resize listener if in a group
	if useScaledSize and tabOrGroup.Instance then
		self._resizeConnection = tabOrGroup.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			local newSize = tabOrGroup:GetScaledElementSize(1, 36)
			row.Size = newSize
		end)
	end
	
	-- Apply initial theme
	self:RefreshTheme()
	
	-- Auto-register with Fiend for theme tracking
	if _G.FiendInstance and _G.FiendInstance._trackElement then
		_G.FiendInstance:_trackElement(self)
	end

	return self
end

return Toggle
