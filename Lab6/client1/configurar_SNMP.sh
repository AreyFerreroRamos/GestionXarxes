#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 30 de maig del 2022. Versió: 1.
# Descripció: Activació d'un agent SNMP al client 1.

	#=== Instal·lació del servidor i de les comandes per fer les consultes desde la CLI. ===#
dpkg -l snmp snmpd smistrip patch snmp-mibs-downloader
if [ $(echo $?) -eq 1 ]
then
	apt install snmp snmpd smistrip patch snmp-mibs-downloader
fi

	#=== Es modifiquen els fitxer de configuració snmp.conf (path de les MIBs a la configuració dels agents i quines MIBs) i snmpd.conf (Informació vària). ===#
cp -p snmp.conf /etc/snmp
cp -p snmpd.conf /etc/snmp

	#=== Es reengega el servei. ===#
service snmpd restart
service snmpd status

# Si es vol comprovar al log que tot ha anat bé s'usa 'journalctl -r --unit=snmpd'.

# Si es vol obtenir informació remota reduida de les MIBs s'utilitzen les comandes:
# 	'snmpwalk -v 2c -c public localhost system'
# 	'snmpwalk -v 2c -c public localhost hrSystem'

# Si es vol obtenir informació remota reduida de les MIBs de la universitat California Davis s'utilitzen les comandes:	
#	'snmptable -v 2c -c 41588224-S 192.0.2.17 UCD-SNMP-MIB::prTable'
#	'snmptable -v 2c -c 41588224-S 192.0.2.17 ucdavis.dskTable'
#	'snmptable -v 2c -c 41588224-S 192.0.2.17 ucdavis.laTable'

# Si es vol obtenir informació més detallada de les MIBs de la universitat California Davis s'utilitza la comanda 'snmptranslate -Td -OS UCD-SNMP-MIB::ucdavis.dskTable'.

# Si es vol depurar cal aturar el servei i engegarlo en background amb la comanda 'snmpd -f -V -Lod -u Debian-snmp -g Debian-snmp -I -smux -p /run/snmpd.pid'.
