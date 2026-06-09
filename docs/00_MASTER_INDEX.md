# TycoonTrends — Index de la documentation

## Navigation rapide

| # | Fichier | Contenu |
|---|---------|---------|
| 01 | [Démarrage rapide](01_NEW_TYCOON_QUICK_START.md) | Lancer le jeu en moins de 2 heures |
| 02 | [Architecture complète](02_COMPLETE_TYCOON_SYSTEM_v1.md) | Structure du code, flux de données, systèmes |
| 03 | [Prompts Claude Code](03_CLAUDE_CODE_PROMPTS.md) | 7 prompts clé-en-main pour étendre le jeu |
| 04 | [Idées d'optimisation](04_OPTIMIZATION_IDEAS.md) | 34 features classées par priorité |
| 05 | [100× moins cher](05_WHY_100X_CHEAPER_AND_NEW_IDEAS.md) | Économies Claude Code + 20 idées bonus |
| 06 | [Maîtriser Claude Code](06_CLAUDE_CODE_MASTERY.md) | Workflows, best practices, astuces |

---

## État du projet

**Nom :** Tycoon Trends  
**Stack :** Roblox Studio + Rojo 7.4.4 + Aftman  
**Langue :** Luau  
**Repo :** `projects/roblox-games/tycoon-trends/`

### Systèmes implémentés (v1)

- [x] Production par tick (buildings → cash)
- [x] Rotation des tendances (×2 sur bâtiments en trend)
- [x] Boutique d'améliorations (UpgradeShop)
- [x] Prestige (reset + multiplicateur permanent)
- [x] Boosts temporaires
- [x] Événements spéciaux
- [x] HUD client (cash, rate, tendances)
- [x] DataStore avec retry (stats + prestige)
- [x] Suite de tests (ZZZ_TestRunner)

### Systèmes à venir (v2+)

- [ ] Interface visuelle des bâtiments en 3D
- [ ] Classement en temps réel (leaderboard)
- [ ] Missions journalières
- [ ] Marché entre joueurs
- [ ] Saisons / rotations thématiques

---

## Structure du code

```
src/
├── server/
│   ├── init.server.luau          — point d'entrée
│   ├── ProductionTicker.server.luau  — boucle cash + tendances
│   ├── UpgradeShop.server.luau   — achat bâtiments
│   ├── PrestigeManager.server.luau   — prestige
│   ├── TemporaryBoosts.server.luau   — boosts
│   ├── EventTrigger.server.luau  — événements
│   ├── Leaderstats.server.luau   — stats Roblox
│   ├── DataStoreStats.server.luau — persistance
│   ├── SessionManager.server.luau — sessions
│   └── ZZZ_TestRunner.server.luau — tests
├── client/
│   ├── init.client.luau
│   ├── FactoryHUD.client.luau    — HUD principal
│   ├── ShopUI.client.luau        — UI boutique
│   ├── BoostUI.client.luau       — UI boosts
│   ├── PrestigeUI.client.luau    — UI prestige
│   └── EventSystem.client.luau   — événements côté client
└── shared/
    ├── GameConfig.luau           — config globale
    ├── GameplayConfig.luau       — config gameplay avancé
    ├── MapConfig.luau            — config carte
    └── Remotes.luau              — RemoteEvents/Functions
```

---

## Commandes utiles

```bash
# Lancer le serveur Rojo (sync VSCode ↔ Studio)
rojo serve

# Voir l'état git
git status
git log --oneline -10
```

---

## Contacts & ressources

- **GitHub :** dim444dim
- **Roblox DevHub :** developer.roblox.com
- **Rojo docs :** rojo.space
