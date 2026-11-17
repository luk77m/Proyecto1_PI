resource "libvirt_volume" "php" {
  name             = "p1-php.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.imagen_php
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_cloudinit_disk" "php" {
  name           = "p1-php-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = templatefile("${path.module}/cloud-init/user-data.tftpl", { hostname = "php", usuario = "debian", ssh_key = local.ssh_key })
  network_config = templatefile("${path.module}/cloud-init/network-config.tftpl", { ip_datos = var.ip_datos_php })
}

resource "libvirt_domain" "php" {
  name      = "p1-php"
  memory    = var.memoria_php
  vcpu      = 1
  cloudinit = libvirt_cloudinit_disk.php.id

  network_interface {
    network_id     = libvirt_network.p1_nat.id
    wait_for_lease = true
  }

  network_interface {
    network_id = libvirt_network.p1_datos.id
  }

  disk {
    volume_id = libvirt_volume.php.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
