#!/bin/bash
# Script para aplicar la configuración optimizada de node-exporter

echo "Aplicando configuración optimizada para node-exporter en WSL..."

# Copiar la configuración
sudo cp /var/www/profiling-pc/node-exporter-wsl.conf /etc/default/prometheus-node-exporter

# Reiniciar el servicio
sudo systemctl restart prometheus-node-exporter

# Verificar el estado
sudo systemctl status prometheus-node-exporter --no-pager

echo ""
echo "✓ Configuración aplicada!"
echo ""
echo "Métricas HABILITADAS ahora:"
echo "  - processes (procesos y estados)"
echo "  - tcpstat (estadísticas TCP)"
echo "  - interrupts (interrupciones por CPU)"
echo "  - cpu.info (información detallada CPU)"
echo ""
echo "Métricas DESHABILITADAS para optimizar WSL:"
echo "  - 15 colectores innecesarios en WSL eliminados"
echo ""
echo "Puedes verificar en: http://172.28.166.51:9100/metrics"
