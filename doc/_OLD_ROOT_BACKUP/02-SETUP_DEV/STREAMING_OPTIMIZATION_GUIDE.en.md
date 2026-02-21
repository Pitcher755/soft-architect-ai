# 📘 Streaming Optimization Guide (HU-3.5)

> **Date:** 10/02/2026
> **Status:** ✅ COMPLETED

---

## 📖 Table of Contents

1. [Goal](#goal)
2. [Requirements](#requirements)
3. [Backend Setup](#backend-setup)
4. [Frontend Setup](#frontend-setup)
5. [Profiling & Metrics](#profiling--metrics)
6. [Acceptance Validation](#acceptance-validation)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Goal

Ensure token streaming with TTFB <200ms, 10+ tokens/sec, and 60 FPS UI
with auto-reconnect and circular buffer memory safety.

---

## ✅ Requirements

- Python 3.12.3
- Flutter 3.38.0+
- Docker (optional for local stack)

---

## ⚙️ Backend Setup

1. Install dependencies:

```bash
cd src/server
pip install -r requirements.txt
```

2. Run backend:

```bash
python -m app.main
```

3. WebSocket endpoint:

- `ws://localhost:8000/api/v1/chat/stream`

---

## 🧩 Frontend Setup

1. Install dependencies:

```bash
cd src/client
flutter pub get
```

2. Run app in profile mode:

```bash
flutter run --profile
```

---

## 📊 Profiling & Metrics

### Backend
- Chrome DevTools → Network → WS → TTFB
- `pytest-benchmark` for p95 latency

### Frontend
- Dart DevTools → Timeline → FPS
- Flutter Performance Overlay

---

## ✅ Acceptance Validation

- TTFB <200ms (p95)
- 10+ tokens/sec
- 60 FPS during streaming
- Circular buffer at 100 messages max
- Reconnect <2s

---

## 🛠️ Troubleshooting

- WebSocket fails: verify `localhost:8000` and CORS settings.
- Jank detected: confirm `RepaintBoundary` usage.
- Disconnects: validate ping/pong every 30s.
