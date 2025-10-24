local Root   = script.Parent
local Theme  = require(Root.lib.theme)
local Window = require(Root.components.window)
local Binds = require(Root.lib.binds)
local Config = require(Root.lib.config)

local Fiend = {}
Fiend._theme = Theme
Fiend.Binds = Binds
Fiend.Config = Config

function Fiend:SetTheme(patch : {[string]: any})
	for k, v in pairs(patch) do
		self._theme[k] = v
	end
end

function Fiend:GetTheme()
	return self._theme
end

function Fiend:CreateWindow(opts)
	opts = opts or {}
	opts.Theme = self._theme
	return Window.new(opts)
end

return Fiend
