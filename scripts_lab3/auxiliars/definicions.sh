#!/bin/sh

# Descripció:
# Definicions de constants per a usar en altres scripts

# s'ha d'incloure amb:
#. ./definicions.sh
# o amb:
# source ./definicions.sh

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.3

# definició de constants:
NODE0=router
NODE1=server
NODE2=intern
NODE3=client1
NODE4=client2
NODE5=client3
NODES="$NODE0 $NODE1 $NODE2 $NODE3 $NODE4" 

ROUTER=$NODE0
# alias, per a terni scripts es nets, però ha de ser el NODE0

PONT0=lxcbr0
PONT1=lxcbr1
PONT2=lxcbr2
PONT3=lxcbr2 # no és un pont,sols una segona connexió al 2
PONT4=lxcbr2 # ídem
PONT5=lxcbr2 # ídem
PONTS="$PONT0 $PONT1 $PONT2" 

nomPONT0=EXT
nomPONT1=DMZ
nomPONT2=INT

# lloc relatiu on hi ha els scripts
# usualment al dir: auxiliars/
relpath=$(dirname $0)

# carregar funcions auxiliars comunes:
if [ -f $relpath/echo_colors.sh ]; then
	. $relpath/echo_colors.sh
else
	echoError() { echo "Error: $1"
	}
	echoAvis() { echo "Avis: $1"
	}
fi

# obtenir informació de la xarxa actual (ISP?)
connectat=$(ip route | grep default | wc -l)
case $connectat in
	0)
		echoAvis "Falta el default gateway!" >&2
		echoAvis "Si cal edita aquest fitxer i configura manualment outINTF i outIP\n" >&2

		echo provo amb la primera inteficie >&2
		outINTF=$(ip link | grep "^[0-9]\+:" | grep -v "lo:" | head -1 | cut -f2 -d: | tr -d ' ')
		outIP=""
		echoAvis "provarem amb outINTF=$outINTF amb outIP=$outIP\n" >&2
		;;
	1)
		outINTF=$(ip route | grep default | grep -o "dev [^ ]\+" | cut -f2 -d' ')
		[ ${#outINTF} -eq 0 ] && echoError "no he detectat la interfície de sortida.\n" && exit 1

		outIP=$(ip route | grep default | grep -o "[0-9.]\{7,15\}")
		[ ${#outIP} -eq 0 ] && echoAvis "no he detectat la IP de sortida.\n"
		;;
	*)	# N'hi ha diversos : preguntar quina tria
		outINTF=$(ip route get 1.1.1.1 | grep -o "dev [^ ]\+" | cut -f2 -d' ')
		outIP=$(ip route get 1.1.1.1 | grep -o "via [0-9.]\{7,15\}" | cut -f2 -d' ')
		[ ${#outIP} -eq 0 ] && echoAvis "no he detectat la IP de sortida.\n"
		;;
esac

[ "$1" = "info" ] && echoAvis "$0: Trobat outINTF=$outINTF amb outIP=$outIP\n"
