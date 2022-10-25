locals {
	vms = {
    "${var.username_42}${var.hostname_postfix}${var.hostname_increment + 0}" = {
			tag		= "standalone"
      ip    = "dhcp"
      public_key = file("~/.ssh/id_rsa.pub")
      users = local.default_users
    }
    "${var.username_42}${var.hostname_postfix}${var.hostname_increment + 1}" = {
			tag		= "standalone"
      ip    = "dhcp"
      public_key = file("~/.ssh/id_rsa.pub")
      users = local.default_users
    }
    "${var.username_42}${var.hostname_postfix}${var.hostname_increment + 2}" = {
			tag		= "standalone"
      ip    = "dhcp"
      public_key = file("~/.ssh/id_rsa.pub")
      users = local.default_users
    }
  }
  default_users = {
    (var.username_42) = {
        password = random_password.user_password
    }
    "debian"      = {
        password = random_password.root_password
    }
  }
}

output "user_password" {
  value = random_password.root_password
  sensitive = true
}

output "root_password" {
  value = random_password.user_password
  sensitive = true
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
  for_each = local.vms
  name   = "${each.key}-cloudimage.qcow2"
  pool   = libvirt_pool.debian.name
  base_volume_id = libvirt_volume.masterimage.id
  format = "qcow2"
  size   = (30800 * 1048576)
}



data "template_file" "user_data" {
  for_each = local.vms
  /* template = file("${path.module}/cloud_init.cfg") */
  template = templatefile(
      
        "${path.module}/templates/cloud_init.tfpl",
        {
        name            = each.key
        host            = each.value
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
  memory = 1024
  vcpu   = 2
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
    volume_id = libvirt_volume.cloudinit[each.key].id
  }
}

// SSH on port 4242 ONLY! NO ROOT
// Need to know how to setup a account

// UFW Firewall and leave port 4242 open
// Must be active on startup UFW instead of default TO install probally need DNF
/* Hostname must be ending on 42 and beginning with intra username_42 */

/* Need strong password policy */
/* Every 30 Days */
/* Min Dats Allowed defore set to 2 */
/* Pasword at least 10 chars, 1 uppercase 1 lowercase 1 number and not more than 3 consecutive indentical characters */
/* Not include the name of the user */
/* At least 7 characters that are not part of the former password (not for root)*/

/* Change all the passowrds of the users after configuration */

/* Autentication using sudo max 3 attempts */
/* Custom message if an error due wrong password occurs when using Sudo */

/* each sudo action should be archived, both input and output > /var/log/sudo/ */

/* TTY mode enabled */

/* For security reasons too, the paths that can be used by sudo must be restricted.
Example: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin */


/* Need to install and configure sudo following strict rules */
/* In addition to the rood user there sould be one with the intralogin as username */
/* This user beloings to the groups user42 and sudo groups */

// During the defense need to create user and assing it to a group

/* 
Finally, you have to create a simple script called monitoring.sh. It must be devel-
oped in bash.
At server startup, the script will display some information (listed below) on all ter- minals every 10 minutes (take a look at wall). The banner is optional. No error must be visible.
Your script must always be able to display the following information:
• The architecture of your operating system and its kernel version.
• The number of physical processors.
• The number of virtual processors.
• The current available RAM on your server and its utilization rate as a percentage. • The current available memory on your server and its utilization rate as a percentage. • The current utilization rate of your processors as a percentage.
• The date and time of the last reboot.
• Whether LVM is active or not.
• The number of active connections.
• The number of users using the server.
• The IPv4 address of your server and its MAC (Media Access Control) address. • The number of commands executed with the sudo program. */

/* 
During the defense, you will be asked to explain how this script
works.  You will also have to interrupt it without modifying it. ?????????
Take a look at cron. */

// Generate Signature