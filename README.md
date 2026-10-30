# Proyecto 1: Infraestructura como código

Escenario web (Debian 13) + bd (Ubuntu 26.04) creado con OpenTofu y configurado con Ansible.

## Despliegue

    cd opentofu && tofu init && tofu apply
    cd ../ansible && ansible-playbook site.yaml
