terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "jensbouma"

    workspaces {
      name = "Born2beroot"
    }
  }
  /* required_version = ">= 0.12" */
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

resource "random_password" "user_password" {
  length           = 16
  special          = false
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1  
  /* override_special = "!#$%&*()-_=+[]{}<>:?" */
}

resource "random_password" "root_password" {
  length           = 16
  special          = false
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1  
  /* override_special = "!#$%&*()-_=+[]{}<>:?" */
}

resource "random_string" "disk_encryptionkey" {
  length           = 16
  special          = false
  /* override_special = "/@£$" */
}

output "user_password" {
  value = random_password.root_password
  sensitive = true
}

output "root_password" {
  value = random_password.user_password
  sensitive = true
}

output "host_disk_encryptionkey" {
  value = random_string.disk_encryptionkey
  sensitive = true
}

provider "libvirt" {
  uri = "qemu:///session?socket=/Users/${var.system_username}/.cache/libvirt/libvirt-sock"
  /* uri = "qemu:///session?socket=/opt/homebrew/var/run/libvirt/libvirt-sock" */
  /* uri = "qemu:///system" */
}
