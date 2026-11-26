#!/bin/bash
# EI1044 · Grupo T1B · Proxmox VE
# Despliega N servidores web (5 por defecto) clonando la plantilla 900.
# Los clones son enlazados (copy-on-write): no copian el disco, por eso tardan segundos.
# Uso:  bash 02_desplegar.sh      (o  bash 02_desplegar.sh 8  para 8 servidores)
set -e

TPL=900
N=${1:-5}
RED=192.168.100
INICIO=$(date +%s)

for i in $(seq 1 "$N"); do
    ID=$((200 + i))
    IP=${RED}.$((10 + i))
    echo ">> web$i  (CT $ID, $IP)"
    pct clone $TPL $ID --hostname web$i >/dev/null
    pct set $ID --net0 name=eth0,bridge=vmbr1,ip=${IP}/24,gw=${RED}.1
    pct start $ID
done

# Cada servidor publica una página con su propio nombre
for i in $(seq 1 "$N"); do
    pct exec $((200 + i)) -- sh -c 'echo "<h1>Hola desde $(hostname)</h1>" > /var/www/html/index.html'
done

# Esperar a que todos respondan (máximo 30 s cada uno)
for i in $(seq 1 "$N"); do
    for intento in $(seq 1 60); do
        curl -s -o /dev/null "http://${RED}.$((10 + i))" && break
        sleep 0.5
    done
done

FIN=$(date +%s)
echo
echo "=== $N servidores desplegados en $((FIN - INICIO)) segundos ==="
echo
for i in $(seq 1 "$N"); do
    printf "%-16s " "${RED}.$((10 + i))"
    curl -s "http://${RED}.$((10 + i))"
done
