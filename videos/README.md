# Vídeos

Vídeos mudos, con rótulos «PASO X/N · …» y las esperas aceleradas. En clase se narran en directo. Límite acordado con el profesor: **5 minutos de vídeo en total**.

| Vídeo | Duración | Narra | Estado |
|---|---|---|---|
| 1 · Snapshot: romper un contenedor y recuperarlo | ≈ 1:00 | Marko | Grabado |
| 2 · Snapshots programados con cv4pve-autosnap | ≈ 1:00 | Marko | Pendiente |
| 3 · Ceph y alta disponibilidad (opcional) | ≈ 1:15 | — | Opcional: no entra en la demo |
| Plan B · Migración en caliente | — | — | Pendiente: solo si falla el directo |
| Plan B · Script de despliegue | — | — | Pendiente: solo si falla el directo |

**Cómo grabar:** OBS a 1920×1080, zoom del navegador al 125 %, cada clip por separado. Difuminad siempre contraseñas y el secreto del token. Exportad en MP4 (H.264).

## Vídeo 1 · Snapshot: romper y recuperar (grabado)

1. Crear el CT 100 desde la plantilla Debian 12 (512 MB, 8 GB).
2. Instalar nginx: `apt update && apt install -y nginx`.
3. La web funciona en el navegador.
4. *CT 100 → Instantáneas → Tomar instantánea*: `antes_del_desastre`.
5. Romperlo: `rm -rf /var/www/html/*` → la web da 404.
6. *Instantáneas → antes_del_desastre → Revertir* → la web vuelve.

Cartel final: «Antes de cada cambio, un snapshot».

## Vídeo 2 · Snapshots programados (≈ 1:00)

Se graba en el nodo del vídeo 1, que tiene internet, sobre el CT 100. Los comandos están en [`scripts/snapshots/`](../scripts/snapshots/).

| Paso | Rótulo | Qué se hace | Duración |
|---|---|---|---|
| 1 | Usuario con los permisos justos | `bash 01_usuario_token.sh` (solo `VM.Audit`, `VM.Snapshot` y `Datastore.Audit`). **Difuminad el secreto** | ≈ 10 s |
| 2 | Token de API | `TOKEN='autosnap@pve!snap=<secreto>'` con comillas simples y sin `< >` | ≈ 5 s |
| 3 | Instalar cv4pve-autosnap | `bash 02_instalar_autosnap.sh` (a ×4) | ≈ 6 s |
| 4 | Prueba en seco | `cv4pve-autosnap --host=localhost --api-token="$TOKEN" --vmid=100 --dry-run snap --label=demo --keep=3` | ≈ 8 s |
| 5 | Snapshots y retención | El mismo comando sin `--dry-run`, 4 veces (a ×4). En la web, *CT 100 → Instantáneas* solo muestra 3 `autodemo…`. Después: `cv4pve-autosnap --host=localhost --api-token="$TOKEN" --vmid=100 status` | ≈ 18 s |
| 6 | Cada noche, automático | `crontab -e` con la línea de [`crontab.example`](../scripts/snapshots/crontab.example); después `crontab -l` | ≈ 8 s |

Cartel final: «Snapshots cada noche sin tocar nada · Un snapshot no es un backup».

Para que la variable `TOKEN` no se pierda al recargar la Shell: `echo "export TOKEN='autosnap@pve!snap=<secreto>'" >> ~/.bashrc`.

## Vídeo 3 · Ceph y alta disponibilidad (opcional)

Necesita **3 nodos** a la vez (unos 9 GB de RAM solo para los nodos) y no entra en la demo actual. Si os da tiempo a grabarlo:

1. Crear el clúster y unir pve2 y pve3 (`pvecm status`: 3 nodos, quórum).
2. *Ceph → Instalar Ceph* en los tres nodos (red `192.168.56.0/24`).
3. Un monitor por nodo y un OSD por nodo sobre un segundo disco de 20 GB. Con 16 GB de RAM: `ceph config set osd osd_memory_target 1073741824`.
4. Pool `ceph-vm` (size 3, min_size 2, añadido como almacenamiento). `ceph -s` → `HEALTH_OK`.
5. VM 101 con el disco en `ceph-vm`; *HA → Recursos → Añadir* `vm:101`.
6. Apagar de golpe el nodo donde está la VM (*VirtualBox → Cerrar → Apagar la máquina*). En unos 2 minutos la VM arranca sola en otro nodo.

Cartel final: «Ceph: sin cabina de discos · HA: la VM vuelve sola».
