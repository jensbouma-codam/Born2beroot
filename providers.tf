terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "jensbouma"

    workspaces {
      name = "Born2beroot"
    }
  }
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
    tls = {
      source  = "hashicorp/tls"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///session?socket=/Users/${var.system_username}/.cache/libvirt/libvirt-sock"
}
