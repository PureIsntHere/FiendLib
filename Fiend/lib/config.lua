local Http = game:GetService("HttpService")

local Config = {}
Config._registry = {} -- controlId -> {get=fn,set=fn}

function Config:Register(id, getters)
	self._registry[id] = getters -- {get=function()->any, set=function(v)}
end

function Config:Serialize()
	local t = {}
	for id,gs in pairs(self._registry) do
		if gs.get then t[id] = gs.get() end
	end
	return Http:JSONEncode(t)
end

function Config:Deserialize(json)
	local ok, data = pcall(function() return Http:JSONDecode(json) end)
	if not ok or type(data) ~= "table" then return false end
	for id,v in pairs(data) do
		local gs = self._registry[id]
		if gs and gs.set then pcall(gs.set, v) end
	end
	return true
end

return Config
