FROM ubuntu/apache2:2.4-22.04_beta

# FICHERO DE APROVISIONAMIENTO DEL CONTENEDOR PARA DMZ

#ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y openssh-server net-tools iputils-ping traceroute nano iproute2 iptables pkg-config nmap tcpdump curl lynx fail2ban rsyslog supervisor

# Descargar la última release de fail2ban (GH)
# RUN cd /tmp && wget https://github.com/fail2ban/fail2ban/releases/download/1.0.2/fail2ban_1.0.2-1.upstream1_all.deb
# RUN apt-get install /tmp/fail2ban_1.0.2-1.upstream1_all.deb -y

# Supervisor para tener varios procesos activos
COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd

# Deshabilitamos el acceso con root (5.1)
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN mkdir /root/.ssh
COPY ./config/motd /etc/motd
COPY ./config/issue /etc/issue

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22

COPY ./apache/index.html /var/www/html/index.html
WORKDIR /root/
COPY ./hosts .

# Parte 5 HTTPS. Copio certificado y clave que he generado con openssh
COPY ./apache/test.unileon.es.key /etc/ssl/private/
COPY ./apache/test.unileon.es.crt /etc/ssl/certs/

# El acceso a el HTTP site nos redirige al HTTPS. Con curl, usaremos -L para seguirlo y -k para no verificar el certificado
# Si no usamos -L veremos un aviso; si usamos -I veremos que el status code es 302
# (3xx son mensajes de redirección https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
COPY ./apache/test.unileon.es.conf /etc/apache2/sites-available/
COPY ./apache/test.unileon.es-ssl.conf /etc/apache2/sites-available/

COPY ./start.sh .
COPY ./scripts ./scripts

# PARTE 5.1 fail2ban
# Copiamos el fichero de configuración de fail2ban
COPY ./config/fail2ban.local /etc/fail2ban/jail.local


RUN chmod +x start.sh ./scripts -R

CMD ["./start.sh"]
