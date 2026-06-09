# Prompts Claude Code — TycoonTrends

7 prompts clé-en-main pour étendre le jeu avec Claude Code.  
Chaque prompt est prêt à coller dans le chat.

---

## Prompt 1 — Ajouter un nouveau bâtiment

```
Dans le projet TycoonTrends (Roblox/Luau), ajoute un nouveau bâtiment.

Fichiers à modifier :
- src/shared/GameplayConfig.luau
  → Section Buildings : ajoute { id="datacenter", name="Data Center", cost=50000, rate=500, level=5 }
  → Section BuildingCosts : ajoute datacenter = { baseCost=50000, costGrowth=1.15 }

Règles :
- Ne touche pas aux autres bâtiments existants
- Respecte le format exactement (virgules, accolades)
- Pas de commentaires inutiles
```

---

## Prompt 2 — Nouvelle RemoteEvent

```
Dans TycoonTrends (Roblox/Luau), ajoute une nouvelle RemoteEvent "DailyReward".

Fichiers à modifier :
- src/shared/Remotes.luau
  → Ajoute DailyReward dans la liste des events (même pattern que les existants)
- src/server/[NouveauFichier].server.luau
  → Crée un nouveau script qui écoute DailyReward.OnServerEvent
  → Donne 500 cash au joueur qui la déclenche (une fois par jour, persisté en DataStore)
- src/client/[NouveauFichier].client.luau
  → Bouton UI simple qui fire DailyReward au serveur

Conventions du projet :
- print("[NomModule] message") pour les logs
- Retry DataStore : GameplayConfig.DataStoreRetryCount / DataStoreRetryDelay
- task.spawn pour les opérations async
```

---

## Prompt 3 — Améliorer le HUD

```
Dans TycoonTrends (Roblox/Luau), améliore src/client/FactoryHUD.client.luau.

Objectif : afficher le multiplicateur de prestige actuel.

Actuellement le script reçoit via UpdateHUD : { cash, rate, sessionEarned, trends }
Le joueur a un Attribute "prestige_multiplier" (number).

Modification :
- Lire player:GetAttribute("prestige_multiplier") au chargement et quand PrestigeReset reçoit success=true
- Afficher "×{multiplier}" dans un TextLabel dédié sur le HUD
- Format : "×1.25" (2 décimales max, supprimer les zéros inutiles)

Ne pas modifier les autres éléments du HUD.
```

---

## Prompt 4 — Système de missions

```
Crée un système de missions journalières pour TycoonTrends (Roblox/Luau).

Architecture souhaitée :
- src/shared/MissionsConfig.luau : liste de 5 missions (earn_cash, buy_buildings, prestige, etc.)
- src/server/MissionsManager.server.luau :
  → Assigne 3 missions aléatoires par joueur par jour
  → Suit la progression via Attributes
  → Récompense : cash bonus ou boost temporaire
  → Persiste l'état dans DataStore "TycoonTrendsMissions_v1"
- src/client/MissionsUI.client.luau : affiche les 3 missions actives + progression
- src/shared/Remotes.luau : ajoute GetMissions, CompleteMission

Conventions :
- Même pattern retry DataStore que PrestigeManager.server.luau
- Format logs : [MissionsManager]
- Réinitialisation à minuit UTC (os.time() % 86400 == 0)
```

---

## Prompt 5 — Leaderboard en temps réel

```
Dans TycoonTrends (Roblox/Luau), crée un leaderboard en temps réel visible dans le jeu.

Fichiers à créer/modifier :
- src/server/Leaderboard.server.luau :
  → Collecte le Cash de tous les joueurs toutes les 5 secondes
  → Trie et envoie le top 10 à tous les clients via RemoteEvent "LeaderboardUpdate"
- src/client/LeaderboardUI.client.luau :
  → Frame UI sur le côté droit de l'écran
  → Affiche rang, nom, cash formaté (1000 → "1K", 1000000 → "1M")
  → Se met à jour à chaque "LeaderboardUpdate"
- src/shared/Remotes.luau : ajoute LeaderboardUpdate

Pas de DataStore pour le leaderboard (mémoire session uniquement).
```

---

## Prompt 6 — Rééquilibrage de l'économie

```
Analyse et rééquilibre l'économie de TycoonTrends.

Fichiers à analyser puis modifier :
- src/shared/GameplayConfig.luau (Buildings, coûts, taux)
- src/shared/GameConfig.luau (PrestigeThresholds, StartingCash)

Objectif : un joueur nouveau doit pouvoir atteindre le prestige 1 en ~30 minutes de jeu actif.

Calcul attendu (à inclure en commentaire) :
  Temps pour prestige 1 = 100 000 cash requis
  Avec HQ seul (75 rate × 10 cash = 750/s)
  → 100 000 / 750 = ~133 secondes sans prestige
  → Trop court ! Ajuster en conséquence.

Propose des valeurs ajustées et explique le raisonnement.
```

---

## Prompt 7 — Sauvegarde et migration DataStore

```
Dans TycoonTrends (Roblox/Luau), améliore la gestion DataStore.

Contexte : DataStoreStats_v1 existe déjà. On veut passer en v2 avec un nouveau champ.

Fichiers à modifier :
- src/shared/GameplayConfig.luau : DataStoreName = "TycoonTrendsStats_v2"
- src/server/DataStoreStats.server.luau :
  → Ajouter un champ "TotalPlaytime" (secondes) dans les données sauvegardées
  → Lors du chargement : si les données viennent de v1 (pas de TotalPlaytime), initialiser à 0
  → Incrémenter TotalPlaytime toutes les 60 secondes via task.spawn

Migration :
  Tenter de lire v1 si v2 est vide → copier les données → écrire en v2
  Ne pas supprimer v1 (garde la sauvegarde)

Même pattern retry que le reste du projet.
```

---

## Conseils d'utilisation

- **Contexte :** Toujours mentionner "TycoonTrends (Roblox/Luau)" pour que Claude comprenne la stack
- **Fichiers :** Citer les chemins exacts (`src/server/X.server.luau`)
- **Conventions :** Rappeler les patterns du projet (logs, retry DataStore, task.spawn)
- **Atomicité :** Un prompt = un système. Ne pas tout mélanger.
- **Validation :** Après chaque prompt, relancer les tests (`ZZZ_TestRunner`)
