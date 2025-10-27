-- Fiend/components/group.lua
-- Group component for organizing elements within tabs
-- Supports automatic space division based on number of groups

local Util = FiendModules.Util
local Theme = FiendModules.Theme
local BaseElement = FiendModules.BaseElement

local Group = {}
Group.__index = Group

export type GroupOptions = {
    Name: string,
    Size: Vector2?, -- {width, height} in grid units (1 = full width/height)
    Position: Vector2?, -- {x, y} grid position
    Theme: any?
}

function Group.new(tab, options: GroupOptions | string)
    -- Handle both new options format and legacy string format
    local opts: GroupOptions
    if typeof(options) == "string" then
        -- Legacy format: Group.new(tab, "Group Name")
        opts = {
            Name = options,
            Size = Vector2.new(1, 1), -- Default to full size
            Position = Vector2.new(0, 0) -- Default to top-left
        }
    else
        -- New format: Group.new(tab, options)
        opts = options or {}
        opts.Name = opts.Name or "Group"
        opts.Size = opts.Size or Vector2.new(1, 1)
        opts.Position = opts.Position or Vector2.new(0, 0)
    end
    
    local theme = opts.Theme or tab.Theme or Theme
    
    -- Create group container
    local groupFrame = Util.Create("Frame", {
        Name = "Group_" .. opts.Name,
        Parent = tab.Container,
        BackgroundColor3 = theme.Background2 or Color3.fromRGB(14, 14, 18),
        BackgroundTransparency = 1, -- Completely transparent
        BorderSizePixel = 0,
        Size = UDim2.new(opts.Size.X, 0, opts.Size.Y, 0),
        Position = UDim2.new(opts.Position.X, 0, opts.Position.Y, 0),
        ZIndex = 2
    })
    
    -- Add rounded corners and border
    Util.CreateUICorner(groupFrame, theme.Corner or UDim.new(0, 6))
    Util.CreateUIStroke(groupFrame, theme.Border or Color3.fromRGB(96, 98, 104), 1, 0.6)
    
    -- Add padding
    Util.CreateUIPadding(groupFrame, theme.Pad or UDim.new(0, 8))
    
    -- Create group header
    local header = Util.Create("Frame", {
        Name = "Header",
        Parent = groupFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        ZIndex = 3
    })
    
    -- Group title
    local title = Util.Create("TextLabel", {
        Name = "Title",
        Parent = header,
        BackgroundTransparency = 1,
        Text = opts.Name,
        Font = theme.FontMono or Enum.Font.Code,
        TextSize = 14,
        TextColor3 = theme.Foreground or Color3.fromRGB(230, 230, 232),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 4
    })
    
    -- Create content area
    local content = Util.Create("Frame", {
        Name = "Content",
        Parent = groupFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -24),
        Position = UDim2.new(0, 0, 0, 24),
        ZIndex = 3
    })
    
	-- Add vertical list layout for elements
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	-- Scaled padding - will update dynamically
	listLayout.Padding = UDim.new(0, 6)
	listLayout.Parent = content
    
    -- Create the group instance
    local self = setmetatable({
        Instance = groupFrame,
        Root = groupFrame,
        Tab = tab,
        Name = opts.Name,
        Content = content,
        Header = header,
        Title = title,
        Theme = theme,
        Size = opts.Size,
        Position = opts.Position,
        Elements = {}
    }, Group)
    
    -- Inherit from BaseElement (preserve Group methods)
    local groupMetatable = {__index = Group}
    local baseMetatable = {__index = BaseElement}
    setmetatable(self, groupMetatable)
    setmetatable(Group, baseMetatable)
    
    -- Initialize BaseElement
    BaseElement.new(self, {
        Theme = theme,
        Root = groupFrame
    })
    
    -- Auto-register with Fiend for theme tracking
    if _G.FiendInstance and _G.FiendInstance._trackElement then
        _G.FiendInstance:_trackElement(self)
    end
    
    -- Update padding based on size (after self is created)
    task.spawn(function()
        task.wait() -- Wait for initial sizing
        if self.Instance and self.Instance.AbsoluteSize.Y then
            local padding = math.max(6, math.floor(self.Instance.AbsoluteSize.Y * 0.03)) -- 3% of height, min 6px
            listLayout.Padding = UDim.new(0, padding)
        end
    end)
    
    -- Note: Group is added to tab.Groups by the tab's AddGroup method
    -- This prevents double-addition and ensures proper initialization order
    
    return self
end

-- Refresh theme for this group
function Group:RefreshTheme()
    -- Get current theme from library
    local currentTheme = self.Theme
    if _G.FiendInstance and _G.FiendInstance.Theme then
        currentTheme = _G.FiendInstance.Theme
    end
    
    if currentTheme then
        -- Update group frame
        if self.Root then
            self.Root.BackgroundColor3 = currentTheme.Background2 or currentTheme.Background
            
            -- Update border
            local stroke = self.Root:FindFirstChild("UIStroke")
            if stroke then
                stroke.Color = currentTheme.Border
                stroke.Thickness = currentTheme.LineThickness or 1
            end
            
            -- Update corner radius
            local corner = self.Root:FindFirstChild("UICorner")
            if corner then
                corner.CornerRadius = currentTheme.Corner or UDim.new(0, 6)
            end
        end
        
        -- Update title
        if self.Title then
            self.Title.TextColor3 = currentTheme.Foreground or currentTheme.TextColor
            self.Title.Font = currentTheme.FontMono or Enum.Font.Code
        end
        
        -- Update stored theme reference
        self.Theme = currentTheme
        
        -- Refresh all child elements
        for _, element in ipairs(self.Elements) do
            if element.RefreshTheme then
                element:RefreshTheme()
            end
        end
    end
end

-- Add elements to the group
function Group:AddButton(text, callback)
    local Button = FiendModules.Button
    local button = Button.new(self, text, callback)
    table.insert(self.Elements, button)
    return button
end

function Group:AddToggle(text, default, callback)
    local Toggle = FiendModules.Toggle
    local toggle = Toggle.new(self, text, default, callback)
    table.insert(self.Elements, toggle)
    return toggle
end

function Group:AddSlider(text, min, max, default, callback)
    local Slider = FiendModules.Slider
    local slider = Slider.new(self, text, min, max, default, callback)
    table.insert(self.Elements, slider)
    return slider
end

function Group:AddDropdown(label, list, default, callback)
    local Dropdown = FiendModules.Dropdown
    local dropdown = Dropdown.new(self, label, list, default, callback)
    table.insert(self.Elements, dropdown)
    return dropdown
end

function Group:AddTextInput(label, placeholder, default, callback)
    local TextInput = FiendModules.TextInput
    local textInput = TextInput.new(self, label, placeholder, default, callback)
    table.insert(self.Elements, textInput)
    return textInput
end

function Group:AddKeybind(label, keyCode, callback)
    local Keybind = FiendModules.Keybind
    local keybind = Keybind.new(self, {
        Label = label,
        DefaultKey = keyCode,
        DefaultMode = "Hold",
        Callback = callback,
        Enabled = true
    })
    table.insert(self.Elements, keybind)
    return keybind
end

-- Get proportional element size based on group's actual size
function Group:GetScaledElementSize(baseWidth, baseHeight)
	-- baseWidth is typically 1 for full width
	-- baseHeight is the preferred height in pixels (e.g., 36 for buttons)
	
	-- Get the group's actual absolute size
	local groupAbsSize = self.Instance and self.Instance.AbsoluteSize or Vector2.new(200, 200)
	
	-- Calculate proportional height based on group size
	-- Scale based on available content area (minus header and padding)
	local headerHeight = 24
	local padding = 16 -- top + bottom padding
	local contentAreaHeight = groupAbsSize.Y - headerHeight - padding
	
	-- Count how many elements we already have to better distribute space
	local elementCount = #self.Elements
	local estimatedElements = math.max(elementCount, 4) -- Assume at least 4 elements
	
	-- Scale height based on available space and element count
	local heightPerElement = contentAreaHeight / estimatedElements
	local scaledHeight = math.min(heightPerElement * 0.9, baseHeight * 0.12) -- Cap at 12% of base or element height
	
	-- Ensure reasonable minimum size
	scaledHeight = math.max(scaledHeight, baseHeight * 0.6)
	
	-- Don't go above base size
	scaledHeight = math.min(scaledHeight, baseHeight)
	
	return UDim2.new(baseWidth, 0, 0, math.floor(scaledHeight))
end

-- Get scaled padding based on group size
function Group:GetScaledPadding()
	local absSize = self.Instance.AbsoluteSize
	local basePadding = 8
	local minPadding = basePadding * 0.5
	local maxPadding = basePadding * 1.5
	
	-- Scale padding based on group height
	local scale = math.clamp(absSize.Y / 400, 0.5, 1.5) -- Reference height of 400px
	return basePadding * scale
end

-- Refresh all element sizes when group is resized
function Group:RefreshElementSizes()
	for _, element in ipairs(self.Elements) do
		if element._row and type(element._row.Size) == "UDim2" then
			local newSize = self:GetScaledElementSize(1, 36)
			element._row.Size = newSize
		end
	end
end

-- Set group size and position
function Group:SetSize(size: Vector2)
	self.Size = size
	self.Instance.Size = UDim2.new(size.X, 0, size.Y, 0)
	self.Tab:_updateGroupLayout()
end

function Group:SetPosition(position: Vector2)
	self.Position = position
	self.Instance.Position = UDim2.new(position.X, 0, position.Y, 0)
	self.Tab:_updateGroupLayout()
end

-- Internal methods that don't trigger layout updates
function Group:_setSizeInternal(size: Vector2)
	self.Size = size
	-- Ensure size components are valid numbers
	local x = size and size.X or 1
	local y = size and size.Y or 1
	self.Instance.Size = UDim2.new(x, 0, y, 0)
end

function Group:_setPositionInternal(position: Vector2)
	self.Position = position
	-- Ensure position components are valid numbers
	local x = position and position.X or 0
	local y = position and position.Y or 0
	self.Instance.Position = UDim2.new(x, 0, y, 0)
end

-- Set group title
function Group:SetTitle(title: string)
    self.Name = title
    self.Title.Text = title
end

-- Show/hide group
function Group:SetVisible(visible: boolean)
    self.Instance.Visible = visible
end

-- Get group info
function Group:GetSize(): Vector2
    return self.Size
end

function Group:GetPosition(): Vector2
    return self.Position
end

function Group:GetElements()
    return self.Elements
end

-- Destroy group
function Group:Destroy()
    -- Remove from tab's group list
    if self.Tab and self.Tab.Groups then
        for i, group in ipairs(self.Tab.Groups) do
            if group == self then
                table.remove(self.Tab.Groups, i)
                break
            end
        end
    end
    
    -- Destroy all elements
    for _, element in ipairs(self.Elements) do
        if element.Destroy then
            element:Destroy()
        elseif element.Instance then
            element.Instance:Destroy()
        end
    end
    
    -- Destroy the group frame
    if self.Instance then
        self.Instance:Destroy()
    end
end

return Group
