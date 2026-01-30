# ☸️ Kubernetes Manifests: The Declarative Way

> **Versión:** Kubernetes 1.25+
> **Formato:** YAML Declarativo
> **Filosofía:** Infrastructure as Code (IaC) - Immutable, Reproducible
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [Filosofía Declarativa](#filosofía-declarativa)
2. [Workloads: Deployment](#workloads-deployment)
3. [Networking: Service & Ingress](#networking-service--ingress)
4. [Configuración: ConfigMap & Secret](#configuración-configmap--secret)
5. [Storage Persistence](#storage-persistence)
6. [Health Checks & Probes](#health-checks--probes)
7. [Resource Management](#resource-management)
8. [Namespace Segregation](#namespace-segregation)

---

## Filosofía Declarativa

### ¿Por Qué Kubernetes?

```
Monolito (VM única)
  ↓
Docker (Contenedor, pero ¿quién lo orquesta?)
  ↓
Kubernetes (Orquestación automática de contenedores)

Kubernetes = Autopiloto para infraestructura
```

**Reglas Fundamentales:**
1. ❌ **NUNCA** despliegues Pods sueltos (mueren sin resurrección)
2. ✅ **SIEMPRE** usa Deployments (controla replicas, actualizaciones)
3. ✅ **SIEMPRE** define Health Checks (liveness + readiness)
4. ✅ **SIEMPRE** establece Resource Limits (evita OOM kills)

### Declarativo vs Imperativo

```yaml
# ❌ IMPERATIVO (antiguo, kubectl commands)
kubectl create deployment myapp --image=myapp:1.0
kubectl set resources deployment myapp --limits=cpu=500m,memory=512Mi
# Problemas: No versionado, difícil de reproducir, dificil de auditar

# ✅ DECLARATIVO (moderno, archivos YAML)
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  # ... rest of spec

kubectl apply -f deployment.yaml
# Ventaja: Versionado en Git, reproducible, auditable
```

---

## Workloads: Deployment

### Anatomía Completa

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: softarchitect-api
  namespace: production
  labels:
    app: api
    version: v1
spec:
  # Alta Disponibilidad
  replicas: 3  # Mínimo para producción

  # Selección de Pods
  selector:
    matchLabels:
      app: api

  # Estrategia de Update
  strategy:
    type: RollingUpdate  # Gradual, sin downtime
    rollingUpdate:
      maxUnavailable: 1  # Max 1 Pod caído durante update
      maxSurge: 1        # Max 1 Pod extra durante update

  # Template del Pod (la receta)
  template:
    metadata:
      labels:
        app: api
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"

    spec:
      # Control de seguridad
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000

      # Pull de imagen desde registry
      imagePullSecrets:
        - name: dockerhub-credentials

      # Contenedores
      containers:
        - name: api
          image: softarchitect-api:v1.0.0
          imagePullPolicy: IfNotPresent  # Usar caché local si existe

          # Puerto
          ports:
            - name: http
              containerPort: 8000
              protocol: TCP

          # Variables de entorno
          env:
            - name: APP_ENV
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: environment
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: db_password

          # ⚠️ CRÍTICO: Health Checks
          livenessProbe:
            # ¿Estás vivo? Si falla, reinicia el Pod.
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 15  # Esperar 15s antes de probar
            periodSeconds: 10        # Probar cada 10s
            timeoutSeconds: 5
            failureThreshold: 3      # 3 fallos = restart

          readinessProbe:
            # ¿Listo para tráfico? Si no, quita del Load Balancer.
            httpGet:
              path: /ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 2

          # ⚠️ CRÍTICO: Resource Limits
          resources:
            requests:
              # Lo que se garantiza
              memory: "256Mi"
              cpu: "250m"      # 0.25 CPU
            limits:
              # Máximo permitido (hard stop)
              memory: "512Mi"
              cpu: "500m"      # 0.5 CPU

          # Volúmenes (si aplica)
          volumeMounts:
            - name: logs
              mountPath: /var/log/app

      # Volúmenes
      volumes:
        - name: logs
          emptyDir: {}  # Temporal (muere con el Pod)

      # Afinidad (dónde correr los Pods)
      affinity:
        podAntiAffinity:
          # Preferir que los Pods NO estén en el mismo nodo
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values: [api]
                topologyKey: kubernetes.io/hostname

      # Tolerancias (qué taints aguanta)
      tolerations:
        - key: workload-type
          operator: Equal
          value: batch
          effect: NoSchedule
```

---

## Networking: Service & Ingress

### Service (Conectividad Interna)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
  namespace: production
spec:
  type: ClusterIP  # Solo accesible dentro del cluster

  selector:
    app: api  # Apunta a Pods con esta etiqueta

  ports:
    - name: http
      port: 80        # Puerto del Service
      targetPort: 8000  # Puerto del Pod
      protocol: TCP

  # Sesiones pegajosas (mismo cliente → mismo Pod)
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600
```

**Tipos de Service:**
- `ClusterIP`: Interno (default)
- `NodePort`: Expone en un puerto del nodo (no usar en producción)
- `LoadBalancer`: Crea LB en la nube ($$$ - uno por service)
- `ExternalName`: Alias DNS externo

### Ingress (Entrada Pública)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: main-ingress
  namespace: production
  annotations:
    # SSL automático (cert-manager + Let's Encrypt)
    cert-manager.io/cluster-issuer: "letsencrypt-prod"

    # Rate limiting
    nginx.ingress.kubernetes.io/limit-rps: "100"

    # Rewrite URLs
    nginx.ingress.kubernetes.io/rewrite-target: /

spec:
  # Clase de Ingress Controller
  ingressClassName: nginx  # O: aws-alb, traefik, etc

  # TLS
  tls:
    - hosts:
        - api.softarchitect.com
        - app.softarchitect.com
      secretName: tls-secret  # Generado por cert-manager

  # Reglas de enrutamiento
  rules:
    # API Backend
    - host: api.softarchitect.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 80

    # Frontend Web
    - host: app.softarchitect.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-service
                port:
                  number: 80

    # WebSocket (chat real-time)
    - host: ws.softarchitect.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: websocket-service
                port:
                  number: 8080
```

**¿Por qué Ingress y no LoadBalancer directo?**

```
1 Ingress + 1 LB = N servicios
vs
N LoadBalancers = N LBs ($$$)

Ahorro: 90%+ del costo de LB
```

---

## Configuración: ConfigMap & Secret

### ConfigMap (No-Sensitive)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: production
data:
  # Datos simples
  LOG_LEVEL: "info"
  DATABASE_HOST: "postgres.production.svc.cluster.local"
  CACHE_TTL: "3600"

  # Archivos completos
  nginx.conf: |
    server {
        listen 80;
        location / {
            proxy_pass http://backend:8000;
        }
    }
```

### Secret (Sensible)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: production
type: Opaque
data:
  # Base64 encoded (NOT encrypted by default!)
  db_password: cG9zdGdyZXNfcGFzc3dvcmQ=  # base64("postgres_password")
  api_key: YWJjZGVmMTIzNDU2Nzg5MA==      # base64("abcdef1234567890")

stringData:  # Si no quieres encodearlo tú
  slack_token: "xoxb-1234567890-abcdefghijk"
```

### Inyectar en Deployment

```yaml
containers:
  - name: api
    # Opción 1: Variables individuales
    env:
      - name: LOG_LEVEL
        valueFrom:
          configMapKeyRef:
            name: app-config
            key: LOG_LEVEL

    # Opción 2: Todas de un ConfigMap
    envFrom:
      - configMapRef:
          name: app-config
      - secretRef:
          name: app-secrets
```

**⚠️ Nota:** Secrets en K8s está codificado en Base64, NOT encriptado. Para encriptación:
- Usar **Sealed Secrets** (tercero)
- Usar **AWS Secrets Manager** / **Azure Key Vault**
- Usar **HashiCorp Vault**

---

## Storage Persistence

### Volumes Transitorios

```yaml
volumes:
  - name: temp-logs
    emptyDir: {}  # Muere con el Pod

  - name: shared-cache
    emptyDir:
      sizeLimit: 1Gi  # Límite de tamaño
```

### Persistent Volumes (Stateful)

```yaml
# 1. PersistentVolumeClaim (solicitud)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-storage
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast  # SSD
  resources:
    requests:
      storage: 20Gi

# 2. Usar en Deployment
volumeMounts:
  - name: db-data
    mountPath: /var/lib/postgresql/data

volumes:
  - name: db-data
    persistentVolumeClaim:
      claimName: db-storage
```

### StatefulSet (Para Bases de Datos)

```yaml
# Cuando el orden y la identidad importan
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    # ... pod spec ...
  volumeClaimTemplates:
    - metadata:
        name: db-data
      spec:
        accessModes: [ReadWriteOnce]
        resources:
          requests:
            storage: 50Gi
```

---

## Health Checks & Probes

### Liveness Probe (¿Vivo?)

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 15
  periodSeconds: 10
  failureThreshold: 3  # 3 fallos = RESTART

# Alternativas
exec:  # Ejecutar comando
  command: ["/bin/sh", "-c", "test -f /tmp/healthy"]

tcpSocket:  # Conectar a puerto
  port: 8000
```

### Readiness Probe (¿Listo para tráfico?)

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 2  # 2 fallos = REMOVE from LB

# ¿Diferencia?
# Liveness = ¿vives? (Si no, restart)
# Readiness = ¿puedes servir? (Si no, no envíes tráfico)
```

---

## Resource Management

### Requests vs Limits

```yaml
resources:
  requests:
    # GARANTIZADO: El scheduler asegura que estos recursos estén disponibles
    memory: "256Mi"
    cpu: "250m"

  limits:
    # MÁXIMO: Hard stop, nunca permitir más
    memory: "512Mi"
    cpu: "500m"

# ¿Qué pasa si excedes?
# - CPU: Throttled (ralentizado)
# - Memoria: OOM killed (terminado)
```

### Quality of Service (QoS)

```yaml
# 1. Guaranteed (requests = limits)
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "512Mi"
    cpu: "500m"

# 2. Burstable (requests < limits)
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"

# 3. BestEffort (sin requests/limits)
# Evitar en producción
```

---

## Namespace Segregation

```yaml
# 1. Crear Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: production

# 2. Usar en manifests
metadata:
  namespace: production

# 3. Resource Quotas (limitar por namespace)
apiVersion: v1
kind: ResourceQuota
metadata:
  name: production-quota
  namespace: production
spec:
  hard:
    requests.memory: "100Gi"
    requests.cpu: "50"
    limits.memory: "200Gi"
    limits.cpu: "100"
    pods: "1000"
```

---

## Resumen: K8s Mastery

✅ **Reglas Inmutables:**
1. Deployment para stateless
2. StatefulSet para stateful
3. Siempre probes (liveness + readiness)
4. Siempre limits (requests + limits)
5. Ingress para HTTP, Service para interno

✅ **Checklist de Seguridad:**
- [ ] runAsNonRoot: true
- [ ] readOnlyRootFilesystem: true (si aplica)
- [ ] No usar :latest (pinear versiones)
- [ ] Secrets en Vault, no en ConfigMap

Kubernetes es orquestación profesional. 🚢✨
