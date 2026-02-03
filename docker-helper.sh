#!/bin/bash

# Script de utilidad para gestionar la aplicación Docker
# Uso: ./docker-helper.sh [build|run|stop|logs|clean|all]

set -e

APP_NAME="devsu-demo-app"
IMAGE_NAME="devsu-demo-app:latest"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funciones
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

build_image() {
    print_info "Construyendo imagen Docker..."
    docker build -t ${IMAGE_NAME} .
    print_info "✓ Imagen construida exitosamente"
}

run_container() {
    print_info "Ejecutando contenedor..."
    docker-compose up -d
    print_info "✓ Contenedor ejecutándose"
    print_info "La aplicación estará disponible en: http://localhost:8000"
    print_info "Swagger UI: http://localhost:8000/api/swagger-ui.html"
    print_info "Health check: http://localhost:8000/api/actuator/health"
}

stop_container() {
    print_info "Deteniendo contenedor..."
    docker-compose down
    print_info "✓ Contenedor detenido"
}

show_logs() {
    print_info "Mostrando logs..."
    docker-compose logs -f
}

clean_all() {
    print_warning "Limpiando contenedores, imágenes y volúmenes..."
    docker-compose down -v
    docker rmi ${IMAGE_NAME} 2>/dev/null || true
    print_info "✓ Limpieza completada"
}

test_health() {
    print_info "Verificando health check..."
    sleep 5
    
    # Intentar actuator/health primero, luego swagger como fallback
    if curl -f http://localhost:8000/api/actuator/health 2>/dev/null; then
        print_info "✓ Aplicación saludable (actuator)"
    elif curl -f http://localhost:8000/api/swagger-ui.html 2>/dev/null; then
        print_info "✓ Aplicación respondiendo (swagger)"
    else
        print_error "✗ Aplicación no responde"
        return 1
    fi
    
    print_info "Swagger UI disponible en: http://localhost:8000/api/swagger-ui.html"
}

run_all() {
    build_image
    run_container
    print_info "Esperando que la aplicación esté lista..."
    sleep 30
    test_health
}

# Menu principal
case "$1" in
    build)
        build_image
        ;;
    run)
        run_container
        ;;
    stop)
        stop_container
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_all
        ;;
    health)
        test_health
        ;;
    all)
        run_all
        ;;
    *)
        echo "Uso: $0 {build|run|stop|logs|clean|health|all}"
        echo ""
        echo "Comandos:"
        echo "  build  - Construir la imagen Docker"
        echo "  run    - Ejecutar el contenedor"
        echo "  stop   - Detener el contenedor"
        echo "  logs   - Mostrar logs del contenedor"
        echo "  clean  - Limpiar contenedores e imágenes"
        echo "  health - Verificar health check"
        echo "  all    - Construir, ejecutar y verificar"
        exit 1
        ;;
esac

exit 0
