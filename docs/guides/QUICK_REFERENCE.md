# 📝 Quick Reference Card - CI/CD Setup

## 🚀 Setup Rápido en 10 Pasos

### 1️⃣ Preparar Proyecto
```bash
cd ~/test_devsu_devops/devsu-demo-devops-java
```

### 2️⃣ Crear Estructura GitHub Actions
```bash
mkdir -p .github/workflows
# Copiar archivos:
# - ci-cd.yml
# - pr-checks.yml
# - dependabot.yml
```

### 3️⃣ Actualizar pom.xml
```xml
<!-- Agregar propiedades de SonarCloud -->
<sonar.projectKey>mgutama_devsu-demo-devops-java</sonar.projectKey>
<sonar.organization>mgutama-github</sonar.organization>
```

### 4️⃣ Crear Repositorio GitHub
```bash
git init
git add .
git commit -m "feat: initial commit with CI/CD"
git remote add origin https://marcogutama/test_devsu_devops.git
git push -u origin main
```

### 5️⃣ Configurar SonarCloud
1. Ir a https://sonarcloud.io
2. Sign up with GitHub
3. Import project
4. Copiar token

### 6️⃣ Configurar Docker Hub
1. Ir a https://hub.docker.com
2. Create Access Token
3. Copiar token

### 7️⃣ Agregar Secrets en GitHub
```
Settings → Secrets → Actions → New secret

SONAR_TOKEN
SONAR_PROJECT_KEY
SONAR_ORGANIZATION
DOCKER_USERNAME
DOCKER_PASSWORD
```

### 8️⃣ Push Workflows
```bash
git add .github/
git commit -m "ci: add GitHub Actions pipeline"
git push
```

### 9️⃣ Verificar Pipeline
```
GitHub → Actions tab
Verifica que se ejecute automáticamente
```

### 🔟 Actualizar README
```bash
# Agregar badges con tus URLs
git add README.md
git commit -m "docs: add CI/CD badges"
git push
```

---

## 🔑 Secrets Requeridos

| Secret | Dónde Obtener | Enlace |
|--------|---------------|--------|
| `SONAR_TOKEN` | SonarCloud → Account → Security | https://sonarcloud.io/account/security |
| `SONAR_PROJECT_KEY` | SonarCloud → Project Settings | Formato: `user_repo` |
| `SONAR_ORGANIZATION` | SonarCloud → Organization | Tu username |
| `DOCKER_USERNAME` | Docker Hub | Tu mgutama |
| `DOCKER_PASSWORD` | Docker Hub → Security | https://hub.docker.com/settings/security |
| `CODECOV_TOKEN` | Codecov → Settings (Opcional) | https://codecov.io |

---

## 📋 Checklist de Verificación

### ✅ Antes de Push
- [ ] pom.xml tiene Actuator y JaCoCo
- [ ] application.properties tiene actuator habilitado
- [ ] Workflows están en .github/workflows/
- [ ] .dockerignore y Dockerfile están presentes
- [ ] Tests pasan localmente: `mvn test`

### ✅ Después de Push
- [ ] Pipeline se ejecuta en GitHub Actions
- [ ] Build & Test job pasa
- [ ] Coverage job genera reporte
- [ ] SonarCloud analiza el código
- [ ] Docker build completa (solo en main)

### ✅ Configuración Externa
- [ ] Proyecto existe en SonarCloud
- [ ] Tokens están en GitHub Secrets
- [ ] Repositorio existe en Docker Hub
- [ ] Badges funcionan en README

---

## 🎯 URLs Importantes

### Tu Proyecto
```
GitHub: https://marcogutama/test_devsu_devops
Actions: https://marcogutama/test_devsu_devops/actions
Settings: https://marcogutama/test_devsu_devops/settings
```

### SonarCloud
```
Dashboard: https://sonarcloud.io/dashboard?id=marcogutama_test_devsu_devops
Projects: https://sonarcloud.io/projects
Settings: https://sonarcloud.io/project/settings?id=marcogutama_test_devsu_devops
```

### Docker Hub
```
Repository: https://hub.docker.com/r/mgutama/devsu-demo-app
Tags: https://hub.docker.com/r/mgutama/devsu-demo-app/tags
Settings: https://hub.docker.com/repository/docker/mgutama/devsu-demo-app/settings
```

---

## 🛠️ Comandos Útiles

### Testing Local
```bash
# Compilar
mvn clean compile

# Tests
mvn test

# Coverage
mvn test jacoco:report
open target/site/jacoco/index.html

# SonarCloud local (requiere token)
mvn sonar:sonar -Dsonar.token=TU_TOKEN

# Package
mvn clean package
```

### Docker Local
```bash
# Build
docker build -t devsu-demo-app:local .

# Run
docker run -p 8000:8000 devsu-demo-app:local

# Compose
docker-compose up -d
docker-compose logs -f
docker-compose down
```

### Git Workflow
```bash
# Crear feature branch
git checkout -b feature/nueva-funcionalidad

# Commit
git add .
git commit -m "feat: descripción"

# Push y crear PR
git push origin feature/nueva-funcionalidad
```

---

## 🐛 Troubleshooting Rápido

### Pipeline No Se Ejecuta
```bash
# Verificar workflows
ls -la .github/workflows/

# Verificar YAML válido
cat .github/workflows/ci-cd.yml | grep -i "on:"

# Push forzado
git push --force-with-lease
```

### SonarCloud Falla
```bash
# Verificar secrets
GitHub → Settings → Secrets → Actions

# Verificar project key
cat pom.xml | grep sonar.projectKey

# Test local
mvn sonar:sonar -Dsonar.token=TU_TOKEN
```

### Docker Build Falla
```bash
# Test local
docker build -t test .

# Verificar secrets
# DOCKER_USERNAME y DOCKER_PASSWORD en GitHub

# Verificar login
docker login -u TU_mgutama
```

### Tests Fallan
```bash
# Ejecutar localmente
mvn clean test

# Ver detalles
mvn test -X

# Ver reporte
cat target/surefire-reports/*.txt
```

---

## 📊 Badges para README

```markdown
[![CI/CD](https://github.com/USER/REPO/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/USER/REPO/actions/workflows/ci-cd.yml)

[![Quality Gate](https://sonarcloud.io/api/project_badges/measure?project=PROJECT_KEY&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=PROJECT_KEY)

[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=PROJECT_KEY&metric=coverage)](https://sonarcloud.io/summary/new_code?id=PROJECT_KEY)

[![Docker](https://img.shields.io/docker/v/USER/devsu-demo-app?label=docker)](https://hub.docker.com/r/USER/devsu-demo-app)
```

---

## 🔄 Flujo de Trabajo Diario

### Desarrollar Feature
```bash
1. git checkout -b feature/mi-feature
2. # Hacer cambios
3. mvn test  # Verificar tests
4. git commit -m "feat: nueva funcionalidad"
5. git push origin feature/mi-feature
6. Crear PR en GitHub
7. Esperar checks del pipeline
8. Merge cuando todo pase
```

### Hotfix en Producción
```bash
1. git checkout -b hotfix/fix-critico
2. # Hacer fix
3. mvn test
4. git commit -m "fix: corrección crítica"
5. git push origin hotfix/fix-critico
6. PR urgente con revisión
7. Merge a main
8. Deploy automático
```

---

## 💡 Tips Profesionales

1. **Siempre ejecuta tests localmente** antes de push
2. **Usa conventional commits** (feat:, fix:, docs:, etc.)
3. **Revisa SonarCloud** después de cada merge
4. **Monitorea Docker Hub** para ver imágenes
5. **Descarga artifacts** si un job falla
6. **Usa branch protection** en main
7. **Habilita Dependabot** para updates automáticos
8. **Revisa logs** en GitHub Actions si algo falla

---

## 📞 Enlaces de Ayuda

- [GitHub Actions Docs](https://docs.github.com/actions)
- [SonarCloud Docs](https://docs.sonarcloud.io)
- [Docker Hub Docs](https://docs.docker.com/docker-hub/)
- [JaCoCo Plugin](https://www.jacoco.org/jacoco/trunk/doc/maven.html)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)

---

## ⚡ Comandos de Emergencia

### Rollback Docker
```bash
# Volver a versión anterior
docker pull mgutama/devsu-demo-app:previous-tag
docker-compose down
docker-compose up -d
```

### Forzar Re-run del Pipeline
```bash
# En GitHub Actions UI: Re-run all jobs
# O hacer un empty commit
git commit --allow-empty -m "chore: trigger pipeline"
git push
```

### Limpiar Cache
```bash
# GitHub: Settings → Actions → Caches → Delete
# Local:
mvn clean
docker system prune -a
```

---

**Fecha de creación:** Febrero 2026  
**Última actualización:** Febrero 2026  
**Versión:** 1.0

---

✨ **¡Pipeline CI/CD listo para producción!** ✨
