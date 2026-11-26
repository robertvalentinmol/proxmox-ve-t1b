#!/bin/bash
# EI1044 · Grupo T1B · Proxmox VE
# Descarga e instala cv4pve-autosnap (comandos del README oficial del proyecto).
# Uso (Shell del nodo, como root, con internet):  bash 02_instalar_autosnap.sh
set -e

cd /root
apt-get install -y unzip
wget -q --show-progress https://github.com/Corsinvest/cv4pve-autosnap/releases/latest/download/cv4pve-autosnap-linux-x64.zip
unzip -o cv4pve-autosnap-linux-x64.zip
chmod +x cv4pve-autosnap
mv cv4pve-autosnap /usr/local/bin/
rm -f cv4pve-autosnap-linux-x64.zip

cv4pve-autosnap --version
