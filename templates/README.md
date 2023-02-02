# Dossier Templates

Dans ce dossier se trouvent les fichiers nomad utilisés pour créer les jobs sur le serveur Nomad. 
Chaque jeu ou service possède son fichier nomad qui peut être personnalisé en fonction des besoins.

Il est nécessaire de **copier les fichiers de configuration pour les jeux** Teeworlds et Minecraft.

- [Copie des fichiers de configuration](#copie-des-fichiers-de-configuration)
- [CSGO](#csgo)
- [Minecraft](#minecraft)
  * [Game settings](#game-settings)
- [Teeworlds](#teeworlds)
  * [Engine settings](#engine-settings)
  * [Game settings](#game-settings-1)
  * [Physics Tuning](#physics-tuning)
  * [Weapon Tuning](#weapon-tuning)

## Copie des fichiers de configuration

Cette étape est à réaliser dans le cadre de la mise en place de Teeworlds ou Minecraft. Les fichiers vont être poussés sur la machine *nomad-node-games*. 

```bash
ansible-playbook start_game.yml --tags copy_files_nomad --extra-vars "source_folder=/home/donkesport/games_conf_files/<game_name>"
```

## Freeradius

Pour appliquer la configuration au niveau du RADIUS, il faut remplacer le fichier `users.other` dans res/infra_conf_files/freeradius/ par celui créé par le script dans [ce dossier](../res/tools/users_auth/).

Enfin, envoyer les fichiers utilisateurs avec la [Copie des fichiers d'utilisation](#copie-des-fichiers-de-configuration) depuis le serveur Nomad.

Relancer le service Freeradius dans le docker avec `sudo docker exec -it <docker_container_id> bash` et `systemctl restart freeradius`.

## CSGO

In the following documentation, *SRCDS* stands for Source Dedicated Server.

**SRCDS_TOKEN** est obligatoire pour lancer le serveur. Il faut générer un jeton pour l'**AppID 730** sur [ce site](https://steamcommunity.com/dev/managegameservers).

**SRCDS_RCONPW** et **SRCDS_PW** peuvent être écrasées par csgo/cfg/server.cfg. 

- SRCDS_TOKEN="changeme" (*Jeton Steam*)
- SRCDS_RCONPW="changeme" (*Mot de passe de la console du serveur*)
- SRCDS_PW="changeme" (*Mot de passe pour accéder au serveur depuis un client*)
- SRCDS_PORT=27015 (*Port sur lequel le serveur est accessible*)
- SRCDS_TV_PORT=27020 (*Port sur lequel les spectateurs pourront se connecter sur la SourceTV*)
- SRCDS_NET_PUBLIC_ADDRESS="0" (*Adresse IP publique du serveur*)
- SRCDS_IP="0.0.0.0" (*Adresse IP locale du serveur*)
- SRCDS_LAN="0" (*Serveur en mode LAN quand set à 1, si c'est le cas, pas de tentative de connexion à Steam*)
- SRCDS_FPSMAX=300 (*FPS maximum du serveur*)
- SRCDS_TICKRATE=128 (*Tickrate du serveur, 64 ou 128, plus le chiffre est élevé, meilleure sera la fluidité*)
- SRCDS_MAXPLAYERS=14 (*Définit le nombre maximum de joueurs*)
- SRCDS_STARTMAP="de_dust2" (*Carte utilisée pour jouer*)
- SRCDS_REGION=3 (*Région du serveur, 3 pour Europe*)
- SRCDS_MAPGROUP="mg_active" (*Mapgroup contenant Ancient, Dust II, Inferno, Mirage, Nuke, Overpass et Vertigo. Utiliser mg_history pour jouer sur Cache, Cobblestone ou Train - Non testé*)
- SRCDS_GAMETYPE=0 (*Changer cette valeur en fonction du tableau ci-dessous pour modifier le mode de jeu*)
- SRCDS_GAMEMODE=1 (*Changer cette valeur en fonction du tableau ci-dessous pour modifier le mode de jeu*)
- SRCDS_HOSTNAME="New CSGO Server" (*Nom du serveur CSGO*)
- SRCDS_WORKSHOP_START_MAP=0 (*Carte custom du Workshop - Non testé*)
- SRCDS_HOST_WORKSHOP_COLLECTION=0 (*Collection custom du Workshop - Non testé*)
- SRCDS_WORKSHOP_AUTHKEY="" (*jeton d'authentification au workshop - Non testé*)
- ADDITIONAL_ARGS="" (*Ajouter des arguments additionnels si nécessaire*)

Tableau des modes de jeu :

![](https://i.imgur.com/4SHIY5d.png)

## Minecraft

Il faut installer la dernière version de Java sur le noeud Nomad pour pouvoir faire tourner les dernières versions de Minecraft. 
Si des versions moins récentes veulent être jouées, il est possible de télécharger une version antérieure de Java.

Actuellement, on installe Java 17 avec :

```bash
apt install openjdk-17-jdk
# check version installed using java --version
```
Pour installer Java 16:

```bash
# Télécharger les .deb
wget http://security.ubuntu.com/ubuntu/pool/universe/o/openjdk-16/openjdk-16-jre-headless_16.0.1+9-1~20.04_amd64.deb
wget http://security.ubuntu.com/ubuntu/pool/universe/o/openjdk-16/openjdk-16-jre_16.0.1+9-1~20.04_amd64.deb

# Installer
sudo apt install ./openjdk-16-jre-headless_16.0.1+9-1~20.04_amd64.deb -y 
sudo apt install ./openjdk-16-jre_16.0.1+9-1~20.04_amd64.deb -y 

# Changer version de java
sudo update-java-alternatives --list
sudo update-alternatives --config java

# Vérification
java --version

# openjdk 16.0.1 2021-04-20
# OpenJDK Runtime Environment (build 16.0.1+9-Ubuntu-120.04)
# OpenJDK 64-Bit Server VM (build 16.0.1+9-Ubuntu-120.04, mixed mode, sharing)
```

On utilise pas l'API Spigot (variable SPIGET_RESOURCES) pour télécharger les plugins car certains peuvent ne plus être disponibles sur la plateforme. 
Si on a des plugins mainstream et maintenu, il est plus intéressant d'utiliser la variable d'environnement dédiée. 

## Game settings

More information on the github repository https://github.com/itzg/docker-minecraft-server/blob/master/README.md

- EULA - **Required to be set to true** so the server can start (eg: EULA=TRUE)

- MEMORY - RAM given to the server (eg: MEMORY=4G)

- VERSION - Version of the server (eg: VERSION=1.19.2) if not specified, the last version will be used

- WORLD - Map to play on (eg: WORLD=http://www.example.com/worlds/MySave.zip) if not specified, a random map will be generated

- TYPE - Server type, can be either Forge, Fabric, Quilt, Spigot, Paper, Pufferfish, Purpur,Magma, Mohist, Catserver, Loliserver, Canyon, SpongeVanilla, FTBA, Curseforge (eg: TYPE=SPIGOT)

- SPIGET_RESOURCES - Download plugins automatically from spigot (eg: SPIGET_RESOURCES=9089 to download https://www.spigotmc.org/resources/essentialsx.9089/)


- PACKWIZ_URL - Run with Packwiz modpack (eg: PACKWIZ_URL=https://example.com/modpack/pack.toml)

## Teeworlds

### Engine settings

- TW_sv_name {default: DeathMatch by Riftbit [ErgoZ] Bitbase <github.com/riftbit>} - Name of the server

- TW_bindaddr {default: *} - Address to bind 

- TW_sv_port {default: 8303} - Port the server will listen on

- TW_sv_external_port {default: 0} - Port to report to the master servers (e.g. in case of a firewall rename)
 
- TW_sv_max_clients {default: 12} - Number of clients that can be connected to the server at the same time
 
- TW_sv_max_clients_per_ip {default: 12} - Number of clients with the same ip that can be connected to the server at the same time

- TW_sv_high_bandwidth {default: 0} - Use high bandwidth mode, for LAN servers only
 
- TW_sv_register {default: 1} - Register on the master servers
 
- TW_sv_map {default: dm1} - Map to use

- TW_sv_rcon_password {default:} - Password to access the remote console (if not set, rcon is disabled)
 
- TW_password {default:} - Password to connect to the server
 
- TW_console_output_level {default: 0} - Adjust the amount of messages in the console
 
- TW_sv_rcon_max_tries {default: 3} - Maximum number of tries for remote console authetication
 
- TW_sv_rcon_bantime {default: 5} - Time (in minutes) a client gets banned if remote console authentication fails (0 makes it just use kick)
 
- TW_sv_auto_demo_record {default: 0} - Automatically record demos
 
- TW_sv_auto_demo_max {default: 10} - Maximum number of automatically recorded demos (0 = no limit)
 
- TW_ec_bindaddr {default: localhost} - Address to bind the external console to. Anything but 'localhost' is dangerous
 
- TW_ec_port {default: 8304} - Port to use for the external console
 
- TW_ec_password {default:} - External console password
 
- TW_ec_bantime {default: 0} - The time a client gets banned if econ authentication fails. 0 just closes the connection
 
- TW_ec_auth_timeout {default: 30} - Time in seconds before the the econ authentication times out

- TW_ec_output_level {default: 1} - Adjusts the amount of information in the external console
 
### Game settings

- TW_sv_warmup {default: 0} - Warmup time between rounds

- TW_sv_scorelimit {default: 20} - Score limit of the game (0 disables it)

- TW_sv_timelimit {default: 0} - Time limit of the game (in case of equal points there will  be sudden death)

- TW_sv_gametype {default: dm} - Gametype (dm/ctf/tdm/lms/lts/mod) (This setting needs the  map to be reloaded in order to take effect)
 
- TW_sv_maprotation {default:} - The maps to be rotated

- TW_sv_rounds_per_map {default: 1} - Number of rounds before changing to next map in rotation
 
- TW_sv_motd {default: Teeworlds server by Riftbit [ErgoZ] Bitbase <github.com/riftbit>} - Message of the day, shown in server info and when joining a server
 
- TW_sv_player_slots {default: 8} - Number of slots to reserve for players. Replaces - "svspectatorslots"
 
- TW_sv_teambalance_time {default: 1} - Time in minutes after the teams are uneven, to auto  balance
 
- TW_sv_spamprotection {default: 1} - Enable spam filter
 
- TW_sv_tournament_mode {default: 0} - Players will automatically join as spectator
 
- TW_sv_player_ready_mode {default: 0} - When enabled, players can pause/unpause the game and start the game on warmup via their ready state
 
- TW_sv_strict_spectate_mode {default: 0} - Restricts information like health, ammo and - armour in spectator mode
 
- TW_sv_silent_spectator_mode {default: 1} - Mute join/leave message of spectator
 
- TW_sv_skill_level {default: 1} - Skill level shown in serverbrowser (0 = casual, 1 = - normal, 2 = competitive)
 
- TW_sv_respawn_delay_tdm {default: 3} - Time needed to respawn after death in tdm gametype
 
- TW_sv_teamdamage {default: 0} - Enable friendly fire
 
- TW_sv_powerups {default: 1} - Enable powerups (katana)
 
- TW_sv_respawn_delay_tdm {default: 1} - Enable powerups (katana)
 
- TW_sv_vote_kick {default: 1} - Enable kick voting
 
- TW_sv_vote_kick_bantime {default: 5} - Time in minutes to ban a player if kicked by voting (0 equals only kick)

- TW_sv_vote_kick_min {default: 0} - Minimum number of players required to start a kick vote

- TW_sv_inactivekick_time {default: 3} - Time in minutes after an inactive player will be taken care of

- TW_sv_inactivekick {default: 1} - How to deal with inactive players (0 = move to - spectator, 1 = move to free spectator slot/kick, 2 = kick)

- TW_sv_vote_spectate {default: 1} - Allow voting to move players to spectators

- TW_sv_vote_spectate_rejoindelay {default: 3} - How many minutes to wait before a player can rejoin after being moved to spectators by vote

### Physics Tuning

Tuning is a way to edit physics and weapon settings so that the server is more customizable. Tuning can only be used on non-pure gametypes. Set the gametype to mod using TW_sv_gametype mod and tune a variable

- TW_ground_control_speed {default: 10.0} - Max speed the tee can get on ground
 
- TW_ground_control_accel {default: 2.0} - Acceleration speed on the ground
 
- TW_ground_friction {default: 0.5} - Friction on the ground
 
- TW_ground_jump_impulse {default: 13.2} - Impulse when jumping on ground
 
- TW_air_jump_impulse {default: 12.0} - Impulse when jumping in air
 
- TW_air_control_speed {default: 5.0} - Max speed the tee can get in the air
 
- TW_air_control_accel {default: 1.5} - Acceleration speed in air
 
- TW_air_friction {default: 0.9} - Friction in the air
 
- TW_hook_length {default: 380.0} - Length of the hook (pixels)
 
- TW_hook_fire_speed {default: 80.0} - How fast the hook is fired
 
- TW_hook_drag_accel {default: 3.0} - Acceleration when hook is stuck
 
- TW_hook_drag_speed {default: 15.0} - Drag speed of the hook
 
- TW_gravity {default: 0.5} - Gravity of the teeworld
 
- TW_velramp_start {default: 550.0} - Velocity ramp start
 
- TW_velramp_range {default: 2000.0} - Velocity ramp range
 
- TW_velramp_curvature {default: 1.4} - Velocity ramp curvature
 
- TW_player_collision {default: 1} - Enable player collisions
 
- TW_player_hooking {default: 1} - Enable player vs player hooking

### Weapon Tuning

Tuning is a way to edit physics and weapon settings so that the server is more customizable. Tuning can only be used on non-pure gametypes. Set the gametype to mod using TW_sv_gametype mod and tune a variable

 
- TW_gun_curvature {default: 1.25} - Gun curvature
 
- TW_gun_speed {default: 2200.0} - Gun speed (pixels / sec)
 
- TW_gun_lifetime {default: 2.0} - Gun lifetime (sec)
 
- TW_shotgun_curvature {default: 1.25} - Shotgun curvature
 
- TW_shotgun_speed {default: 2750.0} - Shotgun speed (pixels / sec)
 
- TW_shotgun_speeddiff {default: 0.8} - (UNUSED) Speed difference between shotgun bullets
 
- TW_shotgun_lifetime {default: 0.20} - Shotgun lifetime (sec)
 
- TW_grenade_curvature {default: 7.0} - Grenade curvature
 
- TW_grenade_speed {default: 1000.0} - Grenade speed (pixels / sec)
 
- TW_grenade_lifetime {default: 2.0} - Grenade lifetime (sec)

- TW_laser_reach {default: 800.0} - How long the laser can reach (pixels)
 
- TW_laser_bounce_delay {default: 150.0} - When bouncing, stop the laser this long (ms)
 
- TW_laser_bounce_num {default: 1.0} - How many times the laser can bounce

- TW_laser_bounce_cost {default: 0.0} - Remove this much from reach when laser is bouncing (pixels)
 
- TW_laser_damage {default: 5.0} - Laser damage (damage)
## Lancache

Le job lancache est composé de 2 images docker (dans respectivement 2 tâches nomad).

### Tasks 
### lancache-dns-server

Le rôle de cette task est de modifier certains enregistrement DNS courant pour le téléchargement des jeux (par ex : Steam, EpicGames, ...).
Cette méthode nous permet d'herberger en local un serveur de fichiers pour les jeux des éditeurs le plus courant.


### lancache-monolitic-server
Cette task est le serveur de fichiers.
Les joueurs vont télécharger leurs jeux depuis ce serveur.

Stockage nécessaire estimée : 200Go.
Mémoire nécessaire estimée : en fonction de la charge

### Pré-requis
- activer les volumes partagés docker sur le client nomad
- imposer le lancache comme serveur DNS des joueurs
- avoir accès à Internet (dl de l'image et des jeux quand pas présent sur le monolitic)


#### Lancer le job nomad via ansible
Positionner le lancache.nomad dans le dossier template.

Déployer le job via ansible : 
```
ansible-playbook start_jobs.yml --tags start_job_nomad --extra-vars "game_name=lancache"
```