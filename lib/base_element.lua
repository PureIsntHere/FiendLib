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
