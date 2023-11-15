#!/bin/bash

IP=$1
fail2ban-client set sshd banip $IP
