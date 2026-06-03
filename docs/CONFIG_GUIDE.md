# Guide de configuration

## Fichiers de configuration

### EventConfig.luau
Configure les 3 événements du jeu.

```lua
local EventConfig = {}

EventConfig.Events = {
    twitch_raid = {
        name = "🎤 Twitch Raid",
        multiplier = 1.5,
        duration = 3600,
        color = Color3.fromRGB(145, 70, 255),
        description = "A streamer raids your factory!"
    },
}
```

## Modification des événements

1. Ouvrez `src/shared/Config/EventConfig.luau`
2. Modifiez les propriétés (multiplicateur, durée, couleur)
3. Sauvegardez et reloadez le jeu

## Constantes UI

Voir `src/client/UIConstants.luau` pour les valeurs de couleur et de positionnement.

## Helpers de bâtiments

Voir `src/shared/Helpers/BuildingsHelper.luau` pour les fonctions utilitaires.
