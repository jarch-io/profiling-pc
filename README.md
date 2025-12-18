# Sistema de Monitoreo Multi-Sistema con Prometheus y Grafana

Sistema de monitoreo completo para WSL y Windows 10 usando Prometheus, Node Exporter/Windows Exporter y Grafana con dashboards pre-configurados.

## 🏗️ Arquitectura

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  WSL Linux      │────▶│                  │     │                 │
│  Node Exporter  │     │   Prometheus     │────▶│    Grafana      │
│  :9100          │     │   (Scraping)     │     │  (Dashboards)   │
│                 │     │   :9090          │     │   :3000         │
│  Windows 10     │────▶│                  │     │                 │
│  :9182  │     │                  │     │                 │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## 📦 Componentes

### 1. **Prometheus**
- Puerto: `9090`
- Configuración: `prometheus.yml`
- Almacenamiento persistente: volumen Docker `prometheus-storage`

### 2. **Grafana**
- Puerto: `3000`
- Usuario: `admin` / Contraseña: `admin`
- Dashboards auto-provisionados desde `grafana/dashboards/`
- Almacenamiento persistente: volumen Docker `grafana-storage`

### 3. **Node Exporter** (WSL)
- Puerto: `9100`
- Configuración optimizada: `node-exporter-wsl.conf`
- Métricas optimizadas para WSL

### 4. **Windows Exporter** (Windows 10)
- Puerto: `9182`
- Endpoint: `http://host.docker.internal:9182`
- Métricas específicas de Windows con prefijo `windows_`

## 🚀 Inicio Rápido

### 1. Configurar Node Exporter (WSL)
```bash
# Aplicar configuración optimizada
./apply-node-exporter-config.sh
```

### 2. Iniciar servicios de monitoreo
```bash
# Iniciar Prometheus y Grafana
docker-compose up -d

# Verificar estado
docker-compose ps
```

### 3. Acceder a las interfaces

- **Grafana**: http://localhost:3000
  - Usuario: `admin`
  - Contraseña: `admin`
  - Dashboards disponibles:
    - "WSL System Monitoring Dashboard" (para WSL/Linux)
    - "Windows 10 System Monitoring Dashboard" (para Windows 10)

- **Prometheus**: http://localhost:9090

- **Node Exporter** (WSL): http://172.28.166.51:9100/metrics

- **Windows Metrics** (W10): http://host.docker.internal:9182/metrics

## 📊 Dashboards Incluidos

### Dashboard WSL System Monitoring

Monitoreo completo de WSL/Linux con paneles:

### Paneles Principales
- CPU Usage % (gráfico + gauge)
- Memory Usage % (gauge + desglose detallado)
- Disk Usage % por punto de montaje
- Network Traffic (entrada/salida)
- TCP Connection States
- Process States (running, sleeping, zombie, blocked)
- System Load Average (1m, 5m, 15m)

### Paneles Avanzados
- CPU by Mode (user, system, idle, iowait)
- Disk I/O Operations
- CPU Information (detalles del procesador)
- Top 5 Interrupts

### Dashboard Windows 10 System Monitoring

Monitoreo completo de Windows 10 con métricas nativas:

#### Paneles de CPU
- **CPU Usage per Core**: Uso de CPU por núcleo
- **CPU by Mode**: Desglose por modo (Privileged, User, DPC, Interrupt)

#### Paneles de Memoria
- **Memory Usage**: Uso de memoria (Usado, Cache, Disponible)

#### Paneles de Disco
- **Disk Usage Capacity**: Capacidad usada por volumen
- **Total Disk Space**: Gráfico de torta del espacio total
- **Disk I/O Operations**: Lecturas y escrituras por volumen

#### Paneles de Red
- **Network Traffic**: Tráfico de red por interfaz (bytes enviados/recibidos)
- **TCP Connection States**: Estados de conexiones TCP (Established, Time Wait)

#### Paneles de Sistema
- **Processes & Threads**: Número de procesos y threads
- **Processor Queue Length**: Longitud de la cola del procesador
- **System Calls Rate**: Tasa de llamadas al sistema

### Métricas de Windows 10

Las métricas de Windows usan el prefijo `windows_`:

#### CPU
- `windows_cpu_time_total` - Tiempo de CPU por modo y núcleo
- Modos: `idle`, `privileged`, `user`, `dpc`, `interrupt`

#### Memoria
- `windows_cs_physical_memory_bytes` - Memoria física total
- `windows_os_visible_memory_bytes` - Memoria disponible
- `windows_memory_cache_bytes` - Memoria en cache

#### Disco
- `windows_logical_disk_size_bytes` - Tamaño total por volumen
- `windows_logical_disk_free_bytes` - Espacio libre por volumen
- `windows_logical_disk_reads_total` - Total de lecturas
- `windows_logical_disk_writes_total` - Total de escrituras

#### Red
- `windows_net_bytes_received_total` - Bytes recibidos por interfaz
- `windows_net_bytes_sent_total` - Bytes enviados por interfaz

#### TCP
- `windows_tcp_connections_established` - Conexiones establecidas
- `windows_tcp_connections_time_wait` - Conexiones en Time Wait

#### Sistema
- `windows_system_processes` - Número de procesos
- `windows_system_threads` - Número de threads
- `windows_system_processor_queue_length` - Cola del procesador
- `windows_system_system_calls_total` - Total de llamadas al sistema

## 📁 Estructura del Proyecto

```
profiling-pc/
├── docker-compose.yml                    # Definición de servicios
├── prometheus.yml                        # Configuración de Prometheus
├── node-exporter-wsl.conf               # Config optimizada de Node Exporter
├── apply-node-exporter-config.sh        # Script de aplicación
├── grafana/
│   ├── provisioning/
│   │   ├── dashboards/
│   │   │   ├── dashboard.yml            # Provisioning de dashboards
│   │   │   ├── grafana-dashboard-wsl.json      # Dashboard WSL
│   │   │   └── grafana-dashboard-windows.json  # Dashboard Windows 10
│   │   └── datasources/
│   │       └── prometheus.yml           # Provisioning de datasources
│   └── README.md                        # Documentación de Grafana
├── GRAFANA-DASHBOARD-README.md          # Guía del dashboard
└── README.md                            # Este archivo
```

## ⚙️ Configuración Optimizada de Node Exporter

La configuración está optimizada para WSL, habilitando solo las métricas relevantes:

### ✅ Métricas Habilitadas
- `processes` - Estados de procesos
- `tcpstat` - Estadísticas TCP
- `interrupts` - Interrupciones por CPU
- `cpu.info` - Información detallada del CPU

### ❌ Métricas Deshabilitadas (15 colectores)
Hardware y servicios no aplicables en WSL: fibrechannel, infiniband, ipvs, nfs, nfsd, nvme, xfs, zfs, bcache, bonding, btrfs, mdadm, edac, hwmon, rapl

## 🔧 Comandos Útiles

### Gestión de servicios
```bash
# Iniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Reiniciar servicios
docker-compose restart

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes (CUIDADO: borra datos)
docker-compose down -v
```

### Verificar métricas
```bash
# Ver métricas de Node Exporter
curl http://172.28.166.51:9100/metrics

# Verificar targets en Prometheus
curl http://localhost:9090/api/v1/targets
```

### Solucionar error de red
```bash
# Si hay error "Network needs to be recreated"
docker-compose down && docker-compose up -d
```

## 📈 Métricas Clave

### CPU
- `node_cpu_seconds_total` - Tiempo de CPU por modo
- `node_cpu_info` - Información del procesador
- `node_load1`, `node_load5`, `node_load15` - Carga del sistema

### Memoria
- `node_memory_MemTotal_bytes` - Memoria total
- `node_memory_MemAvailable_bytes` - Memoria disponible
- `node_memory_Buffers_bytes` - Buffers
- `node_memory_Cached_bytes` - Cache

### Red
- `node_network_receive_bytes_total` - Bytes recibidos
- `node_network_transmit_bytes_total` - Bytes transmitidos
- `node_tcp_connection_states` - Estados de conexiones TCP

### Procesos
- `node_procs_running` - Procesos en ejecución
- `node_procs_blocked` - Procesos bloqueados
- `node_processes_state` - Estados de procesos por tipo

### Disco
- `node_filesystem_size_bytes` - Tamaño total
- `node_filesystem_free_bytes` - Espacio libre
- `node_disk_reads_completed_total` - Lecturas
- `node_disk_writes_completed_total` - Escrituras

### Interrupciones
- `node_interrupts_total` - Interrupciones por tipo

## 🔄 Persistencia de Datos

### Prometheus
Los datos históricos se guardan en el volumen `prometheus-storage`, persistiendo entre reinicios del sistema.

### Grafana
- Configuraciones y dashboards editados: volumen `grafana-storage`
- Dashboards provisionados: archivos en `grafana/provisioning/dashboards/`
- Datasources: configuración en `grafana/provisioning/datasources/`

## 🛠️ Solución de Problemas

### Dashboard no aparece en Grafana
```bash
# Verificar logs de provisioning
docker logs grafana 2>&1 | grep provisioning

# Reiniciar Grafana
docker-compose restart grafana
```

### Prometheus no obtiene métricas
```bash
# Verificar que Node Exporter esté corriendo
systemctl status prometheus-node-exporter

# Verificar conectividad desde el contenedor
docker exec prometheus wget -O- http://172.28.166.51:9100/metrics
```

### Error de red en Docker
```bash
# Eliminar red y recrear
docker-compose down
docker-compose up -d
```

## 📝 Notas

- El dashboard se actualiza cada 5 segundos automáticamente
- Todas las configuraciones están versionadas en Git
- El sistema es completamente reproducible
- Los datos persisten entre reinicios del sistema

## 🎯 Próximos Pasos

1. ✅ Sistema de monitoreo para WSL implementado
2. ✅ Sistema de monitoreo para Windows 10 implementado
3. ✅ Dashboards separados para cada sistema operativo
4. ⬜ Configurar alertas en Prometheus
5. ⬜ Agregar más dashboards personalizados
6. ⬜ Configurar notificaciones en Grafana
7. ⬜ Agregar métricas de aplicaciones específicas

## 🔍 Monitoreo de Windows 10

### Requisitos
Para monitorear Windows 10, necesitas tener un exporter ejecutándose en el puerto 9182 que exponga métricas en `http://host.docker.internal:9182/metrics`.

### Configuración en Prometheus
El archivo `prometheus.yml` ya está configurado para recolectar métricas de Windows 10:

```yaml
scrape_configs:
  - job_name: 'windows'
    static_configs:
      - targets: ['host.docker.internal:9182']
```

### Verificar métricas de Windows
```bash
# Desde WSL/Linux
curl http://host.docker.internal:9182/metrics

# Verificar targets en Prometheus
curl http://localhost:9090/api/v1/targets
```

## 📚 Referencias

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
