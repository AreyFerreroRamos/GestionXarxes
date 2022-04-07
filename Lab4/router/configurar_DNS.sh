#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 6 de març del 2022. Versió: 1.
# Descripció: Actualització del router per incorporar el servei DNS.

	#=== Es configura el client dhcp per a que prefereixi la IP del server i els nostres dominis abans que la configuració del dhcp extern. ===#
cp dhclient.conf /etc/dhcp

	#=== S'abaixa i s'aixeca la interficie eth0. ===#
ifdown eth0
ifup eth0
# Es comprova si el contingut del fitxer /etc/resolv.conf és correcte.
