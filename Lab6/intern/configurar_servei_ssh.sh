#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 2 de maig del 2022. Versió: 1.
# Descripció: Es comprova si està instal·lat el servei ssh i, en cas negatiu, s'instal·la i es comprova si l'instal·lació ha estat correcta. Després s'activa i es reengega el servei.

dpkg -s openssh-server
if [ $(echo $?) -eq 1 ]
then
	echo -e "\nINSTAL·LACIÓ OPENSSH-SERVER\n"
	apt install -y openssh-server
	echo -e "\nESTAT OPENSSH-SERVER\n"
	service ssh status
	if [ $(echo $?) -eq 4 ]
	then
		exit 1
	fi
fi
# Cal afegir la línia 'PermitRootLogin yes' al fitxer sshd_config.
cp -p sshd_config /etc/ssh
service ssh restart

# Per crear arxius a una màquina des d'una altra, per exemple, des al server des del router, s'executa la comanda 'ssh root@server' i es creen els arxius pertinents.
# Per passar arxius des d'una màquina a una altra, per exemple, des del router al server, s'executa la comanda 'ssh -rvp router root@server:/home/milax/'.
