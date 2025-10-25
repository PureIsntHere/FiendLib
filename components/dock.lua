-- Fiend/components/dock.lua
-- Side dock rail that mirrors tabs as icon buttons.
-- Square buttons, even spacing when tall; scrolls when short.

local Util = require(script.Parent.Parent.lib.util)

local Dock = {}
Dock.__index = Dock

function Dock.new(window)
	local self = setmetatable({}, Dock)
	self.Window       = window
	self._buttons     = {}
	self.ButtonSize   = 44     -- square
	self.MinGap       = 8
	self.MaxGap       = 36
	self.EdgePad      = 8

	local rail = Instance.new("Frame")
	rail.Name = "DockRail"
	rail.BackgroundColor3 = window.Theme.Background2
	rail.BorderSizePixel  = 0
	rail.Size             = UDim2.new(0, 56, 1, 0)
	rail.Visible          = false
	rail.ZIndex           = 3
	rail.ClipsDescendants = true
	self.Rail = rail

	Util.CreateUICorner(rail, window.Theme.Corner)
	Util.CreateUIStroke(rail, window.Theme.Border, window.Theme.LineThickness)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "ButtonsScroll"
	scroll.Parent = rail
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Size = UDim2.fromScale(1,1)
	scroll.ScrollBarThickness = 4
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0,0,0,0)
	scroll.ClipsDescendants = true
	self.Scroll = scroll

	local pad = Instance.new("UIPadding")
	pad.PaddingTop    = UDim.new(0, self.EdgePad)
	pad.PaddingBottom = UDim.new(0, self.EdgePad)
	pad.PaddingLeft   = UDim.new(0, 6)
	pad.PaddingRight  = UDim.new(0, 6)
	pad.Parent = scroll
	self.Padding = pad

	local list = Instance.new("UIListLayout")
	list.FillDirection        = Enum.FillDirection.Vertical
	list.HorizontalAlignment  = Enum.HorizontalAlignment.Center
	list.VerticalAlignment    = Enum.VerticalAlignment.Top
	list.SortOrder            = Enum.SortOrder.LayoutOrder
	list.Padding              = UDim.new(0, self.MinGap)
	list.Parent = scroll
	self.List = list

	rail.Parent = window.Shell
	self._szConn = rail:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:_reflow() end)
	return self
end

function Dock:AnchorToShell(shell, titlebarHeight, pad)
	if not self.Rail or not shell then return end
	self.Rail.Parent   = shell
	self.Rail.Position = UDim2.new(0, pad, 0, titlebarHeight + pad)
	self.Rail.Size     = UDim2.new(0, self.Rail.Size.X.Offset, 1, -(titlebarHeight + pad*2))
	self:_reflow()
end

function Dock:SetVisible(b)
	if self.Rail then self.Rail.Visible = (b and true or false) end
end

function Dock:Destroy()
	if self._szConn then self._szConn:Disconnect() end
	if self.Rail then self.Rail:Destroy() end
	self._buttons = {}
end

function Dock:SyncFromTabs(window)
	if not (self.Rail and self.Scroll) then return end
	for _, pack in pairs(self._buttons) do
		if pack.Button then pack.Button:Destroy() end
	end
	self._buttons = {}

	for _, tab in ipairs(window.Tabs) do
		local ico = (tab.Icon and tostring(tab.Icon) ~= "" and tab.Icon) or "•"

		local btn = Instance.new("TextButton")
		btn.Name = "DockTab_"..tab.Name
		btn.Parent = self.Scroll
		btn.Size = UDim2.new(0, self.ButtonSize, 0, self.ButtonSize)
		btn.AutoButtonColor = false
		btn.Text = ico
		btn.TextSize = 18
		btn.Font = window.Theme.FontMono or Enum.Font.Code
		btn.TextColor3 = window.Theme.SubTextColor
		btn.BackgroundColor3 = window.Theme.Background
		btn.BorderSizePixel = 0
		btn.ZIndex = 4

		Util.CreateUICorner(btn, window.Theme.Corner)
		local stroke = Util.CreateUIStroke(btn, window.Theme.Border, window.Theme.LineThickness)

		btn.MouseButton1Click:Connect(function()
			window:ShowTab(tab.Name)
		end)

		self._buttons[tab.Name] = { Button = btn, Stroke = stroke }
	end

	self:_reflow()
	self:Highlight(window.ActiveTab and window.ActiveTab.Name)
end

function Dock:Highlight(tabName)
	for name, pack in pairs(self._buttons) do
		local selected = (name == tabName)
		if pack.Button then
			pack.Button.TextColor3 = selected and self.Window.Theme.TextColor or self.Window.Theme.SubTextColor
		end
		if pack.Stroke then
			pack.Stroke.Color = selected and self.Window.Theme.Accent or self.Window.Theme.Border
		end
	end
end

-- Even distribution when tall; enable scroll when short.
function Dock:_reflow()
	if not (self.Rail and self.Scroll and self.List and self.Padding) then return end
	local n = 0
	for _, ch in ipairs(self.Scroll:GetChildren()) do
		if ch:IsA("TextButton") then n += 1 end
	end
	if n == 0 then
		self.Scroll.ScrollingEnabled = false
		return
	end

	local railH  = self.Rail.AbsoluteSize.Y
	local minPad = self.EdgePad
	local minGap = self.MinGap
	local btnH   = self.ButtonSize

	local minTotal = (n * btnH) + ((n - 1) * minGap) + (minPad * 2)

	if railH >= minTotal then
		local free = railH - (n * btnH)
		local gap  = math.clamp(math.floor(free / (n + 1)), minGap, self.MaxGap)
		self.Padding.PaddingTop    = UDim.new(0, gap)
		self.Padding.PaddingBottom = UDim.new(0, gap)
		self.List.Padding          = UDim.new(0, gap)
		self.Scroll.ScrollingEnabled = false
	else
		self.Padding.PaddingTop    = UDim.new(0, minPad)
		self.Padding.PaddingBottom = UDim.new(0, minPad)
		self.List.Padding          = UDim.new(0, minGap)
		self.Scroll.ScrollingEnabled = true
		self.Scroll.CanvasPosition = Vector2.new(0,0)
	end
end

return Dock
