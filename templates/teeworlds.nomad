job "teeworlds" {
  datacenters = ["dc1"]

  group "teeworlds_server" {

    # Port mapping #
    network {
      port "teeworlds" {
        # Manual port mapping can be done with static
        # static = XXX
        to = 8303
      }
    }

    service {
      name = "teeworlds"
      port = "teeworlds"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.tags=service",
        "traefik.udp.routers.teeworlds-udp.entrypoints=teeworlds-udp",
        "traefik.udp.routers.teeworlds-udp.service=teeworlds",
      ]
    }

    task "teeworlds" {
      # Installing only on the game node
      constraint {
        attribute = "${node.unique.name}"
        operator  = "regexp"
        value = "games"
      }

      # Docker image pull
      driver = "docker"
      config {
        ports = ["teeworlds"]
        image = "registry.donk.lan:5000/teeworlds"
        image_pull_timeout = "5m"
        volumes = ["/home/donkesport/teeworlds/custom_maps:/teeworlds/custom_maps"]
        #After pulling the image, copying the .map file in the host folder and starting the server
        command = "/bin/bash"
        args = ["-c", "cp custom_maps/*.map data/maps/; ./teeworlds_srv -f autoexec.cfg"]
      }

      env {
        TW_sv_name="donkesport-server"
        TW_sv_rcon_password="donkesport"
        TW_sv_motd="@donkesport sur Instagram"
        TW_sv_max_clients="50"
        TW_sv_max_clients_per_ip="50"
        TW_sv_high_bandwidth="1"
        TW_sv_timelimit="10"
        TW_sv_scorelimit="0"
        TW_sv_gametype="CTF"
        TW_sv_map="ctf1"
        TW_sv_player_slots="50"
      }
    }
  }
}