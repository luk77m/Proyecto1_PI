resource "libvirt_volume" "nas" {
  name             = "p1-nas.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.imagen_nas
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_cloudinit_disk" "nas" {
  name           = "p1-nas-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = templatefile("${path.module}/cloud-init/user-data.tftpl", { hostname = "nas", usuario = "debian", ssh_key = local.ssh_key })
  network_config = templatefile("${path.module}/cloud-init/network-config.tftpl", { ip_datos = var.ip_datos_nas })
}

resource "libvirt_domain" "nas" {
  name      = "p1-nas"
  memory    = var.memoria_nas
  vcpu      = 1
  cloudinit = libvirt_cloudinit_disk.nas.id

  network_interface {
    network_id     = libvirt_network.p1_nat.id
    wait_for_lease = true
  }

  network_interface {
    network_id = libvirt_network.p1_datos.id
  }

  disk {
    volume_id = libvirt_volume.nas.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
