# Système d'événements

## Événements disponibles

### 1. Twitch Raid 🎤
- **Multiplicateur** : 1.5x
- **Durée** : 3600s (1h)
- **Couleur** : Violet (145, 70, 255)
- **Description** : "A streamer raids your factory!"

### 2. Rapper Drop 🎵
- **Multiplicateur** : 2.0x
- **Durée** : 1800s (30min)
- **Couleur** : Orange (255, 100, 50)
- **Description** : "A rapper just dropped a hit!"

### 3. TikTok Trend 📱
- **Multiplicateur** : 1.3x
- **Durée** : 900s (15min)
- **Couleur** : Cyan (0, 200, 200)
- **Description** : "Your factory is trending!"

## Configuration

Les événements sont définis dans `EventConfig.luau` :

```lua
EventConfig.Events.twitch_raid.multiplier = 1.5
EventConfig.Events.rapper_drop.duration = 1800
```

## Utilisation

- Serveur : `EventConfig.Events[eventId]`
- Client : `EventConfig.getAll()`
