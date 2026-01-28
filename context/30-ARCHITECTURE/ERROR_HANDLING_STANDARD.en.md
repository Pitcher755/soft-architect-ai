# 🚨 Error Handling Standard

> **Philosophy:** "Fail Gracefully". The user should never see a Python Stack Trace in the Flutter UI.

---

## 1. Error Catalog (Error Codes)

The Backend must return these codes in the `error_code` field of the JSON response.

| Code | Technical Description | User Message (Flutter UI) | Suggested Action |
| :--- | :--- | :--- | :--- |
| **SYS_001** | `ConnectionRefusedError` (DB/Ollama) | "I can't connect to the local brain." | Check Docker. |
| **SYS_002** | `GPU_OOM` (Out of Memory) | "Your graphics card is full." | Close other programs or switch to Cloud mode. |
| **AUTH_001** | `GroqAPIKeyMissing` | "Groq Cloud key is missing." | Go to Settings and add API Key. |
| **RAG_001** | `VectorStoreEmpty` | "The knowledge base is empty." | Run "Ingest Knowledge". |
| **RAG_002** | `ContextWindowExceeded` | "Conversation too long." | Start a new chat. |
| **VAL_001** | `PydanticValidationError` | "Invalid input data." | (Internal bug) Report issue. |

---

## 2. Backend Implementation (Python)

Use a global `ExceptionHandler` in FastAPI.

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

## 3. Frontend Implementation (Flutter)

Map codes to user-friendly error widgets.

```dart
// src/client/lib/core/error_mapper.dart
String getUserMessage(String errorCode) {
  switch (errorCode) {
    case 'SYS_001':
      return '🔌 It seems Docker is not running. Check your terminal.';
    case 'AUTH_001':
      return '🔑 You need an API Key to use Cloud mode.';
    default:
      return '🤔 Something went wrong ($errorCode).';
  }
}

```

---

## 4. Logging and Telemetry

* **User Level:** Only show the friendly message and a red/yellow icon.
* **Dev Level (Debug):** Save the full stack trace in `app.log` (local) or Docker console.