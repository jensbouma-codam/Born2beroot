
resource "libvirt_network" "kube_network" {
  # the name used by libvirt
  name = "default"

  # mode can be: "nat" (default), "none", "route", "open", "bridge"
  mode = "bridge"
  
  addresses = ["192.168.105.0/24"]

  autostart = true

  bridge = "br100"
}

