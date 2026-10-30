#Discos: clones ligeros de las imágenes base

resource "libvirt_volume" "web" {
  name             = "p1-web.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.imagen_web
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_volume" "bd" {
  name             = "p1-bd.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.imagen_bd
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

#Máquina web (Debian 13)

resource "libvirt_domain" "web" {
  name      = "p1-web"
  memory    = var.memoria_web
  vcpu      = 1
  cloudinit = libvirt_cloudinit_disk.web.id

  # ens3: red NAT con DHCP
  network_interface {
    network_id     = libvirt_network.p1_nat.id
    wait_for_lease = true
  }

  # ens4: red de datos, IP estática (sin DHCP, por eso sin wait_for_lease)
  network_interface {
    network_id = libvirt_network.p1_datos.id
  }

  disk {
    volume_id = libvirt_volume.web.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

# Máquina bd (Ubuntu 26.04) 

resource "libvirt_domain" "bd" {
  name      = "p1-bd"
  memory    = var.memoria_bd
  vcpu      = 1
  cloudinit = libvirt_cloudinit_disk.bd.id

  network_interface {
    network_id     = libvirt_network.p1_nat.id
    wait_for_lease = true
  }

  network_interface {
    network_id = libvirt_network.p1_datos.id
  }

  disk {
    volume_id = libvirt_volume.bd.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
