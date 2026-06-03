local PlayerInitializer = {}

local PLAYER_SCHEMA = {
	Cash              = 0,
	ProductionRate    = 0,
	Buildings         = "",
	PrestigeCount     = 0,
	PrestigeMultiplier = 1.0,
	BoostMultiplier   = 1.0,
	EventMultiplier   = 1.0,
	DaysLogged        = 0,
	LastLoginDay      = 0,
	CosmeticSelected  = "default",
	FriendsList       = "",
	GuildId           = "",
}

function PlayerInitializer.initializePlayer(player: Player)
	for attribute, default in PLAYER_SCHEMA do
		if player:GetAttribute(attribute) == nil then
			player:SetAttribute(attribute, default)
		end
	end
end

function PlayerInitializer.getSchema()
	return PLAYER_SCHEMA
end

return PlayerInitializer
