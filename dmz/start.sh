#!/bin/bash
route del default gw 10.5.1.254
route add default gw 10.5.1.1

cat hosts >> /etc/hosts

# PART 4 CONFIGURING THE DMZ
echo "ServerName test.unileon.es" >> /etc/apache2/apache2.conf
/etc/init.d/apache2 start


# PART 5.1 Hardening de SSH
 # Cambiamos el puerto por uno que no sea de sistema
sed -i "s@#Port 22@Port 2222@g" /etc/ssh/sshd_config
# Bloqueamos el acceso a root (Dockerfile)
# Creamos un usuario sin privilegios
useradd -m leon
echo 'leon:leon' | chpasswd
# Bloqueamos el acceso con contraseñas vacías
sed -i "s@#PermitEmptyPasswords no@PermitEmptyPasswords no@g" /etc/ssh/sshd_config
# Permitimos el acceso con clave pública
sed -i "s@#PubkeyAuthentication yes@PubkeyAuthentication yes@g" /etc/ssh/sshd_config
# Establecemos el número máximo de intentos en 2
sed -i "s@#MaxAuthTries 6@MaxAuthTries 2@g" /etc/ssh/sshd_config
# Activamos el MOTD (banner después de un login con éxito)
sed -i "s@PrintMotd no@PrintMotd yes@g" /etc/ssh/sshd_config
# Activamos el banner
sed -i "s@#Banner none@Banner /etc/issue@g" /etc/ssh/sshd_config

# PART 5.2 Configurar HTTPS
a2enmod ssl

a2ensite test.unileon.es.conf       # Añadimos la página HTTP
a2ensite test.unileon.es-ssl.conf   # Añadimos la páginna HTTPS
a2dissite 000-default.conf          # Deshabilitamos la página por defecto de apache

service apache2 reload              # Recargamos la configuración

# El servicio de fail2ban falla si no existe el fichero monitorizado de antemano
touch /var/log/auth.log                 # Nos aseguramos de que el fichero exista
chown syslog.syslog /var/log/auth.log   # Nos aseguramos que supervisord tenga acceso
rm /var/run/fail2ban/fail2ban.sock      # Lo borramos porque a veces se bloquea
service fail2ban restart                # Reiniciamos el servicio de fail2ban

echo "Machine up with ip $(ip add | grep eth0 | tail -n 1 | head --bytes 21 | tail --bytes 12)"
/usr/bin/supervisord
