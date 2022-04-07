#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 6 d'abril del 2022. Versió: 1.
# Descripció: Actualització de l'intern per configurar la xarxa amb un servei DNS.

	#=== En el fitxer /etc/dhcp/dhcpd.conf s'afegiex el domini en l'opció domain-name i la IP del NS en l'opció domain-name-servers. ===#
cp dhcpd.conf /etc/dhcp

	#=== En el fitxer resolv.conf s'afegeix la IP del server. ===#
cp resolv.conf /etc

	#=== Es reinicia el servei. ===#
service isc-dhcp-server restart
