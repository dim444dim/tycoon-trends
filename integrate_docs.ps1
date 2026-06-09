# Script: integrate_docs.ps1
# Crée le dossier docs/ et les 7 fichiers de documentation

$projectPath = Get-Location
$docsPath = Join-Path $projectPath "docs"

Write-Host "🚀 Intégration de la documentation..." -ForegroundColor Cyan

# 1. Créer le dossier docs/
if (-not (Test-Path $docsPath)) {
    New-Item -ItemType Directory -Path $docsPath | Out-Null
    Write-Host "✅ Dossier docs/ créé" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Dossier docs/ existe déjà" -ForegroundColor Yellow
}

# 2. Créer les 7 fichiers de documentation

$docs = @{
    "README.md" = @"
# TycoonTrends

Un jeu Roblox tycoon où vous gérez une usine et monétisez des événements Twitch/TikTok.

## Démarrage rapide

1. Ouvrez le fichier `.rbxl` dans Roblox Studio
2. Vérifiez que le plugin Rojo est installé
3. Lancez `rojo serve` depuis le terminal
4. Jouez et testez les systèmes d'événements

## Structure du projet

- `src/client/` - Code client (UI, visualisations)
- `src/server/` - Code serveur (logique de jeu, événements)
- `src/shared/` - Code partagé (configuration, helpers)

## Documentation

- [Architecture](./ARCHITECTURE.md)
- [Système d'événements](./EVENTS_SYSTEM.md)
- [Guide de configuration](./CONFIG_GUIDE.md)
"@

    "ARCHITECTURE.md" = @"
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
"@

    "EVENTS_SYSTEM.md" = @"
# Système d'événements

## Événements disponibles

### 1. Twitch Raid 🎤
- **Multiplicateur** : 1.5x
- **Durée** : 3600s (1h)
- **Couleur** : Violet (145, 70, 255)

### 2. Rapper Drop 🎵
- **Multiplicateur** : 2.0x
- **Durée** : 1800s (30min)
- **Couleur** : Orange (255, 100, 50)

### 3. TikTok Trend 📱
- **Multiplicateur** : 1.3x
- **Durée** : 900s (15min)
- **Couleur** : Cyan (0, 200, 200)

## Configuration

Les événements sont définis dans `EventConfig.luau` :

```lua
EventConfig.Events.twitch_raid.multiplier = 1.5
EventConfig.Events.rapper_drop.duration = 1800
```

## Utilisation

- Serveur : `EventConfig.Events[eventId]`
- Client : `EventConfig.getAll()`
"@

    "CONFIG_GUIDE.md" = @"
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
    -- ...
}
```

## Modification des événements

1. Ouvrez `src/shared/Config/EventConfig.luau`
2. Modifiez les propriétés (multiplicateur, durée, couleur)
3. Sauvegardez et reloadez le jeu
"@

    "GAMEPLAY_LOOP.md" = @"
# Boucle de gameplay

## Flux principal

1. **Initialisation** (PlayerInitializer)
   - Charge les données du joueur
   - Initialise les bâtiments

2. **Production** (Boucle principale)
   - Les bâtiments produisent de l'argent
   - Multiplicateur appliqué si événement actif

3. **Événements** (EventTrigger)
   - Événement déclenché aléatoirement
   - Multiplicateur appliqué pendant la durée

4. **UI Update** (EventSystem client)
   - Affiche l'événement en cours
   - Compte à rebours

## États d'événement

- `IDLE` - Pas d'événement
- `ACTIVE` - Événement en cours
- `ENDING` - Dernier 30s
"@

    "API_REFERENCE.md" = @"
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

## UIConstants

Constantes pour l'interface utilisateur (à implémenter).
"@

    "INSTALLATION.md" = @"
# Installation et configuration

## Prérequis

- Roblox Studio (dernière version)
- Node.js v24+
- Rojo 7.x
- Git

## Étapes

### 1. Cloner le repo
\`\`\`bash
git clone https://github.com/dim444dim/tycoon-trends.git
cd tycoon-trends
\`\`\`

### 2. Ouvrir dans Roblox Studio
- Lancez Roblox Studio
- Ouvrez le fichier `.rbxl`

### 3. Installer Rojo
\`\`\`bash
npm install -g rojo
\`\`\`

### 4. Lancer le serveur Rojo
\`\`\`bash
rojo serve
\`\`\`

### 5. Connecter dans Studio
- Dans Studio, allez dans Plugins
- Rojo > Connect
"@
}

# Créer les 7 fichiers
$count = 0
foreach ($fileName in $docs.Keys) {
    $filePath = Join-Path $docsPath $fileName
    $docs[$fileName] | Out-File -FilePath $filePath -Encoding UTF8
    $count++
    Write-Host "✅ $fileName créé" -ForegroundColor Green
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✨ $count fichiers de documentation créés dans docs/" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Proposer git commit + push
$response = Read-Host "Veux-tu faire git commit + push ? (o/n)"

if ($response -eq "o") {
    Write-Host "📦 Commit en cours..." -ForegroundColor Cyan
    git add docs/
    git commit -m "docs: Add 7 documentation files (README, ARCHITECTURE, EVENTS_SYSTEM, CONFIG_GUIDE, GAMEPLAY_LOOP, API_REFERENCE, INSTALLATION)"

    if ($?) {
        Write-Host "✅ Commit créé" -ForegroundColor Green

        $push = Read-Host "Pusher vers GitHub ? (o/n)"
        if ($push -eq "o") {
            Write-Host "🚀 Push en cours..." -ForegroundColor Cyan
            git push origin master
            Write-Host "✅ Pushé avec succès !" -ForegroundColor Green
        }
    }
} else {
    Write-Host "ℹ️  Commit annulé. Tu peux faire git commit quand tu es prêt." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✨ Intégration terminée ! Merci d'avoir utilisé integrate_docs.ps1" -ForegroundColor Cyan
