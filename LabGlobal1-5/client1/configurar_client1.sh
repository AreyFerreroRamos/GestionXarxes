#!/bin/bash

# Autor: Arey Ferrero Ramos
# Data: 30 de març del 2022. Versió: 2.
# Descripció: Es fan totes les configuracions pertinents per proporcionar accés a internet al client 1 de la intranet a través del servei DHCP.

	#=== S'aixeca la interfice eth0 del contenidor del client 1. ===#
ifdown eth0
ifup eth0
# Si es vol comprovar que s'ha afegit una adreça IP dinàmica a la interficie eth0, es pot executar la comanda 'ip -c a' (general) o 'ip -f inet address show eth0' (específica).
# Si es vol comprovar que la connexió a internet del client 1 s'estableix des de l'adreça IP 172.22.2.1 que s'ha assignat a la interficie eth2 del router, es pot executar la comanda 'ip route get 8.8.8.8'.
# Si es vol comprovar que el client 1 té connexió a internet, es pot executar la comanda 'ping 8.8.8.8' (ping a Google).

	#=== Es resolen les IPs del router, el server i l'intern a un nom concret especificat en el fitxer /etc/hosts del client1. Això permet establir una connexió amb les màquines utilitzant el nom en lloc de 		l'adreça IP (No hi ha DNS) ===#
# Cal afegir la línia '172.22.2.1	router' al fitxer hosts.
# Cal afegir la línia '192.0.2.24	server' al fitxer hosts.
# Cal afegir la línia '172.22.2.126	intern' al fitxer hosts.
cp -p hosts /etc
# Si es vol validar la connexió del client 1 amb el router utiltzant el nom assignat, es pot executar la comanda 'ping router' des del propi client 1.
# Si es vol validar la connexió del client 1 amb el server utiltzant el nom assignat, es pot executar la comanda 'ping server' des del propi client 1.
# Si es vol validar la connexió del client 1 amb l'intern utiltzant el nom assignat, es pot executar la comanda 'ping intern' des del propi client 1.
