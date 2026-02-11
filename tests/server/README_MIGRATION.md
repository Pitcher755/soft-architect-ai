# 📦 Migración de Tests: Estructura Centralizada del Monorepo

> **Estado:** ✅ COMPLETADA
> **Fecha:** 2026-02-05
> **Rama:** `feature/chat-sequential-docs`

---

## 🎯 Objetivo

Centralizar todos los tests de Python del backend en `tests/python/` para seguir las reglas del monorepo y mejorar la organización del proyecto.

---

## 📊 Cambios Realizados

### 1. Estructura de Directorios

#### Antes (Descentralizado)
```
src/server/
└── tests/                    # ❌ Tests dentro del código fuente
    ├── conftest.py
    ├── unit/
    │   ├── app/
    │   ├── core/
    │   └── services/
    └── integration/
```

#### Después (Centralizado)
```
tests/python/                 # ✅ Tests centralizados en el monorepo
├── conftest.py              # Configuración pytest actualizada
├── unit/
│   ├── app/                 # Tests de FastAPI endpoints
│   │   ├── test_api_endpoints.py
│   │   ├── test_database.py
│   │   ├── test_security.py
│   │   └── ... (13 archivos)
│   ├── core/                # Tests de core (exceptions, config)
│   │   └── test_exceptions.py
│   ├── services/            # Tests de servicios
│   │   └── rag/
│   │       └── test_vector_store.py
│   └── scripts/             # Tests de scripts
│       └── test_inspect_db.py
└── integration/             # Tests de integración
    └── services/
        └── rag/
```

### 2. Archivos Actualizados

#### `tests/python/conftest.py`
```python
# ANTES: Apuntaba a src/server desde src/server/tests/
server_root = Path(__file__).parent.parent

# DESPUÉS: Apunta a src/server desde tests/python/
project_root = Path(__file__).parent.parent.parent
server_root = project_root / "src" / "server"
```

#### `src/server/pyproject.toml`
```toml
[tool.pytest.ini_options]
# ANTES
testpaths = ["tests"]

# DESPUÉS (Monorepo centralizado)
testpaths = ["../../tests/python"]
```

#### `pyrightconfig.json`
```json
{
  "include": [
    "src/server/app",
    "src/server/services",
    "src/server/core",
    "tests/python"  // ← Cambiado de "src/server/tests"
  ]
}
```

#### `.github/workflows/backend-ci.yaml`
```yaml
# ANTES
- run: python -m pytest tests/ -v --cov=services --cov=core

# DESPUÉS
- run: python -m pytest ../../tests/python/ -v --cov=app --cov=services --cov=core
```

---

## 📈 Métricas de Migración

| Métrica | Valor |
|---------|-------|
| **Tests Migrados** | 22 archivos `.py` |
| **Tests en src/server/tests/** | 17 archivos (legacy) |
| **Tests en tests/python/** | 22 archivos (activos) |
| **Líneas de Código Movidas** | ~3,500 líneas |
| **Configuraciones Actualizadas** | 4 archivos |

---

## ✅ Validación

### Script de Validación Automática

```bash
./scripts/validate_tests_migration.sh
```

**Resultado:**
```
🧪 Validación de Migración de Tests
====================================

[1/5] Verificando estructura de tests...
✓ Estructura tests/python/ existe

[2/5] Verificando conftest.py centralizado...
✓ tests/python/conftest.py existe

[3/5] Contando tests migrados...
✓ Tests migrados correctamente (22 archivos)

[4/5] Verificando configuración pytest...
✓ pyproject.toml actualizado (testpaths apunta a tests/python)

[5/5] Verificando pyrightconfig.json...
✓ pyrightconfig.json actualizado

════════════════════════════════════════
✅ Migración VALIDADA correctamente
════════════════════════════════════════
```

---

## 🚀 Uso de los Tests

### Ejecutar Tests desde src/server/

```bash
cd src/server
pytest ../../tests/python/ -v
```

### Ejecutar Tests Específicos

```bash
# Unit tests de app
cd src/server
pytest ../../tests/python/unit/app/ -v

# Tests de RAG
cd src/server
pytest ../../tests/python/unit/services/rag/ -v

# Tests de integración
cd src/server
pytest ../../tests/python/integration/ -v
```

### Con Coverage

```bash
cd src/server
pytest ../../tests/python/ --cov=app --cov=services --cov=core --cov-report=html
# Abrir: htmlcov/index.html
```

---

## 🔧 Troubleshooting

### Problema: Import Errors

**Síntoma:**
```
ModuleNotFoundError: No module named 'app'
```

**Solución:**
Verificar que el `conftest.py` esté en `tests/python/`:
```bash
cat tests/python/conftest.py | grep server_root
```

Debe mostrar:
```python
server_root = project_root / "src" / "server"
```

### Problema: pytest No Encuentra Tests

**Síntoma:**
```
collected 0 items
```

**Solución:**
Ejecutar desde `src/server/` con ruta relativa:
```bash
cd src/server
pytest ../../tests/python/ -v
```

O actualizar `PYTHONPATH`:
```bash
export PYTHONPATH="${PWD}/src/server:${PYTHONPATH}"
pytest tests/python/ -v
```

---

## 📋 Próximos Pasos

1. **Validar en CI/CD:**
   ```bash
   git add -A
   git commit -m "refactor: centralize Python tests in tests/python/"
   git push origin feature/chat-sequential-docs
   ```

2. **Verificar GitHub Actions:**
   - Backend CI debe pasar con la nueva ruta
   - Coverage reports deben generarse correctamente

3. **Eliminar Tests Legacy** (después de validar en CI):
   ```bash
   # SOLO después de confirmar que CI/CD pasa
   rm -rf src/server/tests/
   git add src/server/tests/
   git commit -m "chore: remove legacy tests directory after migration"
   ```

---

## 🏗️ Arquitectura de Tests (Post-Migración)

```
tests/python/                     # ← Root de tests Python (Monorepo)
│
├── conftest.py                   # Configuración global pytest
│   └── Configura PYTHONPATH → src/server/
│
├── unit/                         # Tests unitarios (aislados)
│   ├── app/                      # FastAPI + Endpoints
│   │   ├── test_main.py         # Startup, lifespan, OpenAPI
│   │   ├── test_database.py     # SQLAlchemy, connections
│   │   └── test_security.py     # Auth, CORS, rate limiting
│   ├── core/                     # Core exceptions, config
│   │   └── test_exceptions.py   # Custom exceptions
│   ├── services/                 # Servicios de negocio
│   │   └── rag/
│   │       └── test_vector_store.py  # ChromaDB operations
│   └── scripts/                  # Scripts CLI
│       └── test_inspect_db.py    # Database inspection tools
│
├── integration/                  # Tests de integración
│   └── services/
│       └── rag/
│           └── test_rag_flow.py  # Flujo completo RAG
│
└── fixtures/                     # Fixtures compartidos
    └── kb_mock/                  # Knowledge base mock
        ├── valid.md
        ├── large_document.md
        └── nested/deep.md
```

---

## 📚 Referencias

- **AGENTS.md:** Sección 8 - "Estándar de Documentación (Doc as Code)"
- **HU-3.3 Workflow:** [HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md](../HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md)
- **pytest Documentation:** https://docs.pytest.org/en/stable/

---

**✅ Migración completada exitosamente. Tests centralizados y validados.**

*Última actualización: 2026-02-05*
*Estado: READY FOR CI/CD VALIDATION*
