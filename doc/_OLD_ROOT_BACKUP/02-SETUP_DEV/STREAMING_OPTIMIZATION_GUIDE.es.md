# 📘 Guía de Optimización de Streaming (HU-3.5)

> **Fecha:** 10/02/2026
> **Estado:** ✅ COMPLETADO

---

## 📖 Tabla de Contenidos

1. [Objetivo](#objetivo)
2. [Requisitos](#requisitos)
3. [Configuración Backend](#configuración-backend)
4. [Configuración Frontend](#configuración-frontend)
5. [Profiling y Métricas](#profiling-y-métricas)
6. [Validación de Criterios](#validación-de-criterios)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Objetivo

Asegurar streaming de tokens con TTFB <200ms, 10+ tokens/seg y UI a 60 FPS
con reconexión automática y buffer circular.

---

## ✅ Requisitos

- Python 3.12.3
- Flutter 3.38.0+
- Docker (opcional para stack local)

---

## ⚙️ Configuración Backend

1. Instalar dependencias:

```bash
cd src/server
pip install -r requirements.txt
```

2. Ejecutar el backend:

```bash
python -m app.main
```

3. Verificar endpoint WebSocket:

- `ws://localhost:8000/api/v1/chat/stream`

---

## 🧩 Configuración Frontend

1. Instalar dependencias:

```bash
cd src/client
flutter pub get
```

2. Ejecutar app en modo profile:

```bash
flutter run --profile
```

---

## 📊 Profiling y Métricas

### Backend
- Chrome DevTools → Network → WS → TTFB
- `pytest-benchmark` para latencia p95

### Frontend
- Dart DevTools → Timeline → FPS
- Flutter Performance Overlay

---

## ✅ Validación de Criterios

- TTFB <200ms (p95)
- 10+ tokens/seg
- 60 FPS durante streaming
- Buffer circular con 100 mensajes max
- Reconexión <2s

---

## 🛠️ Troubleshooting

- Si no conecta WebSocket: verificar `localhost:8000` y CORS.
- Si hay jank: revisar uso de `RepaintBoundary` en widgets.
- Si hay desconexiones: validar ping/pong cada 30s.
