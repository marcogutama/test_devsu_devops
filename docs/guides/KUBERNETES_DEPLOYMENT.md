# 🚢 Guía de Deployment en Kubernetes

## 📋 Índice

1. [Descripción General](#descripción-general)
2. [Arquitectura de Kubernetes](#arquitectura-de-kubernetes)
3. [Opción 1: Minikube (Local)](#opción-1-minikube-local)
4. [Opción 2: Kind (CI/CD)](#opción-2-kind-cicd)
5. [Manifiestos de Kubernetes](#manifiestos-de-kubernetes)
6. [Verificación y Testing](#verificación-y-testing)
7. [Troubleshooting](#troubleshooting)

---

## Descripción General

Este proyecto incluye deployment completo a Kubernetes con:

✅ **2+ Réplicas** - Alta disponibilidad  
✅ **Auto-scaling** - HPA basado en CPU/Memoria  
✅ **ConfigMaps** - Configuración externalizada  
✅ **Secrets** - Credenciales seguras  
✅ **Ingress** - Exposición HTTP/HTTPS  
✅ **Health Checks** - Liveness y Readiness probes  
✅ **Persistent Storage** - Volúmenes para H2  
✅ **Resource Limits** - Control de recursos  

---

## Arquitectura de Kubernetes

```
┌─────────────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                            │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    NAMESPACE: devsu-demo                    │ │
│  │                                                             │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │                     INGRESS                          │  │ │
│  │  │  devsu-demo.local → Service                          │  │ │
│  │  └────────────────┬─────────────────────────────────────┘  │ │
│  │                   │                                         │ │
│  │  ┌────────────────▼─────────────────────────────────────┐  │ │
│  │  │                   SERVICE                            │  │ │
│  │  │  ClusterIP: devsu-demo-app:8000                      │  │ │
│  │  │  NodePort: 30080                                     │  │ │
│  │  └────────────────┬─────────────────────────────────────┘  │ │
│  │                   │                                         │ │
│  │  ┌────────────────▼─────────────────────────────────────┐  │ │
│  │  │                DEPLOYMENT                            │  │ │
│  │  │  Replicas: 3 (min: 2, max: 10)                       │  │ │
│  │  │  Strategy: RollingUpdate                             │  │ │
│  │  │                                                       │  │ │
│  │  │  ┌───────────┐  ┌───────────┐  ┌───────────┐        │  │ │
│  │  │  │   POD 1   │  │   POD 2   │  │   POD 3   │        │  │ │
│  │  │  │ Container │  │ Container │  │ Container │        │  │ │
│  │  │  │  App:8000 │  │  App:8000 │  │  App:8000 │        │  │ │
│  │  │  │           │  │           │  │           │        │  │ │
│  │  │  │  Volume   │  │  Volume   │  │  Volume   │        │  │ │
│  │  │  │  /app/data│  │  /app/data│  │  /app/data│        │  │ │
│  │  │  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘        │  │ │
│  │  │        │               │               │              │  │ │
│  │  └────────┼───────────────┼───────────────┼──────────────┘  │ │
│  │           │               │               │                 │ │
│  │  ┌────────▼───────────────▼───────────────▼──────────────┐  │ │
│  │  │            PERSISTENT VOLUME CLAIM                    │  │ │
│  │  │            devsu-app-pvc (1Gi)                        │  │ │
│  │  └────────────────────────────────────────────────────────┘  │ │
│  │                                                             │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │         HORIZONTAL POD AUTOSCALER                    │  │ │
│  │  │  Min: 2 replicas | Max: 10 replicas                  │  │ │
│  │  │  Scale on: CPU > 70%, Memory > 80%                   │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  │                                                             │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │              CONFIGMAP & SECRETS                      │  │ │
│  │  │  ConfigMap: devsu-app-config                         │  │ │
│  │  │  Secret: devsu-app-secret                            │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## Opción 1: Minikube (Local)

### 🎯 Para qué es

- Desarrollo local
- Testing manual
- Demostraciones
- Screenshots para documentación

### 📦 Instalación

```bash
cd k8s

# 1. Instalar Minikube y dependencias
chmod +x setup-minikube.sh
./setup-minikube.sh

# Esto instalará:
# - Docker (si no está)
# - kubectl
# - Minikube
# - Iniciará el cluster
# - Habilitará addons necesarios
```

### 🚀 Deployment

```bash
# 2. Desplegar la aplicación
chmod +x deploy-to-minikube.sh
./deploy-to-minikube.sh

# Durante la ejecución te pedirá tu usuario de Docker Hub
# Ejemplo: marcogutierrez (sin espacios)
```

### 🔍 Acceder a la Aplicación

Después del deployment, tendrás varias opciones:

#### Opción A: NodePort (Recomendado)
```bash
# Obtener IP de Minikube
MINIKUBE_IP=$(minikube ip)

# Abrir en navegador
http://${MINIKUBE_IP}:30080/api/swagger-ui.html
```

#### Opción B: Minikube Service (Automático)
```bash
# Abre automáticamente el navegador
minikube service devsu-demo-app-nodeport -n devsu-demo
```

#### Opción C: Port-Forward
```bash
# Forward del puerto
kubectl port-forward -n devsu-demo svc/devsu-demo-app 8000:8000

# Acceder en:
http://localhost:8000/api/swagger-ui.html
```

#### Opción D: Ingress
```bash
# 1. Obtener IP de Minikube
MINIKUBE_IP=$(minikube ip)

# 2. Agregar a /etc/hosts
echo "${MINIKUBE_IP} devsu-demo.local" | sudo tee -a /etc/hosts

# 3. Acceder
http://devsu-demo.local/api/swagger-ui.html
```

### 🧪 Verificaciones

```bash
# Ver estado general
kubectl get all -n devsu-demo

# Ver pods
kubectl get pods -n devsu-demo -o wide

# Ver logs
kubectl logs -f deployment/devsu-demo-app -n devsu-demo

# Ver eventos
kubectl get events -n devsu-demo --sort-by='.lastTimestamp'

# Ver HPA
kubectl get hpa -n devsu-demo -w

# Dashboard
minikube dashboard
```

### 🧹 Limpieza

```bash
# Eliminar la aplicación
kubectl delete namespace devsu-demo

# Detener Minikube
minikube stop

# Eliminar Minikube completamente
minikube delete
```

---

## Opción 2: Kind (CI/CD)

### 🎯 Para qué es

- CI/CD automatizado
- Tests de deployment
- Validación en pipeline
- Sin configuración local

### ✅ Cómo Funciona

El pipeline de GitHub Actions automáticamente:

1. Crea un cluster Kind efímero
2. Despliega la aplicación
3. Ejecuta health checks
4. Verifica que todo funciona
5. Elimina el cluster

### 📊 Ver en Acción

```
GitHub → Actions → CI/CD Pipeline → Job: Deploy to Kubernetes (Kind)
```

Verás:
- ✅ Create Kind Cluster
- ✅ Deploy to Kubernetes
- ✅ Test Application
- ✅ Deployment Summary

### 🔍 Logs y Debugging

Si falla el deployment en Kind:

1. Ve a GitHub Actions
2. Click en el job "Deploy to Kubernetes (Kind)"
3. Expande cada step para ver logs
4. Descarga artifacts si están disponibles

---

## Manifiestos de Kubernetes

### 📁 Estructura

```
k8s/
├── namespace.yaml           # Namespace aislado
├── configmap.yaml          # Configuración no sensible
├── secret.yaml             # Credenciales encriptadas
├── pvc.yaml                # Persistent Volume Claim
├── deployment.yaml         # Deployment con 3 réplicas
├── service.yaml            # Service ClusterIP + NodePort
├── hpa.yaml                # Horizontal Pod Autoscaler
├── ingress.yaml            # Ingress controller
├── setup-minikube.sh       # Script de instalación
└── deploy-to-minikube.sh   # Script de deployment
```

### 🔧 ConfigMap

Contiene configuración no sensible:

- Puerto de la aplicación
- Variables de Java
- Timezone
- Logging level
- Configuración de H2

**Modificar:**
```bash
kubectl edit configmap devsu-app-config -n devsu-demo
```

### 🔐 Secrets

Contiene credenciales sensibles (base64):

- USERNAME_DB
- PASSWORD_DB

**Crear nuevo secret:**
```bash
# Encode
echo -n "nuevo-password" | base64

# Aplicar
kubectl create secret generic devsu-app-secret \
  --from-literal=PASSWORD_DB=nuevo-password \
  -n devsu-demo --dry-run=client -o yaml | kubectl apply -f -
```

### 🚢 Deployment

Características:

- **Réplicas:** 3 (mín: 2, máx: 10 con HPA)
- **Strategy:** RollingUpdate (cero downtime)
- **Health Checks:** Liveness, Readiness, Startup
- **Resources:** Requests y Limits definidos
- **Security:** Non-root user, read-only filesystem
- **Volumes:** PVC para datos H2

**Escalar manualmente:**
```bash
kubectl scale deployment devsu-demo-app --replicas=5 -n devsu-demo
```

### 📈 HPA (Auto-scaling)

Configurado para:

- **CPU:** Escala cuando > 70%
- **Memoria:** Escala cuando > 80%
- **Min replicas:** 2
- **Max replicas:** 10

**Ver estado:**
```bash
kubectl get hpa -n devsu-demo -w
```

**Generar carga para testing:**
```bash
# Obtener IP y puerto
MINIKUBE_IP=$(minikube ip)

# Generar carga
for i in {1..1000}; do
  curl -s http://${MINIKUBE_IP}:30080/api/users > /dev/null &
done

# Ver HPA escalando
kubectl get hpa -n devsu-demo -w
```

---

## Verificación y Testing

### ✅ Health Checks

```bash
# Health
curl http://${MINIKUBE_IP}:30080/api/actuator/health

# Readiness
curl http://${MINIKUBE_IP}:30080/api/actuator/health/readiness

# Liveness
curl http://${MINIKUBE_IP}:30080/api/actuator/health/liveness
```

### 🧪 API Testing

```bash
# Crear usuario
curl -X POST http://${MINIKUBE_IP}:30080/api/users \
  -H 'Content-Type: application/json' \
  -d '{"dni":"1234567890","name":"Test User"}'

# Listar usuarios
curl http://${MINIKUBE_IP}:30080/api/users

# Obtener usuario
curl http://${MINIKUBE_IP}:30080/api/users/1
```

### 📊 Monitoreo

```bash
# CPU y Memoria de pods
kubectl top pods -n devsu-demo

# Describe pod
kubectl describe pod <pod-name> -n devsu-demo

# Events
kubectl get events -n devsu-demo --sort-by='.lastTimestamp'

# Logs en tiempo real
kubectl logs -f deployment/devsu-demo-app -n devsu-demo --all-containers
```

---

## Troubleshooting

### Pods no inician

```bash
# Ver estado
kubectl get pods -n devsu-demo

# Ver eventos
kubectl describe pod <pod-name> -n devsu-demo

# Ver logs
kubectl logs <pod-name> -n devsu-demo
```

**Causas comunes:**
- Imagen no encontrada (verificar DOCKER_USERNAME)
- Recursos insuficientes (aumentar memoria de Minikube)
- PVC no bound (verificar storage class)

### HPA no funciona

```bash
# Verificar metrics-server
kubectl get apiservice v1beta1.metrics.k8s.io

# Si no está:
minikube addons enable metrics-server

# Verificar métricas
kubectl top pods -n devsu-demo
```

### Ingress no funciona

```bash
# Verificar addon
minikube addons list | grep ingress

# Habilitar si necesario
minikube addons enable ingress

# Ver ingress controller
kubectl get pods -n ingress-nginx
```

### Cannot pull image

```bash
# Verificar que la imagen existe en Docker Hub
docker pull tu-usuario/devsu-demo-app:latest

# Verificar que la imagen está actualizada en deployment.yaml
kubectl get deployment devsu-demo-app -n devsu-demo -o yaml | grep image:

# Actualizar imagen
kubectl set image deployment/devsu-demo-app \
  devsu-demo-app=tu-usuario/devsu-demo-app:latest \
  -n devsu-demo
```

---

## 📸 Screenshots Recomendados

Para documentación, toma screenshots de:

1. **Minikube Dashboard**
   ```bash
   minikube dashboard
   ```

2. **Pods Running**
   ```bash
   kubectl get pods -n devsu-demo -o wide
   ```

3. **HPA Working**
   ```bash
   kubectl get hpa -n devsu-demo
   ```

4. **Application UI**
   - Swagger UI
   - API responses

5. **GitHub Actions**
   - Pipeline completo exitoso
   - Kubernetes deployment job

---

## 🎯 Resultados Esperados

Después de completar el deployment:

✅ 3 pods corriendo  
✅ Service ClusterIP creado  
✅ NodePort accesible  
✅ HPA configurado (2-10 replicas)  
✅ Ingress funcionando  
✅ Health checks pasando  
✅ Pipeline CI/CD completo  
✅ Aplicación accesible y funcional  

---

## 📚 Referencias

- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Minikube Docs](https://minikube.sigs.k8s.io/docs/)
- [Kind Docs](https://kind.sigs.k8s.io/)
- [Spring Boot on Kubernetes](https://spring.io/guides/gs/spring-boot-kubernetes/)

---

**¡Deployment completado!** 🎉
