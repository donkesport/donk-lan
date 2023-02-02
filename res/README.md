# Webserver

0. Create `/home/donkesport/data` folder
1. Alter nomad client configuration :
```
vim /etc/nomad.d/client.hcl
        host_volume "website-data" {
                path = "/home/donkesport/data/website"
                read_only = false
        }
```
2. Copy webserver data to `/home/donkesport/data/website`