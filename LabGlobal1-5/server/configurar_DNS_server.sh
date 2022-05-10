#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 6 d'abril del 2022. Versió: 2.
# Descripció: Creació del servei DNS.

	#=== Es comprova si es tenen els paquets bind9, bind9-doc i dnsutils i, en cas negatiu, s'instal·len. ===#
service bind9 status
if [ $(echo $?) -eq 4 ]
then
	apt install bind9	
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

chmod g+x /etc/bind

	#=== Es configura el servidor DNS. S'edita el fitxer /etc/bind/named.conf.local . ===#
cp -p named.conf.local /etc/bind

	#=== Es configura el servidor DNS. S'edita el fitxer d'opcions. ===#
cp -p named.conf.options /etc/bind	

	#=== Es configuren els fitxers de zona. ===#
cp -p intranet.gsx.db /etc/bind
cp -p dmz.gsx.db /etc/bind

	#=== Es configuren els fitxers de zona inversa. ===#
cp -p db.gsx.intranet /etc/bind
cp -p db.gsx.dmz /etc/bind

	#=== Es comprova que la sintaxi és correcta. ===#
/sbin/named-checkconf -z /etc/bind/named.conf.local
/sbin/named-checkconf -z /etc/bind/named.conf.options
/sbin/named-checkzone dmz.gsx dmz.gsx.db
/sbin/named-checkzone intranet.gsx intranet.gsx.db
/sbin/named-checkzone 2.0.192.in-addr.arpa db.gsx.dmz
/sbin/named-checkzone 22.172.in-addr.arpa db.gsx.intranet

	#=== Es crea el fitxer de log. ===#
mkdir /var/log/bind
chgrp bind /var/log/bind
chmod g+w /var/log/bind
touch /var/log/bind/update_debug.log
chgrp bind /var/log/bind/update_debug.log
chmod g+w /var/log/bind/update_debug.log

	#=== Es reengega el dimoni. ===#
service bind9 enable
service bind9 restart
service bind9 status
