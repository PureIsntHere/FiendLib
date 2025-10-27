-- Fiend/components/window.lua
-- Window manager with dock modes, scrollable top tabs, and rock-solid layout.

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Util = FiendModules.Util
local Theme = FiendModules.Theme
local Safety = FiendModules.Safety
local Behaviors = FiendModules.Behaviors
local FX = FiendModules.FX

local Dock      = FiendModules.Dock
local KeySystem = FiendModules.KeySystem

local Window = {}
Window.__index = Window

export type DockMode = "DockOnly" | "SizeDependent" | "AlwaysOff" | "Both"

local TITLEBAR_H = 36

local function getDockWidth(self)
	local rail = self._dock and self._dock.Rail
	if rail and rail.Visible then
		return math.max(56, rail.AbsoluteSize.X)
	end
	return 0
end

local function decideVisibility(self)
	local w = self.Shell and self.Shell.AbsoluteSize.X or self.Width
	local threshold = self.ResponsiveThreshold or 640
	local mode = self.DockMode

	if mode == "DockOnly"   then return true,  false end
	if mode == "AlwaysOff"  then return false, true  end
	if mode == "Both"       then return true,  true  end
	-- SizeDependent
	return (w < threshold), (w >= threshold)
end

local function realign(self)
	if not self.Shell then return end

	local showDock, showTopbar = decideVisibility(self)
	self._showDock, self._showTopbar = showDock, showTopbar

	-- Dock rail
	if self._dock then
		self._dock:SetVisible(showDock)
		self._dock:AnchorToShell(self.Shell, TITLEBAR_H, self.Theme.Padding)
	end

	-- top tabs bar
	local pillH   = (self.Theme.Tab and self.Theme.Tab.PillHeight or 22)
	local tabsRow = showTopbar and (pillH + 8) or 0
	local leftPad = self.Theme.Padding + (showDock and getDockWidth(self) or 0)

	self.TabsBar.Visible = showTopbar
	if self.TabsBar.Visible then
		self.TabsBar.Position = UDim2.new(0, leftPad, 0, TITLEBAR_H + self.Theme.Padding)
		self.TabsBar.Size     = UDim2.new(1, -(leftPad + self.Theme.Padding), 0, tabsRow)
	end

	local topOffset = TITLEBAR_H + self.Theme.Padding + tabsRow

	if not self.Container then
		self.Container = Util.Create("Frame", {
			Name = "Container",
			Parent = self.Shell,
			BackgroundColor3 = (self.Theme.Window and self.Theme.Window.Background) or self.Theme.Background,
			BorderSizePixel  = 0,
			Position = UDim2.new(0, leftPad, 0, topOffset),
			Size     = UDim2.new(1, -(leftPad + self.Theme.Padding), 1, -(topOffset + self.Theme.Padding)),
			ZIndex   = 2,
		})
		Util.CreateUICorner(self.Container, self.Theme.Corner)
		Util.CreateUIStroke(self.Container, self.Theme.Border, self.Theme.LineThickness)
		if self.Theme.EnableGridBG then
			self.GridBG = FX.AttachGrid(self.Container, self.Theme, { gap = 16, alpha = 0.06 })
		end
		if self.Theme.EnableBrackets then
			self.BracketsContainer = FX.AddCornerBrackets(self.Container, self.Theme)
		end
	else
		self.Container.Position = UDim2.new(0, leftPad, 0, topOffset)
		self.Container.Size     = UDim2.new(1, -(leftPad + self.Theme.Padding), 1, -(topOffset + self.Theme.Padding))
	end
end

local function build_shell(self)
	self.Root = Safety.GetRoot()
	self.FloatLayer = Safety.GetFloatLayer()

	-- Shell
	self.Shell = Util.Create("Frame", {
		Name = "Fiend_Shell",
		Parent = self.Root,
		BackgroundColor3 = self.Theme.Background,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(self.Width, self.Height),
		Position = UDim2.new(0, 48, 0, 48),
		ZIndex = 1,
	})
	Util.CreateUICorner(self.Shell, self.Theme.Corner)
	Util.CreateUIStroke(self.Shell, self.Theme.Border, self.Theme.LineThickness)

	-- Titlebar
	self.TitleBar = Util.Create("Frame", {
		Name = "TitleBar",
		Parent = self.Shell,
		BackgroundColor3 = (self.Theme.Window and self.Theme.Window.Background) or self.Theme.Background2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, TITLEBAR_H),
		ZIndex = 2,
	})
	Util.CreateUIStroke(self.TitleBar, (self.Theme.Window and self.Theme.Window.Border) or self.Theme.Border, self.Theme.LineThickness)

	Util.Create("TextLabel", {
		Name = "Title",
		Parent = self.TitleBar,
		BackgroundTransparency = 1,
		Font = self.Theme.FontMono or Enum.Font.Code,
		Text = string.format("%s  —  %s", self.Title, self.SubTitle or ""),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 16,
		TextColor3 = (self.Theme.Window and self.Theme.Window.TitleText) or self.Theme.Foreground,
		Size = UDim2.new(1, -64, 1, 0),
		Position = UDim2.new(0, self.Theme.Padding, 0, 0),
	})

	local minBtn = Util.Create("TextButton", {
		Name = "Min",
		Parent = self.TitleBar,
		Text = "—",
		Font = self.Theme.FontMono or Enum.Font.Code,
		TextSize = 18,
		TextColor3 = (self.Theme.Window and self.Theme.Window.TitleText) or self.Theme.Foreground,
		BackgroundColor3 = (self.Theme.Window and self.Theme.Window.Background) or self.Theme.Background2,
		BackgroundTransparency = 0.8,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 36, 1, 0),
		Position = UDim2.new(1, -36, 0, 0),
	})
	Util.CreateUICorner(minBtn, self.Theme.Corner)
	
	-- Add hover effects to make the button more visible
	minBtn.MouseEnter:Connect(function()
		Util.Tween(minBtn, {
			BackgroundTransparency = 0.3,
			TextColor3 = self.Theme.Accent
		}, 0.15)
	end)
	
	minBtn.MouseLeave:Connect(function()
		Util.Tween(minBtn, {
			BackgroundTransparency = 0.8,
			TextColor3 = self.Theme.Foreground
		}, 0.15)
	end)
	minBtn.MouseButton1Click:Connect(function()
		if self.Minimized then
			self:Restore()
		else
			self:Minimize()
		end
	end)

	-- FX
	if self.Theme.EnableTopSweep then
		self.TopSweepHandle = FX.AttachTopSweep(self.Shell, self.TitleBar, self.Theme, {speed=180, length=120, gap=24})
	end
	if self.Theme.EnableScanlines then
		self.ScanlinesHandle = FX.AttachScanlines(self.Shell, self.Theme, {speed=110})
	end
	if self.Theme.EnableBrackets then
		self.BracketsShell = FX.AddCornerBrackets(self.Shell, self.Theme)
	end

	-- Dock
	self._dock = Dock.new(self)               -- creates rail & buttons holder
	self._dock:AnchorToShell(self.Shell, TITLEBAR_H, self.Theme.Padding)

	-- Tabs bar (horizontal, scrollable)
	self.TabsBar = Instance.new("ScrollingFrame")
	self.TabsBar.Name = "TabsBar"
	self.TabsBar.Parent = self.Shell
	self.TabsBar.BackgroundTransparency = 1
	self.TabsBar.BorderSizePixel = 0
	self.TabsBar.ZIndex = 3
	self.TabsBar.ClipsDescendants = false -- Allow tab borders to show properly
	self.TabsBar.ScrollBarThickness = 0
	self.TabsBar.ScrollingDirection = Enum.ScrollingDirection.X
	self.TabsBar.AutomaticCanvasSize = Enum.AutomaticSize.X

	local tl = Instance.new("UIListLayout")
	tl.FillDirection = Enum.FillDirection.Horizontal
	tl.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tl.SortOrder = Enum.SortOrder.LayoutOrder
	tl.Padding = UDim.new(0, 8) -- Increased padding for better border visibility
	tl.Parent = self.TabsBar
	
	-- Add padding to prevent border clipping
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.PaddingTop = UDim.new(0, 2)
	padding.PaddingBottom = UDim.new(0, 2)
	padding.Parent = self.TabsBar

	-- wire updates
	self._realignConn1 = self.Shell:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() realign(self) end)
	if self._dock and self._dock.Rail then
		self._realignConn2 = self._dock.Rail:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() realign(self) end)
		self._realignConn3 = self._dock.Rail:GetPropertyChangedSignal("Visible"):Connect(function() realign(self) end)
	end

	realign(self)

	-- drag + resize
	Behaviors.MakeDraggable(self.TitleBar, self.Shell, TITLEBAR_H)
	Behaviors.AddResizeGrip(self.Shell, self.Theme, self.MinSize, self.MaxSize)

	-- ready callbacks
	-- Don't set Visible = true here - let the caller control visibility
	for _, fn in ipairs(self._readyQueue) do task.spawn(fn, self) end
	table.clear(self._readyQueue)
end

function Window.new(opts)
	opts = opts or {}
	local self = setmetatable({}, Window)

	self.Title      = opts.Title or "ARCHFIEND"
	self.SubTitle   = opts.SubTitle or ""
	self.Width      = math.clamp(tonumber(opts.Width) or 760, 540, 1600)
	self.Height     = math.clamp(tonumber(opts.Height) or 480, 360, 1200)
	self.MinSize    = opts.MinSize or Vector2.new(540, 360)
	self.MaxSize    = opts.MaxSize or Vector2.new(1920, 1200)
	self.DockMode   = (opts.DockMode :: DockMode) or "SizeDependent"
	self.ResponsiveThreshold = tonumber(opts.ResponsiveThreshold) or 640
	-- Merge theme properly
	local mergedTheme = {}
	for k, v in pairs(Theme) do
		mergedTheme[k] = v
	end
	if opts.Theme then
		for k, v in pairs(opts.Theme) do
			mergedTheme[k] = v
		end
	end
	self.Theme = mergedTheme
	self.Visible    = false
	self.Minimized  = false
	self.Tabs       = {}
	self.ActiveTab  = nil
	self._readyQueue= {}
	self._minimizeBox = nil

	-- Initialize keysystem
	self.KeySystem = KeySystem.new({
		Theme = self.Theme,
		GlobalKeyCapture = true,
		DebugMode = false
	})

	-- key gate - SECURITY: Only build shell after key validation
	local ks = opts.KeySystem
	if ks and ks.Enabled then
		-- Don't build shell until key is validated
		self.KeySystem:ShowPrompt({
			Title     = ks.Title or (self.Title .. "  —  Showcase"),
			Hint      = ks.Hint or "Enter your access key to continue.",
			Key       = ks.Key,
			Check     = ks.Check,
			OnSuccess = function() 
				build_shell(self)
				-- Make sure the window is visible after key validation
				self.Visible = true
				if self.Shell then
					self.Shell.Visible = true
				end
			end,
			OnFail    = ks.OnFail,
			Theme     = self.Theme,
			MaxAttempts = ks.MaxAttempts or 3
		})
	else
		build_shell(self)
		-- Set visible for non-key system windows
		self.Visible = true
		if self.Shell then
			self.Shell.Visible = true
		end
	end
	
	-- Auto-register with Fiend for theme tracking
	if _G.FiendInstance and _G.FiendInstance._trackElement then
		_G.FiendInstance:_trackElement(self)
	end

	return self
end

function Window:OnReady(fn)
	if self.Visible then task.spawn(fn, self) else table.insert(self._readyQueue, fn) end
end

function Window:SetVisible(b)
	self.Visible = (b and true or false)
	if self.Shell then self.Shell.Visible = self.Visible end
end

function Window:AddTab(name, icon)
	-- create pill + content via tab module
	local Tab = FiendModules.Tab
	local t = Tab.new(self, name, icon)
	table.insert(self.Tabs, t)

	-- mirror to dock
	if self._dock then self._dock:SyncFromTabs(self) end

	-- show the first tab by default
	if not self.ActiveTab then self:ShowTab(name) end

	realign(self)
	return t
end

function Window:ShowTab(name)
	for _, t in ipairs(self.Tabs) do t:Hide() end
	for _, t in ipairs(self.Tabs) do
		if t.Name == name then t:Show(); self.ActiveTab = t; break end
	end
	-- update dock selection highlight
	if self._dock then self._dock:Highlight(name) end
end

function Window:SetFxEnabled(effectName, enabled)
	if effectName == "Scanlines" then
		if enabled and not self.ScanlinesHandle then
			self.ScanlinesHandle = FX.AttachScanlinesTween(self.Shell, self.Theme, {speed=0.45})
		elseif not enabled and self.ScanlinesHandle then
			self.ScanlinesHandle.Destroy(); self.ScanlinesHandle = nil
		end
	elseif effectName == "TopSweep" then
		if enabled and not self.TopSweepHandle then
			self.TopSweepHandle = FX.AttachTopSweep(self.Shell, self.TitleBar, self.Theme, {speed=180, length=120, gap=24})
		elseif not enabled and self.TopSweepHandle then
			self.TopSweepHandle.Destroy(); self.TopSweepHandle = nil
		end
	end
end

function Window:Minimize()
	if self.Minimized or not self.Shell then return end
	
	self.Minimized = true
	self.Visible = false
	
	-- Hide the main shell
	self.Shell.Visible = false
	
	-- Create minimize box
	self:_createMinimizeBox()
end

function Window:Restore()
	if not self.Minimized then return end
	
	self.Minimized = false
	self.Visible = true
	
	-- Show the main shell
	self.Shell.Visible = true
	
	-- Destroy minimize box
	if self._minimizeBox then
		self._minimizeBox:Destroy()
		self._minimizeBox = nil
	end
	
	-- Bring to front by increasing ZIndex
	if self.Shell then 
		self.Shell.ZIndex = self.Shell.ZIndex + 1
	end
end

function Window:_createMinimizeBox()
	if self._minimizeBox then return end
	
	-- Create the minimize box GUI
	local sg = Instance.new("ScreenGui")
	sg.Name = "FiendMinimizeBox_" .. self.Title
	sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
	sg.DisplayOrder = 1000
	sg.Parent = self.Root
	
	-- Create the minimize box button
	local box = Instance.new("TextButton")
	box.Name = "MinimizeBox"
	box.Size = UDim2.fromOffset(60, 40)
	box.BackgroundColor3 = self.Theme.Background2
	box.BorderSizePixel = 0
	box.AutoButtonColor = false
	box.Text = ""
	box.Parent = sg
	
	-- Position the box near the original window position
	local originalPos = self.Shell.Position
	box.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 20, originalPos.Y.Scale, originalPos.Y.Offset + 20)
	
	-- Apply styling
	Util.CreateUICorner(box, self.Theme.Corner)
	Util.CreateUIStroke(box, self.Theme.Border, self.Theme.LineThickness)
	
	-- Add the "</A/>" logo
	local logo = Instance.new("TextLabel")
	logo.Name = "Logo"
	logo.Size = UDim2.fromScale(1, 1)
	logo.BackgroundTransparency = 1
	logo.Text = "</A/>"
	logo.Font = self.Theme.FontMono or Enum.Font.Code
	logo.TextSize = 16
	logo.TextColor3 = self.Theme.TextColor
	logo.TextXAlignment = Enum.TextXAlignment.Center
	logo.TextYAlignment = Enum.TextYAlignment.Center
	logo.Parent = box
	
	-- Enhanced dragging with click detection
	local isDragging = false
	local dragStartPos = nil
	local dragThreshold = 5 -- pixels
	
	-- Handle mouse down to track drag start
	box.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
			dragStartPos = input.Position
		end
	end)
	
	-- Handle mouse move to detect dragging
	box.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragStartPos then
			local currentPos = input.Position
			local distance = math.sqrt((currentPos.X - dragStartPos.X)^2 + (currentPos.Y - dragStartPos.Y)^2)
			
			if distance > dragThreshold then
				isDragging = true
			end
		end
	end)
	
	-- Handle mouse up to restore only if not dragging
	box.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not isDragging then
				self:Restore()
			end
			isDragging = false
			dragStartPos = nil
		end
	end)
	
	-- Use the enhanced dragging function
	Behaviors.MakeDraggable(box, box)
	
	-- Hover effects
	box.MouseEnter:Connect(function()
		Util.Tween(box, {BackgroundColor3 = self.Theme.Background}, 0.15)
	end)
	box.MouseLeave:Connect(function()
		Util.Tween(box, {BackgroundColor3 = self.Theme.Background2}, 0.15)
	end)
	
	self._minimizeBox = sg
end

function Window:Toggle()
	self:SetVisible(not self.Visible)
end

function Window:RefreshTheme()
	-- Get current theme from library
	local currentTheme = self.Theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		currentTheme = _G.FiendInstance.Theme
	end
	
	if currentTheme then
		-- Update stored theme reference
		self.Theme = currentTheme
		
		-- Update shell background and border
		if self.Shell then
			self.Shell.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background
			local shellStroke = self.Shell:FindFirstChild("UIStroke")
			if shellStroke then
				shellStroke.Color = (currentTheme.Window and currentTheme.Window.Border) or currentTheme.Border
				shellStroke.Thickness = currentTheme.LineThickness or 1
			end
		end
		
		-- Update title bar
		if self.TitleBar then
			self.TitleBar.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background2
			local titleBarStroke = self.TitleBar:FindFirstChild("UIStroke")
			if titleBarStroke then
				titleBarStroke.Color = (currentTheme.Window and currentTheme.Window.Border) or currentTheme.Border
				titleBarStroke.Thickness = currentTheme.LineThickness or 1
			end
			
			-- Update title text
			local titleLabel = self.TitleBar:FindFirstChild("Title")
			if titleLabel then
				titleLabel.TextColor3 = (currentTheme.Window and currentTheme.Window.TitleText) or currentTheme.Foreground
			end
			
			-- Update minimize button
			local minBtn = self.TitleBar:FindFirstChild("Min")
			if minBtn then
				minBtn.TextColor3 = (currentTheme.Window and currentTheme.Window.TitleText) or currentTheme.Foreground
				minBtn.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background2
			end
		end
		
		-- Update container
		if self.Container then
			self.Container.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background
			local containerStroke = self.Container:FindFirstChild("UIStroke")
			if containerStroke then
				containerStroke.Color = (currentTheme.Window and currentTheme.Window.Border) or currentTheme.Border
				containerStroke.Thickness = currentTheme.LineThickness or 1
			end
		end
		
		-- Update tabs bar
		if self.TabsBar then
			self.TabsBar.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background
		end
		
		-- Update all tabs
		for _, tab in ipairs(self.Tabs) do
			if tab.RefreshTheme then
				tab:RefreshTheme()
			end
		end
		
		-- Update dock
		if self._dock and self._dock.RefreshTheme then
			self._dock:RefreshTheme()
		end
		
		-- Refresh FX effects with new theme
		self:RefreshFX()
	end
end

-- Refresh all FX effects with current theme
function Window:RefreshFX()
	local currentTheme = self.Theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		currentTheme = _G.FiendInstance.Theme
	end
	
	if not currentTheme then return end
	
	-- Destroy existing FX effects
	if self.ScanlinesHandle then
		self.ScanlinesHandle:Destroy()
		self.ScanlinesHandle = nil
	end
	
	if self.TopSweepHandle then
		self.TopSweepHandle:Destroy()
		self.TopSweepHandle = nil
	end
	
	if self.GridBG then
		self.GridBG:Destroy()
		self.GridBG = nil
	end
	
	if self.BracketsShell then
		self.BracketsShell:Destroy()
		self.BracketsShell = nil
	end
	
	if self.BracketsContainer then
		self.BracketsContainer:Destroy()
		self.BracketsContainer = nil
	end
	
	-- Recreate FX effects with new theme
	if self.Shell and self.TitleBar then
		-- Top sweep
		self.TopSweepHandle = FX.AttachTopSweep(self.Shell, self.TitleBar, currentTheme, {
			speed = (currentTheme.FX and currentTheme.FX.TopSweepSpeed) or 180,
			length = (currentTheme.FX and currentTheme.FX.TopSweepLength) or 120,
			gap = (currentTheme.FX and currentTheme.FX.TopSweepGap) or 24,
			thickness = (currentTheme.FX and currentTheme.FX.TopSweepThickness) or 2
		})
		
		-- Scanlines
		self.ScanlinesHandle = FX.AttachScanlines(self.Shell, currentTheme, {
			speed = (currentTheme.FX and currentTheme.FX.ScanlineSpeed) or 110
		})
		
		-- Corner brackets on shell
		self.BracketsShell = FX.AddCornerBrackets(self.Shell, currentTheme)
	end
	
	if self.Container then
		-- Grid background
		self.GridBG = FX.AttachGrid(self.Container, currentTheme, {
			gap = (currentTheme.FX and currentTheme.FX.GridGap) or 16,
			alpha = (currentTheme.FX and currentTheme.FX.GridAlpha) or 0.06
		})
		
		-- Corner brackets on container
		self.BracketsContainer = FX.AddCornerBrackets(self.Container, currentTheme)
	end
	
	print("[Window] FX effects refreshed with theme:", currentTheme.FX and "FX properties available" or "No FX properties")
end

function Window:Destroy()
	if self._minimizeBox then
		self._minimizeBox:Destroy()
		self._minimizeBox = nil
	end
	if self._realignConn1 then self._realignConn1:Disconnect() end
	if self._realignConn2 then self._realignConn2:Disconnect() end
	if self._realignConn3 then self._realignConn3:Disconnect() end
	if self._dock then self._dock:Destroy() end
	if self.ScanlinesHandle then self.ScanlinesHandle.Destroy() end
	if self.TopSweepHandle then self.TopSweepHandle.Destroy() end
	if self.BracketsShell then self.BracketsShell.Destroy() end
	if self.BracketsContainer then self.BracketsContainer.Destroy() end
	if self.GridBG then self.GridBG.Destroy() end
	if self.Shell then self.Shell:Destroy() end
	self.Visible = false
end

return Window
