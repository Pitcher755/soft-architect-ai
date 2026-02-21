# 📋 HU-3.4: Error Handling & Validation Gates

> **Historia de Usuario:** Manejo robusto de errores con gates de validación
> **Tipo:** Full-Stack (Python + Flutter)
> **Prioridad:** 🔥 **HIGH**
> **Estimación:** M (5 pts)
> **Rama:** `feature/error-handling-gates`
> **Estado:** 🟢 **READY FOR PHASE 0**
> **Linear Issue:** [PIT-78](https://linear.app/soft-architect-ai/issue/PIT-78)

---

<div align="center">

| [🇬🇧 English](#english) | [🇪🇸 Español](#español) |
|:---:|:---:|

</div>

---

<div id="english">

# 🇬🇧 English Version

## 📝 Descripción

### User Story

```
As a System,
I want robust error handling with validation gates and fallback logic,
To guarantee document integrity and recovery from failures.
```

### Context

After HU-3.3 (Chat Sequential Docs), we need **production-grade error handling** to ensure:
- Documentos are validated before storage
- Transient failures are automatically retried
- Users receive actionable, localized error messages
- System maintains audit trail without exposing sensitive data

### Scope

Implement **validation, retry, and recovery** with:

- ✅ **Validation Gates** (5 gates):
  1. Minimum length (>50 chars) - `VAL_001`
  2. Markdown structure - `VAL_002`
  3. UTF-8 encoding - `VAL_003`
  4. XSS pattern detection - `VAL_004`
  5. Maximum size (<5MB) - `VAL_005`

- 🔄 **Retry Logic**:
  - Decorator `@with_retry`
  - Max 3 attempts
  - Exponential backoff: 1s, 2s, 4s
  - Logs each retry with context

- ↩️ **Fallback & Rollback**:
  - Restore anterior documento version
  - Store 5 most recent versions in SQLite
  - User-triggered rollback from UI

- 🎨 **UX-Optimized Notifications**:
  - Success/Info: Auto-hide after 5s
  - Errors: Manual close required
  - Retryable errors: Show "Retry" botón
  - Localized Spanish messages

- 📝 **Comprehensive Logging**:
  - Structured JSON logs
  - Context: operation, timestamp, error_code
  - NEVER log: API keys, archivo contents, PII

---

## ✅ Acceptance Criteria

| # | Criterion | Fase | Estado |
|---|-----------|-------|--------|
| 1 | ✅ Documentos validated (length, structure, encoding, safety, size) | Fase 2 | ⏳ |
| 2 | ✅ Retry logic: 3 attempts, exponential backoff | Fase 2 | ⏳ |
| 3 | ✅ Fallback: restore anterior version on failure | Fase 2 | ⏳ |
| 4 | ✅ Snackbar UX: auto-hide 5s (success), manual (error) | Fase 2 | ⏳ |
| 5 | ✅ Error logging with context (no sensitive data) | Fase 3 | ⏳ |
| 6 | ✅ Localized errors in Spanish (11+ codes mapped) | Fase 2 | ⏳ |
| 7 | ✅ Prueba coverage >90% on gates and retry logic | Fase 1-4 | ⏳ |
| 8 | ❌ Users NEVER see stack traces | Fase 2 | ⏳ |
| 9 | ✅ Integración with HU-3.3 (Chat Sequential Docs) | Fase 4 | ⏳ |

---

## 🛠️ Technical Tasks

### Backend (Python)

| # | Task | Artifact | Lines | Estado |
|---|------|----------|-------|--------|
| 1 | Validation gates implementación | `services/validators/documento_validator.py` | ~150 | ⏳ |
| 2 | Retry decorator with backoff | `core/retry.py` | ~100 | ⏳ |
| 3 | Custom exceptions | `core/exceptions.py` (update) | ~80 | ⏳ |
| 4 | Structured logging | `core/logging_config.py` | ~60 | ⏳ |
| 5 | Unit pruebas (validators) | `pruebas/unit/services/validators/prueba_documento_validator.py` | ~200 | ⏳ |
| 6 | Unit pruebas (retry) | `pruebas/unit/core/prueba_retry.py` | ~150 | ⏳ |
| 7 | Integración pruebas | `pruebas/integration/prueba_error_handling_flow.py` | ~100 | ⏳ |

### Frontend (Flutter)

| # | Task | Artifact | Lines | Estado |
|---|------|----------|-------|--------|
| 1 | Error mapper (codes → messages) | `lib/core/error_handling/error_mapper.dart` | ~120 | ⏳ |
| 2 | Snackbar service | `lib/core/error_handling/snackbar_service.dart` | ~180 | ⏳ |
| 3 | Error context model | `lib/core/error_handling/error_context.dart` | ~40 | ⏳ |
| 4 | Unit pruebas (error mapper) | `pruebas/unit/core/error_handling/error_mapper_prueba.dart` | ~100 | ⏳ |
| 5 | Unit pruebas (snackbar) | `pruebas/unit/core/error_handling/snackbar_service_prueba.dart` | ~150 | ⏳ |
| 6 | Integración pruebas | `pruebas/integration/features/chat/error_handling_flow_prueba.dart` | ~120 | ⏳ |

### Documentoation

| # | Task | Artifact | Estado |
|---|------|----------|--------|
| 1 | Update error handling standard | `context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.md` | ⏳ |
| 2 | Crear developer guide | `doc/02-SETUP_DEV/ERROR_HANDLING_GUIDE.md` | ⏳ |
| 3 | Define validation rules | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/VALIDATION_RULES.md` | ⏳ |
| 4 | Completion summary | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/COMPLETION_SUMMARY.md` | ⏳ |

**Total Estimated Lines:** ~1,650 lines (backend + frontend + pruebas)

---

## 🔗 Dependencies

### Blocked By (Must Complete First)
- ✅ **HU-3.3:** Chat Sequential Docs (merged to develop)
- ✅ **ERROR_HANDLING_STANDARD.md:** Exists in `context/30-ARCHITECTURE/`

### Blocks (Downstream Dependencies)
- 🔄 **HU-3.5:** Streaming Optimization (requires robust error handling)

### Related Issues
- **PIT-78:** Error Handling & Validation Gates (Linear)

---

## 📚 Resources

### Reference Documentoation
- [ERROR_HANDLING_STANDARD.en.md](../../../context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md)
- [WORKFLOW_MASTER_DEFINITION.en.md](./WORKFLOW_MASTER_DEFINITION.en.md)
- [AGENTS.md](../../../AGENTS.md) - Section 8 (CI/CD Pipeline)

### Related HUs
- [HU-3.3: Chat Sequential Docs](../HU-3.3_CHAT_SEQUENTIAL_DOCS/README.md)
- [HU-3.5: Streaming Optimization](../HU-3.5_STREAMING_OPTIMIZATION/README.md)

---

## 🎯 Success Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Prueba Coverage | >90% | ⏳ 0% |
| Error Codes Mapped | 11+ | ⏳ 0 |
| Validation Gates | 5 | ⏳ 0 |
| Retry Max Attempts | 3 | ⏳ N/A |
| Snackbar Auto-Hide (Success) | 5s | ⏳ N/A |
| Snackbar Auto-Hide (Error) | ∞ (manual) | ⏳ N/A |

---

## 📅 Timeline

| Fase | Duration | Estado |
|-------|----------|--------|
| Fase 0: Preparation | 0.5 days | ⏳ Not Started |
| Fase 1: TDD RED | 1 day | ⏳ Not Started |
| Fase 2: TDD GREEN | 1 day | ⏳ Not Started |
| Fase 3: TDD REFACTOR | 0.5 days | ⏳ Not Started |
| Fase 4: Integración | 0.5 days | ⏳ Not Started |
| Fase 5: Documentoation | 0.25 days | ⏳ Not Started |
| Fase 6: CI/CD | 0.25 days | ⏳ Not Started |

**Total Estimated Time:** 3.5 - 4 days

---

## 🚀 Getting Started

### Prerequisites
```bash
# Verify HU-3.3 is merged
git log --oneline develop | grep "HU-3.3"

# Ensure on correct branch
git checkout feature/error-handling-gates
git pull origin develop
```

### Fase 0 Checklist
- [ ] Read ERROR_HANDLING_STANDARD.md
- [ ] Analyze existing error handling code
- [ ] Crear VALIDATION_RULES.md
- [ ] Setup prueba directories
- [ ] Prepare prueba fixtures

**Siguiente:** See [WORKFLOW_MASTER_DEFINITION.en.md](./WORKFLOW_MASTER_DEFINITION.en.md) for detailed execution plan.

</div>

---

<div id="español">

# 🇪🇸 Versión en Español

## 📝 Descripción

### Historia de Usuario

```
Como Sistema,
Quiero manejo robusto de errores con gates de validación y fallback logic,
Para garantizar integridad de documentos y recuperación ante fallos.
```

### Contexto

Después de HU-3.3 (Chat Sequential Docs), necesitamos **manejo de errores production-grade** para asegurar:
- Los documentoos se validan antes del almacenamiento
- Los fallos transitorios se reintentan automáticamente
- Los usuarios reciben mensajes de error accionables y localizados
- El sistema mantiene audit trail sin exponer datos sensibles

### Alcance

Implementar **validación, reintento y recuperación** con:

- ✅ **Gates de Validación** (5 gates):
  1. Longitud mínima (>50 chars) - `VAL_001`
  2. Estructura Markdown - `VAL_002`
  3. Codificación UTF-8 - `VAL_003`
  4. Detección de patrones XSS - `VAL_004`
  5. Tamaño máximo (<5MB) - `VAL_005`

- 🔄 **Lógica de Reintento**:
  - Decorador `@with_retry`
  - Máx 3 intentos
  - Backoff exponencial: 1s, 2s, 4s
  - Registra cada reintento con contexto

- ↩️ **Fallback y Rollback**:
  - Restaurar versión anterior del documentoo
  - Almacenar 5 versiones más recientes en SQLite
  - Rollback activado por el usuario desde UI

- 🎨 **Notificaciones Optimizadas para UX**:
  - Éxito/Info: Auto-ocultar después de 5s
  - Errores: Cierre manual requerido
  - Errores reintentables: Mostrar botón "Reintentar"
  - Mensajes localizados en español

- 📝 **Logging Comprehensivo**:
  - Logs estructurados JSON
  - Contexto: operation, timestamp, error_code
  - NUNCA registrar: claves API, contenidos de archivos, PII

---

## ✅ Criterios de Aceptación

| # | Criterio | Fase | Estado |
|---|----------|------|--------|
| 1 | ✅ Documentoos validados (longitud, estructura, codificación, seguridad, tamaño) | Fase 2 | ⏳ |
| 2 | ✅ Lógica de reintento: 3 intentos, backoff exponencial | Fase 2 | ⏳ |
| 3 | ✅ Fallback: restaurar versión anterior en fallo | Fase 2 | ⏳ |
| 4 | ✅ UX Snackbar: auto-ocultar 5s (éxito), manual (error) | Fase 2 | ⏳ |
| 5 | ✅ Logging de errores con contexto (sin datos sensibles) | Fase 3 | ⏳ |
| 6 | ✅ Errores localizados en español (11+ códigos mapeados) | Fase 2 | ⏳ |
| 7 | ✅ Cobertura de pruebas >90% en gates y lógica de reintento | Fases 1-4 | ⏳ |
| 8 | ❌ Los usuarios NUNCA ven stack traces | Fase 2 | ⏳ |
| 9 | ✅ Integración con HU-3.3 (Chat Sequential Docs) | Fase 4 | ⏳ |

---

## 🛠️ Tareas Técnicas

### Backend (Python)

| # | Tarea | Artefacto | Líneas | Estado |
|---|-------|-----------|--------|--------|
| 1 | Implementación de gates de validación | `services/validators/documento_validator.py` | ~150 | ⏳ |
| 2 | Decorador de reintento con backoff | `core/retry.py` | ~100 | ⏳ |
| 3 | Excepciones personalizadas | `core/exceptions.py` (actualizar) | ~80 | ⏳ |
| 4 | Logging estructurado | `core/logging_config.py` | ~60 | ⏳ |
| 5 | Pruebas unitarios (validadores) | `pruebas/unit/services/validators/prueba_documento_validator.py` | ~200 | ⏳ |
| 6 | Pruebas unitarios (reintento) | `pruebas/unit/core/prueba_retry.py` | ~150 | ⏳ |
| 7 | Pruebas de integración | `pruebas/integration/prueba_error_handling_flow.py` | ~100 | ⏳ |

### Frontend (Flutter)

| # | Tarea | Artefacto | Líneas | Estado |
|---|-------|-----------|--------|--------|
| 1 | Mapeador de errores (códigos → mensajes) | `lib/core/error_handling/error_mapper.dart` | ~120 | ⏳ |
| 2 | Servicio de snackbar | `lib/core/error_handling/snackbar_service.dart` | ~180 | ⏳ |
| 3 | Modelo de contexto de error | `lib/core/error_handling/error_context.dart` | ~40 | ⏳ |
| 4 | Pruebas unitarios (error mapper) | `pruebas/unit/core/error_handling/error_mapper_prueba.dart` | ~100 | ⏳ |
| 5 | Pruebas unitarios (snackbar) | `pruebas/unit/core/error_handling/snackbar_service_prueba.dart` | ~150 | ⏳ |
| 6 | Pruebas de integración | `pruebas/integration/features/chat/error_handling_flow_prueba.dart` | ~120 | ⏳ |

### Documentoación

| # | Tarea | Artefacto | Estado |
|---|-------|-----------|--------|
| 1 | Actualizar estándar de manejo de errores | `context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.md` | ⏳ |
| 2 | Crear guía para desarrolladores | `doc/02-SETUP_DEV/ERROR_HANDLING_GUIDE.md` | ⏳ |
| 3 | Definir reglas de validación | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/VALIDATION_RULES.md` | ⏳ |
| 4 | Resumen de completación | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/COMPLETION_SUMMARY.md` | ⏳ |

**Total Líneas Estimadas:** ~1,650 líneas (backend + frontend + pruebas)

---

## 🔗 Dependencias

### Bloqueado Por (Debe Completarse Primero)
- ✅ **HU-3.3:** Chat Sequential Docs (mergeado a develop)
- ✅ **ERROR_HANDLING_STANDARD.md:** Existe en `context/30-ARCHITECTURE/`

### Bloquea (Dependencias Downstream)
- 🔄 **HU-3.5:** Optimización de Streaming (requiere manejo robusto de errores)

### Issues Relacionados
- **PIT-78:** Error Handling & Validation Gates (Linear)

---

## 📚 Recursos

### Documentoación de Referencia
- [ERROR_HANDLING_STANDARD.es.md](../../../context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.es.md)
- [WORKFLOW_MASTER_DEFINITION.es.md](./WORKFLOW_MASTER_DEFINITION.es.md)
- [AGENTS.md](../../../AGENTS.md) - Sección 8 (Pipeline CI/CD)

### HUs Relacionadas
- [HU-3.3: Chat Sequential Docs](../HU-3.3_CHAT_SEQUENTIAL_DOCS/README.md)
- [HU-3.5: Optimización de Streaming](../HU-3.5_STREAMING_OPTIMIZATION/README.md)

---

## 🎯 Métricas de Éxito

| Métrica | Objetivo | Actual |
|---------|----------|--------|
| Cobertura de Pruebas | >90% | ⏳ 0% |
| Códigos de Error Mapeados | 11+ | ⏳ 0 |
| Gates de Validación | 5 | ⏳ 0 |
| Intentos Máx de Reintento | 3 | ⏳ N/A |
| Auto-Ocultar Snackbar (Éxito) | 5s | ⏳ N/A |
| Auto-Ocultar Snackbar (Error) | ∞ (manual) | ⏳ N/A |

---

## 📅 Cronograma

| Fase | Duración | Estado |
|------|----------|--------|
| Fase 0: Preparación | 0.5 días | ⏳ No Iniciado |
| Fase 1: TDD ROJO | 1 día | ⏳ No Iniciado |
| Fase 2: TDD VERDE | 1 día | ⏳ No Iniciado |
| Fase 3: TDD REFACTOR | 0.5 días | ⏳ No Iniciado |
| Fase 4: Integración | 0.5 días | ⏳ No Iniciado |
| Fase 5: Documentoación | 0.25 días | ⏳ No Iniciado |
| Fase 6: CI/CD | 0.25 días | ⏳ No Iniciado |

**Tiempo Total Estimado:** 3.5 - 4 días

---

## 🚀 Comenzar

### Prerequisitos
```bash
# Verificar que HU-3.3 está mergeado
git log --oneline develop | grep "HU-3.3"

# Asegurar estar en la rama correcta
git checkout feature/error-handling-gates
git pull origin develop
```

### Checklist Fase 0
- [ ] Leer ERROR_HANDLING_STANDARD.md
- [ ] Analizar código de manejo de errores existente
- [ ] Crear VALIDATION_RULES.md
- [ ] Configurar directorios de pruebas
- [ ] Preparar fixtures de pruebas

**Siguiente:** Ver [WORKFLOW_MASTER_DEFINITION.es.md](./WORKFLOW_MASTER_DEFINITION.es.md) para el plan de ejecución detallado.

</div>

---

**Última Actualización:** 09/02/2026
**Autor:** ArchitectZero
**Revisado Por:** N/A
**Estado Workflow:** 🟢 READY FOR EXECUTION
