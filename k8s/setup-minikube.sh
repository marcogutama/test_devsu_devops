#!/bin/bash

# Script de instalación de Minikube y dependencias
# Para Ubuntu/Debian/WSL2

set -e

echo "🚀 Instalando Minikube y dependencias..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Verificar sistema operativo
print_info "Detectando sistema operativo..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    print_error "Sistema operativo no soportado: $OSTYPE"
    exit 1
fi

print_info "Sistema operativo detectado: $OS"

# ====================================
# 1. Instalar Docker (si no está)
# ====================================
if ! command -v docker &> /dev/null; then
    print_info "Instalando Docker..."
    
    if [ "$OS" == "linux" ]; then
        # Instalar Docker en Linux
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        
        print_warning "Docker instalado. Necesitas cerrar sesión y volver a entrar para que los cambios surtan efecto."
        print_warning "O ejecuta: newgrp docker"
    else
        print_info "Por favor instala Docker Desktop desde: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
else
    print_info "✓ Docker ya está instalado"
    docker --version
fi

# ====================================
# 2. Instalar kubectl
# ====================================
if ! command -v kubectl &> /dev/null; then
    print_info "Instalando kubectl..."
    
    if [ "$OS" == "linux" ]; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    else
        # macOS
        brew install kubectl
    fi
else
    print_info "✓ kubectl ya está instalado"
    kubectl version --client
fi

# ====================================
# 3. Instalar Minikube
# ====================================
if ! command -v minikube &> /dev/null; then
    print_info "Instalando Minikube..."
    
    if [ "$OS" == "linux" ]; then
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
    else
        # macOS
        brew install minikube
    fi
else
    print_info "✓ Minikube ya está instalado"
    minikube version
fi

# ====================================
# 4. Verificar instalaciones
# ====================================
print_info "Verificando instalaciones..."

if command -v docker &> /dev/null; then
    print_info "✓ Docker: $(docker --version)"
else
    print_error "✗ Docker no está instalado correctamente"
fi

if command -v kubectl &> /dev/null; then
    print_info "✓ kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
else
    print_error "✗ kubectl no está instalado correctamente"
fi

if command -v minikube &> /dev/null; then
    print_info "✓ Minikube: $(minikube version --short)"
else
    print_error "✗ Minikube no está instalado correctamente"
fi

# ====================================
# 5. Iniciar Minikube
# ====================================
print_info "Iniciando Minikube..."

# Detener minikube si ya está corriendo
minikube stop 2>/dev/null || true

# Iniciar minikube con configuración optimizada
minikube start \
    --driver=docker \
    --cpus=2 \
    --memory=4096 \
    --disk-size=20g \
    --kubernetes-version=stable \
    --addons=ingress,metrics-server,dashboard

# Verificar estado
print_info "Verificando estado de Minikube..."
minikube status

# ====================================
# 6. Habilitar addons necesarios
# ====================================
print_info "Habilitando addons de Minikube..."

minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard

print_info "Addons habilitados:"
minikube addons list | grep enabled

# ====================================
# 7. Configurar kubectl
# ====================================
print_info "Configurando kubectl para usar Minikube..."
kubectl config use-context minikube

# ====================================
# 8. Verificar cluster
# ====================================
print_info "Verificando cluster de Kubernetes..."
kubectl cluster-info
kubectl get nodes

# ====================================
# Resumen
# ====================================
echo ""
echo "=========================================="
print_info "✅ Instalación completada exitosamente!"
echo "=========================================="
echo ""
echo "📋 Información del cluster:"
echo "  Minikube IP: $(minikube ip)"
echo "  Dashboard: minikube dashboard"
echo "  Context: $(kubectl config current-context)"
echo ""
echo "🚀 Próximos pasos:"
echo "  1. Ejecutar: ./deploy-to-minikube.sh"
echo "  2. Verificar: kubectl get all -n devsu-demo"
echo "  3. Acceder: minikube service devsu-demo-app-nodeport -n devsu-demo"
echo ""
echo "💡 Comandos útiles:"
echo "  minikube status          - Ver estado"
echo "  minikube dashboard       - Abrir dashboard"
echo "  minikube stop            - Detener cluster"
echo "  minikube delete          - Eliminar cluster"
echo "  kubectl get pods -A      - Ver todos los pods"
echo ""
