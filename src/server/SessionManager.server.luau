--[[
	SessionManager.server.luau (TycoonTrends)
	Gère le cycle de vie des sessions : LOBBY → ACTIVE → RESULTS → LOBBY.
	Expose un Folder "GameState" dans ReplicatedStorage avec les Attributes :
	  State     : "LOBBY" | "ACTIVE" | "RESULTS"
	  TimeLeft  : secondes restantes dans la session active
	  SessionId : compteur incrémental (identifie la session courante)
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

print("[SessionManager] init")

-- ───────── GAME STATE ─────────
local state = Instance.new("Folder")
state.Name   = "GameState"
state.Parent = ReplicatedStorage

state:SetAttribute("State",     "LOBBY")
state:SetAttribute("TimeLeft",  0)
state:SetAttribute("SessionId", 0)

-- ───────── HELPERS ─────────
local sessionRunning = false

local function setState(s)
	state:SetAttribute("State", s)
	print("[SessionManager] State →", s)
end

local function startSession()
	if sessionRunning then return end
	sessionRunning = true

	local id = (state:GetAttribute("SessionId") or 0) + 1
	state:SetAttribute("SessionId", id)
	setState("ACTIVE")

	task.spawn(function()
		local t = GameConfig.SessionDuration
		while t > 0 and state:GetAttribute("State") == "ACTIVE" do
			state:SetAttribute("TimeLeft", t)
			task.wait(1)
			t -= 1
		end

		if state:GetAttribute("State") == "ACTIVE" then
			setState("RESULTS")
			task.wait(GameConfig.EndDuration)
			setState("LOBBY")
			sessionRunning = false
			-- Réinitialise les stats de session des joueurs
			for _, player in Players:GetPlayers() do
				player:SetAttribute("SessionEarned", 0)
				player:SetAttribute("Buildings", "")
				player:SetAttribute("Cash", GameConfig.StartingCash)
			end
		end
	end)
end

-- ───────── AUTO-START ─────────
local function checkStart()
	if state:GetAttribute("State") == "LOBBY" and not sessionRunning then
		if #Players:GetPlayers() >= GameConfig.MinPlayers then
			task.wait(GameConfig.PrepDuration)
			-- Re-vérifier après le délai (des joueurs peuvent être partis)
			if #Players:GetPlayers() >= GameConfig.MinPlayers then
				startSession()
			end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	-- Cash de départ
	player:SetAttribute("Cash", GameConfig.StartingCash)
	player:SetAttribute("SessionEarned", 0)
	player:SetAttribute("Buildings", "")
	checkStart()
end)

Players.PlayerRemoving:Connect(function()
	-- Arrêt propre si plus personne
	if #Players:GetPlayers() <= 1 and state:GetAttribute("State") == "ACTIVE" then
		setState("RESULTS")
		task.wait(3)
		setState("LOBBY")
		sessionRunning = false
	end
end)

-- Démarre si des joueurs sont déjà là (test Studio solo)
if #Players:GetPlayers() >= GameConfig.MinPlayers then
	task.delay(2, startSession)
end
