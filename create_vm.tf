locals {
	vms = {
    "${var.username_42}${var.hostname_postfix}${var.hostname_increment + 0}" = {
			tag		= "standalone"
      ip    = "dhcp"
      public_key = file("~/.ssh/id_rsa.pub")
      users = local.default_users
      rootpassword = random_password.root_password.result
      cf_tun_key  = "eyJhIjoiNDc1NWNiMTMyZWM4Mzk5ODljMWIwYzY4YzE3MTc1MGEiLCJ0IjoiNmU1ZGE5ODItYzhkYS00MGRkLWJlN2UtMjhlYjE4MGY4ZjhkIiwicyI6Ik5qUTFZV0kwTURjdE5EaGhaaTAwTURjeUxUbGxNbUV0WkdNd05qUmxabVppWkROaCJ9"
      disk_encryptionkey = random_string.disk_encryptionkey.result
   }
  }
  default_users = {
    (var.username_42) = {
        password = random_password.user_password.result
        public_key = file("~/.ssh/id_rsa.pub")
        sudo = "ALL=(ALL) NOPASSWD:ALL"
        shell = "/bin/bash"
        groups = "root, 42user"
    }
    "test" = {
        password = "test"
        shell = "/bin/tty"
    }
  }
}
/* 
variable "size_mb" {
    default = 10
}

output "size_in_bytes" {
    value = var.size*pow(2, 20)
} */

resource "libvirt_pool" "debian" {
  name = "debian"
  type = "dir"
  path = "/Users/${var.system_username}/terraform-provider-libvirt-pool-debian"
}

# We fetch the latest debian release image from their mirrors
resource "libvirt_volume" "masterimage" {
  name   = "debian-11-genericcloud-amd64.qcow2"
  pool   = libvirt_pool.debian.name
  source = var.image_name
  format = "qcow2"
}

# We fetch the latest debian release image from their mirrors
resource "libvirt_volume" "workerimage" {
  for_each = local.vms
  name   = "${each.key}-cloudimage.qcow2"
  pool   = libvirt_pool.debian.name
  base_volume_id = libvirt_volume.masterimage.id
  format = "qcow2"
  /* size   = (30800 * 1048576) */
}

# We fetch the latest debian release image from their mirrors
resource "libvirt_volume" "datadisk" {
  for_each = local.vms
  name   = "${each.key}-datadisk.qcow2"
  pool   = libvirt_pool.debian.name
  format = "qcow2"
  size   = 33071248180
}


data "template_file" "user_data" {
  for_each = local.vms
  /* template = file("${path.module}/cloud_init.cfg") */
  template = templatefile(
      
        "${path.module}/templates/cloud_init.tfpl",
        {
        name            = each.key
        host            = each.value
        sshd_config     = file("${path.module}/files/sshd_config")
        }
  )
}

data "template_file" "network_config" {
  for_each = local.vms
  /* template = file("${path.module}/network_config.cfg") */
  template = templatefile(
      
        "${path.module}/templates/network_config.tfpl",
        {
        name            = each.key
        host            = each.value
        }
    )
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "cloud-init" {
  for_each = local.vms 
  name           = "${each.key}-cloudinit.iso"
  user_data      = data.template_file.user_data[each.key].rendered
  network_config = data.template_file.network_config[each.key].rendered
  pool           = libvirt_pool.debian.name 
}


resource "libvirt_volume" "cloudinit" {
  for_each = local.vms
  depends_on     = [libvirt_cloudinit_disk.cloud-init]
  name   = "${each.key}-cloudinit.iso"
  pool   = libvirt_pool.debian.name
  source = "/Users/${var.system_username}/terraform-provider-libvirt-pool-debian/${each.key}-cloudinit.iso"
}



# Create the machine
resource "libvirt_domain" "domain-debian" {
  for_each = local.vms
  name   = each.key
  memory = 1024 * 4
  vcpu   = 6
  arch = "x86_64"
  machine = "q35"
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

  disk {
    volume_id = libvirt_volume.cloudinit[each.key].id
  }
}
