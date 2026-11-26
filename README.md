# Proxmox VE · Grupo T1B · EI1044

Material de apoyo del grupo T1B para el *SysAdmin Tool Showcase* (EI1044, Universitat Jaume I): guías, scripts y configuraciones que usamos para preparar y ejecutar la demo de **Proxmox VE 9.2**.

| Integrante | Exposición (10 min) | Demo (15 min) |
|---|---|---|
| Robert Valentin Moldovanu | Portada · El problema y la solución | Migración en caliente: vuelta por consola |
| Marko Díaz Savic | Arquitectura | Vídeos de snapshots |
| Raúl Vallespín Centeno | Ceph, migración y HA | Script: 5 servidores en segundos |
| Miriam Llopico Micu | Operación y alternativas | Migración en caliente: ida por la web |

- **Gemini Notebook (fuentes y artefactos):** _[pendiente: enlace público al NotebookLM]_
- **Manual técnico (A2):** `EI1044_A2_Manual_GrupoXX.pdf` (entregado en Moodle)

## Empieza aquí

| Si quieres… | Ve a |
|---|---|
| Ver el orden de la demo, los tiempos y quién hace qué | [`demo/README.md`](demo/README.md) |
| Preparar y ensayar la **migración en vivo** | [`demo/01-migracion.md`](demo/01-migracion.md) |
| Preparar y ensayar el **script de despliegue en vivo** | [`demo/02-despliegue.md`](demo/02-despliegue.md) |
| Grabar los vídeos | [`videos/README.md`](videos/README.md) |
| Preparar la defensa individual | [`docs/preguntas-defensa.md`](docs/preguntas-defensa.md) |

## Estructura

```
.
├── demo/                    Plan de la demo y guías de lo que se hace en vivo
├── videos/                  Guiones de los vídeos (snapshots, snapshots programados, Ceph y HA)
├── docs/                    Preguntas probables de la defensa individual
├── scripts/
│   ├── 00_comprobar_entorno.sh   Comprueba que todo está listo antes de salir
│   ├── despliegue/               Plantilla + despliegue de N servidores web + limpieza
│   ├── migracion/                Migración ida/vuelta con medición de tiempos
│   └── snapshots/                Usuario, token y cron para cv4pve-autosnap
└── config/red/              Ejemplos de /etc/network/interfaces para cada montaje
```

## Entorno de laboratorio

- Proxmox VE 9.2 (Debian 13) instalado en VMs de VirtualBox, con virtualización anidada.
- Clúster de 2 nodos (`pve` y `pve2`) en un único portátil de 16 GB, con red solo-anfitrión `192.168.56.0/24` para el clúster y NAT para internet.
- VM de prueba `101` (Alpine Linux, 512 MB) y contenedor plantilla `900` (Debian 12 + nginx).

Todos los scripts se ejecutan **como root en la Shell del nodo** (web de Proxmox → nodo → `>_ Shell`). Ninguno guarda contraseñas ni tokens: donde haga falta uno, se indica `<secreto>`.

## Fuentes principales

- [Proxmox VE Administration Guide](https://pve.proxmox.com/pve-docs/pve-admin-guide.html): clúster, migración, HA, Ceph, backups.
- [cv4pve-autosnap](https://github.com/Corsinvest/cv4pve-autosnap) y su [página de permisos](https://corsinvest.github.io/cv4pve-autosnap/permissions/).
