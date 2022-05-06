#!/bin/sh

# Descripció:
# Crear la infraestructura de xarxa al host/AMFITRIÓ
# Crear els bridges i connectant-hi les vNICs i la NIC de Internet

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.5

echo "Exec: $0\n"
[ $(id -u) -ne 0 ] && echo "$0: Has de ser root" && exit 1

definicions=$(find . -name "definicions.sh")
[ ! -x $definicions ] && echo "Falta el fitxer definicions.sh" && exit 1
. $definicions 2>/dev/null

fitxer=$relpath/canvia_estat_sortida.sh
[ ! -x $fitxer ] && echoError "Falta el fitxer $fitxer" && exit 1

[ ! -d /etc/network/interfaces.d ] && \
echoError "No existeix el directory /etc/network/interfaces.d" && exit 1

# la interfície principal anirà al pont principal:
# cal evitar interferènceis amb ifupdown
updown=$(grep -c "$outINTF" /etc/network/interfaces)
if [ $updown -gt 0 ]; then
	# comentar la línia de config de la intf principal
	sed -i -e "s/^.*\<$outINTF\>/###&/" /etc/network/interfaces
fi

# algunes distros no inclouen el .d i ifupdown no els llegeix
activat=$(grep -ic "source /etc/network/interfaces.d" /etc/network/interfaces)
if [ $activat -eq 0 ]; then
	echo "source /etc/network/interfaces.d/*" >>/etc/network/interfaces
fi

# També cal evitar interferències amb NM
tenimNM=$(service NetworkManager status 2>/dev/null | grep -ic running)
if [ $tenimNM -gt 0 ]; then
	echoAvis "Mentre creem els ponts aturem temporalment el NetworkManager!"
	service NetworkManager stop
	# aturat abns de crear noves NICs
fi

echo "Preparant els ponts a interfaces.d ..."
fet=$(ls -C1 /etc/network/interfaces.d/hostBridge?.conf 2>/dev/null | wc -l)
if [ $fet -gt 0 ]; then
	echoError "ja tens fitxers de configuració de ponts!"
	echo "Primer caldria que els eliminessis:"
	rm -i /etc/network/interfaces.d/hostBridge?.conf 
	fet=$(ls -C1 /etc/network/interfaces.d/hostBridge?.conf | wc -l)
	[ $fet -gt 0 ] && exit 1
fi

echo "
auto $PONT0
iface $PONT0 inet manual
brige_ports $outINTF
bridge_stp off
bridge_fd 0
bridge_maxwait 0
" > /etc/network/interfaces.d/hostBridge0.conf

# configurem un pont/xarxa on hi haurà les INTERFÍCES INTERNES dels contenidors 
n=1
for pont in $PONTS ; do
	[ $pont = $PONT0 ] && continue
	cat <<- FINAL > /etc/network/interfaces.d/hostBridge$n.conf
	auto $pont
	iface $pont inet manual
	bridge_fd 0
	bridge_maxwait 0
	bridge_stp off
FINAL
	n=$(($n+1))
done

fet=$(ls -C1 /etc/network/interfaces.d/hostBridge?.conf | wc -l)
nbr=$(echo $PONTS | wc -w)
falten=$(($nbr - $fet))
[ $falten -gt 0 ] && \
echoError "alguna ($falten) configuració de pont no s'ha pogut fer!" && exit 1

#chmod 644 /etc/network/interfaces.d/hostBridge?.conf

# Preparar la deshabilitació del NM per als ponts
if [ $tenimNM -gt 0 ]; then
	configNM="/etc/NetworkManager/NetworkManager.conf"

	# evitar que el NM gestioni les definides a interfaces
	ja=$(grep -n "\[ifupdown\]" $configNM | cut -f1 -d:)
	ja=${ja:-0}
	[ $ja -eq 0 ] && echo "\n[ifupdown]" >> $configNM

	sed -i "s/^managed=true/#managed=true/" $configNM
	ja=$(grep -c "managed=false" $configNM)
	[ $ja -eq 0 ] && echo "managed=false" >> $configNM

	ja=$(grep -c "\[keyfile\]" $configNM)
	if [ $ja -eq 0 ]; then
		echo "\n[keyfile]" >> $configNM
	fi
fi

echo "Fent les NICs els ponts: $PONTS"
# Paràmetre: el pont
evita_NM() {
	ja=$(grep -c "^unmanaged.*$1" $configNM)
	if [ $ja -eq 0 ]; then
		# seccio [keyfile] ja està posada (un sol cop)
		nlinia=$(grep -n "\[keyfile\]" $configNM | cut -f1 -d:)
		sed -i "${nlinia}a unmanaged-devices=interface-name:$br" $configNM
	fi

	ja=$(grep -c "^match.*$1" $configNM)
	if [ $ja -eq 0 ]; then
		echo "\n[device]" >> $configNM
		echo "match-device=interface-name:$br" >> $configNM
		echo "managed=no" >> $configNM
	fi
}

nbr=$(echo $PONTS | wc -w)
nom=$(echo $PONT0 | tr -d '0-9')
n=$(ip link | grep -o "$nom.:" | wc -l)
[ $n -eq $nbr ] && echoAvis "Ja tenim tots els ponts ($n) creats al host." && exit 0

for br in $PONTS
do
	ip link show $br >/dev/null 2>&1
	[ $? -eq 0 ] && continue

	echo "nou pont: $br"
	ip link add $br type bridge
	[ $tenimNM -gt 0 ] && evita_NM $br

	ip link set dev $br up

# comprovar que tot ha anat bé:
	ip link show $br >/dev/null 2>&1
	[ $? -eq 1 ] && echoError "el pont $br no s'ha creat !!\n" && exit 1
done

echoAvis "desconnectant temporalment $outINTF"
$relpath/canvia_estat_sortida.sh down
# tot i estar down poden quedar restes, p.e. a la rtable
ip address flush dev $outINTF

# punxar outINTF al pont
# sense IP però UP per a poder tenir Internet

echo "connectant $outINTF a un port del $PONT0"
ip link set dev $outINTF master $PONT0
ip link set dev $outINTF up
#ip -d link show enp0s3 | grep --color "master [^ ]*"

ifdown --force $PONT0
# no es podia posar en dhcp abans perque no estava connectat a la outINTF
sed -i "s/\(iface $PONT0 inet\) manual/\1 dhcp/" /etc/network/interfaces.d/hostBridge0.conf
# la IP la tindrà el pont
#ifquery --state $PONT0
#ip link show $PONT0
#ps aux | grep --color  "dhclient.*lxcbr0 "
ifup $PONT0

if [ $tenimNM -gt 0 ]; then
	echoAvis "... re-engego el NetworkManager"
	service NetworkManager restart
	nmcli dev set $outINTF managed no
fi

#ip -c a show $PONT0
#ip -c route

echo
exit 0
