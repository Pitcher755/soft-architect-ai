# 🔄 HU-5.0: Workflow de Implementación

> **Estado:** 🚧 En Progreso
> **Duración Estimada:** 7 días (88.5 horas desarrollo intensivo)
> **Target Deployment:** Homelab + Demo Cloud

---

## 📖 Tabla de Contenidos

1. [Visión General](#-visión-general)
2. [Pre-requisitos](#-pre-requisitos)
3. [Fase 1: Backend LLM Refinement](#-fase-1-backend-llm-refinement)
4. [Fase 2: Implementación 10 Reglas System Prompt](#-fase-2-implementación-10-reglas-system-prompt)
5. [Fase 3: Integración Frontend](#-fase-3-integración-frontend)
6. [Fase 4: Suite de Testing](#-fase-4-suite-de-testing)
7. [Fase 5: Actualización Knowledge Base](#-fase-5-actualización-knowledge-base)
8. [Fase 6: Deployment Homelab](#-fase-6-deployment-homelab)
9. [Fase 7: Validación Final & Demo](#-fase-7-validación-final--demo)
10. [Plan de Rollback](#-plan-de-rollback)
11. [Checklist Final](#-checklist-final)

---

## 🎯 Visión General

Este workflow implementa **refinamientos críticos** al Arquitecto IA para generar documentación de software profesional siguiendo el **Master Workflow de 24 documentos** (desde entrevista inicial hasta archivos raíz del repositorio).

### Ruta Crítica
```
Fase 1 (Backend)
    ↓
Fase 2 (System Prompt Rules) ← CRÍTICO: 10 reglas de comportamiento
    ↓
Fase 3 (Frontend Integration)
    ↓
Fase 4 (Testing) ← GATE: ≥85% cobertura backend
    ↓
Fase 5 (Knowledge Base)
    ↓
Fase 6 (Deployment Homelab) ← DEMO TFM
    ↓
Fase 7 (Validation & Video Demo)
```

**Objetivo Final:** Demostración en vivo de generación completa de proyecto (0→24 docs) en <15 minutos con IA desplegada en homelab usando Groq Cloud API.

---

## 🔧 Pre-requisitos

### Verificación de Entorno

```bash
# 1. Docker & Docker Compose
docker --version  # ≥24.0
docker compose version  # ≥v2.0

# 2. Python
python --version  # ≥3.12.3
pip list | grep -E "(fastapi|langchain|chromadb)"

# 3. Flutter
flutter --version  # ≥3.22.0
flutter doctor  # All checks pass

# 4. Groq API Key
echo $GROQ_API_KEY  # Debe devolver tu API key

# 5. Branch correcto
git branch --show-current  # feature/hu-5.0-full-workflow-refinement
```

### Variables de Entorno Requeridas

```bash
# Crear archivo .env en raíz del proyecto
cp .env.example .env

# Añadir estas variables:
GROQ_API_KEY=gsk_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
LLM_TEMPERATURE=0.6  # Nueva temperatura (antes: 0.5)
CHROMA_HOST=localhost
CHROMA_PORT=8000
```

---

## 🚀 Fase 1: Backend LLM Refinement

**Objetivo:** Ajustar creatividad del LLM y preparar infraestructura para nuevas reglas

### 1.1 Ajustar Temperatura LLM (1h)

**Archivo:** `src/server/services/llm/groq_client.py`

**Cambio:** Línea 42
```python
# ANTES (demasiado conservador)
temperature=0.5

# DESPUÉS (más creativo pero coherente)
temperature=0.6  # O 0.7 para máxima creatividad
```

**Justificación:** Crear ADR documentando decisión
```bash
# Crear Architecture Decision Record
touch context/30-ARCHITECTURE/ADR/ADR-005-LLM-TEMPERATURE-ADJUSTMENT.md
```

**Contenido sugerido del ADR:**
- **Contexto:** Respuestas actuales del LLM son demasiado conservadoras
- **Decisión:** Aumentar temperatura de 0.5 a 0.6
- **Consecuencias:** Mayor creatividad en redacción manteniendo coherencia técnica
- **Alternativas consideradas:** 0.7 (descartado por posible divagación)

**Commit:**
```bash
git add src/server/services/llm/groq_client.py context/30-ARCHITECTURE/ADR/ADR-005-*.md
git commit -m "feat(llm): Increase temperature to 0.6 for enhanced creativity

- Previously: 0.5 (too conservative)
- New value: 0.6 (balanced creativity + coherence)
- ADR-005 documents justification

Ref: HU-5.0 Phase 1"
```

---

## 🧠 Fase 2: Implementación 10 Reglas System Prompt

**Objetivo:** Implementar comportamiento estricto del Arquitecto IA (20h estimado)

### 2.1 RULE-01: Anti-Manifesto Automático (2h)

**Comportamiento:** Si prompt <50 caracteres, hacer preguntas clarificadoras

**Implementación:**

**Archivo nuevo:** `src/server/services/llm/short_prompt_detector.py`

Consultar versión detallada en: [WORKFLOW.md (English)](../../English/03-HU-TRACKING/HU-5.0-ARCHITECT-AI-REFINEMENT/WORKFLOW.md#phase-2-system-prompt-rules-implementation)

**Tests:** `tests/server/services/llm/test_short_prompt_detector.py`

**Commit:**
```bash
git add src/server/services/llm/short_prompt_detector.py tests/server/services/llm/test_short_prompt_detector.py
git commit -m "feat(llm): Implement RULE-01 Anti-Manifesto detection

- Detects prompts <50 chars
- Generates 2-3 clarifying questions
- 5 unit tests with edge cases

Ref: HU-5.0 RULE-01"
```

---

### 2.2 RULE-02: Proactividad Total (3h)

**Comportamiento:** Prohibir placeholders como `[Insert text here]`, `[TODO:]`, `TBD`

**Implementación:**

**Archivo nuevo:** `src/server/services/llm/placeholder_detector.py`

Consultar versión detallada en: [WORKFLOW.md (English)](../../English/03-HU-TRACKING/HU-5.0-ARCHITECT-AI-REFINEMENT/WORKFLOW.md#rule-02-total-proactivity-3h)

**Tests:** `tests/server/services/llm/test_placeholder_detector.py`

**Commit:**
```bash
git add src/server/services/llm/placeholder_detector.py tests/server/services/llm/test_placeholder_detector.py
git commit -m "feat(llm): Implement RULE-02 Placeholder detection

- Regex patterns for [Insert...], [TODO:], TBD
- Post-processing filter in orchestrator
- 7 unit tests with edge cases

Ref: HU-5.0 RULE-02"
```

---

### 2.3 RULE-03 a RULE-10 (15h restantes)

**Reglas Restantes:**

| Regla | Duración | Descripción Breve |
|-------|----------|-------------------|
| RULE-03 | 2h | Efecto WOW (Markdown enriquecido obligatorio) |
| RULE-04 | 2h | Limpieza `<document>` tags (solo contenido dentro) |
| RULE-05 | 2h | Dictadura directorios (todo bajo `context/` excepto `00-ROOT/`) |
| RULE-06 | 3h | Bloqueo validación (no permitir doc N+1 sin validación doc N) |
| RULE-07 | 1h | Cero prefijos robóticos (prohibir "Chat:", "Robot:") |
| RULE-08 | 2h | Obediencia plantillas (JSON debe ser parseable) |
| RULE-09 | 2h | Inyección userName (personalización dinámica) |
| RULE-10 | 1h | Flujo secuencial 24 docs (no saltos) |

**Referencia:** Para implementación detallada de cada regla, consultar [WORKFLOW.md (English)](../../English/03-HU-TRACKING/HU-5.0-ARCHITECT-AI-REFINEMENT/WORKFLOW.md#phase-2-system-prompt-rules-implementation)

---

## 💻 Fase 3: Integración Frontend

**Objetivo:** Conectar Flutter con backend refinado (5.5h estimado)

### 3.1 Inyección userName (3h)

**Archivos a modificar:**

1. **Entidad UserProfile**
   - Archivo: `src/client/lib/domain/entities/user_profile.dart`
   - Añadir campo: `final String userName;`

2. **Repositorio Chat**
   - Archivo: `src/client/lib/data/repositories/chat_repository.dart`
   - Modificar: Enviar `userName` en body del request `/chat/message`

3. **Header del Chat**
   - Archivo: `src/client/lib/presentation/widgets/chat_header.dart`
   - Mostrar: `"Hola, ${userName}!"`

**Tests:** `tests/client/data/repositories/test_username_injection.dart`

---

### 3.2 Botón "Guardar Documento" Mejorado (1.5h)

**Archivo:** `src/client/lib/presentation/widgets/document_save_button.dart`

**Mejoras:**
- Confirmación visual después de guardar (snackbar verde)
- Enviar confirmación al backend para tracking de RULE-06
- Animación de éxito

**Tests:** `tests/client/presentation/widgets/test_document_save_button.dart`

---

### 3.3 UI para Errores de Validación (1h)

**Nuevo widget:** `validation_error_dialog.dart`

**Caso de uso:** Mostrar mensaje cuando RULE-06 bloquea generación de documento:
```
❌ No puedes solicitar el Documento 05 sin validar el Documento 04.
Por favor, guarda el documento anterior antes de continuar.
```

---

## 🧪 Fase 4: Suite de Testing

**Objetivo:** Cobertura ≥85% backend, ≥80% frontend (16h estimado)

### 4.1 Unit Tests Backend (10h)

**Estructura de archivos:**
```
tests/server/services/llm/
├── test_short_prompt_detector.py      # 5 tests
├── test_placeholder_detector.py       # 7 tests
├── test_markdown_richness.py          # 4 tests
├── test_document_tag_parser.py        # 5 tests
├── test_path_validator.py             # 6 tests
├── test_validation_tracker.py         # 8 tests
├── test_robotic_prefix_filter.py      # 3 tests
├── test_template_validator.py         # 5 tests
├── test_username_injection.py         # 4 tests
└── test_workflow_sequence.py          # 6 tests
```

**Comando:**
```bash
cd tests && pytest server/services/llm/ --cov=src/server/services/llm --cov-report=html
```

**Target:** ≥85% cobertura

---

### 4.2 E2E Tests (5h)

**5 Tests E2E Críticos:**

1. **Test Flujo Completo 0→24 docs** (~50 líneas)
2. **Test Bloqueo Validación** (RULE-06)
3. **Test Inyección userName** en todos los documentos
4. **Test Detección Placeholders** (RULE-02)
5. **Test Enforcement Directorios** (RULE-05)

**Comando:**
```bash
pytest tests/server/e2e/test_full_workflow.py -v
```

---

### 4.3 Smoke Tests (1h)

**3 Smoke Tests:**
1. Health check API: `/health`
2. Conexión ChromaDB
3. LLM query básica (Groq)

---

## 📚 Fase 5: Actualización Knowledge Base

**Objetivo:** Crear 24 ejemplos reales de documentos (12h estimado)

### Estructura de Directorios

```
packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/
├── 01-INTERVIEW_EXAMPLE.md
├── 02-PROJECT_BRIEF_EXAMPLE.md
├── 03-TECH_STACK_EXAMPLE.md
├── 04-VISION_EXAMPLE.md
├── 05-PROMISE_EXAMPLE.md
├── 06-JOURNEY_MAP_EXAMPLE.md
├── 07-EXECUTIVE_SUMMARY_EXAMPLE.md
├── 08-GLOSSARY_EXAMPLE.md
├── 09-FUNCTIONAL_REQUIREMENTS_EXAMPLE.md
├── 10-NON_FUNCTIONAL_REQUIREMENTS_EXAMPLE.md
├── 11-ACCESSIBILITY_EXAMPLE.md
├── 12-SECURITY_REQUIREMENTS_EXAMPLE.md
├── 13-API_CONTRACT_EXAMPLE.md
├── 14-DATABASE_SCHEMA_EXAMPLE.md
├── 15-DOR_DOD_EXAMPLE.md
├── 16-SYSTEM_DIAGRAM_EXAMPLE.md
├── 17-ADR_EXAMPLE.md
├── 18-TECH_STACK_DETAILED_EXAMPLE.md
├── 19-DEPLOYMENT_EXAMPLE.md
├── 20-USER_STORIES_MASTER_EXAMPLE.json
├── 21-SPRINT_PLAN_EXAMPLE.md
├── 22-FIRST_SPRINT_GUIDE_EXAMPLE.md
├── 23-README_EXAMPLE.md
└── 24-CONTRIBUTING_EXAMPLE.md
```

**Requisitos por Ejemplo:**
- Cumplir las 10 reglas del system prompt
- Markdown enriquecido (RULE-03)
- Sin placeholders (RULE-02)
- Rutas de guardado correctas (RULE-05)

---

## 🏠 Fase 6: Deployment Homelab

**Objetivo:** Desplegar en homelab con Groq Cloud API (12.5h estimado)

### 6.1 Configuración Docker Homelab (6h)

**Archivo:** `infrastructure/docker-compose.homelab.yml`

Para configuración completa, consultar: [WORKFLOW.md (English)](../../English/03-HU-TRACKING/HU-5.0-ARCHITECT-AI-REFINEMENT/WORKFLOW.md#phase-6-homelab-deployment)

**Servicios:**
- Backend (FastAPI)
- ChromaDB
- Frontend (Flutter Web)
- Traefik (reverse proxy + HTTPS)

---

### 6.2 Script de Deployment (4h)

**Archivo:** `scripts/devops/deploy-homelab.sh`

**Funcionalidades:**
- Health checks
- Rollback automático
- Logs centralizados
- Pretty output con colores

**Ejecución:**
```bash
./scripts/devops/deploy-homelab.sh --api-key ${GROQ_API_KEY}
```

---

### 6.3 Testing Deployment (2.5h)

**Validaciones Post-Deployment:**
```bash
# 1. Smoke test
curl https://softarchitect.homelab.local/health

# 2. Validar HTTPS
curl -I https://softarchitect.homelab.local

# 3. Performance test
ab -n 100 -c 10 https://softarchitect.homelab.local/api/v1/chat/message

# 4. Load test
k6 run scripts/devops/load_test.js
```

---

## 🎬 Fase 7: Validación Final & Demo

**Objetivo:** Ejecutar workflow completo, grabar video, preparar presentación (25h estimado)

### 7.1 Workflow Execution (5h)

**Checklist Ejecución:**
```
□ Iniciar Docker homelab
□ Abrir Flutter app conectada a homelab
□ Iniciar nuevo proyecto
□ Ejecutar workflow completo (0→24 docs)
□ Cronometrar tiempo total (objetivo: <15 min)
□ Validar que 24 documentos se generaron correctamente
□ Verificar cumplimiento de 10 reglas del system prompt
```

---

### 7.2 Video Demo (4h)

**Script del Video (Timeline 4:30 minutos):**

| Tiempo | Contenido |
|--------|-----------|
| 0:00-0:30 | Intro: "SoftArchitect AI - Automated Project Documentation" |
| 0:30-1:00 | Mostrar homelab deployment (Docker Compose logs) |
| 1:00-2:30 | Demo en vivo: Flujo completo 0→24 docs (acelerado 2x) |
| 2:30-3:30 | Highlights de documentos generados (arquitectura, testing, deployment) |
| 3:30-4:00 | Demostración reglas (ej. inyección userName, bloqueo validación) |
| 4:00-4:30 | Conclusión + GitHub repo link |

**Herramientas:**
- OBS Studio (grabación)
- DaVinci Resolve (edición)
- Formato: 1080p MP4

---

### 7.3 Presentación TFM (4h)

**Estructura Presentación (15 slides):**

1. **Portada:** Título, autor, universidad
2. **Problema:** Parálisis por análisis en ingeniería software
3. **Solución:** Arquitecto IA con workflow estructurado
4. **Arquitectura Sistema:** Diagrama Clean Architecture
5. **10 Reglas System Prompt:** Tabla resumen
6. **Master Workflow:** 24 documentos en 6 fases
7. **Stack Tecnológico:** Flutter + Python + Groq + ChromaDB
8. **Deployment Homelab:** Infraestructura Proxmox
9. **Demo en Vivo:** Screenshots del video
10. **Testing & QA:** Cobertura ≥85%, E2E tests
11. **Resultados:** Métricas de éxito (tiempo, coherencia)
12. **Lecciones Aprendidas:** Challenges técnicos
13. **Trabajo Futuro:** Variante web, CI/CD, multilingüe
14. **Conclusiones:** Impacto en productividad
15. **Preguntas:** QR code repo GitHub

---

### 7.4 Ensayo Presentación (2h)

**Checklist Ensayo:**
- Cronometrar presentación (<10 minutos)
- Practicar transiciones entre slides
- Preparar respuestas a preguntas frecuentes
- Validar funcionamiento demo en vivo (backup video si falla red)

---

## ⚠️ Plan de Rollback

### Estrategia de Rollback

**Si falla Deployment Homelab:**
```bash
# 1. Rollback a commit anterior
git checkout feature/rag-llm-resilience
git branch -D feature/hu-5.0-full-workflow-refinement

# 2. Restaurar configuración Docker
cp infrastructure/docker-compose.yml.backup infrastructure/docker-compose.yml

# 3. Reiniciar stack
./scripts/devops/stop_stack.sh
./scripts/devops/start_stack.sh
```

**Si falla Testing (<85% cobertura):**
- Identificar gaps de cobertura: `pytest --cov --cov-report=html`
- Añadir tests faltantes iterativamente
- No mergear a `develop` hasta alcanzar target

### Mitigación de Riesgos

| Riesgo | Mitigación |
|--------|------------|
| **Groq API rate limits** | Implementar mocking para tests unitarios |
| **Deployment fallos SSL** | Usar certificados auto-firmados para testing local |
| **Frontend no conecta a backend** | Validar CORS y networking Docker |

---

## ✅ Checklist Final

### Pre-Deployment
- [ ] 10/10 reglas del system prompt implementadas
- [ ] 53 tests unitarios pasando
- [ ] 5 tests E2E pasando
- [ ] Cobertura backend ≥85%
- [ ] Cobertura frontend ≥80%
- [ ] 24 ejemplos knowledge base actualizados

### Deployment
- [ ] `docker-compose.homelab.yml` configurado
- [ ] `GROQ_API_KEY` inyectada vía secrets
- [ ] Health checks funcionando
- [ ] HTTPS certificado válido
- [ ] Logs centralizados

### Validación
- [ ] Flujo completo 0→24 docs ejecutado exitosamente
- [ ] Tiempo total <15 minutos
- [ ] Documentos cumplen 10 reglas del system prompt
- [ ] Video demo grabado y editado
- [ ] Presentación TFM lista (15 slides)

### Documentation
- [ ] README.md actualizado
- [ ] CHANGELOG.md actualizado
- [ ] ADRs creados para decisiones técnicas
- [ ] Documentación bilingüe (English + Español)

---

## 📊 Métricas de Éxito

| Métrica | Target | Medición |
|---------|--------|----------|
| **Cobertura Backend** | ≥85% | `pytest --cov` |
| **Cobertura Frontend** | ≥80% | `flutter test --coverage` |
| **Tests Unitarios** | 53+ pasando | `pytest tests/server/ -v` |
| **Tests E2E** | 5+ pasando | `pytest tests/server/e2e/ -v` |
| **Tiempo Workflow** | <15 min | Cronometrado en demo en vivo |
| **Latencia API** | <200ms | `ab -n 100` promedio |
| **Uptime Homelab** | >99% | Monitoring 7 días |

---

**🎯 Status:** 🚧 En Progreso
**📅 Target Completion:** 2026-02-28
**👤 Owner:** Equipo Desarrollo + Agente ArchitectZero

---

## 📖 Referencias

- [README.md (English)](../../English/03-HU-TRACKING/HU-5.0-ARCHITECT-AI-REFINEMENT/README.md) - Especificación completa
- [PROGRESS.md (Español)](./PROGRESS.md) - Tracking de progreso
- [WORKFLOW.md (English)](../../English/03-HU-TRACKING/HU-5.0-ARCHITECT-AI-REFINEMENT/WORKFLOW.md) - Workflow detallado con código
