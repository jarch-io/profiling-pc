# Sistema de Monitoreo WSL con Prometheus y Grafana

Sistema de monitoreo completo para WSL usando Prometheus, Node Exporter y Grafana con dashboards pre-configurados.

## 🏗️ Arquitectura

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  WSL Linux      │────▶│   Prometheus     │────▶│    Grafana      │
│  Node Exporter  │     │   (Scraping)     │     │  (Dashboards)   │
│  :9100          │     │   :9090          │     │   :3000         │
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
  - Dashboard: "WSL System Monitoring Dashboard" (cargado automáticamente)

- **Prometheus**: http://localhost:9090

- **Node Exporter**: http://172.28.166.51:9100/metrics

## 📊 Dashboard Incluido

El dashboard **WSL System Monitoring** incluye:

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

## 📁 Estructura del Proyecto

```
profiling-pc/
├── docker-compose.yml                    # Definición de servicios
├── prometheus.yml                        # Configuración de Prometheus
├── node-exporter-wsl.conf               # Config optimizada de Node Exporter
├── apply-node-exporter-config.sh        # Script de aplicación
├── grafana-dashboard-wsl.json           # Dashboard (backup)
├── grafana/
│   ├── provisioning/
│   │   ├── dashboards/
│   │   │   ├── dashboard.yml            # Provisioning de dashboards
│   │   │   └── grafana-dashboard-wsl.json # Dashboard auto-cargado
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

1. ✅ Configurar alertas en Prometheus
2. ✅ Agregar más dashboards personalizados
3. ✅ Configurar notificaciones en Grafana
4. ✅ Agregar métricas de aplicaciones específicas

## 📚 Referencias

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
