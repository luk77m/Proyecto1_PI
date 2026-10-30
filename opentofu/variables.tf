variable "libvirt_pool_name" { default = "default" }
variable "imagen_web"        { default = "debian13-base.qcow2" }
variable "imagen_bd"         { default = "ubuntu2604-base.qcow2" }
variable "memoria_web"       { default = 1024 }
variable "memoria_bd"        { default = 1024 }
variable "ssh_pubkey_path"   { default = "~/.ssh/id_ed25519.pub" }
variable "red_nat_cidr"      { default = "192.168.150.0/24" }
variable "ip_datos_web"      { default = "10.10.10.10" }
variable "ip_datos_bd"       { default = "10.10.10.20" }

