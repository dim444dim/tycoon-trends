--[[
	GameplayConfig.luau (TycoonTrends)
	Constantes de gameplay avancé : production, bâtiments, tendances, DataStore.
]]

local GameplayConfig = {
	-- ───────── PRODUCTION ─────────
	TickInterval = 1,           -- secondes entre chaque tick de production
	CashPerUnit  = 10,          -- argent gagné par unité produite au tick

	-- ───────── CATALOGUE BÂTIMENTS ─────────
	Buildings = {
		{ id = "workshop",  name = "Atelier",      cost =   100, rate =  1, level = 1 },
		{ id = "factory",   name = "Usine",         cost =   500, rate =  5, level = 2 },
		{ id = "megaplant", name = "Méga-Usine",    cost =  2000, rate = 20, level = 3 },
		{ id = "hq",        name = "Siège Social",  cost =  8000, rate = 75, level = 4 },
	},

	-- ───────── TENDANCES ─────────
	TrendCount           = 2,    -- nombre de bâtiments en tendance simultanément
	TrendDuration        = 120,  -- secondes avant rotation des tendances
	TrendBonusMultiplier = 2.0,  -- ×2 gains si le bâtiment est en tendance

	-- ───────── DATASTORE ─────────
	DataStoreName      = "TycoonTrendsStats_v1",
	DataStoreRetryCount = 3,
	DataStoreRetryDelay = 1.5,

	-- ───────── LIMITES ─────────
	MaxCashStored = 1e12,  -- plafond anti-overflow

	-- ───────── COÛTS EXPONENTIELS (UpgradeShop) ─────────
	-- baseCost  : coût du 1er exemplaire
	-- costGrowth: multiplicateur par exemplaire déjà possédé
	BuildingCosts = {
		workshop  = { baseCost = 100,  costGrowth = 1.15 },
		factory   = { baseCost = 500,  costGrowth = 1.15 },
		megaplant = { baseCost = 2000, costGrowth = 1.15 },
		hq        = { baseCost = 8000, costGrowth = 1.15 },
	},

	-- Scaling MonsterDelay hérité (conservé pour compatibilité future)
	MonsterDelayMin          = 3,
	MonsterDelayMax          = 12,
	MonsterDelayScalingStep  = 1.5,
}

return GameplayConfig
