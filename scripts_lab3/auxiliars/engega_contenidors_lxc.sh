#!/bin/sh

# Descripció:
# executa els contenidors virtual i obre els terminals corresponents

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.3

[ $(id -u) -ne 0 ] && echo "$0: Has de ser root" && exit 1

echo "Exec: $0\n"
definicions=$(find . -name "definicions.sh")
[ ! -x $definicions ] && echo "Falta el fitxer definicions.sh" && exit 1
. $definicions 2>/dev/null

fitxer="$relpath/executa_contenidor_lxc.sh"
[ ! -x $fitxer ] && echoError "Falta el fitxer $fitxer" && exit 1

sense_term=0
# prefereixo gnome-terminal pel copy&paste
term=$(which gnome-terminal)
if [ ${#term} -ne 0 ]; then
	termcmd=gnome-terminal
	OpcionsTerm=""
else
	term=$(which xterm)
	if [ ${#term} -ne 0 ]; then
		termcmd=xterm
		OpcionsTerm="-u8 -fa 'Monospace' -fs 14 -class UXTerm"
	else
		echoAvis "no trobo cap terminal. Sols fare echos de les commandes."
		sense_term=1
	fi
fi

comanda="$relpath/executa_contenidor_lxc.sh"

for node in $NODES
do
	executant=$(lxc-ls --running $node | wc -l)
	if [ $executant -eq 1 ]; then
		attached=$(ps a | grep -v grep | grep -o "lxc-attach $node" | cut -f2 -d' ')
		if [ "$attached" = "$node" ]; then
			echoAvis "ja tens un terminal obert per $node"
			continue
		fi
		comanda="lxc-attach"
	fi

	if [ $sense_term -eq 1 ]; then 
		sudo $comanda $node
		exit 0
	else # tenim xterms
		echo "\nObrint un terminal per a '$node'"
		if [ "$termcmd" = "xterm" ]; then
			xterm $OpcionsTerm -e $comanda $node &

		else
			gnome-terminal $OpcionsTerm >/dev/null -- $comanda $node
		fi
		sleep 1
	fi
done

# comprovar que els tenim executant-se
for node in $NODES
do
	running=$(lxc-ls --running | grep -c "\<$node\>")
	if [ $running -eq 0 ]; then
		echoError "El '$node' no està executant-se !"
	fi
done

queden=$(lxc-ls --running | wc -w)
if [ $queden -gt 0 ]; then
	echo "\nS'estan executant els següents contenidors:"
	lxc-ls --running
	echoAvis "Recorda: sortir del terminal amb 'exit' no atura el contenidor!"
	exit 0
else
	echoError "No hi ha cap contenidor executant-se !"
	echo
	exit 1
fi
