#!/bin/sh

# Descripció:
# executa un dels contenidors de GSX passat per paràmetre

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.1

echo "Exec: $0 $@\n"
[ $(id -u) -ne 0 ] && echo "$0: Has de ser root" && exit 1

definicions=$(find . -name "definicions.sh")
[ ! -x $definicions ] && echo "Falta el fitxer definicions.sh" && exit 1
. $definicions 2>/dev/null

params=$(echo $NODES | tr ' ' '|')
[ $# -eq 0 ] && echoAvis "Us: $0 $params" && exit 1

node=$1
existeix=$(lxc-ls $node | wc -l)
[ $existeix -ne 1 ] && echoError "el node '$node' no existeix. Cal crear-lo" && exit 1

executant=$(lxc-ls --running $node | wc -l)
if [ $executant -eq 0 ]; then
	lxc-start $node -l trace -o /tmp/debug_$node.out
	echo "Fet. Logs a :/tmp/debug_$node.out"
else
	echoAvis "el node '$node' ja s'està executant"
fi

executant=$(lxc-ls --running $node | wc -l)
[ $executant -eq 0 ] && echoError "alguna cossa no va bé. El node '$node' NO s'està executant" && exit 1

ja=$(ps aux | grep -v grep | grep -c "lxc-attach $node")

if [ $ja -gt 0 ]; then
	echoAvis "\nJa tens $ja terminals amb prompt a $node."
	read -p "Entra una s si vols tenir-ne un de nou : " seguir
	[ "$seguir" != "s" ] && echo "doncs no ho faig." && exit 0
fi

# establir el títol de la finestra per a una identificació fàcil
titol=$(echo $node | tr "a-z" "A-Z")
echo "\033]0;$titol\007"


lxc-attach $node
echo

# reset terminal title
echo "\033]0;\007"
exit 0
