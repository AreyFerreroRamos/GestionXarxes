#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 6 d'abril del 2022. Versió: 1.
# Descripció: Creació del servei DNS.

	#=== Es comprova si es tenen els paquets bind9, bind9-doc i dnsutils i, en cas negatiu, s'instal·len. ===#
service bind9 status
if [ $(echo $?) -eq 4 ]
then
	apt install bind9
	service bind9 status
fi
dpkg -l bind9-doc
if [ $(echo $?) -eq 4 ]
then
	apt install bind9-doc
	dpkg -l bind9-doc
fi
dpkg -l dnsutils
if [ $(echo $?) -eq 4 ]
then
	apt install dnsutils
	dpkg -l dnsutils
fi

	#=== Es configura el servidor DNS. S'edita el fitxer /etc/bind/named.conf.local . ===#
cp named.conf.local /etc/bind

	#=== Es configura el servidor DNS. S'edita el fitxer d'opcions. ===#
cp named.conf.options /etc/bind	

	#=== Es configuren els fitxers de zona. ===#
cp intranet.gsx.db /etc/bind
cp dmz.gsx.db /etc/bind

	#=== Es configuren els fitxers de zona inversa. ===#
cp db.gsx.intranet /etc/bind
cp db.gsx.dmz /etc/bind

	#=== Es comprova que la sintaxi és correcta. ===#
/sbin/named-checkconf -z /etc/bind/named.conf.local
/sbin/named-checkconf -z /etc/bind/named.conf.options
/sbin/named-checkzone dmz.gsx dmz.gsx.db
/sbin/named-checkzone intranet.gsx intranet.gsx.db
/sbin/named-checkzone 2.0.192.in-addr.arpa db.gsx.dmz
/sbin/named-checkzone 22.172.in-addr.arpa db.gsx.intranet
	
	#=== Es reengega el dimoni. ===#
service bind9 restart
service bind9 status
