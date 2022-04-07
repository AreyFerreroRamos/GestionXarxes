#!/bin/sh

# Descripció:
# mostra la info de xarxa i prova pings i dns.

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.1

definicions=$(find . -name "definicions.sh")
[ ! -x $definicions ] && echo "Falta el fitxer definicions.sh" && exit 1
. $definicions 

echo "\nEstat actual:\n"
ip -c address show $outINTF
echo
ip -c route

echo "\nProvant pings cap a Internet..."
ping -c2 -W1 1.1.1.1 1>/tmp/sortida.txt 2>&1
no=$?

if [ $no -ne 0 ]; then
	echoError "FATAL !! \nping retorna:"
	cat /tmp/sortida.txt 
else
	echoAvis "OK"
	tail -1 /tmp/sortida.txt

	echo "\nProvant la resolució de noms..."
	host -4 -W1 www.urv.cat 1>/tmp/sortida.txt 2>&1
	no=$?
	if [ $no -ne 0 ]; then
		echoError "FALLA el DNS i retorna:"
		cat /tmp/sortida.txt
	else
		echoAvis "OK"
	fi
	tail -1 /tmp/sortida.txt
fi
rm /tmp/sortida.txt

echo
exit $no
