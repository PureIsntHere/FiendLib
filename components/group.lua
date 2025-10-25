-- Fiend/components/group.lua
-- Group component for organizing elements within tabs
-- Supports automatic space division based on number of groups

local Util = require(script.Parent.Parent.lib.util)
local Theme = require(script.Parent.Parent.lib.theme)

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
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = content
    
    -- Create the group instance
    local self = setmetatable({
        Instance = groupFrame,
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
    
    -- Note: Group is added to tab.Groups by the tab's AddGroup method
    -- This prevents double-addition and ensures proper initialization order
    
    return self
end

-- Add elements to the group
function Group:AddButton(text, callback)
    local Button = require(script.Parent.button)
    local button = Button.new(self, text, callback)
    table.insert(self.Elements, button)
    return button
end

function Group:AddToggle(text, default, callback)
    local Toggle = require(script.Parent.toggle)
    local toggle = Toggle.new(self, text, default, callback)
    table.insert(self.Elements, toggle)
    return toggle
end

function Group:AddSlider(text, min, max, default, callback)
    local Slider = require(script.Parent.slider)
    local slider = Slider.new(self, text, min, max, default, callback)
    table.insert(self.Elements, slider)
    return slider
end

function Group:AddDropdown(label, list, default, callback)
    local Dropdown = require(script.Parent.dropdown)
    local dropdown = Dropdown.new(self, label, list, default, callback)
    table.insert(self.Elements, dropdown)
    return dropdown
end

function Group:AddTextInput(label, placeholder, default, callback)
    local TextInput = require(script.Parent.textinput)
    local textInput = TextInput.new(self, label, placeholder, default, callback)
    table.insert(self.Elements, textInput)
    return textInput
end

function Group:AddKeybind(label, keyCode, callback)
    local Keybind = require(script.Parent.keybind)
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
	self.Instance.Size = UDim2.new(size.X, 0, size.Y, 0)
end

function Group:_setPositionInternal(position: Vector2)
	self.Position = position
	self.Instance.Position = UDim2.new(position.X, 0, position.Y, 0)
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
