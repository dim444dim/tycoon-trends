local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig     = require(ReplicatedStorage.Shared.GameConfig)
local GameplayConfig = require(ReplicatedStorage.Shared.GameplayConfig)
local Remotes        = require(ReplicatedStorage.Shared.Remotes)

-- ─────────────────────────────────────────
--   HELPERS — Buildings attribute (string)
-- ─────────────────────────────────────────
-- Format stocké : "workshop:2,factory:1"
-- Compatible avec DataStoreStats (regex %w+:(%d+))

local function parseBuildings(str)
	local counts = {}
	for btype, countStr in string.gmatch(str, "(%w+):(%d+)") do
		counts[btype] = tonumber(countStr) or 0
	end
	return counts
end

local function serializeBuildings(counts)
	local parts = {}
	for btype, count in pairs(counts) do
		if count > 0 then
			table.insert(parts, btype .. ":" .. tostring(count))
		end
	end
	return table.concat(parts, ",")
end

local function totalBuildings(counts)
	local total = 0
	for _, n in pairs(counts) do total += n end
	return total
end

-- ─────────────────────────────────────────
--   COST FORMULA (exponentiel)
-- ─────────────────────────────────────────

local function calculateCost(buildingType, ownedCount)
	local config = GameplayConfig.BuildingCosts[buildingType]
	if not config then return 0 end
	return math.floor(config.baseCost * config.costGrowth ^ ownedCount)
end

-- ─────────────────────────────────────────
--   BUY BUILDING
-- ─────────────────────────────────────────

local function buyBuilding(player, buildingType)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end
	local cashValue = leaderstats:FindFirstChild("Cash")
	if not cashValue then return false end

	if not GameplayConfig.BuildingCosts[buildingType] then
		Remotes.BuyBuilding:FireClient(player, { success = false, error = "invalid_type" })
		return false
	end

	local counts = parseBuildings(player:GetAttribute("Buildings") or "")
	local owned  = counts[buildingType] or 0

	if totalBuildings(counts) >= GameConfig.MaxProductionBuildings then
		Remotes.BuyBuilding:FireClient(player, { success = false, error = "max_buildings" })
		return false
	end

	local cost = calculateCost(buildingType, owned)
	if cashValue.Value < cost then
		Remotes.BuyBuilding:FireClient(player, { success = false, error = "insufficient_cash", cost = cost })
		return false
	end

	cashValue.Value          -= cost
	counts[buildingType]      = owned + 1
	player:SetAttribute("Buildings", serializeBuildings(counts))

	local newOwned = owned + 1
	Remotes.BuyBuilding:FireClient(player, {
		success      = true,
		buildingType = buildingType,
		owned        = newOwned,
		newCash      = cashValue.Value,
		nextCost     = calculateCost(buildingType, newOwned),
	})

	print(string.format("✅ %s bought %s (×%d) for $%d", player.Name, buildingType, newOwned, cost))
	return true
end

-- ─────────────────────────────────────────
--   SELL BUILDING (refund 50 % du dernier coût)
-- ─────────────────────────────────────────

local function sellBuilding(player, buildingType)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end
	local cashValue = leaderstats:FindFirstChild("Cash")
	if not cashValue then return false end

	local counts = parseBuildings(player:GetAttribute("Buildings") or "")
	local owned  = counts[buildingType] or 0

	if owned <= 0 then
		Remotes.SellBuilding:FireClient(player, { success = false, error = "none_owned" })
		return false
	end

	local refund = math.floor(calculateCost(buildingType, owned - 1) * 0.5)
	cashValue.Value          = math.min(cashValue.Value + refund, GameplayConfig.MaxCashStored)
	counts[buildingType]      = owned - 1
	player:SetAttribute("Buildings", serializeBuildings(counts))

	local newOwned = owned - 1
	Remotes.SellBuilding:FireClient(player, {
		success      = true,
		buildingType = buildingType,
		owned        = newOwned,
		refund       = refund,
		newCash      = cashValue.Value,
	})

	print(string.format("🔄 %s sold %s (×%d), refund $%d", player.Name, buildingType, newOwned, refund))
	return true
end

-- ─────────────────────────────────────────
--   GET SHOP DATA (RemoteFunction)
-- ─────────────────────────────────────────

Remotes.GetShopData.OnServerInvoke = function(player)
	local counts = parseBuildings(player:GetAttribute("Buildings") or "")
	local shopData = {}
	for _, building in ipairs(GameplayConfig.Buildings) do
		local owned = counts[building.id] or 0
		shopData[building.id] = {
			id       = building.id,
			name     = building.name,
			rate     = building.rate,
			level    = building.level,
			owned    = owned,
			nextCost = calculateCost(building.id, owned),
		}
	end
	return shopData
end

-- ─────────────────────────────────────────
--   EVENTS
-- ─────────────────────────────────────────

Remotes.BuyBuilding.OnServerEvent:Connect(function(player, data)
	if type(data) == "table" and type(data.buildingType) == "string" then
		buyBuilding(player, data.buildingType)
	end
end)

Remotes.SellBuilding.OnServerEvent:Connect(function(player, data)
	if type(data) == "table" and type(data.buildingType) == "string" then
		sellBuilding(player, data.buildingType)
	end
end)

print("✅ UpgradeShop loaded")
