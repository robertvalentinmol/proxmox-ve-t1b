# Script: 5 servidores web en segundos (en directo · Raúl)

Objetivo: desplegar 5 servidores web y enseñarlos respondiendo, en unos 20–30 segundos. Duración del bloque: **3:00**.

**El truco:** no se instala nada al desplegar. Se clona una **plantilla** de contenedor que ya tiene nginx, con **clones enlazados** (*copy-on-write*): el clon no copia el disco, solo guarda lo que cambia. Por eso tarda segundos y no minutos.

## Preparación (una vez, en casa, con internet)

En la Shell de `pve`:

```bash
bash scripts/despliegue/01_preparar_plantilla.sh
```

Hace dos cosas:

1. Crea la red interna `vmbr1` (`192.168.100.0/24`) con salida a internet por NAT a través del nodo.
2. Crea el contenedor `900` a partir de la plantilla Debian 12, le instala nginx y lo convierte en plantilla.

Requisitos: la plantilla `debian-12-standard` descargada en `local` (*local → Plantillas de CT → Plantillas*) y que el nodo tenga internet.

Para copiar los scripts al nodo, lo más sencillo es crear cada fichero con `nano <nombre>.sh` en la Shell y pegar el contenido con `Ctrl+Shift+V`, o clonar este repositorio en el nodo con `git clone`.

## Antes de salir a exponer

```bash
bash scripts/despliegue/03_limpiar.sh   # borra web1–web5 de ensayos anteriores
```

El árbol de la web solo debe mostrar la plantilla `900`.

## Guion en directo

| # | Qué hace Raúl | Qué dice (idea) |
|---|---|---|
| 1 | Señala el árbol: solo está la plantilla 900 | «Acabamos de mover un servidor. Con un tercer nodo y Ceph, el disco ni siquiera viajaría, y si un servidor cayera, la VM arrancaría sola en otro. La otra gran ventaja de Proxmox es automatizar» |
| 2 | `bash 02_desplegar.sh` | «Vamos a desplegar 5 servidores web» |
| 3 | Mientras corre, señala el árbol: aparecen web1…web5 | «Cada uno es un clon enlazado de la plantilla: no se copia el disco» |
| 4 | Señala `5 servidores desplegados en XX segundos` y las 5 respuestas | «Cinco servidores respondiendo en XX segundos» |
| 5 | — | «Y como todo pasa por la API, esto mismo se integra en Ansible o Terraform» |

Pantalla recomendada: la Shell a un lado y el árbol de la web al otro, para que se vean aparecer los contenedores.

## Qué hace cada script

| Script | Qué hace | Cuándo |
|---|---|---|
| [`01_preparar_plantilla.sh`](../scripts/despliegue/01_preparar_plantilla.sh) | Crea `vmbr1` con NAT y la plantilla `900` con nginx | Una vez, en casa |
| [`02_desplegar.sh`](../scripts/despliegue/02_desplegar.sh) | Clona la plantilla N veces (CT 201–205), les da IP `192.168.100.11–15`, los arranca, publica «Hola desde webN» y los comprueba con `curl` | En directo |
| [`03_limpiar.sh`](../scripts/despliegue/03_limpiar.sh) | Para y borra los CT 201–205, sin tocar la plantilla | Entre ensayos y antes de exponer |

`bash 02_desplegar.sh 8` despliega 8 en lugar de 5 (y `bash 03_limpiar.sh 8` los borra).

## Notas

- Los servidores están en la red interna `vmbr1`, así que no se ven desde el navegador del portátil: se comprueban con `curl` desde el propio nodo, y eso es lo que se enseña.
- Cada contenedor tiene un límite de 256 MB, pero nginx en reposo usa muy poco: los 5 caben sin problema.
- IDs usadas: `900` (plantilla) y `201`–`205`. No chocan con la VM `101`.

## Problemas frecuentes

| Síntoma | Solución |
|---|---|
| `No encuentro la plantilla Debian 12` | Descargadla en *local → Plantillas de CT → Plantillas → debian-12-standard* |
| `apt-get` falla dentro de la plantilla | El nodo no tiene internet o `vmbr1` no hace NAT: comprobad `ping 8.8.8.8` en el nodo y `iptables -t nat -L POSTROUTING` |
| `CT 201 already exists` | Ejecutad antes `03_limpiar.sh` |
| `curl` no responde en algún servidor | Esperad unos segundos y repetid `curl http://192.168.100.11`; si sigue sin responder, `pct exec 201 -- systemctl status nginx` |
