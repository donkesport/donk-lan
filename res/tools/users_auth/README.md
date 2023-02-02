# Donk'LAN - Tools

Le script `generate_users_creds.py` permet de créer les utilisateurs locaux pour les événements du club Donk'esport sur un pare-feu FortiGate ou serveur Freeradius.

## Usage
```
python generate_users_creds.py
```
## Prérequis 
- Exporter le classeur des inscriptions en csv, puis le placer dans le répertoire sous le nom "input.csv"

## Sortie
- Fichier creds.pdf, contient toutes les informations de connexion à communiquer aux joueurs, en version imprimable
- Fichiers nécessaires en fonction du constructeur

## Fortigate 
### Prérequis 
- Avoir créé le groupe d'utilisateurs `joueurs_portail_captif`
- Avoir une connexion en CLI sur le fortigate (en droit admin)
- Avoir activé la sécurité par mode portail captif sur les interfaces nécessaires

### Sorties
- Fichier create.txt, contient toutes les instructions en CLI pour créer les utilisateurs locaux et l'ajouter dans le groupe `joueurs_portail_captif`
- Fichier delete.txt, contient toutes les instructions en CLI pour détruire les utilisateurs locaux créés via le tools


### Utilisation
Pour créer les utilisateurs, copier/coller le contenu du fichier `create.txt` dans l'interface CLI du fortigate.
Pour supprimer les utilsiateurs, copier/coller le contenu du fichier `delete.txt` dans l'interface CLI du fortigate

## Freeradius
### Prérequis
- Inclure le fichier `users.other` dans le fichier `authorize` (voir docs ou template du projet)

### Sorties
- Fichier `users.other` avec les comptes des joueurs

### Utilisation

Pour voir l'utilisation du Freeradius, se référer à la documentation du job Nomad disponible [ici](../../../templates/README.md#freeradius)

## Version
L'outil est toujours en phase de développement par l'équipe de Donk'esport.