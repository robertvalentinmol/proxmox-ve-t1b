#!/bin/bash
# EI1044 · Grupo T1B · Proxmox VE
# Prepara (una sola vez) lo necesario para desplegar servidores web en segundos:
#   1. Una red interna vmbr1 (192.168.100.0/24) con salida a internet por NAT.
#   2. Un contenedor plantilla (ID 900) con nginx ya instalado.
# Se ejecuta en la Shell del nodo, como root:  bash 01_preparar_plantilla.sh
set -e

TPL=900
RED=192.168.100

# --- 1. Red interna vmbr1 con NAT (masquerading) -----------------------------
if ! grep -q "vmbr1" /etc/network/interfaces; then
    SALIDA=$(ip route show default | awk '{print $5; exit}')   # interfaz con internet
    echo ">> Creando vmbr1 (${RED}.1/24), con salida por ${SALIDA}"
    cat >> /etc/network/interfaces <<EOF

auto vmbr1
iface vmbr1 inet static
        address ${RED}.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0
        post-up   echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up   iptables -t nat -A POSTROUTING -s '${RED}.0/24' -o ${SALIDA} -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '${RED}.0/24' -o ${SALIDA} -j MASQUERADE
EOF
    ifreload -a
else
    echo ">> vmbr1 ya existe, no se toca"
fi

# --- 2. Contenedor plantilla con nginx ---------------------------------------
if pct status $TPL >/dev/null 2>&1; then
    echo ">> El CT $TPL ya existe. Si quieres rehacerlo: pct destroy $TPL"
    exit 0
fi

PLANTILLA_SO=$(pveam list local | awk '/debian-12-standard/ {print $1; exit}')
if [ -z "$PLANTILLA_SO" ]; then
    echo ">> No encuentro la plantilla Debian 12 en 'local'."
    echo "   Descárgala en: nodo > local > Plantillas de CT > Plantillas > debian-12-standard"
    exit 1
fi

echo ">> Creando el CT $TPL a partir de $PLANTILLA_SO"
pct create $TPL "$PLANTILLA_SO" \
    --hostname plantilla-web --memory 256 --cores 1 \
    --rootfs local-lvm:4 --unprivileged 1 \
    --net0 name=eth0,bridge=vmbr1,ip=${RED}.9/24,gw=${RED}.1 \
    --nameserver 8.8.8.8

pct start $TPL
sleep 5
echo ">> Instalando nginx dentro de la plantilla"
pct exec $TPL -- bash -c "apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nginx && systemctl enable nginx"
pct stop $TPL

echo ">> Convirtiendo el CT $TPL en plantilla"
pct template $TPL
echo ">> Listo. Ya puedes ejecutar: bash 02_desplegar.sh"
