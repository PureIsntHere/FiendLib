local UIS = game:GetService("UserInputService")

local Binds = {}
Binds._all = {}
Binds._down = {}

function Binds:Register(name, keyCode, mode, callback)
	self._all[name] = {key = keyCode, mode = mode or "Hold", active = (mode=="Always"), cb = callback}
	if mode == "Always" and callback then task.spawn(callback, true) end
end

function Binds:Unregister(name) self._all[name] = nil end
function Binds:SetKey(name, keyCode) if self._all[name] then self._all[name].key = keyCode end end
function Binds:SetMode(name, mode) if self._all[name] then self._all[name].mode = mode end end

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	for _,b in pairs(Binds._all) do
		if b.key == input.KeyCode then
			if b.mode == "Hold" then b.active = true; if b.cb then b.cb(true) end
			elseif b.mode == "Toggle" then b.active = not b.active; if b.cb then b.cb(b.active) end
			end
		end
	end
end)

UIS.InputEnded:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	for _,b in pairs(Binds._all) do
		if b.key == input.KeyCode and b.mode == "Hold" then
			b.active = false; if b.cb then b.cb(false) end
		end
	end
end)

function Binds:IsActive(name) local b=self._all[name]; return b and b.active or false end

return Binds
