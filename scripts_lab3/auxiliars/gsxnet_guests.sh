#!/bin/sh

# Descripció:
# Un cop creats i configurats els ponts al host
# connecta cada contenidor/guest/VM als ponts
# creant la infraestructura de xarxa.

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# versió: 1.2

echo "Exec: $0\n"
[ $(id -u) -ne 0 ] && echo "$0: Has de ser root" && exit 1

definicions=$(find . -name "definicions.sh")
[ ! -x $definicions ] && echo "Falta el fitxer definicions.sh" && exit 1
. $definicions 2>/dev/null

# comprovar que tot està a punt
nbr=$(echo $PONTS | wc -w)
n=$(ls  -l /etc/network/interfaces.d/hostBridge* | wc -l)
[ $n -ne $nbr ] && echoError "no hi ha tots els ponts creats al host, sols $n de $nbr." && exit 1

n=$(ip link show dev $outINTF | grep -o lxcbr | wc -w)
[ $n -eq 0 ] && echoError "La intf de sortida no està connectada al pont" && exit 1

# una pota del router va a la xarxa externa i les altres a les xarxes internes
 
connecta_router2ponts() {
	# el fitxer /var/lib/lxc/$ROUTER/config es crea en fer lxc-create
	existeix=$(grep -c "GSX" /var/lib/lxc/$ROUTER/config)
	[ $existeix -ne 0 ] && echoAvis "ja existeix la config del node: '$ROUTER'. Considera eliminar-la\n" && return

	if [ ! -z $PONT0 ]; then
		cat <<- FINAL >> /var/lib/lxc/$ROUTER/config
			# GSX configured
			lxc.net.0.type = veth
			lxc.net.0.veth.pair = eth_${ROUTER}_$nomPONT0
			lxc.net.0.flags = up
			lxc.net.0.link = $PONT0
			lxc.net.0.name = eth0

		FINAL
	fi
	if [ ! -z $PONT1 ]; then
		cat <<- FINAL >> /var/lib/lxc/$ROUTER/config
			lxc.net.1.type = veth
			lxc.net.1.veth.pair = eth_${ROUTER}_$nomPONT1
			lxc.net.1.flags = up
			lxc.net.1.link = $PONT1
			lxc.net.1.name = eth1
		FINAL
	fi
	if [ ! -z $PONT2 ]; then
		cat <<- FINAL >> /var/lib/lxc/$ROUTER/config
			# GSX configured
			lxc.net.2.type = veth
			lxc.net.2.veth.pair = eth_${ROUTER}_$nomPONT2
			lxc.net.2.flags = up
			lxc.net.2.link = $PONT2
			lxc.net.2.name = eth2
		FINAL
	fi
	echo "# EOF GSX net config" >> /var/lib/lxc/$ROUTER/config

	fet=$(grep -c "GSX configured" /var/lib/lxc/$ROUTER/config)
	[ $fet -eq 0 ] && echoError "$ROUTER no he pogut configurar la xarxa del $ROUTER al host !" && exit 1
}

connecta_router2ponts

# la resta de nodes sols una intf connetada a un pont

connecta_vm2pont() {
	node=$1
	pont=$2
	existeix=$(grep -c "GSX" /var/lib/lxc/$node/config)
	[ $existeix -ne 0 ] && echoAvis "ja existeix la config del node: '$node'. Considera eliminar-la\n" && return
	cat <<- FINAL >> /var/lib/lxc/$node/config
		# GSX configured
		lxc.net.0.type = veth
		lxc.net.0.veth.pair = eth_$node
		lxc.net.0.flags = up
		lxc.net.0.link = $pont
		lxc.net.0.name = eth0
		# EOF GSX net config
	FINAL
	fet=$(grep -c "GSX configured" /var/lib/lxc/$node/config)
	[ $fet -eq 0 ] && echoError "$node no he pogut configurar la xarxa del $node al host !" && exit 1
}

n=0
for node in $NODES
do
	[ "$node" = "$ROUTER" ] && continue
	n=$(($n+1))

	vm=$(grep "^NODE$n" $definicions | cut -f2 -d=)
	br=$(grep "^PONT$n" $definicions | cut -f2 -d=)
	if [ ! -z $vm ]; then
		connecta_vm2pont $vm $br
	fi
done

echo
lxc-ls --fancy
#echo 
#lxc-info $ROUTER | grep "IP\|Link"
echo

exit 0

