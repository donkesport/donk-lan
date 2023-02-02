# Donk'LAN par Donk'esport

<div align="center">
    <img src="/res/logo.png" width="300px"/>
</div>

## Packer

### Structure du sous dossier terraform

 - [`ubuntu-nomad-server`](../terraform/ubuntu-nomad-server) contient les fichiers terraform (tf) pour déployer la VM server & clients de nomad ;
 - [`ubuntu-consul-server`](../terraform/ubuntu-consul-server) contient les fichiers terraform (tf) pour déployer la VM server de consul ;
 - [`ci`](../terraform/ci) contient les fichiers terraform (tf) pour déployer la CI/CD pour un environnement de dev : drone + gitea ;
 - [`firewall`](../terraform/firewall) contient les fichiers terraform (tf) pour déployer la VM pare-feu sous pfsense ;
 - [`monitoring`](../terraform/monitoring) contient les fichiers terraform (tf) pour déployer la VM server de consul ;
 - cli-file-credentials.tfvars (généré via la cli) contient les variables nécessaires pour le fonctionnement de packer ;

### Initier terraform

Permet de télécharger les dépendances nécessaires (telmate) pour le provider Proxmox
```bash
cd ubuntu-nomad-server
terraform init
```

### Vérification de la configuration

```bash
cd ubuntu-nomad-server
terraform plan -var-file='../cli-file-credentials.pkr.hcl' 
```

### Lancement du build 

```bash
cd ubuntu-nomad-server
terraform apply -var-file='../cli-file-credentials.pkr.hcl' 
```

Pour déployer toute l'infrastructure du Donk'LAN, réaliser toutes les actions pour chacun des dossiers en suivant cet ordre : 
 - firewall
 - registry
 - monitoring
 - ubuntu-consul-server
 - ubuntu-nomad-server

Pour chaque étape, il faudra appliquer le playbook ansible avant de passer au suivant : se référer au README dans le dossier `ansible`, à la racine du projet.

### Troubleshooting

Par défaut, Terraform va considérer que la machine a fini d'être créée quand elle pourra répondre au `ping`. 
Nous avons donc ajouté la section suivante pour attendre que tous les téléchargements de cloud-init soient terminés avant d'appliquer les playbook ansible.

```conf
    provisioner "remote-exec" {
        inline = ["cloud-init status --wait"] # wait until apt lock is available
    }
``` 
