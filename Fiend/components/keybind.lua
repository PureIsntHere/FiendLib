-- Fiend/components/keybind
local Utils = require(script.Parent.Parent.lib.utils)
local Tween = require(script.Parent.Parent.lib.tween)

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(tab, labelText, defaultKeyCode, defaultMode, binds, idForConfig)
	local theme = tab.Theme
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = theme.Background; frame.BackgroundTransparency = 0.15
	frame.Size = UDim2.new(1,0,0,36); frame.ZIndex = 2; frame.Parent = tab.Page
	Utils:Roundify(frame, theme.Corner); Utils:Stroke(frame, theme.Foreground, 1, 0.7); Utils:Pad(frame, theme.Pad)

	local label = Utils:Label({Text = labelText, Parent = frame, Theme = theme})
	label.Size = UDim2.new(1,-160,1,0)

	local keyBtn = Instance.new("TextButton")
	keyBtn.AutoButtonColor = false; keyBtn.Text = defaultKeyCode.Name; keyBtn.Font = theme.Font; keyBtn.TextSize = 14
	keyBtn.TextColor3 = theme.Foreground; keyBtn.BackgroundColor3 = theme.Background; keyBtn.Size = UDim2.fromOffset(90,22)
	keyBtn.AnchorPoint = Vector2.new(1,0.5); keyBtn.Position = UDim2.new(1,-8,0.5,0); keyBtn.Parent = frame
	Utils:Roundify(keyBtn, theme.Corner); Utils:Stroke(keyBtn, theme.Foreground, 1, 0.6)

	local modeBtn = Instance.new("TextButton")
	modeBtn.AutoButtonColor = false; modeBtn.Text = defaultMode or "Hold"; modeBtn.Font = theme.Font; modeBtn.TextSize = 14
	modeBtn.TextColor3 = theme.Foreground; modeBtn.BackgroundColor3 = theme.Background; modeBtn.Size = UDim2.fromOffset(60,22)
	modeBtn.AnchorPoint = Vector2.new(1,0.5); modeBtn.Position = UDim2.new(1,-8-96,0.5,0); modeBtn.Parent = frame
	Utils:Roundify(modeBtn, theme.Corner); Utils:Stroke(modeBtn, theme.Foreground, 1, 0.6)

	-- bind registration
	local name = labelText
	binds:Register(name, defaultKeyCode, defaultMode, function(active) end)

	-- capture for key change
	keyBtn.Activated:Connect(function()
		keyBtn.Text = "..."
		local con; con = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				binds:SetKey(name, input.KeyCode)
				keyBtn.Text = input.KeyCode.Name
				if con then con:Disconnect() end
			end
		end)
	end)

	local modes = {"Hold","Toggle","Always"}
	modeBtn.Activated:Connect(function()
		local i = table.find(modes, modeBtn.Text) or 1
		i = (i % #modes) + 1
		modeBtn.Text = modes[i]; binds:SetMode(name, modes[i])
	end)

	-- config hookup
	if idForConfig then
		local Config = require(script.Parent.Parent.lib.config)
		Config:Register(idForConfig, {
			get = function() return {key = keyBtn.Text, mode = modeBtn.Text} end,
			set = function(v)
				if typeof(v) == "table" and v.key and Enum.KeyCode[v.key] then
					keyBtn.Text = v.key; binds:SetKey(name, Enum.KeyCode[v.key])
				end
				if typeof(v) == "table" and v.mode then
					modeBtn.Text = v.mode; binds:SetMode(name, v.mode)
				end
			end
		})
	end

	return setmetatable({Instance=frame}, Keybind)
end

return Keybind
