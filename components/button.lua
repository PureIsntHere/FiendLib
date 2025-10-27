local TweenService = game:GetService("TweenService")

local Util = FiendModules.Util
local Theme = FiendModules.Theme
local Base = FiendModules.BaseElement

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
	
	-- Get scaled size if this is in a group
	local buttonSize = UDim2.new(1, 0, 0, 36)
	local useScaledSize = false
	if tabOrGroup.GetScaledElementSize then
		buttonSize = tabOrGroup:GetScaledElementSize(1, 36)
		useScaledSize = true
	end

	-- Row container
	local row = Util.Create("Frame", {
		Name = "ButtonRow",
		Parent = container,
		BackgroundTransparency = 1,
		Size = buttonSize,
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

	return self
end

return Button
