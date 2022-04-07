#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 15 de març del 2022. Versió: 1.
# Descripció: Es fan totes les configuracions pertinent per a que la NIC del server sigui funcional.

	#=== Es configura la interficie eth0 de forma estàtica usant el paquet ifupdown. ===#
ifdown eth0
echo -e "auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet static\n\taddress 192.0.2.24\n\tnetwork 192.0.2.16\n\tnetmask 255.255.255.240\n\tbroadcast 192.0.2.31\n\tgateway 192.0.2.17" > /etc/network/interfaces
ifup eth0
# S'executa la comanda 'ip -c a' o la comanda 'ip -f inet address show eth0' (més específica) per comprovar si l'adreça 192.0.2.24 s'ha afegit a la interficie eth0. Si hi apareix es que s'ha afegit.
# S'executa la comanda 'ping 192.0.2.24' des del router per comprovar si es pot establir una connexió amb el server.

	#=== S'afegeix el nom del router i la seva IP al fitxer /etc/hosts del server. Això permet establir una connexió amb el router utilitzant el nom en lloc de l'adreça IP (No hi ha DNS). ===#
echo -e "192.0.2.17\trouter" >> /etc/hosts
# S'executa la comanda 'ping router' per comprovar que es pot establir una connexió amb el router utilitzant el seu nom.

	#=== Es comprova si està instal·lat el servei ssh i, en cas negatiu, s'instal·la i es comprova si la instal·lació ha estat correcta. Després s'activa i es reengega el servei. ===#
dpkg -s openssh-server
if [ $(echo $?) -eq 1 ]
then
	echo -e "\nINSTAL·LANT OPENSSH-SERVER\n"
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
# S'executa la comanda 'ssh root@router' per comprovar que es poden crear arxius al router des del server.
# S'executa la comanda 'ssh -rvp server root@router:/home/milax/' per passar els arxius del server al router.
