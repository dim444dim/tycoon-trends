--[[
	PrestigeUI.client.luau (TycoonTrends)
	Bouton Prestige (bas-droite) + modal de confirmation + toast de succès.
	- Monitore l'attribut Cash du joueur
	- Tween in/out selon éligibilité (tier ≥ 1)
	- Modal bloquant avec CONFIRM / CANCEL
	- Toast 3 s après prestige réussi
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes    = require(ReplicatedStorage.Shared.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

-- ─────────────────────────────────────────
--   CONSTANTES
-- ─────────────────────────────────────────

local TWEEN_IN  = TweenInfo.new(0.25, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
local TWEEN_OUT = TweenInfo.new(0.18, Enum.EasingStyle.Quad,  Enum.EasingDirection.In)

local BG_DARK    = Color3.fromRGB(18, 18, 30)
local TEXT_WHITE = Color3.new(1, 1, 1)
local BTN_ORANGE = Color3.fromRGB(255, 200, 100)
local BTN_GREEN  = Color3.fromRGB(80, 200, 120)
local BTN_RED    = Color3.fromRGB(220, 60, 60)

local THRESHOLDS = GameConfig.PrestigeThresholds   -- { 100000, 500000, 2500000, 10000000 }
local BONUSES    = GameConfig.PrestigeBonus        -- { 1.1, 1.25, 1.5, 2.0 }

-- ─────────────────────────────────────────
--   GUI RACINE
-- ─────────────────────────────────────────

local PrestigeGui = Instance.new("ScreenGui")
PrestigeGui.Name           = "PrestigeUI"
PrestigeGui.ResetOnSpawn   = false
PrestigeGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
PrestigeGui.Parent         = playerGui

-- ─────────────────────────────────────────
--   BOUTON PRESTIGE (bas-droite)
-- ─────────────────────────────────────────

local PrestigeBtn = Instance.new("TextButton")
PrestigeBtn.Name                  = "PrestigeButton"
PrestigeBtn.AnchorPoint           = Vector2.new(0, 0)
PrestigeBtn.Size                  = UDim2.new(0.1, 0, 0.08, 0)
PrestigeBtn.Position              = UDim2.new(0.88, 0, 0.88, 0)
PrestigeBtn.BackgroundColor3      = BTN_ORANGE
PrestigeBtn.BorderSizePixel       = 0
PrestigeBtn.TextScaled            = true
PrestigeBtn.TextColor3            = Color3.fromRGB(30, 20, 0)
PrestigeBtn.Font                  = Enum.Font.GothamBlack
PrestigeBtn.Text                  = "✨ PRESTIGE"
PrestigeBtn.BackgroundTransparency = 1
PrestigeBtn.TextTransparency      = 1
PrestigeBtn.Visible               = false
PrestigeBtn.ZIndex                = 5
PrestigeBtn.Parent                = PrestigeGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 10)
BtnCorner.Parent = PrestigeBtn

-- ─────────────────────────────────────────
--   OVERLAY MODAL (fond bloquant)
-- ─────────────────────────────────────────

-- TextButton plein-écran pour capturer les clics en dehors du modal
local ModalOverlay = Instance.new("TextButton")
ModalOverlay.Name                  = "ModalOverlay"
ModalOverlay.Size                  = UDim2.new(1, 0, 1, 0)
ModalOverlay.Position              = UDim2.new(0, 0, 0, 0)
ModalOverlay.BackgroundColor3      = Color3.new(0, 0, 0)
ModalOverlay.BackgroundTransparency = 0.5
ModalOverlay.BorderSizePixel       = 0
ModalOverlay.Text                  = ""
ModalOverlay.AutoButtonColor       = false
ModalOverlay.Visible               = false
ModalOverlay.ZIndex                = 10
ModalOverlay.Parent                = PrestigeGui

-- ─────────────────────────────────────────
--   MODAL DE CONFIRMATION
-- ─────────────────────────────────────────

local ConfirmModal = Instance.new("Frame")
ConfirmModal.Name             = "ConfirmModal"
ConfirmModal.AnchorPoint      = Vector2.new(0.5, 0.5)
ConfirmModal.Size             = UDim2.new(0.4, 0, 0.3, 0)
ConfirmModal.Position         = UDim2.new(0.5, 0, 0.5, 0)
ConfirmModal.BackgroundColor3 = BG_DARK
ConfirmModal.BorderSizePixel  = 0
ConfirmModal.Visible          = false
ConfirmModal.ZIndex           = 11
ConfirmModal.Parent           = PrestigeGui

local ModalCorner = Instance.new("UICorner")
ModalCorner.CornerRadius = UDim.new(0, 14)
ModalCorner.Parent = ConfirmModal

local ModalPad = Instance.new("UIPadding")
ModalPad.PaddingTop    = UDim.new(0, 18)
ModalPad.PaddingBottom = UDim.new(0, 18)
ModalPad.PaddingLeft   = UDim.new(0, 20)
ModalPad.PaddingRight  = UDim.new(0, 20)
ModalPad.Parent = ConfirmModal

local ModalTitle = Instance.new("TextLabel")
ModalTitle.Name                 = "Title"
ModalTitle.Size                 = UDim2.new(1, 0, 0.22, 0)
ModalTitle.Position             = UDim2.new(0, 0, 0, 0)
ModalTitle.BackgroundTransparency = 1
ModalTitle.TextScaled           = true
ModalTitle.TextColor3           = BTN_ORANGE
ModalTitle.Font                 = Enum.Font.GothamBlack
ModalTitle.Text                 = "✨ PRESTIGE"
ModalTitle.ZIndex               = 12
ModalTitle.Parent               = ConfirmModal

local ModalInfo = Instance.new("TextLabel")
ModalInfo.Name                 = "Info"
ModalInfo.Size                 = UDim2.new(1, 0, 0.28, 0)
ModalInfo.Position             = UDim2.new(0, 0, 0.24, 0)
ModalInfo.BackgroundTransparency = 1
ModalInfo.TextScaled           = true
ModalInfo.TextColor3           = TEXT_WHITE
ModalInfo.Font                 = Enum.Font.GothamBold
ModalInfo.Text                 = ""
ModalInfo.ZIndex               = 12
ModalInfo.Parent               = ConfirmModal

local ModalQuestion = Instance.new("TextLabel")
ModalQuestion.Name                 = "Question"
ModalQuestion.Size                 = UDim2.new(1, 0, 0.18, 0)
ModalQuestion.Position             = UDim2.new(0, 0, 0.54, 0)
ModalQuestion.BackgroundTransparency = 1
ModalQuestion.TextScaled           = true
ModalQuestion.TextColor3           = Color3.fromRGB(200, 180, 140)
ModalQuestion.Font                 = Enum.Font.Gotham
ModalQuestion.Text                 = "Reset cash & buildings. Are you sure?"
ModalQuestion.ZIndex               = 12
ModalQuestion.Parent               = ConfirmModal

local ConfirmBtn = Instance.new("TextButton")
ConfirmBtn.Name             = "ConfirmButton"
ConfirmBtn.Size             = UDim2.new(0.44, 0, 0.2, 0)
ConfirmBtn.Position         = UDim2.new(0.04, 0, 0.77, 0)
ConfirmBtn.BackgroundColor3 = BTN_GREEN
ConfirmBtn.BorderSizePixel  = 0
ConfirmBtn.TextScaled       = true
ConfirmBtn.TextColor3       = Color3.fromRGB(10, 30, 15)
ConfirmBtn.Font             = Enum.Font.GothamBold
ConfirmBtn.Text             = "✅ CONFIRM"
ConfirmBtn.ZIndex           = 12
ConfirmBtn.Parent           = ConfirmModal

local ConfirmCorner = Instance.new("UICorner")
ConfirmCorner.CornerRadius = UDim.new(0, 8)
ConfirmCorner.Parent = ConfirmBtn

local CancelBtn = Instance.new("TextButton")
CancelBtn.Name             = "CancelButton"
CancelBtn.Size             = UDim2.new(0.44, 0, 0.2, 0)
CancelBtn.Position         = UDim2.new(0.52, 0, 0.77, 0)
CancelBtn.BackgroundColor3 = BTN_RED
CancelBtn.BorderSizePixel  = 0
CancelBtn.TextScaled       = true
CancelBtn.TextColor3       = TEXT_WHITE
CancelBtn.Font             = Enum.Font.GothamBold
CancelBtn.Text             = "✕ CANCEL"
CancelBtn.ZIndex           = 12
CancelBtn.Parent           = ConfirmModal

local CancelCorner = Instance.new("UICorner")
CancelCorner.CornerRadius = UDim.new(0, 8)
CancelCorner.Parent = CancelBtn

-- ─────────────────────────────────────────
--   TOAST (centre-haut)
-- ─────────────────────────────────────────

local Toast = Instance.new("TextLabel")
Toast.Name                  = "Toast"
Toast.AnchorPoint           = Vector2.new(0.5, 0)
Toast.Size                  = UDim2.new(0.45, 0, 0.07, 0)
Toast.Position              = UDim2.new(0.5, 0, 0.05, 0)
Toast.BackgroundColor3      = Color3.fromRGB(40, 30, 10)
Toast.BorderSizePixel       = 0
Toast.TextScaled            = true
Toast.TextColor3            = BTN_ORANGE
Toast.Font                  = Enum.Font.GothamBlack
Toast.Text                  = ""
Toast.BackgroundTransparency = 1
Toast.TextTransparency      = 1
Toast.Visible               = false
Toast.ZIndex                = 20
Toast.Parent                = PrestigeGui

local ToastCorner = Instance.new("UICorner")
ToastCorner.CornerRadius = UDim.new(0, 10)
ToastCorner.Parent = Toast

-- ─────────────────────────────────────────
--   HELPERS TIER
-- ─────────────────────────────────────────

local function getCurrentEligibleTier(cash)
	local tier = 0
	for i, threshold in ipairs(THRESHOLDS) do
		if cash >= threshold then
			tier = i
		end
	end
	return tier
end

local function tierFromMultiplier(mult)
	for i, bonus in ipairs(BONUSES) do
		if math.abs(bonus - mult) < 0.001 then return i end
	end
	return 0
end

-- ─────────────────────────────────────────
--   BOUTON : TWEEN IN / OUT
-- ─────────────────────────────────────────

local btnVisible = false
local btnTween: Tween? = nil

local function showButton()
	if btnVisible then return end
	btnVisible = true
	PrestigeBtn.Visible = true
	if btnTween then btnTween:Cancel() end
	btnTween = TweenService:Create(PrestigeBtn, TWEEN_IN, {
		BackgroundTransparency = 0,
		TextTransparency       = 0,
	})
	btnTween:Play()
end

local function hideButton()
	if not btnVisible then return end
	btnVisible = false
	if btnTween then btnTween:Cancel() end
	local t = TweenService:Create(PrestigeBtn, TWEEN_OUT, {
		BackgroundTransparency = 1,
		TextTransparency       = 1,
	})
	t:Play()
	t.Completed:Once(function()
		if not btnVisible then
			PrestigeBtn.Visible = false
		end
	end)
	btnTween = t
end

-- ─────────────────────────────────────────
--   MODAL : OPEN / CLOSE
-- ─────────────────────────────────────────

local modalOpen = false

local function openModal(tier: number, multiplier: number)
	if modalOpen then return end
	modalOpen = true
	ModalInfo.Text = string.format("Tier %d  →  ×%.2f multiplier (permanent)", tier, multiplier)
	ConfirmBtn.Text = "✅ CONFIRM"
	ConfirmBtn.AutoButtonColor = true
	ModalOverlay.Visible = true
	ConfirmModal.Visible = true
	ConfirmModal.Size = UDim2.new(0.01, 0, 0.01, 0)
	TweenService:Create(ConfirmModal, TWEEN_IN, { Size = UDim2.new(0.4, 0, 0.3, 0) }):Play()
end

local function closeModal()
	if not modalOpen then return end
	modalOpen = false
	local t = TweenService:Create(ConfirmModal, TWEEN_OUT, { Size = UDim2.new(0.01, 0, 0.01, 0) })
	t:Play()
	t.Completed:Once(function()
		ConfirmModal.Visible = false
		ModalOverlay.Visible = false
		ConfirmModal.Size = UDim2.new(0.4, 0, 0.3, 0)
	end)
end

-- ─────────────────────────────────────────
--   TOAST : SHOW + AUTO-HIDE
-- ─────────────────────────────────────────

local toastThread: thread? = nil

local function showToast(text: string)
	if toastThread then
		task.cancel(toastThread)
		toastThread = nil
	end
	Toast.Text = text
	Toast.Visible = true
	Toast.BackgroundTransparency = 0
	Toast.TextTransparency = 0
	toastThread = task.delay(3, function()
		TweenService:Create(Toast, TweenInfo.new(0.5), {
			BackgroundTransparency = 1,
			TextTransparency       = 1,
		}):Play()
		task.wait(0.5)
		Toast.Visible = false
	end)
end

-- ─────────────────────────────────────────
--   MONITORING CASH
-- ─────────────────────────────────────────

local function onCashChanged()
	local cash = player:GetAttribute("Cash") or 0
	if getCurrentEligibleTier(cash) > 0 then
		showButton()
	else
		hideButton()
	end
end

player:GetAttributeChangedSignal("Cash"):Connect(onCashChanged)
onCashChanged()  -- état initial

-- ─────────────────────────────────────────
--   INTERACTIONS
-- ─────────────────────────────────────────

PrestigeBtn.MouseButton1Click:Connect(function()
	local cash = player:GetAttribute("Cash") or 0
	local tier = getCurrentEligibleTier(cash)
	if tier == 0 then return end
	openModal(tier, BONUSES[tier])
end)

CancelBtn.MouseButton1Click:Connect(closeModal)

-- Clic en dehors du modal → ferme
ModalOverlay.MouseButton1Click:Connect(closeModal)

ConfirmBtn.MouseButton1Click:Connect(function()
	if not modalOpen then return end
	ConfirmBtn.Text            = "..."
	ConfirmBtn.AutoButtonColor = false
	Remotes.PrestigeReset:FireServer({ confirm = true })
end)

-- ─────────────────────────────────────────
--   RÉPONSE SERVEUR
-- ─────────────────────────────────────────

Remotes.PrestigeReset.OnClientEvent:Connect(function(data)
	-- Restaure le bouton dans tous les cas
	ConfirmBtn.Text            = "✅ CONFIRM"
	ConfirmBtn.AutoButtonColor = true

	if not data then return end

	if data.success then
		closeModal()
		local multiplier = data.multiplier or 1.0
		local tier       = tierFromMultiplier(multiplier)
		showToast(string.format("🎉 Prestige Tier %d! ×%.2f", tier, multiplier))
		hideButton()  -- cash vient d'être remis à 0 côté serveur
	else
		-- Flash rouge sur CONFIRM pour signaler l'échec
		local orig = ConfirmBtn.BackgroundColor3
		ConfirmBtn.BackgroundColor3 = BTN_RED
		task.delay(0.8, function()
			if ConfirmBtn and ConfirmBtn.Parent then
				ConfirmBtn.BackgroundColor3 = orig
			end
		end)
	end
end)

print("✅ PrestigeUI loaded")
