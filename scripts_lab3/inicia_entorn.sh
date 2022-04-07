#!/bin/sh

# Descripció:
# Crea tot l'entorn per a les pràctiques de la part de xarxes (containers i la xarxa)

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.1

cd auxiliars/
./prepara_requisits.sh
[ $? -ne 0 ] && exit 1

./crea_contenidors.sh
[ $? -ne 0 ] && exit 1

./gsxnet_host.sh
[ $? -ne 0 ] && exit 1

./gsxnet_guests.sh
[ $? -ne 0 ] && exit 1

./comprova_internet.sh
#[ $? -ne 0 ] && exit 1
# per anar fent internament no és imprescindible tenir Internet

./engega_contenidors_lxc.sh 2>/dev/null
[ $? -ne 0 ] && exit 1
cd -

echo "Per acabar useu:"
echo "sudo auxiliars/atura_contenidors_lxc.sh [node]"
echo 

echo "Per a netejar-ho tot useu:"
echo "sudo auxiliars/elimina_gsx_lxc.sh"
echo 
exit 0


