#!/bin/sh

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.2

# Descripció:
# Comprova la configuració actual i la guarda
# a un fitxer (ex: 'sortida_router.txt').
# Aquest fitxer el adjuntareu al moodle 
# per a avaluar si ho heu fet bé.

# Execució: 
# A cada contenidor: ./genera_sortida.sh
# Al final, quan ja us funcionin els scripts.

# Important:
############
# no modifiqueu aquest script ni els seus resultats,
# doncs l'avaluació seria dolenta.

qui=$(hostname)
case $qui in
	'router')	peer='server'
		;;
	'server')	peer='router'
		;;
	*)	echo "error en el hostname '$qui'"
		exit 1
esac
out="./sortida_$qui.txt"

date > $out
echo >>$out

sysctl net.ipv4.ip_forward >> $out
echo >>$out

ip address >> $out
echo >>$out

ip route >> $out
echo >>$out

ifquery eth0 >> $out 2>&1
echo >>$out

ifquery eth1 >> $out 2>&1
echo >>$out

dgw=$(ip route | grep default | cut -f3 -d' ')
ping -c3 $dgw >> $out
echo >>$out

ping -c3 $peer >> $out
echo >>$out

ping -c1 1.1.1.1 >> $out
echo >>$out

nmap -p22 $peer >> $out
