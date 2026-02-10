# Especificación de Métricas de Performance - HU-3.5

> **Fecha:** 10/02/2026
> **Estado:** 📝 Draft (Pre-implementación)
> **HU:** HU-3.5 - Streaming Optimization

---

## 📖 Tabla de Contenidos

1. [Latency Metrics](#1-latency-metrics)
2. [Throughput Metrics](#2-throughput-metrics)
3. [UI Performance Metrics](#3-ui-performance-metrics)
4. [Memory Management Metrics](#4-memory-management-metrics)
5. [Connection Stability Metrics](#5-connection-stability-metrics)
6. [Measurement Methodology](#6-measurement-methodology)

---

## 1. Latency Metrics

### 1.1 TTFB (Time To First Byte)
- **Target:** < 200ms (p95 percentile)
- **Definición:** Tiempo desde envío de query hasta recepción del primer token
- **Medición:** Chrome DevTools Network Waterfall
- **Prioridad:** 🔥 CRÍTICO

### 1.2 Token Latency (Inter-Token Delay)
- **Target:** < 100ms (promedio)
- **Definición:** Intervalo de tiempo entre tokens consecutivos
- **Medición:** Timestamp tracking en StreamingProvider
- **Prioridad:** 🔥 ALTA

### 1.3 Reconnection Time
- **Target:** < 2000ms (máximo)
- **Definición:** Tiempo desde desconexión hasta reconexión exitosa
- **Medición:** Logging de eventos en WebSocketClient
- **Prioridad:** 🟡 MEDIA

---

## 2. Throughput Metrics

### 2.1 Token Rate
- **Target:** ≥ 10 tokens/segundo (mínimo)
- **Definición:** Número de tokens transmitidos por segundo durante streaming activo
- **Medición:** Contador de tokens / tiempo elapsed
- **Prioridad:** 🔥 CRÍTICO

### 2.2 Message Capacity
- **Target:** +500 tokens sin degradación
- **Definición:** Número máximo de tokens transmitidos en sesión sin pérdida de conexión
- **Medición:** Test de carga con mensajes largos
- **Prioridad:** 🟡 MEDIA

### 2.3 Concurrent Users
- **Target:** 10 conexiones simultáneas (MVP scope)
- **Definición:** Número de WebSocket connections activas sin degradación de servicio
- **Medición:** Stress testing con múltiples clientes
- **Prioridad:** 🟢 BAJA (futuro scaling)

---

## 3. UI Performance Metrics

### 3.1 Frame Rate
- **Target:** 60 FPS (sin drops)
- **Definición:** Frames por segundo durante rendering de mensajes streaming
- **Medición:** Dart DevTools Performance Timeline
- **Prioridad:** 🔥 CRÍTICO

### 3.2 Jank Threshold
- **Target:** 0 frames > 16.67ms
- **Definición:** Tiempo de rendering por frame (60 FPS = 16.67ms/frame)
- **Medición:** Flutter Timeline (frame analysis)
- **Prioridad:** 🔥 ALTA

### 3.3 Scroll Latency
- **Target:** < 50ms desde trigger hasta inicio de animación
- **Definición:** Tiempo desde evento de nuevo mensaje hasta inicio de auto-scroll
- **Medición:** Timestamp tracking en AutoScrollController
- **Prioridad:** 🟡 MEDIA

---

## 4. Memory Management Metrics

### 4.1 Chat History Buffer Size
- **Target:** Máx 100 mensajes en RAM
- **Definición:** Número de mensajes almacenados en buffer circular
- **Medición:** CircularBuffer.length property
- **Prioridad:** 🔥 CRÍTICO

### 4.2 Memory Growth Rate
- **Target:** < 5MB por 1000 mensajes
- **Definición:** Incremento de memoria RAM con crecimiento de chat history
- **Medición:** Dart DevTools Memory Profiler
- **Prioridad:** 🟡 MEDIA

### 4.3 Garbage Collection Pause Time
- **Target:** < 10ms (promedio)
- **Definición:** Tiempo de pausa durante GC events
- **Medición:** Dart VM GC logs
- **Prioridad:** 🟢 BAJA

---

## 5. Connection Stability Metrics

### 5.1 Uptime (Session Duration)
- **Target:** 99.5% durante sesión de 1 hora
- **Definición:** Porcentaje de tiempo con conexión activa sin desconexiones
- **Medición:** Logging de eventos de conexión/desconexión
- **Prioridad:** 🟡 MEDIA

### 5.2 Ping/Pong Interval
- **Target:** 30 segundos (fijo)
- **Definición:** Intervalo entre heartbeats para keep-alive
- **Medición:** Configuración de StreamingHandler
- **Prioridad:** 🟢 BAJA

### 5.3 Max Idle Time
- **Target:** 5 minutos antes de timeout
- **Definición:** Tiempo máximo de inactividad antes de cerrar conexión
- **Medición:** Configuración de WebSocket timeout
- **Prioridad:** 🟢 BAJA

---

## 6. Measurement Methodology

### 6.1 Backend (Python)
```bash
# Micro-benchmarks con pytest-benchmark
pytest tests/python/unit/api/websocket/test_streaming_handler.py --benchmark-only

# Profiling de handlers async
python -m aiohttp.devtools src/server/app/main.py

# Métricas en runtime
# Usar MetricsCollector para tracking continuo
```

### 6.2 Frontend (Dart)
```bash
# Performance overlay (60 FPS monitoring)
flutter run --profile --trace-startup

# Network waterfall (TTFB measurement)
# Chrome DevTools → Network → WS filter → Record

# Frame analysis
# Dart DevTools → Timeline → Record frames
```

### 6.3 Integration (E2E)
```bash
# Tests E2E con validación de métricas
pytest tests/python/integration/test_streaming_flow.py -v

flutter test tests/test/integration/features/chat/streaming_flow_test.dart
```

### 6.4 Reporting
```markdown
## Performance Report Template

### Test Environment
- OS: Ubuntu 22.04 / macOS 14
- CPU: 8 cores @ 3.0 GHz
- RAM: 16GB
- Network: LAN (1 Gbps)

### Measured Results
| Métrica | Target | Actual | Status |
|---------|--------|--------|--------|
| TTFB (p95) | <200ms | XXXms | ✅/❌ |
| Token Rate | ≥10/s | XX/s | ✅/❌ |
| Frame Rate | 60 FPS | XX FPS | ✅/❌ |

### Evidence
- Chrome DevTools Screenshot: [link]
- Dart Timeline Export: [link]
- Test Logs: [link]
```

---

## 📊 Baseline Metrics (Pre-Optimization)

> **Nota:** Estas métricas se capturarán en Fase 0 antes de implementación.

| Métrica | Baseline | Target | Gap |
|---------|----------|--------|-----|
| TTFB (p95) | TBD | <200ms | - |
| Token Rate | TBD | ≥10/s | - |
| Frame Rate | TBD | 60 FPS | - |
| Buffer Size | TBD | ≤100 msgs | - |

---

**Última Actualización:** 10/02/2026
**Próxima Revisión:** Post-Fase 0 (Baseline Capture)
