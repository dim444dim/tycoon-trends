--[[
	GameConfig.luau (TycoonTrends)
	Paramètres globaux du jeu.
	Fichier safe à modifier pour customiser le tycoon.
]]

local GameConfig = {
	NomDuJeu = "Tycoon Trends",
	Theme    = "trends",

	-- Session
	MinPlayers      = 1,
	SessionDuration = 600,  -- 10 minutes par session
	PrepDuration    = 10,   -- lobby countdown avant démarrage
	EndDuration     = 15,   -- affichage résultats

	-- Production
	BaseProductionRate     = 1,    -- unités/tick de base (sans bâtiment)
	MaxProductionBuildings = 20,   -- bâtiments max par joueur
	StartingCash           = 100,

	-- Couleurs tendances (vibrant + moderne)
	CouleurPrimaire   = Color3.fromRGB(255, 80, 120),   -- rose vif
	CouleurSecondaire = Color3.fromRGB(80, 200, 255),   -- bleu ciel
	CouleurAccent     = Color3.fromRGB(255, 200, 50),   -- jaune doré
	CouleurSol        = Color3.fromRGB(240, 240, 245),  -- blanc cassé
	CouleurMurs       = Color3.fromRGB(200, 195, 220),  -- gris lavande

	-- Prestige
	PrestigeThresholds = { 100000, 500000, 2500000, 10000000 },
	PrestigeBonus      = { 1.1,    1.25,   1.5,     2.0      },

	-- Sons (remplacer les IDs vides par tes assetIds Roblox)
	SoundBuyId    = "",  -- son achat bâtiment
	SoundSellId   = "",  -- son vente
	SoundLevelUpId = "", -- son niveau supérieur
	SoundAmbId    = "",  -- ambiance de fond
}

return GameConfig
