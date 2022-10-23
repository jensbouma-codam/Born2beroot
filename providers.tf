terraform {
  /* required_version = ">= 0.12" */
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///session?socket=/Users/${var.system_username}/.cache/libvirt/libvirt-sock"
  /* uri = "qemu:///session?socket=/opt/homebrew/var/run/libvirt/libvirt-sock" */
  /* uri = "qemu:///system" */
}

/* uri = "qemu+ssh://user@FQDN/system?keyfile=/home/david/.ssh/id_rsa&sshauth=privkey" */
