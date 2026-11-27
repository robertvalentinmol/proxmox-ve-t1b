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

# Cada servidor publica una página con su nombre, su IP y su propio color
PLANTILLA_WEB="$(dirname "$(readlink -f "$0")")/pagina.html"
COLORES=("ff6a2b ffb03a ff3d7f" "4d63ff 7aa2ff 6d3bff" "12a15a 5fe0a8 0f7a8a" "a03bff d08bff 5a2bd6" "1690d8 6ad5ff 2b4dd6")
for i in $(seq 1 "$N"); do
    ID=$((200 + i))
    read -r C1 C2 C3 <<< "${COLORES[$(( (i - 1) % ${#COLORES[@]} ))]}"
    if [ -f "$PLANTILLA_WEB" ]; then
        sed -e "s/{{NOMBRE}}/web$i/g" -e "s/{{NUM}}/$i/g" -e "s/{{IP}}/${RED}.$((10 + i))/g" -e "s/{{CT}}/$ID/g" \
            -e "s/{{HORA}}/$(date +%H:%M:%S)/g" -e "s/{{C1}}/$C1/g" -e "s/{{C2}}/$C2/g" -e "s/{{C3}}/$C3/g" \
            "$PLANTILLA_WEB" > /tmp/web$i.html
        pct push $ID /tmp/web$i.html /var/www/html/index.html --perms 0644
        rm -f /tmp/web$i.html
    else
        pct exec $ID -- sh -c 'echo "<h1>Hola desde $(hostname)</h1>" > /var/www/html/index.html'
    fi
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
    curl -s "http://${RED}.$((10 + i))" | grep -o '<h1>.*</h1>'
done
