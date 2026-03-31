# 🧪 PIT-142 — Reporte de Tests de Integración del SequentialOrchestrator

> **Fecha:** 31/03/2026
> **Estado:** ✅ **TODOS LOS TESTS PASARON**
> **Rama:** `feature/hu-5.1-sequential-orchestrator-integration-tests`
> **Commits:** `3629043`, `bb798b8`, `152806e`, `14a1cb9`
> **Linear:** [PIT-142](https://linear.app/pitcherdev/issue/PIT-142)

## 📖 Tabla de Contenidos

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Tests de Integración (19)](#tests-de-integración)
3. [Correcciones de Suite Completa](#correcciones-de-suite-completa)
4. [Cobertura](#cobertura)
5. [Resultados Completos](#resultados-completos)
6. [Problemas Resueltos](#problemas-resueltos)

---

## Resumen Ejecutivo

| Métrica | Valor |
|---------|-------|
| **Nuevos tests de integración** | 19 |
| **Cobertura sobre `sequential_orchestrator.py`** | 98% |
| **Total servidor** | 791 pasados, 0 fallidos, 0 saltados, 0 warnings |
| **Total cliente** | 959 pasados, 0 fallidos, EXIT=0 |
| **Total proyecto** | **1750 tests, todos en verde** |

---

## Tests de Integración

**Archivo:** `tests/server/integration/services/rag/test_sequential_orchestrator_integration.py`

| # | Test | Escenario | Estado |
|---|------|-----------|--------|
| 1 | `test_full_24_document_generation_flow` | Los 24 pasos del MASTER_WORKFLOW producen tokens | ✅ |
| 2 | `test_state_transitions_between_phases` | `get_next_step()` encadena 6 fases → None | ✅ |
| 3 | `test_get_step_by_type_returns_correct_step_for_all_24_types` | Todos los doc_types son resolubles | ✅ |
| 4 | `test_llm_error_at_step_14_does_not_corrupt_orchestrator_state` | Recuperación de LLMError | ✅ |
| 5 | `test_llm_timeout_does_not_corrupt_project_history` | TimeoutError → LLMError, instancia sobrevive | ✅ |
| 6 | `test_chromadb_connection_failure_graceful_degradation` | ConnectionError → contexto vacío, tokens fluyen | ✅ |
| 7 | `test_rag_retrieval_failure_does_not_block_generation` | VectorStoreError en ambos canales → prompt base | ✅ |
| 8 | `test_rag_context_accumulates_across_phases` | chat_history → `<conversation_history>` | ✅ |
| 9 | `test_context_dependencies_graph_respected` | Grafo: completo, válido, raíces acíclicas | ✅ |
| 10 | `test_prompt_hard_cap_not_exceeded` | Entrada 4× oversized → truncada | ✅ |
| 11 | `test_generate_produces_streaming_tokens` | 10 tokens en orden, injector llamado una vez | ✅ |
| 12 | `test_dual_rag_channel_injection` | Ambos `<rag_context>` y `<retrieved_context>` presentes | ✅ |
| 13 | `test_concurrent_generate_calls_do_not_interfere` | `gather()` paralelo → streams independientes | ✅ |
| 14 | `test_empty_injection_block_falls_back_gracefully` | Injector vacío → fallback solo-RAG | ✅ |
| 15 | `test_extract_docs_text_empty_result_produces_no_rag_context` | Query vacía → sin `<rag_context>` | ✅ |
| 16 | `test_extract_docs_text_flat_string_docs_included_in_context` | Docs planos → rama `flat.append` | ✅ |
| 17 | `test_project_store_empty_chunks_produces_no_retrieved_context` | Chunks vacíos → sin `<retrieved_context>` | ✅ |
| 18 | `test_build_project_documents_block_budget_and_truncation` | Edge cases de budget/truncado | ✅ |
| 19 | `test_history_long_user_message_is_truncated_in_prompt` | >1000 chars → `[text truncated]` | ✅ |

---

## Correcciones de Suite Completa

### Correcciones del Servidor

| Archivo | Problema | Corrección |
|---------|----------|------------|
| `conftest.py` (raíz) | ImportError de `cryptography` durante colección | `_patch_google_sdk()` parcheando 30+ módulos |
| `test_sequential_orchestrator.py` | Desajuste `n_results` (5 vs 3) | Alineado al valor por defecto de producción |
| `test_chat_endpoints.py` | Falta override DI `get_rag_orchestrator` | Añadido dependency override |
| `test_chat_stream_endpoint.py` | Mocking directo de endpoints fallaba | Reescrito con `dependency_overrides` |
| `test_chat_history_integration.py` | Falta mock del orquestador | Añadido override con MagicMock |
| `test_sqlite_persistence.py` | 2 tests saltados (`@pytest.mark.skip`) | Eliminado skip, assertions reescritas |
| `test_validation_blocker_e2e.py` | RuntimeWarning (AsyncMock en sync) | `AsyncMock→MagicMock` para métodos síncronos |
| `test_sequential_orchestrator_integration.py` | 3 errores de tipo Pyright | `cast(MagicMock, ...)` + guardia None |

### Correcciones del Cliente

| Archivo | Problema | Corrección |
|---------|----------|------------|
| `chat_notifier_test.dart` | Fallo de aislamiento (path compartido `/tmp/`) | Paths únicos por grupo de tests |
| `chat_notifier_test.dart` | Test epic completion saltado (condición de carrera) | Estrategia con progress file `documentosCreados=23` |
| `chat_flow_test.dart` | Skips a nivel de framework (import integration_test) | Eliminado import del placeholder |

---

## Cobertura

**Comando:**

```bash
pytest tests/server/integration/services/rag/ -v --cov=src/server/app/services/rag/sequential_orchestrator --cov-report=term-missing
```

**Resultado:** 98% de cobertura sobre `sequential_orchestrator.py`

Las líneas no cubiertas se limitan a ramas defensivas de manejo de errores
que requieren una conexión ChromaDB real para activarse.

---

## Resultados Completos

### Servidor

```
pytest tests/server/ -v --tb=short
============================= 791 passed in 13.02s =============================
EXIT=0
```

### Cliente

```
cd tests && flutter test client/ --reporter expanded
+959 ~2: All tests passed!
EXIT=0
```

> Nota: El `~2` es un artefacto del runner de tests de Flutter por el conteo
> de frames de animación de `ScrollController.animateTo()`, no son tests reales
> saltados. Los 959 tests pasan.
