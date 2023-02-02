job "webserver" {
  datacenters = ["dc1"]
  type        = "service"

  group "webserver" {
    count = 1

    # Port mapping
    network {
      port "http" {
          # Manual port mapping can be done with static
          # static = XXX
          to = 80
      }
    }

    service {
      name = "webserver"
      provider = "nomad"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.tags=service",
        "traefik.http.routers.website.rule=Host(`www.donk.lan`)",
        "traefik.http.routers.website.entrypoints=web",
        "traefik.http.routers.website.service=webserver",
      ]
    }

    task "server" {
      constraint {
          attribute = "${node.unique.name}"
          operator  = "regexp"
          value     = "infra"
      }

      driver = "docker"

      config {
        ports = ["http"]
        image = "registry.donk.lan:5000/httpd"
        image_pull_timeout = "10m"
        volumes = ["/home/donkesport/data/website:/usr/local/apache2/htdocs"]
      }
    }
  }
}