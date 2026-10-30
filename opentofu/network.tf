resource "libvirt_network" "p1_nat" {
  name      = "p1-nat"
  mode      = "nat"
  addresses = [var.red_nat_cidr]
  dhcp { enabled = true }
  autostart = true
}

resource "libvirt_network" "p1_datos" {
  name      = "p1-datos"
  mode      = "none"   # sin addresses: el anfitrión no tiene IP en ella
  autostart = true
}
