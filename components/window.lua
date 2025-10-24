-- Fiend/components/window

local Tween     = require(script.Parent.Parent.lib.tween)
local Utils     = require(script.Parent.Parent.lib.utils)
local Fx        = require(script.Parent.Parent.lib.fx)
local Behaviors = require(script.Parent.Parent.lib.behaviors)
local KeyGate   = require(script.Parent.Parent.lib.keygate)
local Safety    = require(script.Parent.Parent.lib.safety)
local Dock      = require(script.Parent.dock)

local Tab      = require(script.Parent.tab)
local Button   = require(script.Parent.button)
local Toggle   = require(script.Parent.toggle)
local Slider   = require(script.Parent.slider)
local Dropdown = require(script.Parent.dropdown)

local Window = {}
Window.__index = Window

local function R(prefix)
	prefix = prefix or "Node"
	if Safety and Safety.RandomChildName then
		return Safety.RandomChildName(prefix)
	end
	return string.format("%s_%06d", prefix, math.random(0, 999999))
end

function Window.new(opts)
	local self = setmetatable({}, Window)

	self.Theme     = opts.Theme
	self.Title     = opts.Title or "FIEND_UI"
	self.SubTitle  = opts.SubTitle or "SYSTEM ONLINE"
	self.Size      = Vector2.new(opts.Width or 580, opts.Height or 360)
	self.MinSize   = opts.MinSize or Vector2.new(480, 260)
	self.MaxSize   = opts.MaxSize or Vector2.new(1400, 900)

	local keyCfg = opts.KeySystem or { Enabled = false }
	self.KeySystem = {
		Enabled = keyCfg.Enabled == true,
		Key     = keyCfg.Key or "123",
		Title   = keyCfg.Title or "ACCESS KEY REQUIRED",
		Hint    = keyCfg.Hint or "Enter key to continue."
	}

	self.GuiRoot    = Safety.GetRoot()
	self.Gui        = Safety.NewLayer({ Z = 50 })
	self.FloatLayer = Safety.GetFloatLayer()

	self.Shell   = nil
	self.Root    = nil
	self.TabBar  = nil
	self.TabList = nil
	self.Dock    = nil
	self.Content = nil
	self._tabs   = {}
	self._active = nil
	self._built  = false
	self._readyEvent = Instance.new("BindableEvent")

	if self.KeySystem.Enabled then
		KeyGate.Show(nil, self.Theme, self.KeySystem, function()
			self:_buildMainUI(true)
			self:_fireReady()
		end)
	else
		self:_buildMainUI(true)
		self:_fireReady()
	end
	return self
end

function Window:OnReady(cb) self._readyEvent.Event:Connect(function() task.spawn(cb, self) end) end
function Window:_fireReady() self._readyEvent:Fire() end

function Window:_buildMainUI(animate)
	if self._built then return end
	local theme = self.Theme

	local shell = Instance.new("Frame")
	shell.Name = R("Shell")
	shell.Size = UDim2.fromOffset(self.Size.X, self.Size.Y)
	shell.AnchorPoint = Vector2.new(0.5,0.5)
	shell.Position = UDim2.fromScale(0.5,0.5)
	shell.BackgroundColor3 = theme.Background
	shell.BackgroundTransparency = theme.BaseTransparency
	shell.ZIndex = 2
	shell.Parent = self.Gui
	Utils:Roundify(shell, theme.Corner)
	local shellStroke = Utils:Stroke(shell, theme.Foreground, 1.5, theme.StrokeTransparency)
	Fx.PulseStroke(shellStroke, theme)
	self.Shell = shell

	local root = Instance.new("Frame")
	root.Name = R("Root")
	root.BackgroundColor3 = theme.Background
	root.BackgroundTransparency = theme.BaseTransparency
	root.Size = UDim2.fromScale(1,1)
	root.ZIndex = 3
	root.ClipsDescendants = true
	root.Parent = shell
	Utils:Roundify(root, theme.Corner)
	self.Root = root

	if animate then
		local scale = Instance.new("UIScale"); scale.Scale = 0.96; scale.Parent = shell
		shell.BackgroundTransparency = 0.35
		Tween(scale, {Scale = 1}, 0.25, Enum.EasingStyle.Quad)
		Tween(shell, {BackgroundTransparency = theme.BaseTransparency}, 0.25)
		task.delay(0.3, function() scale:Destroy() end)
	end

	-- Title bar
	local title = Instance.new("Frame")
	title.Name = R("TitleBar")
	title.Size = UDim2.new(1,0,0,36)
	title.BackgroundColor3 = theme.Background
	title.BackgroundTransparency = 0.15
	title.ZIndex = 4
	title.Parent = root
	Utils:Stroke(title, theme.Foreground, 1, 0.8)
	Utils:Pad(title, theme.Pad)
	Utils:HList(title, 8)

	local tMain = Utils:Label({Text = self.Title, Parent = title, Theme = theme})
	tMain.Size = UDim2.new(0,0,1,0); tMain.AutomaticSize = Enum.AutomaticSize.XY; tMain.TextSize = 16
	local tSub = Utils:Label({Text = "— "..self.SubTitle, Parent = title, Theme = theme})
	tSub.Size = UDim2.new(0,0,1,0); tSub.AutomaticSize = Enum.AutomaticSize.XY; tSub.TextColor3 = theme.Muted
	Behaviors.MakeDraggable(title, shell)

	-- Scrollable TabBar
	local tabsScroll = Instance.new("ScrollingFrame")
	tabsScroll.Name = R("Tabs")
	tabsScroll.BackgroundTransparency = 1
	tabsScroll.ScrollingDirection = Enum.ScrollingDirection.X
	tabsScroll.ScrollBarImageTransparency = 0.7
	tabsScroll.ScrollBarThickness = 2
	tabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
	tabsScroll.Size = UDim2.new(1, -theme.Pad*2, 0, 28)
	tabsScroll.Position = UDim2.new(0, theme.Pad, 0, 44)
	tabsScroll.ZIndex = 4
	tabsScroll.Parent = root

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = tabsScroll

	self.TabBar  = tabsScroll
	self.TabList = list

	-- Content (initial position — responsive will correct immediately after)
	local content = Instance.new("Frame")
	content.Name = R("Content")
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -theme.Pad*2, 1, -(44 + 28 + theme.Pad*2))
	content.Position = UDim2.new(0, theme.Pad, 0, 44 + 28 + theme.Pad)
	content.ZIndex = 3
	content.Parent = root
	Utils:VList(content, 10)
	self.Content = content

	-- Dock (hidden by default; appears on small widths)
	self.Dock = Dock.new(self)

	self:_reattachFx()
	Behaviors.AddResizeGrip(shell, theme, self.MinSize, self.MaxSize)

	self:_wireResponsive()
	self._built = true
end

function Window:_wireResponsive()
	local TITLE_H = 36
	local TABS_H  = 28
	local P       = self.Theme.Pad or 10

	local function relayout()
		local w = self.Shell.AbsoluteSize.X
		local small = (w < 640)

		self.TabBar.Visible = not small
		self.Dock:SetVisible(small)

		if small then
			-- No tab row, left dock visible
			local y = 44 + P                 -- title(36) + 8gap + pad
			self.Content.Position = UDim2.new(0, 46 + P, 0, y)
			self.Content.Size     = UDim2.new(1, -(46 + P*2), 1, -(y + P))
		else
			-- Tab row shown
			local y = 44 + TABS_H + P
			self.Content.Position = UDim2.new(0, P, 0, y)
			self.Content.Size     = UDim2.new(1, -P*2, 1, -(y + P))
		end
	end

	self.Shell:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)
	task.defer(relayout)
end

function Window:_reattachFx()
	if self._fxTop  and self._fxTop.Destroy  then self._fxTop:Destroy()  end
	if self._fxScan and self._fxScan.Destroy then self._fxScan:Destroy() end
	if self._fxBrk  and self._fxBrk.Destroy  then self._fxBrk:Destroy()  end

	if self.Theme.EnableBrackets ~= false then
		self._fxBrk = Fx.AddCornerBrackets(self.Shell, self.Theme)
	end
	if self.Theme.EnableScanlines ~= false then
		self._fxScan = Fx.AttachScanlines(self.Root, self.Theme, self._scanCfg or {})
	end
	if not self.DisableTopSweep then
		local title = self.Root:FindFirstChildWhichIsA("Frame")
		if title then
			self._fxTop = Fx.AttachTopSweep(self.Root, title, self.Theme, self._sweepCfg or {})
		end
	end
end

function Window:SetFxEnabled(name, enabled)
	if name == "Scanlines" then
		self.Theme.EnableScanlines = enabled
	elseif name == "Brackets" then
		self.Theme.EnableBrackets = enabled
	elseif name == "TopSweep" then
		self.DisableTopSweep = not enabled
	elseif name == "PulseStroke" then
		self.Theme.EnablePulseStroke = enabled
	end
	self:_reattachFx()
end

function Window:SetSweepConfig(cfg)
	self._sweepCfg = self._sweepCfg or {}
	for k,v in pairs(cfg) do self._sweepCfg[k] = v end
	self:_reattachFx()
end

function Window:SetScanConfig(cfg)
	self._scanCfg = self._scanCfg or {}
	for k,v in pairs(cfg) do self._scanCfg[k] = v end
	self:_reattachFx()
end

local function ensureBuilt(self, api)
	if not self._built then
		error(("Fiend: '%s' called before UI is ready. Use window:OnReady(...)"):format(api), 2)
	end
end

function Window:AddTab(name, icon)
	ensureBuilt(self, "AddTab")
	local tab = Tab.new(self, name, icon)
	table.insert(self._tabs, tab)
	if self.Dock then self.Dock:AddTab(tab) end
	if not self._active then tab:Activate() end
	return tab
end

function Window:_switchTo(tab)
	if self._active == tab then return end
	if self._active then self._active:Hide() end
	self._active = tab
	tab:Show()

	-- highlight dock
	if self.Dock and self.Dock.Buttons and self.Dock.Buttons[tab] then
		self.Dock:Select(tab, self.Dock.Buttons[tab])
	end

	-- auto-scroll top tab into view
	if self.TabBar and tab._button then
		local absX  = tab._button.AbsolutePosition.X - self.TabBar.AbsolutePosition.X
		local right = absX + tab._button.AbsoluteSize.X
		local viewW = self.TabBar.AbsoluteSize.X
		if right > viewW then
			self.TabBar.CanvasPosition = Vector2.new(right - viewW + 16, 0)
		elseif absX < 0 then
			self.TabBar.CanvasPosition = Vector2.new(math.max(self.TabBar.CanvasPosition.X + absX - 16, 0), 0)
		end
	end
end

function Window:Destroy()
	if self._fxTop and self._fxTop.Destroy then self._fxTop:Destroy() end
	if self._fxScan and self._fxScan.Destroy then self._fxScan:Destroy() end
	if self._fxBrk and self._fxBrk.Destroy then self._fxBrk:Destroy() end
	if self.Gui then self.Gui:Destroy() end
end

return Window
