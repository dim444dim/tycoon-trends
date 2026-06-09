--[[
	Leaderstats.server.luau (TycoonTrends)
	Copié depuis HorrorVilla — adapté pour les stats tycoon :
	  Cash    : argent actuel du joueur
	  Earned  : total gagné depuis le début (session + historique)
	  Builds  : nombre de bâtiments actifs

	Sync avec les Attributes DataXxx écrits par DataStoreStats.
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig     = require(ReplicatedStorage.Shared.GameConfig)
local GameplayConfig = require(ReplicatedStorage.Shared.GameplayConfig)

print("[Leaderstats] init")

local state = ReplicatedStorage:WaitForChild("GameState", 5)

-- ───────── LEADERSTATS PAR JOUEUR ─────────

local function buildLeaderstats(player)
	local existing = player:FindFirstChild("leaderstats")
	if existing then existing:Destroy() end

	local folder  = Instance.new("Folder")
	folder.Name   = "leaderstats"
	folder.Parent = player

	local cash = Instance.new("NumberValue")
	cash.Name  = "Cash"
	cash.Value = player:GetAttribute("Cash") or GameConfig.StartingCash
	cash.Parent = folder

	local earned = Instance.new("NumberValue")
	earned.Name  = "Earned"
	earned.Value = player:GetAttribute("DataTotalEarned") or 0
	earned.Parent = folder

	local builds = Instance.new("IntValue")
	builds.Name  = "Builds"
	builds.Value = player:GetAttribute("DataTotalBuilds") or 0
	builds.Parent = folder

	-- Sync sur changement d'Attribute
	player:GetAttributeChangedSignal("Cash"):Connect(function()
		cash.Value = player:GetAttribute("Cash") or 0
	end)
	player:GetAttributeChangedSignal("DataTotalEarned"):Connect(function()
		earned.Value = player:GetAttribute("DataTotalEarned") or 0
	end)
	player:GetAttributeChangedSignal("DataTotalBuilds"):Connect(function()
		builds.Value = player:GetAttribute("DataTotalBuilds") or 0
	end)
end

Players.PlayerAdded:Connect(buildLeaderstats)
for _, p in Players:GetPlayers() do
	buildLeaderstats(p)
end

-- ───────── SCALING (conservé pour extension future) ─────────
local function recomputeMonsterDelay()
	local n    = #Players:GetPlayers()
	local base = GameConfig.PrepDuration
	local raw  = base + (n - 2) * GameplayConfig.MonsterDelayScalingStep
	local clamped = math.clamp(raw,
		GameplayConfig.MonsterDelayMin,
		GameplayConfig.MonsterDelayMax)
	if state then
		state:SetAttribute("DynamicPrepDelay", clamped)
	end
end

recomputeMonsterDelay()
Players.PlayerAdded:Connect(function()   recomputeMonsterDelay() end)
Players.PlayerRemoving:Connect(function() recomputeMonsterDelay() end)
