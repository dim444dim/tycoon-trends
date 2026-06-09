-- Point d'entrée client (LocalScript)
-- À compléter avec HUD, shop UI, effets visuels.
print("[TycoonTrends] Client init")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

-- Écoute les mises à jour HUD (placeholder)
Remotes.UpdateHUD.OnClientEvent:Connect(function(data)
	-- TODO: mettre à jour le ScreenGui
	-- data.cash, data.rate, data.sessionEarned, data.trends
end)

-- Écoute les changements de tendances (placeholder)
Remotes.TrendChanged.OnClientEvent:Connect(function(trends)
	-- TODO: afficher les tendances actives dans l'UI
end)

-- Écoute l'état de session (placeholder)
Remotes.SessionState.OnClientEvent:Connect(function(sessionState, timeLeft)
	-- TODO: afficher countdown / résultats
end)
