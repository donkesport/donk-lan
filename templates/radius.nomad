locals {
  ports = [
      {
          port_label = "authentication"
          port       = 1812
      },
      {
          port_label = "accounting"
          port       = 1813
      },
      {
          port_label = "tunnel"
          port       = 18120
      }
  ]
}

job "radius" {
    datacenters = ["dc1"]
    group "radius_server"{
        network{
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
        name = "radius-auth"
        port = "authentication"
        provider = "nomad"

        tags = [
          "traefik.enable=true",
          "traefik.tags=service",
          "traefik.udp.routers.radius-auth-udp.entrypoints=radiusauthentication-udp",
          "traefik.udp.routers.radius-auth-udp.service=radius-auth",
        ]
      }

      service {
        name = "radius-acc"
        port = "accounting"
        provider = "nomad"

        tags = [
          "traefik.enable=true",
          "traefik.tags=service",
          "traefik.udp.routers.radius-acc-udp.entrypoints=radiusaccounting-udp",
          "traefik.udp.routers.radius-acc-udp.service=radius-acc",
        ]
      }
    
      service {
        name = "radius-tun"
        port = "tunnel"
        provider = "nomad"
          tags = [
          "traefik.enable=true",
          "traefik.tags=service",
          "traefik.udp.routers.radius-tun-udp.entrypoints=radiustunnel-udp",
          "traefik.udp.routers.radius-tun-udp.service=radius-tun",
        ]
      }
      
      task "radius" {
        # Installing only on the game node
        constraint {
          attribute = "${node.unique.name}"
          operator  = "regexp"
          value = "infra"
        }

        # Docker image pull
        driver = "docker"
        config {
          volumes = ["/home/donkesport/freeradius/authorize:/etc/raddb/mods-config/files/authorize", "/home/donkesport/freeradius/clients.conf:/etc/raddb/clients.conf", "/home/donkesport/freeradius/users.other:/etc/raddb/mods-config/files/users.other"]
          ports = ["authentication", "accounting", "tunnel"]
          image = "registry.donk.lan:5000/freeradius-server"
          image_pull_timeout = "10m"
        }
      }
    }
}