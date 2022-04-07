#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 6 d'abril del 2022. Versió: 1.
# Descripció: Actualització del client 2 per incorporar el servei DNS.

	#=== S'abaixa la interficie eth0, es comprova que es faci el request del domain-name i del domain-name-servers i es torna a aixecar la interficie. ===#
ifdown eth0
cp dhclient.conf /etc/dhcp
ifup eth0
# Es comprova que el contingut del fitxer /etc/resolv.conf és correcte.
