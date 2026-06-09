# Démarrage rapide — Tycoon Trends en 2 heures

## Prérequis

| Outil | Version | Vérification |
|-------|---------|-------------|
| Roblox Studio | dernière | `roblox-studio --version` |
| Rojo | 7.4.4 | `rojo --version` |
| Aftman | installé | `aftman --version` |
| VS Code | dernière | — |

---

## Étape 1 — Cloner et préparer (5 min)

```bash
cd C:\Users\Admin\projects\roblox-games
git clone <repo> tycoon-trends
cd tycoon-trends
aftman install   # installe Rojo depuis aftman.toml
```

---

## Étape 2 — Ouvrir le projet dans Studio (5 min)

1. Ouvrir **Roblox Studio**
2. Ouvrir le fichier `tycoon-trends.rbxlx`
3. Dans le terminal VS Code, lancer :
   ```bash
   rojo serve
   ```
4. Dans Studio → Plugin Rojo → **Connect** → `localhost:34872`

La sync est active : toute modification dans `src/` se reflète instantanément dans Studio.

---

## Étape 3 — Comprendre la config (10 min)

### `src/shared/GameConfig.luau` — paramètres globaux

```lua
StartingCash    = 100       -- cash de départ
SessionDuration = 600       -- durée d'une session (10 min)
PrestigeThresholds = { 100000, 500000, 2500000, 10000000 }
PrestigeBonus      = { 1.1,    1.25,   1.5,     2.0      }
```

### `src/shared/GameplayConfig.luau` — gameplay avancé

```lua
TickInterval = 1            -- secondes entre chaque tick
CashPerUnit  = 10           -- argent par unité produite

Buildings = {
  { id="workshop",  cost=100,  rate=1  },
  { id="factory",   cost=500,  rate=5  },
  { id="megaplant", cost=2000, rate=20 },
  { id="hq",        cost=8000, rate=75 },
}

TrendCount           = 2    -- bâtiments en tendance simultanément
TrendBonusMultiplier = 2.0  -- bonus ×2
TrendDuration        = 120  -- rotation toutes les 2 min
```

---

## Étape 4 — Tester le jeu (10 min)

1. Dans Studio → **Play** (bouton vert)
2. Ouvrir la **Output window** (View → Output)
3. Vérifier les logs :
   ```
   [TycoonTrends] Server init
   [ProductionTicker] init
   [ProductionTicker] Nouvelles tendances : workshop, factory
   [PrestigeManager] loaded
   ```
4. Le HUD doit afficher cash + taux de production

---

## Étape 5 — Lancer les tests (5 min)

Le `ZZZ_TestRunner.server.luau` s'exécute automatiquement au démarrage du serveur.

Dans la console Studio, chercher :
```
[TestRunner] ✅ PASS : ...
[TestRunner] 4/4 tests passed
```

---

## Personnalisation rapide

### Changer les couleurs du jeu

Dans `GameConfig.luau` :
```lua
CouleurPrimaire   = Color3.fromRGB(255, 80, 120)   -- rose vif → ta couleur
CouleurSecondaire = Color3.fromRGB(80, 200, 255)    -- bleu → ta couleur
```

### Ajouter un bâtiment

Dans `GameplayConfig.luau`, section `Buildings` :
```lua
{ id = "megacorp", name = "MégaCorp", cost = 30000, rate = 250, level = 5 },
```
Et dans `BuildingCosts` :
```lua
megacorp = { baseCost = 30000, costGrowth = 1.15 },
```

### Modifier la durée des tendances

```lua
TrendDuration = 60  -- rotation toutes les 60 secondes
```

---

## Flux de données simplifié

```
Joueur rejoint
    → DataStoreStats charge cash/bâtiments
    → PrestigeManager charge multiplicateur
    ↓
Chaque seconde (TickInterval)
    → ProductionTicker calcule : rate × CashPerUnit × boosts × prestige × event
    → Cash mis à jour via Attribute
    → UpdateHUD envoyé au client
    ↓
Achat bâtiment (UpgradeShop)
    → Déduit le coût (coût exponentiel ×1.15)
    → Modifie l'Attribute "Buildings" : "workshop:3,factory:1"
    ↓
Joueur quitte
    → DataStore sauvegarde stats + prestige
```

---

## Problèmes courants

| Problème | Cause | Solution |
|----------|-------|---------|
| Rojo ne connecte pas | Studio fermé ou port occupé | Redémarrer Studio puis `rojo serve` |
| Cash ne monte pas | State ≠ "ACTIVE" | Vérifier SessionManager dans Output |
| DataStore error | Studio hors-ligne | Activer "Enable Studio Access" dans les paramètres du jeu |
| Tests échouent | Mauvais import | Vérifier `require(ReplicatedStorage.Shared.X)` |

---

## Prochaines étapes

→ Lire [02_COMPLETE_TYCOON_SYSTEM_v1.md](02_COMPLETE_TYCOON_SYSTEM_v1.md) pour l'architecture complète  
→ Lire [03_CLAUDE_CODE_PROMPTS.md](03_CLAUDE_CODE_PROMPTS.md) pour étendre le jeu rapidement
