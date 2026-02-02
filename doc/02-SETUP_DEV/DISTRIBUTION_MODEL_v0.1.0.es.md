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
