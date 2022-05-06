#!/bin/sh

# Descripció:
# Crear els contenidors i configurar la xarxa.

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.3
# Lab03: host amb Client <-> Router <-> Server

echo "Exec: $0\n"
[ $(id -u) -ne 0 ] && echo "$0: Has de ser root" && exit 1

definicions=$(find . -name "definicions.sh")
[ ! -x $definicions ] && echo "Falta el fitxer definicions.sh" && exit 1
. $definicions info

# comprovar els requisits (els paquets ja es miren a prepara_requisits.sh)
dpkg-query --status lxc >/dev/null 2>&1
if [ $? -ne 0 ]; then
	apt-get update
	apt-get install -y lxc debootstrap
fi

espai=$(df -h  | grep "/$" | tr -s ' ' | cut -f 4 -d' ')
units=$(echo $espai | tr -d [0-9])
mida=$(echo $espai | tr -d [A-Z])
if [ $units != 'G' -a $mida -lt 4 ]; then
	echoError "Sembla que $espai de disc lliure no es sufucient per a fer les pràctiques."
	exit 1
fi

paquets="bind9-host,bind9utils,curl,dhcpdump,dnsutils,gawk,iptables,iputils-ping,iputils-tracepath,links,nano,netcat,nmap,openssh-client,patch,perl-base,procps,sudo,tcpdump,telnet,traceroute,tree,vim,wget"

opcions="--enable-non-free --packages=$paquets"

echo
echo "Creo els contenidors de les VMs: "

existeix=$(lxc-ls $ROUTER | grep -c $ROUTER)
if [ $existeix -eq 0 ]; then
	echo "Creant el node: '$ROUTER' ..."
	lxc-create --logpriority=INFO -t debian $ROUTER -- -r buster $opcions
	# ha anat bé ?
	existeix=$(lxc-ls $ROUTER | grep -c $ROUTER)
	[ $existeix -eq 0 ] && echoError "no s'ha creat el node: '$ROUTER'" && exit 1
fi

for node in $NODES
do
	existeix=$(lxc-ls $node | grep -c $node)
	if [ $existeix -eq 0 ]; then
		echo "Clonant  el node : '$node ...'"
		lxc-copy -o /tmp/debug_clona_lxc.txt $ROUTER --newname $node
		existeix=$(lxc-ls $node | grep -c $node)
		if [ $existeix -eq 0 ]; then
			echoError "no s'ha creat $node"
			echo "S'està executant le $ROUTER llavors convé aturar-lo."
			lxc-ls --fancy 
			exit 1
		fi
		# el nom del contenidor canvia, però el del etc NO !
		echo $node > /var/lib/lxc/$node/rootfs/etc/hostname
	else
		echo "Ja existeix el node: '$node'"
	fi
done

# per si ja hi havia nodes: eliminar config xarxa
for node in $NODES
do
	existeix=$(lxc-ls $node | grep -c $node)
	if [ $existeix -eq 1 ]; then
		ja=$(grep -c "GSX" /var/lib/lxc/$node/config)
		if [ $ja -gt 0 ]; then
		# eliminar bloc # GSX --> # EOF GSX
			ini=$(grep -n "GSX" /var/lib/lxc/$node/config | head -1 | cut -f1 -d:)
			fin=$(grep -n "GSX" /var/lib/lxc/$node/config | tail -1 | cut -f1 -d:)
			sed -i "$ini,${fin}d" /var/lib/lxc/$node/config
		fi
	fi
done
exit 0
