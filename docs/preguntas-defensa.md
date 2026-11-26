# Preguntas probables de la defensa individual

Tres preguntas por persona, según el bloque que expone cada uno, con una respuesta corta para ensayar. Las respuestas son una base: en la defensa hay que explicarlas con vuestras palabras.

## Robert · El problema y la solución

- **¿Por qué es un hipervisor de tipo 1?** Se instala directamente sobre el hardware; no hay otro sistema operativo debajo.
- **¿Qué diferencia hay con VirtualBox?** VirtualBox es de tipo 2: un programa que corre sobre Windows o Linux, pensado para escritorio.
- **¿Qué cubre la suscripción?** El repositorio enterprise (paquetes más probados) y el soporte técnico. Las funciones son las mismas con o sin suscripción.

## Marko · Arquitectura

- **¿Por qué LXC no migra en caliente?** Proxmox no lo soporta: el contenedor comparte el kernel del servidor. Se para, se mueve y se arranca (`pct migrate --restart`).
- **¿Qué pasa sin quórum?** `/etc/pve` pasa a solo lectura: desde ese nodo no se pueden crear, arrancar ni mover invitados.
- **¿Qué es pmxcfs?** El sistema de ficheros de `/etc/pve`, respaldado por SQLite y replicado por Corosync en todos los nodos.

## Raúl · Ceph, migración y HA

- **¿Por qué Ceph necesita 3 nodos?** Guarda 3 copias en nodos distintos y sus monitores necesitan mayoría; con 3 nodos aguanta la caída de uno.
- **¿Qué es el fencing?** Asegurar que el nodo caído está apagado antes de arrancar su VM en otro, para que no corra dos veces. En Proxmox lo hace un watchdog de 60 segundos.
- **¿Se puede tener HA con 2 nodos?** No de forma fiable sin un tercer voto: hace falta un QDevice externo.

## Miriam · Operación y alternativas

- **¿Snapshot o backup?** El snapshot vive en el mismo almacenamiento y sirve para deshacer un cambio. El backup es una copia independiente que protege si se pierde el disco o el nodo.
- **¿Qué aporta Proxmox Backup Server?** Copias deduplicadas, cifrado, restaurar ficheros sueltos y restauración en vivo.
- **¿Por qué no VMware?** Por el coste de las licencias por núcleo. VMware sigue siendo más maduro, pero para pymes y laboratorios Proxmox cubre casi todo sin licencia.

## Sobre la demo (cualquiera)

- **¿Por qué la migración no corta el servicio?** Se copia la memoria mientras la VM funciona, se reenvía lo que cambia y solo se pausa unos milisegundos al final.
- **En vuestra demo, ¿por qué viaja también el disco?** Porque los dos nodos no comparten almacenamiento (`local-lvm`). Con Ceph o NFS solo viajaría la memoria.
- **¿Por qué el script tarda tan poco?** Clona una plantilla con nginx ya instalado usando clones enlazados (*copy-on-write*): no se copia el disco ni se instala nada.
- **¿Por qué los contenedores del script no se ven desde el portátil?** Están en una red interna (`vmbr1`) con NAT a través del nodo; se comprueban con `curl` desde el propio nodo.
