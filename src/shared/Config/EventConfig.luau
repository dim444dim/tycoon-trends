local EventConfig = {}

EventConfig.Events = {
	twitch_raid = {
		name = "🎤 Twitch Raid",
		multiplier = 1.5,
		duration = 3600,
		color = Color3.fromRGB(145, 70, 255),
		description = "A streamer raids your factory!"
	},
	rapper_drop = {
		name = "🎵 Rapper Drop",
		multiplier = 2.0,
		duration = 1800,
		color = Color3.fromRGB(255, 100, 50),
		description = "A rapper just dropped a hit!"
	},
	tiktok_trend = {
		name = "📱 TikTok Trend",
		multiplier = 1.3,
		duration = 900,
		color = Color3.fromRGB(0, 200, 200),
		description = "Your factory is trending!"
	}
}

function EventConfig.getAll()
	local events = {}
	for eventId, eventData in pairs(EventConfig.Events) do
		table.insert(events, {
			id = eventId,
			name = eventData.name,
			multiplier = eventData.multiplier,
			duration = eventData.duration,
			color = eventData.color,
			description = eventData.description
		})
	end
	return events
end

return EventConfig
