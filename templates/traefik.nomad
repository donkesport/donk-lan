locals {
  ports = [
      {
          port_label = "http"
          port       = 80
      },
      {
          port_label = "admin"
          port       = 8080
      },
      {
          port_label = "teeworldsport"
          port       = 8303
      },
      {
          port_label = "csgoport"
          port       = 27015
      },
      {
          port_label = "csgotvport"
          port       = 27020
      },
      {
          port_label = "minecraftbuildbattleport"
          port       = 25565
      },
      {
          port_label = "minecraftsurvivalport"
          port       = 25566
      },
      {
          port_label = "radiusauthentication"
          port       = 1812
      },
      {
          port_label = "radiusaccounting"
          port       = 1813
      },
      {
          port_label = "radiustunnel"
          port       = 18120
      }
  ]
}

job "traefik" {
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      dynamic "port" { # works like a for loop
        for_each = local.ports # list ; each element will be labeled as the name of the dynamic bloc
        # iterator = port # optional, name of the temporary variable that represents the current element of the complex value (for_each)
        labels   = [port.value.port_label]

        content {
          static = port.value.port
        }
      }
    }

    service {
      name = "traefik-http"
      provider = "nomad"
      port = "http"
    }

    task "server" {
        constraint {
            attribute = "${node.unique.name}"
            operator  = "regexp"
            value     = "games"
        }
      resources {
        cpu = 2048
        memory = 2048
      }
      driver = "docker"
      config {
        image = "traefik:latest"
        ports = ["admin", "http", "teeworldsport", "csgoport", "csgotvport", "minecraftbuildbattleport", "minecraftsurvivalport", "radiusauthentication", "radiusaccounting", "radiustunnel"]
        args = [
          "--api.dashboard=true",
          "--api.insecure=true", ### For Test only, please do not use that in production
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
          "--entrypoints.teeworlds-udp.address=:${NOMAD_PORT_teeworldsport}/udp",
          "--entrypoints.minecraft-build-udp.address=:${NOMAD_PORT_minecraftbuildbattleport}/udp",
          "--entrypoints.minecraft-build-tcp.address=:${NOMAD_PORT_minecraftbuildbattleport}",
          "--entrypoints.minecraft-survival-udp.address=:${NOMAD_PORT_minecraftsurvivalport}/udp",
          "--entrypoints.minecraft-survival-tcp.address=:${NOMAD_PORT_minecraftsurvivalport}",
          "--entrypoints.csgo-udp.address=:${NOMAD_PORT_csgoport}/udp",
          "--entrypoints.csgo-tcp.address=:${NOMAD_PORT_csgoport}",
          "--entrypoints.csgotv-udp.address=:${NOMAD_PORT_csgotvport}/udp",
          "--entrypoints.radiusauthentication-udp.address=:${NOMAD_PORT_radiusauthentication}/udp",
          "--entrypoints.radiusaccounting-udp.address=:${NOMAD_PORT_radiusaccounting}/udp",
          "--entrypoints.radiustunnel-udp.address=:${NOMAD_PORT_radiustunnel}/udp",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=http://10.50.12.11:4646", ### IP to your nomad server
          "--metrics.prometheus=true",
          "--metrics.prometheus.addEntryPointsLabels=true",
          "--metrics.prometheus.addrouterslabels=true",
          "--metrics.prometheus.addServicesLabels=true",
          "--accesslog=true",
          "--log.level=DEBUG",
        ]
      }
    }
  }
}