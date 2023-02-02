# Ansible

Installer le rôle Ansible sur la VM / station d'administration :
```bash
python3 -m pip install --user ansible
```

## Construction de l'inventaire

Création d'un fichier d'inventaire dans `~/ansible` : le nom du fichier est ajouté dans `ansible.cfg` (paramètre `inventory`).

Pour éviter d'avoir à préciser la clé ssh nécessaire pour se connecter aux hôtes, son chemin est ajouté dans les variables de l'inventaire (pour tous les hôtes).

## pfSense

Exécuter `ansible-playbook pfsense.yaml`.

## Registry 

```bash
ansible-playbook registry.yaml --tags configure_host
ansible-playbook registry.yaml --tags pull_docker_images
ansible-playbook dnsmasq.yaml --extra-vars "dns_upstream=1.1.1.1"
```

## Monitoring

```bash
ansible-playbook monitoring.yaml --tags install-monitoring-stack --extra-vars "loki_ip=10.50.11.100"
ansible-playbook monitoring.yaml --tags copy-sysfiles --extra-vars "loki_ip=10.50.11.100" 
ansible-playbook monitoring.yaml --tags post-install-server --extra-vars "loki_ip=10.50.11.100"
ansible-playbook configure_monitoring.yaml
```

## Nomad & Consul

On lance dans cet ordre `ansible-playbook consul.yaml` et ensuite `ansible-playbook nomad.yaml`.
On installe docker sur Nomad avec `ansible-playbook nomad.yaml --tags dockerinstall`.

### Lancer les services 

```bash
ansible-playbook start_game.yml --tags start_job_nomad --extra-vars "game_name=traefik"    
ansible-playbook webserver.yaml --extra-vars "source_folder=../res/website" --extra-vars "nomad_server_ip=10.50.12.11"
ansible-playbook freeradius.yaml --extra-vars "source_folder=../res/infra_conf_files/freeradius" --extra-vars "nomad_server_ip=10.50.12.11"
```

### Lancer un serveur de jeu

Lire le fichier [template nomad](../templates/README.md#dossier-templates) pour connaître les prérequis et les options disponibles pour les jeux.

Pour lancer un serveur de jeu, il faut utiliser :
```bash
# <name> est le nom du .nomad dans donk-lan/templates/
ansible-playbook start_game.yml --tags copy_files_nomad --extra-vars "source_folder={}" # arg = donk-lan/res/games_conf_file/<game_name>/
ansible-playbook start_jobs.yml --tags start_job_nomad --extra-vars "game_name=<name>"
```

## Post-install

```bash
ansible-playbook monitoring.yaml --tags install-prometheus-agents-promtail
ansible-playbook monitoring.yaml --tags post-install-agent
```

## (facultatif) Gitea

Pour exécuter un playbook sur le serveur gitea : 
```
ansible-playbook gitea/gitea.yaml
```

Pour déployer le serveur, il faut :
- installer le binaire ;
- configurer le service systemd ;
- configurer le service gitea.

Pour ce faire, on utilise https://github.com/roles-ansible/ansible_role_gitea.

Il suffit de cloner dans `roles/` et renommer le rôle comme on le veut (ici, `gitea`).

Modifications:  
- variabilisation de l'IP d'écoute du serveur gitea ;
- variabilisation du mdp de la base de données (il faudra utiliser Ansible Vault) ;
- personnalisation du logo gitea ;
- ajout de tags et d'un redémarrage du service gitea (pour déclencher seulement un tag : `ansible-playbook gitea.yaml --tags "reload"` par exemple) ;
- ajout d'essais pour l'installation des dépendances de gitea (cloud-init fait une mise à jour des paquets, ce qui empêche Ansible d'installer les siens).

Pour déployer le gitea : faire la post-install (ansible) à la main

## (facultatif) Drone

Une fois le gitea déployé :
- Créer une application OAuth pour récupérer le `gitea_client_id` et le `token`. Bien penser à mettre http://drone.donk.lan/login dans "Redirect URI" sur gitea (cf https://docs.drone.io/server/provider/gitea/)
- installer docker sur la VM drone : 
```bash
pip3 install docker # sur la VM d'admin
ansible-playbook drone.yaml --tags dockerinstall
```

- déployer drone (et penser à ajouter l'entrée DNS associée, pour le moment à la main)
```bash
ansible-playbook drone.yaml --tags deploy
```

- aller sur drone.donk.lan pour finaliser la connexion
- activer le repository sur drone.donk.lan
- Settings :
    - ajouter les secrets nécessaires dans l'onglet Secrets

Pour ajouter une clé SSH pour ansible, utiliser la ligne de commande : 
```bash
 drone secret add --repository donkesport/donk-lan --name ansible_private_key --data @/path/to/key
```

Pour la pipeline ANSIBLE : commenter `ansible_ssh_private_key_file` dans `ansible/inventory.yaml`
