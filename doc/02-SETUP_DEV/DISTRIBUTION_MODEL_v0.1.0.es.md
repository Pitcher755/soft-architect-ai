# 📦 Modelo de Distribución: Del Desarrollo a Producción

**Fecha**: 2 de febrero de 2026
**Audiencia**: Arquitectos, DevOps, Product Managers
**Status**: Definición de v0.1.0

---

## 🎯 Pregunta Central

> "¿Cómo se generan los datos (chroma_data/), se generan cuando el usuario final instale? ¿Cómo se compila todo para que sea transparente al usuario?"

---

## 📊 Comparativa: Desarrollo vs Producción

### **Modelo Actual (Desarrollo)**

```
┌─────────────────────────────────────────────────────┐
│ Desarrollador ejecuta (manualmente):                │
├─────────────────────────────────────────────────────┤
│ 1. git clone soft-architect-ai                      │
│ 2. cd infrastructure && docker compose up -d        │
│ 3. cd ../src/server                                 │
│ 4. poetry run python scripts/ingest.py              │
│ 5. poetry run pytest tests/                         │
│ 6. curl localhost:8000/api/v1/chat/message          │
└─────────────────────────────────────────────────────┘

Resultado: ✅ Desarrollador tiene control total
           ❌ Usuario final se pierde en paso 1
```

### **Modelo Ideal (Producción - v0.1.0)**

```
┌──────────────────────────────────────────────────────┐
│ Usuario Final ejecuta (automático):                 │
├──────────────────────────────────────────────────────┤
│ 1. Descarga instalador (softarchitect-ai-0.1.0.msi)│
│ 2. Ejecuta instalador ("Siguiente, Siguiente...")   │
│ 3. El instalador:                                   │
│    ├─ Descomprime archivos a ~/.softarchitect/      │
│    ├─ Ejecuta setup_on_first_run.py                 │
│    ├─ Genera chroma_data/ automáticamente           │
│    ├─ Crea acceso directo en Escritorio            │
│    └─ Abre la app                                   │
│ 4. Usuario ve: Chat limpio, listo para usar        │
│ 5. Usuario escribe: "¿Qué es Clean Architecture?"  │
│ 6. Sistema responde: "Basándose en la KB..."       │
└──────────────────────────────────────────────────────┘

Resultado: ✅ Usuario solo descarga y hace clic
           ✅ chroma_data/ se genera automáticamente
           ✅ No necesita saber de Docker, Python, o Terminal
```

---

## 🏗️ Arquitectura de Distribución

### **Componentes del Instalador**

```
softarchitect-ai-0.1.0-setup.msi (200-300 MB)
│
├─ [Runtime]
│  ├─ Python 3.12 embedded
│  ├─ Flutter engine compiled
│  └─ Ollama runtime (opcional, o descargable)
│
├─ [Application Code]
│  ├─ src/server/compiled (FASTApi pre-compilado con PyInstaller)
│  ├─ src/client/compiled (Flutter binary)
│  └─ scripts/ingest.py (para setup)
│
├─ [Knowledge Base (Fuente)]
│  ├─ packages/knowledge_base/  (archivos .md originales)
│  └─ ~2MB comprimido
│
├─ [Setup Scripts]
│  ├─ setup_on_first_run.py    (genera chroma_data)
│  ├─ installer.nsi             (WinInstaller script)
│  └─ uninstall.sh
│
└─ [Configuration]
   ├─ .env.production           (vars precargadas)
   └─ first_run_marker.txt      (para detectar primer inicio)
```

---

## 🔄 Flujo de Ejecución en Producción

### **Fase 1: Instalación (Una sola vez)**

```
Usuario ejecuta: softarchitect-ai-0.1.0-setup.msi
│
├─ Muestra UI: "SoftArchitect AI v0.1.0 Setup"
│  "Select Installation Folder" (default: C:\Program Files\SoftArchitect AI)
│
├─ Copia archivos a:
│  C:\Program Files\SoftArchitect AI\
│  └─ bin/
│  └─ lib/
│  └─ assets/
│  └─ scripts/
│
├─ Crea folders de datos en:
│  %APPDATA%\SoftArchitect AI\  (C:\Users\User\AppData\Roaming\SoftArchitect AI\)
│  └─ Carpeta vacía (chroma_data se generará después)
│
├─ Crea acceso directo:
│  C:\Users\User\Desktop\SoftArchitect AI.lnk
│  └─ Apunta a: C:\Program Files\SoftArchitect AI\bin\app.exe
│
└─ Instalador termina y muestra:
   "✅ Installation complete. Click 'Finish' to launch app."
```

### **Fase 2: Primer Inicio (Automático)**

```
Usuario hace clic en: Desktop shortcut "SoftArchitect AI"
│
├─ Ejecuta: app.exe
│  (wrapper que iniciaque FastAPI + Flutter en background)
│
├─ app.exe detecta: ~/.softarchitect/chroma_data NO EXISTE
│  └─ Flag: first_run = True
│
├─ Muestra: Splash screen "Inicializando SoftArchitect AI..."
│  (con barra de progreso)
│
├─ app.exe ejecuta AUTOMÁTICAMENTE:
│  $ python scripts/ingest.py
│    └─ Lee: packages/knowledge_base/*.md
│    └─ Crea embeddings localmente (con Ollama offline)
│    └─ Almacena en: ~/.softarchitect/chroma_data/
│    └─ Tarda: 30-60 segundos (según KB size)
│
├─ SQLite se inicializa:
│  ~/.softarchitect/softarchitect.db
│  └─ Tablas: conversations, messages, settings, etc.
│
├─ FastAPI inicia en background:
│  localhost:8000 (solo accesible localmente)
│
├─ Flutter UI se conecta a FastAPI
│  y muestra: "Bienvenido a SoftArchitect AI"
│  └─ Onboarding screen (si primer inicio)
│
└─ Splash desaparece, usuario ve chat limpio
   Listo para usar
```

### **Fase 3: Uso Normal (cada vez que abre)**

```
Usuario abre: SoftArchitect AI (desde Desktop shortcut)
│
├─ app.exe inicia
│  └─ Detecta: ~/.softarchitect/chroma_data EXISTS
│     └─ first_run = False (skip initialization)
│
├─ Carga ChromaDB desde disco (~100ms):
│  $ chroma_client.get_collection("documents")
│
├─ FastAPI + Flutter inician normalmente
│
├─ Usuario escribe: "¿Qué es SOLID?"
│
├─ FastAPI:
│  1. Valida input con Pydantic
│  2. Busca en ChromaDB: vector_store.query("¿Qué es SOLID?")
│  3. Recupera documentos relevantes
│  4. Pasa contexto a Ollama LLM local
│  5. LLM genera respuesta (streaming)
│  6. Devuelve al cliente via SSE
│
├─ Flutter:
│  1. Recibe stream de tokens
│  2. Renderiza tokens en tiempo real
│  3. Usuario ve respuesta aparecer palabra por palabra
│
└─ Usuario satisfecho ✅
   Cierra app cuando termina
   Datos guardan en ~/.softarchitect/
```

---

## 💾 Gestión de Datos (chroma_data/)

### **¿Dónde se almacenan?**

```
DESARROLLO (para Git):
├─ infrastructure/chroma_data/  ← .gitignore ✅
│  ├─ Se regenera ejecutando: python scripts/ingest.py
│  ├─ Nunca se commitea
│  └─ Se borra con: rm -rf infrastructure/chroma_data/

PRODUCCIÓN (para Usuario):
├─ ~/.softarchitect/chroma_data/  ← Datos persistentes
│  ├─ Se generan: en primer inicio
│  ├─ Se actualizan: si usuario ejecuta "Actualizar KB"
│  ├─ Se respaldan: automáticamente en ~/.softarchitect/backups/
│  └─ Se pueden borrar: app se reinicializa
```

### **¿Cuánto espacio ocupa?**

```
chroma_data/ composition:
├─ chroma.sqlite3 (~1.4 MB)      ← Metadata de colecciones
├─ índices HNSW (~6-8 MB)        ← Vectores + índices
└─ parquets binarios (~0.5 MB)   ← Cache de embeddings

TOTAL: ~9 MB por Knowledge Base
       (escalable a 100+ MB con KBs más grandes)

En producto final:
├─ Instalador: 200-300 MB (incluye runtime)
├─ Instalado en disco: ~500 MB (extraído)
├─ chroma_data generado: ~10 MB adicionales
└─ TOTAL en user machine: ~510 MB
```

### **¿Es regenerable?**

```
SÍ, 100% regenerable:

┌─────────────────────────────────────────────┐
│ Usuario abre Settings → Maintenance         │
├─────────────────────────────────────────────┤
│ Opción: "Regenerate Knowledge Base"         │
│  └─ Borra ~/.softarchitect/chroma_data/     │
│  └─ Re-ejecuta ingest.py                    │
│  └─ Tarda ~60 segundos                      │
│                                             │
│ O desde línea de comandos:                  │
│ $ softarchitect --reset-kb                  │
└─────────────────────────────────────────────┘

Esto es importante para:
- Troubleshooting
- Testing
- Actualizaciones de KB
```

---

## 🔒 Datos Persistentes vs Generados

### **Matriz de Decisión**

| Elemento | ¿Versionar? | ¿Por qué? | Ubicación |
|----------|------------|----------|-----------|
| `src/server/scripts/ingest.py` | ✅ SÍ | Es código fuente, instrucciones | `repo/src/server/scripts/` |
| `packages/knowledge_base/*.md` | ✅ SÍ | Es contenido fuente | `repo/packages/knowledge_base/` |
| `infrastructure/chroma_data/` | ❌ NO | Son artefactos generados | `.gitignore` |
| `~/.softarchitect/chroma_data/` (user) | ❌ NO | Usuario-específicos, persistentes localmente | No synced |
| `src/server/pyproject.toml` | ✅ SÍ | Define dependencies | `repo/src/server/` |
| `src/server/venv/` | ❌ NO | Virtual env generado | `.gitignore` |
| `src/server/__pycache__/` | ❌ NO | Bytecode generado | `.gitignore` |

---

## 🚀 Flujo de Build & Release

### **Para cada Release (v0.1.0 → v0.1.1 → v0.2.0)**

```
Commit → Git Tag → CI/CD Pipeline → Release
│        │         │                │
│        │         └─ Run tests     └─ Upload installers
│        └─ v0.1.0  └─ Build apps      to GitHub Releases
└─ "feat: add chat history"

Detalle del Build Pipeline:

1. GitHub Actions triggered on tag push
   │
   ├─ For Linux:
   │  ├─ flutter build linux --release
   │  ├─ PyInstaller src/server/main.py
   │  ├─ fpm --deb (create .deb)
   │  └─ Upload to Release
   │
   ├─ For Windows:
   │  ├─ flutter build windows --release
   │  ├─ PyInstaller src/server/main.py
   │  ├─ NSIS installer (create .msi)
   │  └─ Code sign (.pfx certificate)
   │  └─ Upload to Release
   │
   └─ For macOS:
      ├─ flutter build macos --release
      ├─ PyInstaller src/server/main.py
      ├─ create .dmg (drag & drop installer)
      ├─ Code sign (Apple Developer ID)
      └─ Notarize (Apple requirement)
      └─ Upload to Release

2. User downloads .msi (Windows example)
   │
   ├─ Verifies signature
   ├─ Shows installer UI
   ├─ Copies files to Program Files
   ├─ Creates shortcuts
   ├─ Sets environment variables
   └─ Launches app on first run → auto-setup

3. First run generates chroma_data/
   └─ User doesn't know or care
```

---

## ⚡ Fase 2: Primer Inicio (First-Run Automation)

### Visión General
En el primer inicio, la aplicación ejecuta automáticamente 6 pasos sin que el usuario intervenga:
1. **Verificar Ollama** (0-10% progress)
2. **Descargar Qwen2.5:3b** (10-30%)
3. **Generar embeddings** (30-85%)
4. **Inicializar SQLite** (85-92%)
5. **Health check** (92-98%)
6. **Mostrar onboarding** (98-100%)

### Paso 0: Splash Screen
```
╔═════════════════════════════════════════════╗
║   SoftArchitect AI - Inicializando...       ║
║                                             ║
║   [████░░░░░░░░░░░░░░░░░░░░░░░░] 15%     ║
║                                             ║
║   Descargando dependencias (1/6)...         ║
╚═════════════════════════════════════════════╝
```

- Se muestra apenas abre la app
- Barra de progreso actualiza en tiempo real
- No permite interacción (bloquea UI)

### Paso 1: Verificar Ollama (0-10%)

```python
# Lógica: services/rag/ollama_init.py

def verify_ollama():
    # Detectar si Ollama ya está descargado
    ollama_path = pathlib.Path.home() / ".softarchitect" / "ollama"
    
    if not ollama_path.exists():
        print("Descargando Ollama (390 MB)...")
        # Detectar OS y arquitectura
        # Descargar desde https://ollama.ai/download
        # Extraer a ~/.softarchitect/ollama/
        # [Progress: 0% → 10%]
    
    # Detectar CUDA si está instalado -nvidia
    if is_gpu_variant():
        has_cuda = detect_cuda_toolkit()
        if has_cuda:
            os.environ["OLLAMA_CUDA"] = "1"
            print("✓ CUDA detected, GPU acceleration enabled")
        else:
            # Fallback a CPU - esperado
            print("⚠ GPU mode selected but CUDA not detected. Using CPU.")
            update_ollama_config(gpu_enabled=False)
    
    # Iniciar servicio Ollama en background
    # Bind a 127.0.0.1:11434 (localhost only, no network)
    start_ollama_service()
    
    return 10  # Progress porcentaje
```

**Timing:**
- Si Ollama ya existe: <1 segundo
- Si necesita descargar: 30-45 segundos (depending on internet)

### Paso 2: Descargar Qwen2.5:3b (10-30%)

```python
def pull_model():
    # Verificar si modelo ya descargado
    models_dir = pathlib.Path.home() / ".softarchitect" / "models"
    model_file = models_dir / "qwen2.5-3b.gguf"
    
    if not model_file.exists():
        print("Descargando Qwen2.5:3b (2.0 GB)...")
        # Usa ollama CLI internamente
        subprocess.run([
            "ollama", "pull", "qwen2.5:3b"
        ], timeout=600)
        # [Progress: 10% → 30%]
    else:
        print("✓ Qwen2.5:3b already present")
    
    return 30
```

**Timing:**
- Si modelo existe: <1 segundo
- Si necesita descargar: 60-120 segundos (fiber: 60s, standard: 120s)

**Validación:**
- `ollama list` confirma modelo presente
- Size: ~2 GB en disk

### Paso 3: Generar Embeddings (30-85%)

```python
def generate_embeddings():
    print("Generando embeddings para knowledge base...")
    # Ejecuta: python scripts/ingest.py
    
    # Lógica:
    # 1. Lee todos los .md de packages/knowledge_base/
    # 2. Crea embeddings usando el modelo descargado
    # 3. Almacena en ~/.softarchitect/chroma_data/
    # 4. Construye HNSW index para búsqueda rápida
    
    # Si -nvidia: utiliza CUDA (30-60 segundos)
    # Si -cpu: CPU-only (60-120 segundos)
    
    ingest_result = subprocess.run([
        sys.executable, "scripts/ingest.py",
        "--chroma-dir", str(chroma_dir),
        "--batch-size", "32" if gpu_enabled else "8"
    ], timeout=180)
    
    if ingest_result.returncode != 0:
        raise Exception("Embedding generation failed")
    
    # [Progress: 30% → 85%]
    return 85
```

**Timing:**
- GPU (Nvidia 3050+): 30-60 segundos
- CPU (Quad-core): 60-120 segundos

**Output:**
- `~/.softarchitect/chroma_data/` (≈9 MB)
- HNSW index + SQLite metadata

### Paso 4: Inicializar SQLite (85-92%)

```python
def init_database():
    print("Inicializando base de datos...")
    
    db_path = pathlib.Path.home() / ".softarchitect" / "softarchitect.db"
    
    # Crear schema si no existe
    with sqlite3.connect(db_path) as conn:
        conn.executescript("""
            CREATE TABLE IF NOT EXISTS conversations (
                id TEXT PRIMARY KEY,
                created_at TIMESTAMP,
                title TEXT,
                model TEXT DEFAULT 'qwen2.5:3b'
            );
            
            CREATE TABLE IF NOT EXISTS messages (
                id TEXT PRIMARY KEY,
                conversation_id TEXT,
                role TEXT,
                content TEXT,
                timestamp TIMESTAMP,
                FOREIGN KEY(conversation_id) REFERENCES conversations(id)
            );
            
            CREATE TABLE IF NOT EXISTS settings (
                key TEXT PRIMARY KEY,
                value TEXT
            );
            
            INSERT OR IGNORE INTO settings (key, value) 
            VALUES ('gpu_enabled', ?), ('language', 'es')
        """, (str(gpu_enabled),))
    
    # [Progress: 85% → 92%]
    return 92
```

**Timing:** <2 segundos

### Paso 5: Health Check (92-98%)

```python
def health_check():
    print("Verificando conectividad...")
    
    # 1. FastAPI backend está running?
    try:
        response = requests.get("http://localhost:8000/health", timeout=5)
        if response.status_code != 200:
            raise Exception("Backend not responding")
        print("✓ Backend healthy")
    except Exception as e:
        raise Exception(f"Backend health check failed: {e}")
    
    # 2. Ollama disponible?
    try:
        response = requests.get("http://localhost:11434/api/tags", timeout=5)
        models = response.json().get("models", [])
        if not any("qwen" in m.get("name", "") for m in models):
            raise Exception("Qwen model not available")
        print("✓ Ollama + Qwen2.5:3b ready")
    except Exception as e:
        raise Exception(f"Ollama check failed: {e}")
    
    # 3. ChromaDB accesible?
    try:
        from services.rag.chromadb_client import ChromaClient
        client = ChromaClient()
        stats = client.get_collection_stats()
        print(f"✓ ChromaDB ready ({stats['doc_count']} embeddings)")
    except Exception as e:
        raise Exception(f"ChromaDB check failed: {e}")
    
    # [Progress: 92% → 98%]
    return 98
```

**Timing:** 3-5 segundos

### Paso 6: Mostrar Onboarding (98-100%)

```python
def show_onboarding():
    print("Completado! Bienvenido...")
    
    # Ocultar splash screen
    # Mostrar Flutter UI con 3-4 pantallas:
    
    # Screen 1: "Welcome to SoftArchitect AI"
    # - Explicar qué es
    # - Mostrar key features
    # - "Comenzar chat" button
    
    # Screen 2: "Tu primer prompt"
    # - Ejemplo: "¿Qué es arquitectura limpia?"
    # - Pre-loaded en chat input
    # - Presionar Enter para enviar
    
    # Screen 3: "Ajustes rápidos" (opcional)
    # - Tema: Dark/Light
    # - Lenguaje: ES/EN
    # - "Continuar" button
    
    # Screen 4: "Chat UI"
    # - Empty conversation ready
    # - Cursor en input
    # - Aguardando primer prompt
    
    # [Progress: 98% → 100%]
    # Splash desaparece
    # Chat UI en pantalla
    
    return 100
```

**Timing:** UI appears immediately

### 📊 Tabla de Tiempos Totales

| Escenario | GPU (Nvidia 3050+) | CPU (Quad-core) |
|-----------|-------------------|-----------------|
| **Todo nuevo** (downloads + setup) | 3-5 min | 5-8 min |
| **Solo embeddings** (Ollama existente) | 30-60 seg | 60-120 seg |
| **Todo en caché** (segundo inicio) | <100 ms | <100 ms |

### 🛠️ Manejo de Errores During First Run

```python
# Si Ollama descarga falla:
# → Retry 3 veces con backoff exponencial
# → Si sigue fallando: Mostrar error modal
#   "Cannot download Ollama. Check internet. Manual: https://ollama.ai/download"

# Si GPU variant pero CUDA no encontrado:
# → Auto-fallback a CPU (silencioso)
# → Continuar proceso (usuario ve latencia más alta)
# → Log en ~/.softarchitect/logs/startup.log

# Si embeddings fallan:
# → Retry con batch-size reducido
# → Si sigue fallando: Reset chroma_data/ y retry
# → Si 3 retries fallan: Mostrar error + soporte link

# Si base de datos corrupta:
# → Backup existing DB
# → Crear schema nuevo
# → Perder historial pero continuar funcionando
```

### ✅ Validación Post-Setup

```bash
# Verificaciones que hace el app antes de mostrar UI:

✓ ~/.softarchitect/ directory exists
✓ Ollama service running on 127.0.0.1:11434
✓ Model "qwen2.5:3b" listed in ollama
✓ ~/.softarchitect/chroma_data/ exists with valid index
✓ ~/.softarchitect/softarchitect.db schema OK
✓ FastAPI backend responds to /health
✓ Storage permisos OK (read/write test)
```

Si cualquier validación falla → Mostrar error specifico + opción para retry

---

## 📋 Checklist para Production Release

```
ANTES DE RELEASE v0.1.0:

Code Quality:
[ ] Todos los tests pasan (236+)
[ ] Coverage >80% (88% actual)
[ ] 0 Pylance errors
[ ] 0 CVEs en dependencies
[ ] Code review completado

Performance:
[ ] Startup <10 segundos
[ ] First token <200ms
[ ] Ingest tarda <60 seg (129 docs)
[ ] Memoria baseline <300 MB

Packaging:
[ ] .msi (Windows) probado en VM virgen
[ ] .deb (Linux) probado en Ubuntu 22.04
[ ] .dmg (macOS) probado en macOS 12+
[ ] Código firmado (Code signing certs)
[ ] Desinstalador funciona limpiamente

Documentation:
[ ] README.md para usuario final (no dev)
[ ] Troubleshooting guide
[ ] FAQ publicadas
[ ] Release notes en 2 idiomas (es/en)

Installer Behavior:
[ ] Setup on first run completa sin errores
[ ] chroma_data se genera automáticamente
[ ] Onboarding se muestra
[ ] Chat funciona sin config adicional

Regression Testing:
[ ] Can install -> uninstall -> reinstall
[ ] Settings persisten entre sesiones
[ ] Historial de chat se guarda
[ ] Logout/Login workflow (si aplica)
```

---

## 🎯 Comparativa Antes/Después

### **Antes (Hoy - sin instalador)**

```
Usuario quiere usar SoftArchitect AI:
├─ Instala Docker ❌ (no sabe qué es)
├─ Clona Git repo ❌ (no tiene Git)
├─ Edita .env file ❌ (sin editor)
├─ Ejecuta docker-compose up ❌ (terminal intimidante)
├─ Espera 5 minutos ❌ (sin feedback)
├─ Navega a localhost:8000 ❌ (URL manual)
└─ ABANDONA ❌ (Too many steps)
```

### **Después (v0.1.0 - con instalador)**

```
Usuario quiere usar SoftArchitect AI:
├─ Descarga softarchitect-ai-0.1.0.msi (1 click)
├─ Ejecuta setup.exe
├─ "Siguiente" → "Siguiente" → "Instalar"
├─ Setup completa en 2 minutos
├─ App abre automáticamente
├─ Onboarding explica qué es
├─ Usuario escribe pregunta
├─ Sistema responde ✅
└─ FELIZ ✅ (2 minutos, 3 clicks, done)
```

---

## 🔄 Actualización de Knowledge Base (MVP+)

Para futuras versiones (no en v0.1.0), se podría implementar:

```
USER FLOW:
Usuario abre Settings → Knowledge Base → "Check for Updates"
│
├─ Sistema conecta a: updates.softarchitect.ai
├─ Descarga KB nueva: packages/knowledge_base-v2.tar.gz
├─ Descomprime a: ~/.softarchitect/kb_new/
├─ Re-ejecuta ingest.py
├─ Si éxito → reemplaza chroma_data/
├─ Si fallo → rollback automático
└─ Notifica: "KB actualizada a v2"

Esto permite:
✅ Compartir mejoras sin software update
✅ Comunidad contribuye documentación
✅ Zero-downtime updates
```

---

## 📊 Resumen Ejecutivo

| Aspecto | Respuesta |
|--------|-----------|
| **¿Se generan datos en instalación?** | SÍ, `chroma_data/` se genera en PRIMER INICIO automáticamente |
| **¿El usuario lo ve?** | NO, solo ve "Inicializando..." splash (30-60 seg) |
| **¿Necesita hacer nada el usuario?** | NO, completamente automático (ingest.py se ejecuta sin intervención) |
| **¿Dónde se almacenan datos?** | `~/.softarchitect/chroma_data/` (user home directory) |
| **¿Se syncronizan a la nube?** | NO, todo offline y local (privacidad first) |
| **¿Se puede regenerar?** | SÍ, desde Settings → "Regenerate KB" o CLI |
| **¿Qué incluye el instalador?** | Runtime (Python, Flutter) + código compilado + KB fuente |
| **¿Tamaño del instalador?** | 200-300 MB (comprimido) |
| **¿Tamaño después instalar?** | ~510 MB en disco |

---

## 🎓 Conclusión

**El modelo es:**

1. **Para Desarrolladores** (hoy): Repositorio Git con código fuente + scripts de ingesta
2. **Para Usuarios Finales** (v0.1.0): Instalador one-click que maneja todo automáticamente
3. **Datos generados**: Se crean on-demand en primer inicio, nunca en Git
4. **Transparencia**: Usuario solo ve "Installing..." y luego chat limpio

**El siguiente paso** sería implementar HU-6.1 (packaging) para convertir esto de teoría a realidad.

---

**Documento creado**: 2 de febrero de 2026
**Versión**: 1.0
**Status**: Definición arquitectónica para v0.1.0
