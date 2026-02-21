# 🧪 Guía de Ejecución de Tests

> **Version:** v0.1.0 | **Status:** ✅ Actualizado | **Fecha:** 31/01/2026

---

## 📖 Table of Contents

1. [Requisitos Previos](#requisitos-previos)
2. [Setup Inicial](#setup-inicial)
3. [Execute Tests](#execute-tests)
4. [Ver Results](#ver-resultados)
5. [Debugging](#debugging)
6. [Troubleshooting](#troubleshooting)

---

## 📋 Requisitos Previos

### Sistema Operativo
- ✅ Linux (Ubuntu 20.04+), macOS, o Windows (WSL2)
- ✅ Python 3.12.3+
- ✅ Docker 20.10+ (para tests E2E)

### Herramientas Instaladas
```bash
# Verificar Python
python --version
# Esperado: Python 3.12.3

# Verificar pip
pip --version

# Verificar Docker
docker --version
# Esperado: Docker 20.10+

# Verificar Docker Compose
docker-compose --version
# Esperado: Docker Compose 1.29+
```

### Dependencias del Project
```bash
# Todas las dependencias se instalan con:
pip install -r requirements.txt

# Verificar instalación
pip list | grep -i pytest
pip list | grep -i chromadb
```

---

## 🚀 Setup Inicial

### 1. Clonar/Navegar al Project

```bash
cd /path/to/soft-architect-ai
```

### 2. Create Virtual Environment (si no existe)

```bash
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
```

### 3. Instalar Dependencias

```bash
pip install -r requirements.txt
```

### 4. Iniciar Docker Services

```bash
# Navegar a directorio infrastructure
cd infrastructure

# Iniciar servicios (ChromaDB, API server, Ollama)
docker-compose up -d

# Verificar que los servicios están corriendo
docker-compose ps
# Esperado:
# NAME        STATUS          PORTS
# chromadb    Up 5 seconds    0.0.0.0:8000->8000/tcp
# ollama      Up 5 seconds    0.0.0.0:11434->11434/tcp
# api-server  Up 5 seconds    0.0.0.0:8001->8001/tcp
```

### 5. Verificar Conectividad

```bash
# Verificar ChromaDB
curl http://localhost:8000/api/v1/heartbeat
# Esperado: {"status":"ok"}

# Verificar API Server
curl http://localhost:8001/health
# Esperado: {"status":"healthy"}
```

---

## 🧪 Execute Tests

### Opción 1: Todos los Tests (Recomendado)

```bash
cd /path/to/soft-architect-ai

# Setup environment
export PYTHONPATH=/path/to/src/server:/path/to/project
export CHROMA_HOST=localhost

# Ejecutar suite completa
python -m pytest \
  src/server/tests/unit/ \
  src/server/tests/integration/ \
  -v \
  --cov=src/server \
  --cov-report=term-missing:skip-covered \
  --cov-report=html
```

**Salida Esperada:**
```
======================== test session starts ========================
collected 19 items

tests/unit/services/rag/test_vector_store.py ..............   [ 73%]
tests/integration/services/rag/test_vector_store_e2e.py .....

======================== 19 passed in 10.40s ========================
```

### Opción 2: Solo Tests Unitarios

```bash
python -m pytest src/server/tests/unit/ -v
```

### Opción 3: Solo Tests de Integración/E2E

```bash
python -m pytest src/server/tests/integration/ -v
```

### Opción 4: Test Específico

```bash
# Ejecutar un test individual
python -m pytest \
  src/server/tests/unit/services/rag/test_vector_store.py::test_initialization_success \
  -v

# Ejecutar una clase de tests
python -m pytest \
  src/server/tests/unit/services/rag/test_vector_store.py::TestDocumentIngestion \
  -v

# Ejecutar tests que coincidan con patrón
python -m pytest -k "ingest" -v
```

### Opción 5: Con Output Detallado

```bash
# Ver print statements y logs
python -m pytest src/server/tests/ -v -s

# Ver logs en nivel DEBUG
python -m pytest src/server/tests/ -v -s --log-cli-level=DEBUG
```

---

## 📊 Ver Results

### Coverage HTML Report

```bash
# Coverage report está en htmlcov/index.html
# Generado automáticamente con --cov-report=html

# Abrir en navegador
# Linux
xdg-open htmlcov/index.html

# macOS
open htmlcov/index.html

# Windows
start htmlcov/index.html
```

### Coverage Terminal Report

```bash
# Reporte en terminal (sin skipped files)
python -m pytest \
  src/server/tests/ \
  --cov=src/server \
  --cov-report=term-missing:skip-covered
```

**Ejemplo de Salida:**
```
Name                                  Stmts  Miss  Cover  Missing
---------------------------------------------------------------------
services/rag/vector_store.py            99     5    95%   112-113, 289-291
tests/unit/services/rag/test_vector_store.py 143  0   100%
tests/integration/.../test_vector_store_e2e.py 39  0   100%
---------------------------------------------------------------------
TOTAL                                   406    130   68%
```

### JUnit XML Report

```bash
# Para integración con CI/CD
python -m pytest src/server/tests/ \
  --junit-xml=test-results.xml
```

---

## 🐛 Debugging

### Execute Test con Breakpoint

```bash
# Usar pdb para debugging interactivo
python -m pytest \
  src/server/tests/unit/test_vector_store.py::test_initialization_success \
  --pdb

# Comandos útiles en pdb:
# n = next line
# s = step into
# c = continue
# p variable_name = print variable
# l = list code around current line
# q = quit
```

### Execute Test con Traceback Completo

```bash
python -m pytest \
  src/server/tests/unit/test_vector_store.py \
  --tb=long  # long, short, line, native, no
```

### Capturar Output de Test

```bash
# Mostrar todo lo que el test imprime
python -m pytest src/server/tests/ -v -s --capture=no
```

### Logging Detallado

```bash
# Habilitar logging del test
python -m pytest \
  src/server/tests/ \
  --log-cli-level=DEBUG \
  --log-file=test.log \
  --log-file-level=DEBUG
```

---

## 🔧 Troubleshooting

### Problema 1: ChromaDB no está disponible

**Error:**
```
httpx.ConnectError: [Errno -2] Name or service not known
```

**Solución:**
```bash
# Verificar que ChromaDB está ejecutándose
docker ps | grep chromadb

# Si no está, iniciar servicios
cd infrastructure
docker-compose up -d chromadb

# Verificar conectividad
curl http://localhost:8000/api/v1/heartbeat
```

### Problema 2: PYTHONPATH inválido

**Error:**
```
ModuleNotFoundError: No module named 'services'
```

**Solución:**
```bash
# Configurar PYTHONPATH correctamente
export PYTHONPATH=/full/path/to/src/server:/full/path/to/project

# Verificar
echo $PYTHONPATH

# Ejecutar pytest desde el directorio correcto
cd /full/path/to/soft-architect-ai
```

### Problema 3: Tests se skippean

**Output:**
```
SKIPPED [5] tests/integration/services/rag/test_vector_store_e2e.py:23:
Requires Docker ChromaDB (set CHROMA_HOST env var)
```

**Solución:**
```bash
# Asegurar que CHROMA_HOST está seteada
export CHROMA_HOST=localhost

# Verificar
echo $CHROMA_HOST

# Ejecutar con env var inline
CHROMA_HOST=localhost python -m pytest src/server/tests/integration/ -v
```

### Problema 4: Timeout en tests

**Error:**
```
Timeout: no response from ChromaDB after 30 seconds
```

**Solución:**
```bash
# Aumentar timeout
python -m pytest src/server/tests/ --timeout=60

# O verificar que ChromaDB está bien
docker logs chromadb | tail -20

# Reiniciar si es necesario
docker-compose restart chromadb
```

### Problema 5: Port ya en uso

**Error:**
```
ERROR: for chromadb Cannot start service chromadb: driver failed
```

**Solución:**
```bash
# Matar proceso en puerto 8000
lsof -i :8000 | awk 'NR==2 {print $2}' | xargs kill -9

# O cambiar puerto en docker-compose.yml
# y setear CHROMA_HOST=localhost:PORT
```

---

## 📊 Comandos Útiles

### Quick Reference

```bash
# Ejecutar todos los tests
pytest src/server/tests/ -v

# Con coverage
pytest src/server/tests/ -v --cov=src/server --cov-report=html

# Solo tests que fallan
pytest src/server/tests/ -v --lf

# Tests fallidos + todos después
pytest src/server/tests/ -v --ff

# N tests aleatorios
pytest src/server/tests/ -v --randomly-seed=123

# Stop en primer fallo
pytest src/server/tests/ -v -x

# Stop después de N fallos
pytest src/server/tests/ -v --maxfail=3

# Verbose mode (show all assertions)
pytest src/server/tests/ -vv

# Quiet mode
pytest src/server/tests/ -q

# Markers
pytest src/server/tests/ -v -m unit
pytest src/server/tests/ -v -m integration
```

### Performance Analysis

```bash
# Ver tests más lentos
pytest src/server/tests/ -v --durations=10

# Profile memory
pytest src/server/tests/ --memray

# Ver coverage por función
pytest src/server/tests/ --cov=src/server --cov-report=term-missing
```

---

## 📋 Checklist de Validación

Antes de hacer commit, execute:

```bash
# 1. Todos los tests pasan
✅ pytest src/server/tests/ -v

# 2. Coverage es adecuado
✅ pytest src/server/tests/ --cov=src/server --cov-report=term-missing

# 3. No hay warnings
✅ pytest src/server/tests/ -v -W error::DeprecationWarning

# 4. Docker services están arriba
✅ docker-compose ps | grep -i "up"

# 5. ChromaDB responde
✅ curl http://localhost:8000/api/v1/heartbeat
```

---

## 🎓 Mejores Prácticas

### Para Tests Nuevos

1. **Ubicación:** `src/server/tests/{unit,integration}/`
2. **Naming:** `test_*.py` o `*_test.py`
3. **Fixtures:** Usar `conftest.py` para fixtures compartidas
4. **Marcadores:** Usar `@pytest.mark.unit`, `@pytest.mark.integration`
5. **Async:** Usar `@pytest.mark.asyncio` para async tests

### Para Development

1. Execute suite cada 30 minutos
2. Execute test específico antes de commit
3. Mantener coverage >80% en código nuevo
4. Revisar failing tests inmediatamente
5. Documentar test cases complejos

---

## 📞 Recursos

- **Pytest Documentation:** https://docs.pytest.org/
- **Pytest Coverage:** https://coverage.readthedocs.io/
- **Docker Compose:** https://docs.docker.com/compose/
- **ChromaDB:** https://docs.trychroma.com/

---

**Última Actualización:** 31/01/2026 | **Generado por:** GitHub Copilot
