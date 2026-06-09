--[[
	MapBuilder.server.luau (TycoonTrends)
	Grille visuelle 10×6 (60 slots) — génère les marqueurs de case et pose
	les modèles de bâtiments quand l'attribut "Buildings" d'un joueur change.

	Consommé par :
	  - UpgradeShop.server.luau (écrit l'attribut "Buildings")
	  - FactoryHUD.client.luau  (animations upgrade futures via buildingVisuals)
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig) -- luacheck: ignore
local MapConfig  = require(ReplicatedStorage.Shared.MapConfig)

-- ───────── CONSTANTES GRILLE ─────────
local COLS      = 10
local ROWS      = 6
local SLOT_SIZE = 5
local GRID_Y    = 0

-- buildingVisuals[userId][buildingType] = { Part, ... }
-- Utilisé par les futures animations d'upgrade.
local buildingVisuals = {}

-- ───────── DÉFINITIONS VISUELLES ─────────
-- yOffset = centre Y du Part (base au sol = yOffset - height/2 = 0)

local BUILDING_DEFS = {
	workshop  = { size = Vector3.new(3, 3, 3), color = MapConfig.Colors.CouleurMachines, yOffset = 1.5 },
	factory   = { size = Vector3.new(3, 5, 3), color = MapConfig.Colors.CouleurMachines, yOffset = 2.5 },
	megaplant = { size = Vector3.new(3, 8, 3), color = MapConfig.Colors.CouleurMachines, yOffset = 4.0 },
	hq        = { size = Vector3.new(4, 4, 4), color = MapConfig.Colors.CouleurAccent,   yOffset = 2.0 },
}

-- ───────── ÉTAT INTERNE ─────────
local slotParts    = {}  -- [slotIndex] = Part marqueur
local usedSlots    = {}  -- [slotIndex] = userId (occupant)
-- playerSlots[userId] = { {part, type, slotIdx}, ... } — ordre d'insertion
local playerSlots  = {}

-- ───────── HELPERS ─────────

local function parseBuildings(str)
	local counts = {}
	for btype, n in string.gmatch(str or "", "(%w+):(%d+)") do
		counts[btype] = tonumber(n) or 0
	end
	return counts
end

local function slotCenter(slotIndex)
	local idx = slotIndex - 1
	local col = idx % COLS
	local row = math.floor(idx / COLS)
	return col * SLOT_SIZE + SLOT_SIZE / 2, row * SLOT_SIZE + SLOT_SIZE / 2
end

local function nextFreeSlot()
	for i = 1, COLS * ROWS do
		if not usedSlots[i] then return i end
	end
	return nil
end

-- ───────── CRÉATION DE LA GRILLE ─────────

local gridFolder      = Instance.new("Folder")
gridFolder.Name       = "FactoryGrid"
gridFolder.Parent     = workspace

for i = 1, COLS * ROWS do
	local x, z = slotCenter(i)
	local col   = (i - 1) % COLS
	local row   = math.floor((i - 1) / COLS)

	local slot = Instance.new("Part")
	slot.Name         = string.format("Slot(%d,%d)", col, row)
	slot.Size         = Vector3.new(SLOT_SIZE - 0.2, 0.2, SLOT_SIZE - 0.2)
	slot.Position     = Vector3.new(x, GRID_Y + 0.1, z)
	slot.Anchored     = true
	slot.CanCollide   = false
	slot.Transparency = 0.3
	slot.Color        = MapConfig.Palette.PlotBase
	slot.Material     = Enum.Material.SmoothPlastic
	slot.CastShadow   = false
	slot.Parent       = gridFolder

	local bg = Instance.new("BillboardGui")
	bg.Size            = UDim2.fromScale(1.2, 0.6)
	bg.StudsOffset     = Vector3.new(0, 0.5, 0)
	bg.AlwaysOnTop     = false
	bg.Parent          = slot

	local lbl = Instance.new("TextLabel")
	lbl.Size                 = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text                 = string.format("%d,%d", col, row)
	lbl.TextColor3           = Color3.fromRGB(80, 85, 110)
	lbl.TextScaled           = true
	lbl.Font                 = Enum.Font.GothamBold
	lbl.Parent               = bg

	slotParts[i] = slot
end

-- ───────── PLACEMENT / SUPPRESSION VISUELS ─────────

local function placeBuilding(player, buildingType)
	local def = BUILDING_DEFS[buildingType]
	if not def then return end

	local slotIdx = nextFreeSlot()
	if not slotIdx then
		warn("MapBuilder: grille pleine, impossible de placer", buildingType, "pour", player.Name)
		return
	end

	usedSlots[slotIdx] = player.UserId

	local x, z = slotCenter(slotIdx)
	local part  = Instance.new("Part")
	part.Name       = "Building_" .. buildingType .. "_" .. player.UserId
	part.Size       = def.size
	part.Position   = Vector3.new(x, def.yOffset, z)
	part.Anchored   = true
	part.CanCollide = false
	part.Color      = def.color
	part.Material   = Enum.Material.SmoothPlastic
	part.Parent     = gridFolder

	local userId = player.UserId
	if not playerSlots[userId] then playerSlots[userId] = {} end
	table.insert(playerSlots[userId], { part = part, type = buildingType, slotIdx = slotIdx })

	-- Expose buildingVisuals[userId][buildingType] pour futures animations
	if not buildingVisuals[userId] then buildingVisuals[userId] = {} end
	if not buildingVisuals[userId][buildingType] then
		buildingVisuals[userId][buildingType] = {}
	end
	table.insert(buildingVisuals[userId][buildingType], part)
end

local function removeBuilding(player, buildingType)
	local userId = player.UserId
	local slots  = playerSlots[userId]
	if not slots then return end

	for i = #slots, 1, -1 do
		local entry = slots[i]
		if entry.type == buildingType then
			entry.part:Destroy()
			usedSlots[entry.slotIdx] = nil
			table.remove(slots, i)

			-- Nettoie buildingVisuals
			local typeList = buildingVisuals[userId] and buildingVisuals[userId][buildingType]
			if typeList then
				for j = #typeList, 1, -1 do
					if typeList[j] == entry.part or not typeList[j].Parent then
						table.remove(typeList, j)
						break
					end
				end
			end
			return
		end
	end
end

local function cleanupPlayer(player)
	local userId = player.UserId
	local slots  = playerSlots[userId]
	if slots then
		for _, entry in ipairs(slots) do
			if entry.part and entry.part.Parent then
				entry.part:Destroy()
			end
			usedSlots[entry.slotIdx] = nil
		end
		playerSlots[userId]  = nil
		buildingVisuals[userId] = nil
	end
end

-- ───────── LISTENER ATTRIBUT "Buildings" ─────────

local function setupListener(player)
	local prevCounts = parseBuildings(player:GetAttribute("Buildings"))

	player:GetAttributeChangedSignal("Buildings"):Connect(function()
		local newCounts = parseBuildings(player:GetAttribute("Buildings"))

		for btype, newCount in pairs(newCounts) do
			local oldCount = prevCounts[btype] or 0
			for _ = 1, newCount - oldCount do
				placeBuilding(player, btype)
			end
		end

		for btype, oldCount in pairs(prevCounts) do
			local newCount = newCounts[btype] or 0
			for _ = 1, oldCount - newCount do
				removeBuilding(player, btype)
			end
		end

		prevCounts = newCounts
	end)
end

-- ───────── LIFECYCLE JOUEURS ─────────

Players.PlayerAdded:Connect(setupListener)

Players.PlayerRemoving:Connect(cleanupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
	setupListener(player)
end

print("✅ MapBuilder loaded")
