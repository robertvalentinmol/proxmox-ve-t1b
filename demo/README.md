# Plan de la demo (15 min)

Dos vídeos cortos para lo que es lento o repetitivo, y en directo lo más vistoso: la migración y la automatización. Sobre el papel son unos 9 minutos; en la realidad, 11–12. El resto es margen.

| Min. | Bloque | Formato | Quién | Guía |
|---|---|---|---|---|
| 0:00 | Snapshot: romper un contenedor y recuperarlo | 🎞️ Vídeo ≈ 1:00 | Marko | [`videos/`](../videos/README.md) |
| 1:15 | Snapshots programados con cv4pve-autosnap | 🎞️ Vídeo ≈ 1:00 | Marko | [`videos/`](../videos/README.md) |
| 2:30 | Migración en caliente: ida por la web | 🔴 Directo | Miriam | [`01-migracion.md`](01-migracion.md) |
| 4:00 | Migración en caliente: vuelta por consola | 🔴 Directo | Robert | [`01-migracion.md`](01-migracion.md) |
| 5:30 | Script: 5 servidores web en segundos | 🔴 Directo | Raúl | [`02-despliegue.md`](02-despliegue.md) |
| 8:30 | Cierre | — | — | |

**Truco de tiempo:** se empieza con los vídeos. Mientras corren, Miriam y Robert dejan abiertas la web de Proxmox, la terminal con el ping y la Shell. Cuando acaban los vídeos, todo está listo.

## Puntos de recorte (decididos de antemano)

- Si al acabar la ida de la migración vais por encima del **minuto 5**, no se hace la vuelta por consola.
- Si al empezar el script vais por encima del **minuto 9**, se pone el vídeo de plan B del script.
- Uno que no esté hablando lleva el reloj y avisa en el minuto 5 y en el 10.

## Lista de comprobación del día (30 min antes)

- [ ] Portátil enchufado, solo VirtualBox, un navegador y el reproductor de vídeo abiertos.
- [ ] iPhone con el punto de acceso activo, enchufado y con la pantalla del punto de acceso abierta.
- [ ] Nodos `pve` y `pve2` arrancados; web de `pve` abierta en `https://192.168.56.11:8006`.
- [ ] `bash scripts/00_comprobar_entorno.sh` en la Shell de `pve`: todo en ✔.
- [ ] `bash scripts/despliegue/03_limpiar.sh`: el árbol solo muestra la plantilla 900.
- [ ] Terminal de Windows con `ping -t 192.168.56.101` preparada (sin lanzar).
- [ ] Vídeos abiertos en el reproductor, en el orden de la tabla.
- [ ] Vídeos de plan B (migración y script) a mano, por si algo falla.

## Plan B

| Si falla… | Qué hacemos |
|---|---|
| La migración | Decimos qué ha fallado (el registro lo explica) y ponemos el vídeo de plan B de la migración |
| El script | Ponemos el vídeo de plan B del script |
| El portátil entero | Seguimos con los vídeos de plan B desde el USB o la nube |

Los vídeos de plan B solo se ponen si algo falla, y entonces no cuentan para el límite de 5 minutos de vídeo.
