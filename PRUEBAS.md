# Informe de pruebas

Todas las órdenes se ejecutan en mi equipo, en el directorio `ansible/`, con el
escenario levantado desde cero.

## Modificación 1: NAS con NFS

Qué demuestra: los ficheros de la aplicación viven en una máquina aparte y todas
las demás los ven de forma compartida.

### 1.1. Las webs y php montan la aplicación del NAS

* Dónde: en mi equipo
* Orden:

  ```
  ansible servidores_web:servidores_php -a "findmnt -n -o SOURCE,FSTYPE,OPTIONS /var/www/guestbook_php-main"
  ```

* Resultado esperado: las tres máquinas (`web`, `web2` y `php`) responden
  `CHANGED | rc=0` y una línea que empieza por
  `10.10.10.30:/srv/nfs/guestbook_php-main nfs4 ro,`.

### 1.2. Un fichero creado en el NAS aparece al instante en las demás

* Dónde: en mi equipo
* Orden:

  ```
  ansible nas -b -a "touch /srv/nfs/guestbook_php-main/prueba-nfs"
  ansible servidores_web:servidores_php -a "ls /var/www/guestbook_php-main/prueba-nfs"
  ansible nas -b -a "rm /srv/nfs/guestbook_php-main/prueba-nfs"
  ```

* Resultado esperado: `web`, `web2` y `php` responden `CHANGED | rc=0` con la
  línea `/var/www/guestbook_php-main/prueba-nfs`. La aplicación está en un único
  sitio compartido, no copiada en cada máquina.

## Modificación 2: PHP-FPM en otra máquina

Qué demuestra: el PHP se ejecuta en la máquina `php` y la web depende de ella.

### 2.1. PHP-FPM escucha en la red de datos

* Dónde: en mi equipo
* Orden:

  ```
  ansible php -b -m shell -a "ss -tln | grep 9000"
  ```

* Resultado esperado: una línea `LISTEN` con `10.10.10.40:9000`.

### 2.2. Sin PHP-FPM la web da 503 y al arrancarlo vuelve el 200

* Dónde: en mi equipo
* Orden:

  ```
  LB=$(awk '/^lb /{print $2}' hosts | cut -d= -f2)
  ansible php -b -a "systemctl stop php8.4-fpm"
  curl -s -o /dev/null -w "%{http_code}\n" -H "Host: www.lucamatonte.org" http://$LB
  ansible php -b -a "systemctl start php8.4-fpm"
  curl -s -o /dev/null -w "%{http_code}\n" -H "Host: www.lucamatonte.org" http://$LB
  ```

* Resultado esperado: el primer `curl` imprime `503` y el segundo `200`. Apache
  no ejecuta PHP por sí mismo: depende de la máquina `php`.

## Modificación 3: dos servidores web con HAProxy

Qué demuestra: las peticiones se reparten entre las dos webs y la aplicación
sigue funcionando aunque se caiga una.

### 3.1. HAProxy reparte entre las dos webs

* Dónde: en mi equipo
* Orden:

  ```
  LB=$(awk '/^lb /{print $2}' hosts | cut -d= -f2)
  for i in 1 2 3 4; do curl -sI -H "Host: www.lucamatonte.org" http://$LB | grep -i x-servidor; done
  ```

* Resultado esperado: cuatro líneas que alternan `x-servidor: web` y
  `x-servidor: web2` (HAProxy devuelve el nombre de la cabecera en minúsculas).

### 3.2. Si se cae una web, la aplicación sigue

* Dónde: en mi equipo
* Orden:

  ```
  LB=$(awk '/^lb /{print $2}' hosts | cut -d= -f2)
  ansible web2 -b -a "systemctl stop apache2"
  for i in 1 2 3 4; do curl -sI -H "Host: www.lucamatonte.org" http://$LB | grep -i -E "^HTTP|x-servidor"; done
  ansible web2 -b -a "systemctl start apache2"
  ```

* Resultado esperado: las cuatro respuestas son `HTTP/1.1 200 OK` con
  `x-servidor: web`; ninguna es un `502` ni un `503`.
