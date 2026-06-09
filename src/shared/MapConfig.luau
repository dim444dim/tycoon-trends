--[[
	MapConfig.luau (TycoonTrends)
	Configuration de la map : dimensions plots, palette couleurs, ambiance.
	Copié depuis HorrorVilla — COULEURS À SWAP pour le thème tycoon (vibrant/moderne).

	Consommé par :
	  - MapBuilder.server.luau  (dimensions + palette + matériaux)
	  - Atmosphere.server.luau  (Lighting, bloom, color correction)
]]

local MapConfig = {}

-- ───────── DIMENSIONS PLOTS (en studs) ─────────
MapConfig.Plot = {
	Width  = 80,   -- X
	Depth  = 80,   -- Z
	Height = 50,   -- hauteur max bâtiments
	Margin = 10,   -- espace entre plots voisins
}

MapConfig.World = {
	GridCols = 4,
	GridRows = 4,  -- 4×4 = 16 plots joueurs max
	BaseY    = 0,
}

-- ───────── PALETTE ─────────
-- ⚠️ SWAP COLORS ICI pour changer le thème visuel du tycoon
MapConfig.Palette = {
	-- Structurel
	PlotBase       = Color3.fromRGB(200, 195, 215),  -- gris lavande (SWAP → ta couleur)
	PlotBorder     = Color3.fromRGB(255, 80, 120),   -- rose vif accent (SWAP)
	Ground         = Color3.fromRGB(155, 210, 145),  -- vert gazon
	Sky            = Color3.fromRGB(120, 185, 255),  -- bleu ciel

	-- Bâtiments par niveau
	Building_L1    = Color3.fromRGB(255, 180, 100),  -- orange chaleureux (atelier)
	Building_L2    = Color3.fromRGB(100, 200, 220),  -- cyan (usine)
	Building_L3    = Color3.fromRGB(160, 100, 255),  -- violet (méga-usine)
	Building_L4    = Color3.fromRGB(255, 210, 50),   -- or (siège social)
	Roof           = Color3.fromRGB(220, 220, 230),  -- blanc-gris

	-- Décor urbain
	Road           = Color3.fromRGB(80, 80, 90),
	Sidewalk       = Color3.fromRGB(200, 200, 210),
	Grass          = Color3.fromRGB(130, 195, 120),
	TreeLeaves     = Color3.fromRGB(80, 175, 90),
	TreeTrunk      = Color3.fromRGB(120, 80, 50),
	SignBoard      = Color3.fromRGB(255, 255, 255),
	SignText       = Color3.fromRGB(30, 30, 50),

	-- Metal / vitres
	Metal          = Color3.fromRGB(170, 175, 185),
	Glass          = Color3.fromRGB(200, 230, 255),
	WindowFrame    = Color3.fromRGB(80, 85, 100),
}

-- ───────── ATMOSPHERE / LIGHTING ─────────
MapConfig.Lighting = {
	ClockTime    = 13,
	Brightness   = 2.5,
	Ambient      = Color3.fromRGB(180, 185, 200),
	OutdoorAmbient     = Color3.fromRGB(140, 150, 170),
	FogColor     = Color3.fromRGB(200, 210, 230),
	FogStart     = 200,
	FogEnd       = 600,
	GlobalShadows = true,
	EnvironmentDiffuseScale  = 0.7,
	EnvironmentSpecularScale = 0.5,
}

MapConfig.Atmosphere = {
	Density = 0.10,
	Offset  = 0.05,
	Color   = Color3.fromRGB(200, 215, 235),
	Decay   = Color3.fromRGB(180, 195, 215),
	Glare   = 0.15,
	Haze    = 0.5,
}

MapConfig.Bloom = {
	Intensity = 0.4,
	Size      = 20,
	Threshold = 0.95,
}

MapConfig.ColorCorrection = {
	Brightness  = 0.05,
	Contrast    = 0.10,
	Saturation  = 0.15,
	TintColor   = Color3.fromRGB(255, 250, 245),
}

MapConfig.DepthOfField = {
	FarIntensity  = 0.1,
	FocusDistance = 60,
	InFocusRadius = 25,
	NearIntensity = 0.0,
}

-- ───────── COULEURS SÉMANTIQUES (alias pour scripts) ─────────
MapConfig.Colors = {
	CouleurAmbiance = Color3.fromRGB(220, 230, 240),   -- gris clair
	CouleurMachines = Color3.fromRGB(100, 180, 200),   -- teal production
	CouleurAccent   = Color3.fromRGB(255, 200, 100),   -- or cash/upgrade
}

-- ───────── MATÉRIAUX ─────────
MapConfig.Materials = {
	Concrete     = Enum.Material.Concrete,
	Wood         = Enum.Material.Wood,
	Brick        = Enum.Material.Brick,
	Slate        = Enum.Material.Slate,
	Metal        = Enum.Material.Metal,
	Grass        = Enum.Material.Grass,
	SmoothPlastic = Enum.Material.SmoothPlastic,
	Glass        = Enum.Material.Glass,
}

-- ───────── TRANSPARENCE ─────────
MapConfig.Transparency = {
	Opaque     = 0,
	GlassLight = 0.3,
	GlassDark  = 0.6,
}

return MapConfig
