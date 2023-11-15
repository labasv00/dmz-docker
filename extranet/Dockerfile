FROM ubuntu/apache2:2.4-22.04_beta

# FICHERO DE APROVISIONAMIENTO DEL CONTENEDOR DE EXTRANET

RUN apt-get update && apt-get install -y openssh-server net-tools iputils-ping nano iproute2 iptables pkg-config nmap tcpdump curl lynx
#RUN apt-get install -y apache2

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN mkdir /root/.ssh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22

COPY ./index.html /var/www/html/index.html

WORKDIR /root/
COPY ./hosts .

COPY ./start.sh .
COPY ./scripts ./scripts

COPY ./issue /etc/issue

RUN chmod +x start.sh scripts

CMD ["./start.sh"]
