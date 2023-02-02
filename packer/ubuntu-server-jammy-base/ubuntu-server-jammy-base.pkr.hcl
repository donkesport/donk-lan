# Ubuntu Server jammy-nomad
# ---
# Packer Template to create an Ubuntu Server (jammy) on Proxmox

# Variable Definitions
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "admin_ip" {
    type = string
}


variable "disk_size" {
    type = string
}

variable "cores" {
    type = string
}

variable "memory" {
    type = string
}

variable "bridge" {
    type = string
}

variable "node" {
    type = string
}

variable "vmid" {
    type = string
}

# Resource Definiation for the VM Template
source "proxmox" "ubuntu-server-jammy-base" {

    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true

    # VM General Settings
    node = "${var.node}" 
    vm_id = "${var.vmid}"
    vm_name = "ubuntu-server-jammy-base"
    template_description = "Ubuntu Server jammy image"

    # VM OS Settings
    # (Option 1) Local ISO File
    iso_file = "local:iso/ubuntu-22.04.1-live-server-amd64.iso"
    # - or -
    # (Option 2) Download ISO
    # iso_url = "https://releases.ubuntu.com/jammy/ubuntu-22.04.1-live-server-amd64.iso"
    # iso_checksum = "10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"

    iso_storage_pool = "local"
    unmount_iso = true

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "${var.disk_size}"
        format = "raw"
        storage_pool = "local-lvm"
        storage_pool_type = "lvm"
        type = "sata"
    }

    # VM CPU Settings
    cores = "${var.cores}"

    # VM Memory Settings
    memory = "${var.memory}"

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "${var.bridge}"
        firewall = "false"
    }

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    # PACKER Boot Commands
    boot_command = [
      "c",
      "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
      "<wait5><enter><wait5>",
      "initrd /casper/initrd",
      "<wait><enter><wait>",
      "boot",
      "<wait><enter><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    http_directory = "ubuntu-server-jammy-base/http"
    # (Optional) Bind IP Address and Port
    http_bind_address = "${var.admin_ip}"
    http_port_min = 8802
    http_port_max = 8802

    ssh_username = "donkesport"

    # (Option 1) Add your Password here
    # ssh_password = 
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    ssh_private_key_file = "~/.ssh/id_ed25519_ansible"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-jammy-base"
    sources = ["source.proxmox.ubuntu-server-jammy-base"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo rm -f /etc/netplan/50-cloud-init.yaml",
            "sudo cloud-init clean",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "ubuntu-server-jammy-base/files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}
