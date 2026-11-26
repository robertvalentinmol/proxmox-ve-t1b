#!/bin/bash
# EI1044 · Grupo T1B · Proxmox VE
# Comprueba que el entorno está listo para la demo en directo.
# Solo lee: no cambia nada.
# Uso (en la Shell de cualquier nodo):  bash 00_comprobar_entorno.sh [ID_VM]   (por defecto 101)

VM=${1:-101}
FALLOS=0

ok()    { echo "  ✔ $1"; }
fallo() { echo "  ✘ $1"; FALLOS=$((FALLOS + 1)); }
aviso() { echo "  ! $1"; }

echo "== Clúster"
if pvecm status 2>/dev/null | grep -q "Quorate:.*Yes"; then
    NODOS=$(pvecm nodes 2>/dev/null | awk '$1 ~ /^[0-9]+$/' | wc -l)
    ok "Clúster con quórum ($NODOS nodos)"
else
    fallo "El clúster no tiene quórum (pvecm status). Con 2 nodos, ¿están los dos encendidos?"
fi

echo "== VM $VM (migración)"
CONF=$(ls /etc/pve/nodes/*/qemu-server/"$VM".conf 2>/dev/null | head -n 1)
if [ -z "$CONF" ]; then
    fallo "No existe la VM $VM"
else
    NODO=$(echo "$CONF" | cut -d/ -f5)
    ok "La VM $VM está en el nodo '$NODO'"
    [ "$NODO" = "$(hostname)" ] || aviso "Esta Shell es de '$(hostname)'; la ida se lanza desde '$NODO'"

    if grep -E '^(ide|sata|scsi)[0-9]+:' "$CONF" | grep 'media=cdrom' | grep -qv ': none,'; then
        fallo "Hay una ISO montada en la unidad de CD: Hardware > CD/DVD > No usar ningún medio"
    else
        ok "Sin ISO montada"
    fi

    CPU=$(awk -F': ' '/^cpu:/ {print $2}' "$CONF")
    case "$CPU" in
        *host*) fallo "Tipo de CPU 'host': cambiadlo a x86-64-v2-AES" ;;
        "")     ok "Tipo de CPU por defecto" ;;
        *)      ok "Tipo de CPU: $CPU" ;;
    esac

    if grep -qE "^vm: *$VM\$" /etc/pve/ha/resources.cfg 2>/dev/null; then
        aviso "La VM $VM está en HA: la migración pasará por el gestor de HA"
    fi

    if grep -E '^(scsi|virtio|sata|ide)[0-9]+:' "$CONF" | grep -v 'media=cdrom' | grep -q 'local'; then
        aviso "Disco en almacenamiento local: la migración copiará también el disco (--with-local-disks)"
    fi
fi

echo "== Script de despliegue"
if ls /etc/pve/nodes/*/lxc/900.conf >/dev/null 2>&1 && grep -q '^template: 1' /etc/pve/nodes/*/lxc/900.conf; then
    ok "Plantilla 900 preparada"
else
    fallo "Falta la plantilla 900: bash despliegue/01_preparar_plantilla.sh (necesita internet)"
fi

QUEDAN=""
for ID in 201 202 203 204 205; do
    ls /etc/pve/nodes/*/lxc/"$ID".conf >/dev/null 2>&1 && QUEDAN="$QUEDAN $ID"
done
if [ -n "$QUEDAN" ]; then
    fallo "Quedan contenedores de un ensayo anterior:$QUEDAN (bash despliegue/03_limpiar.sh)"
else
    ok "Sin restos de ensayos anteriores"
fi

if ip link show vmbr1 >/dev/null 2>&1; then
    ok "Red interna vmbr1 creada"
else
    aviso "No existe vmbr1 en este nodo (el script se lanza en el nodo de la plantilla)"
fi

echo "== Recursos de este nodo"
LIBRE=$(free -m | awk '/^Mem:/ {print $7}')
if [ "$LIBRE" -lt 700 ]; then
    fallo "Solo quedan ${LIBRE} MB de RAM disponibles"
else
    ok "${LIBRE} MB de RAM disponibles"
fi

echo
if [ "$FALLOS" -eq 0 ]; then
    echo "Todo listo para la demo."
else
    echo "Hay $FALLOS problema(s) que resolver antes de la demo."
    exit 1
fi
