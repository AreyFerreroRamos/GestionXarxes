#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 15 de març del 2022. Versió: 2.
# Descripció: Es fan les configuracions pertinents per a que la NIC del router sigui funcional.

	#=== Es configura la interfície eth1 de forma estàtica usant el paquet iproute2. ===#
ip link set eth1 down
ip address add 192.0.2.17/28 broadcast 192.0.2.31 dev eth1
ip link set eth1 up
# Si es vol comprovar que l'adreça 192.0.2.17 s'ha afegit a la interficie eth1, es poden executar les comandes 'ip -c a' (general) o 'ip -f inet address show eth1' (específica).
# Si es vol validar la connexió del server amb el router, es pot executar la comanda 'ping 192.0.2.17' des del server.

	#=== S'activa el ipv4 forwarding. ===#
sysctl -w net.ipv4.ip_forward=1

	#=== S'afegeix el nom del server i la seva IP al fitxer /etc/hosts del router. Això permet establir una connexió al server utilitzant el nom en lloc de l'adreça IP (No hi ha DNS). ===#
# Cal afegir la línia '192.0.2.24	server' al fitxer hosts.
cp -p hosts /etc
# Si es vol validar la connexió del router amb el server utilitzant el seu nom, es pot executar la comanda 'ping server' des del propi router.

	#=== Es canvia la IP font privada (SA) per la IP externa del router (SNAT) per a tenir sortida cap a internet. ===#
iptables -t nat -A POSTROUTING -s 192.0.2.16/28 -o eth0 -j MASQUERADE
# Si es vol comprovar que s'ha afegit la regla correctament, s'executa la comanda 'iptables -t nat -L' per llistar les regles de la chain de la taula nat.
# Si es vol comprovar que la connexió a internet del server s'estableix a través de la adreça IP 192.0.2.17 assignada a la interfície eth1, es pot executar la comanda 'ip route get 8.8.8.8' des del server.
# Si es vol comprovar que es té connexió a internet des del server, es pot executar la comanda 'ping 8.8.8.8' (ping a Google) des del server.
