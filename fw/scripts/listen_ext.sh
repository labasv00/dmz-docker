#!/bin/bash
tcpdump icmp -p -n -i eth1

# -n desactiva la resolución de IP por DNS, 
#    en otras palabras, muestra las IP y no 
#    los nombres (los cuales son identificadores de docker)
