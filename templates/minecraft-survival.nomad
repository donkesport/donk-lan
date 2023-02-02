job "minecraft-survival"{
    datacenters = ["dc1"]
    priority = 80
    group "mc-server" {
        network {
            port "minecraft" {
                to = 25565
            }
        }

        service {
            name = "minecraft-survival"
            port = "minecraft"
            provider = "nomad"

            tags = [
                "traefik.enable=true",
                "traefik.tags=service",
                "traefik.udp.routers.minecraft-survival-udp.entrypoints=minecraft-survival-udp",
                "traefik.udp.routers.minecraft-survival-udp.service=minecraft-survival",
                "traefik.tcp.routers.minecraft-survival-tcp.entrypoints=minecraft-survival-tcp",
                "traefik.tcp.routers.minecraft-survival-tcp.service=minecraft-survival",
                "traefik.tcp.routers.minecraft-survival-tcp.rule=HostSNI(`*`)",
            ]
            }


        task "minecraft" {
            resources {
                cpu = 4000
                memory = 4096
                disk = 4000
            }

            constraint {
                attribute = "${node.unique.name}"
                operator  = "regexp"
                value = "games"
             }

            driver = "docker"
                config {
                    ports = ["minecraft"]
                    image = "registry.donk.lan:5000/minecraft-server"
                    image_pull_timeout = "10m"
                    volumes = ["/home/donkesport/minecraft-survival/plugins:/data/plugins",
                               "/home/donkesport/minecraft-survival/survival_map:/data/world"
                    ]
                }

            env {
                EULA="TRUE"
                TYPE="PAPER"
                OPS="WildP4sta"
                MEMORY="4G"
                ICON="https://i.imgur.com/pHh7007.png"
                OVERRIDE_ICON="TRUE"
                SERVER_NAME="Buildbattle Donkesport"
                MOTD="\u00a72\u00a7l@donkesport sur Instagram"
                ONLINE_MODE="FALSE"
            }
        }
    }
}