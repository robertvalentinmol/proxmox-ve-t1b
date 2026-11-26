#!/bin/bash
# EI1044 · Grupo T1B · Proxmox VE
# Crea un usuario y un token de API con los permisos justos para cv4pve-autosnap.
# Privilegios según https://corsinvest.github.io/cv4pve-autosnap/permissions/
#   VM.Audit y VM.Snapshot sobre /vms, Datastore.Audit sobre /storage
# Uso (Shell del nodo, como root):  bash 01_usuario_token.sh
# IMPORTANTE: el secreto del token se muestra UNA sola vez. Copiadlo y no lo subáis a GitHub.
set -e

pveum role add AutoSnap --privs "VM.Audit VM.Snapshot Datastore.Audit"
pveum user add autosnap@pve --comment "Snapshots programados (cv4pve-autosnap)"
pveum acl modify /vms --users autosnap@pve --roles AutoSnap
pveum acl modify /storage --users autosnap@pve --roles AutoSnap

# --privsep 0: el token hereda los permisos del usuario.
# Con separación de privilegios habría que dar el rol también al token.
pveum user token add autosnap@pve snap --privsep 0

echo
echo "Copiad el 'value' de arriba y definid la variable (con comillas simples, sin < >):"
echo "  TOKEN='autosnap@pve!snap=<value>'"
