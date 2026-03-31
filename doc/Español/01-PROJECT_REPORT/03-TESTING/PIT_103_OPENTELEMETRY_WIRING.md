# PIT-103 — Cableado OpenTelemetry

> **Fecha:** 21/07/2025
> **Estado:** ✅ Completado
> **Ticket:** PIT-103 — [HU-4.5] Conectar OpenTelemetry al servidor FastAPI

---

## 📖 Tabla de Contenidos

1. [Objetivo](#-objetivo)
2. [Implementación](#-implementación)
3. [Configuración](#-configuración)
4. [Resultados de Tests](#-resultados-de-tests)
5. [Archivos Modificados](#-archivos-modificados)

---

## 🎯 Objetivo

Conectar el trazado distribuido de OpenTelemetry al backend FastAPI, proporcionando generación automática de spans por petición HTTP y un ciclo de vida de apagado limpio. La telemetría se activa condicionalmente mediante la variable de entorno `OTEL_ENABLED` (por defecto: deshabilitado).

---

## 🔧 Implementación

### Módulo: `src/server/app/core/telemetry.py`

Tres funciones públicas:

| Función | Propósito |
|---------|-----------|
| `setup_telemetry(app)` | Configura TracerProvider + OTLPSpanExporter (gRPC) + FastAPIInstrumentor. No-op cuando está deshabilitado. |
| `get_tracer(name)` | Devuelve un tracer OTel para spans personalizados, o un MagicMock no-op cuando está deshabilitado. |
| `shutdown_telemetry()` | Vacía spans pendientes y apaga el TracerProvider de forma ordenada. |

**Decisiones de diseño:**
- **Imports lazy** dentro de cada función para evitar ImportError en entornos de test donde los paquetes OTel están mockeados.
- **Degradación elegante** — ImportError y excepciones genéricas se capturan y loguean, nunca se propagan.
- **Patrón no-op** — Cuando `OTEL_ENABLED=False`, todas las funciones retornan inmediatamente sin overhead.

### Cableado en `main.py`

```python
# En el handler lifespan:
setup_telemetry(app)    # Antes de startup_event()
yield
shutdown_telemetry()    # Antes de shutdown_event()
```

---

## ⚙️ Configuración

Tres nuevos settings en `src/server/app/core/config.py`:

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| `OTEL_ENABLED` | `bool` | `False` | Habilitar/deshabilitar telemetría |
| `OTEL_SERVICE_NAME` | `str` | `"softarchitect-ai"` | Nombre del servicio en spans |
| `OTEL_EXPORTER_ENDPOINT` | `str` | `"localhost:4317"` | Endpoint del colector OTLP gRPC |

Para habilitar en `.env`:
```env
OTEL_ENABLED=true
OTEL_EXPORTER_ENDPOINT=localhost:4317
```

---

## 🧪 Resultados de Tests

**8 unit tests** — todos pasando:

| Test | Escenario |
|------|-----------|
| `test_setup_disabled_is_noop` | No-op cuando OTEL_ENABLED=False |
| `test_setup_enabled_configures_provider` | TracerProvider + exporter + instrumentor cableados |
| `test_setup_handles_import_error` | ImportError capturado elegantemente |
| `test_get_tracer_disabled_returns_mock` | Retorna MagicMock cuando deshabilitado |
| `test_get_tracer_enabled_returns_real_tracer` | Delega a opentelemetry.trace |
| `test_shutdown_disabled_is_noop` | No-op cuando deshabilitado |
| `test_shutdown_enabled_calls_provider_shutdown` | Llama provider.shutdown() |
| `test_shutdown_handles_exception` | RuntimeError capturado elegantemente |

---

## 📁 Archivos Modificados

| Archivo | Cambio |
|---------|--------|
| `src/server/app/core/telemetry.py` | **Nuevo** — Setup OTel, tracer, shutdown |
| `src/server/app/core/config.py` | Añadidos 3 settings OTEL_* |
| `src/server/app/main.py` | Cableado setup_telemetry/shutdown_telemetry en lifespan |
| `tests/server/unit/app/core/test_telemetry.py` | **Nuevo** — 8 unit tests |
