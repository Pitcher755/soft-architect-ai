# 🪣 AWS S3 Storage Patterns

> **Servicio:** Simple Storage Service (S3)
> **Durabilidad:** 99.999999999% (11 nueves)
> **Disponibilidad:** 99.99%
> **Filosofía:** "Tiering automático para ahorrar 90% en storage"
> **Status:** ✅ Establecido
> **Date:** 30/01/2026

---

## 📖 Table of Contents

1. [Conceptos Fundamentales](#conceptos-fundamentales)
2. [Storage Classes](#storage-classes)
3. [Lifecycle Policies](#lifecycle-policies)
4. [Security Best Practices](#security-best-practices)
5. [Cost Optimization](#cost-optimization)
6. [Advanced Patterns](#advanced-patterns)

---

## Conceptos Fundamentales

### Estructura de S3

```
S3 (Global service)
├── Bucket (Región específica)
│   ├── Object (archivo + metadata)
│   │   ├── Key (path: /folder/document.pdf)
│   │   ├── Content-Type
│   │   ├── Tags
│   │   ├── Metadata (custom)
│   │   └── Version ID (si versionado)
```

### Naming Rules

```python
# ✅ VÁLIDO
- my-bucket-2026
- bucket.example.com
- 123-bucket

# ❌ INVÁLIDO
- My-Bucket (mayúsculas)
- bucket_ (underscore)
- -bucket (guion al inicio)
- bucket.example (conflicto con DNS)
```

### Acceso a Objetos

```
S3 es simple: Todo es HTTP.

Directa (NO RECOMENDADO en producción):
  https://my-bucket.s3.us-east-1.amazonaws.com/photo.jpg
  (Inseguro, expone el bucket directamente)

Via CloudFront (CDN - RECOMENDADO):
  https://d123abc.cloudfront.net/photo.jpg
  (Cachea, comprime, distribuye globalmente)

Via Presigned URL (Cliente único):
  https://my-bucket.s3.us-east-1.amazonaws.com/doc.pdf?X-Amz-Signature=...
  (Temporal, con permisos limitados)
```

---

## Storage Classes

### Cuando Cambiar de Tier

```
Tabla de Decisión:

Acceso FRECUENTE (diario)        → S3 Standard ($0.023/GB/mes)
Acceso OCASIONAL (mensual)       → S3 Standard-IA ($0.0125/GB/mes)
Acceso RARO (trimestral)         → S3 Glacier Instant ($0.004/GB/mes)
Acceso MUY RARO (anual)          → S3 Glacier Flexible ($0.0036/GB/mes)
Archivo LEGAL/COMPLIANCE (años)  → S3 Glacier Deep Archive ($0.00099/GB/mes)
```

### 1. S3 Standard (Hot)

```yaml
StorageClass: STANDARD

# Features
- Acceso inmediato
- Replicado en ≥3 AZs automáticamente
- Throughput: Ilimitado
- Costo: Más alto, pero sin retrieval fees

# Caso de Uso
- Aplicación web activa
- Logs diarios
- Assets dinámicos (imágenes de perfil de usuarios activos)
```

### 2. S3 Standard-IA (Infrequent Access)

```yaml
StorageClass: STANDARD_IA

# Features
- Almacenamiento 40% más barato que Standard
- PERO: Retrieval fee = $0.01 por GB descargado
- Mínimo de 30 días de almacenamiento
- Mínimo de 128KB por objeto (archivos pequeños no aplican)

# Caso de Uso
- Backups mensuales
- Logs de auditoría (descarga rara)
- Documentos archivados (acceso ocasional)

# Cálculo de ROI
Si un objeto está almacenado 90 días y se descarga 1 vez:
  Costo Standard (90 días):    $0.023 × 3 meses × GB = $0.069
  Costo IA (90 días + retrieval): ($0.0125 × 3 + $0.01) × GB = $0.0475
  Ahorro: ~30%
```

### 3. S3 Glacier Instant Retrieval

```yaml
StorageClass: GLACIER_IR

# Features
- Almacenamiento 80% más barato
- Retrieval tarda: milisegundos (instant)
- Mínimo: 30 días
- Mínimo: 128KB

# Caso de Uso
- Respaldos trimestrales
- Archivos que necesitan acceso urgente pero raro
- Datos de sensores históricos
```

### 4. S3 Glacier Flexible Retrieval

```yaml
StorageClass: GLACIER

# Features
- Almacenamiento 95% más barato ($0.0036/GB/mes)
- Retrieval tardío:
  * Standard: 3-5 horas
  * Bulk: 5-12 horas (más barato)
  * Expedited: 1-5 min ($0.03 por GB)
- Mínimo: 90 días

# Caso de Uso
- Archivo anual (auditoría, compliance)
- Backup de backup (última línea de defensa)
- Datos científicos históricos
```

### 5. S3 Glacier Deep Archive

```yaml
StorageClass: DEEP_ARCHIVE

# Features
- Almacenamiento 99% más barato ($0.00099/GB/mes)
- Retrieval tardío:
  * Standard: 12 horas
  * Bulk: 48 horas
- Mínimo: 180 días
- Mejor durabilidad (más copias)

# Caso de Uso
- Archivo legal (7+ años)
- Backup de cumplimiento normativo (HIPAA, PCI)
- Raramente accedido pero crítico si se necesita

# Ejemplo Real
1TB de datos archivo anual:
  Standard:        $23 × 12 = $276/año
  Deep Archive:    $1 × 12 = $12/año
  Ahorro:          95%
```

---

## Lifecycle Policies

### Automatizar Transiciones

```yaml
# Configurar movimiento automático de objetos
# (No tienes que hacerlo manualmente)

LifecycleConfiguration:
  Rules:
    - Id: auto-archive-cold-data
      Status: Enabled

      # Aplicar a objetos con este prefijo
      Prefix: logs/
      Filter:
        Tags:
          Environment: production

      # Transición automática
      Transitions:
        - Days: 30
          StorageClass: STANDARD_IA

        - Days: 90
          StorageClass: GLACIER

        - Days: 180
          StorageClass: DEEP_ARCHIVE

      # Expiración (borrar)
      Expiration:
        Days: 365  # Borrar después de 1 año

      # Para versiones no-actuales (si versioning está ON)
      NoncurrentVersionTransitions:
        - NoncurrentDays: 30
          StorageClass: STANDARD_IA

      NoncurrentVersionExpiration:
        NoncurrentDays: 90
```

### Ejemplo Real: Sistema de Logs

```yaml
# Simular base de datos de logs sin base de datos

# Estructura:
# s3://logs-bucket/2026-01-30/app/api.log
# s3://logs-bucket/2026-01-29/app/api.log
# s3://logs-bucket/2026-01-15/app/api.log
# ...

LifecycleConfiguration:
  Rules:
    - Id: logs-tiering
      Status: Enabled
      Filter:
        Prefix: 'app/'

      Transitions:
        # Hoy: Standard (hot)
        # 7 días: Acceso frecuente (debuggear)

        - Days: 7
          StorageClass: STANDARD_IA
        # Después de 7 días: Acceso raro (business intelligence)

        - Days: 30
          StorageClass: GLACIER
        # Después de 30 días: Archivo (compliance)

        - Days: 90
          StorageClass: DEEP_ARCHIVE
        # Después de 90 días: Guardar para siempre

      Expiration:
        Days: 1825  # 5 años de retención legal
```

---

## Security Best Practices

### 1. Block Public Access (OBLIGATORIO)

```yaml
# Nivel Bucket
BucketPublicAccessBlockConfiguration:
  BlockPublicAcls: true
  BlockPublicPolicy: true
  IgnorePublicAcls: true
  RestrictPublicBuckets: true

# Nivel Cuenta (aplicar a TODOS los buckets automáticamente)
AccountPublicAccessBlockConfiguration:
  BlockPublicAcls: true
  BlockPublicPolicy: true
  IgnorePublicAcls: true
  RestrictPublicBuckets: true
```

**¿Por qué?**
```
Si un bucket está público, cualquiera puede:
- Listar todos los objetos
- Descargarlos
- Subir malware
- Generar facturas enormes de egreso

Regla de Oro: S3 NUNCA debe estar público directamente.
Alternativa: CloudFront (CDN) con Bucket Policy restringida.
```

### 2. Encryption (Encriptación)

#### Server-Side Encryption (SSE)

```yaml
# Opción 1: SSE-S3 (AWS gestiona las claves)
BucketEncryption:
  Rules:
    - ApplyServerSideEncryptionByDefault:
        SSEAlgorithm: AES256  # ← Default, gratis

# Opción 2: SSE-KMS (Control con AWS KMS)
BucketEncryption:
  Rules:
    - ApplyServerSideEncryptionByDefault:
        SSEAlgorithm: aws:kms
        KMSMasterKeyID: arn:aws:kms:us-east-1:ACCOUNT:key/...
      BucketKeyEnabled: true  # Reduce costos KMS
```

#### Client-Side Encryption (Cliente encripta antes de enviar)

```python
# Python: Usar S3 client-side encryption
import boto3
from cryptography.fernet import Fernet

# Generar clave
key = Fernet.generate_key()

s3 = boto3.client('s3')

# Encriptar localmente
cipher = Fernet(key)
encrypted_data = cipher.encrypt(b'Datos sensibles')

# Subir encriptado
s3.put_object(
    Bucket='my-bucket',
    Key='sensitive/file.enc',
    Body=encrypted_data,
    Metadata={'encryption': 'client-side-fernet'}
)
```

### 3. Versioning (Protección contra borrados)

```yaml
VersioningConfiguration:
  Status: Enabled

# Beneficios
# - Recuperación ante borrados accidentales
# - Auditoría (quién cambió qué y cuándo)
# - Protección contra ransomware (versiones históricas intactas)

# Combinado con Lifecycle:
NoncurrentVersionExpiration:
  NoncurrentDays: 90
# (Mantener últimas 90 días de versiones antiguas)
```

### 4. Logging (Auditoría)

```yaml
# Registrar TODOS los accesos a un bucket
LoggingConfiguration:
  DestinationBucketName: logs-bucket
  LogFilePrefix: s3-access-logs/

# Cada acceso genera un objeto:
# s3://logs-bucket/s3-access-logs/2026-01-30-12-34-56-ABC123...

# Estructura del log
# Requester, Bucket, Key, RequestDateTime, Status, ErrorCode, BytesSent, ObjectSize, ...
```

### 5. Políticas de Acceso (IAM + Bucket Policy)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnencryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::my-bucket/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    },
    {
      "Sid": "AllowCloudFrontOnly",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Principal User ID"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

---

## Cost Optimization

### Estrategias Reales

#### 1. Intelligent-Tiering

```yaml
# AWS lo hace automáticamente por ti
StorageClass: INTELLIGENT_TIERING

# Monitorea acceso automáticamente
# - No acceso 30 días → STANDARD_IA
# - No acceso 90 días → GLACIER
# - Acceso nuevamente → Vuelve a STANDARD

# Costo: $0.0125/GB/mes (un poco más que STANDARD)
# Valor: Zero management, optimización automática
```

#### 2. Eliminar Versiones Obsoletas

```python
# Script para limpiar versiones viejas
import boto3

s3 = boto3.client('s3')

paginator = s3.get_paginator('list_object_versions')

for page in paginator.paginate(Bucket='my-bucket'):
    for version in page.get('Versions', []):
        if version['IsLatest'] == False:
            # Borrar versión no-actual
            s3.delete_object(
                Bucket='my-bucket',
                Key=version['Key'],
                VersionId=version['VersionId']
            )

    for marker in page.get('DeleteMarkers', []):
        s3.delete_object(
            Bucket='my-bucket',
            Key=marker['Key'],
            VersionId=marker['VersionId']
        )
```

#### 3. Multipart Upload para Archivos Grandes

```python
# Subir archivo de 5GB en paralelo
import boto3
from concurrent.futures import ThreadPoolExecutor

s3 = boto3.client('s3')

# Iniciar upload de múltiples partes
response = s3.create_multipart_upload(
    Bucket='my-bucket',
    Key='large-file.zip'
)
upload_id = response['UploadId']

# Subir partes en paralelo (mucho más rápido)
parts = []

def upload_part(part_number, data):
    response = s3.upload_part(
        Bucket='my-bucket',
        Key='large-file.zip',
        PartNumber=part_number,
        UploadId=upload_id,
        Body=data
    )
    return {
        'ETag': response['ETag'],
        'PartNumber': part_number
    }

with ThreadPoolExecutor(max_workers=8) as executor:
    futures = [
        executor.submit(upload_part, i, chunk)
        for i, chunk in enumerate(chunks, 1)
    ]
    parts = [f.result() for f in futures]

# Completar upload
s3.complete_multipart_upload(
    Bucket='my-bucket',
    Key='large-file.zip',
    UploadId=upload_id,
    MultipartUpload={'Parts': parts}
)
```

---

## Advanced Patterns

### 1. Presigned URLs (Acceso Temporal)

```python
import boto3
from datetime import timedelta

s3 = boto3.client('s3')

# Generar URL temporal (válida 15 minutos)
url = s3.generate_presigned_url(
    'get_object',
    Params={
        'Bucket': 'my-bucket',
        'Key': 'documents/contract.pdf'
    },
    ExpiresIn=900  # 15 minutos
)

# Resultado:
# https://my-bucket.s3.us-east-1.amazonaws.com/documents/contract.pdf?X-Amz-Signature=...&X-Amz-Expires=900

# Cliente puede descargar sin credenciales
# Automáticamente expira después de 900s
```

### 2. Cross-Region Replication (CRR)

```yaml
# Replicar automáticamente a otra región
# (para DR, latencia baja, conformidad)

ReplicationConfiguration:
  Role: arn:aws:iam::ACCOUNT:role/s3-replication
  Rules:
    - Id: replicate-all
      Status: Enabled
      Priority: 1
      Filter:
        Prefix: ''  # Replicar todo
      Destination:
        Bucket: arn:aws:s3:::my-bucket-replica-us-west-2
        ReplicationTime:
          Status: Enabled
          Time:
            Minutes: 15  # Replicar dentro de 15 min
        Metrics:
          Status: Enabled
```

### 3. S3 Event Notifications (Trigger Lambda)

```yaml
# Cuando subes un archivo → Ejecutar Lambda automáticamente

NotificationConfiguration:
  LambdaFunctionConfigurations:
    - Event: s3:ObjectCreated:*
      Filter:
        Key:
          FilterRules:
            - Name: prefix
              Value: uploads/
            - Name: suffix
              Value: .jpg
      LambdaFunctionArn: arn:aws:lambda:us-east-1:ACCOUNT:function:resize-image

# Uso real:
# Usuario sube image.jpg → S3 trigger → Lambda resize-image
# Lambda redimensiona, comprime, guarda thumbnail
# Todo automático en segundos
```

---

## Resumen: S3 Mastery

✅ **Reglas Inmutables:**
- Nunca público (BLOCK PUBLIC ACCESS activado)
- Versioning + Lifecycle = Backup + Ahorro
- CloudFront para servir assets (no S3 directo)
- Presigned URLs para acceso temporal
- CRR para DR

✅ **Checklist de Security:**
- [ ] Block Public Access: true
- [ ] Encryption: SSE-KMS
- [ ] Versioning: Enabled
- [ ] Logging: Configured
- [ ] Lifecycle: Policies en place
- [ ] MFA Delete: true (para buckets críticos)

✅ **Ahorros Típicos:**
- Lifecycle + Tiering: 80% reducción en storage
- Intelligent-Tiering: Zero management
- Presigned URLs: Mejor que ampliar IAM

AWS S3 es el corazón del data lake. 🪣✨
