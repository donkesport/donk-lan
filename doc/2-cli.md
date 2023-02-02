# Donk'LAN par Donk'esport

<div align="center">
    <img src="../res/logo.png" width="300px"/>
</div>


## Manuel d'utilisation

Par défaut, l'outil affiche des informations pour comprendre l'utilisation de base :
```bash
python main.py

    ____              __  _  __    ___    _   __   ______            __    
   / __ \____  ____  / /_( )/ /   /   |  / | / /  /_  __/___  ____  / /____
  / / / / __ \/ __ \/ //_/// /   / /| | /  |/ /    / / / __ \/ __ \/ / ___/
 / /_/ / /_/ / / / / ,<   / /___/ ___ |/ /|  /    / / / /_/ / /_/ / (__  ) 
/_____/\____/_/ /_/_/|_| /_____/_/  |_/_/ |_/    /_/  \____/\____/_/____/  
                                                                           

Usage: main.py [OPTIONS] COMMAND [ARGS]...

  CLI for Donk'LAN tools by Donk'esport club !

Options:
  --help  Show this message and exit.

Commands:
  add        Adding game to deploy in Donk'LAN
  apply      Move all generated files in specific directory
  build      Build all files from config.json
  packer     Give informations about packer user
  proxmox    Give informations about proxmox server
  reset      Delete config.json file and all files in generated_files
  run        Execute all commands and create the Donk'Lan environnement
  show       Show all games Donk'LAN can deploy
  terraform  Give informations about terraform user
```

## Configuration pour dialoguer avec le serveur

### Configuration du proxmox

```bash
python main.py proxmox "pve.donk.lan" "pve"
```

### Configuration packer

Fournir les informations de l'utilisateur packer (utilisé pour la création des templates de VMs)
**Attention** : Il faut mettre les informations entre simple quote ('id') car la chaine de caractères contient un `!`.
```bash
python main.py packer 'packer@pve!packer-demo' 'abcdef123456789'
```

### Configuration terraform

Fournir les informations de l'utilisateur terraform (utilisé pour la création des VMs)
**Attention** : Il faut mettre les informations entre simple quote ('id') car la chaine de caractères contient un `!`.
```bash
python main.py terraform 'terraform@pve!terraform-demo' 'abcdef123546789'
```

## Configuration spécifiques

### Voir les jeux supportés par l'outil

```bash
python main.py show
```

### Ajouter des jeux à déployer

```bash
python main.py add GAME_NAME
```

### Générer les fichiers de variables 

```bash
python main.py build
```

### Déplacer les fichiers de configuration dans les sous répertoires

```bash
python main.py apply
```

### Lancer le scripts 

```bash
python main.py run
```
