--[[
	ProductionTicker.server.luau (TycoonTrends)
	Boucle de production : génère du cash pour chaque bâtiment actif par tick.
	Gère aussi la rotation des tendances (bonus ×2 sur les bâtiments en trend).

	Format de l'Attribute "Buildings" sur le joueur :
	  Chaîne "id1:count1,id2:count2" (ex : "workshop:3,factory:1")
	  Écrite et lue par BuyBuilding / SellBuilding (non implémentés ici).
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig     = require(ReplicatedStorage.Shared.GameConfig)
local GameplayConfig = require(ReplicatedStorage.Shared.GameplayConfig)
local Remotes        = require(ReplicatedStorage.Shared.Remotes)

print("[ProductionTicker] init")

local state = ReplicatedStorage:WaitForChild("GameState", 10)

-- ───────── TENDANCES ─────────
local activeTrends = {}

local function rotateTrends()
	activeTrends = {}
	local buildings = GameplayConfig.Buildings
	-- Choisit TrendCount bâtiments distincts aléatoirement
	local pool = {}
	for _, b in ipairs(buildings) do table.insert(pool, b.id) end
	for i = #pool, 2, -1 do
		local j = math.random(i)
		pool[i], pool[j] = pool[j], pool[i]
	end
	for i = 1, math.min(GameplayConfig.TrendCount, #pool) do
		activeTrends[pool[i]] = true
	end
	Remotes.TrendChanged:FireAllClients(activeTrends)
	print("[ProductionTicker] Nouvelles tendances :", table.concat(pool, ", "))
end

rotateTrends()

task.spawn(function()
	while true do
		task.wait(GameplayConfig.TrendDuration)
		rotateTrends()
	end
end)

-- ───────── TICK DE PRODUCTION ─────────
task.spawn(function()
	while true do
		task.wait(GameplayConfig.TickInterval)

		if not state or state:GetAttribute("State") ~= "ACTIVE" then
			continue
		end

		for _, player in Players:GetPlayers() do
			local buildingsStr = player:GetAttribute("Buildings")
			if not buildingsStr or buildingsStr == "" then continue end

			local totalRate = 0
			for buildId, countStr in string.gmatch(buildingsStr, "(%w+):(%d+)") do
				local count = tonumber(countStr) or 0
				local rate  = 0
				for _, b in ipairs(GameplayConfig.Buildings) do
					if b.id == buildId then rate = b.rate; break end
				end
				local mult = activeTrends[buildId] and GameplayConfig.TrendBonusMultiplier or 1
				totalRate += rate * count * mult
			end

			local boostMult    = player:GetAttribute("BoostMultiplier")    or 1.0
			local prestigeMult = player:GetAttribute("prestige_multiplier") or 1.0
			local eventMult    = player:GetAttribute("EventMultiplier")    or 1.0
			local earned = totalRate * GameplayConfig.CashPerUnit * boostMult * prestigeMult * eventMult
			if earned > 0 then
				local current = player:GetAttribute("Cash") or GameConfig.StartingCash
				local newCash = math.min(current + earned, GameplayConfig.MaxCashStored)
				player:SetAttribute("Cash", newCash)

				local sessionTotal = (player:GetAttribute("SessionEarned") or 0) + earned
				player:SetAttribute("SessionEarned", sessionTotal)

				Remotes.UpdateHUD:FireClient(player, {
					cash          = newCash,
					rate          = totalRate,
					sessionEarned = sessionTotal,
					trends        = activeTrends,
				})
			end
		end
	end
end)

-- Expose les shop data via RemoteFunction
Remotes.GetShopData.OnServerInvoke = function(_player)
	return GameplayConfig.Buildings
end
