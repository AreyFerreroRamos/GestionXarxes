#!/bin/sh

# Descripció:
# Eliminar la infraestructura: xarxa i contenidors

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.2

echo "Exec: $0\n"
[ $(id -u) -ne 0 ] && echo "$0: Has de ser root" && exit 1

definicions=$(find . -name "definicions.sh")
[ ! -x $definicions ] && echo "Falta el fitxer definicions.sh" && exit 1
. $definicions 2>/dev/null

fitxer=$relpath/atura_contenidors_lxc.sh
[ ! -x $fitxer ] && echoError "Falta el fitxer $fitxer" && exit 1
fitxer=$relpath/canvia_estat_sortida.sh
[ ! -x $fitxer ] && echoError "Falta el fitxer $fitxer" && exit 1
fitxer=$relpath/comprova_internet.sh
[ ! -x $fitxer ] && echoError "Falta el fitxer $fitxer" && exit 1

$relpath/atura_contenidors_lxc.sh

echo
echo "\nEliminant els contenidors dels nodes...\n"
echoAvis "Si els elimines pots perdre els fitxers locals"
echo "(primer els hauries de salvar cap al host)"
echo "A més, hauries de tornar a crear-los i tarda.\n"

for node in $NODES
do
	creat=$(lxc-ls | grep -c $node)
	if [ $creat -ne 0 ]; then
		read -p "Elimino $node [y,N] ? " answ
		answ=${answ:-'n'}
		if [ $answ = 'y' -o $answ = 'Y' ]; then 
			lxc-stop $node 2>/dev/null
			lxc-destroy $node
		fi
	fi
	[ -f /tmp/debug_$node ] && rm /tmp/debug_$node 
done

echo "\nEliminant les NIC del del HOST: $PONTS...\n"
canvis=0

br=$PONT0
ip link show $br >/dev/null 2>&1
if [ $? -eq 0 ]; then
	# alliberar la IP del vpont principal
	ifdown $PONT0

	# outINTF ha canviat:
	. $definicions 2>/dev/null

	# desconectar la NIC de sortida del vpont:
	ip link set dev $outINTF nomaster
	ip link set dev $outINTF down

	ip link set dev $br down
	ip link del $br 
	canvis=1
else
	echoAvis "$br no existeix"
fi

for br in $PONTS
do
	[ $br = $PONT0 ] && continue
	ip link show $br >/dev/null 2>&1
	[ $? -eq 1 ] && echoAvis "$br no existeix" && continue

	ip link set dev $br down
	ip link del $br 
	canvis=1
done

echo "\nQueden ponts?"
bridge -d link | grep "lxcbr.:"

si=$(ls /etc/network/interfaces.d/hostBridge?.conf 2>/dev/null| wc -l)
if [ $si -gt 0 ]; then
	echo "\nEliminant les configs dels ponts del HOST a interfaces.d:\n"
	rm /etc/network/interfaces.d/hostBridge?.conf
	canvis=1
fi

if [ $canvis -ne 0 ]; then
	# Tornar la intf principal a l'estat previ
	updown=$(grep -c "\<$outINTF\>" /etc/network/interfaces)
	if [ $updown -gt 0 ]; then
		# descomentar la línia de config  per al ifupdown
		sed -i "s/^#\+\(.*\<$outINTF\>\)/\1/" /etc/network/interfaces
	fi

	tenimNM=$(service NetworkManager status 2>/dev/null | grep -ic running)
	if [ $tenimNM -eq 1 ]; then
		configNM="/etc/NetworkManager/NetworkManager.conf"

		ja=$(grep -c "#managed=true" $configNM)
		if [ $ja -gt 0 ]; then
			# Tornant-li les interfíces gestionades al NM
			sed -i "s/managed=false//" $configNM
			sed -i "s/^#managed=true/managed=true/" $configNM
		fi
		nmcli dev set $outINTF managed yes
		service NetworkManager restart
	fi

	$relpath/canvia_estat_sortida.sh up

	#service networking restart
	# millor no, per a no afectar altres NICs, com la wifi, etc
fi

#$relpath/comprova_internet.sh

echo
exit 0
