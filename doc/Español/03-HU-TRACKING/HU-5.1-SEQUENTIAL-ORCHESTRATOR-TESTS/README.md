# HU-5.1-05 — Tests de Integración del SequentialOrchestrator

> **Fecha:** 31/03/2026
> **Estado:** ✅ Completado
> **Rama:** `feature/hu-5.1-sequential-orchestrator-integration-tests`
> **Ticket Linear:** [PIT-142](https://linear.app/pitcherdev/issue/PIT-142)

## 📖 Tabla de Contenidos

1. [Resumen](#resumen)
2. [Motivación](#motivaci%C3%B3n)
3. [Implementación](#implementaci%C3%B3n)
4. [Suite de Tests](#suite-de-tests)
5. [Cobertura](#cobertura)
6. [Archivos Modificados](#archivos-modificados)

---

## Resumen

Esta Historia de Usuario refuerza la cobertura de tests de integración para el
`SequentialOrchestrator` — el servicio principal de producción que orquesta la
generación secuencial de los 24 documentos de arquitectura (el Master Workflow 0→100).

El archivo de tests de integración cubre el gap identificado en la auditoría:
`tests/server/integration/services/rag/` estaba completamente vacío (solo
`__init__.py`), mientras que `tests/server/e2e/test_full_workflow_e2e.py`
apuntaba al **legacy** `RAGOrchestrator` en lugar del `SequentialOrchestrator`.

---

## Motivación

**Gap descubierto:** No existían tests de integración para `SequentialOrchestrator`.

| Riesgo | Descripción |
|--------|-------------|
| Fallos silenciosos en CI | `continue-on-error: true` en CI para integration tests |
| Cobertura E2E errónea | Los tests E2E apuntaban a `RAGOrchestrator` (obsoleto) |
| Sin validación cross-phase | Nada validaba la state machine de 24 pasos de extremo a extremo |
| Sin cobertura de resiliencia | Las rutas de fallo del dual RAG channel no estaban testeadas |

---

## Implementación

**Archivos nuevos:**

- `tests/server/integration/services/rag/conftest.py` — Parches del SDK de Google
  (replica el patrón de `tests/server/services/rag/conftest.py`, requerido porque
  pytest no propaga conftest.py entre directorios no-ancestros).

- `tests/server/integration/services/rag/test_sequential_orchestrator_integration.py`
  — 19 tests de integración (12 de PIT-142 + 1 adicional para `get_step_by_type` + 6 tests de cobertura de casos borde).

**Estrategia:** Instanciación real del `SequentialOrchestrator` con dependencias
externas completamente mockeadas (LLM client, vector store, ChromaDB per-project).
La capa de integración prueba el cableado real entre el orquestador, `MASTER_WORKFLOW`,
`CONTEXT_DEPENDENCIES`, `WorkflowInjector`, y el pipeline dual de canales RAG.

---

## Suite de Tests

| # | Nombre del test | Escenario |
|---|-----------------|-----------|
| 1 | `test_full_24_document_generation_flow` | Los 24 doc_types del MASTER_WORKFLOW producen tokens |
| 2 | `test_state_transitions_between_phases` | `get_next_step()` encadena las 6 fases correctamente |
| 3 | `test_get_step_by_type_returns_correct_step_for_all_24_types` | `get_step_by_type()` resuelve los 24 tipos |
| 4 | `test_llm_error_at_step_14_does_not_corrupt_orchestrator_state` | LLMError en DESIGN_SYSTEM, recuperación en la siguiente llamada |
| 5 | `test_llm_timeout_does_not_corrupt_project_history` | TimeoutError mid-stream → LLMError, instancia sobrevive |
| 6 | `test_chromadb_connection_failure_graceful_degradation` | ConnectionError → tokens siguen llegando |
| 7 | `test_rag_retrieval_failure_does_not_block_generation` | VectorStoreError en ambos canales → generación continúa |
| 8 | `test_rag_context_accumulates_across_phases` | chat_history inyectado como `<conversation_history>` |
| 9 | `test_context_dependencies_graph_respected` | Grafo CONTEXT_DEPENDENCIES: completo, válido, raíces acíclicas |
| 10 | `test_prompt_hard_cap_not_exceeded` | Entrada 4× oversized truncada silenciosamente a `_MAX_PROMPT_CHARS` |
| 11 | `test_generate_produces_streaming_tokens` | 10 tokens generados en orden exacto, WorkflowInjector llamado una vez |
| 12 | `test_dual_rag_channel_injection` | Ambas etiquetas `<rag_context>` y `<retrieved_context>` en el prompt |
| 13 | `test_concurrent_generate_calls_do_not_interfere` | `gather()` paralelo produce streams independientes |
| 14 | `test_empty_injection_block_falls_back_gracefully` | Inyector vacío → fallback solo RAG |
| 15 | `test_extract_docs_text_empty_result_produces_no_rag_context` | Consulta vacía → sin bloque `<rag_context>` en el prompt |
| 16 | `test_extract_docs_text_flat_string_docs_included_in_context` | Docs de cadena plana añadidos via rama `flat.append` |
| 17 | `test_project_store_empty_chunks_produces_no_retrieved_context` | Chunks vacíos → sin bloque `<retrieved_context>` en el prompt |
| 18 | `test_build_project_documents_block_budget_and_truncation` | Casos borde de presupuesto y truncación por documento |
| 19 | `test_history_long_user_message_is_truncated_in_prompt` | Mensaje de usuario >1000 chars → `[text truncated]` |

**Resultado:** ✅ 19/19 passed in 0.13s

---

## Cobertura

Los tests de integración ahora cubren:

- ✅ Pipeline completo de generación 0→24 documentos
- ✅ Transiciones de fase del MASTER_WORKFLOW (las 6 fases)
- ✅ Resiliencia: Fallos LLM (RuntimeError, asyncio.TimeoutError)
- ✅ Resiliencia: Fallos de almacenamiento (ConnectionError, VectorStoreError)
- ✅ Canal RAG dual (KB global + ChromaDB por proyecto)
- ✅ Protección prompt hard-cap (200K chars)
- ✅ Integridad del grafo de dependencias de contexto
- ✅ Seguridad de concurrencia
- ✅ Fallback de inyección vacía (ruta solo RAG)
- ✅ Caso borde: resultado vacío en `_extract_docs_text` → sin bloque `<rag_context>`
- ✅ Caso borde: docs de cadena plana añadidos en `<rag_context>`
- ✅ Caso borde: chunks vacíos en project store → sin bloque `<retrieved_context>`
- ✅ Presupuesto de construcción de prompt y truncación por documento
- ✅ Truncación de mensajes de usuario largos en historial (`[text truncated]`)

---

## Archivos Modificados

```
tests/server/integration/services/rag/
├── conftest.py                              [NUEVO] Parches SDK Google
└── test_sequential_orchestrator_integration.py  [NUEVO] 19 tests de integración
```
