#!/bin/bash

# Descripció:
# Per a fer echo vermell dels errors i blau dels avisos

# s'ha d'incloure amb:
#. ./echo_colors.sh

# Us:
# echoError missatge
# echoAvis missatge

# Els codis no van bé per a bash

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.0

RED='\033[0;31m'
LRED='\033[1;31m'
BLUE='\033[0;34m'
LBLUE='\033[1;34m'
YLLW='\033[1;33m'
NOC='\033[0m' # No Color

# aquests després del color
BOLD=$(tput bold)
NORM=$(tput sgr0)

echoError() {
	missatge=$@
	header=$(echo $1 | grep -ic "^[^ :]\+:") 
	if [ $header -gt 0 ]; then
		header=$(echo $missatge | grep -o "^[^ :]\+:") 
		missatge=$(echo $missatge | cut -f2 -d:)
	else
		header="Error"
	fi
	echo "${LRED}${BOLD}$header: $missatge $NORM\n"
}

echoAvis() {
	missatge=$@
	header=$(echo $1 | grep -c ':')
	if [ $header -gt 0 ]; then
		header=$(echo $missatge | cut -f1 -d:)
		missatge=$(echo $missatge | cut -f2 -d:)
	else
		header="Avís"
	fi
	echo "${LBLUE}${BOLD}$header: $missatge $NORM"
}
