#!/bin/bash
# EI1044 · Grupo T1B · Proxmox VE
# Ransomware SIMULADO para la demo: no cifra nada.
#   1. Renombra los ficheros de la web del CT 100 añadiéndoles .locked.
#   2. Pone en su lugar una nota de rescate (demo/web-tienda/hackeada.html).
# Se deshace restaurando el CT 100 desde su backup (pct restore ... --force).
# Uso, en la Shell del nodo:  bash ~/proxmox-ve-t1b/scripts/ransomware/ataque.sh
set -e

CT=100
WEB=/var/www/html
NOTA="$(dirname "$(readlink -f "$0")")/../../demo/web-tienda/hackeada.html"

[ -f "$NOTA" ] || { echo "No encuentro la nota de rescate: $NOTA"; exit 1; }
pct status $CT | grep -q running || { echo "El CT $CT no está encendido: pct start $CT"; exit 1; }

pct exec $CT -- bash -c "cd $WEB && for f in *; do [ -e \"\$f\" ] && mv \"\$f\" \"\$f.locked\"; done"
pct push $CT "$NOTA" $WEB/index.html --perms 0644
