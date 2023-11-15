#!/bin/bash
jail=sshd; fail2ban-client -d | grep -E "($jail.*\b(add)?(logpath|journalmatch)\b)|(\b(start|add)\b.*$jail)"