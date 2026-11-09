output "maquinas" {
  value = {
    web = {
      nat   = try(libvirt_domain.web.network_interface[0].addresses[0], "No disponible")
      datos = var.ip_datos_web
    }
    bd = {
      nat   = try(libvirt_domain.bd.network_interface[0].addresses[0], "No disponible")
      datos = var.ip_datos_bd
    }
    nas = {
      nat   = try(libvirt_domain.nas.network_interface[0].addresses[0], "No disponible")
      datos = var.ip_datos_nas
    }
  }
}
