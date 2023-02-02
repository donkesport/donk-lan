# Donk'LAN par Donk'esport

<div align="center">
    <img src="/res/logo.png" width="300px"/>
</div>

## Packer

### Structure du sous dossier packer

 - [`ubuntu-server-jammy`](../packer/ubuntu-server-jammy) contient les fichiers packer (hcl) et les fichiers cloud-init (http et files) pour le template Ubuntu;
 - [`pfsense`](../packer/pfsense) contient les fichiers packer (hcl) pour le template pfSense. ;
 - cli-file-credentials.pkr.hcl (généré via la cli) contient les variables nécessaires pour le fonctionnement de packer ;

### Vérification de la configuration

```bash
$ packer validate -var-file='./credentials.pkr.hcl' ./ubuntu-server-jammy/
The configuration is valid.
```

### Lancement du build 

```bash
$ packer build -var-file='./credentials.pkr.hcl' ./ubuntu-server-jammy
```

Note : répéter les mêmes actions pour `pfsense`
