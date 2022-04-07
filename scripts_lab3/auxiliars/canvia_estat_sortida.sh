#!/bin/sh

# Descripció:
# Posa la interfície de sortida UP o DOWN segons el paràmetre
# si ja ho està llavors no fa res, sols mostrar-ho
# Requisits: ifupdown, iproute2

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.3

echo "Exec: $0 $@\n"
[ $(id -u) -ne 0 ] && echo "$0: Has de ser root" && exit 1

definicions=$(find . -name "definicions.sh")
[ ! -x $definicions ] && echo "Falta el fitxer definicions.sh" && exit 1
. $definicions 2>/dev/null

accio='cap'
if [ $# -eq 1 ]; then
	accio=$1
fi
[ $accio != "up" -a $accio != "down" ] && echo "Us: $0 up|down" && exit 1

gestio=""
tenimNM=0
up=$(ip addr show $outINTF 2>/dev/null | grep -c UP)

#updown=$(grep -c "iface $outINTF" /etc/network/interfaces)
ifquery $outINTF 2>/dev/null
if [ $? -eq 0 ]; then
	gestio="ifupdown:"
#	up=$(ifquery --state $outINTF | wc -l) # podria creure que està UP i no ho estigués
	if [ $up -eq 0 -a $accio = "up" ]; then
		ifup --force $outINTF
	elif [ $up -eq 1 -a $accio = "down" ]; then
		ifdown --force $outINTF 
	else
		echo "$gestio $outINTF ja està $accio\n"
		exit 0
	fi
else
	tenimNM=$(service NetworkManager status 2>/dev/null | grep -ic running)
	if [ $tenimNM -eq 1 ]; then
		estat=$(nmcli -g GENERAL.STATE dev show $outINTF 2>/dev/null | tr -d '[0-9 ()]')
		nmcli -g GENERAL.STATE dev show $outINTF 2>/dev/null | tr -d '[0-9 ()]'
		nmcli -g GENERAL.STATE dev show $outINTF
		case $estat in
			"connected")
				up=1
				gestio="NetworkManager:"
				;;
			"disconnected")
				up=0
				gestio="NetworkManager:"
				;;
			"unmanaged")
				tenimNM=0
				;;
			*)	# unavailable ?
				echoError "NetworkManager: $outINTF estat desconegut: $estat\n"
				exit 1
		esac
		if [ $tenimNM -eq 1 ]; then
			if [ $up -eq 0 -a $accio = "up" ]; then
				nmcli dev connect $outINTF
			elif [ $up -eq 1 -a $accio = "down" ]; then
				nmcli dev disconnect $outINTF
			else
				echo "$gestio $outINTF ja està $accio\n"
				exit 0
			fi
		fi
	fi

# la resta en principi no cal. doncs als prerequisits hi ha el ifupdown
# però ho deixo per completitut

	if [ $tenimNM -eq 0 ]; then
		gestio="dhclient:"
		if [ $up -eq 0 -a $accio = "up" ]; then
			dhclient -4 $outINTF
			ip link set $outINTF up 
		elif [ $up -eq 1 -a $accio = "down" ]; then
			dhclient -r $outINTF
			ip link set $outINTF down
		else
			echo "$gestio $outINTF ja està $accio\n"
			exit 0
		fi
	fi
fi

# per si de cas tot falla:
if [ -z $gestio ]; then
	gestio="WARNING !"
	if [ $accio = "down" -o $up -gt 0 ]; then
		ip address flush dev $outINTF
		ip link set $outINTF down
	else
		ip link set $outINTF up 
	fi
fi

if [ $accio = "down" -o $up -gt 0 ]; then
	echo "\n$gestio he BAIXAT la interface $outINTF\n"
	exit 0	
else
	echo "\n$gestio he AIXECAT la interface $outINTF\n"
	exit 1
fi
