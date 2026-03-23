# ADR-002: Estrategia de Inyección de Contexto LLM en Generación Secuencial de Documentos

> **Fecha:** 16 de marzo de 2026
> **Estado:** ✅ Aceptado
> **Contexto:** "Operación Raíles" — flujo de generación secuencial de 24 documentos
> **Responsables:** ArchitectZero, Equipo de Desarrollo

---

## 📋 Tabla de Contenidos

1. [Contexto del Problema](#-contexto-del-problema)
2. [Opciones Consideradas](#-opciones-consideradas)
3. [Decisión](#-decisión)
4. [Justificación Estratégica](#-justificación-estratégica)
5. [Consecuencias](#-consecuencias)
6. [Hoja de Ruta de Implementación](#-hoja-de-ruta-de-implementación)

---

## 🔍 Contexto del Problema

Durante la ejecución secuencial del flujo de 24 documentos ("Operación Raíles"), inyectar
el **contexto completo del proyecto** en cada prompt del LLM provoca un
**desbordamiento de la ventana de contexto**:

```
HTTP 500 Internal Server Error (API de Gemini)
→ Primer punto de fallo: Documento 5 — USER_STORIES_MASTER
→ Causa raíz: Crecimiento lineal del payload — cada nueva petición incluye todos
  los documentos generados anteriormente como texto en bruto en el prompt.
```

### Perfil de Crecimiento (caracteres por petición)

| Doc # | Documento | Crecimiento aproximado del payload |
|-------|-----------|-----------------------------------|
| 1 | PROJECT_MANIFESTO | ~2 000 |
| 2 | DOMAIN_LANGUAGE | ~4 500 |
| 3 | USER_JOURNEY_MAP | ~8 000 |
| 4 | REQUIREMENTS_MASTER | ~14 000 |
| **5** | **USER_STORIES_MASTER** | **~22 000 → 💥 error 500** |
| … | … | … |
| 24 | RELEASE_NOTES | ~120 000+ (teórico) |

Este patrón de crecimiento es **arquitectónicamente insostenible** para el MVP.

### Restricción: Privacy-First (AGENTS.md)

El principio fundamental del proyecto es la **Soberanía del Dato** — los datos del
proyecto del usuario no deben salir del entorno local salvo autorización explícita.
Cualquier solución debe ser operable completamente en modo offline.

---

## 🗂️ Opciones Consideradas

### Opción A — Vector RAG / ChromaDB (Recuperación Semántica Dinámica)

Cada documento generado se ingesta en una colección ChromaDB aislada identificada por
`project_id`. Antes de generar el documento N, una query semántica recupera solo los chunks
más relevantes de esa colección.

**Funcionamiento:**
```
Documento generado → POST /documents/{project_id}/ingest → ChromaDB (local)
                                                              ↓
Siguiente generación → query semántica("actores flujos historias de usuario")
                     → recuperar top-K chunks (~1 500 chars)
                     → inyectar solo los fragmentos relevantes en el prompt
```

**Ventajas:**
- Footprint de tokens constante independientemente del número de documentos
  (escala al documento 24 con el mismo coste que el documento 2).
- Habilita un chat inteligente con preguntas sobre toda la documentación del proyecto.
- Soporta casos de uso futuros: "¿Qué stack tecnológico elegimos?", solicitudes de actualización de documentos.
- Totalmente compatible con el principio de Privacy-First (ChromaDB corre localmente en Docker).

**Desventajas / Riesgos para el MVP:**
- Requiere un modelo de embedding local (`sentence-transformers` ~500 MB RAM) o un endpoint de embedding de Ollama.
- `VectorStoreService` es actualmente un stub — el adaptador real de ChromaDB no está implementado.
- Introduce un pipeline de ingesta asíncrona con modos de fallo (ingesta parcial, chunks obsoletos).
- Añade complejidad arquitectónica (estrategia de chunking, ciclo de vida de colecciones, ajuste de similitud coseno).
- Estimación de implementación: 3–5 días + suite de tests dedicada.

---

### Opción B — Grafo de Dependencias Estático (Filtrado Determinista)

Se define un mapa estático `doc_type → [doc_types_requeridos]` en la capa de constantes
del dominio. El backend filtra `project_context` antes de construir el prompt del LLM —
Flutter sigue enviando todos los documentos, pero solo los 2–4 genuinamente necesarios
se inyectan por petición.

**Funcionamiento:**
```python
DEPENDENCY_GRAPH = {
    "USER_STORIES_MASTER": ["PROJECT_MANIFESTO", "REQUIREMENTS_MASTER"],
    "ARCHITECTURE_OVERVIEW": ["DOMAIN_LANGUAGE", "REQUIREMENTS_MASTER", "USER_STORIES_MASTER"],
    # ... 24 entradas
}

# En el orquestador: filtrar antes de _build_project_documents_block()
relevant = {k: v for k, v in project_context.items()
            if any(dep in k for dep in DEPENDENCY_GRAPH[doc_type])}
```

**Ventajas:**
- < 150 líneas de código, cero cambios en la infraestructura.
- 100% determinista — sin umbrales de similitud ni problemas de precisión de embeddings.
- Completamente testable con tests unitarios.
- Resuelve de inmediato el error HTTP 500 en producción.

**Desventajas:**
- El mapa estático requiere actualizaciones manuales cuando el flujo de 24 pasos evoluciona.
- No habilita el chat semántico sobre documentación del proyecto (mejora del chat bloqueada).
- El conocimiento está codificado por el ingeniero, no derivado del contenido del documento.

---

## 🎯 Decisión

**Enfoque iterativo en dos fases:**

```
Fase 1 (MVP — inmediata)          →  Opción B: Grafo de Dependencias Estático
Fase 2 (Post-lanzamiento — backlog) →  Opción A: Vector RAG / ChromaDB
```

La Opción B se implementa **ahora** como parche táctico.
La Opción A queda registrada formalmente como un **Epic técnico prioritario** para
el primer ciclo de desarrollo post-MVP.

---

## 📐 Justificación Estratégica

### 1. Time-to-Market
La Opción B es entregable en una sola sesión de trabajo con riesgo de infraestructura cero.
Garantiza un **flujo de generación de 24 documentos totalmente determinista** para la
validación con usuarios antes de invertir en infraestructura vectorial.

### 2. Gestión de Riesgos
Adoptar la Opción A de inmediato introduce tres problemas sin resolver durante la fase MVP:
- Selección y alojamiento del modelo de embedding (presupuesto RAM local vs. integración con Ollama).
- Estrategia de chunking (nivel de sección vs. párrafo vs. semántico).
- Gestión de fallos en la ingesta asíncrona (ingesta parcial, corrupción de colecciones).

Aplazar estos problemas a un ciclo dedicado aísla el riesgo de forma apropiada.

### 3. Deuda Técnica Táctica (Decisión Consciente)
La Opción B será descartada cuando se entregue la Opción A — esto es **trabajo doble
asumido conscientemente**. Se acepta porque:
- Permite validar la calidad de los prompts y la UX de la aplicación con usuarios reales de inmediato.
- Aísla el problema de infraestructura vectorial a un sprint de ingeniería enfocado.
- El código es suficientemente pequeño (~150 líneas) para que el coste de desecharlo sea despreciable.

### 4. Coherencia Arquitectónica
Ambas opciones respetan el principio de **Clean Architecture + Hexagonal**:
la lógica de filtrado (B) o el adaptador de recuperación (A) residen en la capa de
servicios/infraestructura — la capa de dominio del prompting del LLM permanece ajena
a la implementación.

---

## 📊 Consecuencias

### Positivas
- El flujo de generación de documentos completa los 24 pasos sin errores HTTP 500.
- El prompt del sistema se mantiene dentro de los límites de tokens del nivel gratuito de Gemini.
- No se requieren cambios en el cliente Flutter ni en la infraestructura Docker.

### Negativas / Compromisos Aceptados
- El grafo de dependencias requiere mantenimiento manual cuando el flujo de 24 pasos cambia.
- La Fase 2 (Opción A) debe planificarse y presupuestarse antes del segundo ciclo de desarrollo.
- El chat con preguntas sobre la documentación del proyecto **no estará disponible** hasta que se entregue la Fase 2.

### Neutrales
- El campo `project_context` permanece en el schema `ChatRequest` — será usado por la Opción A
  como fuente de ingesta, haciendo el schema compatible hacia adelante.

---

## 🗺️ Hoja de Ruta de Implementación

### Fase 1 — Opción B (Sprint Actual)

| Tarea | Archivo | Esfuerzo |
|-------|---------|----------|
| Definir constante del grafo de dependencias | `src/server/app/domain/constants/workflow.py` | XS |
| Implementar `_filter_relevant_context()` en el orquestador | `src/server/app/services/rag/sequential_orchestrator.py` | S |
| Tests unitarios para la lógica de filtrado | `tests/server/services/rag/test_sequential_orchestrator.py` | S |
| Pasar Black + Ruff + Pyright | Todos los archivos modificados | XS |

### Fase 2 — Opción A (Epic Post-MVP)

| Tarea | Capa | Prioridad |
|-------|------|-----------|
| Implementar adaptador `ChromaDBDocumentStore` | `infrastructure/vector_store/` | P1 |
| Endpoint POST `/api/v1/documents/{project_id}/ingest` | `api/v1/` | P1 |
| Disparar ingesta al guardar documento (hook post-stream) | `chat.py` | P1 |
| Modificar orquestador para consultar colección del proyecto | `sequential_orchestrator.py` | P1 |
| Selección de modelo de embedding e integración Docker | `infrastructure/docker-compose.yml` | P2 |
| Eliminar inyección en bruto de `project_context` del prompt | `sequential_orchestrator.py` | P2 |
| Tests de integración del pipeline RAG completo | `tests/server/` | P2 |
