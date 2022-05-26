#!/bin/sh

# GSX-2022
# Autor: Josep M. Banús
# Versió: 1.0
# Descripció:
# Re-establir el docker a  l'estat inicial, abans de cacti+DMZ

[ $(id -u) -ne 0 ] && echo "Has de ser root!" && exit 1

systemctl --no-pager  status docker >/dev/null 2>&1
[ $? -ne 0 ] && echo "Error: el docker no està actiu." && exit 1

ja=$(docker container ls | grep -c "docker-cacti")
if [ $ja -gt 0 ]; then
	echo "AVÍS: encara tens el cacti executant-se !"
	read -p "Estàs segur que el vols aturar i eliminar [S,n] ?" answ
	answ=${answ:-'s'}
	[ $answ != 's' -a $answ != 'S' ] && exit 0
	docker stop cacti
fi
ja=$(docker container ls -a | grep -c "cacti$")
[ $ja -gt 0 ] && docker container rm cacti

# eliminar les dues veth inter-connectades
ip link show veth10 >/dev/null 2>&1
[ $? -eq 0 ] && ip link del veth10

ip link show veth20 >/dev/null 2>&1
[ $? -eq 0 ] && ip link del veth20

pontLXC=lxcbr1
# eliminar el pont de la DMZ dels LXC
ip link show lxcbr0 >/dev/null 2>&1
if [ $? -ne 0 ]; then
	# no hi ha el lxcbr0: no tenim els LXC
	# es pot eliminar el bridge de la DMZ
	ip link show $pontLXC >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo  elminant el bridge $pontLXC de la DMZ
		ip link del $pontLXC
	fi
	echo "No elimino el pont $pontLXC perquè encara tens l'entorn LXC definit."
fi

# eliminar el pont docker DMZ
ja=$(docker network ls | grep -c DMZ)
if [ $ja -ne 0 ]; then 
	id=$(docker network ls | grep DMZ | cut -f1 -d ' ')
	pontDocker="br-$id"

	docker network rm DMZ
#	docker network prune 
	ip link del $pontDocker
else
	echo "Avís: no existeix la DMZ al docker."
fi

systemctl stop docker
# restaurar possible config anterior del docker
if [ -f ./daemon.json.bkp ]; then
	mv daemon.json.bkp /etc/docker/daemon.json
else
	rm /etc/docker/daemon.json
fi

# eliminar possibles configs de xarxa romanents
rm /var/lib/docker/network/files/local-kv.db

echo
echo Ponts actuals:
brctl show 
echo

read -p "engego el servei docker [s,N] ? " answ
[ "$answ" = "s" ] || exit 0

systemctl start docker
journalctl -e --unit=docker
exit 0
