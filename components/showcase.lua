-- Fiend/components/showcase.lua
-- Demonstration GUI for Fiend UI Library

local Rep = game:GetService("ReplicatedStorage")
local Fiend = require(Rep:WaitForChild("Fiend"):WaitForChild("init"))

-- Optional addons (gracefully degrade if missing)
local Announce do
	local ok, mod = pcall(function() return require(Rep.Fiend.components.announce) end)
	Announce = ok and mod or nil
end
local Notify do
	local ok, mod = pcall(function() return require(Rep.Fiend.components.notify) end)
	Notify = ok and mod or nil
end

local Window = Fiend:CreateWindow({
	Title    = "ARCHFIEND  —  Showcase",
	SubTitle = "V:0.1  |  BETA  |  Fiend UI Library",
	Width    = 720,
	Height   = 460,
	MinSize  = Vector2.new(520, 320),
	MaxSize  = Vector2.new(1800, 1100),

	KeySystem = {
		Enabled = true,
		Key     = "123",
		Title   = "ACCESS REQUIRED",
		Hint    = "Enter your Archfiend key to unlock access."
	},
})

Window:OnReady(function(w)
	local Ann = Announce
	local Toasts = Notify and Notify.new(w.Theme) or nil
	if Toasts then Toasts:AttachTo(w.Gui) end

	local function toast(msg, dur)
		if Toasts then Toasts:Push(msg, dur or 2) else print("[Fiend/Toast]", msg) end
	end

	if Ann then
		Ann.Show(w, {
			Title = "Welcome to FiendLib",
			Message = "Retro-futuristic UI demo.\nResize small to reveal the dock.",
			RichText = true,
			Buttons = { {Text = "Begin", Primary = true} }
		})
	end

	-- Tabs (dock + topbar)
	local Overview  = w:AddTab("Overview",  "◎")
	local Controls  = w:AddTab("Controls",  "⚙")
	local Visuals   = w:AddTab("Visuals",   "✦")
	local Shortcuts = w:AddTab("Shortcuts", "⌨")
	local Config    = w:AddTab("Config",    "⎙")
	local About     = w:AddTab("About",     "ⓘ")

	-- OVERVIEW
	Overview:AddButton("Show Announcement", function()
		if Ann then
			Ann.Show(w, {
				Title = "Server Notice",
				Message = "Pools reset in <b>2 minutes</b>.",
				RichText = true,
				Buttons = { {Text = "Okay", Primary = true, Callback = function() toast("Thanks!") end} }
			})
		else
			toast("Announce module not found.")
		end
	end)

	Overview:AddButton("Show Toast", function() toast("Hello from Fiend!", 2.5) end)
	Overview:AddDropdown("Demo Dropdown", {
		"Legit","Instant","Mixed","Quantized","Adaptive",
		"Raw","Smoothed","High","Medium","Low","Ultra"
	}, "Legit", function(v) toast("Dropdown → "..v) end)

	-- CONTROLS
	Controls:AddToggle("Perfect Cast", false, function(v) toast("Perfect Cast: "..tostring(v)) end)
	Controls:AddToggle("AntiSnap", true,   function(v) toast("AntiSnap: "..tostring(v)) end)
	Controls:AddSlider("CPU Load", 0, 100, 28, function(v) toast(("CPU: %d"):format(v)) end)
	Controls:AddDropdown("Reeling Mode", {"Legit","Instant","Mixed"}, "Legit", function(v) toast("Reeling: "..v) end)
	Controls:AddButton("Execute Task", function() toast("Task executed.") end)

	-- VISUALS
	Visuals:AddToggle("Top Sweep", true, function(on) w:SetFxEnabled("TopSweep", on) end)
	Visuals:AddToggle("Scanlines", true, function(on) w:SetFxEnabled("Scanlines", on) end)
	Visuals:AddToggle("Brackets", true, function(on) w:SetFxEnabled("Brackets", on) end)
	Visuals:AddToggle("Pulse Stroke", true, function(on) w:SetFxEnabled("PulseStroke", on) end)
	Visuals:AddSlider("Sweep Speed", 60, 300, 140, function(v) w:SetSweepConfig({speed=v}) end)
	Visuals:AddSlider("Glow Width", 60, 300, 160, function(v) w:SetSweepConfig({glowWidth=v}) end)
	Visuals:AddSlider("Scan Speed", 60, 300, 110, function(v) w:SetScanConfig({speed=v}) end)

	-- SHORTCUTS
	local Binds = Fiend.Binds
	if Binds then
		Binds:Register("Toggle UI", Enum.KeyCode.RightShift, "Toggle", function(active)
			if w.Gui then w.Gui.Enabled = active end
			toast("UI Visible: "..tostring(active), 1.25)
		end)
	end

	-- CONFIG
	local ConfigSys = Fiend.Config
	Config:AddButton("Save → Clipboard", function()
		if ConfigSys and ConfigSys.Serialize then
			local json = ConfigSys:Serialize()
			if typeof(setclipboard) == "function" then
				setclipboard(json)
				toast("Config copied to clipboard.")
			else
				print("[Fiend] Config:", json)
				toast("Clipboard not available.")
			end
		else
			toast("No config system detected.")
		end
	end)

	Config:AddButton("Load ← Clipboard", function()
		if ConfigSys and ConfigSys.Deserialize then
			local data = typeof(getclipboard) == "function" and getclipboard() or nil
			local ok = data and ConfigSys:Deserialize(data)
			toast("Load result: "..tostring(ok))
		else
			toast("Config system not found.")
		end
	end)

	-- ABOUT
	About:AddButton("Center Window", function()
		if w.Shell then w.Shell.Position = UDim2.fromScale(0.5, 0.5) end
	end)
	About:AddButton("Show Welcome Again", function()
		if Ann then
			Ann.Show(w, {
				Title = "Hello again",
				Message = "Resize the window to test dock behavior.",
				Buttons = { {Text="Nice", Primary=true} }
			})
		end
	end)
	About:AddButton("Destroy UI", function()
		toast("Destroying UI…", 1)
		task.delay(0.15, function() w:Destroy() end)
	end)

	toast("Fiend Showcase ready.")
end)

return Window
