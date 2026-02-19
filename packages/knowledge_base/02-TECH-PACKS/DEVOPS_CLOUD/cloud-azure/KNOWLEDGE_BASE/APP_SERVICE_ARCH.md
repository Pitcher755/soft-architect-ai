# ☁️ Azure App Service Architecture

> **Servicio:** Azure Web Apps for Containers
> **Tipo:** PaaS (Platform as a Service)
> **Protocolo:** HTTP/HTTPS
> **Escalado:** Automático opcional
> **Status:** ✅ Establecido
> **Date:** 30/01/2026

---

## 📖 Table of Contents

1. [¿Por Qué App Service?](#por-qué-app-service)
2. [App Service Plans](#app-service-plans)
3. [Deployment Slots](#deployment-slots)
4. [Web App for Containers](#web-app-for-containers)
5. [Configuration & Networking](#configuration--networking)
6. [Monitoring & Debugging](#monitoring--debugging)

---

## ¿Por Qué App Service?

### Comparación: Lambda vs App Service vs Kubernetes

```
AWS Lambda
  ✅ Serverless puro
  ✅ Costo mínimo en idle
  ❌ Timeout 15 min
  ❌ Específico de AWS
  → APIs event-driven

Azure App Service
  ✅ Docker soportado nativamente
  ✅ No hay timeout
  ✅ Operación simplificada (vs K8s)
  ❌ Costo mínimo aunque idle
  → Apps web, APIs siempre-en

Kubernetes (K8s)
  ✅ Control total
  ✅ Multi-cloud
  ❌ Muy complejo
  ❌ DevOps intensivo
  → Aplicaciones empresariales
```

### El Valor de App Service

```
Si tienes una aplicación web "normal":
- FastAPI, Django, Express, ASP.NET Core
- Tráfico predecible
- No necesita control absoluto

Opción 1: Subir a EC2 (IaaS)
  - Provisionar VM
  - Instalar OS, runtime, dependencias
  - Configurar firewall, backups, patching
  - Monitorear uptime
  = Trabajo infinito

Opción 2: Usar App Service (PaaS)
  - `git push` → Deploy automático
  - SSL automático
  - Scaling automático
  - Backups automáticos
  = Trabajo mínimo

La diferencia: App Service abstractiza la infraestructura.
```

---

## App Service Plans

### ¿Qué es un Plan?

```
App Service Plan (ASP) = Máquina virtual compartida con otras apps.

Analogy:
  ASP Free/Shared = Departamento compartido (vecinos ruidosos afectan tu app)
  ASP Basic       = Apartamento privado en edificio (mejor aislamiento)
  ASP Standard    = Casa privada (mucho espacio, pricing premium)
```

### Tipos de SKU

```yaml
# Gratuito - Development only
Free:
  CPU: Compartida
  Memory: 1 GB compartida
  Instances: 1 (no escala)
  SLA: Ninguno (sin garantía)
  Costo: $0/mes
  Límites: 60 min/día de compute, 1GB storage
  → Demo, desarrollo local solamente

# Desarrollo
Shared:
  CPU: Compartida
  Memory: 1 GB compartida
  Instances: 1 (no escala)
  SLA: Ninguno
  Costo: $13/mes
  → Hobby projects, blogs

Basic (B1, B2, B3):
  CPU: Dedicada (parcial)
  Memory: 1.75 / 3.5 / 7 GB
  Instances: Escala manual (1-10)
  SLA: 99.95%
  Costo: $56-$225/mes por instancia
  SSL: Manual (Let's Encrypt integrado)
  → Producción pequeña/mediana

# Recomendado: Estándar o Premium
Standard (S1, S2, S3):
  CPU: Dedicada
  Memory: 1.75 / 3.5 / 7 GB
  Instances: Auto-scale (1-10+)
  SLA: 99.95%
  Costo: $87-$350/mes por instancia
  Features:
    ✅ Staging Slots (blue/green deploy)
    ✅ Traffic routing (% a staging)
    ✅ Auto-scale
    ✅ SSL automático (Azure-managed)
  → Aplicaciones profesionales

Premium (P1v3, P2v3, P3v3):
  CPU: Dedicada full
  Memory: 2 / 4 / 8 GB
  Instances: Auto-scale
  SLA: 99.95%
  Costo: $167-$629/mes por instancia
  Features:
    ✅ Todo de Standard
    ✅ VNet integration (IP privada)
    ✅ Backup/restore
    ✅ Priority para scaling
  → Apps mission-critical
```

### Scaling Configuration

```yaml
# Manual (dentro de plan)
AppServiceScaleConfiguration:
  MinInstances: 1
  MaxInstances: 5

# Auto Scaling (automático basado en métricas)
AutoScaleSettings:
  Name: cpu-scaling
  Enabled: true
  Rules:
    - MetricName: CpuPercentage
      Threshold: 70
      Operator: GreaterThan
      Cooldown: 300
      ScaleIncrement: 1
      AggregationType: Average

    - MetricName: CpuPercentage
      Threshold: 30
      Operator: LessThan
      Cooldown: 300
      ScaleIncrement: -1  # Escala hacia abajo
```

---

## Deployment Slots

### Blue/Green Deployments (Zero Downtime)

```
Sin Slots (Tradicional - con downtime):
  1. Usuario accede a https://myapp.azurewebsites.net
  2. Comienza deployment → App se cae
  3. Deployment termina → App vuelve arriba
  = Usuario ve error

Con Slots (Moderno - sin downtime):
  1. Usuario accede a https://myapp.azurewebsites.net (Production)
  2. Despliegas versión nueva en Staging
  3. Validas que funciona
  4. Haces "Swap" → Production ← Staging (intercambio de IPs)
     = Usuario sigue usando misma URL, pero ahora es la versión nueva
  5. Si falla, haces Swap-back inmediato
  = Cero downtime, rollback instantáneo
```

### Configuration de Slots

```yaml
# App Service con 2 slots
AppService:
  Name: my-app-prod
  Plan:
    Tier: Standard  # Mínimo para slots

  Slots:
    # Slot 1: Production (default)
    Production:
      Name: production
      TrafficPercent: 100

    # Slot 2: Staging (para validar deploy)
    Staging:
      Name: staging
      TrafficPercent: 0  # Sin tráfico hasta validar

    # Slot 3: Canary (opcional - 10% tráfico)
    Canary:
      Name: canary
      TrafficPercent: 10  # Solo 10% de usuarios
```

### Workflow de Deployment

```python
# 1. Desplegar a Staging
az webapp deployment source config-zip \
  --resource-group my-rg \
  --name my-app-prod \
  --slot staging \
  --src-path app.zip

# 2. Testear (checks automáticos)
# En CI/CD: Hit /health endpoint, run smoke tests

# 3. Si todo OK → Swap
az webapp deployment slot swap \
  --resource-group my-rg \
  --name my-app-prod \
  --slot staging

# 4. Si falla → Rollback instant
az webapp deployment slot swap \
  --resource-group my-rg \
  --name my-app-prod \
  --slot staging  # Swap back
```

### Slot-Sticky Settings

```yaml
# Configurar qué settings NO se copian en el swap
# (mantienen su valor en cada slot)

ConnectionStrings:
  DbConnection:
    Value: 'Server=staging-db.database.windows.net;...'
    Type: SqlServer
    Sticky: true  # Este valor NO cambia en swap

AppSettings:
  ENVIRONMENT:
    Value: 'staging'
    Sticky: true

  API_KEY:
    Value: 'secret-staging-only'
    Sticky: true
```

---

## Web App for Containers

### Desplegando Docker en App Service

#### Opción 1: Azure Container Registry (ACR)

```yaml
# 1. Crear container registry
az acr create \
  --resource-group my-rg \
  --name mycontainerregistry \
  --sku Basic

# 2. Buildear y pushear imagen
az acr build \
  --registry mycontainerregistry \
  --image my-app:latest .

# 3. Crear Web App for Containers
az appservice plan create \
  --resource-group my-rg \
  --name my-plan \
  --sku S1 \
  --is-linux

az webapp create \
  --resource-group my-rg \
  --plan my-plan \
  --name my-app \
  --deployment-container-image-name-user mycontainerregistry \
  --deployment-container-image-name my-app:latest \
  --registry-username <username> \
  --registry-password <password>
```

#### Opción 2: Docker Hub

```yaml
# Más simple pero menos seguro
az webapp create \
  --resource-group my-rg \
  --plan my-plan \
  --name my-app \
  --deployment-container-image-name-user username \
  --deployment-container-image-name myapp:latest
```

### Dockerfile Optimizado para App Service

```dockerfile
# Usar imagen slim (más pequeña)
FROM python:3.12-slim

# Puerto (CRÍTICO: Comunicar a App Service)
EXPOSE 8000

# Workdir
WORKDIR /app

# Dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Código
COPY . .

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Comunicar el Puerto a App Service

```yaml
# Azure NECESITA saber qué puerto expone el contenedor

AppServiceConfig:
  AppSettings:
    - Name: WEBSITES_PORT
      Value: "8000"  # Coincide con EXPOSE en Dockerfile

    - Name: WEBSITE_ROLE_INSTANCE_ID
      Value: "0"

    - Name: WEBSITE_INSTANCE_ID
      Value: "0"
```

### Ver Logs del Contenedor

```bash
# Log Stream en tiempo real (como docker logs)
az webapp log tail \
  --name my-app \
  --resource-group my-rg

# Salida:
# 2026-01-30 15:23:45.123  INFO  Uvicorn server started
# 2026-01-30 15:24:10.456  INFO  GET /api/users HTTP/200

# Guardar logs a Storage (persistencia)
az webapp config appsettings set \
  --resource-group my-rg \
  --name my-app \
  --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=true
```

---

## Configuration & Networking

### Environment Variables & Secrets

```yaml
# App Settings (variables de entorno)
AppSettings:
  DATABASE_URL:
    Value: 'postgresql://user:pass@host/db'
    # Accesible como: os.environ['DATABASE_URL']

  DEBUG:
    Value: 'false'

  # Azure KeyVault Reference (seguro)
  API_SECRET:
    Value: '@Microsoft.KeyVault(SecretUri=https://my-vault.vault.azure.net/secrets/api-secret/)'
```

### Connection Strings (especiales)

```yaml
# App Service encripta estas automáticamente
ConnectionStrings:
  DefaultConnection:
    Value: 'Server=my-server.database.windows.net;Database=mydb;User Id=admin;Password=...'
    Type: SqlServer

  RedisConnection:
    Value: 'my-redis.redis.cache.windows.net:6379,ssl=True,password=...'
    Type: Custom
```

### VNet Integration (Networking Privada)

```yaml
# Solo disponible en Premium SKU
# Permite que App Service acceda a recursos privados (DB, VMs)

VnetConfiguration:
  SubnetId: /subscriptions/sub/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/app-subnet

# Ahora la app puede acceder a:
# - Bases de datos en subnet privada
# - APIs internas
# - Cache privado
# - Todo sin exponerse a internet
```

---

## Monitoring & Debugging

### Application Insights (APM)

```yaml
# Integración automática con Azure Monitor
AppSettings:
  APPINSIGHTS_INSTRUMENTATION_KEY: '...'
  APPINSIGHTS_PROFILER_ENABLED: 'true'
  ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
```

### Métricas Importantes

```bash
# Ver métricas en portal
az monitor metrics list \
  --resource my-app-resource \
  --metric "Http5xx" \
  --dimension "InstanceId"

# Métricas clave:
# - Http2xx, Http4xx, Http5xx (códigos de respuesta)
# - ResponseTime (latencia)
# - MemoryUsage (memoria consumida)
# - CpuPercentage (CPU)
# - ActiveConnections (usuarios activos)
```

### Alerts

```yaml
# Alertar si tasa de error > 5%
Alert:
  Name: high-error-rate
  Condition:
    MetricName: Http5xx
    Threshold: 5
    Operator: GreaterThan
    AggregationType: Average
    WindowSize: 5m
  Action:
    Type: Email
    Emails:
      - devops@company.com
    Type: Webhook
    ServiceUri: https://hooks.slack.com/...
```

### Remote Debugging

```bash
# Conectar debugger remoto (VS Code, Visual Studio)
az webapp create-remote-connection \
  --resource-group my-rg \
  --name my-app

# El output te dice dónde conectarte en el debugger local
# Luego puedes:
# - Poner breakpoints
# - Inspeccionar variables
# - Paso a paso en producción (cuidado!)
```

---

## Comparación: App Service vs Otras Opciones

```
┌──────────────────────┬──────────────┬──────────────┬──────────────┐
│ Criterio             │ App Service  │ AKS (K8s)    │ Container    │
│                      │              │              │ Instances    │
├──────────────────────┼──────────────┼──────────────┼──────────────┤
│ Complejidad          │ Baja         │ Muy Alta     │ Media        │
│ Costo (pequeño)      │ $87/mes      │ $500+/mes    │ $50-100      │
│ Costo (escala)       │ Lineal       │ No lineal    │ Predecible   │
│ Deploy               │ Git push     │ kubectl      │ Webhook      │
│ Timeout              │ Ilimitado    │ Ilimitado    │ Ilimitado    │
│ Scaling              │ Auto         │ Auto         │ Manual       │
│ Slots (Blue/Green)   │ ✅ Nativo    │ ⚠️ Manual    │ ❌           │
│ Operación            │ Mínima       │ Alta         │ Media        │
│ Multi-cloud          │ ❌ Azure     │ ✅ Sí        │ ✅ Sí        │
│ Mejor para           │ Apps web     │ Enterprise   │ Batch jobs   │
│                      │ normales     │ complejas    │              │
└──────────────────────┴──────────────┴──────────────┴──────────────┘
```

---

## Resumen: App Service Mastery

✅ **Reglas Inmutables:**
- Use Standard o Premium (no Free/Shared)
- Slots para deployment sin downtime
- VNet Integration para networking privado
- Application Insights desde día 1
- Auto-scale basado en CPU/Memory

✅ **Checklist de Deployments:**
- [ ] Dockerfile optimizado (slim image, health check)
- [ ] WEBSITES_PORT configurado
- [ ] Staging slot validado antes de swap
- [ ] Traffic % configurado si canary
- [ ] Alerts en 5xx errors
- [ ] Logs guardados en Storage

✅ **Ahorros:**
- App Service vs AKS: 5-10x más barato para apps normales
- Slots automáticos vs downtime manual: Riesgo cero

Azure App Service es PaaS hecha bien. ☁️✨
