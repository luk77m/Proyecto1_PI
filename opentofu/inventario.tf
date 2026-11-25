resource "local_file" "inventario" {
  filename        = "${path.module}/../ansible/hosts"
  file_permission = "0644"
  content = templatefile("${path.module}/inventario.tftpl", {
    ip_web       = try(libvirt_domain.web.network_interface[0].addresses[0], "")
    ip_bd        = try(libvirt_domain.bd.network_interface[0].addresses[0], "")
    ip_datos_web = var.ip_datos_web
    ip_datos_bd  = var.ip_datos_bd
    ip_nas       = try(libvirt_domain.nas.network_interface[0].addresses[0], "")
    ip_datos_nas = var.ip_datos_nas
    ip_php       = try(libvirt_domain.php.network_interface[0].addresses[0], "")
    ip_datos_php = var.ip_datos_php
    ip_web2       = try(libvirt_domain.web2.network_interface[0].addresses[0], "")
    ip_datos_web2 = var.ip_datos_web2
    ip_lb         = try(libvirt_domain.lb.network_interface[0].addresses[0], "")
    ip_datos_lb   = var.ip_datos_lb
  })
}
