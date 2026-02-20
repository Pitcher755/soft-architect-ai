# 🚀 Preparación Lista para HU-3.3: Chat Secuencial

> **Status:** ✅ LISTO PARA INICIAR
> **Rama:** `feature/chat-sequential-docs`
> **Date:** 2026-02-05

---

## 📋 Checklist Pre-HU-3.3

### ✅ Completed

- [x] **Tests de Python Centralizados**
  - Migrados de `src/server/tests/` → `tests/python/`
  - 22 test files validados
  - Conftest.py actualizado
  - Configuraciones actualizadas (pytest, pyright, CI/CD)

- [x] **Workflow Maestro HU-3.3 Creado**
  - Document completo: `doc/03-HU-TRACKING/HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md`
  - 6 Phases TDD definidas
  - Todos los tests planificados
  - Casos de uso y validación especificada

- [x] **Documentación de Migración**
  - README_MIGRATION.md en tests/python/
  - TESTS_MIGRATION_REPORT.md en doc/01-PROJECT_REPORT/
  - Script de validación: scripts/validate_tests_migration.sh

- [x] **CI/CD Pipeline Actualizado**
  - backend-ci.yaml apunta a tests/python/
  - Pytest.ini testpaths correcto
  - Pyrightconfig.json actualizado

### 🚀 Listo para Iniciar

- [ ] Leer el Workflow Maestro HU-3.3 completo
- [ ] Entender los 6 phases (RED → GREEN pattern)
- [ ] Preparar el ambiente para TDD
- [ ] Create branch para HU-3.3 (ya existente)

---

## 📁 Estructura del Project (Post-Migración)

```
soft-architect-ai/
│
├── src/
│   ├── client/                  # Flutter Desktop app (HU-3.1 ✅, HU-3.2 ✅)
│   │   └── lib/
│   │       └── features/
│   │           └── project_shell/  # UI + SQLite (ProjectShell)
│   │
│   └── server/                  # FastAPI backend (HU-1.2 ✅, HU-2.1 ✅, HU-2.2 ✅)
│       ├── app/                 # FastAPI application
│       ├── services/            # RAG, ChromaDB integration
│       ├── core/                # Exceptions, config
│       └── pyproject.toml       # Updated: testpaths → ../../tests/python
│
├── tests/
│   ├── python/                  # ← NEWLY CENTRALIZED (Monorepo)
│   │   ├── conftest.py         # Pytest config
│   │   ├── unit/               # Unit tests (22 files)
│   │   │   ├── app/            # FastAPI tests
│   │   │   ├── core/           # Core tests
│   │   │   ├── services/       # RAG tests
│   │   │   └── scripts/        # CLI tests
│   │   └── integration/        # Integration tests
│   │
│   └── test/                    # Flutter tests (Dart)
│       └── features/
│           └── project_shell/   # ProjectShell tests
│
├── packages/
│   └── knowledge_base/          # RAG Templates (HU-2.1 ✅)
│       └── 03-TEMPLATES/        # Doc templates for chat
│
├── doc/
│   ├── 01-PROJECT_REPORT/
│   │   ├── TESTS_MIGRATION_REPORT.md     # ← NEW
│   │   └── ...
│   │
│   └── 03-HU-TRACKING/
│       └── HU-3.3_CHAT_SEQUENTIAL_DOCS/
│           ├── HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md  # ← NEW (21 sections)
│           └── README.md
│
├── scripts/
│   ├── validate_tests_migration.sh  # ← NEW (validation script)
│   └── ...
│
├── .github/workflows/
│   ├── backend-ci.yaml          # Updated: tests path
│   └── ...
│
└── pyrightconfig.json           # Updated: include tests/python
```

---

## 🎯 HU-3.3 Overview

### Historia de Usuario
```
"Como Usuario, quiero un chat que me guíe secuencialmente
para generar documentos (Doc 1→25) usando templates RAG
e iteración conversacional."
```

### Complejidad
- **Estimación:** XXL (21 Story Points)
- **Prioridad:** CRITICAL
- **Duración Estimada:** 3-4 días

### Dependencias (Todas Resueltas ✅)
- [x] HU-3.1: ProjectShell + SQLite
- [x] HU-3.2: FileSystemService
- [x] HU-2.2: ChromaDB + RAG

---

## 📖 Workflow Maestro: 6 Phases

### Phase 1: Backend RAG Orchestration (TDD RED)
- Tests de orchestrator
- Tests de template loader
- Tests de streaming SSE

### Phase 2: Backend SSE Streaming (TDD GREEN)
- Implementar endpoint FastAPI
- Completar SequentialOrchestrator
- Conexión con LLM

### Phase 3: Frontend State Machine (TDD RED)
- Tests de Domain Layer (ChatMessage, DocumentProposal)
- Tests de ChatNotifier (máquina de statuss)
- Validación de flujo secuencial

### Phase 4: UI Components Golden Kit (TDD GREEN)
- ProposalCardWidget
- Mensaje bubbles
- Streaming indicator
- Progress bar (Doc N/25)

### Phase 5: Integration The Gate (TDD RED)
- Tests E2E
- Conexión Frontend → Backend → FileSystem (HU-3.2)
- Validación y persistencia

### Phase 6: End-to-End Validation (TDD GREEN)
- Script de validación completa
- Manual E2E checklist
- Performance benchmarks

---

## 🔧 Comando para Iniciar HU-3.3

### 1. Estar en la Rama Correcta
```bash
git checkout develop
git pull
git checkout feature/chat-sequential-docs
```

### 2. Validar Setup
```bash
# Verificar tests migrados
./scripts/validate_tests_migration.sh

# Verificar estructura
tree tests/python -L 2

# Verificar conftest
cat tests/python/conftest.py
```

### 3. Leer el Workflow Completo
```bash
# Abrir documento
code doc/03-HU-TRACKING/HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md
```

### 4. Comenzar Phase 1 (TDD RED)
```bash
# Crear archivo de test
mkdir -p tests/python/unit/services/rag
touch tests/python/unit/services/rag/test_orchestrator.py

# Escribir primer test (RED)
# Ver sección 4.2 en HU-3.3 Workflow
```

---

## 🚦 Estatus de Dependencias

| HU | Name | Status | Impacto en HU-3.3 |
|----|--------|--------|-------------------|
| **HU-3.1** | ProjectShell + SQLite | ✅ DONE | Progreso Doc N/25 |
| **HU-3.2** | FileSystemService | ✅ DONE | Persistencia |
| **HU-2.2** | ChromaDB + RAG | ✅ DONE | Templates |
| **HU-3.4** | Error Handling Gates | ⏳ Optional | Validación robusta |
| **HU-3.5** | Streaming Optimization | ⏳ Optional | Performance |

---

## 📊 Criterios de Aceptación (del Roadmap)

### ✅ Positivos (8)
- [ ] Chat inicial pregunta description y genera 'Propuesta Doc 1'
- [ ] Propuesta es temporal (NO persiste hasta 'Validar')
- [ ] Button enviar deshabilitado si campo vacío/espacios
- [ ] Bloques código con button 'Copiar' funcional
- [ ] Button 'Validar y Guardar' llama FileSystemService (HU-3.2)
- [ ] Streaming SSE con <200ms TTF
- [ ] Barra de progreso actualiza (Doc N/25) tras validar
- [ ] Flujo 100% secuencial (nunca 2 docs paralelos)

### ❌ Negativos (1)
- [ ] Documents NO se guardan sin clic en 'Validar'

---

## 🔍 Validación Pre-Commit

Todos los tests deben pasar antes de push:

```bash
cd src/server
pytest ../../tests/python/ -v --cov=app --cov-fail-under=80

# Esperado: ✅ passed
```

---

## 📚 Documents de Referencia

1. **Workflow Maestro:**
   - [HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md](doc/03-HU-TRACKING/HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md)

2. **Migración de Tests:**
   - [TESTS_MIGRATION_REPORT.md](doc/01-PROJECT_REPORT/TESTS_MIGRATION_REPORT.md)
   - [tests/python/README_MIGRATION.md](tests/python/README_MIGRATION.md)

3. **Reglas del Project:**
   - [AGENTS.md](AGENTS.md) - Sección 8 (Estándar de Documentación)

4. **Roadmap Completo:**
   - [USER_STORIES_MASTER.es.json](context/40-ROADMAP/USER_STORIES_MASTER.es.json)

---

## ⚡ Quick Start HU-3.3

```bash
# 1. Estar en la rama correcta
git status  # Debe mostrar: "On branch feature/chat-sequential-docs"

# 2. Validar ambiente
./scripts/validate_tests_migration.sh  # Debe pasar 5/5 ✅

# 3. Leer workflow
less doc/03-HU-TRACKING/HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md

# 4. Comenzar Fase 1 - Backend RAG Orchestration
cd src/server
pytest ../../tests/python/unit/services/rag/ -v  # Test suite vacío (expected)

# 5. Crear primer test
touch ../../tests/python/unit/services/rag/test_orchestrator.py
# Copiar contenido de sección 4.2 en HU-3.3 Workflow

# 6. Ejecutar test (RED - debería fallar)
pytest ../../tests/python/unit/services/rag/test_orchestrator.py -v
```

---

## ✨ Lo Que Está Listo

- ✅ Tests centralizados y validados
- ✅ Workflow maestro documentado (6 phases TDD)
- ✅ CI/CD actualizado
- ✅ Dependencias resueltas (HU-3.1, HU-3.2, HU-2.2)
- ✅ Rama creada y limpia
- ✅ Documentación completa

---

## 🎯 Próximo Checkpoint

**Lectura obligatoria:** [HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md](doc/03-HU-TRACKING/HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md) (completo, 21 secciones)

**Tiempo estimado:** 30-45 minutos

**Objetivo:** Entender los 6 phases y estar listo para comenzar TDD RED de Phase 1

---

**🚀 ¡Estamos ready for construir el corazón de SoftArchitect AI!**

*Fecha: 2026-02-05*
*Rama: feature/chat-sequential-docs*
*Status: READY FOR HU-3.3*
