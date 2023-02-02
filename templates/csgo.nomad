locals {
  ports = [
      {
          port_label = "csgoport"
          port       = 27015
      },
      {
          port_label = "csgotvport"
          port       = 27020
      }
  ]
}

job "csgo" {
  datacenters = ["dc1"]

  # Disk size of the container, must be large to download the CSGO files
  group "csgo_server" {
      ephemeral_disk {
        size = 30720
      }

      # Port mapping
      network {
        dynamic "port" { # works like a for loop
                for_each = local.ports # list ; each element will be labeled as the name of the dynamic bloc
                # iterator = port # optional, name of the temporary variable that represents the current element of the complex value (for_each)
                labels   = [port.value.port_label]

                content {
                  to = port.value.port
                }
          }
      }

    service {
      name = "csgo"
      port = "csgoport"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.tags=service",
        "traefik.tcp.routers.csgo-tcp.entrypoints=csgo-tcp",
        "traefik.udp.routers.csgo-udp.entrypoints=csgo-udp",
        "traefik.udp.routers.csgo-udp.service=csgo",
        #"traefik.udp.routers.csgo-tcp.service=csgo", # TO TEST
      ]
    }

    service {
      name = "csgotv"
      port = "csgotvport"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.tags=service",
        "traefik.udp.routers.csgotv-udp.entrypoints=csgotv-udp",
        "traefik.udp.routers.csgotv-udp.service=csgotv",
      ]
    }

    # Specs of the nomad container
    task "csgo" {
      resources {
        cpu = 7168
        memory = 8192
        disk = 30720
      }

      # Installing only on the game node
      constraint {
        attribute = "${node.unique.name}"
        operator  = "regexp"
        value = "games"
      }

      # Docker image pull
      driver = "docker"
      config {
        ports = ["csgoport", "csgotvport"]
        image = "registry.donk.lan:5000/csgo"
        image_pull_timeout = "10m"
      }

      # Docker environment variables
      # Setting up map, gamemode etc.
      # Don't forget to update the Steam Token
      env{
        SRCDS_TOKEN=""
        SRCDS_RCONPW="donkesport"
        SRCDS_PW="donkesport"
        SRCDS_PORT=27015
        SRCDS_TV_PORT=27020
        SRCDS_NET_PUBLIC_ADDRESS="0"
        SRCDS_IP="0.0.0.0"
        SRCDS_FPSMAX=300
        SRCDS_TICKRATE=128
        SRCDS_MAXPLAYERS=14
        SRCDS_STARTMAP="de_dust2"
        SRCDS_REGION=3
        SRCDS_MAPGROUP="mg_active"
        SRCDS_GAMETYPE=0
        SRCDS_GAMEMODE=1
        SRCDS_HOSTNAME="DONK CSGO Server"
      }
    }
  }
}