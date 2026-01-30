# 📑 Índice de Documentación - SoftArchitect AI

> **Fecha:** 28 de Enero de 2026
> **Estado:** ✅ Documentación Centralizada en `doc/`
> **Estructura:** Bilingual (ES/EN), Organizada por Categorías

---

## 📂 Estructura de Directorios

```
doc/
├── 00-VISION/                    # Visión y concepto del proyecto
│   ├── CONCEPT_WHITE_PAPER.es.md     (Documento conceptual en español)
│   └── CONCEPT_WHITE_PAPER.en.md     (Documento conceptual en inglés)
│
├── 01-PROJECT_REPORT/           # Reportes, métrics y documentación técnica
│   ├── CONTEXT_COVERAGE_REPORT.es.md     (Cobertura de contexto en español)
│   ├── CONTEXT_COVERAGE_REPORT.en.md     (Cobertura de contexto en inglés)
│   ├── FUNCTIONAL_TEST_REPORT.md         (Reporte de pruebas funcionales)
│   ├── INITIAL_SETUP_LOG.es.md          (Log de instalación en español)
│   ├── INITIAL_SETUP_LOG.en.md          (Log de instalación en inglés)
│   ├── MEMORIA_METODOLOGICA.es.md       (Metodología en español)
│   ├── MEMORIA_METODOLOGICA.en.md       (Metodología en inglés)
│   ├── PROJECT_MANIFESTO.es.md          (Manifiesto en español)
│   ├── PROJECT_MANIFESTO.en.md          (Manifiesto en inglés)
│   ├── SIMULACION_POC.es.md            (Simulación POC en español)
│   └── SIMULACION_POC.en.md            (Simulación POC en inglés)
│
├── 02-SETUP_DEV/                 # Guías técnicas para setup y desarrollo
│   ├── AUTOMATION.es.md          (Automatización y DevOps en español)
│   ├── AUTOMATION.en.md          (Automatización y DevOps en inglés)
│   ├── DOCKER_COMPOSE_GUIDE.es.md    (Guía Docker Compose en español)
│   ├── QUICK_START_GUIDE.es.md   (Inicio rápido en español) ⭐ NEW
│   ├── QUICK_START_GUIDE.en.md   (Inicio rápido en inglés) ⭐ NEW
│   ├── SETUP_GUIDE.es.md         (Guía de instalación en español)
│   ├── SETUP_GUIDE.en.md         (Guía de instalación en inglés)
│   ├── TOOLS_AND_STACK.es.md     (Stack tecnológico en español)
│   ├── TOOLS_AND_STACK.en.md     (Stack tecnológico en inglés)
│   ├── TEST_COVERAGE_DASHBOARD.md    (Dashboard de cobertura de tests) ⭐ NEW
│   └── TEST_EXECUTION_LOG.md     (Histórico de ejecuciones de tests) ⭐ NEW
├── 03-HU-TRACKING/                # Seguimiento de Historias de Usuario
│   ├── README.md                  (Índice maestro de HUs)
│   ├── HU-1.1-DOCKER-SETUP/       (HU-1.1: Infraestructura Docker)
│   │   ├── README.md
│   │   ├── PROGRESS.md
│   │   └── ARTIFACTS.md
│   └── HU-1.2-BACKEND-SKELETON/   (HU-1.2: Backend FastAPI) ⭐ NEW
│       ├── README.md
│       ├── WORKFLOW.md
│       ├── PROGRESS.md
│       └── ARTIFACTS.md
│
│
└── private/                      # Documentación interna (no publicada)
    └── INTERNAL_DEV_BLUEPRINT.md (Blueprint de desarrollo interno)
```

---

## 📖 Guía de Lectura Recomendada

### ✨ Para Nuevos Usuarios

**Ruta Recomendada (30 minutos - COMIENZA AQUÍ):**
1. **⭐ [WHAT_WE_ARE_BUILDING.es.md](00-VISION/WHAT_WE_ARE_BUILDING.es.md)** - Entiende exactamente QUÉ estamos construyendo
2. Lee [CONCEPT_WHITE_PAPER.es.md](00-VISION/CONCEPT_WHITE_PAPER.es.md) - Entiende la visión detallada
3. Lee [QUICK_START_GUIDE.es.md](02-SETUP_DEV/QUICK_START_GUIDE.es.md) - Levanta servicios
4. Lee [FUNCTIONAL_TEST_REPORT.md](01-PROJECT_REPORT/FUNCTIONAL_TEST_REPORT.md) - Verifica que todo funciona

### 🏗️ Para Arquitectos & Tech Leads

**Ruta Recomendada (60 minutos):**
1. [SYSTEM_E2E_WORKFLOW.md](01-PROJECT_REPORT/SYSTEM_E2E_WORKFLOW.md) - ⭐ **COMIENZA AQUÍ** - Visualiza el flujo completo
2. [MEMORIA_METODOLOGICA.es.md](01-PROJECT_REPORT/MEMORIA_METODOLOGICA.es.md) - Metodología
3. [PROJECT_MANIFESTO.es.md](01-PROJECT_REPORT/PROJECT_MANIFESTO.es.md) - Principios
4. [../../AGENTS.md](../../AGENTS.md) - Definición del agente
5. [../../context/30-ARCHITECTURE/](../../context/30-ARCHITECTURE/) - Detalles arquitectónicos

### 👨‍💻 Para Desarrolladores

**Ruta Recomendada (90 minutos):**
1. [QUICK_START_GUIDE.es.md](02-SETUP_DEV/QUICK_START_GUIDE.es.md) - Setup rápido
2. [SETUP_GUIDE.es.md](02-SETUP_DEV/SETUP_GUIDE.es.md) - Configuración detallada
3. [TOOLS_AND_STACK.es.md](02-SETUP_DEV/TOOLS_AND_STACK.es.md) - Stack y versiones
4. [AUTOMATION.es.md](02-SETUP_DEV/AUTOMATION.es.md) - CI/CD y scripts
5. [FUNCTIONAL_TEST_REPORT.md](01-PROJECT_REPORT/FUNCTIONAL_TEST_REPORT.md) - Testing

### 🚀 Para DevOps & Infrastructure

**Ruta Recomendada (60 minutos):**
1. [DOCKER_COMPOSE_GUIDE.es.md](02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.es.md)
2. [AUTOMATION.es.md](02-SETUP_DEV/AUTOMATION.es.md)
3. [../../infrastructure/docker-compose.yml](../../infrastructure/docker-compose.yml)
4. [../../infrastructure/validate-docker-setup.sh](../../infrastructure/validate-docker-setup.sh)

---

## 📊 Contenido por Categoría

### 🎯 Visión & Contexto (00-VISION/)

| Archivo | Descripción | Audiencia |
|---------|-------------|-----------|
| **WHAT_WE_ARE_BUILDING** ⭐ NEW | La definición completa de qué estamos construyendo (La Esencia) | Todos |
| CONCEPT_WHITE_PAPER | Documento conceptual del proyecto (Problemática, Solución, Oportunidad) | Todos |

### 📈 Reportes & Análisis (01-PROJECT_REPORT/)

| Archivo | Descripción | Audiencia | Líneas |
|---------|-------------|-----------|--------|
| **SYSTEM_E2E_WORKFLOW** ⭐ NEW | Diagrama Mermaid del flujo end-to-end completo (5 fases interactivas) | Arquitectos/Diseñadores | ~320 |
| FUNCTIONAL_TEST_REPORT | 18/18 pruebas pasadas, métricas, compliance | QA/DevOps | ~716 |
| INITIAL_SETUP_LOG | Timeline de instalación, 4 fases de setup | DevOps/Infra | ~500 |
| MEMORIA_METODOLOGICA | Visión, metodología, reglas de ingeniería | Arquitectos/Leads | ~600 |
| PROJECT_MANIFESTO | Principios, valores, compromisos del proyecto | Todos | ~300 |
| CONTEXT_COVERAGE_REPORT | Análisis de completitud de documentación | PMs/Leads | ~400 |
| SIMULACION_POC | Simulación y análisis POC del sistema | Técnicos | ~400 |
| KNOWLEDGE_BASE_COMPLETION | Reporte de Fases 0-6 del Knowledge Base (29 archivos, 934 líneas) | Arquitectos | ~400 |

### 🛠️ Setup & Desarrollo (02-SETUP_DEV/)

| Archivo | Descripción | Audiencia | Líneas |
|---------|-------------|-----------|--------|
| QUICK_START_GUIDE ⭐ NEW | Inicio rápido (3 opciones), troubleshooting | Nuevos usuarios | ~450 |
| SETUP_GUIDE | Guía detallada paso a paso | DevOps | ~600 |
| TOOLS_AND_STACK | Versiones exactas, compatibilidades | Desarrolladores | ~400 |
| DOCKER_COMPOSE_GUIDE | Docker Compose detallado, networking | DevOps/Infra | ~500 |
| AUTOMATION | CI/CD, scripts de automatización | DevOps/SRE | ~500 |
| TEST_COVERAGE_DASHBOARD ⭐ NEW | Dashboard de cobertura y métricas de tests | QA/Dev/Leads | ~400 |
| TEST_EXECUTION_LOG ⭐ NEW | Histórico y seguimiento de test runs | QA/CI | ~350 |
| TEST_STRATEGY_AND_ROADMAP ⭐ NEW | Plan detallado para robustez production-ready | Arquitectos/Leads | ~600 |
### 📋 Tracking de Historias de Usuario (03-HU-TRACKING/)

| Historia | Descripción | Estado | Documentos |
|---------|-------------|--------|------------|
| HU-1.1 | Docker Infrastructure Setup | ✅ Completado | README, PROGRESS, ARTIFACTS |
| HU-1.2 ⭐ COMPLETED | Backend Skeleton (FastAPI) | ✅ Completado | README (bilingüe), WORKFLOW, PROGRESS, ARTIFACTS |

### 🧠 Knowledge Base (Fases 0-6) ⭐ NEW

> **Estado:** ✅ COMPLETED (30 de Enero de 2026)
> **Fases:** 0-6 (Meta Brain + Templates)
> **Total Archivos:** 29 (4 Meta + 25 Templates)
> **Líneas Generadas:** 934 líneas
> **Cobertura:** 100% Lifecycle Development (Idea → Deploy → Monitor)

**Documentación Detallada:**
- [KNOWLEDGE_BASE_COMPLETION.md](01-PROJECT_REPORT/KNOWLEDGE_BASE_COMPLETION.md) - Reporte completo de Fases 0-6

**Estructura Generada:**
```
packages/knowledge_base/
├── 00-META/ (4 Meta Files - RAG Brain)
│   ├── WORKFLOW_RULES.yaml          # Machine-readable workflow definition
│   ├── MASTER_WORKFLOW_HUMAN.md     # Human-readable with Mermaid diagram
│   ├── PROJECT_ONTOLOGY.md          # DDD terminology definitions
│   └── AI_PERSONA_PROMPT.md         # System prompt with 7 Prime Directives
│
├── 01-TEMPLATES/ (25 Template Files - 6 Phases)
│   ├── 00-ROOT/                     # Phase 1: Gobernanza
│   │   ├── README.template.md
│   │   ├── AGENTS.template.md
│   │   ├── RULES.template.md
│   │   └── CONTRIBUTING.template.md
│   ├── 10-CONTEXT/
│   │   ├── PROJECT_MANIFESTO.template.md
│   │   ├── USER_JOURNEY_MAP.template.md
│   │   └── DOMAIN_LANGUAGE.template.md
│   ├── 20-REQUIREMENTS/             # Phase 2: Especificación
│   │   ├── REQUIREMENTS_MASTER.template.md
│   │   ├── USER_STORIES_MASTER.template.json
│   │   ├── SECURITY_PRIVACY_POLICY.template.md
│   │   └── COMPLIANCE_MATRIX.template.md
│   ├── 30-ARCHITECTURE/             # Phase 3: Arquitectura
│   │   ├── TECH_STACK_DECISION.template.md
│   │   ├── PROJECT_STRUCTURE_MAP.template.md
│   │   ├── API_INTERFACE_CONTRACT.template.md
│   │   ├── DATA_MODEL_SCHEMA.template.md
│   │   ├── ARCH_DECISION_RECORDS.template.md
│   │   └── SECURITY_THREAT_MODEL.template.md
│   ├── 35-UX_UI/                    # Phase 4: Experiencia
│   │   ├── DESIGN_SYSTEM.template.md
│   │   ├── UI_WIREFRAMES_FLOW.template.md
│   │   └── ACCESSIBILITY_GUIDE.template.md
│   ├── 40-PLANNING/                 # Phase 5: Operaciones
│   │   ├── ROADMAP_PHASES.template.md
│   │   ├── TESTING_STRATEGY.template.md
│   │   ├── CI_CD_PIPELINE.template.md
│   │   └── DEPLOYMENT_INFRASTRUCTURE.template.md
│   └── 99-META/                     # Phase 6: Meta-Instrucciones
│       └── CONTEXT_GENERATOR_PROMPT.template.md
│
└── 02-TECH-PACKS/                   # Ready for Phase 6.1 Tech Pack Population
    ├── _STANDARD_SCHEMA/
    ├── BACKEND/
    ├── FRONTEND/
    ├── DEVOPS_CLOUD/
    ├── AI_ENGINEERING/
    └── DATA/
```

**Capacidades Implementadas:**
| Feature | Detalles | Status |
|---------|----------|--------|
| **Template Universales** | {{PLACEHOLDER}} pattern para RAG substitution | ✅ |
| **5-Layer Security Model** | Legal → Data → Technical → Historical → Persona | ✅ |
| **Bilingual Ready** | Estructura soporta EN/ES automáticamente | ✅ |
| **Lifecycle Coverage** | 100% (Governance → Spec → Architecture → UX → Operations → RAG) | ✅ |
| **RAG Integration** | ChromaDB-vectorizable, Ollama-compatible | ✅ |
| **Documentation** | Comprehensive KNOWLEDGE_BASE_COMPLETION.md report | ✅ |

### 🔒 Privado (private/)

| Archivo | Descripción | Acceso |
|---------|-------------|--------|
| INTERNAL_DEV_BLUEPRINT | Blueprint interno de desarrollo | Solo core team |

---

## 🔗 Enlaces Rápidos

### Contexto del Proyecto
- [AGENTS.md](../../AGENTS.md) - Identidad y responsabilidades del agente
- [RULES.md](../../context/RULES.md) - Reglas globales del proyecto
- [Roadmap](../../context/40-ROADMAP/) - Fases y planificación

### Especificaciones Técnicas
- [Tech Stack Details](../../context/30-ARCHITECTURE/TECH_STACK_DETAILS.en.md)
- [API Interface Contract](../../context/30-ARCHITECTURE/API_INTERFACE_CONTRACT.en.md)
- [Error Handling Standard](../../context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md)

### Seguridad & Privacidad
- [Security and Privacy Rules](../../context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md)
- [Definition of Ready](../../context/20-REQUIREMENTS_AND_SPEC/DEFINITION_OF_READY.en.md)

---

## ✅ Estado de Documentación

| Aspecto | Estado | Detalles |
|---------|--------|----------|
| **Cobertura Visual** | ✅ 100% | Todos los temas documentados |
| **Bilingual (ES/EN)** | ✅ 95% | Mayoría bilingüe, algunos doc EN-only |
| **Centralización** | ✅ 100% | Todo en `doc/` (raíz limpia) |
| **Actualización** | ✅ 30 Ene 2026 | Última actualización (Knowledge Base Phases 0-6 ✅) |
| **Métricas** | ✅ 33 Archivos | ~10,400+ líneas totales |
| **HU Tracking** | ✅ 2 HUs | HU-1.1 ✅ (Complete), HU-1.2 ✅ (Phases 0-5 Complete) |
| **Security Report** | ✅ NEW | PHASE_5_SECURITY_VALIDATION_REPORT.md agregado |
| **Knowledge Base** | ✅ NEW | 29 archivos (4 Meta + 25 Templates) - Fases 0-6 Completadas |

---

## 🔍 Búsqueda de Documentación

### Por Palabra Clave

**Setup & Instalación:**
- [QUICK_START_GUIDE.es.md](02-SETUP_DEV/QUICK_START_GUIDE.es.md) - Inicio en 5 minutos
- [SETUP_GUIDE.es.md](02-SETUP_DEV/SETUP_GUIDE.es.md) - Setup completo paso a paso
- [DOCKER_COMPOSE_GUIDE.es.md](02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.es.md) - Docker en detalle

**Testing & Validación:**
- [TEST_COVERAGE_DASHBOARD.md](02-SETUP_DEV/TEST_COVERAGE_DASHBOARD.md) - Métricas actuales de cobertura ⭐ NEW
- [TEST_EXECUTION_LOG.md](02-SETUP_DEV/TEST_EXECUTION_LOG.md) - Histórico de test runs ⭐ NEW
- [TEST_STRATEGY_AND_ROADMAP.md](TEST_STRATEGY_AND_ROADMAP.md) - Plan para robustez production-ready ⭐ NEW
- [FUNCTIONAL_TEST_REPORT.md](01-PROJECT_REPORT/FUNCTIONAL_TEST_REPORT.md) - Resultados de pruebas
- [INITIAL_SETUP_LOG.es.md](01-PROJECT_REPORT/INITIAL_SETUP_LOG.es.md) - Verificación de instalación

**Arquitectura & Diseño:**
- [MEMORIA_METODOLOGICA.es.md](01-PROJECT_REPORT/MEMORIA_METODOLOGICA.es.md) - Diseño arquitectónico
- [PROJECT_MANIFESTO.es.md](01-PROJECT_REPORT/PROJECT_MANIFESTO.es.md) - Principios de diseño

**Automatización & DevOps:**
- [AUTOMATION.es.md](02-SETUP_DEV/AUTOMATION.es.md) - CI/CD y scripts
- [TOOLS_AND_STACK.es.md](02-SETUP_DEV/TOOLS_AND_STACK.es.md) - Stack técnico

**Troubleshooting:**
- [QUICK_START_GUIDE.es.md](02-SETUP_DEV/QUICK_START_GUIDE.es.md) - Problemas comunes
- [DOCKER_COMPOSE_GUIDE.es.md](02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.es.md) - Problemas Docker

---

## 📝 Notas Importantes

1. **Preferencia de Idioma:** Este índice y la mayoría de guías tienen versiones en español (`.es.md`)
2. **Actualizaciones:** Consultar fecha de última modificación en cada documento
3. **Links Internos:** Todos los links usan rutas relativas desde el directorio `doc/`
4. **Contexto:** Para configuración global del agente, ver [../../context/](../../context/)
5. **Reportes:** Los reportes de tests y métricas están en `01-PROJECT_REPORT/`

---

## 🎯 Próximas Mejoras

- [ ] Crear tabla de contenidos interactiva en GitHub Pages
- [ ] Agregar diagrama visual de estructura del proyecto
- [ ] Implementar búsqueda full-text en documentación
- [ ] Automatizar versionado de docs en cada release
- [ ] Crear wiki interna con permisos (para `private/`)

---

**Última Actualización:** 29 de Enero de 2026
**Responsable:** ArchitectZero AI Agent
**Estado:** ✅ LISTO PARA PRODUCCIÓN
