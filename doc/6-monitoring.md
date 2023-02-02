# Monitoring de l'infrastructure

Pour effectuer le monitoring de l'infrastructure, tant au niveau des performances (utilisation des ressources) et des événements de sécurité (remontée des journaux), trois éléments sont déployés :
- prometheus
- loki
- une interface de visualisation : Grafana

Promtail est un agent permettant d'envoyer des logs à Loki : il sera parfois nécessaire de l'installer en agent sur les hôtes, en complément de syslog. 

Tous ces éléments seront hébergés sur la même machine virtuelle, située dans le VLAN `SRV_MONITORING` (10.50.11.0/24).

## Configuration de la VM

Création d'une nouvelle VM avec terraform.
Celle-ci doit avoir au moins 8GB de RAM (Prometheus est assez gourmand).

### Application de la politique de journalisation

Selon la politique de journalisation souhaitée, modifier le template promtail>templates>promtail.yml.j2 : choix des fichiers de /var/log à exporter

### Installation de la pile

Installation de Loki, prometheus et grafana grâce au rôle ansible : 
https://github.com/jinja2ninja/grafana_stack_collection

Il faut d'abord mettre à jour les versions :
- node_exporter_version: 1.4.0
- prometheus_version: 2.40.2
- loki_version: 2.7.0
- promtail_version: 2.7.0

Pour utiliser les adresses IP et non les noms d'hôtes dans la configuration du serveur prometheus : utiliser la variable `server.ansible_host` dans le template `prometheus.yaml.j2`.

Pour lancer le playbook : 
```
ansible-playbook monitoring.yaml --extra-vars "loki_ip=10.50.11.100"
```

Il installe automatiquement les agents prometheus sur les clients.

### Troubleshooting loki

Au besoin, redémarrer le service loki
Pour tester la connexion : `curl http://ip:3100/ready` : doit retourner ready.

Vérifier que le binaire dans /opt/loki a bien été renommé : le chemin doit être `/opt/loki/loki`

### Connexion à Grafana

http://ip:3000 pour accéder au panneau grafana
Par défaut : `admin/admin`, mot de passe à modifier lors de la première connexion

http://ip:9090 pour prometheus : aller dans Status > Targets pour voir les serveurs surveillés par Prometheus.

### Dashboards

Les dashboards s'affichant sont dans res/grafana_dashboards :
- node-exporter-full : https://grafana.com/grafana/dashboards/1860-node-exporter-full/

## Configuration des clients

### Pfsense 

#### Journaux d'événements

Activer le forward des logs : https://www.manageengine.com/products/firewall/help/configure-pfsense-firewalls.html

Puis pour pouvoir relayer les logs à Loki, envoi par rsyslog vers promtail (cf : https://alexandre.deverteuil.net/post/syslog-relay-for-loki/)
- modification de config-promtail.yml
```yaml
  - job_name: syslog
    syslog:
      listen_address: 0.0.0.0:1514
      listen_protocol: udp
      labels:
        job: syslog
    relabel_configs:
      - source_labels: [__syslog_message_hostname]
        target_label: host
      - source_labels: [__syslog_message_hostname]
        target_label: hostname
      - source_labels: [__syslog_message_severity]
        target_label: level
      - source_labels: [__syslog_message_app_name]
        target_label: application
      - source_labels: [__syslog_message_facility]
        target_label: facility
      - source_labels: [__syslog_connection_hostname]
        target_label: connection_hostname
```

- configuration de rsyslog pour forward les logs à promtail en udp : fichier /etc/rsyslog.d/00-promtail-relay.conf
```conf
# https://www.rsyslog.com/doc/v8-stable/concepts/multi_ruleset.html#split-local-and-remote-logging
ruleset(name="remote"){
  # https://www.rsyslog.com/doc/v8-stable/configuration/modules/omfwd.html
  # https://grafana.com/docs/loki/latest/clients/promtail/scraping/#rsyslog-output-configuration
  action(type="omfwd" protocol="udp" target="localhost" port="1514" Template="RSYSLOG_SyslogProtocol23Format")
}


# https://www.rsyslog.com/doc/v8-stable/configuration/modules/imudp.html
module(load="imudp")
input(type="imudp" port="514" ruleset="remote")

# https://www.rsyslog.com/doc/v8-stable/configuration/modules/imtcp.html
module(load="imtcp")
input(type="imtcp" port="514" ruleset="remote")
```

Les logs remontent alors dans grafana (penser à reload rsyslog et promtail après la modification de configuration).

Tags : 
- `application=php-fpm` : actions d'administration, login/logout des administrateurs ;
- `facility=auth` : login des admins (entre autres) ;
- `facility=daemon` : logout des admins (entre autres) ;
- `application=filterlog` : filtrage : pour plus de détails sur le format :  https://docs.netgate.com/pfsense/en/latest/monitoring/logs/raw-filter-format.html

#### Metrics

Installer le paquet (System > Package Manager > Package Installer) `node_exporter`.

Puis l'activer dans le menu Services > Prometheus node_exporter.
On doit pouvoir accéder aux métriques sur l'interface choisie : par exemple : `http://10.50.11.254:9100/metrics`.

### FortiGate

Activer le forward des logs vers Loki.
