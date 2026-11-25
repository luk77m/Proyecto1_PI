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
    php = {
      nat   = try(libvirt_domain.php.network_interface[0].addresses[0], "No disponible")
      datos = var.ip_datos_php
    }
    web2 = {
      nat   = try(libvirt_domain.web2.network_interface[0].addresses[0], "No disponible")
      datos = var.ip_datos_web2
    }
    lb = {
      nat   = try(libvirt_domain.lb.network_interface[0].addresses[0], "No disponible")
      datos = var.ip_datos_lb
    }
  }
}
