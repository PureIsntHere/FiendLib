-- Fiend/components/slider.lua

local UIS    = game:GetService("UserInputService")
local Util = FiendModules.Util
local Theme = FiendModules.Theme
local BaseElement = FiendModules.BaseElement

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
		Size = UDim2.new(1, -10, 0, 16), Position = UDim2.new(0, 5, 0, 20),
		TextWrapped = false,
	})
end

function Slider.new(tabOrGroup, text, min, max, default, callback)
	local w = tabOrGroup.Window or (tabOrGroup.Tab and tabOrGroup.Tab.Window)
	local theme = (w and w.Theme) or Theme
	local container = tabOrGroup.Content or tabOrGroup.Container
	local p, cr    = padPx(theme), corner(theme)
	
	-- Get scaled size if this is in a group
	local rowSize = UDim2.new(1, 0, 0, 56)
	if tabOrGroup.GetScaledElementSize then
		rowSize = tabOrGroup:GetScaledElementSize(1, 56)
	end

	local row = Util.Create("Frame", { Parent = container, BackgroundTransparency = 1, Size = rowSize })
	local label = makeLabel(row, theme, text, p)
	local valueLbl = makeValueLabel(row, theme)
	
	-- Store row for resize
	local rowRef = row

	min = tonumber(min) or 0
	max = tonumber(max) or 100
	default = tonumber(default) or min
	
	-- Calculate bar position based on row height (default 56px)
	-- Label is 18px at y=0, value label is 16px at y=20 (ends at y=36), bar at y=42, we want space after value
	local rowHeight = rowSize.Y.Offset or 56
	local barYPosition = math.max(42, rowHeight - 14) -- Ensure minimum spacing after value label

	local bar = Util.Create("Frame", {
		Parent = row, BackgroundColor3 = theme.Background2 or theme.Background, BorderSizePixel = 0,
		Size = UDim2.new(1, -(p*2), 0, 10), Position = UDim2.new(0, p, 0, barYPosition),
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
	
	-- Add resize listener if in a group
	if tabOrGroup.GetScaledElementSize and tabOrGroup.Instance then
		self._resizeConnection = tabOrGroup.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if rowRef then
				local newSize = tabOrGroup:GetScaledElementSize(1, 56)
				rowRef.Size = newSize
				-- Update bar position based on new row height
				local newRowHeight = newSize.Y.Offset or 56
				local newBarYPosition = math.min(38, newRowHeight - 12)
				bar.Position = UDim2.new(0, p, 0, newBarYPosition)
			end
		end)
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
