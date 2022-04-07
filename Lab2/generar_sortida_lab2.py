#!/bin/env python3
'''
    File name: genera_sortida_lab2.py
    Author: Josep M. Banús
    Subject: GSX
    Date created: 3/12/2022
    Version: 1.3
    Python Version: 3.7
'''

import subprocess

# necessito Internet per a poder instal.lar els mòduls
def comprovaInternet():
	command = ['ping', '-c' , '1', '1.1.1.1']
	inet= subprocess.run(command, stdout= subprocess.PIPE, stderr= subprocess.PIPE)
	if inet.returncode == 0:
#		print(inet.stdout.decode())
		pass
	else:
		print("Error: no tenim accés a Internet i necessito instal·lar mòduls python.")
		print(inet.stderr.decode('utf-8'))
		quit()

# importat algins mòduls que podria ser no els tinguessin instal.lats
try:
	import json, docker , requests
except ModuleNotFoundError as e:
	modul= str(e).split("'")[1]
	print("Error en importar el mòdul:", modul)
	comprovaInternet()
	subprocess.os.system('sudo apt install --no-install-recommends -y python3-'+modul)
	print("\n\nTorna'm a executar !")
	quit()

# fitxer on es guardarà el resultat
sortida='./sortida_lab2.txt'
if subprocess.os.path.isfile(sortida):
	subprocess.os.system('rm -i '+sortida)
try:
	log= open(sortida, 'w')
except OSError as e:
	print("Error: no he pogut obrir per escriure el fitxer ", sortida)
	print(e)
	quit()

# el nom que hi diu a l'enunciat
contenidor='servei-web'

client = docker.APIClient(base_url='unix://var/run/docker.sock')
conf = client.inspect_container(contenidor)

# Mostrar tota la informació en json
print("La informació del contenidor és:", file=log)
print(json.dumps(conf, indent=4), file=log)

# per si no tinguessin definada la xarxa DMZ
print("\nLes networks i IPs son:", file=log)
for net in conf['NetworkSettings']['Networks']:
	print(net , conf['NetworkSettings']['Networks'][net]['IPAddress'], file=log)

ip=conf['NetworkSettings']['Networks']['DMZ']['IPAddress']

resposta= requests.get('http://localhost:8080')
print("\nLa web normal retorna:", resposta.status_code, file=log)
print(resposta.text, file=log)
resposta.close()

resposta= requests.get('http://'+ip+'/welcome.html')
print("\nLa web extra a", ip, "retorna:", resposta.status_code, file=log)
print(resposta.request.url, file=log)
print(resposta.headers, file=log)
print(resposta.text, file=log)
resposta.close()
log.close()
print("Podeu trobar el resultat a:", sortida)
