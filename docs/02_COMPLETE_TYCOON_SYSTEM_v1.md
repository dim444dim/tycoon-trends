# Architecture complète — TycoonTrends v1

## Vue d'ensemble

TycoonTrends est un jeu Roblox de type "tycoon idle" avec un mécanisme de **tendances** (trends) qui booste ×2 certains bâtiments de façon rotative. L'architecture suit le modèle client-serveur Roblox standard, organisé via Rojo.

---

## Systèmes serveur

### 1. SessionManager

**Fichier :** `src/server/SessionManager.server.luau`

Gère le cycle de vie d'une session de jeu :
- État machine : `WAITING → ACTIVE → ENDED`
- Stocké dans `ReplicatedStorage.GameState` via Attributes
- Contrôle si la production est active (`State == "ACTIVE"`)

### 2. ProductionTicker

**Fichier :** `src/server/ProductionTicker.server.luau`

Cœur du jeu. Deux boucles `task.spawn` indépendantes :

**Boucle tendances** (toutes les `TrendDuration` secondes) :
```
rotateTrends()
  → choisit TrendCount bâtiments aléatoires
  → stocke dans activeTrends{}
  → FireAllClients(TrendChanged, activeTrends)
```

**Boucle production** (toutes les `TickInterval` secondes) :
```
pour chaque joueur actif :
  lit Attribute "Buildings" → "workshop:3,factory:1"
  calcule totalRate = Σ(rate × count × trendMult)
  calcule earned = totalRate × CashPerUnit × boostMult × prestigeMult × eventMult
  met à jour Attribute "Cash"
  FireClient(UpdateHUD, { cash, rate, sessionEarned, trends })
```

**Multiplicateurs de gains :**
| Attribute | Source | Valeur par défaut |
|-----------|--------|------------------|
| `BoostMultiplier` | TemporaryBoosts | 1.0 |
| `prestige_multiplier` | PrestigeManager | 1.0 |
| `EventMultiplier` | EventTrigger | 1.0 |

### 3. UpgradeShop

**Fichier :** `src/server/UpgradeShop.server.luau`

Gère l'achat et la vente de bâtiments :
- Coûts exponentiels : `baseCost × costGrowth^(déjà possédé)`
- Ex : 1er atelier = 100$, 2ème = 115$, 3ème = 132$
- Format Attribute Buildings : `"workshop:3,factory:1"`
- Expose `GetShopData` (RemoteFunction) → liste des bâtiments

### 4. PrestigeManager

**Fichier :** `src/server/PrestigeManager.server.luau`

Système de prestige avec DataStore dédié `TycoonTrendsPrestige_v1` :

```
Seuils cash → tier prestige :
  100 000$ → tier 1 → ×1.1
  500 000$ → tier 2 → ×1.25
  2 500 000$ → tier 3 → ×1.5
  10 000 000$ → tier 4 → ×2.0
```

Au prestige : reset Buildings + Cash = 0, multiplicateur permanent.

### 5. TemporaryBoosts

**Fichier :** `src/server/TemporaryBoosts.server.luau`

Boosts à durée limitée (achats in-game ou événements) :
- Modifie `Attribute("BoostMultiplier")` pendant N secondes
- Revient à 1.0 automatiquement

### 6. EventTrigger

**Fichier :** `src/server/EventTrigger.server.luau`

Déclenche des événements spéciaux (rush hour, soldes, etc.) :
- Modifie `Attribute("EventMultiplier")` pendant la durée de l'événement
- Notifie tous les clients via RemoteEvent

### 7. DataStoreStats

**Fichier :** `src/server/DataStoreStats.server.luau`

Persistance des stats principales (`TycoonTrendsStats_v1`) :
- Sauvegarde : Cash, Buildings, SessionEarned
- Retry automatique (3 tentatives, 1.5s délai)
- Fallback RAM si DataStore indisponible

### 8. Leaderstats

**Fichier :** `src/server/Leaderstats.server.luau`

Crée le leaderboard Roblox natif (affiché en haut à droite) :
- Cash affiché en direct depuis l'Attribute

---

## Systèmes client

### 1. FactoryHUD

**Fichier :** `src/client/FactoryHUD.client.luau`

HUD principal affiché à l'écran :
- Cash actuel
- Taux de production (unités/s)
- Gains de session
- Indicateur des tendances actives

Reçoit les mises à jour via `UpdateHUD` RemoteEvent.

### 2. ShopUI

**Fichier :** `src/client/ShopUI.client.luau`

Interface d'achat des bâtiments :
- Récupère la liste via `GetShopData` (RemoteFunction)
- Affiche le coût actuel (exponentiellement calculé)
- Envoie `BuyBuilding` / `SellBuilding` au serveur

### 3. BoostUI

**Fichier :** `src/client/BoostUI.client.luau`

Interface des boosts temporaires :
- Affiche les boosts disponibles
- Timer visuel pendant un boost actif

### 4. PrestigeUI

**Fichier :** `src/client/PrestigeUI.client.luau`

Interface de prestige :
- Affiche le tier disponible selon le cash
- Bouton de confirmation (reset irréversible)
- Affiche le multiplicateur actuel et le suivant

### 5. EventSystem (client)

**Fichier :** `src/client/EventSystem.client.luau`

Reçoit les notifications d'événements serveur :
- Affiche les popups d'événements
- Mise à jour visuelle du multiplicateur

---

## Shared (partagé client+serveur)

### GameConfig.luau

Paramètres globaux du jeu. **À modifier pour personnaliser le tycoon.**

### GameplayConfig.luau

Constantes gameplay : bâtiments, tendances, DataStore, coûts. **Source de vérité pour l'équilibrage.**

### MapConfig.luau

Configuration de la carte (couleurs, matériaux, layout).

### Remotes.luau

Centralise tous les RemoteEvents et RemoteFunctions :

| Nom | Type | Sens | Usage |
|-----|------|------|-------|
| `UpdateHUD` | Event | S→C | Mise à jour cash/rate/tendances |
| `TrendChanged` | Event | S→C | Nouvelles tendances actives |
| `BuyBuilding` | Event | C→S | Achat d'un bâtiment |
| `SellBuilding` | Event | C→S | Vente d'un bâtiment |
| `PrestigeReset` | Event | C↔S | Demande + confirmation prestige |
| `GetShopData` | Function | C→S | Liste des bâtiments disponibles |
| `ActivateBoost` | Event | C→S | Activation d'un boost |

---

## Flux de données complet

```
┌─────────────────────────────────────────────────────────────┐
│                         SERVEUR                              │
│                                                             │
│  SessionManager                                             │
│       ↓ State = "ACTIVE"                                    │
│  ProductionTicker ─────────────────────────────────────┐   │
│       ↑ reads                    ↑ reads               │   │
│  [Player.Attributes]         [activeTrends]            │   │
│  Cash, Buildings,            PrestigeManager           │   │
│  BoostMult, EventMult,       TemporaryBoosts           │   │
│  prestige_mult               EventTrigger              │   │
│                                                        │   │
│  UpgradeShop → modifie Buildings                       │   │
│  DataStoreStats → persiste Cash/Buildings              │   │
│  PrestigeManager → persiste multiplicateur             │   │
└────────────────────────────────────────────────────────┼───┘
                    RemoteEvents/Functions                │
┌────────────────────────────────────────────────────────┼───┐
│                         CLIENT                         │   │
│                                                        │   │
│  FactoryHUD ←──────────── UpdateHUD ──────────────────┘   │
│  EventSystem ←─────────── TrendChanged                     │
│  ShopUI ──────────────→ BuyBuilding/SellBuilding           │
│  PrestigeUI ──────────→ PrestigeReset                      │
│  BoostUI ─────────────→ ActivateBoost                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Conventions de code

- `print("[NomModule] message")` → logs identifiés par module
- `warn("[NomModule] message")` → erreurs non fatales
- Retry pattern DataStore : 3 tentatives, 1.5s délai
- Fallback RAM si DataStore indisponible
- `task.spawn` pour boucles indépendantes (pas de yield blocking)
- Attributes sur Player pour partager l'état entre scripts

---

## Tests

**Fichier :** `src/server/ZZZ_TestRunner.server.luau`

S'exécute automatiquement en dernier (préfixe `ZZZ_`).  
4 tests couvrent les modules core. Résultat dans Output Studio :
```
[TestRunner] 4/4 tests passed
```
