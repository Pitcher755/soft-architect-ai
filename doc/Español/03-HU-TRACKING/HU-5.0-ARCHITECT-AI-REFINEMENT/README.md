# 🎟️ HU-5.0: Refinamiento del Arquitecto IA (Era Groq) y Master Workflow Completo

> **Estado:** 🚧 En Progreso
> **Prioridad:** 🔴 Crítica
> **Estimación:** L (5-7 días desarrollo intensivo)
> **Sprint:** Sprint 5
> **Rama:** `feature/hu-5.0-full-workflow-refinement`

---

## 📋 Resumen Ejecutivo

Esta **Historia de Usuario CRÍTICA** refina el comportamiento del Arquitecto IA para entregar **documentación de ingeniería de software profesional, coherente y completa** siguiendo el Master Workflow de 24 documentos (desde visión inicial hasta archivos raíz del repositorio).

### ¿Por Qué es CRÍTICA para Presentación TFM?
- **Audiencia objetivo:** Comité académico internacional + profesionales de industria
- **Demostración requerida:** Creación de proyecto guiada por IA **production-ready** sin placeholders ni interfaz rota
- **Showcase:** Automatización de flujo completo (0→24 docs) en <15 minutos
- **Deployment homelab con Groq Cloud API:** Demostración en vivo sin dependencia de Ollama local

### Innovaciones Clave
1. **Reglas de Proactividad:** LLM rellena datos faltantes con estándares de industria (sin placeholders)
2. **Excelencia Visual:** Uso obligatorio de Markdown enriquecido (emojis, tree blocks, código, tablas, paletas de colores)
3. **Validación Estricta:** Bloquea generación del siguiente documento hasta que el usuario valide el anterior
4. **Cero Prefijos Robóticos:** Conversación natural sin "Chat:", "Robot:", "Asistente:"
5. **Obediencia de Plantillas:** Formato original preservado (ej. JSON debe ser válido y parseable)

---

## 🎯 Objetivos

### Objetivos Principales
1. **Refinar System Prompt:** Implementar 10 reglas de comportamiento estrictas para el Arquitecto IA
2. **Ajuste de Temperatura:** Aumentar creatividad (0.6-0.7) manteniendo coherencia
3. **Inyección de userName:** Personalizar respuestas dinámicamente desde Flutter a FastAPI
4. **Enforcement Master Workflow:** Flujo secuencial de 24 documentos con checkpoints de validación
5. **Deployment Homelab:** Despliegue production-ready con integración Groq Cloud API

### Objetivos Secundarios
6. **Cobertura Testing:** 15+ tests unitarios para cada regla del system prompt
7. **Validación E2E:** Flujo completo (0→24 docs) ejecutable en <15 minutos
8. **Ejemplos Knowledge Base:** Actualizar con ejemplos reales de cada documento del workflow

---

## 📚 Master Workflow (24 Documentos)

### Fase 00: DISCOVERY (3 documentos)
**Objetivo:** Entrevista inicial y definición de alcance

| # | Documento | Guardado En | Descripción |
|---|-----------|-------------|-------------|
| 01 | Entrevista Inicial Q&A | `context/00-DISCOVERY/INTERVIEW.md` | Preguntas estructuradas sobre Target, Stack, Features |
| 02 | Project Brief | `context/00-DISCOVERY/PROJECT_BRIEF.md` | Resumen ejecutivo de una página |
| 03 | Decisión Tech Stack | `context/00-DISCOVERY/TECH_STACK.md` | Elección de tecnologías con justificación |

### Fase 10: CONTEXT (5 documentos)
**Objetivo:** Visión, promesa, journey map, resumen ejecutivo

| # | Documento | Guardado En | Descripción |
|---|-----------|-------------|-------------|
| 04 | Declaración de Visión | `context/10-CONTEXT/VISION.md` | Visión a largo plazo del proyecto |
| 05 | Promesa de Valor | `context/10-CONTEXT/PROMISE.md` | Propuesta de valor para usuarios |
| 06 | Mapa de Journey Usuario | `context/10-CONTEXT/JOURNEY_MAP.md` | Flujos end-to-end del usuario |
| 07 | Resumen Ejecutivo | `context/10-CONTEXT/EXECUTIVE_SUMMARY.md` | Resumen para stakeholders |
| 08 | Glosario | `context/10-CONTEXT/GLOSSARY.md` | Diccionario de términos técnicos |

### Fase 20: REQUIREMENTS (7 documentos)
**Objetivo:** Requisitos funcionales, no funcionales, accesibilidad, seguridad

| # | Documento | Guardado En | Descripción |
|---|-----------|-------------|-------------|
| 09 | Requisitos Funcionales | `context/20-REQUIREMENTS/FUNCTIONAL.md` | Especificaciones de features |
| 10 | Requisitos No Funcionales | `context/20-REQUIREMENTS/NON_FUNCTIONAL.md` | Rendimiento, escalabilidad, confiabilidad |
| 11 | Checklist Accesibilidad | `context/20-REQUIREMENTS/ACCESSIBILITY.md` | Cumplimiento WCAG 2.1 AA |
| 12 | Requisitos Seguridad | `context/20-REQUIREMENTS/SECURITY.md` | OWASP Top 10, data sovereignty |
| 13 | Contrato API | `context/20-REQUIREMENTS/API_CONTRACT.md` | Especificación RESTful/GraphQL API |
| 14 | Schema Base de Datos | `context/20-REQUIREMENTS/DATABASE_SCHEMA.md` | Diagramas ER, migraciones |
| 15 | Definition of Ready/Done | `context/20-REQUIREMENTS/DOR_DOD.md` | Estándares de criterios de aceptación |

### Fase 30: ARCHITECTURE (4 documentos)
**Objetivo:** Diagramas arquitectura, decisiones técnicas, tech stack

| # | Documento | Guardado En | Descripción |
|---|-----------|-------------|-------------|
| 16 | Arquitectura del Sistema | `context/30-ARCHITECTURE/SYSTEM_DIAGRAM.md` | Diagramas modelo C4 |
| 17 | Decisiones Técnicas | `context/30-ARCHITECTURE/ADR.md` | Architecture Decision Records |
| 18 | Tech Stack Detallado | `context/30-ARCHITECTURE/TECH_STACK_DETAILED.md` | Librerías, frameworks, versiones |
| 19 | Arquitectura de Despliegue | `context/30-ARCHITECTURE/DEPLOYMENT.md` | Diagrama de infraestructura |

### Fase 40: ROADMAP (2 documentos)
**Objetivo:** User stories master, planificación sprints

| # | Documento | Guardado En | Descripción |
|---|-----------|-------------|-------------|
| 20 | User Stories Master | `context/40-ROADMAP/USER_STORIES_MASTER.json` | Backlog completo (formato JSON) |
| 21 | Planificación Sprint | `context/40-ROADMAP/SPRINT_PLAN.md` | Primeros 3 sprints detallados |

### Fase 50: IMPLEMENTATION (1 documento)
**Objetivo:** Guía de implementación primer sprint

| # | Documento | Guardado En | Descripción |
|---|-----------|-------------|-------------|
| 22 | Guía de Implementación | `context/50-IMPLEMENTATION/FIRST_SPRINT_GUIDE.md` | Estructura código, instrucciones setup |

### Fase 00-ROOT: Archivos Raíz (2 documentos)
**Objetivo:** README y CONTRIBUTING en raíz del repositorio

| # | Documento | Guardado En | Descripción |
|---|-----------|-------------|-------------|
| 23 | README.md | `README.md` | Introducción proyecto, setup, uso |
| 24 | CONTRIBUTING.md | `CONTRIBUTING.md` | Guías de contribución |

---

## 🧠 10 Reglas del System Prompt

### REGLA-01: Anti-Manifiesto Automático
**Trigger:** Prompt de usuario <50 caracteres
**Comportamiento:** No empezar a generar. Hacer 2-3 preguntas clave:
- "¿Qué tipo de aplicación estás construyendo? (web, móvil, escritorio, API)"
- "¿Cuál es tu stack tecnológico preferido? (ej. React+Node, Flutter+Python)"
- "¿Cuáles son las 3 funcionalidades principales de tu proyecto?"

### REGLA-02: Proactividad Total (Sin Placeholders)
**Prohibido:** `[Inserta tu texto aquí]`, `[TODO: Añadir descripción]`, `TBD`, `...`
**Requerido:** Borradores completos y realistas usando estándares de industria

### REGLA-03: Efecto WOW (Excelencia Visual)
**Obligatorio:**
- Emojis en todos los headers de sección
- Tree blocks para estructuras de directorios
- Bloques de código con tags de lenguaje
- Tablas para comparaciones, requisitos, endpoints API
- Códigos HEX visibles para paletas de colores

### REGLA-04: Limpieza Extrema `<document>`
**Dentro de tags `<document>`:** SOLO contenido puro del documento + ruta de guardado inicial
**Fuera de tags:** Toda conversación, sugerencias, explicaciones, saludos

### REGLA-05: Dictadura de Directorios
**Regla:** Todos los documentos DEBEN guardarse bajo `context/{FASE}/` excepto fase `00-ROOT/`
**Excepción:** `README.md` y `CONTRIBUTING.md` van en raíz del repositorio

### REGLA-06: Bloqueo por Validación
**Trigger:** Usuario intenta solicitar documento N+1
**Check:** Buscar en historial de chat el string exacto: `"He validado y guardado el documento en"`
**Acción:** Si no se encuentra para documento N, rechazar cortésmente

### REGLA-07: Cero Prefijos Robóticos
**Prohibido:** `"Chat:"`, `"Robot:"`, `"IA:"`, `"Asistente:"`, `"Assistant:"`
**Permitido:** Lenguaje natural directo: `"Aquí está el..."`, `"He generado..."`, `"El siguiente paso es..."`

### REGLA-08: Obediencia de Plantillas
**Regla:** El formato original de la plantilla DEBE preservarse
**Ejemplos:**
- `USER_STORIES_MASTER.json` → JSON válido parseable con `jq`
- Tablas → Mantener alineación de columnas
- Bloques de código → Sintaxis highlighting correcta

### REGLA-09: Inyección de userName
**Fuente:** Cliente Flutter envía campo `userName` en request `/chat/message`
**Inyección:** System prompt reemplaza placeholder `{userName}`
**Ejemplo:** `"Hola, {userName}!"` → `"Hola, Juan!"`

### REGLA-10: Flujo Secuencial 24 Docs
**Regla:** Documentos deben generarse en orden (01→24)
**Validación:** Verificar número de documento actual antes de generar siguiente
**Bloqueo:** No permitir saltos (ej. generar doc 05 sin completar 01-04)

---

## 🚀 Targets de Deployment

### 1. Homelab (Primario para Demo TFM)
**Infraestructura:**
- Proxmox VM (8GB RAM, 4 vCPUs)
- Docker 24.x + Docker Compose v2
- Reverse proxy (Nginx/Traefik) con HTTPS (Let's Encrypt)
- Groq API Key (variable de entorno)
- Volumen persistente ChromaDB

**Deployment:**
```bash
# Deployment de un comando
./scripts/devops/deploy-homelab.sh --api-key ${GROQ_API_KEY}

# Health check
curl https://softarchitect.homelab.local/health
# Esperado: {"status": "healthy", "llm_provider": "groq"}
```

### 2. Demo Cloud (Backup para TFM)
**Plataformas:** Cloud Run / Railway / Render (serverless)
**Requisitos:**
- Groq API Key en secrets manager
- ChromaDB in-memory o Chroma Cloud
- HTTPS obligatorio
- Scaling automático (0→N instancias)

---

## 📊 Fases de Implementación

| Fase | Duración | Entregables |
|------|----------|-------------|
| **Fase 1:** Backend Refinement | 2 días | Temperature ajustada, RULE-01 a RULE-05 |
| **Fase 2:** Frontend Integration | 1 día | userName injection, botón validación |
| **Fase 3:** Testing Suite | 2 días | 30+ tests unitarios, 5 tests E2E |
| **Fase 4:** Knowledge Base | 1 día | 24 ejemplos reales de documentos |
| **Fase 5:** Deployment Homelab | 1 día | docker-compose.homelab.yml + scripts |
| **Fase 6:** Validación & Demo | 1 día | Video demo, presentación, ensayo |

**Total:** 8 días (buffer incluido para imprevistos)

---

## ✅ Criterios de Aceptación (Resumen)

### Mínimo Viable
- [ ] 10/10 reglas del system prompt implementadas y testeadas
- [ ] Temperatura ajustada (0.6-0.7)
- [ ] Inyección userName funcional
- [ ] Deployment homelab exitoso
- [ ] 15+ tests unitarios pasando
- [ ] Cobertura backend ≥85%, frontend ≥80%

### Objetivos Stretch
- [ ] 5 tests E2E para flujo completo
- [ ] Deployment demo en cloud (Railway/Render)
- [ ] Knowledge base actualizada con 24 ejemplos reales
- [ ] Video demo grabado (<5 min)

---

## 📖 Documentación Adicional

| Documento | Idioma | Descripción |
|-----------|--------|-------------|
| [README.md](../../English/03-HU-TRACKING/HU-5.0-ARCHITECT-AI-REFINEMENT/README.md) | English | Especificación completa (versión inglés) |
| [PROGRESS.md](../../English/03-HU-TRACKING/HU-5.0-ARCHITECT-AI-REFINEMENT/PROGRESS.md) | English | Tracking de progreso implementación |
| [WORKFLOW.md](../../English/03-HU-TRACKING/HU-5.0-ARCHITECT-AI-REFINEMENT/WORKFLOW.md) | English | Workflow detallado paso a paso + deployment |

---

## 📅 Timeline (7 Días)

| Día | Foco | Entregable |
|-----|------|------------|
| **Día 1** | Reglas System Prompt 1-5 | Ajuste temperatura, proactividad, efecto WOW |
| **Día 2** | Reglas System Prompt 6-10 | Bloqueo validación, inyección userName |
| **Día 3** | Suite de Testing | 15+ tests unitarios implementados |
| **Día 4** | Deployment Homelab | docker-compose.homelab.yml + script deploy |
| **Día 5** | Testing E2E | 5 tests E2E + smoke tests |
| **Día 6** | Knowledge Base | Actualizar con 24 ejemplos reales documentos |
| **Día 7** | Validación Final | Flujo completo 0→24 docs, video demo |

---

**🎯 Fecha Meta Presentación:** Defensa TFM
**🚀 Estado:** 🚧 En Progreso
**👤 Owner:** Equipo Desarrollo + Agente ArchitectZero
