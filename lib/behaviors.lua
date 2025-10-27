-- Handle both Studio and Executor environments
local Util = FiendModules.Util

local Behaviors = {}

function Behaviors.MakeDraggable(handle, targetFrame, cutoff)
	-- Enhanced dragging function inspired by LinoriaLib
	local UIS = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local Mouse = LocalPlayer:GetMouse()
	
	-- Make the handle active for input
	handle.Active = true
	
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Check if click is within cutoff area (for title bars, etc.)
			local objPos = Vector2.new(
				Mouse.X - handle.AbsolutePosition.X,
				Mouse.Y - handle.AbsolutePosition.Y
			)
			
			-- If cutoff is specified and click is below it, don't drag
			if cutoff and objPos.Y > cutoff then
				return
			end
			
			-- Store the initial mouse offset from the frame's position
			local initialMousePos = Vector2.new(Mouse.X, Mouse.Y)
			local initialFramePos = targetFrame.Position
			
			-- Start dragging loop
			local dragConnection
			dragConnection = RunService.RenderStepped:Connect(function()
				if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
					dragConnection:Disconnect()
					return
				end
				
				-- Calculate the mouse movement delta
				local currentMousePos = Vector2.new(Mouse.X, Mouse.Y)
				local mouseDelta = currentMousePos - initialMousePos
				
				-- Apply the delta to the initial frame position
				local newPosition = UDim2.new(
					initialFramePos.X.Scale,
					initialFramePos.X.Offset + mouseDelta.X,
					initialFramePos.Y.Scale,
					initialFramePos.Y.Offset + mouseDelta.Y
				)
				
				-- Apply the new position
				targetFrame.Position = newPosition
			end)
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
	Util:Roundify(grip, UDim.new(0,4))
	Util:Stroke(grip, theme.Foreground, 1, 0.6)

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
