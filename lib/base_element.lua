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
		local Util = FiendModules.Util
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
		local Util = FiendModules.Util
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
