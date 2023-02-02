/* Create machine pool */
resource "libvirt_pool" "debian" {
  name = "debian"
  type = "dir"
  path = "/Users/${var.system_username}/terraform-provider-libvirt-pool-debian"
}

/* Get the image and make it a master image */
/* resource "libvirt_volume" "masterimage" {
  name   = "debian-11-genericcloud-amd64.qcow2"
  pool   = libvirt_pool.debian.name
  source = var.image_name
  format = "qcow2"
} */

/* Get the image and make it a master image */
/* resource "libvirt_volume" "masterimage" {
  name   = "debian-11-base-image-v1.qcow2"
  pool   = libvirt_pool.debian.name
  source = "${path.module}/templates/base_image_v1.qcow2"
  format = "qcow2"
} */

resource "libvirt_network" "kube_network" {
  # the name used by libvirt
  name = "default"

  # mode can be: "nat" (default), "none", "route", "open", "bridge"
  mode = "bridge"
  
  addresses = ["192.168.105.0/24"]

  autostart = true

  bridge = "br100"
}

