local Utils = {}

function Utils:Roundify(inst, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius
	c.Name = "Corner"
	c.Parent = inst
	return c
end

function Utils:Pad(inst, pad)
	local ui = Instance.new("UIPadding")
	ui.PaddingTop    = UDim.new(0,pad)
	ui.PaddingBottom = UDim.new(0,pad)
	ui.PaddingLeft   = UDim.new(0,pad)
	ui.PaddingRight  = UDim.new(0,pad)
	ui.Parent = inst
	return ui
end

function Utils:Stroke(inst, color, thickness, trans)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Color = color
	s.Transparency = trans
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = inst
	return s
end

function Utils:VList(parent, gap)
	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0,gap)
	list.Parent = parent
	return list
end

function Utils:HList(parent, gap)
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0,gap)
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Parent = parent
	return list
end

function Utils:Label(props)
	local l = Instance.new("TextLabel")
	l.Name = "Label"
	l.BackgroundTransparency = 1
	l.ClipsDescendants = true
	l.Font = props.Theme.Font
	l.Text = props.Text or ""
	l.TextColor3 = props.Theme.Foreground
	l.TextSize = 14
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.RichText = false
	l.TextWrapped = false
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.AutoLocalize = false
	l.Parent = props.Parent
	return l
end

return Utils
