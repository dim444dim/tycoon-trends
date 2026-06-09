--[[
	BoostUI.client.luau (TycoonTrends)
	Affiche les notifications de boost temporaire (2x, 3x, FastUpgrades).
	Écoute BoostSpawned / BoostExpired et anime un bandeau left-center.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local Players           = game:GetService("Players")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes   = require(ReplicatedStorage.Shared.Remotes)

-- ───────── CONFIG BOOST ─────────
local BOOST_CONFIG = {
	["2xIncome"]     = { icon = "⚡", label = "×2 Income",     color = Color3.fromRGB(255, 200, 100) },
	["3xIncome"]     = { icon = "🔥", label = "×3 Income",     color = Color3.fromRGB(255,  50,  50) },
	["FastUpgrades"] = { icon = "⚙️", label = "Fast Upgrades", color = Color3.fromRGB(100, 180, 200) },
}

local POS_VISIBLE = UDim2.new(0.02, 0, 0.45, 0)
local POS_HIDDEN  = UDim2.new(-0.25, 0, 0.45, 0)

-- ───────── CONSTRUCTION UI ─────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "BoostUI"
screenGui.ResetOnSpawn  = false
screenGui.IgnoreGuiInset = true
screenGui.Parent        = playerGui

local notifFrame = Instance.new("Frame")
notifFrame.Name             = "NotificationFrame"
notifFrame.Size             = UDim2.new(0.2, 0, 0.1, 0)
notifFrame.Position         = POS_HIDDEN
notifFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
notifFrame.BorderSizePixel  = 0
notifFrame.Parent           = screenGui

do
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = notifFrame

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft   = UDim.new(0, 10)
	pad.PaddingRight  = UDim.new(0, 10)
	pad.PaddingTop    = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.Parent = notifFrame
end

local iconLabel = Instance.new("TextLabel")
iconLabel.Name               = "Icon"
iconLabel.Size               = UDim2.new(0.15, 0, 1, 0)
iconLabel.Position           = UDim2.new(0, 0, 0, 0)
iconLabel.BackgroundTransparency = 1
iconLabel.TextScaled         = true
iconLabel.Font               = Enum.Font.GothamBold
iconLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
iconLabel.Parent             = notifFrame

local nameLabel = Instance.new("TextLabel")
nameLabel.Name               = "BoostName"
nameLabel.Size               = UDim2.new(0.83, 0, 0.50, 0)
nameLabel.Position           = UDim2.new(0.17, 0, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextScaled         = true
nameLabel.Font               = Enum.Font.GothamBold
nameLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
nameLabel.TextXAlignment     = Enum.TextXAlignment.Left
nameLabel.Parent             = notifFrame

local countdownLabel = Instance.new("TextLabel")
countdownLabel.Name               = "Countdown"
countdownLabel.Size               = UDim2.new(0.83, 0, 0.50, 0)
countdownLabel.Position           = UDim2.new(0.17, 0, 0.50, 0)
countdownLabel.BackgroundTransparency = 1
countdownLabel.TextScaled         = true
countdownLabel.Font               = Enum.Font.GothamBold
countdownLabel.TextColor3         = Color3.fromRGB(200, 200, 200)
countdownLabel.TextXAlignment     = Enum.TextXAlignment.Left
countdownLabel.Parent             = notifFrame

-- ───────── TWEENS ─────────
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenIn  = TweenService:Create(notifFrame, TWEEN_INFO, { Position = POS_VISIBLE })
local tweenOut = TweenService:Create(notifFrame, TWEEN_INFO, { Position = POS_HIDDEN  })

-- ───────── ÉTAT ─────────
local activeBoostId:      string? = nil
local countdownConnection: RBXScriptConnection? = nil
local remainingTime = 0

-- ───────── HELPERS ─────────
local function stopCountdown()
	if countdownConnection then
		countdownConnection:Disconnect()
		countdownConnection = nil
	end
end

local function hideNotification()
	stopCountdown()
	activeBoostId = nil
	tweenIn:Cancel()
	tweenOut:Play()
end

local function showBoost(boostId: string, duration: number)
	local cfg = BOOST_CONFIG[boostId]
	if not cfg then return end

	stopCountdown()
	activeBoostId = boostId
	remainingTime = duration

	iconLabel.Text      = cfg.icon
	nameLabel.Text      = cfg.label
	nameLabel.TextColor3 = cfg.color
	countdownLabel.Text = math.ceil(remainingTime) .. "s"
	countdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

	tweenOut:Cancel()
	tweenIn:Play()

	-- Heartbeat pour un décompte sans dérive
	local lastClock = os.clock()
	countdownConnection = RunService.Heartbeat:Connect(function()
		local now   = os.clock()
		remainingTime = remainingTime - (now - lastClock)
		lastClock   = now

		if remainingTime <= 0 then
			countdownLabel.Text = "0s"
			hideNotification()
		else
			countdownLabel.Text = math.ceil(remainingTime) .. "s"
		end
	end)
end

-- ───────── EVENTS ─────────
Remotes.BoostSpawned.OnClientEvent:Connect(function(data)
	showBoost(data.id, data.duration)
end)

Remotes.BoostExpired.OnClientEvent:Connect(function(data)
	if activeBoostId == data.id then
		stopCountdown()
		countdownLabel.Text      = "Boost expiré"
		countdownLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		task.delay(0.8, hideNotification)
	end
end)

print("✅ BoostUI loaded")
