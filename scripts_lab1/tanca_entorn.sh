#!/bin/sh

# Descripció:
# Elimina tot l'entorn de les pràctiques de la part de xarxes
# Per a començar des de zero.

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 1.0

cd auxiliars/
sudo ./elimina_gsx_lxc.sh

./comprova_internet.sh

cd -
exit 0
