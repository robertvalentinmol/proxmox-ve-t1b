#!/bin/bash
# EI1044 · Grupo T1B · Proxmox VE
# Migra en caliente una VM a otro nodo y resume cuánto ha tardado.
# Si el disco está en almacenamiento local, añade --with-local-disks.
# Hay que lanzarlo en el nodo donde está la VM ahora.
# Uso:  bash migrar.sh <ID_VM> <nodo_destino>      Ej.: bash migrar.sh 101 pve
set -o pipefail

VM=$1
DESTINO=$2
if [ -z "$VM" ] || [ -z "$DESTINO" ]; then
    echo "Uso: bash migrar.sh <ID_VM> <nodo_destino>"
    exit 1
fi

CONF=$(ls /etc/pve/nodes/*/qemu-server/"$VM".conf 2>/dev/null | head -n 1)
if [ -z "$CONF" ]; then
    echo "No existe la VM $VM"
    exit 1
fi
ORIGEN=$(echo "$CONF" | cut -d/ -f5)
if [ "$ORIGEN" != "$(hostname)" ]; then
    echo "La VM $VM está en '$ORIGEN'. Lanza este script desde la Shell de '$ORIGEN'."
    exit 1
fi
if [ "$ORIGEN" = "$DESTINO" ]; then
    echo "La VM $VM ya está en '$DESTINO'."
    exit 1
fi

OPCIONES="--online"
if grep -E '^(scsi|virtio|sata|ide)[0-9]+:' "$CONF" | grep -v 'media=cdrom' | grep -q 'local'; then
    OPCIONES="$OPCIONES --with-local-disks"
fi

LOG=$(mktemp)
echo ">> qm migrate $VM $DESTINO $OPCIONES"
INICIO=$(date +%s.%N)
qm migrate "$VM" "$DESTINO" $OPCIONES 2>&1 | tee "$LOG"
RESULTADO=$?
FIN=$(date +%s.%N)

echo
echo "================ Resumen ================"
printf "VM %s: %s -> %s\n" "$VM" "$ORIGEN" "$DESTINO"
awk -v i="$INICIO" -v f="$FIN" 'BEGIN {printf "Tiempo total:  %.1f s\n", f - i}'
DOWNTIME=$(grep -o 'downtime [0-9]* ms' "$LOG" | tail -n 1)
[ -n "$DOWNTIME" ] && echo "Tiempo parada: ${DOWNTIME#downtime }"
if [ "$RESULTADO" -eq 0 ] && grep -q 'migration finished successfully' "$LOG"; then
    echo "Estado:        OK"
else
    echo "Estado:        ERROR (revisa el registro de arriba)"
fi
rm -f "$LOG"
exit $RESULTADO
