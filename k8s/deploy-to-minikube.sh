#!/bin/bash

# Script de deployment a Minikube
# Despliega la aplicación Devsu Demo a Kubernetes

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

# Variables
NAMESPACE="devsu-demo"
APP_NAME="devsu-demo-app"
DOCKER_IMAGE="${DOCKER_IMAGE:-tu-usuario/devsu-demo-app:latest}"  # Cambiar por tu imagen

# ====================================
# Verificaciones previas
# ====================================
print_step "Verificando prerrequisitos..."

# Verificar que minikube está corriendo
if ! minikube status | grep -q "Running"; then
    print_error "Minikube no está corriendo. Ejecuta: minikube start"
    exit 1
fi
print_info "✓ Minikube está corriendo"

# Verificar que kubectl está configurado
if ! kubectl cluster-info &> /dev/null; then
    print_error "kubectl no está configurado correctamente"
    exit 1
fi
print_info "✓ kubectl está configurado"

# Verificar conexión al cluster
print_info "Cluster: $(kubectl config current-context)"
print_info "Nodes: $(kubectl get nodes --no-headers | wc -l)"

# ====================================
# Actualizar imagen de Docker
# ====================================
print_step "Configurando imagen de Docker..."

read -p "¿Cuál es tu usuario de Docker Hub? (default: tu-usuario): " docker_user
docker_user=${docker_user:-tu-usuario}

DOCKER_IMAGE="${docker_user}/devsu-demo-app:latest"
print_info "Usando imagen: $DOCKER_IMAGE"

# Actualizar deployment.yaml con la imagen correcta
sed -i.bak "s|image:.*devsu-demo-app:latest|image: ${DOCKER_IMAGE}|g" deployment.yaml
print_info "✓ Deployment actualizado con imagen correcta"

# ====================================
# Crear namespace
# ====================================
print_step "Creando namespace..."

if kubectl get namespace $NAMESPACE &> /dev/null; then
    print_warning "Namespace $NAMESPACE ya existe"
else
    kubectl apply -f namespace.yaml
    print_info "✓ Namespace creado"
fi

# ====================================
# Aplicar ConfigMaps
# ====================================
print_step "Aplicando ConfigMaps..."
kubectl apply -f configmap.yaml
print_info "✓ ConfigMaps aplicados"

# ====================================
# Aplicar Secrets
# ====================================
print_step "Aplicando Secrets..."
kubectl apply -f secret.yaml
print_info "✓ Secrets aplicados"

# ====================================
# Crear PersistentVolumeClaim
# ====================================
print_step "Creando PersistentVolumeClaim..."
kubectl apply -f pvc.yaml
print_info "✓ PVC creado"

# Esperar a que PVC esté bound
print_info "Esperando a que PVC esté disponible..."
kubectl wait --for=condition=Bound pvc/devsu-app-pvc -n $NAMESPACE --timeout=60s || true

# ====================================
# Aplicar Deployment
# ====================================
print_step "Desplegando aplicación..."
kubectl apply -f deployment.yaml

# Esperar a que el deployment esté listo
print_info "Esperando a que los pods estén listos (esto puede tomar 1-2 minutos)..."
kubectl rollout status deployment/$APP_NAME -n $NAMESPACE --timeout=5m

print_info "✓ Deployment completado"

# ====================================
# Aplicar Service
# ====================================
print_step "Creando Services..."
kubectl apply -f service.yaml
print_info "✓ Services creados"

# ====================================
# Aplicar HPA
# ====================================
print_step "Configurando Auto-scaling..."
kubectl apply -f hpa.yaml
print_info "✓ HorizontalPodAutoscaler configurado"

# ====================================
# Aplicar Ingress
# ====================================
print_step "Configurando Ingress..."
kubectl apply -f ingress.yaml
print_info "✓ Ingress configurado"

# ====================================
# Verificar deployment
# ====================================
print_step "Verificando deployment..."

echo ""
echo "📊 Estado de los recursos:"
echo "================================"

# Pods
echo ""
print_info "Pods:"
kubectl get pods -n $NAMESPACE -o wide

# Services
echo ""
print_info "Services:"
kubectl get svc -n $NAMESPACE

# HPA
echo ""
print_info "HorizontalPodAutoscaler:"
kubectl get hpa -n $NAMESPACE

# Ingress
echo ""
print_info "Ingress:"
kubectl get ingress -n $NAMESPACE

# ====================================
# Obtener URLs de acceso
# ====================================
print_step "Obteniendo URLs de acceso..."

MINIKUBE_IP=$(minikube ip)
NODE_PORT=$(kubectl get svc devsu-demo-app-nodeport -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')

echo ""
echo "=========================================="
print_info "✅ Deployment completado exitosamente!"
echo "=========================================="
echo ""
echo "🌐 URLs de acceso:"
echo ""
echo "  1. NodePort (directo):"
echo "     http://${MINIKUBE_IP}:${NODE_PORT}/api/swagger-ui.html"
echo ""
echo "  2. Port-forward (alternativo):"
echo "     kubectl port-forward -n $NAMESPACE svc/devsu-demo-app 8000:8000"
echo "     http://localhost:8000/api/swagger-ui.html"
echo ""
echo "  3. Minikube service (abre automáticamente):"
echo "     minikube service devsu-demo-app-nodeport -n $NAMESPACE"
echo ""
echo "  4. Ingress (si configuraste /etc/hosts):"
echo "     http://devsu-demo.local/api/swagger-ui.html"
echo "     Agrega a /etc/hosts: ${MINIKUBE_IP} devsu-demo.local"
echo ""
echo "🔍 Comandos de verificación:"
echo ""
echo "  Ver pods:        kubectl get pods -n $NAMESPACE"
echo "  Ver logs:        kubectl logs -f deployment/$APP_NAME -n $NAMESPACE"
echo "  Ver servicios:   kubectl get svc -n $NAMESPACE"
echo "  Ver HPA:         kubectl get hpa -n $NAMESPACE -w"
echo "  Ver ingress:     kubectl get ingress -n $NAMESPACE"
echo "  Dashboard:       minikube dashboard"
echo ""
echo "🧪 Probar la aplicación:"
echo ""
echo "  Health check:"
echo "    curl http://${MINIKUBE_IP}:${NODE_PORT}/api/actuator/health"
echo ""
echo "  Crear usuario:"
echo "    curl -X POST http://${MINIKUBE_IP}:${NODE_PORT}/api/users \\"
echo "      -H 'Content-Type: application/json' \\"
echo "      -d '{\"dni\":\"1234567890\",\"name\":\"Test User\"}'"
echo ""
echo "  Listar usuarios:"
echo "    curl http://${MINIKUBE_IP}:${NODE_PORT}/api/users"
echo ""
echo "🔄 Comandos de gestión:"
echo ""
echo "  Escalar manualmente:"
echo "    kubectl scale deployment/$APP_NAME --replicas=5 -n $NAMESPACE"
echo ""
echo "  Actualizar imagen:"
echo "    kubectl set image deployment/$APP_NAME $APP_NAME=$DOCKER_IMAGE -n $NAMESPACE"
echo ""
echo "  Rollback:"
echo "    kubectl rollout undo deployment/$APP_NAME -n $NAMESPACE"
echo ""
echo "  Eliminar todo:"
echo "    kubectl delete namespace $NAMESPACE"
echo ""
