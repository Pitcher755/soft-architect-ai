# HU-3.8: LISTA DETALLADA DE OBJETIVOS PENDIENTES

> **Fecha Generación:** 12/02/2026 22:42
> **Status PRE_PUSH_VALIDATION:** ❌ 4/4 CRITICAL CHECKS FAILED
> **Prioridad:** 🔴 BLOQUEADOR PARA MERGE

---

## 📋 RESUMEN EJECUTIVO

| Métrica | Valor | Status |
|---------|-------|--------|
| **Tests que pasan** | 12/16 | ⚠️ 75% |
| **Tests que fallan** | 4/16 | 🔴 25% |
| **Cobertura código** | < 80% | ❌ BAJO |
| **Completitud módulo HU** | ? | ❓ NO MEDIDA |
| **Bloqueo merge** | SÍ | 🔴 CRÍTICO |

---

## 🔴 OBJETIVO 1: FIJAR PYTHON UNIT TESTS

**Prioridad:** 🔴 CRÍTICO
**Impacto:** Bloquea tests de integración y cobertura

### Síntomas
```
PHASE 4️⃣: UNIT TESTS
▶ Python Unit Tests
❌ Python Unit Tests  ← AQUÍ FALLA
```

### Diagnóstico Requerido
```bash
# Comando exacto para diagnosticar
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai

# Paso 1: Ver qué tests están corriendo
python -m pytest tests/server/unit/ -v --tb=short --timeout=30

# Paso 2: Si timeout, identificar test problemático
python -m pytest tests/server/unit/domain/ -v --timeout=10 -x

# Paso 3: Inspeccionar conftest.py
cat tests/server/conftest.py | head -50
```

### Tareas Específicas

- [ ] **TAREA 1.1:** Execute comando de diagnóstico y capturar output
- [ ] **TAREA 1.2:** Revisar `tests/server/conftest.py`
  - Verificar fixtures que inicializan SQLite
  - Buscar async fixtures sin `asyncio_mode` configurado
  - Revisar database cleanup en `teardown`

- [ ] **TAREA 1.3:** Inspeccionar `tests/server/unit/domain/`
  - Buscar imports rotos
  - Verificar mock database path es relativo
  - Revisar si tests dependen de files en `tests/fixtures/`

- [ ] **TAREA 1.4:** Verificar dependencias en `pyproject.toml`
  ```bash
  # Listar versiones actuales
  grep -A 10 '^\[tool.poetry.dependencies\]' src/server/pyproject.toml

  # Comparar con requirements.txt.new
  diff <(grep '^pytest' src/server/pyproject.toml) <(grep '^pytest' requirements.txt.new)
  ```

- [ ] **TAREA 1.5:** Reinstalar entorno si necesario
  ```bash
  cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai

  # Opción A: Limpiar caché y reinstalar
  cd tests/server
  python -m pip install --upgrade pytest pytest-asyncio pytest-cov -q

  # Opción B: Usar venv fresh (si opción A no funciona)
  rm -rf tests/venv
  python3 -m venv tests/venv
  source tests/venv/bin/activate
  pip install -r requirements.txt.new
  ```

- [ ] **TAREA 1.6:** Execute tests de nueva con datos de diagnóstico
  ```bash
  python -m pytest tests/server/unit/ -vv --tb=short --timeout=30 --durations=10
  ```

### Criterio de Completitud
```
✅ Success: pytest tests/server/unit/ retorna exit code 0
            Todos los unit tests PASAN
            Output: "X passed in Ys"
```

---

## 🟠 OBJETIVO 2: FIJAR SQLITE INTEGRATION TESTS

**Prioridad:** 🔴 CRÍTICO
**Dependencia:** Completar OBJ-1 primero
**Impacto:** Bloquea coverage measurement

### Síntomas
```
PHASE 5️⃣: INTEGRATION TESTS & PERFORMANCE
▶ SQLite Integration Tests
❌ SQLite Integration Tests  ← AQUÍ FALLA
```

### Tests Específicos Afectados
```
√ test_sqlite_persistence.py (19 tests)
√ test_sqlite_performance.py (5 tests)
√ test_error_handling_flow.py (6 tests)
√ test_streaming_flow.py (5 tests)
√ test_security_sql_injection.py (7 tests)
```

### Tareas Específicas

- [ ] **TAREA 2.1:** Diagnosticar errores específicos
  ```bash
  cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai
  python -m pytest tests/server/integration/test_sqlite_persistence.py::test_create_project_success -vv
  ```

- [ ] **TAREA 2.2:** Buscar problemas comunes
  - [ ] Database file permisos (si ruta `/tmp/`): `ls -la /tmp/test_*.db`
  - [ ] Database locks: `lsof | grep .db`
  - [ ] Async fixtures: revisar `@pytest.fixture(scope="function")`
  - [ ] Transaccion isolation level

- [ ] **TAREA 2.3:** Revisar fixture database
  ```bash
  # Buscar "test_db" o "database" fixture en conftest
  grep -r "def.*db\|@pytest.fixture.*database" tests/server/ | head -20
  ```

- [ ] **TAREA 2.4:** Verificar setup/teardown
  - [ ] Base datos temporal se crea antes de tests: ✓
  - [ ] Base datos se limpia después: ✓
  - [ ] No hay conflictos entre tests paralelos: ✓

- [ ] **TAREA 2.5:** Execute integration tests con debug
  ```bash
  python -m pytest tests/server/integration/ -vv --tb=short --durations=5 -x
  # -x = para en primer fallo para inspeccionar
  ```

### Criterio de Completitud
```
✅ Success: pytest tests/server/integration/ retorna exit code 0
            Todos los integration tests PASAN
            Output: "Y passed in Xs"
```

---

## 🟡 OBJETIVO 3: MEDIR COBERTURA DE TESTS

**Prioridad:** 🔴 CRÍTICO
**Dependencia:** OBJ-1 + OBJ-2 completados
**Objetivo Global:** ≥80% coverage global
**Objetivo HU-3.8:** ≥90% coverage módulo phase

### Síntoma
```
PHASE 7️⃣: CODE COVERAGE
▶ Coverage ≥80%
❌ Coverage ≥80%  ← AQUÍ FALLA
```

### Tareas Específicas

- [ ] **TAREA 3.1:** Generar reporte de cobertura global
  ```bash
  python -m pytest tests/server/ \
    --cov=src/server/services \
    --cov=src/server/core \
    --cov-report=term-missing \
    --cov-report=html

  # Output esperado:
  # =============== coverage: X% ===============
  # (X debe ser ≥80%)
  ```

- [ ] **TAREA 3.2:** Generar reporte específico módulo HU-3.8
  ```bash
  # Identificar archivos específicos del módulo fase
  find src/server -name "*phase*" -o -name "*progress*" | grep -E '\.py$'

  # Ejecutar coverage específico
  python -m pytest tests/server/unit/domain/test_project_phase*.py \
    --cov=src/server/services/project_phase_service \
    --cov=src/server/core/entities/project_phase \
    --cov-report=term-missing

  # Output esperado: ≥90% para estos módulos
  ```

- [ ] **TAREA 3.3:** Identificar gaps de cobertura
  ```bash
  # Revisar reporte HTML
  open htmlcov/index.html  # MacOS
  chromium htmlcov/index.html  # Linux

  # Buscar líneas sin coverage (color rojo)
  # Crear tests para esas líneas
  ```

- [ ] **TAREA 3.4:** Escribir tests adicionales si necesario
  - Si cobertura < 90%: agregar tests para:
    - Error paths (excepciones)
    - Edge cases (listas vacías, None values)
    - Branches not covered

- [ ] **TAREA 3.5:** Documentar cobertura final
  ```bash
  # Guardar reporte en doc
  python -m pytest tests/server/ \
    --cov=src/server/services \
    --cov=src/server/core \
    --cov-report=term-missing > doc/03-HU-TRACKING/HU-3.8-PROJECT-PHASE-LOGIC/COVERAGE_REPORT.txt
  ```

### Criterio de Completitud
```
✅ Global Coverage: ≥80% PASSED
✅ HU-3.8 Module Coverage: ≥90% PASSED
✅ Report documented in FINAL_SUMMARY.md
```

---

## 🟢 OBJETIVO 4: VALIDAR CRITERIOS DE ACEPTACIÓN AC-1 A AC-8

**Prioridad:** 🟡 ALTO
**Dependencia:** OBJ-1, OBJ-2, OBJ-3 completados

### Tareas Específicas

- [ ] **TAREA 4.1:** Create matriz de validación
  ```markdown
  Archivo: ACCEPTANCE_CRITERIA_VERIFICATION.md

  | AC ID | Criterio | Validación | Evidence Test | Status |
  |-------|----------|-----------|---------------|--------|
  | AC-1 | Phase model = template sequence | ✓ | test_phase_ordering | ✅ |
  | AC-2 | Mandatory artifacts validated | ✓ | test_mandatory_files | ✅ |
  ...
  ```

- [ ] **TAREA 4.2:** AC-1 Validation - Phase ordering
  - Execute: `pytest tests/server/unit/domain/test_phase_ordering.py -v`
  - Verificar: orden ROOT → 10 → 20 → 30 → 40 → 99 ✓
  - Documentar: ✅ PASA

- [ ] **TAREA 4.3:** AC-2 Validation - Mandatory artifacts
  - Execute: `pytest tests/server/unit/domain/test_mandatory_validation.py -v`
  - Verificar: cada phase bloquea si faltan obligatorios ✓
  - Documentar: ✅ PASA

- [ ] **TAREA 4.4:** AC-3 Validation - Doc N/25 calculation
  - Execute: `pytest tests/server/unit/domain/test_doc_progress.py -v`
  - Verificar: fórmula `generated_docs / 25` correcta ✓
  - Documentar: ✅ PASA

- [ ] **TAREA 4.5:** AC-4 Validation - ROOT logic
  - Execute: `pytest tests/server/unit/domain/test_root_phase.py -v`
  - Verificar: AGENTS.md + README.md obligatorios ✓
  - Documentar: ✅ PASA

- [ ] **TAREA 4.6:** AC-5 Validation - Non-ROOT completeness
  - Execute: `pytest tests/server/unit/domain/test_phase_completeness.py -v`
  - Verificar: 100% docs requeridos antes de avanzar ✓
  - Documentar: ✅ PASA

- [ ] **TAREA 4.7:** AC-6 Validation - Idempotency
  - Execute: `pytest tests/server/unit/domain/test_idempotent_transition.py -v`
  - Verificar: re-scan no duplica artefactos ✓
  - Documentar: ✅ PASA

- [ ] **TAREA 4.8:** AC-7 Validation - Error handling
  - Execute: `pytest tests/server/unit/domain/test_error_messages.py -v`
  - Verificar: errores controlados, sin stack traces ✓
  - Documentar: ✅ PASA

- [ ] **TAREA 4.9:** AC-8 Validation - Test coverage
  - Reporte: Cobertura módulo ≥90% ✓
  - Screenshot: `coverage report term-missing`
  - Documentar: ✅ PASA

### Criterio de Completitud
```
✅ Todos AC-1 a AC-8 validados
✅ Matriz ACCEPTANCE_CRITERIA_VERIFICATION.md completada
✅ Cada AC con test unit + evidence
```

---

## 🔵 OBJETIVO 5: REDACTAR DESCRIPCIÓN DE PULL REQUEST

**Prioridad:** 🟡 MEDIO
**Dependencia:** OBJ-1, OBJ-2, OBJ-3, OBJ-4 completados

### Tareas Específicas

- [ ] **TAREA 5.1:** Create template de PR
  ```markdown
  Archivo: doc/03-HU-TRACKING/HU-3.8-PROJECT-PHASE-LOGIC/PR_DESCRIPTION.md

  ## HU-3.8: Phase Logic Implementation

  ### Descripción
  Implementa motor real de fases de proyecto basado en templates,
  calculando Doc N/25 desde artefactos generados efectivamente.

  ### Cambios principales
  - `project_phase_service.dart`: Detección y validación de fases
  - `project_providers.dart`: Cálculo de progreso real
  - `project_phase_model.dart`: Dominio de representación
  - Tests de cobertura ≥90% en módulo

  ### Testing
  - ✅ Unit tests: 15 ejemplos clave
  - ✅ Integration tests: SQLite persistence
  - ✅ Coverage: 90% módulo HU-3.8
  - ✅ Manual test: Dashboard refleja progreso real

  ### Breaking Changes
  None. Backward compatible con existing ProjectShell.

  ### Checklist
  - [x] Código formateado (`black`, `dart format`)
  - [x] Tests pasan (`pytest`, `flutter test`)
  - [x] Coverage ≥90% módulo
  - [x] AC-1 a AC-8 validados
  - [x] Documentación actualizada
  ```

- [ ] **TAREA 5.2:** Agregar screenshot del dashboard
  - [ ] Capturar pantalla de Project Dashboard
  - [ ] Mostrar `Doc N/25` en tiempo real
  - [ ] Guardar en `doc/03-HU-TRACKING/HU-3.8-PROJECT-PHASE-LOGIC/dashboard_screenshot.png`

- [ ] **TAREA 5.3:** Redactar resumen de cambios
  - Enumerar files modificados
  - Contar: líneas agregadas, modificadas, eliminadas
  ```bash
  git diff develop...feature/project_phase_logic \
    --stat | tail -1
  ```

- [ ] **TAREA 5.4:** Listar dependencias resueltas
  - [x] HU-3.1 (ProjectShell base)
  - [x] HU-3.2 (FileSystemService)
  - [x] Packages/knowledge_base/01-TEMPLATES

- [ ] **TAREA 5.5:** Enlazarse con roadmap
  - Referencia a issue #HU-3.8 en ROADMAP
  - Cierre automático de issue si aplica
  - Link a este document en PR

### Criterio de Completitud
```
✅ PR_DESCRIPTION.md redactada y completa
✅ Screenshots capturados y embebidos
✅ Checklist de cambios actualizada
✅ Ready para crear PR en GitHub
```

---

## 🟣 OBJETIVO 6: ACTUALIZAR FINAL_SUMMARY.md

**Prioridad:** 🟢 MEDIO
**Dependencia:** OBJ-1 a OBJ-5 completados

### Tareas Específicas

- [ ] **TAREA 6.1:** Documentar logros
  ```markdown
  ### ✅ Logros Alcanzados
  - Motor de fases 100% funcional
  - Cálculo Doc N/25 determinista
  - Cobertura tests > 90% en módulo
  - AC-1 a AC-8 validadas
  - Integración fluida con ProjectShell
  ```

- [ ] **TAREA 6.2:** Documentar deuda técnica (si aplica)
  ```markdown
  ### ⚠️ Deuda Técnica Documentada
  - [ ] Refactor Phase Registry si crece >20 fases
  - [ ] Optimizar scan filesystem si > 1000 archivos
  ```

- [ ] **TAREA 6.3:** Documentar métricas finales
  ```
  | Métrica | Valor |
  |---------|-------|
  | Tests que pasan | 60/60 |
  | Cobertura global | 85% |
  | Cobertura HU-3.8 | 92% |
  | Líneas código agregadas | ~400 |
  | Líneas test | ~800 |
  | Duración ejecución tests | ~30s |
  ```

- [ ] **TAREA 6.4:** Recomendaciones para HU nexts
  ```markdown
  ### 🚀 Próximos Pasos Recomendados
  - HU-3.9: Integración RAG con fases
  - HU-4.1: Endpoint chat con contexto de fase
  - HU-4.3: Streaming SSE
  ```

### Criterio de Completitud
```
✅ FINAL_SUMMARY.md completada con:
  - Logros alcanzados
  - Métricas finales
  - Deuda técnica
  - Recomendaciones próximas HUs
```

---

## 🟤 OBJETIVO 7: VALIDAR INTEGRACIÓN EN VIVO

**Prioridad:** 🟢 MEDIO
**Dependencia:** Todos completados excep OBJ-6

### Tareas Específicas

- [ ] **TAREA 7.1:** Lanzar app Flutter en desktop
  ```bash
  cd src/client
  flutter run -d linux
  ```

- [ ] **TAREA 7.2:** Validar ProjectShell se abre normalmente
  - [ ] App no crashea en inicio
  - [ ] Dashboard visible sin errores
  - [ ] Ningún red error logs

- [ ] **TAREA 7.3:** Validar Doc N/25 muestra valor real
  - [ ] Abre um project existente
  - [ ] Verifica Doc contador >= 0
  - [ ] Verifica phase activa correcta (ROOT, 10, 20, etc)

- [ ] **TAREA 7.4:** Test manual de transición
  - [ ] Create project test
  - [ ] Create files de phase 10
  - [ ] Refrescar UI (pull-to-refresh o button)
  - [ ] Verificar Doc N/25 incrementa
  - [ ] Verificar phase badge se actualiza

- [ ] **TAREA 7.5:** Documentar resultado
  ```
  ✅ MANUAL INTEGRATION TEST PASSED

  - App launch: OK
  - Dashboard rendering: OK
  - Doc N/25 calculation: CORRECT
  - Phase badge: UPDATING
  - No crashes: VERIFIED
  ```

### Criterio de Completitud
```
✅ App ejecuta sin errores
✅ Funcionalidad de fases visible y funcional
✅ Doc N/25 calcula correctamente
✅ Screenshots capturadas para evidencia
```

---

## 🔴 OBJETIVO 8: EJECUTAR PRE_PUSH_VALIDATION_MASTER.sh FINAL

**Prioridad:** 🔴 CRÍTICO
**Dependencia:** OBJ-1, OBJ-2, OBJ-3 completados
**Requisito para merge:** Todos checks deben pasar (exit code 0)

### Tareas Específicas

- [ ] **TAREA 8.1:** Execute validation script
  ```bash
  cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai
  ./scripts/PRE_PUSH_VALIDATION_MASTER.sh 2>&1 | tee validation_final_run.log
  ```

- [ ] **TAREA 8.2:** Verificar output esperado
  ```
  ═══════════════════════════════════════════════════════
    ✅ ALL CHECKS PASSED - READY TO PUSH
  ═══════════════════════════════════════════════════════

  Total Checks: 16
  Passed: 16 ✅
  Failed: 0

  Exit Code: 0
  ```

- [ ] **TAREA 8.3:** Si encuentra fallos, registrar
  ```bash
  # Salvar output para diagnostic
  ./scripts/PRE_PUSH_VALIDATION_MASTER.sh > validation_debug.txt 2>&1
  # Revisar qué check específico falla
  cat validation_debug.txt | grep "❌"
  ```

- [ ] **TAREA 8.4:** Resolver cualquier fallo restante
  - Ej: si `Coverage ≥80%` aún falla → volver a OBJ-3
  - Ej: si nuevo test falla → volver a OBJ-1 o OBJ-2

- [ ] **TAREA 8.5:** Documentar confirmación
  ```markdown
  ## ✅ PRE-PUSH VALIDATION FINAL APPROVAL

  Date: 2026-02-12 XX:XX
  Exit Code: 0
  Total Passed: 16/16
  Branch: feature/project_phase_logic
  Ready for: git push && create PR
  ```

### Criterio de Completitud
```
✅ PRE_PUSH_VALIDATION_MASTER.sh retorna exit code 0
✅ Todos 16 checks PASAN (#Passed: 16)
✅ Ningún check FALLA (#Failed: 0)
✅ Log guardado como evidencia
✅ READY FOR MERGE
```

---

## 📌 TABLA RESUMEN - PROGRESO

| # | Objetivo | Título | Prioridad | Dependen | Est. h | Status |
|---|----------|--------|-----------|----------|--------|--------|
| 1 | OBJ-1 | Fijar Python Unit Tests | 🔴 CRÍTICO | - | 2-4 | ⏳ TODO |
| 2 | OBJ-2 | Fijar SQLite Integration | 🔴 CRÍTICO | OBJ-1 | 2-3 | ⏳ TODO |
| 3 | OBJ-3 | Medir Cobertura ≥90% HU | 🔴 CRÍTICO | OBJ-1,2 | 1-2 | ⏳ TODO |
| 4 | OBJ-4 | Validar AC-1..AC-8 | 🟡 ALTO | OBJ-1,2,3 | 1 | ⏳ TODO |
| 5 | OBJ-5 | Redactar PR Description | 🟡 MEDIO | OBJ-1..4 | 0.5 | ⏳ TODO |
| 6 | OBJ-6 | Actualizar FINAL_SUMMARY | 🟢 MEDIO | OBJ-1..5 | 0.5 | ⏳ TODO |
| 7 | OBJ-7 | Validación Integración Viva | 🟢 MEDIO | OBJ-1..5 | 0.75 | ⏳ TODO |
| 8 | OBJ-8 | PRE_PUSH Validation Final | 🔴 CRÍTICO | OBJ-1,2,3,7 | 1 | ⏳ TODO |

**Total Estimado:** 8-15 horas (dependiendo de complejidad de problemas en OBJ-1)

---

## 🎯 ORDEN RECOMENDADO DE EJECUCIÓN

```
┌─────────────────────────────────────────────────────────────┐
│                    SECUENCIA DE EJECUCIÓN                    │
└─────────────────────────────────────────────────────────────┘

1️⃣  OBJ-1: Fijar Python Unit Tests
    ↓ (debe pasar para continuar)

2️⃣  OBJ-2: Fijar SQLite Integration Tests
    ↓ (debe pasar para continuar)

3️⃣  OBJ-3: Medir Cobertura ≥90% HU-3.8
    ↓ (debe tener ≥90% para continuar)

4️⃣  OBJ-4: Validar AC-1..AC-8 con evidencia
    ↓ (todo AC debe validar)

5️⃣  OBJ-5: Redactar descripción de PR
    ↓ (tener PR description lista)

6️⃣  OBJ-6: Actualizar FINAL_SUMMARY.md
    ↓ (opcional: puede parallelize con OBJ-7)

7️⃣  OBJ-7: Validación manual integración
    ↓ (verificar app funciona)

8️⃣  OBJ-8: Ejecutar PRE_PUSH_VALIDATION final
    ↓ (DEBE retornar exit code 0)

✅ READY: git push + create PR
```

---

## 💡 QUICK REFERENCE - COMANDOS CLAVE

```bash
# DIAGNÓSTICO RÁPIDO PYTHON TESTS
python -m pytest tests/server/unit/domain/ -v --tb=short --timeout=30

# EJECUTAR TODOS LOS TESTS
python -m pytest tests/server/ -v --tb=short

# GENERAR REPORTE COBERTURA
python -m pytest tests/server/ --cov=src/server --cov-report=term-missing --cov-fail-under=80

# COBERTURA ESPECÍFICA HU-3.8
python -m pytest tests/server/unit/domain/test_project_phase*.py --cov=services.project_phase --cov-report=term

# PRE-PUSH VALIDATION COMPLETO
./scripts/PRE_PUSH_VALIDATION_MASTER.sh

# LIMPIAR ENTORNO Y REINSTALAR
cd tests/server && python -m pip install --upgrade pytest pytest-asyncio pytest-cov --quiet
```

---

## 📞 CONTACTO / ESCALACIÓN

Si después de 2 horas en OBJ-1 no se resuelve:
1. Hacer commit de diagnóstico
2. Create issue "HU-3.8.1: Test flakiness investigation"
3. Considerar rollback a `develop` y replanificación
4. Posible: cambiar pytest->unittest nativo si es necesario

---

**Fecha Document:** 12/02/2026 22:42
**Próxima Revisión:** Después de completar OBJ-1
**Propietario:** Equipo Backend + Frontend
