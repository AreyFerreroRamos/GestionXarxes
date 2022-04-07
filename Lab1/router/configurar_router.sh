#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 15 de març del 2022. Versió: 1.
# Descripció: Es fan les configuracions pertinents per a que les NICs del router siguin funcionals.

	#=== Es configura la interfície eth1 de forma estàtica usant el paquet iproute2. ===#
ip link set eth1 down
ip address add 192.0.2.17/28 broadcast 192.0.2.31 dev eth1
ip link set eth1 up
# S'executa la comanda 'ip -c a' o la comanda 'ip -f inet address show eth1' (més específica) per comprovar si l'adreça 192.0.2.17 s'ha afegit a la interfície eth1. Si hi apareix, és que s'ha afegit.
# S'executa la comanda 'ping 192.0.2.17' des del server per comprovar que es pot establir una connexió amb el router.

	#=== S'activa el ipv4 forwarding. ===#
sysctl -w net.ipv4.ip_forward=1

	#=== S'afegeix el nom del server i la seva IP al fitxer /etc/hosts del router. Això permet establir una connexió al server utilitzant el nom en lloc de l'adreça IP (No hi ha DNS). ===#
echo -e "192.0.2.24\tserver" >> /etc/hosts
# S'executa la comanda 'ping server' per comprovar que es pot establir una connexió amb el server utilitzant el seu nom.

	#=== Es canvia la IP font privada (SA) per la IP externa del router (SNAT) per a tenir sortida cap a internet. ===#
iptables -t nat -A POSTROUTING -s 192.0.2.16/28 -o eth0 -j MASQUERADE
# S'executa la comanda 'iptables -t nat -L' per llistar les iptables y comprovar que s'ha afegit la regla correctament.
# S'executa la comanda 'ip route get 8.8.8.8' al server per comprovar que la connexió a internet del server s'estableix a través de la adreça IP 192.0.2.17 que s'ha assignat a la interfície eth1.
# S'executa la comanda 'ping 8.8.8.8' (ping a Google) al server per a comprovar que es té connexió a internet des del server.

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
# S'executa la comanda 'ssh root@server' per comprovar que es poden crear arxius al server des del router.
# S'executa la comanda 'ssh -rvp router root@server:/home/milax/' per passar arxius del router al server.
