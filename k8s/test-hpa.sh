#!/bin/bash

# Script de prueba de carga para testing de HPA
# Genera tráfico para ver el auto-scaling en acción

set -e

echo "🔥 Iniciando prueba de carga para HPA..."

# Obtener IP y puerto
MINIKUBE_IP=$(minikube ip)
NODE_PORT=30080
URL="http://${MINIKUBE_IP}:${NODE_PORT}/api/users"

echo "URL objetivo: $URL"

# Verificar que la app está corriendo
if ! curl -s "$URL" > /dev/null; then
    echo "❌ La aplicación no responde. Verifica que esté desplegada."
    exit 1
fi

echo "✅ Aplicación respondiendo correctamente"
echo ""
echo "📊 Estado inicial del HPA:"
kubectl get hpa -n devsu-demo
echo ""

# Abrir watch del HPA en otra terminal (si es posible)
echo "💡 Tip: Abre otra terminal y ejecuta:"
echo "   kubectl get hpa -n devsu-demo -w"
echo ""
echo "   Y también:"
echo "   kubectl get pods -n devsu-demo -w"
echo ""

read -p "Presiona Enter para iniciar la prueba de carga..."

echo ""
echo "🚀 Generando carga (esto tomará unos minutos)..."
echo "Se crearán 1000 requests concurrentes para estresar el CPU..."
echo ""

# Generar carga
for i in {1..1000}; do
    curl -s "$URL" > /dev/null &
    
    # Mostrar progreso cada 50 requests
    if [ $((i % 50)) -eq 0 ]; then
        echo "Requests enviados: $i/1000"
    fi
done

echo ""
echo "✅ Todos los requests enviados"
echo ""
echo "⏳ Esperando a que HPA reaccione (puede tomar 1-2 minutos)..."
sleep 30

echo ""
echo "📊 Estado del HPA después de 30 segundos:"
kubectl get hpa -n devsu-demo
echo ""

echo "📦 Estado de los pods:"
kubectl get pods -n devsu-demo
echo ""

echo "📈 Uso de recursos:"
kubectl top pods -n devsu-demo || echo "Metrics no disponibles aún"
echo ""

echo "💡 Continúa monitoreando con:"
echo "   kubectl get hpa -n devsu-demo -w"
echo ""
echo "Para ver el HPA reducir las réplicas, espera 5-10 minutos sin carga."
