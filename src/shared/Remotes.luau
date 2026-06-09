--[[
	Remotes.luau (TycoonTrends)
	Crée et expose les RemoteEvents / RemoteFunctions partagés.
	À require() côté server ET client.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EVENTS = {
	"BuyBuilding",     -- client → server : acheter un bâtiment (buildingId: string)
	"SellBuilding",    -- client → server : vendre un bâtiment (buildingId: string)
	"CollectCash",     -- client → server : ramasser le cash accumulé
	"UpdateHUD",       -- server → client : mettre à jour l'affichage (cash, rate)
	"TrendChanged",    -- server → allClients : nouvelles tendances actives (table)
	"SessionState",    -- server → allClients : changement d'état de session (state, timeLeft)
	"BoostSpawned",    -- server → allClients : nouveau boost actif {id, multiplier, duration, endsAt}
	"BoostExpired",    -- server → allClients : boost expiré {id}
	"PrestigeReset",   -- client → server : {confirm=true} / server → client : {success, multiplier?, error?}
	"EventStarted",    -- server → allClients : event démarré {eventId, name, multiplier, duration, color}
	"EventEnded",      -- server → allClients : event terminé
}

local FUNCTIONS = {
	"GetShopData",     -- client → server : récupère le catalogue de bâtiments
}

local function ensureFolder()
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
	return folder
end

local folder = ensureFolder()
local Remotes = {}

for _, name in ipairs(EVENTS) do
	local ev = folder:FindFirstChild(name)
	if not ev then
		ev = Instance.new("RemoteEvent")
		ev.Name = name
		ev.Parent = folder
	end
	Remotes[name] = ev
end

for _, name in ipairs(FUNCTIONS) do
	local fn = folder:FindFirstChild(name)
	if not fn then
		fn = Instance.new("RemoteFunction")
		fn.Name = name
		fn.Parent = folder
	end
	Remotes[name] = fn
end

return Remotes
