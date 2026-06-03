# Installation et configuration

## Prérequis

- Roblox Studio (dernière version)
- Node.js v24+
- Rojo 7.x
- Git

## Étapes

### 1. Cloner le repo
```bash
git clone https://github.com/dim444dim/tycoon-trends.git
cd tycoon-trends
```

### 2. Ouvrir dans Roblox Studio
- Lancez Roblox Studio
- Ouvrez le fichier `.rbxl`

### 3. Installer Rojo
```bash
npm install -g rojo
```

### 4. Lancer le serveur Rojo
```bash
rojo serve
```

### 5. Connecter dans Studio
- Dans Studio, allez dans Plugins
- Rojo > Connect
- La synchronisation se fera automatiquement

## Structure du fichier de place

Pour que Rojo fonctionne, assurez-vous que votre fichier `.rbxl` contient :
- Un dossier `ServerScriptService`
- Un dossier `StarterPlayer`
- Un dossier `ReplicatedStorage` ou similaire

## Troubleshooting

Si la synchronisation ne fonctionne pas :
1. Vérifiez que le serveur Rojo est lancé
2. Vérifiez la connexion dans Studio (Plugins > Rojo)
3. Vérifiez les chemins dans la configuration Rojo
