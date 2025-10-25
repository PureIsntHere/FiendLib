-- Fiend/lib/binds.lua
-- Legacy compatibility layer for the old binds system
-- This now delegates to the new KeySystem for consistency

local KeySystem = require(script.Parent.keysystem)

local Binds = {}
Binds.__index = Binds

export type BindType = "Toggle" | "Hold" | "Press"

function Binds.new()
	local self = setmetatable({}, Binds)
	
	-- Create a new keysystem instance for this binds instance
	self._keySystem = KeySystem.new({
		Theme = nil,
		GlobalKeyCapture = true,
		DebugMode = false
	})
	
	return self
end

-- Register or overwrite a bind
function Binds:Register(name:string, keyCode:Enum.KeyCode, bindType:BindType?, callback:(...any)->()?, id:string?)
	if not name or not keyCode then
		error("[Fiend/Binds] Missing bind name or keyCode")
	end
	
	-- Convert legacy bind types to new format
	local newType = bindType
	if bindType == "Press" then
		newType = "Press"
	elseif bindType == "Hold" then
		newType = "Hold"
	else
		newType = "Toggle"
	end
	
	self._keySystem:RegisterBind(name, keyCode, newType, callback, id)
end

function Binds:Unregister(name:string)
	self._keySystem:UnregisterBind(name)
end

function Binds:Get(name:string)
	return self._keySystem:GetBind(name)
end

function Binds:GetState(name:string):boolean
	return self._keySystem:GetBindState(name)
end

function Binds:SetState(name:string, value:boolean)
	-- Legacy method - not directly supported in new system
	warn("[Fiend/Binds] SetState is deprecated. Use the new KeySystem API.")
end

-- === Added for components/keybind.lua compatibility ===
function Binds:SetKey(name:string, keyCode:Enum.KeyCode)
	self._keySystem:SetBindKey(name, keyCode)
end

function Binds:SetMode(name:string, mode:BindType)
	-- Convert legacy mode names
	local newMode = mode
	if mode == "Always" then
		newMode = "Always"
	elseif mode == "Hold" then
		newMode = "Hold"
	elseif mode == "Press" then
		newMode = "Press"
	else
		newMode = "Toggle"
	end
	
	self._keySystem:SetBindType(name, newMode)
end
-- ================================================

function Binds:GetAll()
	return self._keySystem:GetAllBinds()
end

function Binds:Destroy()
	self._keySystem:Destroy()
end

return Binds.new()
