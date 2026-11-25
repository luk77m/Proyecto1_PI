resource "libvirt_volume" "web2" {
  name             = "p1-web2.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.imagen_web2
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_cloudinit_disk" "web2" {
  name           = "p1-web2-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = templatefile("${path.module}/cloud-init/user-data.tftpl", { hostname = "web2", usuario = "debian", ssh_key = local.ssh_key })
  network_config = templatefile("${path.module}/cloud-init/network-config.tftpl", { ip_datos = var.ip_datos_web2 })
}

resource "libvirt_domain" "web2" {
  name      = "p1-web2"
  memory    = var.memoria_web2
  vcpu      = 1
  cloudinit = libvirt_cloudinit_disk.web2.id

  network_interface {
    network_id     = libvirt_network.p1_nat.id
    wait_for_lease = true
  }

  network_interface {
    network_id = libvirt_network.p1_datos.id
  }

  disk {
    volume_id = libvirt_volume.web2.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
