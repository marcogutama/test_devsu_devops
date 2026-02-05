# 🔧 Solución: H2 File Lock con Múltiples Réplicas

## ❌ El Problema

```
Caused by: org.h2.mvstore.MVStoreException: The file is locked: /app/data/test.mv.db
```

**Causa:** H2 en modo archivo (`jdbc:h2:file`) NO soporta acceso concurrente. Solo un proceso puede abrir el archivo a la vez. Con 3 réplicas en Kubernetes, múltiples pods intentan acceder al mismo archivo → **File Lock**.

---

## ✅ Soluciones (3 Opciones)

### 📊 Comparación Rápida

| Solución | Complejidad | Producción | Réplicas | Persistencia |
|----------|-------------|------------|----------|--------------|
| **1. H2 In-Memory** | ⭐ Baja | ❌ No | ✅ 3+ | ❌ No |
| **2. PostgreSQL** | ⭐⭐ Media | ✅ Sí | ✅ 3+ | ✅ Sí |
| **3. 1 Réplica** | ⭐ Baja | ❌ No | ❌ 1 | ✅ Sí |

---

## 🚀 Solución 1: H2 In-Memory (Rápido - Para Demo)

**Pros:** Simple, funciona inmediatamente, 3+ réplicas  
**Contras:** No persistente, cada pod tiene su propia DB

### Paso 1: Limpiar deployment actual

```bash
kubectl delete namespace devsu-demo
```

### Paso 2: Actualizar manifiestos

Los archivos ya están actualizados:
- `configmap.yaml` → usa `jdbc:h2:mem:devsudb`
- `deployment.yaml` → sin volumeMounts

### Paso 3: Re-desplegar

```bash
cd k8s
./deploy-to-minikube.sh
```

### Paso 4: Verificar

```bash
kubectl get pods -n devsu-demo
# Todos deberían estar Running
```

**Nota:** Cada pod tiene su propia base de datos. Los datos se pierden al reiniciar.

---

## 🗄️ Solución 2: PostgreSQL (Recomendado - Producción)

**Pros:** Real, producción, persistente, múltiples réplicas  
**Contras:** Requiere actualizar `pom.xml` y rebuild

### Paso 1: Agregar dependencia PostgreSQL

Edita `pom.xml` y agrega:

```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

### Paso 2: Rebuild y push imagen

```bash
# Recompilar
mvn clean package

# Rebuild Docker
docker build -t tu-usuario/devsu-demo-app:latest .
docker push tu-usuario/devsu-demo-app:latest
```

### Paso 3: Desplegar PostgreSQL

```bash
cd k8s

# Limpiar deployment anterior
kubectl delete namespace devsu-demo

# Crear namespace
kubectl apply -f namespace.yaml

# Desplegar PostgreSQL primero
kubectl apply -f postgres.yaml

# Esperar a que esté listo
kubectl wait --for=condition=Ready pod -l app=postgres -n devsu-demo --timeout=2m
```

### Paso 4: Desplegar aplicación con PostgreSQL

```bash
# Aplicar ConfigMaps y Secrets de PostgreSQL
kubectl apply -f configmap-postgres.yaml
kubectl apply -f secret-postgres.yaml

# Desplegar app (sin PVC, usa deployment.yaml editado)
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml
kubectl apply -f ingress.yaml
```

### Paso 5: Verificar

```bash
# Verificar PostgreSQL
kubectl get pods -n devsu-demo -l app=postgres

# Verificar aplicación
kubectl get pods -n devsu-demo -l app=devsu-demo-app

# Ver logs
kubectl logs -f deployment/devsu-demo-app -n devsu-demo
```

### Paso 6: Conectar a PostgreSQL (opcional)

```bash
# Port-forward a PostgreSQL
kubectl port-forward -n devsu-demo svc/postgres 5432:5432

# Conectar con psql
psql -h localhost -U devsuuser -d devsudb
# Password: devsupass
```

---

## 🎯 Solución 3: 1 Réplica (Solo Demo)

**Pros:** Simple, H2 funciona  
**Contras:** NO cumple requisito de 2+ réplicas

### Paso 1: Usar deployment de 1 réplica

```bash
cd k8s

# Limpiar
kubectl delete namespace devsu-demo

# Aplicar todo con deployment de 1 réplica
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml  # Volver a H2 file
kubectl apply -f secret.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment-single-replica.yaml  # Este tiene 1 réplica
kubectl apply -f service.yaml
```

### Paso 2: Verificar

```bash
kubectl get pods -n devsu-demo
# Solo 1 pod, debe estar Running
```

**Nota:** Esto NO cumple con el requisito de "mínimo 2 réplicas".

---

## 🎯 Mi Recomendación

### Para Evaluación Técnica: **Solución 1 (H2 In-Memory)**

**Por qué:**
- ✅ Cumple requisito de 2+ réplicas (3 réplicas)
- ✅ Funciona inmediatamente
- ✅ Demuestra conocimiento de Kubernetes
- ✅ HPA funciona correctamente
- ✅ No requiere rebuild de la app
- ⚠️ Explicas limitación en documentación

**Implementación:**
```bash
cd k8s
kubectl delete namespace devsu-demo
./deploy-to-minikube.sh
# Ya está configurado para H2 in-memory
```

**En la documentación menciona:**
> "Para esta demo se usa H2 in-memory para permitir múltiples réplicas. En producción se recomendaría PostgreSQL/MySQL con un StatefulSet o servicio managed (RDS, Cloud SQL)."

---

### Para Producción Real: **Solución 2 (PostgreSQL)**

Demuestra arquitectura production-ready completa.

---

## 📋 Comandos de Verificación

### Para cualquier solución:

```bash
# Estado de pods
kubectl get pods -n devsu-demo -o wide

# Logs en tiempo real
kubectl logs -f deployment/devsu-demo-app -n devsu-demo

# Health check
kubectl port-forward -n devsu-demo svc/devsu-demo-app 8000:8000
curl http://localhost:8000/api/actuator/health

# HPA
kubectl get hpa -n devsu-demo -w

# Eventos
kubectl get events -n devsu-demo --sort-by='.lastTimestamp'
```

---

## 🐛 Troubleshooting

### Pods siguen crasheando después de cambiar a H2 in-memory

```bash
# 1. Verificar ConfigMap
kubectl get configmap devsu-app-config -n devsu-demo -o yaml | grep NAME_DB

# Debe mostrar: jdbc:h2:mem:devsudb

# 2. Reiniciar deployment para aplicar cambios
kubectl rollout restart deployment/devsu-demo-app -n devsu-demo

# 3. Ver logs
kubectl logs -f deployment/devsu-demo-app -n devsu-demo
```

### PostgreSQL no inicia

```bash
# Verificar PVC
kubectl get pvc -n devsu-demo | grep postgres

# Ver logs de postgres
kubectl logs -f deployment/postgres -n devsu-demo

# Verificar que tenga recursos
kubectl describe pod -l app=postgres -n devsu-demo
```

### App no conecta a PostgreSQL

```bash
# Verificar que PostgreSQL esté ready
kubectl get pods -n devsu-demo -l app=postgres

# Verificar ConfigMap
kubectl get configmap devsu-app-config-postgres -n devsu-demo -o yaml

# Verificar Secret
kubectl get secret devsu-app-secret-postgres -n devsu-demo -o yaml

# Test de conectividad
kubectl exec -it deployment/devsu-demo-app -n devsu-demo -- sh
# Dentro del pod:
nc -zv postgres 5432
```

---

## 📊 Arquitectura Final

### Con H2 In-Memory:
```
┌─────────────────────────────────────┐
│  Load Balancer (Service)            │
└─────────┬───────────────────────────┘
          │
    ┌─────┴─────┬─────────┐
    │           │         │
┌───▼───┐  ┌───▼───┐  ┌──▼────┐
│ Pod 1 │  │ Pod 2 │  │ Pod 3 │
│ H2:mem│  │ H2:mem│  │ H2:mem│
└───────┘  └───────┘  └───────┘
  DB 1       DB 2       DB 3
 (aisladas, no compartidas)
```

### Con PostgreSQL:
```
┌─────────────────────────────────────┐
│  Load Balancer (Service)            │
└─────────┬───────────────────────────┘
          │
    ┌─────┴─────┬─────────┐
    │           │         │
┌───▼───┐  ┌───▼───┐  ┌──▼────┐
│ Pod 1 │  │ Pod 2 │  │ Pod 3 │
└───┬───┘  └───┬───┘  └──┬────┘
    │          │         │
    └──────────┴─────────┘
               │
        ┌──────▼──────┐
        │ PostgreSQL  │
        │   Service   │
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │   PVC 5Gi   │
        └─────────────┘
```

---

## ✅ Resultado Esperado

Con **Solución 1 (H2 In-Memory)**:

```bash
$ kubectl get pods -n devsu-demo
NAME                            READY   STATUS    RESTARTS   AGE
devsu-demo-app-xxx-aaa         1/1     Running   0          2m
devsu-demo-app-xxx-bbb         1/1     Running   0          2m
devsu-demo-app-xxx-ccc         1/1     Running   0          2m

$ kubectl get hpa -n devsu-demo
NAME                 REFERENCE                   TARGETS   MINPODS   MAXPODS   REPLICAS
devsu-demo-app-hpa   Deployment/devsu-demo-app   15%/70%   2         10        3
```

✅ **3 pods Running**  
✅ **HPA configurado**  
✅ **Aplicación accesible**  

---

**Implementa la Solución 1 ahora mismo y en 5 minutos estará funcionando!** 🚀

```bash
cd k8s
kubectl delete namespace devsu-demo
./deploy-to-minikube.sh
```
