#!/bin/bash

# Autor: Arey Ferrero Ramos.
# Data: 2 de maig del 2022. Versió: 1.
# Descripció: Es comprova si està instal·lat el paquet rsyslog i, en cas negatiu, s'instal·la i es comprova si la instal·lació ha estat correcte.

service rsyslog status
if [ $(echo $?) -eq 4 ]
then
	echo -e "\nINSTAL·LACIÓ RSYSLOG\n"
	apt install rsyslog
	echo -e "\nESTAT RSYSLOG\n"
	service rsyslog status
fi
