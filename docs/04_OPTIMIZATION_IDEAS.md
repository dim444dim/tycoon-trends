# 34 idées d'optimisation — TycoonTrends

Classées par priorité : 🔴 Haute / 🟡 Moyenne / 🟢 Basse

---

## 🔴 Priorité haute (impact joueur immédiat)

### 1. Sauvegarde automatique toutes les 60s
Actuellement la sauvegarde se fait uniquement à la déconnexion.  
Risque de perte de données si le serveur crash.  
**Fix :** `task.spawn` avec boucle `task.wait(60)` dans DataStoreStats.

### 2. Formatage du cash en HUD
Afficher `1 234 567` au lieu de `1234567`.  
**Fix :** fonction `formatCash(n)` dans un module utilitaire partagé.

### 3. Animation du cash qui monte
Tweening visuel quand le cash augmente (LerpNumber sur 0.5s).  
Rend le jeu bien plus satisfaisant.

### 4. Indicateur visuel des tendances
Les 2 bâtiments en tendance devraient être mis en évidence dans la ShopUI (badge "🔥 TREND" ou couleur dorée).  
Actuellement pas différenciés visuellement.

### 5. Confirmation avant prestige
Ajouter un popup "Es-tu sûr ? Tu perds tous tes bâtiments et ton cash." avant le reset.  
Évite les clics accidentels.

### 6. Feedback achat réussi / échec
Son + animation quand on achète un bâtiment (ou message d'erreur si pas assez de cash).

### 7. DataStore version guard
Si DataStoreName change (v1→v2), migrer automatiquement les anciennes données plutôt que repartir de zéro.

---

## 🔴 Priorité haute (stabilité / bugs potentiels)

### 8. Rate limiting sur BuyBuilding
Un joueur malveillant pourrait spammer la RemoteEvent.  
**Fix :** cooldown de 0.1s par joueur dans UpgradeShop.

### 9. Validation serveur du coût
Actuellement le serveur calcule le coût → sécurisé.  
Vérifier qu'aucun client ne peut tricher en envoyant un coût différent.

### 10. Protection contre le cash négatif
Si un bug fait descendre Cash < 0, bloquer à 0.  
**Fix :** `math.max(0, newCash)` dans ProductionTicker et UpgradeShop.

### 11. Gestion joueur déjà en session
Si un joueur rejoint mid-session, s'assurer que SessionManager l'initialise correctement.

### 12. Cleanup PlayerRemoving complet
Vérifier que tous les scripts (TemporaryBoosts, EventTrigger) nettoient leurs tables locales quand un joueur quitte.

---

## 🟡 Priorité moyenne (contenu + rétention)

### 13. Missions journalières
3 missions aléatoires par jour.  
Exemples : "Gagne 10 000 cash", "Achète 5 bâtiments", "Effectue un prestige".  
Récompense : boost 2h ou cash bonus.

### 14. Succès / trophées
Succès permanents débloqués par jalons.  
Exemples : "Premier million", "10 prestiges", "Jouer 7 jours d'affilée".  
Affichage sur le profil du joueur.

### 15. Leaderboard sessions
Top 10 des joueurs de la session actuelle (cash + taux de production).  
Refresh toutes les 5 secondes.

### 16. Boutique de boosts
Interface dédiée pour acheter des boosts temporaires avec du cash (ou Robux).  
Durées : 15min, 1h, 4h.

### 17. Événements planifiés
Calendrier d'événements (weekend double-gains, flash sales).  
Configurable dans GameplayConfig sans code.

### 18. Notifications push in-game
Popup discret quand une tendance change.  
"🔥 Nouvelle tendance : Usine ×2 pendant 2 min !"

### 19. Tutoriel interactif
Guide les nouveaux joueurs en 3 étapes (acheter un bâtiment, voir la production, regarder les tendances).  
Affiché une seule fois (flag dans DataStore).

### 20. Historique des gains
Graphique simple (barres) des gains des 10 dernières sessions.  
Stocké localement (pas DataStore).

---

## 🟡 Priorité moyenne (progression + économie)

### 21. Bâtiment niveau 5
Ajouter "Data Center" (cost=50 000, rate=500) pour les joueurs avancés.  
Objectif à long terme après prestige.

### 22. Amélioration de bâtiment (upgrade)
En plus d'acheter plusieurs exemplaires, permettre d'améliorer un bâtiment (×1.5 rate, coût ×3).  
Stocké comme `"workshop:3:2"` (3 exemplaires, niveau 2).

### 23. Combo de tendances
Si un joueur possède les 2 bâtiments en tendance simultanément, bonus combo ×1.5 supplémentaire.

### 24. Prestige tier 5
Ajouter un 5ème palier de prestige (50M cash → ×3.0).  
Déjà prévu dans l'architecture (juste ajouter aux tableaux).

### 25. Cash offline
Calculer les gains pendant que le joueur était hors-ligne (plafonné à 4h).  
Afficher un popup au retour.

---

## 🟢 Priorité basse (polish + longévité)

### 26. Thèmes saisonniers
Noël, Halloween, été : remplacer les couleurs `GameConfig.CouleurPrimaire` automatiquement selon la date.

### 27. Mode spectateur
Les joueurs qui ont terminé leur session peuvent regarder les autres jouer.

### 28. Chat de guilde
3-5 joueurs forment une guilde.  
Bonus de production partagé (+5% si tous les membres sont connectés).

### 29. Marché de troc
Les joueurs peuvent échanger des bâtiments entre eux.  
RemoteEvent sécurisée avec validation des deux côtés.

### 30. Replay de session
Enregistrer les principaux événements d'une session (achats, tendances) pour un récap en fin de partie.

### 31. Accessibilité
Option daltonisme (remplacer les couleurs par des icônes dans les tendances).

### 32. Mode mobile
Vérifier que toute l'UI est utilisable sur mobile (boutons ≥ 44px, pas de hover).

### 33. Statistiques détaillées
Page de stats : total cash gagné toutes sessions, bâtiment préféré, nombre de tendances surfées.  
Persisté en DataStore.

### 34. Export / partage de score
Générer une image de score partageable (via ImageLabel avec DrawingAPI Roblox ou équivalent).

---

## Implémentation recommandée

**Sprint 1 (cette semaine) :** #1, #2, #3, #4, #5, #8, #10  
**Sprint 2 :** #13 (missions), #15 (leaderboard), #18 (notifications)  
**Sprint 3 :** #21 (bâtiment 5), #25 (cash offline), #26 (thèmes)
