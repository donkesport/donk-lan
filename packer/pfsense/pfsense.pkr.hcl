# Ubuntu Server jammy-nomad
# ---
# Packer Template to create a template of pfense OS on Proxmox

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

variable "ssh_key" {
    type = string
}



source "proxmox" "pfsense" {

    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true

    # VM General Settings
    node = "${var.node}" 
    vm_id = "${var.vmid}"
    vm_name = "pfsense-template"
    template_description = "Pfsense 2.6.0 image"

     # VM OS Settings
    # (Option 1) Local ISO File
    iso_file = "local:iso/pfSense-CE-2.6.0-RELEASE-amd64.iso"

    # VM CPU Settings
    cores = "${var.cores}"
    cpu_type = "host"

    # VM Memory Settings
    memory = "${var.memory}"

    # System    
    # os = "l26"
    
    # Storage
    disks {
        type="scsi"
        disk_size="${var.disk_size}"
        storage_pool="local-lvm"
        storage_pool_type="lvm"
    }
    

    # Network WAN
    network_adapters {
            model = "virtio"
            bridge = "vmbr10"
    }
    
    # Network LAN
    network_adapters {
            model = "virtio"
            bridge = "vmbr32"
    }
    
    # Remove installation media
    unmount_iso = true
    # Start this on system boot
    onboot = true

    # Boot commands
    boot_wait = "2m"
    boot_command = [
        # Accept copyright
        "<enter><wait2s>",
        # Options: Install, Rescue Shell, Recover config.xml
        # Press enter to install
        "<enter><wait2s>",
        # Select keyboard layout, default US
        "<enter><wait2s>",
        # Options: Auto (UFS) Bios, Auto (UFS) UEFI, Manual, Shell, Auto (ZFS)
        # Enter for Auto UFS Bios
        "<enter><wait2s>",
        
        # Custom install
        "<enter><wait2s>",
        "<enter><wait2s>",
        "<spacebar><wait2s><enter><wait2s>",
        "<left><wait><enter><wait3m>",
        
        # Enter to Shell
        "<left><wait><enter>",
        # Dropped to shell...
        #"echo 'Port 22' >> /etc/ssh/sshd_config"
        #"echo 'ListenAddress 0.0.0.0 >> /etc/ssh/sshd_config'"
        # Allow password auth
        #"echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config",
        #"<enter><wait>",
        # Enable sshd on reboot
        #"echo 'sshd_enable=\"YES\"' >> /etc/rc.conf",
        #"<enter><wait>",
        # Create a user for ourselves
        "pw user add -n donkesport -G wheel",
        "<enter><wait>",
        #"passwd packer",
        #"<enter><wait>",
        #"testing"
        #"<enter><wait>",
        #"testing",
        #"<enter><wait>",

        # Add authorized keys
        "mkdir /home/donkesport",
        "<enter><wait>",
        "cd /home/donkesport/",
        "<enter><wait>",
        "mkdir .ssh",
        "<enter><wait>",
        "echo \"${var.ssh_key}\" > .ssh/authorized_keys",
        "<enter><wait>",
        "chown -R donkesport:donkesport /home/donkesport",
        "<enter><wait>",
        
        "reboot",
        #"<enter><wait2m>",

        #Chain the rest or it fails to get through due to reboot...
        # Enter to reboot
        # n to setting up vlan tags
        # vtnet0 for WAN interface name
        # blank for LAN interface
        # y to confirm and start configuration
        # 14 -> y to enable sshd
        "<enter><wait2m>n<enter><wait1s>vtnet0<enter><wait1s><enter><wait1s>y<enter><wait4m>14<enter><wait>y<enter><wait>",

        # Static IP configuration
        # 2 for Set IP Address 
        # 1 for WAN interface
        # n for disable DHCP 
        # 10.50.10.123 for IP
        # 24 for netmask 
        # n and enter for disable IPv6 configuration
        # "2<enter><wait>1<enter><wait>n<enter><wait>10.50.10.123<enter><wait>24<enter><wait><enter><wait>n<enter><wait><enter><wait>n<enter><wait>y<enter><wait><enter><wait>",

        # DHCP IP configuration

        # Shell configuration
        "8<enter><wait>",

        # Static network configuration ? => need ip address before ?
        #"route add 0.0.0.0 10.50.10.1",
        #"<enter><wait>",
        
        # Install and configure sudo
        "pkg update",
        "<enter><wait>",
        "pkg install sudo",
        "<enter><wait>",
        "y<enter><wait10s>",
        "echo \"%wheel ALL=(ALL) NOPASSWD: ALL\" >> /usr/local/etc/sudoers",
        "<enter><wait>",
        # "<leftCtrlOn>c<leftCtrlOff>",
        "exit",
        "<enter><wait>",

        # Halt System
        "6<wait><enter>y<enter><wait>"
    ]
    # We don't need to do anything further in packer for now
    # If we did, we would have to install qemu utils to discover IP & configure ssh communicator
    communicator = "none"
}

build {
    // Load iso configuration
   sources = ["source.proxmox.pfsense"]
}