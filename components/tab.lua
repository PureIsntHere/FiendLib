-- Fiend/components/tab.lua
-- Pill tabs (top bar) + vertical scrolling content.

local Util = FiendModules.Util
local Button   = FiendModules.Button
local Toggle   = FiendModules.Toggle
local Slider   = FiendModules.Slider
local Dropdown = FiendModules.Dropdown
local TextInput = FiendModules.TextInput
local Notify    = FiendModules.Notify
local Group     = FiendModules.Group

local Tab = {}
Tab.__index = Tab

function Tab.new(window, name, icon)
	local self = setmetatable({}, Tab)
	self.Window    = window
	self.Name      = name
	self.Icon      = icon or ""
	self.Container = nil
	self.Groups    = {} -- Array of groups
	self.DefaultGroup = nil -- Default group for elements not assigned to specific groups

	local theme = window.Theme
	local bar   = window.TabsBar
	local pillH = (theme.Tab and theme.Tab.PillHeight or 22)
	local upper = (theme.Tab and theme.Tab.Uppercase) and string.upper(self.Name) or self.Name

	-- top pill
	local btn = Util.Create("TextButton", {
		Name = "Tab_"..upper,
		Parent = bar,
		Text = (self.Icon ~= "" and (self.Icon.." ") or "") .. upper,
		Font = theme.FontMono or Enum.Font.Code,
		TextSize = 14,
		TextColor3 = (theme.Tab and theme.Tab.IdleText) or theme.SubTextColor,
		AutoButtonColor = false,
		BackgroundColor3 = (theme.Tab and theme.Tab.IdleFill) or theme.Background2,
		BorderSizePixel = 0,
		Size = UDim2.new(0, math.max(70, upper:len()*7 + 24), 0, pillH),
		ZIndex = 4,
	})
	Util:Roundify(btn, theme.Corner)
	local stroke = Util:Stroke(btn, (theme.Tab and theme.Tab.Border) or theme.Border, theme.LineThickness)

	-- content
	local sc = Instance.new("ScrollingFrame")
	sc.Name = "TabContainer_"..self.Name
	sc.Parent = window.Container
	sc.BackgroundTransparency = 1
	sc.BorderSizePixel = 0
	sc.Size = UDim2.new(1, 0, 1, 0)
	sc.Visible = false
	sc.ScrollingDirection = Enum.ScrollingDirection.Y
	sc.ScrollBarThickness = 4
	sc.AutomaticCanvasSize = Enum.AutomaticSize.None -- Changed from Y to None for groups
	sc.CanvasSize = UDim2.new(1, 0, 1, 0) -- Fixed canvas size for groups
	sc.ClipsDescendants = true
	sc.ZIndex = 3

	local paddingPx = theme.Padding or 6
	local pad = Instance.new("UIPadding")
	pad.PaddingTop    = UDim.new(0, paddingPx)
	pad.PaddingBottom = UDim.new(0, paddingPx)
	pad.PaddingLeft   = UDim.new(0, paddingPx)
	pad.PaddingRight  = UDim.new(0, paddingPx)
	pad.Parent = sc

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Left
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = sc

	self.Container = sc
	self.ListLayout = list -- Store reference to list layout
	self.Icon      = icon or ""
	
	-- Add resize listener to update group layout when window resizes
	local resizeConnection
	resizeConnection = sc:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if #self.Groups > 0 then
			self:_updateGroupLayout()
		end
	end)
	
	-- Store connection for cleanup
	self._resizeConnection = resizeConnection

	local function setActive(active)
		if active then
			btn.TextColor3 = (theme.Tab and theme.Tab.ActiveText) or theme.TextColor
			btn.BackgroundColor3 = (theme.Tab and theme.Tab.ActiveFill) or theme.Background
			if stroke then stroke.Color = theme.Accent end
		else
			btn.TextColor3 = (theme.Tab and theme.Tab.IdleText) or theme.SubTextColor
			btn.BackgroundColor3 = (theme.Tab and theme.Tab.IdleFill) or theme.Background2
			if stroke then stroke.Color = theme.Border end
		end
	end

	btn.MouseEnter:Connect(function()
		if sc.Visible then return end
		Util.Tween(btn, { BackgroundColor3 = theme.Background }, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		if sc.Visible then return end
		Util.Tween(btn, { BackgroundColor3 = (theme.Tab and theme.Tab.IdleFill) or theme.Background2 }, 0.12)
	end)
	btn.MouseButton1Click:Connect(function()
		window:ShowTab(self.Name)
	end)

	function self:Show() sc.Visible = true; setActive(true) end
	function self:Hide() sc.Visible = false; setActive(false) end

	-- helpers
	function self:AddButton(text, callback)              return Button.new(self, text, callback) end
	function self:AddToggle(text, default, callback)     return Toggle.new(self, text, default, callback) end
	function self:AddSlider(text, min, max, default, cb) return Slider.new(self, text, min, max, default, cb) end
	function self:AddDropdown(label, list, def, cb)      return Dropdown.new(self, label, list, def, cb) end
	function self:AddTextInput(label, placeholder, default, callback) return TextInput.new(self, label, placeholder, default, callback) end
	function self:AddKeybind(label, keyCode, callback)    
		local Keybind = FiendModules.Keybind
		return Keybind.new(self, {
			Label = label,
			DefaultKey = keyCode,
			DefaultMode = "Hold",
			Callback = callback,
			Enabled = true
		})
	end
	
	function self:AddNotify(message, type)
		-- Create a simple notification that works with our tab structure
		local notify = Notify.new(self.Window.Theme)
		notify:AttachTo(self.Window.Root)
		notify:Push(message, 3)
		return notify
	end

	-- Group management methods
	function self:AddGroup(options)
		local group = Group.new(self, options)
		
		-- Add group to tab's group list
		if not self.Groups then
			self.Groups = {}
		end
		table.insert(self.Groups, group)
		
		-- If this is the first group, make it the default
		if #self.Groups == 1 then
			self.DefaultGroup = group
			-- Keep automatic sizing for elements outside groups
			self.Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
			self.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
		end
		
		-- Update layout immediately (this will check for mixed content and adjust)
		self:_updateGroupLayout()
		
		return group
	end
	
	function self:GetGroup(name)
		for _, group in ipairs(self.Groups) do
			if group.Name == name then
				return group
			end
		end
		return nil
	end
	
	function self:GetDefaultGroup()
		return self.DefaultGroup
	end
	
	-- Space division logic
	function self:_updateGroupLayout()
		local groupCount = #self.Groups
		if groupCount == 0 then return end
		
		-- Check if there are any children that are NOT groups (i.e., direct elements)
		local hasNonGroupChildren = false
		for _, child in ipairs(self.Container:GetChildren()) do
			if not child:IsA("UIListLayout") and not child:IsA("UIPadding") and not child.Name:match("^Group_") then
				hasNonGroupChildren = true
				break
			end
		end
		
		-- If there are non-group children, use list layout (LayoutOrder) instead of absolute positioning
		if hasNonGroupChildren then
			-- Count existing elements to place groups after them
			local elementCount = self._elementCounter or 0

			-- Groups should be sized to full width and stacked vertically
			for i, group in ipairs(self.Groups) do
				-- Set LayoutOrder to ensure proper stacking after existing elements
				group.Instance.LayoutOrder = elementCount + i
				-- Size to full width (like direct elements), auto height
				group.Instance.Size = UDim2.new(1, 0, 0, 0)  -- Full width, auto height
				-- Position should be 0,0 when using LayoutOrder - UIListLayout handles centering
				group.Instance.Position = UDim2.new(0, 0, 0, 0)
				-- Enable automatic size for height
				group.Instance.AutomaticSize = Enum.AutomaticSize.Y
			end
			return
		end
		
		-- If no non-group children, use the original grid layout
		-- Calculate grid layout based on number of groups
		local cols, rows = self:_calculateGridLayout(groupCount)
		
		-- Calculate cell size as scale (0-1)
		local cellWidth = 1 / cols
		local cellHeight = 1 / rows
		
		-- Debug logging
		print(string.format("[Group Layout] Groups: %d, Grid: %dx%d, Cell Scale: %.2fx%.2f", 
			groupCount, cols, rows, cellWidth, cellHeight))
		
		-- Position groups in grid using scale-based positioning
		for i, group in ipairs(self.Groups) do
			local col = (i - 1) % cols
			local row = math.floor((i - 1) / cols)
			
			-- Calculate position as scale (0-1)
			local x = col * cellWidth
			local y = row * cellHeight
			
			-- Debug logging
			print(string.format("[Group Layout] Group %d: col=%d, row=%d, pos=(%.2f,%.2f), size=(%.2f,%.2f)", 
				i, col, row, x, y, cellWidth, cellHeight))
			
            -- Reset LayoutOrder and disable AutomaticSize for absolute positioning
            -- Some engines disallow assigning nil to numeric properties
            group.Instance.LayoutOrder = 0
			group.Instance.AutomaticSize = Enum.AutomaticSize.None
			
			-- Set size and position using scale values
			group:_setSizeInternal(Vector2.new(cellWidth, cellHeight))
			group:_setPositionInternal(Vector2.new(x, y))
		end
	end
	
	function self:_calculateGridLayout(count)
		-- Determine optimal grid layout based on count
		if count == 1 then
			return 1, 1
		elseif count == 2 then
			return 2, 1 -- Side by side
		elseif count == 3 then
			return 2, 2 -- 2 smaller, 1 larger (2x2 grid, skip one)
		elseif count == 4 then
			return 2, 2 -- 2x2 grid
		elseif count <= 6 then
			return 3, 2 -- 3x2 grid
		elseif count <= 9 then
			return 3, 3 -- 3x3 grid
		else
			-- For more than 9 groups, use a larger grid
			local cols = math.ceil(math.sqrt(count))
			local rows = math.ceil(count / cols)
			return cols, rows
		end
	end
	
	-- Track element count for LayoutOrder
	self._elementCounter = 0
	self._groupCounter = 0
	
	-- Override element addition methods to use default group if no group specified
	local originalAddButton = self.AddButton
	local originalAddToggle = self.AddToggle
	local originalAddSlider = self.AddSlider
	local originalAddDropdown = self.AddDropdown
	local originalAddTextInput = self.AddTextInput
	local originalAddKeybind = self.AddKeybind
	
	function self:AddButton(text, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddButton(text, callback)
		else
			local element = originalAddButton(self, text, callback)
			-- Set LayoutOrder for proper stacking
			if element.Root then
				self._elementCounter = self._elementCounter + 1
				element.Root.LayoutOrder = self._elementCounter
			end
			return element
		end
	end
	
	function self:AddToggle(text, default, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddToggle(text, default, callback)
		else
			local element = originalAddToggle(self, text, default, callback)
			-- Set LayoutOrder for proper stacking
			if element.Root then
				self._elementCounter = self._elementCounter + 1
				element.Root.LayoutOrder = self._elementCounter
			end
			return element
		end
	end
	
	function self:AddSlider(text, min, max, default, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddSlider(text, min, max, default, callback)
		else
			local element = originalAddSlider(self, text, min, max, default, callback)
			-- Set LayoutOrder for proper stacking
			if element.Root then
				self._elementCounter = self._elementCounter + 1
				element.Root.LayoutOrder = self._elementCounter
			end
			return element
		end
	end
	
	function self:AddDropdown(label, list, default, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddDropdown(label, list, default, callback)
		else
			local element = originalAddDropdown(self, label, list, default, callback)
			-- Set LayoutOrder for proper stacking
			if element.Root then
				self._elementCounter = self._elementCounter + 1
				element.Root.LayoutOrder = self._elementCounter
			end
			return element
		end
	end
	
	function self:AddTextInput(label, placeholder, default, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddTextInput(label, placeholder, default, callback)
		else
			local element = originalAddTextInput(self, label, placeholder, default, callback)
			-- Set LayoutOrder for proper stacking
			if element.Root then
				self._elementCounter = self._elementCounter + 1
				element.Root.LayoutOrder = self._elementCounter
			end
			return element
		end
	end
	
	function self:AddKeybind(label, keyCode, callback)
		if self.DefaultGroup then
			return self.DefaultGroup:AddKeybind(label, keyCode, callback)
		else
			local element = originalAddKeybind(self, label, keyCode, callback)
			-- Set LayoutOrder for proper stacking
			if element.Root then
				self._elementCounter = self._elementCounter + 1
				element.Root.LayoutOrder = self._elementCounter
			end
			return element
		end
	end
	
	-- Auto-register with Fiend for theme tracking
	if _G.FiendInstance and _G.FiendInstance._trackElement then
		_G.FiendInstance:_trackElement(self)
	end

	return self
end

-- Cleanup method
function Tab:Destroy()
	if self._resizeConnection then
		self._resizeConnection:Disconnect()
		self._resizeConnection = nil
	end
	
	-- Destroy all groups
	for _, group in ipairs(self.Groups) do
		if group.Destroy then
			group:Destroy()
		end
	end
	
	-- Clear groups array
	table.clear(self.Groups)
	self.DefaultGroup = nil
	
	-- Re-enable list layout for traditional elements
	if self.ListLayout then
		self.ListLayout.Parent = self.Container
	end
	if self.Container then
		self.Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
		self.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
	end
end

function Tab:RefreshTheme()
	-- Get current theme from library
	local currentTheme = self.Window.Theme
	if _G.FiendInstance and _G.FiendInstance.Theme then
		currentTheme = _G.FiendInstance.Theme
	end
	
	if currentTheme then
		-- Update stored theme reference
		self.Window.Theme = currentTheme
		
		-- Update tab button
		if self.Button then
			local btn = self.Button
			local isActive = (self.Window.ActiveTab == self)
			
			if isActive then
				btn.TextColor3 = (currentTheme.Tab and currentTheme.Tab.ActiveText) or currentTheme.TextColor
				btn.BackgroundColor3 = (currentTheme.Tab and currentTheme.Tab.ActiveFill) or currentTheme.Background
			else
				btn.TextColor3 = (currentTheme.Tab and currentTheme.Tab.IdleText) or currentTheme.SubTextColor
				btn.BackgroundColor3 = (currentTheme.Tab and currentTheme.Tab.IdleFill) or currentTheme.Background2
			end
			
			-- Update border
			local stroke = btn:FindFirstChild("UIStroke")
			if stroke then
				stroke.Color = (currentTheme.Tab and currentTheme.Tab.Border) or currentTheme.Border
				stroke.Thickness = currentTheme.LineThickness or 1
			end
		end
		
		-- Update container background
		if self.Container then
			self.Container.BackgroundColor3 = (currentTheme.Window and currentTheme.Window.Background) or currentTheme.Background
		end
	end
end

return Tab
