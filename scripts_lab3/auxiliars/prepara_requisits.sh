#!/bin/sh

# Descripció:
# Comprova que estem a un Debian-like i
# instal.la els paquets que necessitarem al amfitrió.
# Amb sort anirà tot bé a la VM milax@casa + Virtualbox

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# versió: 1.4

echo "Exec: $0\n"
[ $(id -u) -ne 0 ] && echo "$0: Has de ser root" && exit 1

definicions=$(find . -name "definicions.sh")
[ ! -x $definicions ] && echo "Falta el fitxer definicions.sh" && exit 1
. $definicions 2>/dev/null

debianLike=$(grep -i "debian\|ubuntu" /etc/os-release 2>/dev/null | wc -l)
[ $debianLike -eq 0 ] && \
echoError "Necessito un Debian per a poder crear els contenidors." && exit 1

distro=$(grep "^ID=" /etc/os-release | cut -f2 -d=)
[ "$distro" = "" ] && distro=$(grep "^ID_LIKE=" /etc/os-release | cut -f2 -d=)

# llista de paquets necessaris al host:
paquets="isc-dhcp-client iproute2 ifupdown lxc lxc-templates debootstrap $distro-keyring xterm rsync apparmor links"

for paq in $paquets
do
	dpkg-query --status $paq >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echoAvis "cal instal.lar el paquet $paq"
		necessito=$necessito" "$paq
	fi
done

if [ ${#necessito} -gt 0 ]; then
	read -p "Instal.lo els paquets $necessito [Y,n] ? " fes
	fes=${fes:-'y'}
	if [ $fes = 'y' -o $fes = 'Y' ]; then
		apt-get update
		apt-get install --no-install-recommends -y $necessito
	else
		exit 1
	fi
else
	echo "Perfecte: tenim els paquets que necessitem."
fi

echo
exit 0
