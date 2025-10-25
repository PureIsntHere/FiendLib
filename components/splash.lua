-- Fiend/components/splash.lua
-- Retro wireframe splash screen with loading progress

local Tween = require(script.Parent.Parent.lib.tween)
local Theme = require(script.Parent.Parent.lib.theme)
local Safety = require(script.Parent.Parent.lib.safety)

local Splash = {}
Splash.__index = Splash

function Splash.new()
    local self = setmetatable({}, Splash)
    
    -- Create the main splash screen GUI
    self._gui, self._container = self:_createGUI()
    
    -- Get references to the UI elements
    self._progressBar = self._container:FindFirstChild("ProgressBar")
    self._progressFill = self._progressBar and self._progressBar:FindFirstChild("Fill")
    self._statusLabel = self._container:FindFirstChild("StatusLabel")
    self._titleLabel = self._container:FindFirstChild("TitleLabel")
    self._versionLabel = self._container:FindFirstChild("VersionLabel")
    
    -- Animation state
    self._isVisible = false
    self._currentProgress = 0
    self._totalSteps = 0
    self._currentStep = 0
    
    return self
end

function Splash:_createGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "FiendSplash"
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.DisplayOrder = 9999
    sg.Parent = Safety.GetRoot()
    
    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Position = UDim2.fromScale(0.5, 0.5)
    container.Size = UDim2.fromOffset(420, 280)
    container.BackgroundColor3 = Theme.Background
    container.BorderSizePixel = 0
    container.Parent = sg
    
    -- Apply theme styling
    Theme:Apply(container, "Container")
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Theme.Rounding)
    corner.Parent = container
    
    -- Border stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Thickness = Theme.LineThickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = container
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -20, 0, 32)
    titleLabel.Position = UDim2.fromOffset(10, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "FIEND"
    titleLabel.Font = Theme.Font
    titleLabel.TextSize = 28
    titleLabel.TextColor3 = Theme.TextColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = container
    
    -- Version
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Name = "VersionLabel"
    versionLabel.Size = UDim2.new(0, 80, 0, 16)
    versionLabel.Position = UDim2.new(1, -90, 0, 25)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v0.1.0"
    versionLabel.Font = Theme.Font
    versionLabel.TextSize = 12
    versionLabel.TextColor3 = Theme.SubTextColor
    versionLabel.TextXAlignment = Enum.TextXAlignment.Right
    versionLabel.TextYAlignment = Enum.TextYAlignment.Center
    versionLabel.Parent = container
    
    -- Subtitle
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "SubtitleLabel"
    subtitleLabel.Size = UDim2.new(1, -20, 0, 20)
    subtitleLabel.Position = UDim2.fromOffset(10, 55)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "UI Library"
    subtitleLabel.Font = Theme.Font
    subtitleLabel.TextSize = 14
    subtitleLabel.TextColor3 = Theme.SubTextColor
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.TextYAlignment = Enum.TextYAlignment.Center
    subtitleLabel.Parent = container
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.fromOffset(10, 200)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Initializing..."
    statusLabel.Font = Theme.Font
    statusLabel.TextSize = 14
    statusLabel.TextColor3 = Theme.TextColor
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Center
    statusLabel.Parent = container
    
    -- Progress container
    local progressContainer = Instance.new("Frame")
    progressContainer.Name = "ProgressContainer"
    progressContainer.Size = UDim2.new(1, -20, 0, 8)
    progressContainer.Position = UDim2.fromOffset(10, 230)
    progressContainer.BackgroundColor3 = Theme.Background2
    progressContainer.BorderSizePixel = 0
    progressContainer.Parent = container
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 4)
    progressCorner.Parent = progressContainer
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.Position = UDim2.fromScale(0, 0)
    progressBar.BackgroundColor3 = Theme.Accent
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressContainer
    
    local progressBarCorner = Instance.new("UICorner")
    progressBarCorner.CornerRadius = UDim.new(0, 4)
    progressBarCorner.Parent = progressBar
    
    -- Progress fill (for smooth animation)
    local progressFill = Instance.new("Frame")
    progressFill.Name = "Fill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.Position = UDim2.fromScale(0, 0)
    progressFill.BackgroundColor3 = Theme.Accent
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBar
    
    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(0, 4)
    progressFillCorner.Parent = progressFill
    
    -- Retro wireframe decorations
    self:_addWireframeDecorations(container)
    
    return sg, container
end

function Splash:_addWireframeDecorations(container)
    -- Top bracket
    local topBracket = Instance.new("Frame")
    topBracket.Name = "TopBracket"
    topBracket.Size = UDim2.new(0, 20, 0, 1)
    topBracket.Position = UDim2.fromOffset(10, 10)
    topBracket.BackgroundColor3 = Theme.Border
    topBracket.BorderSizePixel = 0
    topBracket.Parent = container
    
    local topBracket2 = Instance.new("Frame")
    topBracket2.Size = UDim2.new(0, 1, 0, 20)
    topBracket2.Position = UDim2.fromOffset(10, 10)
    topBracket2.BackgroundColor3 = Theme.Border
    topBracket2.BorderSizePixel = 0
    topBracket2.Parent = container
    
    -- Bottom bracket
    local bottomBracket = Instance.new("Frame")
    bottomBracket.Name = "BottomBracket"
    bottomBracket.Size = UDim2.new(0, 20, 0, 1)
    bottomBracket.Position = UDim2.new(1, -30, 1, -10)
    bottomBracket.BackgroundColor3 = Theme.Border
    bottomBracket.BorderSizePixel = 0
    bottomBracket.Parent = container
    
    local bottomBracket2 = Instance.new("Frame")
    bottomBracket2.Size = UDim2.new(0, 1, 0, 20)
    bottomBracket2.Position = UDim2.new(1, -11, 1, -30)
    bottomBracket2.BackgroundColor3 = Theme.Border
    bottomBracket2.BorderSizePixel = 0
    bottomBracket2.Parent = container
    
    -- Scanlines effect
    if Theme.EnableScanlines then
        for i = 0, 4 do
            local scanline = Instance.new("Frame")
            scanline.Name = "Scanline" .. i
            scanline.Size = UDim2.new(1, 0, 0, 1)
            scanline.Position = UDim2.new(0, 0, 0, 80 + i * 40)
            scanline.BackgroundColor3 = Theme.Border
            scanline.BackgroundTransparency = 0.8
            scanline.BorderSizePixel = 0
            scanline.Parent = container
        end
    end
end

function Splash:Show()
    if self._isVisible then return end
    
    self._isVisible = true
    self._gui.Enabled = true
    
    -- Fade in animation
    self._container.BackgroundTransparency = 1
    Tween(self._container, {BackgroundTransparency = 0}, 0.3)
end

function Splash:Hide()
    if not self._isVisible then return end
    
    -- Fade out animation
    Tween(self._container, {BackgroundTransparency = 1}, 0.3)
    
    -- Wait for animation to complete, then destroy
    task.wait(0.3)
    self._gui:Destroy()
    self._isVisible = false
end

function Splash:SetStatus(text)
    if self._statusLabel then
        self._statusLabel.Text = text
    end
end

function Splash:SetProgress(current, total, filename)
    self._currentStep = current
    self._totalSteps = total
    
    local percent = total > 0 and (current / total) or 0
    self._currentProgress = percent
    
    -- Update status text
    if filename then
        self:SetStatus(string.format("Loading %s (%d/%d)", filename, current, total))
    else
        self:SetStatus(string.format("Progress: %d%%", math.floor(percent * 100)))
    end
    
    -- Animate progress bar
    if self._progressFill then
        local targetSize = UDim2.new(percent, 0, 1, 0)
        Tween(self._progressFill, {Size = targetSize}, 0.2)
    end
end

function Splash:SetTitle(title)
    if self._titleLabel then
        self._titleLabel.Text = title
    end
end

function Splash:SetVersion(version)
    if self._versionLabel then
        self._versionLabel.Text = version
    end
end

function Splash:Complete()
    self:SetStatus("Complete!")
    self:SetProgress(self._totalSteps, self._totalSteps)
    
    -- Brief delay before hiding
    task.wait(0.5)
    self:Hide()
end

return Splash
