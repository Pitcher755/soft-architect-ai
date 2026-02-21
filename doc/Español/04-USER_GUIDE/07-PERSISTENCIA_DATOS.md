# 💾 Persistencia de Datos - SoftArchitect AI

> **Fecha:** 19/02/2026
> **Estado:** ✅ Guía de almacenamiento de datos
> **Tiempo de lectura:** 10 minutos

---

## 📖 Tabla de Contenidos

- [Dónde se Guardan tus Datos](#dónde-se-guardan-tus-datos)
- [Estructura de Archivos](#estructura-de-archivos)
- [Backup y Restauración](#backup-y-restauración)
- [Privacidad y Seguridad](#privacidad-y-seguridad)
- [Migración de Datos](#migración-de-datos)

---

## 📁 Dónde se Guardan tus Datos

**Principio fundamental:** Todo se guarda **localmente en tu computadora**. Nunca se envía a la nube (excepto si usas Groq Cloud para inferencia, pero solo el contexto de preguntas, NO tus datos).

### Mapa de Ubicaciones

```
soft-architect-ai/
├── data/                          ← TUS DATOS PRINCIPALES
│   ├── projects/                  ← Proyectos creados
│   │   ├── academic-blog/
│   │   │   ├── 00-governance/
│   │   │   ├── 01-architecture/
│   │   │   ├── 02-implementation/
│   │   │   └── 03-tracking/
│   │   └── ecommerce-mvp/
│   │
│   ├── chat_history/              ← Historial de conversaciones
│   │   ├── 2026-02-19.json
│   │   └── 2026-02-20.json
│   │
│   └── user_config/               ← Configuración personalizada
│       ├── preferences.json
│       └── tech_packs_custom.json
│
├── infrastructure/
│   └── chroma_data/               ← Base de datos vectorial (RAG)
│       ├── chroma.sqlite3
│       └── embeddings/
│
└── .env                           ← Secretos (API keys, etc.)
```

---

## 🏗️ Estructura de Archivos

### 1. Proyectos (`data/proyectos/`)

Cada proyecto tiene esta estructura:

```
data/projects/<nombre-proyecto>/
├── metadata.json                  ← Información del proyecto
├── 00-governance/
│   ├── PROBLEM_STATEMENT.md       ← Definición del problema
│   ├── STAKEHOLDERS.md            ← Stakeholders y requisitos
│   └── FUNCTIONAL_REQUIREMENTS.md ← Requisitos funcionales
│
├── 01-architecture/
│   ├── ADR-001-DATABASE.md        ← Decisiones de arquitectura
│   ├── C4_CONTEXT_DIAGRAM.md      ← Diagramas C4
│   ├── TECH_STACK.md              ← Stack tecnológico elegido
│   └── SYSTEM_DESIGN.md           ← Diseño de sistema
│
├── 02-implementation/
│   ├── USER_STORIES.md            ← Historias de usuario
│   ├── BACKLOG.md                 ← Backlog priorizado
│   └── TASKS.json                 ← Tareas técnicas
│
└── 03-tracking/
    ├── SPRINT_1.md                ← Sprints ejecutados
    ├── METRICS.json               ← Métricas de progreso
    └── RETROSPECTIVES.md          ← Retrospectivas
```

#### Ejemplo: `metadata.json`

```json
{
  "id": "academic-blog-2026-02-19",
  "name": "Academic Blog Platform",
  "created_at": "2026-02-19T10:30:00Z",
  "updated_at": "2026-02-20T15:45:00Z",
  "status": "active",
  "tech_stack": ["Python", "FastAPI", "PostgreSQL", "Flutter"],
  "team_size": 3,
  "target_launch_date": "2026-05-01"
}
```

---

### 2. Historial de Chat (`data/chat_history/`)

Las conversaciones se guardan como JSON por fecha.

#### Ejemplo: `2026-02-19.json`

```json
{
  "session_id": "sess_1234567890",
  "project_id": "academic-blog-2026-02-19",
  "date": "2026-02-19",
  "messages": [
    {
      "id": 1,
      "role": "user",
      "content": "Necesito diseñar una app de blog para universidades",
      "timestamp": "2026-02-19T10:30:15Z"
    },
    {
      "id": 2,
      "role": "assistant",
      "content": "Perfecto, comencemos definiendo los stakeholders...",
      "timestamp": "2026-02-19T10:30:20Z",
      "sources": [
        "packages/knowledge_base/01-TEMPLATES/PROBLEM_STATEMENT.md"
      ]
    }
  ],
  "total_messages": 42,
  "tokens_used": 8521
}
```

---

### 3. Configuración de Usuario (`data/user_config/`)

#### `preferences.json`

```json
{
  "theme": "dark",
  "language": "es",
  "streaming_enabled": true,
  "default_tech_stack": ["Python", "PostgreSQL"],
  "notifications": {
    "email": false,
    "desktop": true
  }
}
```

#### `tech_packs_custom.json`

```json
{
  "custom_packs": [
    {
      "name": "My Custom Stack",
      "path": "/home/user/custom_packs/my_stack.md",
      "enabled": true
    }
  ]
}
```

---

### 4. Base de Datos Vectorial (`infrastructure/chroma_data/`)

**Tecnología:** ChromaDB (SQLite + embeddings vectoriales)

**Qué contiene:**
- Embeddings de la Knowledge Base (Tech Packs, Templates)
- Índice de búsqueda semántica

**Tamaño típico:** 500MB - 2GB (depende de Tech Packs instalados)

**Backup:** Copiar carpeta completa `chroma_data/`

---

## 💾 Backup y Restauración

### Opción A: Backup Manual (Recomendado)

```bash
# 1. Crear carpeta de backup
mkdir -p ~/backups/soft-architect-ai/$(date +%Y%m%d)

# 2. Copiar datos
cp -r ./data ~/backups/soft-architect-ai/$(date +%Y%m%d)/
cp -r ./infrastructure/chroma_data ~/backups/soft-architect-ai/$(date +%Y%m%d)/
cp .env ~/backups/soft-architect-ai/$(date +%Y%m%d)/

# 3. Comprimir (opcional)
tar -czvf ~/backups/soft-architect-ai_$(date +%Y%m%d).tar.gz \
  -C ~/backups/soft-architect-ai/ $(date +%Y%m%d)
```

---

### Opción B: Backup Automatizado (Script)

**Crear script:** `scripts/backup.sh`

```bash
#!/bin/bash

BACKUP_DIR="$HOME/backups/soft-architect-ai"
DATE=$(date +%Y%m%d_%H%M%S)
SOURCE_DIR="$(pwd)"

# Crear directorio de backup
mkdir -p "$BACKUP_DIR"

# Backup
tar -czvf "$BACKUP_DIR/backup_$DATE.tar.gz" \
  --exclude='./node_modules' \
  --exclude='./venv' \
  --exclude='./build' \
  ./data \
  ./infrastructure/chroma_data \
  ./.env

echo "✅ Backup completo: $BACKUP_DIR/backup_$DATE.tar.gz"
```

**Ejecutar:**
```bash
chmod +x scripts/backup.sh
./scripts/backup.sh
```

---

### Restauración de Backup

```bash
# 1. Detener aplicación
docker-compose down  # Si usas Docker

# 2. Extraer backup
tar -xzvf ~/backups/soft-architect-ai_20260219.tar.gz -C ./

# 3. Verificar permisos
chmod -R 755 ./data
chmod -R 755 ./infrastructure/chroma_data

# 4. Reiniciar aplicación
docker-compose up -d
```

---

## 🔒 Privacidad y Seguridad

### Garantías de Privacidad

✅ **Data Sovereignty:** Todos tus datos están en tu máquina, bajo tu control físico.
✅ **Zero Telemetry:** No hay analytics, no hay tracking, no hay "phone home".
✅ **GDPR Compliant:** Cumple con legislación europea de protección de datos.
✅ **Offline-First:** Funciona sin conexión a internet (si usas Ollama Local).

---

### Datos Sensibles

**❌ NUNCA commitear estos archivos:**
```
.env                    ← API keys, secrets
data/                   ← Tus proyectos privados
infrastructure/chroma_data/ ← Base de datos
```

**Verificar `.gitignore`:**
```gitignore
# .gitignore
.env
.env.local
data/
infrastructure/chroma_data/
*.log
*.sqlite3
```

---

### Encriptación (Opcional)

**Para proyectos ultra-confidenciales:**

```bash
# Encriptar carpeta data con GPG
tar -czf - ./data | gpg --symmetric --cipher-algo AES256 > data_encrypted.tar.gz.gpg

# Desencriptar
gpg --decrypt data_encrypted.tar.gz.gpg | tar -xzf -
```

---

### Permisos de Archivos

**Linux/Mac:**
```bash
# Solo tu usuario puede leer/escribir
chmod 700 data/
chmod 700 infrastructure/chroma_data/
chmod 600 .env
```

**Windows:**
```powershell
# Configurar permisos NTFS
icacls "data" /inheritance:r /grant:r "%USERNAME%:(OI)(CI)F"
```

---

## 🔄 Migración de Datos

### Migrar entre Versiones

**Escenario:** Actualizaste de v0.1.0 a v0.2.0 y la estructura de datos cambió.

**Proceso:**

1. **Backup de datos antiguos** (ver sección anterior)

2. **Ejecutar script de migración:**
   ```bash
   python scripts/migrate_data.py --from 0.1.0 --to 0.2.0
   ```

3. **Verificar integridad:**
   ```bash
   python scripts/verify_data_integrity.py
   ```

---

### Exportar a Otros Formatos

#### A Notion

**Usar API de Notion:**
```bash
python scripts/export_to_notion.py \
  --project "academic-blog" \
  --notion-api-key "secret_xxxxx" \
  --notion-database-id "xxxxx"
```

#### A Confluence

**Usar API REST de Confluence:**
```bash
python scripts/export_to_confluence.py \
  --project "academic-blog" \
  --confluence-url "https://company.atlassian.net" \
  --token "xxxxx"
```

#### A PDF

**Exportar documentoación completa:**
```bash
# Requiere Pandoc
pandoc data/projects/academic-blog/**/*.md \
  -o academic-blog-docs.pdf \
  --toc \
  --pdf-engine=xelatex
```

---

## 📊 Gestión de Espacio en Disco

### Verificar Uso

```bash
# Tamaño total
du -sh data/
du -sh infrastructure/chroma_data/

# Por proyecto
du -sh data/projects/*/
```

### Limpiar Datos Antiguos

```bash
# Eliminar historial de chat > 30 días
find data/chat_history/ -type f -mtime +30 -delete

# Eliminar proyectos archivados
rm -rf data/projects/archived_*/

# Reindexar ChromaDB (libera espacio)
python scripts/reindex_chroma.py --optimize
```

---

## 🛠️ Troubleshooting

### ❌ "No puedo guardar archivos (Permission denied)"

**Solución:**
```bash
# Linux/Mac
sudo chown -R $USER:$USER data/
chmod -R 755 data/

# Windows: Run as Administrator
icacls "data" /reset /t
```

---

### ❌ "Mis proyectos desaparecieron"

**Causa común:** Carpeta `data/` movida o eliminada accidentalmente

**Solución:**
1. Verificar backup (ver sección Backup)
2. Restaurar desde backup más reciente
3. Si no hay backup, los datos se perdieron 😢

**Prevención:**
- Backup automático diario
- Usar Docker volumes (persistencia garantizada)

---

## 📚 Documentoos Relacionados

- [Instalación](02-INSTALLATION.md) - Configuración inicial
- [Solución de Problemas](08-SOLUCIÓN_DE_PROBLEMAS.md) - Errores comunes
- [Seguridad](../../context/SECURITY_HARDENING_POLICY.es.md) - Políticas de seguridad

---

<p align="center">
  <a href="08-SOLUCIÓN_DE_PROBLEMAS.md">Solución de Problemas →</a> |
  <a href="06-RESPUESTAS_STREAMING.md">← Streaming</a>
</p>
