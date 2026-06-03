# Référence API

## EventConfig

### EventConfig.Events
Table des événements disponibles.

```lua
EventConfig.Events[eventId] = {
    name: string,
    multiplier: number,
    duration: number,
    color: Color3,
    description: string
}
```

### EventConfig.getAll()
Retourne la liste de tous les événements.

```lua
local allEvents = EventConfig.getAll()
-- Retourne: [{id, name, multiplier, duration, color, description}, ...]
```

## BuildingsHelper

Helpers pour les bâtiments (à implémenter).

### BuildingsHelper.createBuilding(config)
Crée un nouveau bâtiment avec la configuration donnée.

## UIConstants

Constantes pour l'interface utilisateur (à implémenter).

### UIConstants.EVENT_DISPLAY_SIZE
Taille de l'affichage des événements.

### UIConstants.EVENT_COLORS
Table des couleurs pour les événements.
