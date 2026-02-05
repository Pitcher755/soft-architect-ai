# HU-3.2: Streaming API Connection

**Estado:** ❌ PENDIENTE
**Prioridad:** Critical
**Estimación:** XL (Extra Large)
**Branch:** feature/ui-api-connection

## Descripción

Como Usuario, quiero recibir la respuesta de la IA en tiempo real (Streaming), para reducir la sensación de espera.

## Criterios de Verificación

- ❌ Al enviar un mensaje, no hay bloqueo de UI (Optimistic UI).
- ❌ El texto aparece token a token vía SSE.
- ❌ El scroll baja automáticamente con nuevos mensajes.
- ❌ Si el backend falla, se muestra un mensaje amigable según `ERROR_HANDLING_STANDARD.md`.

## Tareas Técnicas

- ❌ Implementar Repositorio `ChatRepository` en Dart.
- ❌ Gestionar estado con `Riverpod` (StreamProvider).
- ❌ Conectar con endpoint `/api/v1/chat/stream`.
