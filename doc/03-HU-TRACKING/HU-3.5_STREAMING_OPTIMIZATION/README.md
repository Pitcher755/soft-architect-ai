# 📋 HU-3.5: Streaming & Performance Optimization

> **Historia de Usuario:** Optimización de streaming y latencia <200ms
> **Tipo:** Backend (Python)
> **Prioridad:** 🟠 HIGH
> **Estimación:** M (8 pts)
> **Rama:** `feature/streaming-optimization`
> **Estado:** 📋 PENDIENTE

---

## 📝 Descripción

### User Story

```
Como Usuario,
Quiero streaming optimizado y latencia <200ms,
Para una experiencia fluida sin esperas.
```

### Alcance

Implementar **optimizaciones de performance** con:

- ⚡ WebSocket para comunicación bidireccional
- 💾 Cache de embeddings en ChromaDB
- 📦 Compresión gzip en respuestas
- 🎯 Batch de tokens (mínimo 50ms)
- 📊 Profiling de latencia con APM

---

## ✅ Criterios de Aceptación

| # | Criterio | Status |
|---|----------|--------|
| 1 | ✅ Primer token en <200ms (medido con chrono) | ⏳ |
| 2 | ✅ WebSocket para comunicación bidireccional | ⏳ |
| 3 | ✅ Cache de embeddings en ChromaDB | ⏳ |
| 4 | ✅ Compresión gzip en respuestas HTTP | ⏳ |
| 5 | ✅ Batch de tokens: mínimo 50ms entre sends | ⏳ |
| 6 | ✅ UI no se congela durante generación (async rendering) | ⏳ |
| 7 | ❌ Cero latencia de red visible al usuario | ⏳ |

---

## 🛠️ Tareas Técnicas

| # | Tarea | Status |
|---|-------|--------|
| 1 | Implementar WebSocket en FastAPI | ⏳ |
| 2 | Optimizar queries ChromaDB (índices, batch size) | ⏳ |
| 3 | Middleware de compresión gzip | ⏳ |
| 4 | Profiling de latencia con OpenTelemetry | ⏳ |
| 5 | Tests de performance: medir latencia P95 | ⏳ |
| 6 | Cache warming de embeddings frecuentes | ⏳ |

---

## 🔗 Dependencias

### Bloqueantes
- ✅ HU-3.3: Chat Sequential Docs (requiere streaming)
- ✅ HU-3.4: Error Handling Gates (requiere handlers)

---

## 📊 Progreso: 0% (0 pts de 8)

---

**HU-3.5: STREAMING OPTIMIZATION**
**Sprint 3: Project-First Sequential Document Generation**
