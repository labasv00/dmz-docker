#!/bin/bash
route del default gw 10.5.2.254
route add default gw 10.5.2.1

# Activamos el banner
sed -i "s@#Banner none@Banner /etc/issue@g" /etc/ssh/sshd_config

cat hosts >> /etc/hosts
echo "Machine up with ip $(ip add | grep eth0 | tail -n 1 | head --bytes 21 | tail --bytes 12 && echo)"
/usr/sbin/sshd -D
