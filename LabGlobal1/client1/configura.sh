#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 3 de maig del 2022. Versió: 1.
# Descripció: Script responsable d'executar tots els scripts de configuració del client 1 en l'ordre pertinent.

	#=== Configuració de la xarxa i del servei dhcp. ===#
./configurar_client1_lab3.sh

	#=== Configuració del servei DNS ===#
./configurar_DNS_client1.sh

	#=== Configuració del servei ssh. ===#
./configurar_servei_ssh.sh
