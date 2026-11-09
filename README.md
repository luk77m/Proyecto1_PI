# Proyecto 1: Infraestructura como código

Despliegue de un libro de visitas en PHP con MariaDB
([guestbook_php](https://github.com/josedom24/guestbook_php)) sobre un escenario creado con
**OpenTofu** (libvirt/KVM) y configurado con **Ansible**.

Autor: Luca Matonte Antúnez · Proyecto Intermodular · 2º ASIR · IES Gonzalo Nazareno

## Escenario

### Máquinas

- **p1-web** (Debian 13): servidor web con Apache y PHP, virtual host `www.lucamatonte.org`.
  - ens3: red NAT, IP por DHCP.
  - ens4: red de datos, `10.10.10.10`.
- **p1-bd** (Ubuntu 26.04): servidor de base de datos con MariaDB, que escucha solo en la red de datos.
  - ens3: red NAT, IP por DHCP.
  - ens4: red de datos, `10.10.10.20`.
- **p1-nas** (Debian 13): servidor NFS que guarda los ficheros de la aplicación y su `config.php`, y los exporta en solo lectura a la red de datos.
  - ens3: red NAT, IP por DHCP.
  - ens4: red de datos, `10.10.10.30`.

### Redes

- **p1-nat** (`192.168.150.0/24`): red NAT con DHCP. Desde ella se accede al servidor web y las máquinas salen a internet.
- **p1-datos**: red muy aislada, sin IP en el anfitrión, por la que web y bd se comunican.

El usuario de la base de datos solo puede conectarse desde `10.10.10.10`.
Los ficheros de la aplicación viven en el NAS: `web` los monta por NFS (solo lectura) en `/var/www/guestbook_php-main`, así que se puede recrear `web` sin volver a descargar la aplicación.

## Requisitos

- OpenTofu y libvirt (`qemu:///system`).
- Ansible con las colecciones `community.mysql` y `community.general`
  (incluidas en el paquete `ansible` completo; si no:
  `ansible-galaxy collection install community.mysql community.general`).
- Imágenes cloud en el pool `default` de libvirt:
  - `debian13-base.qcow2` (Debian 13)
  - `ubuntu2604-base.qcow2` (Ubuntu 26.04)
- Clave SSH pública en `~/.ssh/id_ed25519.pub` (se cambia con la variable `ssh_pubkey_path`).

## Despliegue

Con el repositorio recién clonado:

```bash
cd opentofu
tofu init        # solo la primera vez
tofu apply

cd ../ansible
ansible-playbook site.yaml
```

OpenTofu genera el inventario `ansible/hosts` con las IP de las máquinas.

Para acceder a la aplicación, añade a `/etc/hosts` la IP NAT de web (se ve con `tofu output`):

```
<IP_NAT_web> www.lucamatonte.org
```

Y abre `http://www.lucamatonte.org`.

Para eliminar el escenario: `tofu destroy` en `opentofu/`.

## Estructura

```
opentofu/
├── provider.tf          # providers libvirt y local
├── variables.tf         # imágenes, memoria, red e IP de datos
├── network.tf           # red NAT y red de datos
├── cloudinit.tf         # discos cloud-init de web y bd
├── main.tf              # volúmenes y máquinas web y bd
├── nas.tf               # volumen, cloud-init y máquina del NAS
├── output.tf            # IP de las máquinas
├── inventario.tf        # genera ../ansible/hosts
├── inventario.tftpl
└── cloud-init/          # plantillas user-data y network-config
ansible/
├── ansible.cfg
├── site.yaml
├── group_vars/          # variables (BD, aplicación, dominio)
└── roles/
    ├── commons/         # actualiza el sistema y paquetes comunes
    ├── bd/              # MariaDB, base de datos, usuario y tablas
    ├── nas/             # servidor NFS: descarga la aplicación y la exporta
    └── web/             # Apache, PHP, mod_rewrite, montaje NFS y virtual host

```

## Idempotencia

Una segunda ejecución de `ansible-playbook site.yaml` termina con `changed=0`:

- Las tablas solo se importan si la base de datos está vacía.
- La aplicación solo se descarga si no está ya descomprimida.
- Los servicios solo se reinician mediante handlers cuando cambia su configuración.
