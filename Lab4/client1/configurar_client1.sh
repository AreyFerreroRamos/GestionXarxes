#!/bin/bash

# Autor: Arey Ferrero Ramos
# Data: 30 de març del 2022. Versió: 1.
# Descripció: Es fan totes les configuracions pertinents per proporcionar accés a internet al client 1 de la intranet a través del servei DHCP.

	#=== S'aixeca la interfice eth0 del contenidor del client 1. ===#
ifdown eth0
ifup eth0
# S'executa la comanda 'ip -c a' o 'ip -f inet address show eth0' (més específica) per comprovar si s'ha afegit una adreça IP dinàmica a la interficeie eth0. Si hi apareix, és que s'ha afegit.
# S'executa la comanda 'ip route get 8.8.8.8' per comprovar que la connexió a internet s'estableix a través de l'adreça IP 172.22.2.1 que s'ha assignat a la interficie eth2 del router.
# S'executa la comanda 'ping 8.8.8.8' (ping a Google) per comprovar que es té connexió a internet.

	#=== Es resolen les IPs del router, el server i l'intern a un nom concret especificat en el fitxer /etc/hosts del client1. Això permet establir una connexió amb les màquines utilitzant el nom en lloc de 		l'adreça IP (No hi ha DNS) ===#
echo -e "172.22.2.1\trouter" >> /etc/hosts
echo -e "192.0.2.24\tserver" >> /etc/hosts
echo -e "172.22.2.126\tintern" >> /etc/hosts
# S'executa la comanda 'ping router' per comprovar que es pot establir una connexió amb el router utilitzant el nom assignat.
# S'executa la comanda 'ping server' per comprovar que es pot establir una connexió amb el server utilitzant el nom assignat.
# S'executa la comanda 'ping intern' per comprovar que es pot establir una connexió amb l'intern utilitzant el nom assignat.
	
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
# S'executa la comanda 'ssh root@router' per comprovar que es poden crear arxius al router des del client1.
# S'executa la comanda 'ssh -rvp client1 root@router:/home/milax/' per passar arxius del client1 al router.
