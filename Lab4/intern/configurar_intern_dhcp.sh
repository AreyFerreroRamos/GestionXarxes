#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 30 de març del 2022. Versió: 1.
# Descripció: Es fan totes les configuracions pertinents per a proporcionar el servei DHCP a la xarxa intranet.

	#=== Es configura la interficie eth0 de forma estàtica usant el paquet ifupdown. ===#
ifdown eth0
echo -e "\nauto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet static\n\taddress 172.22.2.126\n\tnetwork 172.22.2.0\n\tnetmask 255.255.255.128\n\tbroadcast 172.22.2.127\n\tgateway 172.22.2.1" > /etc/network/interfaces
ifup eth0
# S'executa la comanda 'ip -c a' o la comanda 'ip -f inet address show eth0' (més específica) per comprovar si l'adreça 172.22.2.126 s'ha afegit a la interficie eth0. Si hi apareix és que s'ha afegit.
# S'executa la comanda 'ping 172.22.2.126' des del router per comprovar que es pot establir una connexió amb l'intern.

	#=== Es resolen les IPs del router i del server a un nom concret especificat en el fitxer /etc/hosts de l'intern. Això permet establir una connexió amb les màquines utilitzant el nom en lloc de l'adreça 		IP (No hi ha DNS). ===#
echo -e "172.22.2.1\trouter" >> /etc/hosts
echo -e "192.0.2.24\tserver" >> /etc/hosts
# S'executa la comanda 'ping router' per comprovar que es pot establir una connexió amb el router utilitzant el nom assignat.
# S'executa la comanda 'ping server' per comprovar que es pot establir una connexió amb el server utilitzant el nom assignat.

	#=== Es comprova si està instal·lat el paquet rsyslog i, en cas negatiu, s'instal·la i es comprova si la instal·lació ha estat correcta. ===#
service rsyslog status
if [ $(echo $?) -eq 4 ]
then
	echo -e "\nINSTAL·LANT RSYSLOG\n"
	apt install rsyslog
	echo -e "\nESTAT RSYSLOG\n"
	service rsyslog status
fi

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
#echo -e "INTERFACESv4=\"eth0\"\nINTERFACESv6=\"\""

	#=== Es configura una subnet (amb les IPs de la nostra classe B) al fitxer /etc/dhcp/dhcpd.conf. Després es reengega el servei. ===#
echo -e "\n\nsubnet 172.22.2.0 netmask 255.255.255.128 {\n\trange 172.22.2.1 172.22.2.126;\n\toption subnet-mask 255.255.255.128;\n\toption broadcast-address 172.22.2.127;\n\toption routers 172.22.2.1;\n\toption domain-name-servers 172.22.2.1;\n}" >> /etc/dhcp/dhcpd.conf		# El servidor de noms és el router.
service isc-dhcp-server restart
# S'executa la comanda 'journalctl --unit isc-dhcp-server' per comprovar l'estat del servei isc-dhcp-server. La comanda llista tot l'historial d'execucions del servei, cosa que permet detectar els errors que s' hagin produït durant la configuració d'aquest.
	
	#=== Es comprova si està instal·lat el servei ssh i, en cas negatiu, s'instal·la i es comprova si l'instal·lació ha estat correcta. Després s'activa i es reengega el servei. ===#
dpkg -s openssh-server
if [ $(echo $?) -eq 1 ]
then
	echo -e "\nINSTAL·LACIÓ OPENSSH-SERVER\n"
	apt install -y openssh-server
	echo -e "\nESTAT OPENSSH-SERVER\n"
	service ssh status
	if [ $(echo $?) -eq 4 ]
	then
		exit 1
	fi
fi
echo -e "PermitRootLogin yes" >> /etc/ssh/sshd_config
service ssh restart
# S'executa la comanda 'ssh root@router' per comprovar que es poden crear arxius al router des de l'intern.
# S'executa la comanda 'ssh -rvp intern root@router:/home/milax/' per passar arxius de l'intern al router.
