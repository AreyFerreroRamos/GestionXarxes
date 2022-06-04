#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 30 de març del 2022. Versió: 2.
# Descripció: Es fan totes les configuracions pertinents per a proporcionar el servei DHCP a la xarxa intranet.

	#=== Es configura la interficie eth0 de forma estàtica usant el paquet ifupdown. ===#
ifdown eth0
# Cal afegir les línies
#	'auto lo
#	iface lo inet loopback
#
#	auto eth0
#	iface eth0 inet static
#		address 172.22.2.126
#		network 172.22.2.0
#		netmask 255.255.255.128
#		broadcast 172.22.2.127
#		gateway 172.22.2.1'
# al fitxer interfaces.
cp -p interfaces /etc/network
ifup eth0
# Si es vol comprovar si l'adreça 172.22.2.126 s'ha afegit a la interficie eth0, es poden executar les comandes 'ip -c a' (general) o 'ip -f inet address show eth0' (específica).
# Si es vol validar la connexió del router amb l'intern, es pot executar la comanda 'ping 172.22.2.126' des del router.
# Si es vol validar la connexió del server amb l'intern, es pot executar la comanda 'ping 172.22.2.126' des del server.

	#=== Es resolen les IPs del router i del server a un nom concret especificat en el fitxer /etc/hosts de l'intern. Això permet establir una connexió amb les màquines utilitzant el nom en lloc de l'adreça 		IP (No hi ha DNS). ===#
# Cal afegir la línia '172.22.2.1	router' al fitxer hosts.
# Cal afegir la línia '192.0.2.24	server' al fitxer hosts.
cp -p hosts /etc
# Si es vol validar la connexió de l'intern amb el router utilitzant el nom assignat, es pot executar la comanda 'ping router' des del propi intern.
# Si es vol validar la connexió de l'intern amb el server utilitzant el nom assignat, es pot executar la comanda 'ping server' des del propi intern.

	#=== Es comprova si està instal·lat el paquet isc-dhcp-server i, en cas negatiu, s'instal·la i es comprova si la instal·lació ha estat correcta. ===#
service isc-dhcp-server status
if [ $(echo $?) -eq 4 ]
then
	echo -e "\nINSTAL·LANT ISC-DHCP-SERVER\n"
	apt install isc-dhcp-server
	echo -e "\nESTAT ISC-DHCP-SERVER\n"
	service isc-dhcp-server status
fi

	#=== Es configura el fitxer /etc/default/isc-dhcp-server per a que escolti la eth0. ===#
# Cal afegir la línia 'INTERFACESv4=\"eth0\"\nINTERFACESv6=\"\"' al fitxer isc-dhcp-server.
cp -p isc-dhcp-server /etc/default
	
	#=== Es configura una subnet (amb les IPs de la nostra classe B) al fitxer /etc/dhcp/dhcpd.conf. Després es reengega el servei. ===#
# Cal afegir les línies
#	'subnet 172.22.2.0 netmask 255.255.255.128 {
#		range 172.22.2.1 172.22.2.126;
#		option subnet-mask 255.255.255.128;
#		option broadcast-address 172.22.2.127;
#		option routers 172.22.2.1;
#		option domain-name-servers 192.0.2.24;
#		option domain-name "intranet.gsx"
#	}'
# al fitxer dhcpd.conf. El servidor de noms és el router.
cp -p dhcpd.conf /etc/dhcp

service isc-dhcp-server restart
service isc-dhcp-server status
# Si es vol comprovar l'estat del servei isc-dhcp-server, es poden executar les comandes 'service isc-dhcp-server status' o 'journalctl --unit isc-dhcp-server'. La segona comanda llista tot l'historial d'execucions del servei, cosa que permet detectar els errors que s'hagin produït durant la configuració d'aquest.
