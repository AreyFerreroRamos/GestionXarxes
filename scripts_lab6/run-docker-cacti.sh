#!/bin/sh

# GSX-2022
# Autor: Josep M. Banús
# Versió: 2.1
# Descripció:
# Executar un Cacti en un contenidor docker
# per a gestionar les xarxes dels contennidors LXC

usuari=$(id -un)
uRdocker=$(groups $usuari | grep -c docker)
[ $uRdocker -eq 0 ] && echo "Error: l'usuari $usuari ha de pertanyer al grup docker." && exit 1

ja=$(docker container ls | grep -c quantumobject/docker-cacti)
[ $ja -eq 1 ] && echo "Ja s'està executant el docker-cacti." && exit 0

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

docker run -d --hostname=noc --network=DMZ --ip=$noc \
  --domainname=dmz.gsx --dns=$dns --dns-search="dmz.gsx" \
  --dns-search="intranet.gsx" \
  --env TZ=Europe/Madrid \
  -v $HOME/GSX/cacti/plugins:/opt/cacti/plugins \
  -v $HOME/GSX/cacti/templates:/opt/cacti/templates \
  -v $HOME/GSX/cacti/mysql:/var/lib/mysql \
  -v $HOME/GSX/cacti/rra:/opt/cacti/rra \
  -v $HOME/GSX/cacti/log:/var/log \
  --name=cacti quantumobject/docker-cacti

exit 0
