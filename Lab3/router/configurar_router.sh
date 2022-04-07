#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 15 de març del 2022. Versió: 2.
# Descripció: Es fan les configuracions pertinents per a que les NICs del router siguin funcionals.

	#=== Es configuran les interfícies eth1 i eth2 de forma estàtica usant el paquet iproute2. ===#
ip link set eth1 down
ip address add 192.0.2.17/28 broadcast 192.0.2.31 dev eth1
ip link set eth1 up
ip link set eth2 down
ip address add 172.22.2.1/25 broadcast 172.22.2.127 dev eth2
ip link set eth2 up
# S'executa la comanda 'ip -c a' o la comanda 'ip -f inet address show eth1' (més específica) per comprovar si l'adreça 192.0.2.17 s'ha afegit a la interfície eth1. Si hi apareix, és que s'ha afegit.
# S'executa la comanda 'ip -c a' o la comanda 'ip -f inet address show eth2' (més específica) per comprovar si l'adreça 172.22.2.1 s'ha afegit a la interfície eth2. Si hi apareix, és que s'ha afegit.
# S'executa la comanda 'ping 192.0.2.17' des del server per comprovar que es pot establir una connexió amb el router.
# S'executa la comanda 'ping 172.22.2.1' des del intern per comprovar que es pot establir una connexió amb el router.

	#=== S'activa el ipv4 forwarding. ===#
sysctl -w net.ipv4.ip_forward=1

	#=== Es resolen les IPs del servidor i de l'intern a un nom concret especificat al fitxer /etc/hosts del router. Això permet establir una connexió amb les màquines utilitzant el nom en lloc de l'adreça 		IP (No hi ha DNS). ===#
echo -e "192.0.2.24\tserver" >> /etc/hosts
echo -e "172.22.2.126\tintern" >> /etc/hosts
# S'executa la comanda 'ping server' per comprovar que es pot establir una connexió amb el server utilitzant el nom assignat.
# S'executa la comanda 'ping intern' per comprovar que es pot establir una connexió amb l'intern utilitzant el nom assignat.

	#=== Es canvia la IP font privada (SA) per la IP externa del router (SNAT) per a tenir sortida cap a internet des del server i l'intern. ===#
iptables -t nat -A POSTROUTING -s 192.0.2.16/28 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.22.2.0/25 -o eth0 -j MASQUERADE
iptables -t nat -A PREROUTING -i eth2 -d 172.22.2.1 -p udp --dport 53 -j DNAT --to-destination 8.8.8.8:53
iptables -t nat -A PREROUTING -i eth2 -d 172.22.2.1 -p tcp --dport 53 -j DNAT --to-destination 8.8.8.8:53
# S'executa la comanda 'iptables -t nat -L' per llistar les iptables y comprovar que s'han afegit les regles correctament.
# S'executa la comanda 'ip route get 8.8.8.8' al server per comprovar que la connexió a internet del server s'estableix a través de la adreça IP 192.0.2.17 que s'ha assignat a la interfície eth1.
# S'executa la comanda 'ip route get 8.8.8.8' a l'intern per comprovar que la connexió a internet de l'intern s'estableix a través de la adreça IP 172.22.2.1 que s'ha assignat a la interfície eth2.
# S'executa la comanda 'ping 8.8.8.8' (ping a Google) al server per a comprovar que es té connexió a internet des del server.
# S'executa la comanda 'ping 8.8.8.8' (ping a Google) a l'intern per a comprovar que es té connexió a internet des de l'intern. 

	#=== Es comprova si està instal·lat el paquet rsyslog i, en cas negatiu, s'instal·la i es comprova si la instal·lació ha estat correcte. ===#
service rsyslog status
if [ $(echo $?) -eq 4 ]
then
	echo -e "\nINSTAL·LACIÓ RSYSLOG\n"
	apt install rsyslog
	echo -e "\nESTAT RSYSLOG\n"
	service rsyslog status
fi

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
