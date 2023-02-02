# Proxmox Full-Clone
# ---
# Create a new VM from a clone

resource "proxmox_vm_qemu" "consul-server" {

    # Count Variable
    count = length(var.hostnames)    
    
    # VM General Settings
    target_node = var.node
    vmid = var.vmid + count.index
    name = var.hostnames[count.index]
    desc = "Automatic VM by Terraform"  
    
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"

    # VM Advanced General Settings
    onboot = true     
    oncreate = true

    # VM OS Settings
    full_clone = false # test
    clone = "ubuntu-server-jammy-base"    

    # VM System Settings
    agent = 1
    
    # VM CPU Settings
    cores = 2
    cpu = "host"    
    
    # VM Memory Settings
    memory = var.rams[count.index]

    # VM Network Settings
    network {

        bridge = var.bridges[count.index]
        model  = "virtio"
    }    

    # VM Settings
    os_type = "cloud-init"
    ipconfig0 = "ip=${var.ips[count.index]}/24,gw=${var.gateways[count.index]}"
    nameserver = var.dns_server
    searchdomain = "donk.lan"
    sshkeys = file(var.ssh_keys["pub"])

    # Connection settings for remote-exec 
    connection {
        type        = "ssh"
        user        = "donkesport"
        private_key = file(var.ssh_keys["priv"])
        host = "${var.ips[count.index]}"
    }
    
    provisioner "remote-exec" {
	    # Leave this here so we know when to start with Ansible local-exec 
        inline = ["cloud-init status --wait"] # waiting until all cloud-init dl is done. Playbook need to install via apt and cloud-init make conflict with
    }
    # # Send server.hcl file to /home/donkesport/nomad-server-data/ WIP
    # provisioner "local-exec" {
    #     working_dir = "../../ansible/"
    #     command = "ansible-playbook consul.yaml"
    # }

}
