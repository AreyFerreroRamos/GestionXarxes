#!/bin/sh

# GSX-2022
# Autor: Josep M. Banús
# Versió: 1.8
# Data: 5/5/2022

# Descripció:
# Descarrega un docker amb cacti per a monitoritzar la infraestructura
# El penja a la DMZ dels contenidors LXC

# Requereix: docker, lxc, ./ips_personals.sh
# https://hub.docker.com/r/quantumobject/docker-cacti/
# (apareix a dockerhub  github com a public i sense llicència)
# (depèn de: quantumobject/docker-baseimage:18.04 que si té llicencia)
# (però és permisiva: "to use, copy, modify, merge, publish, distribute, sublicense...")

[ $(id -u) -ne 0 ] && echo "Has de ser root!" && exit 1

# comprovar els requisits
ja=$(dpkg -l lxc* 2>/dev/null | grep -c "^ii")
[ $ja -eq 0 ] && echo "Fa falta instal.lar el paquet lxc" && exit 1

ja=$(dpkg -l docker* 2>/dev/null | grep -c "^ii")
[ $ja -eq 0 ] && echo "Fa falta instal.lar el paquet docker" && exit 1

systemctl status docker >/dev/null 2>&1
[ $? -ne 0 ] && systemctl start docker

if [ ! -f ips_personals.sh ]; then
	echo "Error: falta els fitxer ./ips_personals.sh"
	echo "Ha de definir:"
	echo "subnet= (IPDMZ/MASK)"
	echo "gateway= (IP del router a la dmz)"
	echo "dns= (IP del nostre dns)"
	echo "noc= (IP per al contenidor docker cacti)"
	exit 1
fi
. ./ips_personals.sh
[ -z $subnet ] && echo "ips_personals.sh no completat: subnet" && exit 1
[ -z $gateway ] && echo "ips_personals.sh no completat: gateway" && exit 1
[ -z $dns ] && echo "ips_personals.sh no completat: dns" && exit 1
[ -z $noc ] && echo "ips_personals.sh no completat: noc" && exit 1

# requisits comprovats

# PAS1: preparar el docker
ja=$(grep "iptables.: false"  /etc/docker/daemon.json 2>/dev/null | wc -l)
if [ $ja -eq 0 ]; then
	systemctl stop docker

	# fem un backup de la config actual del docker, per si calgués restaurar-la
	[ -f /etc/docker/daemon.json ] && cp -pi /etc/docker/daemon.json daemon.json.bkp

	# permetre la cohexistència dels contenidors LXC i docker a la mateixa xarxa
	echo "{ \"iptables\": false }" > /etc/docker/daemon.json

	# per si de cas, eliminar possibles configs de xarxa romanents
	rm /var/lib/docker/network/files/local-kv.db
fi

systemctl status docker >/dev/null 2>&1
[ $? -ne 0 ] && systemctl start docker
# comprovació paranòica:
systemctl status docker >/dev/null 2>&1
[ $? -ne 0 ] && echo "Error en l'estat del dockerd !" && exit -1

# Comprovacions preliminars
ja=$(docker container ls | grep -c "docker-cacti")
[ $ja -gt 0 ] && echo "Ja tens executant el contenidor cacti." && exit 0
ja=$(docker container ls | grep -v "^CONTAINER" | wc -l)
[ $ja -gt 0 ] && echo "Tens executant altres contenidors docker i podria ser un problema." && exit 1

# PAS2: el pont docker0 no ens val (per les IPs).
# Crear un bridge personalitzat per a connectar-lo a la DMZ

ja=$(docker network ls | grep -c DMZ)
if [ $ja -eq 0 ]; then
	docker network create \
		 --driver=bridge \
		 --subnet=$subnet \
		 --gateway=$gateway \
		 DMZ
else
	echo "Ja existeix la xarxa DMZ pel docker."
	docker network inspect DMZ | grep -A5 "Config\""
fi

# PAS3: connectar el pont docker DMZ al pont LXC de la dmz

id=$(docker network inspect --format "{{ .Id }}" DMZ | cut -b 1-12)
id=$(docker network ls | grep DMZ | cut -f1 -d ' ')
pontDocker="br-$id"
pontLXC=lxcbr1

# eliminar la IP del bridge perquè coincideix amb el default gateway (primera IP del rang)
ip address flush $pontDocker

# assegurar que existeix el bridge de la DMZ dels LXC
# per si encara no s'ha iniciat l'entorn LXC
ip link show $pontLXC >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo Creant el bridge $pontLXC de la DMZ
	ip link add $pontLXC type bridge
	ip link set $pontLXC up
else
	echo Perfecte, ja existeix el pont dels LXC.
fi

# crear dues veth inter-connectades, una a cada pont
ip link show veth10 >/dev/null 2>&1
if [ $? -ne 0 ]; then
	ip link add veth10 type veth peer name veth20
fi

ip link show veth20 >/dev/null 2>&1
[ $? -ne 0 ] && ip link add veth20 type veth peer name veth10

ja=$(ip link show veth10 | grep -c "veth10@veth20")
[ $ja -eq 0 ] && echo Ja tenim les dues veth interconnectades.

# connectar cada veth a un bridge per a juntar els dos ponts
ja=$(ip link show veth10 | grep -c "master *$pontDocker")
if [ $ja -eq 0 ]; then
	echo "Connectant un port del pont docker $pontDocker amb el pont $pontLXC"
	ip link set veth10 master $pontDocker
	ip link set veth10 up
fi
ja=$(ip link show veth20 | grep -c "master *$pontLXC")
if [ $ja -eq 0 ]; then
	echo "Connectant un port del $pontLXC amb el pont docker $pontDocker"
	ip link set veth20 master $pontLXC
	ip link set veth20 up
else
	echo Perfecte, els ponts ja estan connectats per veths.
fi 

echo
echo Ponts resultants:
brctl show $pontDocker $pontLXC

# PAS4: descarregar la imatge 
ja=$(docker image ls quantumobject/docker-cacti 2>/dev/null | grep -c "docker-cacti")
if [ $ja -eq 0 ]; then
	docker pull quantumobject/docker-cacti
else
	echo Perfecte, ja tenim la imatge docker del cacti.
fi

# Té l'script startup.sh el qual comprova si ja estava configurat el cacti
# mirant si existeix /etc/configured
# Com /etc no es persistent, cada cop que fas stop i rm del contaenidor
# es perd i hauràs de configurar tot des de zero.

# solució maldestre: que el guardi al volum persistent /var/log

n=$(find /var/lib/docker -iname "startup.sh" | wc -l)
if [ $n -gt 0 ]; then
	find /var/lib/docker -iname "startup.sh" \
		-exec sed -i "s:etc/configured:var/log/configured:" \{\} \;
else
	echo "Avís: no trobo startup.sh: persistència no garantida."
fi

# PAS FINAL: executar el contenidor
echo
echo Ara cal engegar el contenidor:
echo ./run-docker-cacti.sh
exit 0
