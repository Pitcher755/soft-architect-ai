# 📦 Azure Blob Storage Patterns

> **Estructura:** Account → Container → Blob
> **Protocolo:** HTTPS (REST API)
> **Durabilidad:** 99.999999999% (11 nueves)
> **Disponibilidad:** 99.99% (RA-GRS)
> **Filosofía:** "Almacenamiento masivo, barato y seguro"
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [Conceptos Fundamentales](#conceptos-fundamentales)
2. [Access Tiers](#access-tiers)
3. [Lifecycle Management](#lifecycle-management)
4. [Security Patterns](#security-patterns)
5. [Advanced Features](#advanced-features)
6. [Cost Optimization](#cost-optimization)

---

## Conceptos Fundamentales

### Estructura Jerárquica

```
Storage Account (Espacio global)
├── Container (Carpeta lógica, pública/privada)
│   ├── Blob (Objeto - archivo individual)
│   │   ├── Name (Path: documents/2026/report.pdf)
│   │   ├── Properties (Size, Created, Modified)
│   │   ├── Metadata (custom key-value)
│   │   ├── Tags (categorización)
│   │   ├── Access Tier (Hot, Cool, Archive)
│   │   └── Version ID (si versionado)
```

### Tipos de Blob

```
1. Block Blob (Defecto)
   - Para archivos estándar (fotos, documentos, logs)
   - Ideal para upload/download
   - Máximo: 4.75 TB

2. Page Blob (VHD - Virtual Hard Disk)
   - Para discos de VM
   - Optimizado para random I/O
   - No lo uses a menos que sea para VM

3. Append Blob
   - Solo append (agregar al final)
   - Ideal para logs, eventos continuos
   - Nunca actualizar o borrar líneas intermedias
```

---

## Access Tiers

### Cuatro Capas de Acceso

```
Decisión: ¿Cuándo fue la última vez que accediste a este archivo?

Hoy o ayer         → Hot      ($0.0192/GB/mes)
Última semana       → Cool     ($0.01/GB/mes)
Último mes          → Archive  ($0.00099/GB/mes, OFFLINE)
```

### 1. Hot Tier (Acceso Frecuente)

```yaml
AccessTier: Hot

# Características
- Almacenamiento: $0.0192/GB/mes
- Retrieval: Inmediato (ms)
- Lectura/Escritura: Frecuente, sin penalidad
- Caso de uso: Producción activa, assets dinámicos

# Ejemplo real:
# - Perfil de usuario subido hace 1 hora
# - Imagen de producto mostrada a clientes ahora
# - Logs diarios siendo escritos
```

### 2. Cool Tier (Acceso Ocasional)

```yaml
AccessTier: Cool

# Características
- Almacenamiento: $0.01/GB/mes (48% cheaper)
- Retrieval: Inmediato pero con mínimo de billable
- Mínimo billable: 30 días (si lo borras antes, pagas igual)
- Mínimo por blob: 128 KB
- Caso de uso: Backups semanales, archivos ocasionales

# Cálculo de ROI:
# Archivo de 1GB almacenado 90 días:
#   Hot:  $0.0192 × 3 meses = $0.0576
#   Cool: $0.01 × 3 meses = $0.03
#   Ahorro: 48%

# PERO Si lo necesitas después de 7 días y lo borras:
#   Pagas mínimo 30 días = $0.30 incluso así
#   → Solo usar si seguro que durará 30+ días
```

### 3. Archive Tier (Acceso Raro, OFFLINE)

```yaml
AccessTier: Archive

# Características
- Almacenamiento: $0.00099/GB/mes (94% cheaper que Hot)
- Retrieval: 12+ horas (Rehidratación, no instantáneo)
- Mínimo billable: 180 días
- Mínimo por blob: 128 KB
- Estado: Offline (no accesible hasta rehidratar)
- Caso de uso: Backup anual, archivos legales, disaster recovery

# Rehydration (traer de Archive):
# 1. Iniciar rehidratación: `Set-Tier` a Hot o Cool
# 2. Esperar: 12+ horas
# 3. Una vez online: Usar normalmente

# Cálculo ultra-agresivo:
# 1TB de data archive (nunca accedida, pero guardada por ley):
#   Hot:     $0.0192 × 12 meses = $230.4/año
#   Archive: $0.00099 × 12 meses = $11.88/año
#   Ahorro: 95%
```

### Cambiar Access Tier

```python
# Python: Cambiar tier de un blob
from azure.storage.blob import BlobServiceClient, BlobSasPermissions
from datetime import datetime, timedelta

service = BlobServiceClient.from_connection_string(connection_string)
container = service.get_container_client('my-container')
blob = container.get_blob_client('document.pdf')

# Cambiar a Cool
blob.set_blob_tier('Cool')

# Cambiar a Archive
blob.set_blob_tier('Archive')

# Rehydrate desde Archive
blob.set_blob_tier('Hot')  # Tarda ~12 horas
```

---

## Lifecycle Management

### Automatizar Transiciones

```yaml
# Configuración de ciclo de vida
LifecyclePolicy:
  Rules:
    - Name: archive-old-logs
      Type: Lifecycle

      # Aplicar a objetos con este prefijo
      Filters:
        BlobTypes:
          - blockBlob
        PrefixMatch:
          - logs/
        BlobIndexMatch:
          - Name: environment
            Value: production

      # Acciones
      Actions:
        BaseBlobActions:
          # Transición automática
          TierToHot:
            DaysAfterModificationGreaterThan: 0

          TierToCool:
            DaysAfterModificationGreaterThan: 30

          TierToArchive:
            DaysAfterModificationGreaterThan: 180

          # Borrar si es muy viejo
          Delete:
            DaysAfterModificationGreaterThan: 730  # 2 años

        # Para versiones anteriores (si versionado)
        VersionActions:
          Delete:
            DaysAfterCreationGreaterThan: 180
```

### Ejemplo Real: Sistema de Backups

```yaml
# Política para automatizar backups de base de datos

LifecyclePolicy:
  Rules:
    - Name: database-backups
      Enabled: true

      Filters:
        BlobIndexMatch:
          - Name: BackupType
            Value: Database

      Actions:
        BaseBlobActions:
          # Estructura de carpetas:
          # backups/2026-01-30/db.sql    (Hoy: Hot)
          # backups/2026-01-29/db.sql    (Ayer: Cool)
          # backups/2025-11-01/db.sql    (Hace 2 meses: Archive)

          TierToCool:
            DaysAfterModificationGreaterThan: 1

          TierToArchive:
            DaysAfterModificationGreaterThan: 30

          Delete:
            DaysAfterModificationGreaterThan: 365  # Retención legal
```

---

## Security Patterns

### 1. Acceso Privado (por defecto)

```yaml
# Container = Privado (por defecto)
ContainerProperties:
  PublicAccess: None  # Obligatorio en producción

# ❌ NUNCA hacer esto:
ContainerProperties:
  PublicAccess: Blob  # Expone TODO públicamente
  PublicAccess: Container  # Expone lista de blobs

# ✅ CORRECTO: Acceso controlado
```

### 2. Managed Identity (Recomendado para Backend)

```yaml
# Aplicación web obtiene credenciales automáticas de Azure

# 1. Habilitar Managed Identity en App Service
AppService:
  Identity:
    Type: SystemAssigned

# 2. Asignar rol de acceso
RoleAssignment:
  Principal: AppServiceIdentity
  Role: Storage Blob Data Contributor
  Scope: /subscriptions/.../storageAccounts/myaccount

# 3. Código (NO necesita secrets!)
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential

# Azure automáticamente usa la identidad del App Service
credential = DefaultAzureCredential()
blob_service = BlobServiceClient(
    account_url='https://myaccount.blob.core.windows.net',
    credential=credential
)
```

### 3. SAS Tokens (Shared Access Signature)

```python
# Para clientes frontend o externos
# URL temporal con permisos limitados

from azure.storage.blob import BlobServiceClient, generate_blob_sas, BlobSasPermissions
from datetime import datetime, timedelta

service = BlobServiceClient.from_connection_string(connection_string)

# Generar token para descargar por 1 hora
sas_token = generate_blob_sas(
    account_name='myaccount',
    container_name='uploads',
    blob_name='document.pdf',
    account_key=account_key,
    permission=BlobSasPermissions(read=True),
    expiry=datetime.utcnow() + timedelta(hours=1)
)

# URL con token
url_with_sas = f"https://myaccount.blob.core.windows.net/uploads/document.pdf?{sas_token}"

# Cliente puede descargar sin credenciales
# Automáticamente expira después de 1 hora
```

#### Tipos de Permisos SAS

```python
BlobSasPermissions(
    read=True,      # Descargar
    add=True,       # Agregar a blobs (append)
    create=True,    # Crear blobs nuevos
    write=True,     # Sobrescribir
    delete=True,    # Borrar
    list=True       # Listar contenidos
)
```

### 4. Encryption (Encriptación)

#### Server-Side Encryption (SSE)

```yaml
# Automático, siempre activado

Encryption:
  Services:
    Blob:
      Enabled: true
      KeyType: Microsoft.Storage  # Azure gestiona las claves

  # Alternativa: Customer-Managed Keys (CMK)
  KeyVaultProperties:
    KeyVaultUri: https://my-vault.vault.azure.net
    KeyVersion: ...
```

#### Client-Side Encryption

```python
# Encriptar localmente antes de subir
from cryptography.fernet import Fernet

# Generar clave (guardar segura)
key = Fernet.generate_key()
cipher = Fernet(key)

# Encriptar datos localmente
plaintext = b"Confidential data"
encrypted = cipher.encrypt(plaintext)

# Subir encriptado
blob_client.upload_blob(encrypted)

# Para descargar:
encrypted_blob = blob_client.download_blob().readall()
decrypted = cipher.decrypt(encrypted_blob)
```

### 5. Immutable Storage (WORM - Write Once, Read Many)

```yaml
# Política de almacenamiento inmutable
# Una vez escrito, NUNCA se puede modificar o borrar

ImmutabilityPolicy:
  ImmutabilityPeriodSinceCreationInDays: 2555  # 7 años
  State: Locked

# Casos de uso:
# - Logs de auditoría (compliance)
# - Documentos legales (retención mandatoria)
# - Registros médicos (HIPAA)
# - PII archivado

# Beneficio: Protección contra ransomware (no pueden borrar)
```

---

## Advanced Features

### 1. Blob Snapshots (Versionado)

```python
# Crear snapshot de un blob (copia readonly en ese momento)
blob_client = container_client.get_blob_client('document.pdf')
snapshot = blob_client.create_snapshot()

# Listar todos los snapshots
generator = container_client.list_blobs(include='snapshots')
for blob in generator:
    print(f"Snapshot: {blob.snapshot}")

# Restaurar a un snapshot anterior
snapshot_blob = container_client.get_blob_client(
    blob_name='document.pdf',
    snapshot=snapshot['snapshot']
)
# Ahora puedes leer la versión vieja
```

### 2. Blob Index Tags (Categorización)

```python
# Etiquetar blobs para queries posteriores
blob_client.set_blob_tags({
    'environment': 'production',
    'backup-type': 'database',
    'cost-center': 'engineering',
    'retention-days': '180'
})

# Luego buscar por tags (Blob Index Query)
# SELECT * WHERE "environment" = 'production' AND "retention-days" > 90
```

### 3. Soft Delete (Protección contra borrados)

```yaml
# Recuperar blobs borrados accidentalmente

BlobServiceProperties:
  DeleteRetentionPolicy:
    Enabled: true
    Days: 30  # Poder recuperar por 30 días

  ContainerDeleteRetentionPolicy:
    Enabled: true
    Days: 7
```

### 4. Change Feed (Auditoría de cambios)

```python
# Ver un registro de TODOS los cambios en blobs
# Útil para: Replicación, procesamiento, auditoría

from azure.storage.blob import BlobServiceClient

service = BlobServiceClient.from_connection_string(connection_string)

# Leer change feed
for event in service.get_container_client('mycontainer').get_blob_client().get_changefeed():
    print(f"Event: {event.event_type}")
    print(f"Blob: {event.blob_url}")
    print(f"Time: {event.event_time}")
```

---

## Cost Optimization

### Estrategia de Tiering Automático

```
Ejemplo real: Servicio de streaming de videos

Día 1:     Upload → Hot    ($0.0192/GB)
Días 2-30: Viewers bajan   → Cool ($0.01/GB)
Días 31+:  Archivado       → Archive ($0.00099/GB)

Costo anual de 100GB video:
  Todo Hot:     $0.0192 × 100 × 12 = $23/año
  Con Lifecycle: $2.30 × 100 = $230 para 10 años
  Ahorro: 90%
```

### Recomendaciones

```yaml
# Tier 1: Aplicaciones (No archive)
HotTier:
  Retention: 30-60 días
  Lifecycle:
    Cool: 30 días
    Delete: 90 días

# Tier 2: Backups (Include Archive)
BackupTier:
  Retention: 180+ días
  Lifecycle:
    Cool: 1 mes
    Archive: 6 meses
    Delete: 1 año (o retención legal)

# Tier 3: Compliance (WORM)
ComplianceTier:
  Retention: 7+ años
  Storage: Archive + Immutable Policy
  Lifecycle: None (manual retention)
```

---

## CLI Commands (Útiles)

```bash
# Crear storage account
az storage account create \
  --name mystorageaccount \
  --resource-group my-rg \
  --location eastus \
  --sku Standard_LRS

# Crear container
az storage container create \
  --account-name mystorageaccount \
  --name mycontainer

# Subir blob
az storage blob upload \
  --account-name mystorageaccount \
  --container-name mycontainer \
  --name myfile.txt \
  --file /path/to/local/file.txt

# Cambiar access tier
az storage blob set-tier \
  --account-name mystorageaccount \
  --container-name mycontainer \
  --name myfile.txt \
  --tier Archive

# Listar blobs
az storage blob list \
  --account-name mystorageaccount \
  --container-name mycontainer \
  --output table

# Generar SAS token
az storage blob generate-sas \
  --account-name mystorageaccount \
  --container-name mycontainer \
  --name myfile.txt \
  --permissions racwd \
  --expiry 2026-02-01
```

---

## Resumen: Blob Storage Mastery

✅ **Reglas Inmutables:**
- Nunca público (Private containers)
- Usar Managed Identity para apps internas
- Lifecycle + Tiers para ahorrar 90%
- Archive para retención legal
- Immutable + Soft Delete para compliance

✅ **Checklist de Seguridad:**
- [ ] Container = Private
- [ ] Managed Identity si backend
- [ ] SAS tokens si frontend
- [ ] Encryption enabled
- [ ] Versioning si importante
- [ ] Change feed auditado

✅ **Ahorros Típicos:**
- Lifecycle + Tiering: 80-95% reducción
- Archive vs Hot para backups: 94% cheaper
- Soft Delete + Snapshots: Zero cost, máxima protección

Azure Blob Storage es el corazón del data lake. 📦✨
