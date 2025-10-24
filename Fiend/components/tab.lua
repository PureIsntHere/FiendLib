-- Fiend/components/tab
local Utils     = require(script.Parent.Parent.lib.utils)
local Safety    = require(script.Parent.Parent.lib.safety)
local Tween     = require(script.Parent.Parent.lib.tween)

local Button    = require(script.Parent.button)
local Toggle    = require(script.Parent.toggle)
local Slider    = require(script.Parent.slider)
local Dropdown  = require(script.Parent.dropdown)

local Tab = {}
Tab.__index = Tab

local function R(prefix)
	prefix = prefix or "Node"
	if Safety and Safety.RandomChildName then
		return Safety.RandomChildName(prefix)
	end
	return string.format("%s_%06d", prefix, math.random(0, 999999))
end

function Tab.new(window, name, icon)
	local theme = window.Theme

	local self = setmetatable({
		Window    = window,
		Theme     = window.Theme,
		Name      = name or "Tab",
		Icon      = icon or "●",
		Id        = (name or "tab"):gsub("%s+","_"):lower() .. "_" .. math.random(1000,9999),
		_button   = nil,
		Container = nil,
	}, Tab)

	-- Top pill button
	local btn = Instance.new("TextButton")
	btn.Name = R("TabBtn")
	btn.AutoButtonColor = false
	btn.Text = self.Name
	btn.Font = theme.Font
	btn.TextSize = 14
	btn.TextColor3 = theme.Foreground
	btn.BackgroundColor3 = theme.Background
	btn.BackgroundTransparency = 0.25
	btn.Size = UDim2.fromOffset(130, 28)
	btn.ZIndex = 5
	btn.Parent = window.TabBar

	local bc = Instance.new("UICorner"); bc.CornerRadius = theme.Corner; bc.Parent = btn
	local bs = Utils:Stroke(btn, theme.Foreground, 1, 0.8)

	btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.1}, 0.08) end)
	btn.MouseLeave:Connect(function()
		if window._active ~= self then Tween(btn, {BackgroundTransparency = 0.25}, 0.08) end
	end)
	btn.Activated:Connect(function() window:_switchTo(self) end)
	self._button = btn

	-- Content container
	local container = Instance.new("Frame")
	container.Name = R("TabContent")
	container.BackgroundTransparency = 1
	container.Size = UDim2.fromScale(1,1)
	container.Visible = false
	container.ZIndex = 3
	container.Parent = window.Content
	Utils:VList(container, 10)
	self.Container = container

	return self
end

function Tab:Show()
	self.Container.Visible = true
	Tween(self._button, {BackgroundTransparency = 0.05}, 0.08)
end

function Tab:Hide()
	self.Container.Visible = false
	Tween(self._button, {BackgroundTransparency = 0.25}, 0.08)
end

function Tab:Activate()
	self.Window:_switchTo(self)
end

-- Components expect a TAB (with .Theme and .Container), so pass self
function Tab:AddButton(text, cb)          return Button.new(self, text, cb) end
function Tab:AddToggle(text, default, cb) return Toggle.new(self, text, default, cb) end
function Tab:AddSlider(text, min, max, default, cb)
	return Slider.new(self, text, min, max, default, cb)
end
function Tab:AddDropdown(text, list, default, cb)
	return Dropdown.new(self, text, list, default, cb)
end

return Tab
