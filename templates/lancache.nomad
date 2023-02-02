job "lancache" {
  datacenters = ["dc1"]

  group "lancache" {

      ephemeral_disk {
        size = 300000
      }

    # Port mapping
    network {
      port "lancacheportdns" {
        # Manual port mapping can be done with static
        static = 53
        to = 53
      }
      port "lancacheporthttp" {
        # Manual port mapping can be done with static
        static = 80
        to = 80
      }
      port "lancacheporthttps" {
        # Manual port mapping can be done with static
        static = 443
        to = 443
      } 

    }

    task "lancache-dns-server" {
      # Installing only on the game node

      resources {
        cpu = 3000
        memory = 8192
      }

      constraint {
        attribute = "${node.unique.name}"
        operator  = "regexp"
        value     = "infra"
      }

      # Docker image pull
      driver = "docker"
      config {
        ports = ["lancacheportdns"]
        image = "lancachenet/lancache-dns:latest"
        volumes = ["/home/donkesport/data/lancache/custom.db:/etc/bind/cache/custom.db"]
      }

      env {
        USE_GENERIC_CACHE="true"
        LANCACHE_IP="${attr.unique.network.ip-address}"
      }
    }

    task "lancache-monolitic-server" {

      resources {
        cpu = 4000
        memory = 16384 
      }

      # Installing only on the game node
      constraint {
        attribute = "${node.unique.name}"
        operator  = "regexp"
        value     = "infra"
      }

      # Docker image pull
      driver = "docker"
      config {
        ports = ["lancacheporthttp" , "lancacheporthttps" ]
        image = "lancachenet/monolithic:latest"
        volumes = ["/home/donkesport/lancache/data/cache:/data/cache", "/home/donkesport/lancache/data/logs:/data/logs"] 
      }
    }
  }
}