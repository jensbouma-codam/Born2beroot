locals {
	vms = [
    {
			name 	= "test${var.username_42}${var.hostname_postfix}${var.hostname_increment + 0}"
			tag		= "standalone"
			user	= "root"
			desc	= ""
		}
    /* {
			name 	= "test${var.username_42}${var.hostname_postfix}${var.hostname_increment + 1}"
			tag		= "standalone"
			user	= "root"
			desc	= ""
		},
    {
			name 	= "test${var.username_42}${var.hostname_postfix}${var.hostname_increment + 2}"
			tag		= "standalone"
			user	= "root"
			desc	= ""
		},
    {
			name 	= "test${var.username_42}${var.hostname_postfix}${var.hostname_increment + 3}"
			tag		= "standalone"
			user	= "root"
			desc	= ""
		},
    {
			name 	= "test${var.username_42}${var.hostname_postfix}${var.hostname_increment + 4}"
			tag		= "standalone"
			user	= "root"
			desc	= ""
		}    */
	]
}

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
  for_each = {for vm in local.vms:  vm.name => vm}
  name   = "${each.value.name}-cloudimage.qcow2"
  pool   = libvirt_pool.debian.name
  base_volume_id = libvirt_volume.masterimage.id
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "cloud-init" {
  for_each = {for vm in local.vms:  vm.name => vm}
  name           = "${each.value.name}-cloudinit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.debian.name
  
}

# We fetch the latest debian release image from their mirrors
resource "libvirt_volume" "cloudinit" {
  for_each = {for vm in local.vms:  vm.name => vm}
  name   = "${each.value.name}-cloudinit"
  pool   = libvirt_pool.debian.name
  source = "/Users/${var.system_username}/terraform-provider-libvirt-pool-debian/${libvirt_cloudinit_disk.cloud-init[each.value.name].name}"
}



# Create the machine
resource "libvirt_domain" "domain-debian" {
  for_each = {for vm in local.vms:  vm.name => vm}
  name   = each.value.name
  memory = 1024
  vcpu   = 2
  arch = "x86_64"
  machine = "q35"

  /* network_interface {
    network_name = "default"
  } */

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  disk {
    volume_id = libvirt_volume.workerimage[each.value.name].id
  }

  disk {
    volume_id = libvirt_volume.cloudinit[each.value.name].id
  }
}

