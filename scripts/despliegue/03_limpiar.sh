#!/bin/bash
# EI1044 · Grupo T1B · Proxmox VE
# Borra los servidores creados por 02_desplegar.sh, para poder repetir la demo.
# No toca la plantilla 900.
# Uso:  bash 03_limpiar.sh      (o  bash 03_limpiar.sh 8  si desplegaste 8)
N=${1:-5}

for i in $(seq 1 "$N"); do
    ID=$((200 + i))
    if pct status $ID >/dev/null 2>&1; then
        pct stop $ID 2>/dev/null
        pct destroy $ID
        echo ">> CT $ID (web$i) eliminado"
    fi
done
