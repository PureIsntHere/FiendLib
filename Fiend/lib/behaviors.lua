local Utils = require(script.Parent.utils)

local Behaviors = {}

function Behaviors.MakeDraggable(handle, targetFrame)
	local UIS = game:GetService("UserInputService")
	local dragging, dragStart, startPos = false, nil, nil

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos  = targetFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - dragStart
			targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

function Behaviors.AddResizeGrip(shell, theme, minSize, maxSize)
	local UIS = game:GetService("UserInputService")

	local grip = Instance.new("Frame")
	grip.Name = "ResizeGrip"
	grip.Size = UDim2.fromOffset(16,16)
	grip.AnchorPoint = Vector2.new(1,1)
	grip.Position = UDim2.new(1,-4,1,-4)
	grip.BackgroundColor3 = theme.Background
	grip.BackgroundTransparency = 0.2
	grip.ZIndex = (shell.ZIndex or 1) + 4
	grip.Parent = shell
	Utils:Roundify(grip, UDim.new(0,4))
	Utils:Stroke(grip, theme.Foreground, 1, 0.6)

	for i=0,2 do
		local line = Instance.new("Frame")
		line.BackgroundColor3 = theme.Foreground
		line.BorderSizePixel = 0
		line.AnchorPoint = Vector2.new(1,1)
		line.Size = UDim2.fromOffset(10 - (i*3), 1)
		line.Position = UDim2.new(1,-2,1,-(2 + i*4))
		line.Rotation = 45
		line.ZIndex = (grip.ZIndex or 1) + 1
		line.Parent = grip
	end

	local resizing, startMouse, startSize = false, nil, nil
	grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			startMouse = input.Position
			startSize  = shell.AbsoluteSize
			local c; c = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
					if c then c:Disconnect() end
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if not resizing or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local d = input.Position - startMouse
		local nx = math.clamp(startSize.X + d.X, minSize.X, maxSize.X)
		local ny = math.clamp(startSize.Y + d.Y, minSize.Y, maxSize.Y)
		shell.Size = UDim2.fromOffset(nx, ny)
	end)

	return grip
end

return Behaviors
