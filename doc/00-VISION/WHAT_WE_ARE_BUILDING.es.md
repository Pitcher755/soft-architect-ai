# 🏗️ QUÉ ESTAMOS CONSTRUYENDO

> **Fecha:** 30 de Enero de 2026
> **Estado:** ✅ Definición Completa
> **Audiencia:** Todos (Equipo, Stakeholders, Investors)
> **Versión:** 1.0

---

## 📖 Tabla de Contenidos

- [La Esencia](#la-esencia)
- [El Flujo Core](#el-flujo-core)
- [La Infraestructura](#la-infraestructura)
- [Los 5 Gates de Seguridad](#los-5-gates-de-seguridad)
- [Arquitectura General](#arquitectura-general)
- [La Propuesta de Valor Única](#la-propuesta-de-valor-única)
- [Por Qué Local-First & Sin Fisuras](#por-qué-local-first--sin-fisuras)
- [El Próximo Acto: Phase 6.1](#el-próximo-acto-phase-61)
- [El Estado Actual](#el-estado-actual)
- [Por Qué Esto Importa](#por-qué-esto-importa)
- [La Pregunta Fundamental](#la-pregunta-fundamental)

---

## 🎯 La Esencia

**SoftArchitect AI** es un **asistente de ingeniería robusto, privado y offline** que actúa como tu **arquitecto senior virtual on-demand**.

### ¿Qué NO es?
- ❌ Un chatbot de código
- ❌ Un generador de boilerplate sin contexto
- ❌ Un servicio cloud que envía tus datos a OpenAI
- ❌ Una herramienta "apunta y genera"

### ¿Qué SÍ es?
- ✅ Un **Quality Gate inteligente** que guía a desarrolladores a través de un **workflow de ingeniería estricto**
- ✅ Un **asistente de arquitectura** que construye cimiento ANTES del código
- ✅ Un **sistema offline-first** que respeta tu privacidad total
- ✅ Un **motor de contexto** que entiende tu proyecto completamente

**La premisa fundamental:** *"No se debe escribir una sola línea de código sin haber documentado y validado completamente la arquitectura que lo soportará."*

---

## 🔀 El Flujo Core

### El Punto de Partida: Una IDEA

Un usuario (emprendedor, tech lead, developer) entra al sistema con una idea:

```
"App estilo Tinder para adoptar mascotas, hecha en Flutter, sin fines de lucro"
```

### El Viaje por 5 Fases

El sistema (powered by RAG + Knowledge Base) guía al usuario a través de un workflow estrictamente estructurado:

#### **FASE 1: GOBERNANZA E IDENTIDAD**
```
¿Quiénes somos? ¿Qué queremos construir? ¿Para quién? ¿Por qué?

RAG Análisis:
  • Detecta constraints tecnológicos (Flutter)
  • Detecta constraints económicos (Sin fines de lucro = costo cero)
  • Detecta patrones UX (Tinder-like = swipe interaction)

Genera: PROJECT_MANIFESTO.md
  • Visión del proyecto
  • Valores y principios
  • Alcance del MVP
  • Compromisos con stakeholders

Interacción:
  💬 "Entendido. Aquí tienes la Visión y Promesa del proyecto.
      ¿Te parece bien este alcance para el MVP?"

  Usuario puede:
    ✅ APROBAR → Avanzar a Fase 2
    🔄 REFINAR → Ajustar detalles
    ❓ PREGUNTAR → RAG consulta Knowledge Base
```

#### **FASE 2: REQUISITOS Y SEGURIDAD**
```
¿Qué exactamente vamos a construir? ¿Qué riesgos hay?

RAG Deducción:
  • Tinder-like → Necesita Swipe Logic (RF)
  • Geolocalización → Necesita Maps API (RF)
  • Gratuito → Hosting de bajo costo (RNF)

Genera:
  • REQUIREMENTS_MASTER.md (RF + RNF + Constraints)
  • USER_STORIES_MASTER.json (Historias estructuradas)
  • SECURITY_PRIVACY_POLICY.md (GDPR/CCPA compliance)
  • COMPLIANCE_MATRIX.md (Matriz de cumplimiento legal)

Interacción:
  💬 "He definido las Historias de Usuario y añadido política
      de privacidad GDPR para donantes. ¿Algún requisito faltante?"

  Usuario puede refinar completamente los requisitos
```

#### **FASE 3: ARQUITECTURA TÉCNICA**
```
¿Cómo vamos a construirlo? ¿Qué tecnologías?

RAG Consultor:
  • Busca Tech Pack: "Flutter" (Mobile Framework)
  • Busca Backend: "Firebase" o "Supabase" (por requisito costo cero)
  • Deduce: Clean Architecture + MVVM

Genera:
  • TECH_STACK_DECISION.md (Justificación de cada tecnología)
  • PROJECT_STRUCTURE_MAP.md (Estructura ASCII - THE LAW)
  • API_INTERFACE_CONTRACT.md (Especificación de endpoints)
  • DATA_MODEL_SCHEMA.md (ERD + tipos de datos)
  • ARCH_DECISION_RECORDS.md (Por qué cada decisión - ADRs)
  • SECURITY_THREAT_MODEL.md (STRIDE analysis + mitigaciones)

Interacción:
  💬 "Por requisito de 'costo cero', sugiero Firebase con Realtime DB.
      Aquí está la estructura Clean Architecture para Flutter.
      ¿Estás de acuerdo o prefieres otro backend?"

  Usuario puede cambiar cualquier tecnología y regenerar
```

#### **FASE 4: EXPERIENCIA Y FRONTERA**
```
¿Cómo se verá? ¿Cómo interactuará el usuario?

RAG Designer:
  • Define paleta de colores (Amigable, orientada a mascotas)
  • Define componentes reutilizables
  • Define flujos de pantalla

Genera:
  • DESIGN_SYSTEM.md (Tokens, tipografía, componentes)
  • UI_WIREFRAMES_FLOW.md (Diagramas Mermaid de pantallas)
  • ACCESSIBILITY_GUIDE.md (WCAG 2.1 AA compliance)

Interacción:
  💬 "Aquí están los wireframes y design tokens.
      ¿Te gustan? ¿Cambio la paleta de colores?"
```

#### **FASE 5: OPERACIONES Y CALIDAD**
```
¿Cuándo lanzamos? ¿Con qué rigor probamos?

RAG Planner:
  • Define fases: MVP (8 semanas), V1 (12 semanas), V2 (ongoing)
  • Define estrategia de testing (pirámide de tests)
  • Define pipeline CI/CD

Genera:
  • ROADMAP_PHASES.md (Timeline MVP/V1/V2)
  • TESTING_STRATEGY.md (Test pyramid + métricas)
  • CI_CD_PIPELINE.md (Stages: build, test, deploy)
  • DEPLOYMENT_INFRASTRUCTURE.md (Cloud architecture)

Interacción:
  💬 "Aquí está el plan de lanzamiento y testing.
      ¿Son realistas estas fechas? ¿Ajustamos?"
```

### El Resultado Final

```
🏁 CONTEXTO COMPLETADO

Tu proyecto tiene ahora:
  ✅ ~40 documentos técnicos
  ✅ 100% arquitectura definida
  ✅ 0 ambigüedades
  ✅ 5 capas de seguridad validadas
  ✅ Roadmap detallado
  ✅ Listo para que el equipo comience a codificar

🚀 RAG: "¿Listo para iniciar generación de código?"
```

---

## 🧠 La Infraestructura

### Knowledge Base: El Cerebro del Sistema

```
packages/knowledge_base/
│
├── 00-META/ (Sistema Nervioso - 4 archivos, 228 líneas)
│   ├── WORKFLOW_RULES.yaml
│   │   └── Definición machine-readable del workflow
│   │       (Cómo el RAG sabe qué hacer en cada fase)
│   │
│   ├── MASTER_WORKFLOW_HUMAN.md
│   │   └── Versión humana + Mermaid diagrams
│   │       (Para que cualquiera entienda el flujo)
│   │
│   ├── PROJECT_ONTOLOGY.md
│   │   └── Terminología DDD (Domain Driven Design)
│   │       (Tech Pack, Gate, Artifact, Hardening)
│   │
│   └── AI_PERSONA_PROMPT.md
│       └── System prompt con 7 Prime Directives
│           (Cómo debe comportarse el agente IA)
│
├── 01-TEMPLATES/ (Plantillas Reutilizables - 25 archivos, 706 líneas)
│   │
│   ├── 00-ROOT/ (Gobernanza - 4 templates)
│   │   ├── README.template.md         → Portada proyecto
│   │   ├── AGENTS.template.md         → Definición de roles
│   │   ├── RULES.template.md          → Constitución proyecto
│   │   └── CONTRIBUTING.template.md   → Guía contribuciones
│   │
│   ├── 10-CONTEXT/ (Contexto - 3 templates)
│   │   ├── PROJECT_MANIFESTO.template.md     → Visión y valores
│   │   ├── USER_JOURNEY_MAP.template.md      → Personas y journeys
│   │   └── DOMAIN_LANGUAGE.template.md       → Glosario DDD
│   │
│   ├── 20-REQUIREMENTS/ (Especificación - 4 templates)
│   │   ├── REQUIREMENTS_MASTER.template.md         → RF + RNF
│   │   ├── USER_STORIES_MASTER.template.json       → Historias
│   │   ├── SECURITY_PRIVACY_POLICY.template.md     → Compliance
│   │   └── COMPLIANCE_MATRIX.template.md           → Checklist legal
│   │
│   ├── 30-ARCHITECTURE/ (Diseño Técnico - 6 templates)
│   │   ├── TECH_STACK_DECISION.template.md    → Justificación tech
│   │   ├── PROJECT_STRUCTURE_MAP.template.md  → Estructura ASCII
│   │   ├── API_INTERFACE_CONTRACT.template.md → Endpoints REST
│   │   ├── DATA_MODEL_SCHEMA.template.md      → ERD + validaciones
│   │   ├── ARCH_DECISION_RECORDS.template.md  → ADRs (por qué)
│   │   └── SECURITY_THREAT_MODEL.template.md  → STRIDE analysis
│   │
│   ├── 35-UX_UI/ (Experiencia - 3 templates)
│   │   ├── DESIGN_SYSTEM.template.md       → Tokens + componentes
│   │   ├── UI_WIREFRAMES_FLOW.template.md  → Wireframes Mermaid
│   │   └── ACCESSIBILITY_GUIDE.template.md → WCAG 2.1 AA
│   │
│   ├── 40-PLANNING/ (Operaciones - 4 templates)
│   │   ├── ROADMAP_PHASES.template.md              → MVP/V1/V2
│   │   ├── TESTING_STRATEGY.template.md            → Test pyramid
│   │   ├── CI_CD_PIPELINE.template.md              → Build/test/deploy
│   │   └── DEPLOYMENT_INFRASTRUCTURE.template.md   → Cloud diagram
│   │
│   └── 99-META/ (Metainstrucciones - 1 template)
│       └── CONTEXT_GENERATOR_PROMPT.template.md → 7 Prime Directives
│
└── 02-TECH-PACKS/ (Próximo Paso - Phase 6.1)
    ├── _STANDARD_SCHEMA/    → Formato base para todos los tech packs
    ├── BACKEND/             → Python FastAPI + LangChain
    ├── FRONTEND/            → Flutter Desktop + Riverpod
    ├── DEVOPS_CLOUD/        → Docker + GitHub Actions
    ├── AI_ENGINEERING/      → Ollama + ChromaDB
    └── DATA/                → Database patterns + migrations
```

### Características Clave de las Plantillas

- **Patrón {{PLACEHOLDER}}:** Todas las variables usan `{{NOMBRE}}` para sustitución automática por RAG
- **Bilingual Ready:** Soportan EN/ES automáticamente
- **Verificables:** Pueden ser revisadas y validadas por humanos
- **Versionables:** Se guardan en Git con historial completo
- **Referenciables:** Se pueden linkear desde código, PRs, documentación

---

## 🔐 Los 5 Gates de Seguridad ("Sin Fisuras")

El sistema implementa validación en **5 capas independientes** para garantizar que nada se escape:

| Gate | Capa | Responsabilidad | Documento |
|------|------|-----------------|-----------|
| 1️⃣ | **LEGAL** | ¿Cumple regulaciones (GDPR/CCPA/HIPAA)? | COMPLIANCE_MATRIX.md |
| 2️⃣ | **DATA** | ¿Trata datos sensibles correctamente? | SECURITY_PRIVACY_POLICY.md |
| 3️⃣ | **TÉCNICA** | ¿La arquitectura es segura (STRIDE)? | SECURITY_THREAT_MODEL.md |
| 4️⃣ | **HISTÓRICA** | ¿Hemos cometido este error antes? | ARCH_DECISION_RECORDS.md |
| 5️⃣ | **PERSONA** | ¿El agente IA sigue sus directivas? | CONTEXT_GENERATOR_PROMPT.md |

**Ningún documento se genera sin pasar por estas 5 capas.**

---

## 🏗️ Arquitectura General

```
┌────────────────────────────────────────────────────────────┐
│                  CAPA DE PRESENTACIÓN                      │
│                   (User Interface)                          │
│              Flutter Desktop App (Linux/Win/Mac)            │
│         📱 Chat interactivo + Documentos generados         │
└────────────────────────────────────────────────────────────┘
                              ↕
┌────────────────────────────────────────────────────────────┐
│                    GATEWAY API                             │
│                   (Orquestación)                           │
│               FastAPI + Security Layer                      │
│    • Sanitización de inputs                               │
│    • Autenticación y autorización                         │
│    • Rate limiting y auditoría                            │
└────────────────────────────────────────────────────────────┘
                              ↕
┌──────────────────┬──────────────────┬─────────────────────┐
│  KNOWLEDGE BASE  │   VECTOR DB      │   LLM ENGINE        │
│  (El Cerebro)    │   (La Memoria)   │   (La Inteligencia) │
├──────────────────┼──────────────────┼─────────────────────┤
│ • 00-META/       │ • ChromaDB       │ • Ollama (Local)    │
│   Workflow       │ • Vectores de    │ • Groq (Cloud)      │
│   Rules          │   templates      │ • LangChain         │
│ • 01-TEMPLATES/  │ • Búsqueda       │   Framework         │
│   25 templates   │   semántica      │ • Context Manager   │
│ • 02-TECH-PACKS/ │ • Relevancia     │ • Prompt Engineer   │
│   Stack guides   │   ranking        │                     │
└──────────────────┴──────────────────┴─────────────────────┘
                              ↕
┌────────────────────────────────────────────────────────────┐
│              ALMACENAMIENTO LOCAL                          │
│  • SQLite + JSON (Config)                                 │
│  • Git (Versionado de contextos)                          │
│  • Audit logs (Quién hizo qué, cuándo, por qué)          │
└────────────────────────────────────────────────────────────┘
```

---

## 💎 La Propuesta de Valor Única

### Vs. ChatGPT / Claude (Generic AI)
```
ChatGPT:        "Dame la idea que quieras, te genero lo que sea"
SoftArchitect:  "Dame la idea, yo te genero ARQUITECTURA VALIDADA"

Diferencia: Guía estructurada vs libertad sin control
```

### Vs. GitHub Copilot (Code AI)
```
Copilot:        "Aquí está el código que escribiste"
SoftArchitect:  "Aquí está el PLAN para que escribas código correcto"

Diferencia: Generación de código vs Generación de arquitectura
```

### Vs. Arquitectos Externos (Humanos)
```
Arquitecto:     "Te cobro $50k, me toma 3 meses"
SoftArchitect:  "Te cuesta $0 (open source), 1 hora, infinito escalable"

Diferencia: Recurso limitado vs Herramienta infinita
```

### Nuestra Ventaja Competitiva
```
RAG + Workflow + Templates = Ingeniería Democratizada
  ✅ Accesible (on-demand)
  ✅ Privada (offline)
  ✅ Verificable (templates probados)
  ✅ Escalable (infinitos proyectos)
  ✅ Auditable (cada decisión documentada)
```

---

## 🛡️ Por Qué Local-First & Sin Fisuras

### Privacidad Total

**Problema tradicional:**
```
Tu código → OpenAI servers → Copilot responde
           ⚠️ ¿Quién ve tu código? ¿Se guarda? ¿Se usa para entrenar?
```

**Nuestra solución:**
```
Tu código → Tu máquina (Docker) → Ollama (Local)
           ✅ Nunca sale de tu control
```

**Modo híbrido opcional:**
```
Tu código → Tu máquina → Groq API (SOLO si user elige)
           ✅ Consentimiento explícito
           ✅ Fallback a local si no funciona
```

### Calidad Sin Fisuras

**Problema tradicional:**
```
LLM genera → Alucinaciones → Documentación falsa → Código roto
```

**Nuestra solución:**
```
Template probado → RAG rellena {{ }} → Usuario valida → Guarda
     ✅ No hay hallucinations (solo sustitución)
     ✅ Usuario SIEMPRE valida antes de guardar
     ✅ 5 capas de seguridad
```

---

## 🚀 El Próximo Acto: Phase 6.1

### Tech Packs Population

La Phase 6 (Phases 0-6 ya completadas) fue **construir la infraestructura**.

La Phase 6.1 es **poblar los Tech Packs con contenido real**:

```
02-TECH-PACKS/BACKEND/ ← Llenamos con:
  ├── PYTHON_FASTAPI_SETUP.md
  │   └── Paso a paso: cómo configurar FastAPI
  │       (Usando nuestro propio backend como referencia)
  │
  ├── LANGCHAIN_INTEGRATION.md
  │   └── Cómo integrar LangChain con RAG
  │
  └── BEST_PRACTICES.md
      └── Patrones que funcionan (de nuestro proyecto)

02-TECH-PACKS/FRONTEND/ ← Llenamos con:
  ├── FLUTTER_CLEAN_ARCH.md
  ├── RIVERPOD_STATE_MANAGEMENT.md
  └── DESKTOP_OPTIMIZATION.md

02-TECH-PACKS/AI_ENGINEERING/ ← Llenamos con:
  ├── OLLAMA_LOCAL_SETUP.md
  ├── CHROMADB_VECTORS.md
  └── PROMPTING_STRATEGIES.md
```

### Context Generator Integration

Mapear `WORKFLOW_RULES.yaml` a **prompts dinámicos**:

```
Usuario elige: "Backend = Python + FastAPI"
    ↓
Sistema busca en Tech Packs: "Backend/PYTHON_FASTAPI_SETUP.md"
    ↓
Inyecta Tech Pack en contexto RAG
    ↓
RAG genera templates + Tech Pack guidance
    ↓
"Aquí está el setup FastAPI + Best practices"
```

---

## 📊 El Estado Actual

| Componente | Estado | Líneas | Progreso |
|-----------|--------|--------|----------|
| **00-META** (Brain) | ✅ Completado | 228 | 100% |
| **01-TEMPLATES** (Plantillas) | ✅ Completado | 706 | 100% |
| **Knowledge Base Total** | ✅ Completado | 934 | 100% |
| **Documentación** | ✅ Completado | 630+ | 100% |
| **E2E Workflow Diagram** | ✅ Completado | 303 | 100% |
| **02-TECH-PACKS** (Contenido) | 🏗️ En progreso | 0 → ∞ | 0% |
| **Frontend (Flutter)** | 🏗️ En progreso | ~2000 | 60% |
| **Backend (Python)** | ✅ Completado | ~1500 | 100% |
| **Tests** | ✅ Funcionales | ~400 | 80% |
| **CI/CD Pipeline** | ✅ GitHub Actions | - | 100% |

---

## 💡 Por Qué Esto Importa

Estamos construyendo algo que **no existe en el mercado**:

### El Mercado Actual
- **Copilot:** Genera código sin arquitectura
- **ChatGPT:** Genera cualquier cosa sin garantía
- **Arquitectos externos:** Caros, lentos, difíciles de escalar
- **Herramientas low-code:** Te atrapan en su ecosistema

### Lo Que Nosotros Hacemos
- ✅ Genera **arquitectura verificada** (no alucinaciones)
- ✅ Genera **documentación completa** (no solo código)
- ✅ Funciona **offline** (tu privacidad es sagrada)
- ✅ Es **democratizado** (accessible a cualquier equipo)
- ✅ Es **auditable** (cada decisión documentada)
- ✅ Es **interactivo** (usuario tiene control total)

### El Impacto

Un junior con **SoftArchitect AI** puede tomar decisiones arquitectónicas que normalmente requieren un senior.

Un equipo remoto puede llegar a consenso sobre arquitectura en **2 horas** en lugar de 2 semanas.

Una startup puede **documentar completamente su proyecto** sin contratar a un arquitecto.

---

## 🧭 La Pregunta Fundamental

Si te hago una pregunta:

**"¿Qué quiero que haga un arquitecto por mi equipo?"**

La respuesta tradicional es:
```
- Decidir tecnologías
- Diseñar la estructura
- Asegurar calidad
- Documentar decisiones
```

**Nuestra respuesta es:**

```
"Que guíe CADA decisión técnica desde la idea hasta el deployment,
documentando TODO, sin ambigüedades, sin sorpresas, respetando
la privacidad del equipo, y que sea accesible a cualquiera,
en cualquier momento, sin depender de consultores externos caros."
```

Eso es **SoftArchitect AI**.

---

## 🎯 En Una Frase

**"El primer asistente de arquitectura verdaderamente offline, privado, interactivo y auditable para democratizar la ingeniería de software de calidad."**

---

**Última Actualización:** 30 de Enero de 2026
**Responsable:** ArchitectZero AI + Usuario
**Estado:** ✅ VISIÓN CLARA Y ARTICULADA
