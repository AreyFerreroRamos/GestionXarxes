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
# Si es vol comprovar que l'adreça 192.0.2.17 s'ha afegit a la interficie eth1, es pot executar la comanda 'ip -c a' (general) o la comanda 'ip -f inet address show eth1' (específica).
# Si es vol comprovar que l'adreça 172.22.2.1 s'ha afegit a la interficie eth2, es pot executar la comanda 'ip -c a' (general) o la comanda 'ip -f inet address show eth2' (específica).
# Si es vol validar la connexió del server amb el router, s'executa la comanda 'ping 192.0.2.17' des del server.
# Si es vol validar la connexió de l'intern amb el router, s'executa la comanda 'ping 172.22.2.1' des de l'intern.

	#=== S'activa el ipv4 forwarding. ===#
sysctl -w net.ipv4.ip_forward=1

	#=== Es resolen les IPs del servidor i de l'intern a un nom concret especificat al fitxer /etc/hosts del router. Això permet establir una connexió amb les màquines utilitzant el nom en lloc de l'adreça 		IP (No hi ha DNS). ===#
# Cal afegir la línia '192.0.2.24	server' al fitxer hosts.
# Cal afegir la línia '172.22.2.126	intern' al fitxer hosts.
cp -p hosts /etc
# Si es vol validar la connexió del router amb el server utilitzant el nom assignat, s'executa la comanda 'ping server' des del propi router.
# Si es vol validar la connexió del router amb l'intern utilitzant el nom assignat, s'executa la comanda 'ping intern' des del propi router.

	#=== Es canvia la IP font privada (SA) per la IP externa del router (SNAT) per a tenir sortida cap a internet des del server i l'intern. ===#
iptables -t nat -A POSTROUTING -s 192.0.2.16/28 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.22.2.0/25 -o eth0 -j MASQUERADE
# Si es vol comprovar que les regles s'han afegit correctament, s'executa la comanda 'iptables -t nat -L' per llistar les regles de les chains PREROUTING i POSTROUTING de la taula nat.
# Si es vol comprovar que la connexió a internet del server s'estableix a través de la adreça IP 192.0.2.17 que s'ha assignat a la interfície eth1, es pot executar la comanda 'ip route get 8.8.8.8'.
# Si es vol comprovar que la connexió a internet de l'intern s'estableix a través de la adreça IP 172.22.2.1 que s'ha assignat a la interfície eth2, es pot executar la comanda 'ip route get 8.8.8.8'.
# Si es vol comprovar que el server té connexió a internet, s'executa la comanda 'ping 8.8.8.8' (ping a Google) al server.
# Si es vol comprovar que l'intern té connexió a internet, s'executa la comanda 'ping 8.8.8.8' (ping a Google) a l'intern.
