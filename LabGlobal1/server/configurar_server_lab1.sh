#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 15 de març del 2022. Versió: 2.
# Descripció: Es fan totes les configuracions pertinent per a que la NIC del server sigui funcional.

	#=== Es configura la interficie eth0 de forma estàtica usant el paquet ifupdown. ===#
ifdown eth0
# Cal afegir les línies
#	'auto lo
#	iface lo inet loopback
#
#	auto eth0
#	iface eth0 inet static
#		address 192.0.2.24
#		network 192.0.2.16
#		netmask 255.255.255.240
#		broadcast 192.0.2.31
#		gateway 192.0.2.17'
# al fitxer interfaces.
cp -p interfaces /etc/network
ifup eth0
# Si es vol comprovar que l'adreça 192.0.2.24 s'ha afegit a la interficie eth0, es poden executar les comanda 'ip -c a' (general) o 'ip -f inet address show eth0' (específica).
# Si es vol validar la connexió del router amb el server, es pot executar la comanda 'ping 192.0.2.24' des del router.

	#=== S'afegeix el nom del router i la seva IP al fitxer /etc/hosts del server. Això permet establir una connexió amb el router utilitzant el nom en lloc de l'adreça IP (No hi ha DNS). ===#
# Cal afegir la línia '192.0.2.17	router' al fitxer hosts.
cp -p hosts /etc
# Si es vol validar la connexió del server amb el router utilitzant el seu nom, s'executa la comanda 'ping router' des del propi server.
