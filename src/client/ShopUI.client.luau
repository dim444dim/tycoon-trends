local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes        = require(ReplicatedStorage.Shared.Remotes)
local GameConfig     = require(ReplicatedStorage.Shared.GameConfig)
local GameplayConfig = require(ReplicatedStorage.Shared.GameplayConfig)

-- ─────────────────────────────────────────
--   CONSTANTES VISUELLES (cohérent avec FactoryHUD)
-- ─────────────────────────────────────────

local BG_COLOR   = Color3.fromRGB(18, 18, 30)
local BG_ALPHA   = 0.3
local TEXT_WHITE = Color3.new(1, 1, 1)

local ICONS = {
	workshop  = "⚙️",
	factory   = "🏭",
	megaplant = "🏗️",
	hq        = "🏢",
}

-- ─────────────────────────────────────────
--   GUI RACINE
-- ─────────────────────────────────────────

local ShopGui = Instance.new("ScreenGui")
ShopGui.Name = "ShopUI"
ShopGui.ResetOnSpawn = false
ShopGui.Parent = playerGui

-- ─────────────────────────────────────────
--   TOGGLE BUTTON (☰ Shop)
-- ─────────────────────────────────────────

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleShop"
ToggleBtn.Size = UDim2.new(0, 90, 0, 34)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.19, 0)
ToggleBtn.BackgroundColor3 = GameConfig.CouleurPrimaire
ToggleBtn.BorderSizePixel = 0
ToggleBtn.TextScaled = true
ToggleBtn.TextColor3 = TEXT_WHITE
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "☰ Shop"
ToggleBtn.Parent = ShopGui

local TCorner = Instance.new("UICorner")
TCorner.CornerRadius = UDim.new(0, 8)
TCorner.Parent = ToggleBtn

-- ─────────────────────────────────────────
--   PANEL PRINCIPAL
-- ─────────────────────────────────────────

local ShopPanel = Instance.new("Frame")
ShopPanel.Name = "ShopPanel"
ShopPanel.Size = UDim2.new(0, 280, 0, 0)   -- hauteur gérée par UIListLayout
ShopPanel.Position = UDim2.new(0.02, 0, 0.19, 44)  -- juste sous le ToggleBtn (34px + 10 gap)
ShopPanel.AnchorPoint = Vector2.new(0, 0)
ShopPanel.BackgroundColor3 = BG_COLOR
ShopPanel.BackgroundTransparency = BG_ALPHA
ShopPanel.BorderSizePixel = 0
ShopPanel.ClipsDescendants = true
ShopPanel.Visible = false
ShopPanel.Parent = ShopGui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = ShopPanel

local PanelPad = Instance.new("UIPadding")
PanelPad.PaddingTop    = UDim.new(0, 10)
PanelPad.PaddingBottom = UDim.new(0, 10)
PanelPad.PaddingLeft   = UDim.new(0, 10)
PanelPad.PaddingRight  = UDim.new(0, 10)
PanelPad.Parent = ShopPanel

local PanelLayout = Instance.new("UIListLayout")
PanelLayout.Padding = UDim.new(0, 8)
PanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
PanelLayout.Parent = ShopPanel

-- Titre intégré au panel
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.LayoutOrder = 0
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextScaled = true
TitleLabel.TextColor3 = GameConfig.CouleurAccent
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.Text = "🏪 Boutique"
TitleLabel.Parent = ShopPanel

-- ─────────────────────────────────────────
--   BUILDING CARD
-- ─────────────────────────────────────────

local cardRefs = {}   -- [buildingId] = { costLabel, ownedLabel, buyBtn }

local function flashButton(btn, color, delay)
	local orig = btn.BackgroundColor3
	btn.BackgroundColor3 = color
	task.delay(delay or 0.4, function()
		if btn and btn.Parent then
			btn.BackgroundColor3 = orig
		end
	end)
end

local function createBuildingCard(building, order)
	local id   = building.id
	local icon = ICONS[id] or "🏠"

	-- Carte
	local card = Instance.new("Frame")
	card.Name = id
	card.LayoutOrder = order
	card.Size = UDim2.new(1, 0, 0, 72)
	card.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	card.BackgroundTransparency = 0
	card.BorderSizePixel = 0
	card.Parent = ShopPanel

	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 8)
	cc.Parent = card

	-- Icône + nom
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(0.55, 0, 0.55, 0)
	nameLabel.Position = UDim2.new(0.02, 0, 0.05, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextScaled = true
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextColor3 = TEXT_WHITE
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = icon .. " " .. building.name
	nameLabel.Parent = card

	-- Owned count
	local ownedLabel = Instance.new("TextLabel")
	ownedLabel.Name = "OwnedLabel"
	ownedLabel.Size = UDim2.new(0.55, 0, 0.38, 0)
	ownedLabel.Position = UDim2.new(0.02, 0, 0.58, 0)
	ownedLabel.BackgroundTransparency = 1
	ownedLabel.TextScaled = true
	ownedLabel.TextXAlignment = Enum.TextXAlignment.Left
	ownedLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
	ownedLabel.Font = Enum.Font.Gotham
	ownedLabel.Text = "+$" .. building.rate .. "/sec  ×0"
	ownedLabel.Parent = card

	-- Coût
	local costLabel = Instance.new("TextLabel")
	costLabel.Name = "CostLabel"
	costLabel.Size = UDim2.new(0.4, 0, 0.45, 0)
	costLabel.Position = UDim2.new(0.58, 0, 0.05, 0)
	costLabel.BackgroundTransparency = 1
	costLabel.TextScaled = true
	costLabel.TextXAlignment = Enum.TextXAlignment.Right
	costLabel.TextColor3 = GameConfig.CouleurAccent
	costLabel.Font = Enum.Font.GothamBold
	costLabel.Text = "$..."
	costLabel.Parent = card

	-- Bouton BUY
	local buyBtn = Instance.new("TextButton")
	buyBtn.Name = "BuyButton"
	buyBtn.Size = UDim2.new(0.4, 0, 0.38, 0)
	buyBtn.Position = UDim2.new(0.58, 0, 0.56, 0)
	buyBtn.BackgroundColor3 = GameConfig.CouleurSecondaire
	buyBtn.BorderSizePixel = 0
	buyBtn.TextScaled = true
	buyBtn.TextColor3 = Color3.fromRGB(10, 10, 20)
	buyBtn.Font = Enum.Font.GothamBold
	buyBtn.Text = "BUY"
	buyBtn.Parent = card

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 6)
	bc.Parent = buyBtn

	buyBtn.MouseButton1Click:Connect(function()
		Remotes.BuyBuilding:FireServer({ buildingType = id })
	end)

	cardRefs[id] = { costLabel = costLabel, ownedLabel = ownedLabel, buyBtn = buyBtn, rate = building.rate }
	return card
end

-- Génère les cartes depuis le catalogue
for i, building in ipairs(GameplayConfig.Buildings) do
	createBuildingCard(building, i)
end

-- Resize panel au contenu
local function resizePanel()
	ShopPanel.Size = UDim2.new(0, 280, 0, PanelLayout.AbsoluteContentSize.Y + 20)
end
PanelLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizePanel)
task.defer(resizePanel)  -- attend le premier layout pass

-- ─────────────────────────────────────────
--   HELPERS AFFICHAGE
-- ─────────────────────────────────────────

local function formatCash(v)
	if v >= 1_000_000 then
		return string.format("%.1fM", v / 1_000_000)
	elseif v >= 1_000 then
		return string.format("%.1fK", v / 1_000)
	end
	return tostring(math.floor(v))
end

local function updateCard(buildingId, owned, nextCost)
	local refs = cardRefs[buildingId]
	if not refs then return end
	refs.costLabel.Text = "$" .. formatCash(nextCost)
	refs.ownedLabel.Text = "+$" .. refs.rate .. "/sec  ×" .. tostring(owned)
end

-- ─────────────────────────────────────────
--   INIT — récupère les données via GetShopData
-- ─────────────────────────────────────────

task.spawn(function()
	-- Attente que le server soit prêt
	task.wait(1)
	local ok, shopData = pcall(function()
		return Remotes.GetShopData:InvokeServer()
	end)
	if ok and type(shopData) == "table" then
		for id, data in pairs(shopData) do
			updateCard(id, data.owned, data.nextCost)
		end
	end
end)

-- ─────────────────────────────────────────
--   TOGGLE SHOP PANEL
-- ─────────────────────────────────────────

local shopOpen = false

ToggleBtn.MouseButton1Click:Connect(function()
	shopOpen = not shopOpen
	if shopOpen then
		ShopPanel.Visible = true
		ShopPanel.BackgroundTransparency = 1
		TweenService:Create(ShopPanel, TweenInfo.new(0.2), { BackgroundTransparency = BG_ALPHA }):Play()
		ToggleBtn.Text = "✕ Shop"
	else
		TweenService:Create(ShopPanel, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
		task.delay(0.15, function() ShopPanel.Visible = false end)
		ToggleBtn.Text = "☰ Shop"
	end
end)

-- ─────────────────────────────────────────
--   REMOTE LISTENER — BuyBuilding
-- ─────────────────────────────────────────

Remotes.BuyBuilding.OnClientEvent:Connect(function(data)
	if not data then return end
	local refs = cardRefs[data.buildingType]

	if data.success then
		updateCard(data.buildingType, data.owned, data.nextCost)
		if refs then
			flashButton(refs.buyBtn, Color3.fromRGB(80, 200, 120), 0.5)
		end
	else
		if refs then
			if data.error == "max_buildings" then
				refs.buyBtn.Text = "MAX"
				task.delay(1.5, function()
					if refs.buyBtn and refs.buyBtn.Parent then
						refs.buyBtn.Text = "BUY"
					end
				end)
			else
				flashButton(refs.buyBtn, Color3.fromRGB(220, 60, 60), 0.4)
			end
		end
	end
end)

print("✅ ShopUI loaded")
