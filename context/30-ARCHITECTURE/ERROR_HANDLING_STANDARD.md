# 🚨 Estándar de Gestión de Errores

> **Filosofía:** "Fail Gracefully". El usuario nunca debe ver un Stack Trace de Python en la UI de Flutter.

---

## 1. Catálogo de Errores (Error Codes)

El Backend debe devolver estos códigos en el campo `error_code` del JSON de respuesta.

| Código | Descripción Técnica | Mensaje al Usuario (Flutter UI) | Acción Sugerida |
| :--- | :--- | :--- | :--- |
| **SYS_001** | `ConnectionRefusedError` (DB/Ollama) | "No puedo conectar con el cerebro local." | Verificar Docker. |
| **SYS_002** | `GPU_OOM` (Out of Memory) | "Tu tarjeta gráfica está llena." | Cerrar otros programas o cambiar a modo Cloud. |
| **AUTH_001** | `GroqAPIKeyMissing` | "Falta la clave de Groq Cloud." | Ir a Configuración y añadir API Key. |
| **RAG_001** | `VectorStoreEmpty` | "La base de conocimiento está vacía." | Ejecutar "Ingestar Conocimiento". |
| **RAG_002** | `ContextWindowExceeded` | "Conversación demasiado larga." | Iniciar un nuevo chat. |
| **VAL_001** | `PydanticValidationError` | "Datos de entrada inválidos." | (Bug interno) Reportar issue. |

---

## 2. Implementación en Backend (Python)

Usar un `ExceptionHandler` global en FastAPI.

```python
# src/server/core/exceptions.py
from fastapi.responses import JSONResponse

async def global_exception_handler(request, exc):
    if isinstance(exc, OutOfMemoryError):
        return JSONResponse(
            status_code=503,
            content={
                "status": "error",
                "code": "SYS_002",
                "message": "VRAM Exhausted"
            }
        )

```

---

## 3. Implementación en Frontend (Flutter)

Mapear códigos a Widgets de error amigables.

```dart
// src/client/lib/core/error_mapper.dart
String getUserMessage(String errorCode) {
  switch (errorCode) {
    case 'SYS_001':
      return '🔌 Parece que Docker no está corriendo. Revisa tu terminal.';
    case 'AUTH_001':
      return '🔑 Necesitas una API Key para usar el modo Nube.';
    default:
      return '🤔 Algo salió mal ($errorCode).';
  }
}

```

---

## 4. Logging y Telemetría

* **Nivel Usuario:** Solo mostrar el mensaje amigable y un icono rojo/amarillo.
* **Nivel Dev (Debug):** Guardar el stack trace completo en `app.log` (local) o consola de Docker.
