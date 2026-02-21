# 🧪 FASE 6: End-to-End Validation (TDD GREEN)

> **Estado:** 📋 LISTA PARA INICIAR (Scaffold completado, mocks en lugar)
> **Propósito:** Verificar el flujo completo E2E con backend real
> **Estimación:** 3-4 días
> **Pruebas Coverage Target:** Backend >85%, Frontend >80%

---

## 📋 Tabla de Contenidos

1. [Manual E2E Validation Checklist](#manual-e2e-validation-checklist)
2. [Criterios de Aceptación (Definition of Ready)](#criterios-de-aceptación)
3. [Definition of Done](#definition-of-done)
4. [Guía de Pruebaing](#guía-de-pruebaing)
5. [Troubleshooting](#troubleshooting)
6. [Comandos Útiles](#comandos-útiles)
7. [Métricas de Performance](#métricas-de-performance)

---

## 🧪 Manual E2E Validation Checklist

### Pre-requisitos
```bash
# Terminal 1: Backend
cd src/server && uvicorn app.main:app --reload --log-level debug

# Terminal 2: ChromaDB
docker-compose up -d chroma

# Terminal 3: Flutter
cd src/client && flutter run -d linux
```

### ✅ Flujo 1: Creación de Proyecto

**Objetivo:** Verificar que la creación de proyecto funciona correctamente

| Paso | Verificación | Estado |
|------|--------------|--------|
| 1.1 | Click "Nuevo Proyecto" botón | [ ] |
| 1.2 | Modal dialog aparece | [ ] |
| 1.3 | Selector de carpeta funciona (click "Examinar") | [ ] |
| 1.4 | Seleccionar carpeta válida | [ ] |
| 1.5 | Nombre del proyecto: "PruebaProyecto" | [ ] |
| 1.6 | Click "Crear" botón | [ ] |
| 1.7 | Dashboard carga correctamente | [ ] |
| 1.8 | Barra de progreso muestra "Doc 1/25" | [ ] |
| 1.9 | Carpeta del proyecto se crea en disco | [ ] |
| 1.10 | Subcarpetas (10-CONTEXT, 20-REQUIREMENTS, etc.) se crean | [ ] |

**Expected Resultado:** Dashboard visible con chat listo para Doc 1

---

### ✅ Flujo 2: Chat Secuencial - Entrada de Usuario

**Objetivo:** Verificar que la entrada de usuario funciona correctamente

| Paso | Verificación | Estado |
|------|--------------|--------|
| 2.1 | Input field visible y enfocable | [ ] |
| 2.2 | Input field vacío → Botón enviar **deshabilitado** (gris) | [ ] |
| 2.3 | Escribir: "Genera el Proyecto Manifesto para un sistema de gestión de tareas" | [ ] |
| 2.4 | Botón enviar habilitado (color activo) | [ ] |
| 2.5 | Click enviar | [ ] |
| 2.6 | Input field se limpia automáticamente | [ ] |
| 2.7 | Teclado: Enter también envía mensaje | [ ] |

**Expected Resultado:** Mensaje usuario enviado exitosamente

---

### ✅ Flujo 3: Streaming de Respuesta

**Objetivo:** Verificar streaming token-a-token con indicador visual

| Paso | Verificación | Estado |
|------|--------------|--------|
| 3.1 | Mensaje usuario aparece alineado a la **derecha** | [ ] |
| 3.2 | Streaming indicator aparece (ej: "IA escribe...") | [ ] |
| 3.3 | Indicador tiene animación (ej: 3 puntos parpadeantes) | [ ] |
| 3.4 | Tokens aparecen progresivamente (efecto máquina de escribir) | [ ] |
| 3.5 | **TTFT (Time To First Token) < 200ms** (medir con chrono) | [ ] |
| 3.6 | Streaming completa en <5 segundos | [ ] |
| 3.7 | Indicador desaparece cuando streaming termina | [ ] |

**Expected Resultado:** Streaming visible y suave, <200ms TTFT

---

### ✅ Flujo 4: Propuesta (ProposalCard)

**Objetivo:** Verificar que la propuesta se renderiza correctamente

| Paso | Verificación | Estado |
|------|--------------|--------|
| 4.1 | ProposalCard aparece después de streaming | [ ] |
| 4.2 | Contenido es Markdown válido (títulos, listas, énfasis) | [ ] |
| 4.3 | Bloques de código renderizados con syntax highlighting | [ ] |
| 4.4 | **Botón "Copiar" en cabecera de cada bloque de código** | [ ] |
| 4.5 | Click en "Copiar" → contenido en clipboard (verificar Ctrl+V) | [ ] |
| 4.6 | Propuesta tiene los 3 botones: [Rechazar] [Regenerar] [Validar y Guardar] | [ ] |
| 4.7 | Botones bien espaciados y visibles | [ ] |
| 4.8 | Colores siguen Dark Mode (GitHub Dark) | [ ] |

**Expected Resultado:** ProposalCard renderizada correctamente con Markdown

---

### ✅ Flujo 5: Validación y Persistencia

**Objetivo:** Verificar que la propuesta se valida y persiste correctamente

| Paso | Verificación | Estado |
|------|--------------|--------|
| 5.1 | Click botón "Validar y Guardar" | [ ] |
| 5.2 | Toast notificación aparece: **"✅ Documentoo guardado"** | [ ] |
| 5.3 | Toast desaparece después de 3s | [ ] |
| 5.4 | Barra de progreso actualiza: "Doc 2/25" | [ ] |
| 5.5 | ProposalCard desaparece | [ ] |
| 5.6 | Abrir explorador de archivos | [ ] |
| 5.7 | Navegar a: `PruebaProyecto/context/10-CONTEXT/` | [ ] |
| 5.8 | Archivo existe: `PROJECT_MANIFESTO.md` | [ ] |
| 5.9 | Contenido del archivo **coincide exactamente** con propuesta | [ ] |
| 5.10 | Chat automáticamente pregunta por Doc 2 | [ ] |

**Expected Resultado:** Documentoo guardado correctamente en disco

---

### ✅ Flujo 6: Regeneración de Propuesta

**Objetivo:** Verificar que el botón "Regenerar" funciona correctamente

| Paso | Verificación | Estado |
|------|--------------|--------|
| 6.1 | Generar Doc 2 (respuesta cualquiera) | [ ] |
| 6.2 | Propuesta aparece | [ ] |
| 6.3 | Click botón "Regenerar" | [ ] |
| 6.4 | Streaming indicator aparece nuevamente | [ ] |
| 6.5 | Nueva propuesta aparece (contenido diferente) | [ ] |
| 6.6 | Historial del chat mantiene mensajes anteriores | [ ] |
| 6.7 | Propuesta anterior desaparece (solo la última visible) | [ ] |

**Expected Resultado:** Regeneración funciona sin perder historial

---

### ✅ Flujo 7: Rechazo de Propuesta

**Objetivo:** Verificar que el botón "Rechazar" funciona correctamente

| Paso | Verificación | Estado |
|------|--------------|--------|
| 7.1 | Generar Doc 3 (respuesta cualquiera) | [ ] |
| 7.2 | Propuesta aparece | [ ] |
| 7.3 | Click botón "Rechazar" | [ ] |
| 7.4 | Propuesta desaparece **sin guardar** | [ ] |
| 7.5 | Chat espera nueva instrucción del usuario | [ ] |
| 7.6 | Progreso sigue en "Doc 3/25" (no avanza) | [ ] |
| 7.7 | Archivo **NO se crea** en disco | [ ] |

**Expected Resultado:** Rechazo descarta propuesta sin persistencia

---

### ✅ Flujo 8: Manejo de Errores

**Objetivo:** Verificar que los errores se manejan elegantemente

| Paso | Verificación | Estado |
|------|--------------|--------|
| 8.1 | Parar backend: `Ctrl+C` en terminal del servidor | [ ] |
| 8.2 | Enviar mensaje en chat | [ ] |
| 8.3 | Error aparece en <5s: "❌ No se pudo conectar al servidor" | [ ] |
| 8.4 | Botón "Reintentar" visible | [ ] |
| 8.5 | Reiniciar backend | [ ] |
| 8.6 | Click botón "Reintentar" | [ ] |
| 8.7 | Streaming funciona correctamente | [ ] |
| 8.8 | **NO hay stack traces** mostrados al usuario | [ ] |

**Expected Resultado:** Errores manejados elegantemente sin crashes

---

## ✅ Criterios de Aceptación

### ✅ Positivos (Must Have)

| ID | Criterio | Verificación |
|----|----------|--------------|
| **P1** | Chat inicial pregunta descripción y genera 'Propuesta Doc 1' | [ ] |
| **P2** | Propuesta es temporal (NO persiste hasta 'Validar') | [ ] |
| **P3** | Botón enviar deshabilitado si campo vacío/espacios | [ ] |
| **P4** | Bloques código con botón 'Copiar' funcional | [ ] |
| **P5** | Botón 'Validar y Guardar' llama ArchivoSystemService (HU-3.2) | [ ] |
| **P6** | Streaming SSE con <200ms TTFT | [ ] |
| **P7** | Barra de progreso actualiza (Doc N/25) tras validar | [ ] |
| **P8** | Flujo 100% secuencial (nunca 2 docs paralelos) | [ ] |

### ❌ Negativos (Must NOT Have)

| ID | Criterio | Verificación |
|----|----------|--------------|
| **N1** | Documentoos NO se guardan sin clic en 'Validar' | [ ] |
| **N2** | Stack traces no aparecen en UI (errores genéricos amigables) | [ ] |
| **N3** | App no se cuelga con conexión de red inestable | [ ] |

---

## ✅ Definition of Done

### Código

- [ ] **Backend:**
  - [ ] `SequentialOrchestrator` implementado con lógica de orquestación
  - [ ] Pruebas unitarios: >85% coverage
  - [ ] Pruebas de integración: /api/v1/chat/stream funciona
  - [ ] Manejo de errores: Excepciones custom documentoadas
  - [ ] Logging: Debug logs útiles para troubleshooting

- [ ] **Frontend:**
  - [ ] `ChatNotifier` + UI Widgets con pruebas >80% coverage
  - [ ] Integración pruebas E2E pasan (chat flow completo)
  - [ ] ArchivoSystemService integrado y funcionando
  - [ ] Mock services reemplazados por servicios reales

- [ ] **Arquitectura:**
  - [ ] SSE streaming implementado correctamente
  - [ ] Manejo de state sincronizado (provider + notifier)
  - [ ] Error recovery automático (retry logic)

### Visual (Golden Kit / Screenshots)

- [ ] ProposalCard idéntico al diseño aprobado
- [ ] Dark Mode estricto (colores exactos de GitHub Dark)
- [ ] Animaciones suaves (<16ms frame time)
- [ ] Responsive layout (redimensionamiento ventana)
- [ ] Scroll behavior correcto en chat

### Funcional

- [ ] ✅ Streaming funciona (<200ms TTFT medido)
- [ ] ✅ Validación persiste correctamente (archivo explorer)
- [ ] ✅ Manejo de errores elegante (no crashes)
- [ ] ✅ Progreso se actualiza correctamente
- [ ] ✅ Regeneración y rechazo funcionan

### Documentoación

- [ ] [ ] README actualizado con instrucciones de uso
- [ ] [ ] API docs: Swagger endpoint `/api/v1/chat/stream` documentoado
- [ ] [ ] ADR (Architecture Decision Record) creado para SSE vs WebSocket
- [ ] [ ] Troubleshooting guide completado

### CI/CD & Quality

- [ ] [ ] GitHub Actions pipeline pasa
- [ ] [ ] No hay warnings de linting (Ruff, Black)
- [ ] [ ] Type checking pasa (Pyright)
- [ ] [ ] Coverage reports generados (backend + frontend)
- [ ] [ ] Pre-commit hooks pasan

---

## 📊 Guía de Pruebaing

### Backend Pruebas

```bash
cd src/server

# Unit tests con coverage
pytest tests/unit/services/rag/ \
    tests/unit/api/v1/test_chat_endpoints.py \
    -v --cov=app --cov-report=term-missing

# Solo tests de orquestador
pytest tests/unit/services/rag/test_sequential_orchestrator.py -vv

# Solo tests del endpoint SSE
pytest tests/unit/api/v1/test_chat_endpoints.py -vv

# Con profiling
pytest --profile --profile-svg
```

### Frontend Pruebas

```bash
cd tests

# Unit tests
flutter test test/unit/features/chat/ --coverage

# Widget tests
flutter test test/widget/features/chat/ --coverage

# Integration tests
flutter test test/integration/features/chat/chat_flow_test.dart -vv

# Todos los tests
flutter test --coverage

# Generar reporte HTML
genhtml coverage/lcov.info -o coverage/html
# Abrir: coverage/html/index.html
```

### Coverage Reports

```bash
# Backend coverage HTML
cd src/server
pytest --cov=app --cov-report=html
# Abrir: htmlcov/index.html

# Frontend coverage HTML
cd tests
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
# Abrir: coverage/html/index.html
```

---

## 🔧 Troubleshooting

### ❌ Problema: Streaming muy lento (>1s TTFT)

**Diagnóstico:**

```bash
# 1. Medir latencia de red
curl -w "@curl-format.txt" -o /dev/null -s \
    http://localhost:8000/api/v1/chat/generate

# 2. Profile backend en tiempo real
py-spy top --pid $(pgrep -f uvicorn)

# 3. Verificar carga de ChromaDB
docker logs chroma | grep -i "query\|embedding"

# 4. Medir tiempo de embedding
python -c "
from app.services.embeddings import EmbeddingsService
import time
svc = EmbeddingsService()
start = time.time()
embedding = svc.embed('test query')
print(f'Embedding time: {time.time() - start:.2f}s')
"
```

**Soluciones:**

1. **Calentar cache de ChromaDB:**
   ```bash
   cd src/server && python scripts/warm_cache.py
   ```

2. **Reducir tamaño del modelo de embeddings:**
   ```python
   # En core/config.py
   EMBEDDING_MODEL = "all-MiniLM-L6-v2"  # Más rápido
   # En lugar de: "all-mpnet-base-v2"
   ```

3. **Usar modelo LLM más pequeño:**
   ```bash
   # En .env
   OLLAMA_MODEL=mistral:7b  # Más rápido
   # En lugar de: mistral:13b
   ```

---

### ❌ Problema: Pruebas de integración fallan

**Diagnóstico:**

```bash
# 1. Verificar dependencias
cd tests && flutter pub get
flutter pub outdated

# 2. Ejecutar tests con output verbose
flutter test test/integration/features/chat/chat_flow_test.dart -vv

# 3. Verificar mocks
flutter test test/unit/features/chat/data/ -vv

# 4. Limpiar build
flutter clean && flutter pub get
```

**Soluciones:**

1. **Regenerar mocks (si usas mockito):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Actualizar dependencias:**
   ```bash
   flutter pub upgrade
   cd src/server && pip install -U -r requirements.txt
   ```

3. **Usar imagen de Chromedriver compatible:**
   ```yaml
   # En pubspec.yaml
   dev_dependencies:
     chromedriver: ^2.1.2
   ```

---

### ❌ Problema: ProposalCard no renderiza Markdown

**Diagnóstico:**

```bash
# 1. Verificar dependencia
cd src/client
flutter pub deps | grep markdown

# 2. Ver logs en flutter run
flutter run -d linux -v | grep -i markdown

# 3. Test widget aislado
flutter test test/widget/features/chat/widgets/proposal_card_widget_test.dart -vv
```

**Soluciones:**

1. **Reinstalar dependencia:**
   ```bash
   cd src/client
   flutter pub remove flutter_markdown
   flutter pub add flutter_markdown
   flutter pub get
   ```

2. **Verificar sintaxis Markdown:**
   ```dart
   // En test
   expect(
     find.byType(MarkdownBody),
     findsWidgets,
     reason: 'MarkdownBody debe renderizar el contenido'
   );
   ```

3. **Usar fallback si Markdown falla:**
   ```dart
   // En proposal_card_widget.dart
   Widget _buildContent() {
     try {
       return MarkdownBody(data: content);
     } catch (e) {
       logger.error('Markdown error: $e');
       return Text(content);  // Fallback a texto plano
     }
   }
   ```

---

### ❌ Problema: App se cuelga en chat

**Diagnóstico:**

```bash
# 1. Ver logs
flutter run -d linux -v 2>&1 | tee flutter_logs.txt

# 2. Perfil de memoria
flutter run --profile --trace-startup -v

# 3. Usar DevTools
flutter pub global activate devtools
devtools
# Luego acceder a http://localhost:9100

# 4. Verificar stack overflow en streaming
# (Si StringBuffer es muy grande)
```

**Soluciones:**

1. **Limitar tamaño de propuesta:**
   ```dart
   // En chat_notifier.dart
   const MAX_PROPOSAL_SIZE = 50000;  // tokens

   if (_streamBuffer.length > MAX_PROPOSAL_SIZE) {
     _streamBuffer.clear();
     _clearProposal();
     _emitError('Propuesta muy larga, rechazada');
   }
   ```

2. **Usar pagination en chat:**
   ```dart
   // Mostrar últimos 50 mensajes
   final visibleMessages = state.messages.skip(
     max(0, state.messages.length - 50)
   ).toList();
   ```

3. **Garbage collection manual:**
   ```dart
   // En disposal
   @override
   void dispose() {
     _streamBuffer.clear();
     _chatRepository = null;  // Liberar referencias
     super.dispose();
   }
   ```

---

## 📚 Comandos Útiles

### Setup & Control

```bash
# Crear rama
git checkout develop && git pull
git checkout -b feature/chat-sequential-docs

# Backend Development
cd src/server
pytest tests/unit/services/rag/ -v --cov=app
uvicorn app.main:app --reload --log-level debug

# Frontend Development
cd src/client
flutter run -d linux --debug
flutter test --coverage

# Docker Services
docker-compose up -d chroma
docker-compose logs -f chroma
docker-compose down

# Validación Completa
bash scripts/validate_hu_3_3.sh
```

### Coverage & Reports

```bash
# Backend
cd src/server
pytest --cov=app --cov-report=html --cov-report=term
open htmlcov/index.html

# Frontend
cd tests
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Debugging

```bash
# Logs detallados
flutter run -d linux -v --verbose

# Profile app
flutter run --profile --trace-startup

# Hot reload manual
R  # En flutter run

# Hot restart
Shift+R  # En flutter run

# Salir
Q  # En flutter run
```

---

## 📊 Métricas de Performance

### TTFT (Time To First Token)

```bash
cd scripts

# Script Python para medir TTFT
python measure_ttft.py \
    --endpoint http://localhost:8000/api/v1/chat/generate \
    --samples 10 \
    --prompt "Genera el Project Manifesto"

# Output esperado:
# TTFT: 150ms (±25ms)
# p95: 200ms
# p99: 250ms
```

### Memoria

```bash
# Flutter
flutter run --profile --trace-startup

# Luego en DevTools:
# 1. Abrir DevTools (URL mostrada en flutter run)
# 2. Ir a "Memory" tab
# 3. Grabar timeline
# 4. Generar doc
# 5. Verificar: <100MB por documento

# Backend
ps aux | grep uvicorn
# Verificar: RSS <500MB con 5 documentos
```

### CPU

```bash
# Durante streaming
top -p $(pgrep -f "flutter|uvicorn")

# Esperado:
# Flutter: <30% CPU
# Uvicorn: <20% CPU
```

### Benchmarks

```bash
# Crear script test_performance.py
python -c "
import time
from app.services.rag import SequentialOrchestrator

orchestrator = SequentialOrchestrator()

for doc_type in ['PROJECT_MANIFESTO', 'VISION_PROMISE', 'USER_JOURNEY']:
    start = time.time()
    stream = orchestrator.generate(
        project_id='test',
        doc_type=doc_type,
        context='test'
    )
    tokens = sum(1 for _ in stream)
    elapsed = time.time() - start
    ttft = elapsed / tokens if tokens > 0 else 0
    print(f'{doc_type}: {tokens} tokens in {elapsed:.1f}s (avg {ttft:.3f}s per token)')
"
```

---

## 🎯 Resumen de FASE 6

**Objetivo Principal:** Validar que el flujo completo E2E funciona con backend real

**Salidas Esperadas:**
- ✅ Todos los flujos de validación manual pasan
- ✅ Coverage: Backend >85%, Frontend >80%
- ✅ Performance: TTFT <200ms, memoria estable
- ✅ Documentoación completa y actualizada

**Tiempo Estimado:** 3-4 días

**Siguiente Fase:** Deployment + Release Candidacy

---

**Última actualización:** 6 febrero 2026
**Estado:** 📋 LISTA PARA INICIAR
**Rama:** feature/chat-sequential-docs
