# Architecture TycoonTrends

## Vue d'ensemble

```
┌─────────────────┐
│    Serveur      │
├─────────────────┤
│ PlayerInitializer
│ EventTrigger
│ GameLogic
└────────┬────────┘
         │
    ┌────▼────┐
    │ Network  │
    └────┬────┘
         │
┌────────▼────────┐
│    Client       │
├─────────────────┤
│ UIConstants
│ EventSystem
│ PlayerUI
└─────────────────┘
```

## Modules clés

### Serveur
- **PlayerInitializer** - Initialise les joueurs
- **EventTrigger** - Déclenche les événements

### Client
- **UIConstants** - Constantes UI
- **EventSystem** - Gère les événements client

### Partagé
- **EventConfig** - Configuration des événements
- **BuildingsHelper** - Helpers pour les bâtiments
