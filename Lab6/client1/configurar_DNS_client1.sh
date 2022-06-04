#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 6 d'abril del 2022. Versió: 2.
# Descripció: Actualització del client 1 per incorporar el servei DNS.

	#=== Es comenta la línia 'send host-name = gethostname();' i es comprova que es faci el request del domain-name i del domain-name-servers. ===#	
cp -p dhclient.conf /etc/dhcp

	#=== Es descomprimeix al directori /etc/dhcp/dhclient-exit-hooks.d/ un script que, després del DACK, proporciona el lease de la nova IP i nom. ===#
if [ ! -e actualitza_nom ]
then
	tar -xvf dhclient-exit-hook.tar
	chmod u+x actualitza_nom
fi
if [ ! -e /etc/dhcp/dhclient-exit-hooks.d ]
then
	mkdir -p /etc/dhcp/dhclient-exit-hooks.d
fi
cp -p actualitza_nom /etc/dhcp/dhclient-exit-hooks.d

	#=== S'abaixa i s'aixeca la interficie eth0. ===#
ifdown eth0
ifup eth0
# S'ha de comprovar que el contingut del fitxer /etc/resolv.conf és correcte.
