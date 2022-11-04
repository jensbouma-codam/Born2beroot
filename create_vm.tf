locals {
	vms = {
    "${var.username_42}${var.hostname_postfix}${var.hostname_increment + 0}" = {
			tag		= "standalone"
      ip    = "dhcp"
      public_key = file("~/.ssh/id_rsa.pub")
      users = local.default_users
      groups = local.default_groups
      rootpassword = random_password.root_password.result
      cf_tun_key  = "eyJhIjoiNDc1NWNiMTMyZWM4Mzk5ODljMWIwYzY4YzE3MTc1MGEiLCJ0IjoiNmU1ZGE5ODItYzhkYS00MGRkLWJlN2UtMjhlYjE4MGY4ZjhkIiwicyI6Ik5qUTFZV0kwTURjdE5EaGhaaTAwTURjeUxUbGxNbUV0WkdNd05qUmxabVppWkROaCJ9"
      disk_encryptionkey = random_string.disk_encryptionkey.result
      partitions = local.partitions
   }
  }
  default_groups = [
    "42user"
  ]
  default_users = {
    (var.username_42) = {
        password = random_password.user_password.result
        public_key = file("~/.ssh/id_rsa.pub")
        /* sudo = "ALL=(ALL) NOPASSWD:ALL" For no password SUDO*/
        sudo = "ALL=(ALL) ALL"
        shell = "/bin/bash"
        groups = "root, 42user"
        /* shell = "/bin/tty" */
    }
    "test" = {
        password = "test"
        shell = "/bin/tty"
    }
  }
  partitions = {
    vdb = {
      1 = {
        size = "+500M"
        name = "boot"
        boot = true
        mountpoint = "/boot"
      }
      2 = {
        size = "+1K"
      }
      3 = {
        name = "crypt"
        mapper = "crypt"
        lvmname = "LVMGroup"
        lvm = {
          "root" = {
            size = "10G"
            mountpoint = ""
          }
          "swap" = {
            size = "2.3GB"
            swap = true
          }
          "home" = {
            size = "5GB"
            mountpoint = "/home"
          }
          "var" = {
            size = "3GB"
            mountpoint = "/var"
          }
          "srv" = {
            size = "3GB"
            mountpoint = "/srv"
          }
          "tmp" = {
            size = "3GB"
            mountpoint = "/tmp"
          }
          "var--log" = {
            size = "3.99GB"
            mountpoint = "/var/log"
          }
        }
      }
    }
  }
}

/* Create cloud-init userdata from template file */
data "template_file" "user_data" {
  for_each = local.vms
  template = templatefile(
      
        "${path.module}/templates/cloud_init.tfpl",
        {
        name            = each.key
        host            = each.value
        }
  )
}

/* Create cloud-init network-config from template file */
data "template_file" "network_config" {
  for_each = local.vms
  template = templatefile(
      
        "${path.module}/templates/network_config.tfpl",
        {
        name            = each.key
        host            = each.value
        }
    )
}

/* Create cloud-init image for every VM */
resource "libvirt_cloudinit_disk" "cloud-init" {
  for_each = local.vms 
  name           = "${each.key}-cloudinit.iso"
  user_data      = data.template_file.user_data[each.key].rendered
  network_config = data.template_file.network_config[each.key].rendered
  pool           = libvirt_pool.debian.name 
}


/* Create worker image for each VM from main image */
resource "libvirt_volume" "workerimage" {
  for_each = local.vms
  name   = "${each.key}-cloudimage.qcow2"
  pool   = libvirt_pool.debian.name
  base_volume_id = libvirt_volume.masterimage.id
  format = "qcow2"
}

/* Create datadisk for each VM */
resource "libvirt_volume" "datadisk" {
  for_each = local.vms
  name   = "${each.key}-datadisk.qcow2"
  pool   = libvirt_pool.debian.name
  format = "qcow2"
  size   = 33071248180
}

/* Create each VM */
resource "libvirt_domain" "domain-debian" {
  depends_on = [
    libvirt_cloudinit_disk.cloud-init
  ]
  for_each = local.vms
  name   = each.key
  memory = 4096
  vcpu   = 2
  arch = "x86_64"
  machine = "pc"
  network_interface {
    
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  disk {
    volume_id = libvirt_volume.workerimage[each.key].id
  }

  disk {
    volume_id = libvirt_volume.datadisk[each.key].id
  }

  /* cloudinit = libvirt_cloudinit_disk.cloud-init[each.key].id */
}
