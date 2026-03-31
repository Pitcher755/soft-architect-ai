# PIT-101 — GZipMiddleware para Compresión HTTP

> **Fecha:** 31/03/2026
> **Estado:** ✅ Completado
> **Ticket:** PIT-101 — [HU-4.5] Añadir GZipMiddleware para compresión HTTP
> **Rama:** `feature/hu-4.5-gzip-middleware`

---

## 📖 Tabla de Contenidos

- [Objetivo](#objetivo)
- [Implementación](#implementación)
- [Testing](#testing)
- [Configuración](#configuración)
- [Verificación](#verificación)

---

## 🎯 Objetivo

Añadir `GZipMiddleware` de Starlette a la aplicación FastAPI para comprimir respuestas HTTP mayores a 500 bytes. Esto reduce el uso de ancho de banda y mejora los tiempos de respuesta para clientes que soportan codificación gzip.

## 🔧 Implementación

### Archivo Modificado: `src/server/app/main.py`

**Cambios:**
1. Import añadido: `from starlette.middleware.gzip import GZipMiddleware`
2. Middleware añadido después de CORSMiddleware: `app.add_middleware(GZipMiddleware, minimum_size=500)`

### Orden del Stack de Middleware (de arriba a abajo):
1. **CORSMiddleware** — Headers de cross-origin
2. **GZipMiddleware** — Compresión HTTP (minimum_size=500 bytes)

## 🧪 Testing

### Archivo de Tests: `tests/server/integration/test_gzip_middleware.py`

| Clase de Test | Método | Aserción |
|---------------|--------|----------|
| `TestGzipMiddlewareLargeResponse` | `test_large_response_has_gzip_content_encoding` | Respuestas >500 bytes incluyen `Content-Encoding: gzip` |
| `TestGzipMiddlewareLargeResponse` | `test_large_response_body_is_valid_after_decompression` | El cuerpo comprimido se descomprime a JSON válido |
| `TestGzipMiddlewareSmallResponse` | `test_small_response_has_no_gzip_encoding` | Respuestas <500 bytes NO se comprimen |
| `TestGzipMiddlewareWithoutAcceptEncoding` | `test_identity_accept_encoding_no_gzip` | `Accept-Encoding: identity` → sin compresión |
| `TestGzipMiddlewareWebSocket` | `test_http_connection_unaffected` | Los endpoints HTTP funcionan normalmente con el middleware activo |

**Resultados:** 5/5 pasaron

### Flujo TDD Aplicado:
- **RED:** Tests escritos antes de la implementación — `test_large_response_has_gzip_content_encoding` falló (sin header `Content-Encoding`)
- **GREEN:** `GZipMiddleware` añadido a `main.py` — los 5 tests pasaron
- **REFACTOR:** Import no usado eliminado, formateado con Black, Ruff limpio

## ⚙️ Configuración

| Parámetro | Valor | Justificación |
|-----------|-------|---------------|
| `minimum_size` | 500 bytes | Evitar overhead para respuestas pequeñas (endpoint raíz ~150 bytes) |

### Comportamiento:
- **HTTP >500 bytes + `Accept-Encoding: gzip`** → Respuesta comprimida con `Content-Encoding: gzip`
- **HTTP <500 bytes** → Sin compresión (el overhead no compensa)
- **`Accept-Encoding: identity`** → Sin compresión (se respeta la preferencia del cliente)
- **WebSocket** → No afectado (GZipMiddleware solo maneja HTTP)

## ✅ Verificación

```bash
# Ejecutar tests de integración
pytest tests/server/integration/test_gzip_middleware.py -v

# Verificar formateo
black --check src/server/app/main.py
ruff check src/server/app/main.py
```
