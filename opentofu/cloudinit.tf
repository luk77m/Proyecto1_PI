locals {
  ssh_key = trimspace(file(pathexpand(var.ssh_pubkey_path)))
}

resource "libvirt_cloudinit_disk" "web" {
  name           = "p1-web-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = templatefile("${path.module}/cloud-init/user-data.tftpl", { hostname = "web", usuario = "debian", ssh_key = local.ssh_key })
  network_config = templatefile("${path.module}/cloud-init/network-config.tftpl", { ip_datos = var.ip_datos_web })
}

resource "libvirt_cloudinit_disk" "bd" {
  name           = "p1-bd-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = templatefile("${path.module}/cloud-init/user-data.tftpl", { hostname = "bd", usuario = "ubuntu", ssh_key = local.ssh_key })
  network_config = templatefile("${path.module}/cloud-init/network-config.tftpl", { ip_datos = var.ip_datos_bd })
}
