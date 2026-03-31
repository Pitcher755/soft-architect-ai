# PIT-103 — OpenTelemetry Wiring

> **Date:** 21/07/2025
> **Status:** ✅ Complete
> **Ticket:** PIT-103 — [HU-4.5] Connect OpenTelemetry to FastAPI server

---

## 📋 Table of Contents

1. [Objective](#-objective)
2. [Implementation](#-implementation)
3. [Configuration](#-configuration)
4. [Test Results](#-test-results)
5. [Files Modified](#-files-modified)

---

## 🎯 Objective

Connect OpenTelemetry distributed tracing to the FastAPI backend, providing automatic span generation per HTTP request and a clean shutdown lifecycle. Telemetry is conditionally activated via the `OTEL_ENABLED` environment variable (default: disabled).

---

## 🔧 Implementation

### Module: `src/server/app/core/telemetry.py`

Three public functions:

| Function | Purpose |
|----------|---------|
| `setup_telemetry(app)` | Configures TracerProvider + OTLPSpanExporter (gRPC) + FastAPIInstrumentor. No-op when disabled. |
| `get_tracer(name)` | Returns an OTel tracer for custom spans, or a MagicMock no-op when disabled. |
| `shutdown_telemetry()` | Flushes pending spans and shuts down TracerProvider gracefully. |

**Design decisions:**
- **Lazy imports** inside each function to avoid ImportError in test environments where OTel packages are mocked.
- **Graceful degradation** — ImportError and generic exceptions are caught and logged, never propagated.
- **No-op pattern** — When `OTEL_ENABLED=False`, all functions return immediately with zero overhead.

### Wiring in `main.py`

```python
# In lifespan handler:
setup_telemetry(app)    # Before startup_event()
yield
shutdown_telemetry()    # Before shutdown_event()
```

---

## ⚙️ Configuration

Three new settings in `src/server/app/core/config.py`:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `OTEL_ENABLED` | `bool` | `False` | Enable/disable telemetry |
| `OTEL_SERVICE_NAME` | `str` | `"softarchitect-ai"` | Service name in spans |
| `OTEL_EXPORTER_ENDPOINT` | `str` | `"localhost:4317"` | OTLP gRPC collector endpoint |

To enable in `.env`:
```env
OTEL_ENABLED=true
OTEL_EXPORTER_ENDPOINT=localhost:4317
```

---

## 🧪 Test Results

**8 unit tests** — all passing:

| Test | Scenario |
|------|----------|
| `test_setup_disabled_is_noop` | No-op when OTEL_ENABLED=False |
| `test_setup_enabled_configures_provider` | TracerProvider + exporter + instrumentor wired |
| `test_setup_handles_import_error` | ImportError caught gracefully |
| `test_get_tracer_disabled_returns_mock` | Returns MagicMock when disabled |
| `test_get_tracer_enabled_returns_real_tracer` | Delegates to opentelemetry.trace |
| `test_shutdown_disabled_is_noop` | No-op when disabled |
| `test_shutdown_enabled_calls_provider_shutdown` | Calls provider.shutdown() |
| `test_shutdown_handles_exception` | RuntimeError caught gracefully |

---

## 📁 Files Modified

| File | Change |
|------|--------|
| `src/server/app/core/telemetry.py` | **New** — OTel setup, tracer, shutdown |
| `src/server/app/core/config.py` | Added 3 OTEL_* settings |
| `src/server/app/main.py` | Wired setup_telemetry/shutdown_telemetry in lifespan |
| `tests/server/unit/app/core/test_telemetry.py` | **New** — 8 unit tests |
