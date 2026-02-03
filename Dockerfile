# Dockerfile multi-stage para aplicación Spring Boot
# Etapa 1: Build
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de Maven primero (para aprovechar cache de Docker)
COPY pom.xml .
COPY mvnw .
COPY mvnw.cmd .
COPY .mvn .mvn

# Descargar dependencias (esta capa se cachea si pom.xml no cambia)
RUN mvn dependency:go-offline -B

# Copiar código fuente
COPY src ./src

# Compilar la aplicación y ejecutar tests
RUN mvn clean package -DskipTests

# Etapa 2: Runtime
FROM eclipse-temurin:21-jre-alpine

# Metadata
LABEL maintainer="devsu-demo"
LABEL description="Devsu Demo DevOps Java Application"
LABEL version="1.0"

# Instalar curl para healthcheck y dumb-init para manejo correcto de señales
RUN apk add --no-cache curl dumb-init

# Variables de entorno con valores por defecto
ENV PORT=8000 \
    JAVA_OPTS="-Xmx512m -Xms256m" \
    SPRING_PROFILES_ACTIVE=prod \
    NAME_DB=jdbc:h2:file:/app/data/test \
    USERNAME_DB=user \
    PASSWORD_DB=password \
    APP_USER=appuser \
    APP_GROUP=appgroup \
    APP_HOME=/app

# Crear usuario y grupo no-root para ejecutar la aplicación
RUN addgroup -S ${APP_GROUP} && \
    adduser -S ${APP_USER} -G ${APP_GROUP} && \
    mkdir -p ${APP_HOME} ${APP_HOME}/data && \
    chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}

# Establecer directorio de trabajo
WORKDIR ${APP_HOME}

# Copiar el JAR desde la etapa de build
COPY --from=builder --chown=${APP_USER}:${APP_GROUP} /app/target/*.jar app.jar

# Cambiar al usuario no-root
USER ${APP_USER}

# Exponer puerto (configurable via env var)
EXPOSE 8000

# Healthcheck - usa actuator/health si está disponible, o swagger como fallback
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/api/actuator/health || curl -f http://localhost:8000/api/swagger-ui.html || exit 1

# Usar dumb-init para manejar señales correctamente
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Comando para ejecutar la aplicación
CMD ["sh", "-c", "java ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom -jar app.jar"]
