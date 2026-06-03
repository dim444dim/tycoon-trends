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
   - Notification envoyée au client

4. **UI Update** (EventSystem client)
   - Affiche l'événement en cours
   - Compte à rebours
   - Mise à jour du multiplicateur

## États d'événement

- `IDLE` - Pas d'événement
- `ACTIVE` - Événement en cours
- `ENDING` - Dernier 30s

## Réseau

Les changements d'état sont synchronisés via RemoteEvents et RemoteFunctions.
