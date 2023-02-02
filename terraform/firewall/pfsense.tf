# Proxmox Full-Clone
# ---
# Create a new VM from a clone

resource "proxmox_vm_qemu" "pfsense" {

    count = length(var.hostnames) 

    # VM General Settings
    target_node = var.node
    vmid = var.vmid + count.index
    name = var.hostnames[count.index]
    desc = "Pfsense VM"  
    
    scsihw = "virtio-scsi-pci"
    boot = "dcn"
    bootdisk = "scsi0"

    # VM Advanced General Settings
    hotplug = "network,disk,usb"
    onboot = true     
    oncreate = true

        # VM OS Settings
    full_clone = false # test
    clone = "pfsense-template"    
 

    # VM System Settings
    # agent = 0
    
    # VM CPU Settings
    cores = 4
    sockets = 2
    cpu = "host"    
    
    # VM Memory Settings
    memory = var.rams[count.index]

    # VM Network Settings
    network {
        bridge = var.bridges[0]
        macaddr= "6A:79:CC:81:7C:1F" # force DHCP to give 10.50.10.25 (test) or 10.50.10.254 (prod)
        model  = "virtio"
    } 

    network {
        bridge = var.bridges[1]
        model  = "virtio"
    } 

    network {
        bridge = var.bridges[2]
        model  = "virtio"
    } 

    network {
        bridge = var.bridges[3]
        model  = "virtio"
    } 

    network {
        bridge = var.bridges[4]
        model  = "virtio"
    } 

    network {
        bridge = var.bridges[5]
        model  = "virtio"
    } 

    network {
        bridge = var.bridges[6]
        model  = "virtio"
    } 


    connection {
        type        = "ssh"
        user        = "donkesport"
        private_key = file(var.ssh_keys["priv"])
        host = "${var.ips[count.index]}"
    }

    provisioner "remote-exec" {
        inline = ["echo 'ready for provisionning'"]      
    }
     
}