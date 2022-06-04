#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 3 de maig del 2022. Versió: 2.
# Descripció: Script responsable d'executar tots els scripts de configuració del server en l'ordre pertinent.

	#=== Instal·lació de noves versions dels paquets i actualització dels repositoris. ===#
apt upgrade
apt update

	#=== Configuració de la xarxa i del servei dhcp. ===#
./configurar_server.sh

	#=== Configuració del servei DNS ===#
./configurar_DNS_server.sh

	#=== Configuració del servei ssh. ===#
./configurar_servei_ssh.sh

	#=== Configuració del servei rsyslog. ===#
./configurar_servei_rsyslog.sh

	#=== Activació d'un agent SNMP. ===#
./configurar_SNMP.sh
