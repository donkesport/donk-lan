Pour utiliser le compte donkesport pour ansible via clé :
- ajouter la clé public dans /home/donkesport/.ssh/authorized_keys
- ajouter le compte dans le groupe wheel
- installer sudo (nécessite Internet)
- configurer sudo (pas besoin de mdp pour les commandes sudo pour le groupe wheel)

Pour avoir accès à internet, 
- activer le DHCP au niveau du forti
- piste : pour avoir une IP fixe : forcer via @mac => Comment si via packer ?
=> modifier l'interface WAN en fixant une mac statique )> dépressié

