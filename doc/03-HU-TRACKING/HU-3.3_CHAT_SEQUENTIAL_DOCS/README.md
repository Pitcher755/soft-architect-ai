# 📋 HU-3.3: Chat Sequential Document Generation

> **Historia de Usuario:** Chat guiado para generar documentos secuencialmente (Doc 1-25)
> **Tipo:** Full-Stack (Frontend + Backend)
> **Prioridad:** 🔴 CRITICAL
> **Estimación:** XXL (21 pts)
> **Rama:** `feature/chat-sequential-docs`
> **Estado:** 📋 PENDIENTE

---

## 📝 Descripción

### User Story

```
Como Usuario,
Quiero un chat que me guíe secuencialmente para generar documentos (Doc 1→25),
Usando templates RAG e iteración conversacional,
Para generar de manera estructurada todos los documentos del proyecto.
```

### Alcance

Implementar el **orquestador de generación secuencial** con:

- 💬 Chat iterativo y guiado
- 📋 Generación secuencial 1-25 documentos
- 🎯 RAG 100% guiado por templates (NO generación libre)
- 💾 Persistencia de chat en BD
- ⚡ Streaming token-a-token
- 🔄 Iteración: Regenerar, Refinar, Siguiente

---

## ✅ Criterios de Aceptación

| # | Criterio | Status |
|---|----------|--------|
| 1 | ✅ Chat inicial pregunta idea/nombre proyecto y genera Doc 1 | ⏳ |
| 2 | ✅ Cada documento se guarda automáticamente en carpeta correcta | ⏳ |
| 3 | ✅ Usuario puede iterar: 'Regenerar', 'Refinar', 'Siguiente Doc' | ⏳ |
| 4 | ✅ RAG 100% guiado por templates (sin generación libre) | ⏳ |
| 5 | ✅ Barra de progreso muestra documentos completados (X/25) | ⏳ |
| 6 | ✅ Streaming de respuesta token-a-token con latencia <200ms | ⏳ |
| 7 | ✅ Persistencia de chat en BD para recuperación | ⏳ |
| 8 | ✅ Manejo de errores con retry automático | ⏳ |
| 9 | ✅ Tests de flujo: 3+ escenarios de generación secuencial | ⏳ |
| 10 | ✅ (UX) El botón de enviar (➤) se deshabilita visualmente (gris) si el campo de texto está vacío o solo tiene espacios | ⏳ |
| 11 | ✅ (UX) Los bloques de código renderizados incluyen un botón de 'Copiar' en la cabecera que guarda el contenido en el portapapeles | ⏳ |

---

## 🛠️ Tareas Técnicas

| # | Tarea | Status |
|---|-------|--------|
| 1 | Implementar `ChatSequentialDocsOrchestrator` en Backend | ⏳ |
| 2 | Crear templates RAG para Doc 1-25 en knowledge_base | ⏳ |
| 3 | Endpoint POST /api/v1/chat/sequential para iniciar generación | ⏳ |
| 4 | Endpoint POST /api/v1/chat/iterate para refinamiento | ⏳ |
| 5 | Endpoint GET /api/v1/documents/status para progreso | ⏳ |
| 6 | Gestionar estado de generación con Riverpod en Frontend | ⏳ |
| 7 | Tests E2E: usuario crea proyecto → genera 3+ documentos | ⏳ |
| 8 | Implementar `TextEditingController` listener para gestionar el estado `isEnabled` del botón de envío | ⏳ |
| 9 | Crear widget `CodeBlockHeader` con icono de copiado e integración con `Clipboard` de Flutter | ⏳ |

---

## 🔗 Dependencias

### Bloqueantes (Requiere)
- ✅ HU-3.1: Project Shell (UI)
- ✅ HU-3.2: FileSystemService (I/O)

### Contribuye a
- 🔜 HU-3.4: Error Handling Gates
- 🔜 HU-3.5: Streaming Optimization

---

## 📊 Progreso

Ver: [PROGRESS.md](PROGRESS.md)

```
Fase 0: Planificación ......................... [███░░░░░░░░░░░░░░░] 15%
Fase 1: Backend Orchestrator ................. [░░░░░░░░░░░░░░░░░░] 0%
Fase 2: Frontend Chat ........................ [░░░░░░░░░░░░░░░░░░] 0%
Fase 3: RAG Templates ........................ [░░░░░░░░░░░░░░░░░░] 0%
Fase 4: Testing & Integration ............... [░░░░░░░░░░░░░░░░░░] 0%

Progreso Total: 3% (0.63 pts de 21)
```

---

## 📦 Artefactos

Ver: [ARTIFACTS.md](ARTIFACTS.md)

**Entregables esperados:** 15+ archivos de código + 25 templates RAG

---

**HU-3.3: CHAT SEQUENTIAL DOCS**
**Sprint 3: Project-First Sequential Document Generation**
