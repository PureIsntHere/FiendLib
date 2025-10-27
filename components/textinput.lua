-- Fiend/components/textinput.lua
-- Text input component with retro wireframe styling

local Util = FiendModules.Util
local Theme = FiendModules.Theme
local Tween = FiendModules.Tween

local TextInput = {}
TextInput.__index = TextInput

function TextInput.new(tabOrGroup, labelText, placeholderText, defaultValue, callback)
    local self = setmetatable({}, TextInput)
    
    self.Tab = tabOrGroup
    self.LabelText = labelText or "Text Input"
    self.PlaceholderText = placeholderText or "Enter text..."
    self.Value = defaultValue or ""
    self.Callback = callback
    self.Theme = tabOrGroup.Theme or Theme
    
    -- Auto-register with Fiend if available
    if _G.FiendInstance and _G.FiendInstance._trackElement then
        _G.FiendInstance:_trackElement(self)
    end
    
    self._frame = nil
    self._textBox = nil
    self._label = nil
    self._isFocused = false
    
    self:_createUI()
    self:_setupEvents()
    
    return self
end

function TextInput:_createUI()
    local theme = self.Theme
    local p = theme.Padding or 6
    
    -- Get scaled size if this is in a group
    local rowSize = UDim2.new(1, 0, 0, 36)
    if self.Tab.GetScaledElementSize then
        rowSize = self.Tab:GetScaledElementSize(1, 36)
    end
    
    -- Row container (like button component)
    local row = Instance.new("Frame")
    row.Name = "TextInputRow"
    row.BackgroundTransparency = 1
    row.Size = rowSize
    row.Parent = self.Tab.Content or self.Tab.Container
    
    -- Store row for resize listener
    self._row = row
    
    -- Main container frame (with proper padding like button)
    self._frame = Instance.new("Frame")
    self._frame.Name = "TextInput_" .. self.LabelText:gsub("%s+", "_")
    self._frame.BackgroundColor3 = theme.Background2
    self._frame.BackgroundTransparency = 0.15
    self._frame.Size = UDim2.new(1, -(p * 2), 1, 0)
    self._frame.Position = UDim2.new(0, p, 0, 0)
    self._frame.ZIndex = 2
    self._frame.Parent = row
    
    -- Use Util functions for consistent styling
    Util:Roundify(self._frame, UDim.new(0, theme.Rounding))
    Util:Stroke(self._frame, theme.Border, theme.LineThickness, 0.3)
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, theme.Padding)
    padding.PaddingBottom = UDim.new(0, theme.Padding)
    padding.PaddingLeft = UDim.new(0, theme.Padding)
    padding.PaddingRight = UDim.new(0, theme.Padding)
    padding.Parent = self._frame
    
    -- Label
    self._label = Instance.new("TextLabel")
    self._label.Name = "Label"
    self._label.Size = UDim2.new(1, -120, 1, 0)
    self._label.Position = UDim2.new(0, 0, 0, 0)
    self._label.BackgroundTransparency = 1
    self._label.Text = self.LabelText
    self._label.Font = theme.Font
    self._label.TextSize = 14
    self._label.TextColor3 = theme.TextColor
    self._label.TextXAlignment = Enum.TextXAlignment.Left
    self._label.TextYAlignment = Enum.TextYAlignment.Center
    self._label.TextTruncate = Enum.TextTruncate.AtEnd  -- Add text truncation
    self._label.Parent = self._frame
    
    -- Text input box
    self._textBox = Instance.new("TextBox")
    self._textBox.Name = "TextBox"
    self._textBox.Size = UDim2.new(0, 100, 0, 22)
    self._textBox.Position = UDim2.new(1, -105, 0.5, -11)
    self._textBox.BackgroundColor3 = theme.Background
    self._textBox.BackgroundTransparency = 0
    self._textBox.BorderSizePixel = 0
    self._textBox.Font = theme.Font
    self._textBox.TextSize = 12
    self._textBox.TextColor3 = theme.TextColor
    self._textBox.PlaceholderText = self.PlaceholderText
    self._textBox.PlaceholderColor3 = theme.SubTextColor
    self._textBox.Text = self.Value
    self._textBox.TextXAlignment = Enum.TextXAlignment.Left
    self._textBox.TextYAlignment = Enum.TextYAlignment.Center
    self._textBox.ClearTextOnFocus = false
    self._textBox.TextTruncate = Enum.TextTruncate.AtEnd  -- Add text truncation
    self._textBox.Parent = self._frame
    
    -- Use Util functions for consistent styling
    Util:Roundify(self._textBox, UDim.new(0, 4))
    Util:Stroke(self._textBox, theme.Border, 1, 0.5)
    
    -- Text box padding
    local textBoxPadding = Instance.new("UIPadding")
    textBoxPadding.PaddingLeft = UDim.new(0, 6)
    textBoxPadding.PaddingRight = UDim.new(0, 6)
    textBoxPadding.Parent = self._textBox
    
    -- Refresh theme for this text input
    function self:RefreshTheme()
        -- Get current theme from library
        local currentTheme = self.Theme
        if _G.FiendInstance and _G.FiendInstance.Theme then
            currentTheme = _G.FiendInstance.Theme
        end
        
        if currentTheme then
            -- Update text box colors
            self:SetBackgroundColor(currentTheme.Background, false)
            self:SetTextColor(currentTheme.TextColor, false)
            self:SetPlaceholderColor(currentTheme.SubTextColor, false)
            self:SetBorderColor(currentTheme.Border, false)
            
            -- Update text box border thickness
            local stroke = self._textBox:FindFirstChild("UIStroke")
            if stroke then
                stroke.Thickness = currentTheme.LineThickness or 1
            end
            
            -- Update text box corner radius
            local corner = self._textBox:FindFirstChild("UICorner")
            if corner then
                corner.CornerRadius = currentTheme.Corner or UDim.new(0, 4)
            end
            
            -- Update label colors
            if self._label then
                self._label.TextColor3 = currentTheme.TextColor
                self._label.Font = currentTheme.Font
            end
            
            -- Update frame background
            if self._frame then
                self._frame.BackgroundColor3 = currentTheme.Background2 or currentTheme.Background
                
                -- Update frame border
                local frameStroke = self._frame:FindFirstChild("UIStroke")
                if frameStroke then
                    frameStroke.Color = currentTheme.Border
                    frameStroke.Thickness = currentTheme.LineThickness or 1
                end
                
                -- Update frame corner radius
                local frameCorner = self._frame:FindFirstChild("UICorner")
                if frameCorner then
                    frameCorner.CornerRadius = currentTheme.Corner or UDim.new(0, 8)
                end
            end
            
            -- Update stored theme reference
            self.Theme = currentTheme
        end
    end
    
    -- Apply initial theme
    self:RefreshTheme()
    
    -- Add resize listener if in a group
    if self.Tab.GetScaledElementSize and self.Tab.Instance then
        self._resizeConnection = self.Tab.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            if self._row then
                local newSize = self.Tab:GetScaledElementSize(1, 36)
                self._row.Size = newSize
            end
        end)
    end
end

function TextInput:_setupEvents()
    -- Focus events
    self._textBox.Focused:Connect(function()
        self._isFocused = true
        self:_onFocusChanged(true)
    end)
    
    self._textBox.FocusLost:Connect(function()
        self._isFocused = false
        self:_onFocusChanged(false)
    end)
    
    -- Text changed event
    self._textBox:GetPropertyChangedSignal("Text"):Connect(function()
        self.Value = self._textBox.Text
        if self.Callback then
            self.Callback(self.Value)
        end
    end)
end

function TextInput:_onFocusChanged(focused)
    local theme = self.Theme
    
    if focused then
        -- Focused state - brighter border
        Tween(self._textBox.UIStroke, {Color = theme.Accent, Transparency = 0}, 0.15)
        Tween(self._textBox, {BackgroundColor3 = theme.Background2}, 0.15)
    else
        -- Unfocused state - dimmer border
        Tween(self._textBox.UIStroke, {Color = theme.Border, Transparency = 0.5}, 0.15)
        Tween(self._textBox, {BackgroundColor3 = theme.Background}, 0.15)
    end
end

-- Public methods
function TextInput:SetValue(value)
    self.Value = value or ""
    self._textBox.Text = self.Value
end

function TextInput:GetValue()
    return self.Value
end

function TextInput:SetPlaceholder(text)
    self.PlaceholderText = text or ""
    self._textBox.PlaceholderText = self.PlaceholderText
end

function TextInput:SetCallback(callback)
    self.Callback = callback
end

function TextInput:SetEnabled(enabled)
    self._textBox.TextEditable = enabled
    self._textBox.Active = enabled
end

function TextInput:Focus()
    self._textBox:CaptureFocus()
end

-- Instant color updates
function TextInput:SetBackgroundColor(color, animate)
    if animate == false then
        self._textBox.BackgroundColor3 = color
    elseif animate == true then
        Tween(self._textBox, {BackgroundColor3 = color}, 0.15)
    else
        self._textBox.BackgroundColor3 = color
    end
end

function TextInput:SetTextColor(color, animate)
    if animate == false then
        self._textBox.TextColor3 = color
    elseif animate == true then
        Tween(self._textBox, {TextColor3 = color}, 0.15)
    else
        self._textBox.TextColor3 = color
    end
end

function TextInput:SetPlaceholderColor(color, animate)
    if animate == false then
        self._textBox.PlaceholderColor3 = color
    elseif animate == true then
        Tween(self._textBox, {PlaceholderColor3 = color}, 0.15)
    else
        self._textBox.PlaceholderColor3 = color
    end
end

function TextInput:SetBorderColor(color, animate)
    local stroke = self._textBox:FindFirstChild("UIStroke")
    if stroke then
        if animate == false then
            stroke.Color = color
        elseif animate == true then
            Tween(stroke, {Color = color}, 0.15)
        else
            stroke.Color = color
        end
    end
end


-- Add BaseElement-compatible methods
function TextInput:UpdateProperty(property, value, animate)
    if not self._textBox then return end
    
    if animate == false then
        -- Instant update
        self._textBox[property] = value
    elseif animate == true then
        -- Animated update using default tween
        Tween(self._textBox, {[property] = value}, 0.15)
    else
        -- Default behavior - instant update
        self._textBox[property] = value
    end
end

function TextInput:UpdateProperties(properties, animate)
    if not self._textBox then return end
    
    if animate == false then
        -- Instant update
        for property, value in pairs(properties) do
            self._textBox[property] = value
        end
    elseif animate == true then
        -- Animated update using default tween
        Tween(self._textBox, properties, 0.15)
    else
        -- Default behavior - instant update
        for property, value in pairs(properties) do
            self._textBox[property] = value
        end
    end
end

function TextInput:Destroy()
    if self._resizeConnection then
        self._resizeConnection:Disconnect()
    end
    if self._row then
        self._row:Destroy()
    end
    if self._frame then
        self._frame:Destroy()
        self._frame = nil
    end
end

return TextInput
