# 🚀 Devsu DevOps Challenge - Spring Boot Kubernetes Deployment

[![CI/CD Pipeline](https://github.com/marcogutama/test_devsu_devops//actions/workflows/ci-cd.yml/badge.svg)](https://github.com/marcogutama/test_devsu_devops//actions/workflows/ci-cd.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=marcogutama_test_devsu_devops&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=marcogutama_test_devsu_devops)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=marcogutama_test_devsu_devops&metric=coverage)](https://sonarcloud.io/summary/new_code?id=marcogutama_test_devsu_devops)
[![Docker Image](https://img.shields.io/docker/v/mgutama/devsu-demo-app?label=docker&logo=docker)](https://hub.docker.com/r/mgutama/devsu-demo-app)

> **Aplicación REST API** de gestión de usuarios construida con **Spring Boot 3.2**, completamente **dockerizada** y desplegada en **Kubernetes** con pipeline **CI/CD automatizado**.

---

## 📋 Tabla de Contenidos

1. [Descripción del Proyecto](#-descripción-del-proyecto)
2. [Arquitectura General](#-arquitectura-general)
3. [Tecnologías Utilizadas](#-tecnologías-utilizadas)
4. [Dockerización](#-dockerización)
5. [Pipeline CI/CD](#-pipeline-cicd)
6. [Deployment en Kubernetes](#-deployment-en-kubernetes)
7. [Decisiones Técnicas](#-decisiones-técnicas)
8. [Problemas y Soluciones](#-problemas-y-soluciones)
9. [Ejecución Local](#-ejecución-local)
10. [Mejoras para Producción](#-mejoras-para-producción)
11. [Conclusiones](#-conclusiones)

---

## 📝 Descripción del Proyecto

Este proyecto es una **aplicación REST API** desarrollada en **Spring Boot** para gestión de usuarios (CRUD completo), implementada siguiendo las mejores prácticas de **DevOps** y **SRE**.

### Características Principales

- ✅ **REST API completa** con operaciones CRUD
- ✅ **Documentación interactiva** con Swagger/OpenAPI
- ✅ **Base de datos H2** con persistencia
- ✅ **Health checks** con Spring Boot Actuator
- ✅ **Dockerización** con multi-stage builds
- ✅ **Pipeline CI/CD** automatizado con GitHub Actions
- ✅ **Kubernetes deployment** con alta disponibilidad
- ✅ **Auto-scaling** horizontal (HPA)
- ✅ **Security scanning** con Trivy
- ✅ **Code quality** con SonarCloud
- ✅ **Code coverage** >50% con JaCoCo

### Endpoints de la API

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/users` | Crear usuario |
| `GET` | `/api/users` | Listar usuarios |
| `GET` | `/api/users/{id}` | Obtener usuario por ID |
| `GET` | `/api/actuator/health` | Health check |
| `GET` | `/api/swagger-ui.html` | Documentación interactiva |

---

## 🏗 Arquitectura General

```
┌─────────────────────────────────────────────────────────────────────┐
│                         GITHUB REPOSITORY                            │
│                                                                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────────┐ │
│  │   Source   │  │   Docker   │  │ Kubernetes │  │    CI/CD     │ │
│  │    Code    │  │   Files    │  │ Manifests  │  │  Workflows   │ │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └──────┬───────┘ │
└────────┼───────────────┼───────────────┼─────────────────┼─────────┘
         │               │               │                 │
         │               │               │                 │
         └───────────────┴───────────────┴─────────────────┘
                                  │
                                  ▼
         ┌────────────────────────────────────────────────┐
         │           GITHUB ACTIONS PIPELINE              │
         │                                                 │
         │  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
         │  │  Build   │→ │  Test    │→ │ Analysis │    │
         │  │ & Test   │  │ Coverage │  │ SonarQube│    │
         │  └──────────┘  └──────────┘  └──────────┘    │
         │                                                 │
         │  ┌──────────┐  ┌──────────┐                   │
         │  │  Docker  │→ │   K8s    │                   │
         │  │  Build   │  │  Deploy  │                   │
         │  └────┬─────┘  └────┬─────┘                   │
         └───────┼─────────────┼─────────────────────────┘
                 │             │
                 ▼             ▼
         ┌─────────────┐  ┌─────────────────────────┐
         │  DOCKER HUB │  │  KUBERNETES CLUSTER     │
         │             │  │  (Minikube/Kind)        │
         │  ┌────────┐ │  │                         │
         │  │ Image  │ │  │  ┌────────────────────┐ │
         │  │:latest │ │  │  │  Deployment        │ │
         │  └────────┘ │  │  │  - 3 Replicas      │ │
         └─────────────┘  │  │  - HPA (2-10)      │ │
                          │  │  - ConfigMaps      │ │
                          │  │  - Secrets         │ │
                          │  │  - Ingress         │ │
                          │  │  - Services        │ │
                          │  └────────────────────┘ │
                          │                         │
                          │  ┌────────────────────┐ │
                          │  │  LoadBalancer      │ │
                          │  │  Service:8000      │ │
                          │  └───────┬────────────┘ │
                          └──────────┼──────────────┘
                                     │
                                     ▼
                          ┌──────────────────────┐
                          │   USUARIOS           │
                          │   http://IP:8000     │
                          └──────────────────────┘
```

---

## 🛠 Tecnologías Utilizadas

### Backend & Framework
- **Java 21** - Lenguaje de programación
- **Spring Boot 3.2.2** - Framework principal
- **Spring Data JPA** - Capa de persistencia
- **Spring Boot Actuator** - Métricas y health checks
- **H2 Database** - Base de datos (in-memory para K8s)
- **Lombok** - Reducción de boilerplate
- **ModelMapper** - Mapeo de DTOs

### Documentación
- **SpringDoc OpenAPI 3** - Generación de documentación
- **Swagger UI** - Interfaz interactiva de API

### Testing & Quality
- **JUnit 5** - Framework de testing
- **JaCoCo** - Code coverage (>50%)
- **SonarCloud** - Static code analysis
- **Maven Surefire** - Ejecución de tests

### DevOps & Infrastructure
- **Docker** - Containerización
- **Docker Compose** - Orquestación local
- **Kubernetes** - Orquestación en producción
- **Minikube** - Cluster local de K8s
- **Kind** - Kubernetes in Docker (CI/CD)
- **GitHub Actions** - CI/CD pipeline
- **Trivy** - Security scanning
- **Helm** - Package manager (Kind action)

### Cloud & Registry
- **Docker Hub** - Registry de imágenes
- **GitHub Container Registry** - Alternativa disponible

---

## 🐳 Dockerización

### Arquitectura Multi-Stage Build

```dockerfile
# STAGE 1: Builder
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# STAGE 2: Runtime
FROM eclipse-temurin:21-jre-alpine
RUN apk add --no-cache curl dumb-init
COPY --from=builder /app/target/*.jar app.jar
USER appuser
EXPOSE 8000
HEALTHCHECK CMD curl -f http://localhost:8000/api/actuator/health
ENTRYPOINT ["dumb-init", "--"]
CMD ["java", "-jar", "app.jar"]
```

### Mejores Prácticas Implementadas

| Práctica | Implementación | Beneficio |
|----------|----------------|-----------|
| **Multi-stage build** | Builder + Runtime | Imagen final ~200MB vs ~700MB |
| **Usuario no-root** | `USER appuser` | Seguridad mejorada |
| **Health checks** | Actuator endpoint | Monitoreo automático |
| **Signal handling** | dumb-init | Graceful shutdown |
| **Layer caching** | Dependencies separadas | Builds más rápidos |
| **Alpine Linux** | Base image minimal | Menor superficie de ataque |

### Características del Contenedor

- **Tamaño**: ~200MB (optimizado)
- **Usuario**: Non-root (UID 1000)
- **Puerto**: 8000
- **Health check**: `/api/actuator/health`
- **Variables de entorno**: Configurables
- **Volúmenes**: Soporte para datos persistentes

### Comandos Docker

```bash
# Build local
docker build -t devsu-demo-app:latest .

# Run local
docker run -d -p 8000:8000 --name devsu-app devsu-demo-app:latest

# Con docker-compose
docker-compose up -d
```

---

## 🔄 Pipeline CI/CD

### Arquitectura del Pipeline

El pipeline implementado en **GitHub Actions** incluye 5 stages principales:

```
┌─────────────────────────────────────────────────────────────┐
│                    GITHUB ACTIONS PIPELINE                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Stage 1: BUILD & TEST                   (2-3 min)          │
│  ├─ Checkout code                                           │
│  ├─ Setup JDK 21                                            │
│  ├─ Cache Maven dependencies                                │
│  ├─ Compile with Maven                                      │
│  ├─ Run unit tests                                          │
│  └─ Upload test results as artifacts                        │
│                                                              │
│  Stage 2: CODE COVERAGE                  (1-2 min)          │
│  ├─ Generate JaCoCo report                                  │
│  ├─ Upload to Codecov                                       │
│  ├─ Validate coverage threshold (>50%)                      │
│  └─ Upload coverage artifacts                               │
│                                                              │
│  Stage 3: STATIC CODE ANALYSIS           (2-3 min)          │
│  ├─ Run SonarCloud analysis                                 │
│  ├─ Detect bugs & vulnerabilities                           │
│  ├─ Check code smells                                       │
│  └─ Validate Quality Gate                                   │
│                                                              │
│  Stage 4: DOCKER BUILD & PUSH            (3-5 min)          │
│  ├─ Setup Docker Buildx                                     │
│  ├─ Login to Docker Hub                                     │
│  ├─ Build multi-stage image                                 │
│  ├─ Push to Docker Hub                                      │
│  ├─ Scan with Trivy (vulnerabilities)                       │
│  └─ Upload security scan results                            │
│                                                              │
│  Stage 5: KUBERNETES DEPLOYMENT          (3-5 min)          │
│  ├─ Create Kind cluster                                     │
│  ├─ Apply K8s manifests                                     │
│  ├─ Wait for deployment ready                               │
│  ├─ Run health checks                                       │
│  ├─ Test application endpoints                              │
│  └─ Cleanup cluster                                         │
│                                                              │
│  TOTAL TIME: 11-18 minutes                                  │
└─────────────────────────────────────────────────────────────┘
```

### Triggers del Pipeline

```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
```

### Métricas del Pipeline

| Métrica | Valor |
|---------|-------|
| **Tiempo promedio** | 12-15 minutos |
| **Tests ejecutados** | 12 unit tests |
| **Code coverage** | >50% |
| **Bugs detectados** | 0 |
| **Vulnerabilidades** | 0 (critical/high) |
| **Quality Gate** | PASSED |

### Secrets Configurados

```
SONAR_TOKEN           # Token de SonarCloud
SONAR_PROJECT_KEY     # Clave del proyecto
SONAR_ORGANIZATION    # Organización en SonarCloud
DOCKER_USERNAME       # Usuario de Docker Hub
DOCKER_PASSWORD       # Access token de Docker Hub
CODECOV_TOKEN         # Token de Codecov (opcional)
```

---

## ☸️ Deployment en Kubernetes

### Arquitectura de Kubernetes

```
┌─────────────────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER (Minikube)                     │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                   NAMESPACE: devsu-demo                         │ │
│  │                                                                 │ │
│  │  ┌──────────────────────────────────────────────────────────┐  │ │
│  │  │                    INGRESS CONTROLLER                     │  │ │
│  │  │  devsu-demo.local → Service                              │  │ │
│  │  │  Rate limiting: 100 req/s                                │  │ │
│  │  └────────────────┬─────────────────────────────────────────┘  │ │
│  │                   │                                             │ │
│  │  ┌────────────────▼─────────────────────────────────────────┐  │ │
│  │  │            SERVICE (ClusterIP + NodePort)                │  │ │
│  │  │  ClusterIP: devsu-demo-app:8000                          │  │ │
│  │  │  NodePort: 30080                                         │  │ │
│  │  │  Session Affinity: ClientIP                              │  │ │
│  │  └────────────────┬─────────────────────────────────────────┘  │ │
│  │                   │                                             │ │
│  │  ┌────────────────▼─────────────────────────────────────────┐  │ │
│  │  │               DEPLOYMENT (3 replicas)                    │  │ │
│  │  │  Strategy: RollingUpdate                                 │  │ │
│  │  │  MaxSurge: 1, MaxUnavailable: 1                          │  │ │
│  │  │                                                           │  │ │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │  │ │
│  │  │  │   POD 1     │  │   POD 2     │  │   POD 3     │      │  │ │
│  │  │  │             │  │             │  │             │      │  │ │
│  │  │  │  Container  │  │  Container  │  │  Container  │      │  │ │
│  │  │  │  App:8000   │  │  App:8000   │  │  App:8000   │      │  │ │
│  │  │  │             │  │             │  │             │      │  │ │
│  │  │  │  Resources: │  │  Resources: │  │  Resources: │      │  │ │
│  │  │  │  CPU: 250m  │  │  CPU: 250m  │  │  CPU: 250m  │      │  │ │
│  │  │  │  Mem: 512Mi │  │  Mem: 512Mi │  │  Mem: 512Mi │      │  │ │
│  │  │  │             │  │             │  │             │      │  │ │
│  │  │  │  Probes:    │  │  Probes:    │  │  Probes:    │      │  │ │
│  │  │  │  ✓ Liveness │  │  ✓ Liveness │  │  ✓ Liveness │      │  │ │
│  │  │  │  ✓ Readiness│  │  ✓ Readiness│  │  ✓ Readiness│      │  │ │
│  │  │  │  ✓ Startup  │  │  ✓ Startup  │  │  ✓ Startup  │      │  │ │
│  │  │  │             │  │             │  │             │      │  │ │
│  │  │  │  H2:memory  │  │  H2:memory  │  │  H2:memory  │      │  │ │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘      │  │ │
│  │  │                                                           │  │ │
│  │  └───────────────────────────────────────────────────────────┘  │ │
│  │                                                                 │ │
│  │  ┌──────────────────────────────────────────────────────────┐  │ │
│  │  │        HORIZONTAL POD AUTOSCALER (HPA)                   │  │ │
│  │  │  Min: 2 replicas | Max: 10 replicas                      │  │ │
│  │  │  Target CPU: 70% | Target Memory: 80%                    │  │ │
│  │  │  Current: 3 replicas | CPU: 15% | Memory: 45%            │  │ │
│  │  └──────────────────────────────────────────────────────────┘  │ │
│  │                                                                 │ │
│  │  ┌──────────────────────────────────────────────────────────┐  │ │
│  │  │              CONFIGMAPS & SECRETS                         │  │ │
│  │  │                                                           │  │ │
│  │  │  ConfigMap: devsu-app-config                             │  │ │
│  │  │  - PORT: 8000                                            │  │ │
│  │  │  - SPRING_PROFILES_ACTIVE: prod                          │  │ │
│  │  │  - JAVA_OPTS: -Xmx512m -Xms256m                          │  │ │
│  │  │  - NAME_DB: jdbc:h2:mem:devsudb                          │  │ │
│  │  │                                                           │  │ │
│  │  │  Secret: devsu-app-secret                                │  │ │
│  │  │  - USERNAME_DB: (base64)                                 │  │ │
│  │  │  - PASSWORD_DB: (base64)                                 │  │ │
│  │  └──────────────────────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### Recursos de Kubernetes Desplegados

| Recurso | Cantidad | Descripción |
|---------|----------|-------------|
| **Namespace** | 1 | Aislamiento de recursos |
| **Deployment** | 1 | 3 réplicas del pod |
| **Service** | 2 | ClusterIP + NodePort |
| **ConfigMap** | 1 | Configuración de la app |
| **Secret** | 1 | Credenciales encriptadas |
| **HPA** | 1 | Auto-scaling 2-10 réplicas |
| **Ingress** | 1 | Exposición HTTP/HTTPS |
| **PVC** | 0 | No requerido (H2 memory) |

### Manifiestos de Kubernetes

```
k8s/
├── namespace.yaml            # Namespace devsu-demo
├── configmap.yaml           # Variables de configuración
├── secret.yaml              # Credenciales (base64)
├── deployment.yaml          # 3 réplicas con health checks
├── service.yaml             # ClusterIP + NodePort
├── hpa.yaml                 # Auto-scaling configuration
├── ingress.yaml             # Nginx ingress rules
├── setup-minikube.sh        # Script de instalación
├── deploy-to-minikube.sh    # Script de deployment
└── test-hpa.sh              # Script de prueba de scaling
```

### Health Checks Configurados

```yaml
livenessProbe:
  httpGet:
    path: /api/actuator/health/liveness
    port: 8000
  initialDelaySeconds: 60
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /api/actuator/health/readiness
    port: 8000
  initialDelaySeconds: 30
  periodSeconds: 5

startupProbe:
  httpGet:
    path: /api/actuator/health
    port: 8000
  failureThreshold: 30
  periodSeconds: 10
```

### Recursos y Límites

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

### Auto-scaling (HPA)

```yaml
minReplicas: 2
maxReplicas: 10
targetCPUUtilizationPercentage: 70
targetMemoryUtilizationPercentage: 80
```

---

## 🎯 Decisiones Técnicas

### 1. Elección de Java/Spring Boot

**Decisión**: Usar Java 21 con Spring Boot 3.2.2

**Justificación**:
- ✅ Lenguaje robusto y probado en producción
- ✅ Spring Boot ofrece auto-configuración y productividad
- ✅ Ecosistema maduro con amplia documentación
- ✅ Soporte nativo para Kubernetes (Actuator)
- ✅ Java 21 LTS con mejoras de performance

### 2. Multi-Stage Docker Build

**Decisión**: Implementar build en 2 etapas (Builder + Runtime)

**Justificación**:
- ✅ Reducción de tamaño de imagen (70% menos)
- ✅ Separación de concerns (build vs runtime)
- ✅ Mayor seguridad (sin herramientas de compilación)
- ✅ Mejor cacheo de dependencias
- ✅ Builds más rápidos en iteraciones

### 3. Usuario No-Root en Docker

**Decisión**: Ejecutar contenedor como usuario `appuser` (UID 1000)

**Justificación**:
- ✅ Principio de mínimo privilegio
- ✅ Cumplimiento de security best practices
- ✅ Reducción de superficie de ataque
- ✅ Compatibilidad con security policies de K8s

### 4. H2 Database en Modo In-Memory para Kubernetes

**Decisión**: Usar `jdbc:h2:mem` en lugar de `jdbc:h2:file`

**Justificación**:
- ✅ **Problema identificado**: H2 file-based no soporta acceso concurrente
- ✅ Permite múltiples réplicas simultáneas
- ✅ Cumple requisito de HA (3 réplicas)
- ✅ Simplifica deployment (no requiere PVC)
- ⚠️ **Trade-off**: Datos no persistentes entre reinicios
- ✅ **Producción**: Se usaría PostgreSQL/MySQL con StatefulSet

### 5. GitHub Actions vs Otras Plataformas

**Decisión**: Usar GitHub Actions como plataforma de CI/CD

**Justificación**:
- ✅ Integración nativa con GitHub
- ✅ 2,000 minutos gratis/mes (suficiente)
- ✅ YAML como código (versionable)
- ✅ Ecosystem robusto de actions
- ✅ Secrets management integrado
- ✅ No requiere infraestructura adicional

### 6. Minikube + Kind (Enfoque Híbrido)

**Decisión**: Usar Minikube para local y Kind para CI/CD

**Justificación**:

**Minikube**:
- ✅ Cluster persistente para demos
- ✅ Dashboard visual
- ✅ Múltiples opciones de acceso (NodePort, Ingress)
- ✅ Addons pre-configurados

**Kind**:
- ✅ Ephemeral cluster en pipeline
- ✅ Testing automatizado de deployment
- ✅ Más ligero y rápido
- ✅ Ideal para CI/CD

### 7. ConfigMaps y Secrets

**Decisión**: Externalizar toda configuración sensible

**Justificación**:
- ✅ Principio 12-factor app
- ✅ Facilita cambios sin rebuild
- ✅ Secrets encriptados con base64
- ✅ Separación de configuración y código

### 8. Horizontal Pod Autoscaler (HPA)

**Decisión**: Configurar auto-scaling basado en CPU y Memoria

**Justificación**:
- ✅ Elasticidad automática
- ✅ Optimización de recursos
- ✅ Manejo de picos de tráfico
- ✅ Reducción de costos (scale down)

### 9. SonarCloud para Static Analysis

**Decisión**: Usar SonarCloud en lugar de SonarQube self-hosted

**Justificación**:
- ✅ Gratuito para repos públicos
- ✅ No requiere infraestructura
- ✅ Integración directa con GitHub
- ✅ Quality Gates configurables

### 10. Trivy para Security Scanning

**Decisión**: Escanear imágenes Docker con Trivy

**Justificación**:
- ✅ Detección de vulnerabilidades en tiempo de build
- ✅ Gratuito y open-source
- ✅ Base de datos actualizada diariamente
- ✅ Integración con GitHub Security

---

## 🔥 Problemas y Soluciones

### Problema 1: H2 File Lock con Múltiples Réplicas

**Descripción**:
```
Caused by: org.h2.mvstore.MVStoreException: The file is locked: /app/data/test.mv.db
```

Al desplegar 3 réplicas en Kubernetes, múltiples pods intentaban acceder simultáneamente al archivo de base de datos H2, resultando en:
- 1 pod Running
- 2 pods en CrashLoopBackOff

**Causa Raíz**:
H2 en modo archivo (`jdbc:h2:file`) utiliza file locking para garantizar consistencia, permitiendo solo una conexión activa al archivo. Esto es incompatible con arquitecturas de múltiples réplicas.

**Soluciones Evaluadas**:

| Solución | Pros | Contras | Implementada |
|----------|------|---------|--------------|
| H2 In-Memory | Simple, 3+ réplicas | No persistente | ✅ Sí |
| PostgreSQL | Production-ready | Requiere rebuild | ❌ No |
| 1 Réplica | Simple | No cumple requisito | ❌ No |

**Solución Implementada**: H2 In-Memory

**Justificación**:
- ✅ Cumple requisito de 2+ réplicas (tenemos 3)
- ✅ No requiere cambios en código
- ✅ Deployment inmediato
- ✅ Demuestra conocimiento de Kubernetes
- ✅ HPA funciona correctamente

**Configuración**:
```yaml
# configmap.yaml
NAME_DB: "jdbc:h2:mem:devsudb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE"
```

**Trade-off Aceptado**:
- Cada pod tiene su propia base de datos en memoria
- Los datos no persisten entre reinicios de pods
- Para producción se usaría PostgreSQL/MySQL con conexión compartida

**Mejora para Producción**:
Se incluye manifiestos de PostgreSQL (`postgres.yaml`) para demostrar cómo se implementaría en producción:
- StatefulSet o Deployment de PostgreSQL
- PersistentVolumeClaim para datos
- Service interno para conexión
- Múltiples réplicas de la app conectándose a la misma DB

---

### Problema 2: GitHub Actions - Permisos de Test Reporter

**Descripción**:
```
Error: HttpError: Resource not accessible by integration
```

El action `dorny/test-reporter@v1` fallaba al intentar crear Check Runs en GitHub.

**Causa Raíz**:
El `GITHUB_TOKEN` por defecto no tiene permisos de escritura para crear checks.

**Solución**:
Agregar permisos explícitos al workflow:

```yaml
permissions:
  contents: read
  checks: write
  pull-requests: write
  statuses: write
  security-events: write
```

**Resultado**: ✅ Test reports generados correctamente

---

### Problema 3: Estructura de Directorios con GitHub Actions

**Descripción**:
GitHub Actions no encontraba los workflows porque estaban en un subdirectorio.

**Estructura Inicial** (incorrecta):
```
test_devsu_devops/
├── .git/
└── devsu-demo-devops-java/
    └── .github/workflows/
```

**Solución**:
Cambiar la raíz del repositorio Git al directorio del proyecto:

```bash
cd devsu-demo-devops-java
git init
git remote add origin URL
git push -u origin main
```

**Estructura Final** (correcta):
```
devsu-demo-devops-java/
├── .git/
├── .github/workflows/
├── k8s/
└── src/
```

**Resultado**: ✅ Pipeline se ejecuta automáticamente

---

### Problema 4: SonarCloud - Análisis Fallo Inicial

**Descripción**:
SonarCloud fallaba con error de binaries no encontrados.

**Solución**:
Agregar parámetro faltante en el análisis:

```bash
mvn sonar:sonar \
  -Dsonar.java.binaries=target/classes \
  ...
```

**Resultado**: ✅ Análisis completado exitosamente

---

### Problema 5: Docker Build - Cache Ineficiente

**Descripción**:
Builds de Docker tomaban >10 minutos en el pipeline.

**Solución**:
Implementar multi-stage build con layer caching:

```dockerfile
# Cache de dependencias
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Código fuente en capa separada
COPY src ./src
RUN mvn clean package
```

**Configuración GitHub Actions**:
```yaml
cache-from: type=registry,ref=USER/IMAGE:buildcache
cache-to: type=registry,ref=USER/IMAGE:buildcache,mode=max
```

**Resultado**: ✅ Build reducido a 3-5 minutos

---

## 💻 Ejecución Local

### Prerrequisitos

- **Java 21** o superior
- **Maven 3.6+**
- **Docker** y **Docker Compose**
- **kubectl**
- **Minikube** (para Kubernetes local)

### Opción 1: Ejecución con Maven

```bash
# Clonar repositorio
git clone https://github.com/marcogutama/test_devsu_devops/.git
cd devsu-demo-devops-java

# Compilar
mvn clean compile

# Ejecutar tests
mvn test

# Ejecutar aplicación
mvn spring-boot:run

# Acceder
open http://localhost:8000/api/swagger-ui.html
```

### Opción 2: Ejecución con Docker

```bash
# Build de imagen
docker build -t devsu-demo-app:latest .

# Ejecutar contenedor
docker run -d -p 8000:8000 --name devsu-app devsu-demo-app:latest

# Ver logs
docker logs -f devsu-app

# Health check
curl http://localhost:8000/api/actuator/health

# Acceder
open http://localhost:8000/api/swagger-ui.html
```

### Opción 3: Ejecución con Docker Compose

```bash
# Iniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down

# Acceder
open http://localhost:8000/api/swagger-ui.html
```

### Opción 4: Deployment en Minikube

```bash
# 1. Instalar Minikube
cd k8s
chmod +x setup-minikube.sh
./setup-minikube.sh

# 2. Desplegar aplicación
chmod +x deploy-to-minikube.sh
./deploy-to-minikube.sh
# Cuando pregunte: ingresar usuario de Docker Hub (mgutama)

# 3. Acceder a la aplicación
minikube service devsu-demo-app-nodeport -n devsu-demo

# 4. Ver dashboard
minikube dashboard

# 5. Verificar deployment
kubectl get all -n devsu-demo
kubectl get hpa -n devsu-demo
```

### Testing de Endpoints

```bash
# Health check
curl http://localhost:8000/api/actuator/health

# Crear usuario
curl -X POST http://localhost:8000/api/users \
  -H 'Content-Type: application/json' \
  -d '{"dni":"1234567890","name":"Marco Gutierrez"}'

# Listar usuarios
curl http://localhost:8000/api/users

# Obtener usuario por ID
curl http://localhost:8000/api/users/1
```

---

## 🚀 Mejoras para Producción

### 1. Base de Datos

**Estado Actual**: H2 in-memory

**Mejora**:
- Usar PostgreSQL o MySQL con StatefulSet
- Implementar backups automáticos
- Configurar replicación master-slave
- Usar servicios managed (RDS, Cloud SQL)

### 2. Secrets Management

**Estado Actual**: Kubernetes Secrets (base64)

**Mejora**:
- Implementar HashiCorp Vault
- Usar AWS Secrets Manager / Azure Key Vault
- Rotación automática de secretos
- Encriptación en reposo con KMS

### 3. Observabilidad

**Estado Actual**: Logs básicos y health checks

**Mejora**:
- Implementar Prometheus + Grafana
- Logs centralizados con ELK Stack
- Distributed tracing con Jaeger/Zipkin
- APM con Datadog o New Relic
- Alerting con PagerDuty

### 4. Ingress y DNS

**Estado Actual**: Nginx Ingress en Minikube

**Mejora**:
- Certificados SSL/TLS con Let's Encrypt
- DNS con Route53 o Cloud DNS
- WAF (Web Application Firewall)
- Rate limiting avanzado
- DDoS protection

### 5. CI/CD Avanzado

**Estado Actual**: Pipeline básico en GitHub Actions

**Mejora**:
- Implementar GitOps con ArgoCD/Flux
- Deployment strategies (Blue/Green, Canary)
- Smoke tests automatizados
- Performance testing en pipeline
- Rollback automático en fallos

### 6. Security

**Mejoras**:
- SAST/DAST en pipeline
- Container image signing
- Network policies en Kubernetes
- RBAC granular
- Pod Security Policies/Admission Controllers
- Regular penetration testing

### 7. Alta Disponibilidad

**Mejoras**:
- Multi-zone deployment
- Disaster recovery plan
- Backup y restore automatizado
- Chaos engineering (Chaos Monkey)
- SLA monitoring

### 8. Performance

**Mejoras**:
- CDN para assets estáticos
- Redis para caching
- Connection pooling optimizado
- Database query optimization
- Load testing con k6/Locust

### 9. Compliance

**Mejoras**:
- Audit logging completo
- Compliance scanning (PCI-DSS, SOC2)
- Data encryption at rest y in transit
- GDPR compliance
- Regular security audits

### 10. Infrastructure as Code

**Mejoras**:
- Terraform/Pulumi para infraestructura
- Helm charts para aplicaciones
- GitOps workflow completo
- Environment promotion automatizado
- Cost optimization con FinOps

---

## 📊 Conclusiones

### Objetivos Cumplidos

- ✅ **Dockerización completa** con multi-stage builds y optimizaciones
- ✅ **Pipeline CI/CD** con 5 stages (Build, Test, Coverage, Analysis, Deploy)
- ✅ **Kubernetes deployment** con 3 réplicas y auto-scaling
- ✅ **ConfigMaps y Secrets** para configuración externalizada
- ✅ **Ingress** configurado con Nginx
- ✅ **Health checks** completos (Liveness, Readiness, Startup)
- ✅ **Security scanning** con Trivy
- ✅ **Code coverage** >50% con JaCoCo
- ✅ **Static analysis** con SonarCloud
- ✅ **Documentación completa** con diagramas

### Métricas del Proyecto

| Métrica | Valor |
|---------|-------|
| **Tamaño imagen Docker** | ~200MB (optimizado) |
| **Tiempo de build** | 3-5 minutos |
| **Tiempo pipeline completo** | 12-15 minutos |
| **Code coverage** | >50% |
| **Bugs detectados** | 0 |
| **Vulnerabilidades críticas** | 0 |
| **Réplicas en K8s** | 3 (2-10 con HPA) |
| **Health check success rate** | 100% |
| **Tests ejecutados** | 12 unit tests |

### Lecciones Aprendidas

1. **H2 y múltiples réplicas**: H2 file-based no es compatible con arquitecturas de HA
2. **Multi-stage builds**: Reducen significativamente el tamaño de imágenes
3. **Health checks en K8s**: Son críticos para rolling updates sin downtime
4. **GitOps**: Versionar infraestructura como código facilita colaboración
5. **Security first**: Escanear vulnerabilidades en cada build previene problemas

### Habilidades Demostradas

- ✅ **Docker**: Containerización, multi-stage builds, optimización
- ✅ **Kubernetes**: Deployments, Services, ConfigMaps, Secrets, HPA, Ingress
- ✅ **CI/CD**: GitHub Actions, pipeline as code, automated testing
- ✅ **Security**: Vulnerability scanning, secrets management, non-root users
- ✅ **Monitoring**: Health checks, actuator, metrics
- ✅ **Best Practices**: 12-factor app, GitOps, Infrastructure as Code

---

## 📞 Información de Contacto

**Autor**: Marco Gutama 
**Email**: paul.gutama@gmail.com  
**LinkedIn**: https://www.linkedin.com/in/marcogutama/
**GitHub**: https://github.com/marcogutama

---

## 📚 Referencias

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [SonarCloud](https://sonarcloud.io/)
- [12-Factor App](https://12factor.net/)

---

## 📄 Licencia

Este proyecto es un ejercicio técnico para demostración de habilidades DevOps.

---

**Desarrollado con ❤️ para Devsu DevOps Challenge**

