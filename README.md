# Donk'LAN par Donk'esport

<div align="center">
    <img src="res/logo.png" width="300px"/>
</div>

Repository Git du club Donk'esport pour l'automatisation des LAN organisées par le club.
Il contient les ressources nécessaires pour l'outil nommé "Donk'LAN"

## Structure du repository

 - [`res`](res) contient les ressources graphiques globales ;
 - [`packer`](packer) contient les fichiers de configuration de packer, nécessaire à la construction des templates ;
 - [`terraform`](terraform) contient les fichiers de configuration de terraform, nécessaire au déploiement des VMs ;
 - [`ansible`](ansible) contient les fichiers de configuration d'ansible, nécessaire à la configuration des VMs ;
 - [`templates`](templates) contient les fichiers de configuration pour nomad, nécessaire au déploiement des services sous Docker via Nomad;
 - [`cli`](cli) contient les fichiers de configuration pour utiliser l'outil via la CLI ;
 - [`doc`](doc) contient les documentations pour l'utilisation du projet;

## Prérequis

Installer les utilitaires suivants sur Linux (Ansible non-compatible avec Windows) :
- Télécharger le repo `git clone https://github.com/donkesport/donk-lan/`
- Suivre la procédure de proxmox dans `donk-lan/doc/proxmox.md` 
- Installer le package unzip (`sudo apt install unzip`)
- Installer le package python3 et pip (`sudo apt install python3 pip`) Python3 et pip docs
- Générer une clé SSH appelée `id_ed25519_ansible` (ne pas préciser de mot de passe) : `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_ansible`
- Installer Packer selon la [documentation](https://developer.hashicorp.com/packer/downloads)
- Installer Terraform selon la [documentation](https://developer.hashicorp.com/terraform/downloads)
- Installer Ansible (apt install ansible) selon la [documentation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- Installer les dépendances ansible `ansible-galaxy install -r ./ansible/requirements.yaml`

## Démarrage rapide

Consulter le `cli.md` disponible dans le dossier `donk-lan/doc`. **L'utilisation de la CLI est recommandé.**

## Lancement manuel

Pour débugger certains processus, il est possible de lancer manuellement les tâches. **Il est cependant nécessaire d'utiliser la CLI pour certaines étapes**.

Suivre [les documentations](doc) dans l'ordre, au moins jusqu'à la commande `apply` de la CLI.

### Troubleshooting

Lors du provisionning de la machine de monitoring, il se peut que l'API de Grafana ne réponde pas correctement à cette étape.
 
 ![](https://i.imgur.com/dkKnr1F.png)
 
Il suffira de la relancer en pressant sur la touche R.
