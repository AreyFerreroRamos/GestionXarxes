#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 2 de juny del 2022. Versió: 1.
# Descripció: S'afegeix una regla a les iptables per a configurar el cacti.

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.0.2.25:80
