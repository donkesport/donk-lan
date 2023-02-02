# Proxmox Provider
# ---
# Initial Provider Configuration for Proxmox

terraform {

    required_version = ">= 0.13.0"

    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "2.9.11"
        }
    }
}

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

variable "vmid" {
    type = number
}

variable "hostnames" {
    type = list(string)
}

variable "ips" {
    type = list(string)
}

variable "bridges" {
    type = list(string)
}

variable "rams" {
    type = list(number)
}

variable "gateways" {
    type = list(string)
}

variable "node" {
    type = string
}

variable "user" {
    type = string
}

variable "dns_server" {
    type = string
}


variable "ssh_keys" {
	type = map
     default = {
       pub  = "~/.ssh/id_ed25519_ansible.pub"
       priv = "~/.ssh/id_ed25519_ansible"
     }
}

provider "proxmox" {

    pm_api_url = var.proxmox_api_url
    pm_api_token_id = var.proxmox_api_token_id
    pm_api_token_secret = var.proxmox_api_token_secret

    # (Optional) Skip TLS Verification
    pm_tls_insecure = true
    pm_debug = true

}