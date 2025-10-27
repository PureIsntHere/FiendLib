local TweenService = game:GetService("TweenService")

local function t(obj : Instance, props : {[string]: any}, duration : number?, easing : Enum.EasingStyle?, dir : Enum.EasingDirection?)
	local info = TweenInfo.new(duration or 0.25, easing or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

return t
