#!/bin/bash

# SCRIPT DE ARRANQUE DEL FIREWALL

function interface_or_exit() {
  interface=$1

  if [ -z "$interface" ]; then
    echo "The interface could not be found"
    exit -1
  fi
}

# Activamos la redirección
echo 1 > /proc/sys/net/ipv4/ip_forward

# Localizamos las interfaces
intranet_interface=$(ip add | grep 10.5.2 -B 2 | head -n 1 | grep -Eo '[A-Za-z0-9]+@' | sed 's/@//')
extranet_interface=$(ip add | grep 10.5.0 -B 2 | head -n 1 | grep -Eo '[A-Za-z0-9]+@' | sed 's/@//')
dmz_interface=$(ip add | grep 10.5.1 -B 2 | head -n 1 | grep -Eo '[A-Za-z0-9]+@' | sed 's/@//')
interface_or_exit $intranet_interface
interface_or_exit $extranet_interface
interface_or_exit $dmz_interface	

printf "Configuration for FIREWALL.\n  |_ interface intranet: '$intranet_interface'\n  |_ interface dmz: '$dmz_interface'\n  |_ interface extranet: '$extranet_interface'\n"

# Establecemos las políticas por defecto
# Funcionar a estilo de "whitelist" siempre es más seguro
iptables -P INPUT DROP
iptables -P FORWARD DROP

iptables -P OUTPUT ACCEPT
iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT

# Aceptamos todo el tráfico de la interfaz de "loopback" (localhost)
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Habilitamos ping desde el router solo (firewall)
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
# No permitimos todos los tipos de ICMP: https://www.frozentux.net/iptables-tutorial/chunkyhtml/a6339.html

# Permitir comunicación dentro de las subredes
# Parece ser que las redes tienen un enlace "físico", de modo que el router no está actuando de switch/hub
# Lo podemos confirmar con tcpdump en modo no promiscuo: tcpdump icmp -i eth2 -n -p
# iptables -A FORWARD -i $intranet_interface -o $intranet_interface -j ACCEPT
# iptables -A FORWARD -i $extranet_interface -o $extranet_interface -j ACCEPT
# iptables -A FORWARD -i $dmz_interface -o $dmz_interface -j ACCEPT

# Habilitamos SSH (redunda con las anteriores políticas)
# iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
# iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# PARTE 3: Comunicaciones desde la red interna
# Permitimos conexiones relacionadas y establecidas para los siguientes protocolos
iptables -A FORWARD -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT
# Esta regla añade la restricción de solo permitir este tipo de tráfico a través de la intranet y extranet
# iptables -A FORWARD -p tcp -i $intranet_interface -o $extranet_interface -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -p tcp -i $intranet_interface -o $extranet_interface -s 10.5.2.0/24 -j ACCEPT
iptables -A FORWARD -p icmp -i $intranet_interface -o $extranet_interface -s 10.5.2.0/24 -j ACCEPT

# Ocultamos la red interna con SNAT
# Todo el tráfico que venga de la red interna y salga por la interfaz externa cambiará su IP de origen
iptables -t nat -A POSTROUTING -s 10.5.2.0/24 -o eth1 -j SNAT --to 10.5.0.1


# PARTE 4: DMZ
# Permitimos el tráfico a la DMZ desde cualquier lugar, pero solo al puerto 80
iptables -A FORWARD -p tcp --dport 80 -o $dmz_interface -j ACCEPT
iptables -A FORWARD -p tcp --dport 443 -o $dmz_interface -j ACCEPT

#PARTE 4 Permitimos el acceso a int1 a dmz1 a través de ssh
iptables -A INPUT -p tcp --dport 22 -s 10.5.2.20 -j ACCEPT
# Podemos comprobarlo lanzando nmap desde ext e int para listar los puertos expuestos

# Permitimos el acceso el acceso a ssh desde int1 (para probar el ban)
iptables -A FORWARD -p tcp --dport 2222 -s 10.5.2.20 -o eth0 -j ACCEPT

# Activamos el banner
sed -i "s@#Banner none@Banner /etc/issue@g" /etc/ssh/sshd_config

echo "Machine up"
cd ~
cat hosts >> /etc/hosts

/usr/sbin/sshd -D
