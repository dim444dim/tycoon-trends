local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local Players            = game:GetService("Players")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

-- ─────────────────────────────────────────
--           EVENT DEFINITIONS (MVP)
-- ─────────────────────────────────────────

local EVENTS = {
	twitch_raid  = { name = "🎮 Streamer Raid", multiplier = 1.5, duration = 3600, bgColor = Color3.fromRGB(145, 70, 255) },
	rapper_drop  = { name = "🎤 Rap Drop",      multiplier = 2.0, duration = 1800, bgColor = Color3.fromRGB(255, 50,  50)  },
	tiktok_trend = { name = "📱 TikTok Viral",  multiplier = 1.3, duration = 900,  bgColor = Color3.fromRGB(0,   0,   0)   },
}

-- ─────────────────────────────────────────
--           BANNER UI CREATION
-- ─────────────────────────────────────────

local EventGui = Instance.new("ScreenGui")
EventGui.Name          = "EventSystem"
EventGui.ResetOnSpawn  = false
EventGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
EventGui.Parent        = playerGui

local Banner = Instance.new("Frame")
Banner.Name            = "EventBanner"
Banner.AnchorPoint     = Vector2.new(0.5, 0)
Banner.Size            = UDim2.new(0.30, 0, 0.08, 0)
Banner.Position        = UDim2.new(0.50, 0, 0.01, 0)
Banner.BackgroundColor3 = Color3.fromRGB(145, 70, 255)
Banner.BorderSizePixel = 0
Banner.Visible         = false
Banner.Parent          = EventGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent       = Banner

local BannerLabel = Instance.new("TextLabel")
BannerLabel.Name              = "BannerLabel"
BannerLabel.Size              = UDim2.new(1, -12, 1, 0)
BannerLabel.Position          = UDim2.new(0, 6, 0, 0)
BannerLabel.BackgroundTransparency = 1
BannerLabel.TextColor3        = Color3.new(1, 1, 1)
BannerLabel.Font               = Enum.Font.GothamBold
BannerLabel.TextScaled         = true
BannerLabel.TextWrapped        = true
BannerLabel.Text               = ""
BannerLabel.Parent             = Banner

-- ─────────────────────────────────────────
--           STATE
-- ─────────────────────────────────────────

local activeEvent      = nil  -- { def, remaining }
local countdownConn    = nil

local function stopCountdown()
	if countdownConn then
		countdownConn:Disconnect()
		countdownConn = nil
	end
end

local function hideBanner()
	stopCountdown()
	activeEvent   = nil
	Banner.Visible = false
end

local function updateLabel()
	if not activeEvent then return end
	local def = activeEvent.def
	BannerLabel.Text = string.format(
		"%s  ×%.1f  |  %ds",
		def.name,
		def.multiplier,
		math.max(0, activeEvent.remaining)
	)
end

-- ─────────────────────────────────────────
--           COUNTDOWN LOOP
-- ─────────────────────────────────────────

local function startCountdown(def, duration)
	stopCountdown()

	activeEvent = { def = def, remaining = duration }
	Banner.BackgroundColor3 = def.bgColor
	Banner.Visible = true
	updateLabel()

	local accumulated = 0
	countdownConn = RunService.Heartbeat:Connect(function(dt)
		if not activeEvent then return end

		accumulated += dt
		if accumulated >= 1 then
			local ticks = math.floor(accumulated)
			accumulated -= ticks
			activeEvent.remaining -= ticks

			if activeEvent.remaining <= 0 then
				hideBanner()
			else
				updateLabel()
			end
		end
	end)
end

-- ─────────────────────────────────────────
--           REMOTE LISTENER
-- ─────────────────────────────────────────

Remotes.EventStarted.OnClientEvent:Connect(function(payload)
	local eventId    = payload.eventId
	local multiplier = payload.multiplier
	local duration   = payload.duration

	local def = EVENTS[eventId]
	if not def then
		warn("[EventSystem] Événement inconnu :", eventId)
		return
	end

	-- override : latest event wins
	local resolvedDef = {
		name       = def.name,
		multiplier = multiplier or def.multiplier,
		bgColor    = def.bgColor,
	}
	local resolvedDuration = duration or def.duration

	startCountdown(resolvedDef, resolvedDuration)
end)

print("✅ EventSystem loaded")
