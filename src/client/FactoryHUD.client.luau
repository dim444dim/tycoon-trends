local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local HUD_BG      = Color3.fromRGB(18, 18, 30)
local HUD_ALPHA   = 0.3
local TEXT_WHITE  = Color3.new(1, 1, 1)
local SESSION_CAP = 50000  -- barre pleine à 50K gagné dans la session

-- ─────────────────────────────────────────
--           HUD CREATION
-- ─────────────────────────────────────────

local HudGui = Instance.new("ScreenGui")
HudGui.Name = "FactoryHUD"
HudGui.ResetOnSpawn = false
HudGui.Parent = playerGui

-- CASH PANEL (top-left, big)
local CashPanel = Instance.new("Frame")
CashPanel.Name = "CashPanel"
CashPanel.Size = UDim2.new(0.25, 0, 0.15, 0)
CashPanel.Position = UDim2.new(0.02, 0, 0.02, 0)
CashPanel.BackgroundColor3 = HUD_BG
CashPanel.BackgroundTransparency = HUD_ALPHA
CashPanel.BorderSizePixel = 0
CashPanel.Parent = HudGui

local Corner1 = Instance.new("UICorner")
Corner1.CornerRadius = UDim.new(0, 12)
Corner1.Parent = CashPanel

local CashScale = Instance.new("UIScale")
CashScale.Scale = 1
CashScale.Parent = CashPanel

local CashLabel = Instance.new("TextLabel")
CashLabel.Name = "CashLabel"
CashLabel.Size = UDim2.new(1, 0, 1, 0)
CashLabel.BackgroundTransparency = 1
CashLabel.TextScaled = true
CashLabel.TextColor3 = GameConfig.CouleurAccent  -- or doré
CashLabel.Font = Enum.Font.GothamBold
CashLabel.Text = "💰 $0"
CashLabel.Parent = CashPanel

-- PRODUCTION RATE PANEL (top-right, petit)
local ProdPanel = Instance.new("Frame")
ProdPanel.Name = "ProductionPanel"
ProdPanel.Size = UDim2.new(0.2, 0, 0.1, 0)
ProdPanel.Position = UDim2.new(0.73, 0, 0.02, 0)
ProdPanel.BackgroundColor3 = HUD_BG
ProdPanel.BackgroundTransparency = HUD_ALPHA
ProdPanel.BorderSizePixel = 0
ProdPanel.Parent = HudGui

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 12)
Corner2.Parent = ProdPanel

local ProdLabel = Instance.new("TextLabel")
ProdLabel.Name = "ProdLabel"
ProdLabel.Size = UDim2.new(1, 0, 1, 0)
ProdLabel.BackgroundTransparency = 1
ProdLabel.TextScaled = true
ProdLabel.TextColor3 = GameConfig.CouleurSecondaire  -- bleu ciel
ProdLabel.Font = Enum.Font.GothamBold
ProdLabel.Text = "📈 $0/sec"
ProdLabel.Parent = ProdPanel

-- SESSION PANEL (bottom) — gains cumulés de la session
local SessionPanel = Instance.new("Frame")
SessionPanel.Name = "SessionPanel"
SessionPanel.Size = UDim2.new(0.3, 0, 0.08, 0)
SessionPanel.Position = UDim2.new(0.35, 0, 0.9, 0)
SessionPanel.BackgroundColor3 = HUD_BG
SessionPanel.BackgroundTransparency = HUD_ALPHA
SessionPanel.BorderSizePixel = 0
SessionPanel.Parent = HudGui

local Corner3 = Instance.new("UICorner")
Corner3.CornerRadius = UDim.new(0, 12)
Corner3.Parent = SessionPanel

local SessionLabel = Instance.new("TextLabel")
SessionLabel.Name = "SessionLabel"
SessionLabel.Size = UDim2.new(0.4, 0, 1, 0)
SessionLabel.BackgroundTransparency = 1
SessionLabel.TextScaled = true
SessionLabel.TextColor3 = TEXT_WHITE
SessionLabel.Font = Enum.Font.Gotham
SessionLabel.Text = "🏭 Session:"
SessionLabel.Parent = SessionPanel

local SessionBar = Instance.new("Frame")
SessionBar.Name = "SessionBar"
SessionBar.Size = UDim2.new(0, 0, 0.7, 0)
SessionBar.Position = UDim2.new(0.42, 0, 0.15, 0)
SessionBar.BackgroundColor3 = GameConfig.CouleurPrimaire  -- rose vif
SessionBar.BorderSizePixel = 0
SessionBar.Parent = SessionPanel

local CornerBar = Instance.new("UICorner")
CornerBar.CornerRadius = UDim.new(0, 8)
CornerBar.Parent = SessionBar

-- ─────────────────────────────────────────
--           HELPERS
-- ─────────────────────────────────────────

local function formatCash(value)
	if value >= 1_000_000 then
		return string.format("%.1fM", value / 1_000_000)
	elseif value >= 1_000 then
		return string.format("%.1fK", value / 1_000)
	else
		return tostring(math.floor(value))
	end
end

local function updateCashDisplay(cash)
	CashLabel.Text = "💰 $" .. formatCash(cash)
	-- bounce via UIScale (TextScaled = true → ne pas tweener TextSize)
	CashScale.Scale = 1.08
	TweenService:Create(
		CashScale,
		TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()
end

local function updateProductionRate(rate)
	ProdLabel.Text = "📈 $" .. formatCash(rate) .. "/sec"
end

local function updateSessionBar(sessionEarned)
	local percent = math.clamp(sessionEarned / SESSION_CAP, 0, 1)
	TweenService:Create(
		SessionBar,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.new(percent * 0.55, 0, 0.7, 0) }
	):Play()
end

-- ─────────────────────────────────────────
--           EVENT LISTENERS
-- ─────────────────────────────────────────

Remotes.UpdateHUD.OnClientEvent:Connect(function(data)
	if not data then return end
	updateCashDisplay(data.cash or 0)
	updateProductionRate(data.rate or 0)
	updateSessionBar(data.sessionEarned or 0)
end)

print("✅ FactoryHUD loaded")
