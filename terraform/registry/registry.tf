# Proxmox Full-Clone
# ---
# Create a new VM from a clone

resource "proxmox_vm_qemu" "registry" {

    # Count Variable
    count = length(var.hostnames)    
    
    # VM General Settings
    target_node = var.node
    vmid = var.vmid + count.index
    name = var.hostnames[count.index]
    desc = "Registry VM"  
    
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    # disk {
    #     slot            = 1
    #     size            = "30G"
    #     type            = "scsi"
    #     storage         = "local-lvm"
    # }

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

    # provisioner "local-exec" {
    #     # provision gitea VM
    #     working_dir = "../../ansible/"
    #     command = "ansible-playbook gitea.yaml --tags install --extra-vars 'gitea_ip=${var.ips[count.index]}'"
    # }

    # provisioner "local-exec" {
    #     # provision gitea VM
    #     working_dir = "../../ansible/"
    #     command = "ansible-playbook gitea.yaml --tags postinstall"
    # }

    # provisioner "local-exec" {
    #     # provision drone vm
    #     working_dir = "../../ansible/"
    #     command = "ansible-playbook drone.yaml --tags dockerinstall"
    # }

    # # Send server.hcl file to /home/donkesport/nomad-server-data/
    # provisioner "local-exec" {
    #     working_dir = "../../ansible/"
    #     command = "ansible-playbook -u ${var.user} --key-file ${var.ssh_keys["priv"]} -i ${var.ips[count.index]}, nomad-server.yaml"
    # }

    # provisioner "local-exec" {
    #     working_dir = "../../ansible/"
    #     command = "cat provision.yaml"
    # }
   

    # provisioner "local-exec" {
    #     working_dir = "../../ansible/"
    #     command = "ansible-playbook -u ${var.user} --key-file ${var.ssh_keys["priv"]} -i ${var.ips[count.index]}, provision.yaml"
    # }
  
    

    # # Send ssh authorized_keys file to /home/donkesport/.ssh/
    # provisioner "local-exec" {
    #     working_dir = "../../ansible/"
    #     command = "ansible-playbook -u ${var.user} --key-file ${var.ssh_keys["priv"]} -i ${var.ips[count.index]}, ssh.yaml"
    # }
}
