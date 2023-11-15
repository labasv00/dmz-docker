# Configuración de una DMZ
Práctica 1 para la asignatura de Sistemas Confiables


## Estructura del proyecto

El proyecto está dividido en cinco directorios y un fichero docker-compose.

En el docker-compose encontraremos toda la información básica para levantar tanto los contenedores como las redes, sin ninguna configuración especial.

En cada uno de los directorios encontraremos la imagen de docker de cada uno de los dispositivos de la red (a excepción de la intranet, que se usa la misma imagen usa para dos dispositivos). Estos directorios contienen el script de entrada, el Dockerfile, ficheros de configuración o scripts que se han utilizado para realizar pruebas.

Podemos ver que hay cinco imágenes en total:
* `dmz`: La zona desmilitarizada
* `extranet`: los dispositivos externos a la red
* `fw`: el encaminador que actúa de cortafuegos
* `intranet`: los dispositivos de la red interna
* `intranetvpn`: (sin casi empezar) el servicio de VPN

## Ejecución

Para iniciar los contenedores y ejecutarlos simplemente se deben ejecutar los siguientes comandos:
```bash
# Para levantar los contenedores
docker-compose up --build

# Entramos por SSH
docker-compose exec fw bash
```

## Imágenes

### DMZ
La zona desmilitarizada cuenta con lo siguiente:

* `apache`: directorio con la configuración y ficheros para HTTP y HTTPS
* `config`: directorio con la configuración de *fail2ban*, *supervisord*, el *banner* y el *message of the day*
* `scripts`: contiene scripts de prueba. Hay algunos interesantes como *show_jails*
* `hosts`: un fichero que se añade al final de `/etc/hosts` para la resolución de nombres de la red

El fichero de arranque está lo suficientemente comentado como para entenderse. Lo más notable probablemente sea la configuración de *fail2ban* (que me tomó más horas de las que me gustaría por el backend), y la configuración de *supervisord* y *rsyslog*. 

También podemos ver varias líneas de `sed` con la configuración del daemon de SSH y la de Apache Web Server en HTTPS.

### Firewall

El firewall no ofrece ningún servicio en especial, sino que se enfoca en la configuración de las reglas de iptables que podemos encontrar en el script de inicio. Como iptables no es persistente, tenemos que recurrir a añadir las reglas de esta manera, aunque existen alternativas.

### Extranet

Lo más interesante probablemente sea el servicio de HTTP en Apache Web Server, que en realidad viene de una imagen de la comunidad.

### Intranet

Nada especialmente relevante.

## `ip route`, `ip address`

### Firewall

```bash
root@d580889252eb:~# ip add
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
271: eth0@if272: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:0a:05:01:01 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.5.1.1/24 brd 10.5.1.255 scope global eth0
       valid_lft forever preferred_lft forever
273: eth1@if274: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:0a:05:00:01 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.5.0.1/24 brd 10.5.0.255 scope global eth1
       valid_lft forever preferred_lft forever
275: eth2@if276: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:0a:05:02:01 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.5.2.1/24 brd 10.5.2.255 scope global eth2
       valid_lft forever preferred_lft forever
```

```bash
root@d580889252eb:~# ip route
default via 10.5.1.254 dev eth0 
10.5.0.0/24 dev eth1 proto kernel scope link src 10.5.0.1 
10.5.1.0/24 dev eth0 proto kernel scope link src 10.5.1.1 
10.5.2.0/24 dev eth2 proto kernel scope link src 10.5.2.1
```

### Intranet

```bash
root@705d303f4849:~# ip add
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
283: eth0@if284: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:0a:05:02:14 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.5.2.20/24 brd 10.5.2.255 scope global eth0
       valid_lft forever preferred_lft forever
```

```bash
root@705d303f4849:~# ip route
default via 10.5.2.1 dev eth0 
10.5.2.0/24 dev eth0 proto kernel scope link src 10.5.2.20
```

### Extranet
```bash
root@bd8c8596777e:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
281: eth0@if282: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:0a:05:00:14 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.5.0.20/24 brd 10.5.0.255 scope global eth0
       valid_lft forever preferred_lft forever
```

```bash
root@bd8c8596777e:~# ip route
default via 10.5.0.1 dev eth0 
10.5.0.0/24 dev eth0 proto kernel scope link src 10.5.0.20
```

### DMZ
```bash
root@534b6ebbf403:~# ip add
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
277: eth0@if278: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:0a:05:01:14 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.5.1.20/24 brd 10.5.1.255 scope global eth0
       valid_lft forever preferred_lft forever
```

```bash
root@534b6ebbf403:~# ip route
default via 10.5.1.1 dev eth0 
10.5.1.0/24 dev eth0 proto kernel scope link src 10.5.1.20
```