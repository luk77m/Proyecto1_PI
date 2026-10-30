terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}
