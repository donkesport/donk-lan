# Déploiement d'une instance Gitea
===

Afin de faciliter le développement et les tests, un Gitea mirroir du dépôt GitHub est ajouté en interne.

## Terraform

```
terraform apply -var-files="../credentials.tfvars"
ansible-playbook gitea.yaml --tags postinstall # à faire à la main après installation
ansible-playbook drone.yaml --tags deploy # à faire après configuration des secrets 
```
