# Migración en caliente (en directo · Miriam y Robert)

Objetivo: mover la VM 101 encendida de `pve` a `pve2` sin que el servicio se corte, y volverla por consola. Duración del bloque: **3:30**, sin pasar de 4:00.

Hay dos formas de montarlo. **En clase usamos la forma 2** porque no depende de ninguna wifi.

| | Forma 1 · Dos portátiles | Forma 2 · Un portátil, dos VMs |
|---|---|---|
| Red del clúster | Wifi del hotspot del iPhone (`172.20.10.0/28`) | Red solo-anfitrión de VirtualBox (`192.168.56.0/24`) |
| El iPhone sirve para | Unir los portátiles y dar internet | Solo dar internet |
| Qué viaja al migrar | RAM y disco, por wifi | RAM y disco, dentro del portátil |
| Duración esperada | Uno o varios minutos | Segundos |
| Riesgo en directo | Medio–alto | Bajo |

## Forma 2 · Un portátil (la de clase)

### 1. VirtualBox

1. *Archivo → Herramientas → Administrador de red → Redes solo-anfitrión*: IP `192.168.56.1`, máscara `255.255.255.0`, **sin DHCP**.
2. En cada VM de Proxmox (apagada):
   - Memoria 3072 MB, 2 CPU, *VT-x/AMD-V anidado* (si no deja: [`VBoxManage modifyvm "pve" --nested-hw-virt on`](#sin-virtualización-anidada)).
   - *Adaptador 1*: **Solo-anfitrión**, modo promiscuo **Permitir todo**.
   - *Adaptador 2*: **NAT**.

### 2. Red de cada nodo

Copiad [`config/red/forma2-pve.interfaces`](../config/red/forma2-pve.interfaces) en `/etc/network/interfaces` (en `pve2`, cambiad `.11` por `.12`). Después:

```bash
nano /etc/hosts          # 192.168.56.11 pve.local pve   (en pve2: 192.168.56.12 pve2.local pve2)
nano /etc/resolv.conf    # nameserver 10.0.2.3
ifreload -a
ping -c 2 8.8.8.8 && ping -c 2 192.168.56.12
```

### 3. Clúster

```bash
pvecm create T1B          # en pve
pvecm add 192.168.56.11   # en pve2 (que no tenga ninguna VM creada)
pvecm status              # Nodes: 2 · Quorate: Yes
```

### 4. VM 101 (en `pve`)

Alpine necesita internet para instalarse. Dadle salida temporal por NAT (se deshace al reiniciar):

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s 192.168.56.0/24 -o enp0s8 -j MASQUERADE
```

1. *Crear VM*: ID `101`, nombre `web`, ISO de Alpine *Virtual*, disco **2 GB** en `local-lvm`, CPU **`x86-64-v2-AES`**, **512 MB**, red `vmbr0`.
2. Consola → `root` → `setup-alpine`: IP `192.168.56.101`, máscara `255.255.255.0`, puerta de enlace **`192.168.56.11`**, DNS `8.8.8.8`, *mirror* `1`, disco `sda` en modo `sys`.
3. `poweroff` → *Hardware → Unidad CD/DVD → No usar ningún medio* → arrancar.
4. Desde Windows: `ping 192.168.56.101` responde.

## Forma 1 · Dos portátiles (alternativa)

Cada VM de Proxmox va **en puente sobre la tarjeta wifi** de su portátil, conectada al hotspot del iPhone.

| Equipo | IP |
|---|---|
| iPhone (puerta de enlace y DNS) | `172.20.10.1` |
| `pve` (portátil A) | `172.20.10.11/28` |
| `pve2` (portátil B) | `172.20.10.12/28` |
| VM 101 | `172.20.10.13/28` |

- En el iPhone: *Punto de acceso personal* activo y **Maximizar compatibilidad** activado. Pantalla abierta y enchufado.
- La red del iPhone solo va de `.1` a `.14`: comprobad con `ipconfig` que `.11`, `.12` y `.13` están libres.
- VirtualBox: *Adaptador 1* → **Adaptador puente** sobre la wifi, modo promiscuo **Permitir todo**. Sin adaptador 2.
- Red del nodo: [`config/red/forma1-pve.interfaces`](../config/red/forma1-pve.interfaces), `nameserver 172.20.10.1`.
- Con 2 nodos el quórum necesita los dos. Si se apaga un portátil: `pvecm expected 1` en el otro.
- En `setup-alpine`: IP `172.20.10.13`, máscara `255.255.255.240`, puerta de enlace y DNS `172.20.10.1`.
- Si la VM 101 no responde al ping por la wifi, demostrad que no se reinicia con `uptime` en su consola antes y después.

## Guion en directo

| # | Quién | Qué hace | Qué dice (idea) |
|---|---|---|---|
| 1 | Robert | Lanza `ping -t 192.168.56.101` en Windows, a la derecha del navegador | «Esto es un servidor web funcionando; el ping lo vigila» |
| 2 | Robert | Shell de `pve`: `pvecm status` | «Dos servidores en clúster, con quórum» |
| 3 | Miriam | *VM 101 → Migrar → `pve2` → Migrar* | «La movemos a otro servidor sin apagarla» |
| 4 | Miriam | Mientras corre la tarea | «Copia la memoria en caliente, reenvía lo que cambia y al final para la VM unos milisegundos» |
| 5 | Miriam | Señala en el registro `downtime` y `migration finished successfully` | «Ha estado parada X milisegundos» |
| 6 | Robert | Señala el ping | «Sin perder paquetes» |
| 7 | Robert | Shell de **`pve2`**: `bash migrar.sh 101 pve` | «Y la vuelta por consola: todo es automatizable» |
| 8 | Robert | Lee el resumen del script | «X segundos de servidor a servidor» |

[`scripts/migracion/migrar.sh`](../scripts/migracion/migrar.sh) detecta si el disco es local y añade `--with-local-disks`, mide el tiempo y saca el *downtime* del registro. Hay que lanzarlo **en el nodo donde está la VM**.

## Medir los ensayos

| Ensayo | Forma | Ida | Vuelta | Downtime | Pings perdidos | Bloque completo |
|---|---|---|---|---|---|---|
| 1 | | | | | | |
| 2 | | | | | | |
| 3 | | | | | | |

- **Ida:** última línea del registro, `migration finished successfully (duration 00:00:XX)`.
- **Vuelta y downtime:** el resumen de `migrar.sh`.
- **Pings perdidos:** `Ctrl+C` en la ventana del ping.
- **Bloque completo:** cronómetro del móvil, del paso 1 al 8.

Si con la forma 1 la ida pasa de 1:30 o algún ensayo falla, en clase se usa la forma 2.

## Problemas frecuentes

| Síntoma | Solución |
|---|---|
| `can't migrate … local resource` | Hay una ISO montada: *Hardware → CD/DVD → No usar ningún medio* |
| Error de CPU al migrar | Tipo de CPU `x86-64-v2-AES` (o `kvm64`), nunca `host` |
| La VM migra pero no responde al ping | Modo promiscuo en **Permitir todo** en el adaptador del clúster |
| No deja unir `pve2` | Tiene VMs creadas o el mismo nombre que `pve` |
| Forma 1: los nodos no se ven | Comprobad que los dos Windows se hacen ping. Si no, el iPhone no deja pasar tráfico entre equipos: forma 2 |
| Todo va lento o con *timeouts* | Falta RAM: cerrad programas; 3072 MB por nodo |

### Sin virtualización anidada

Si la casilla *VT-x/AMD-V anidado* no se puede marcar:

```powershell
cd "C:\Program Files\Oracle\VirtualBox"
.\VBoxManage modifyvm "pve" --nested-hw-virt on
```

Si da error, Windows está usando Hyper-V (tortuga verde en la barra de la VM). Desactivad Hyper-V, *Plataforma de máquina virtual*, *Plataforma del hipervisor de Windows* e *Integridad de memoria*, ejecutad `bcdedit /set hypervisorlaunchtype off` como administrador y reiniciad. Plan B: en la VM 101, *Opciones → Virtualización por hardware KVM → No*. Va más lenta, pero migra igual.
