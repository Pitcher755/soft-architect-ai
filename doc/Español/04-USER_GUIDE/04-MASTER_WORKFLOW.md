# 🗺️ El Master Workflow - Las 4 Fases de SoftArchitect AI

> **Fecha:** 19/02/2026
> **Estado:** ✅ Guía completa
> **Tiempo de lectura:** 15 minutos
> **Aplicable a:** Todos los proyectos

---

## 📖 Tabla de Contenidos

- [Visión General](#visión-general)
- [FASE 1: Gobernanza e Identidad](#fase-1-gobernanza-e-identidad)
- [FASE 2: Análisis y Diseño Arquitectónico](#fase-2-análisis-y-diseño-arquitectónico)
- [FASE 3: Planificación de Implementación](#fase-3-planificación-de-implementación)
- [FASE 4: Seguimiento y Optimización](#fase-4-seguimiento-y-optimización)
- [Diagrama Completo](#diagrama-completo)
- [Referencias](#referencias)

---

## 🎯 Visión General

SoftArchitect AI sigue un **Master Workflow de 4 Fases** que te guía desde la idea hasta la optimización continua.

### Metáfora Simple:
Imagina que construir un proyecto es como preparar un viaje:
- **FASE 1** = Decidir a dónde vamos (destino, por qué, quién viaja)
- **FASE 2** = Planificar la ruta (mapa, obstáculos, recursos)
- **FASE 3** = Preparar el viaje (equipaje, calendario, presupuesto)
- **FASE 4** = Durante y después del viaje (ajustes, aprender, mejorar)

### Duración Total:
| Fase | Duración | Usuarios | Salidas |
|------|----------|----------|---------|
| **FASE 1** | 45 min | Todos | Proyecto Manifesto + Análisis |
| **FASE 2** | 1.5 h | Líderes técnicos | Diagrama C4 + Patterns |
| **FASE 3** | 2 h | Líderes técnicos | Roadmap + Sprints |
| **FASE 4** | Continuo | Todos | KPIs + Retrospectivas |

---

## 🏛️ FASE 1: Gobernanza e Identidad

> **Pregunta principal:** ¿QUIÉN somos y POR QUÉ existimos?

### Objetivo
Definir la **identidad clara y compartida** del proyecto. Es el fundamento sobre el que se construye todo lo demás.

### Lo que Respondes (6 Preguntas)

```
1️⃣  ¿Cuál es tu propósito?
    └─ La razón de ser de tu proyecto

2️⃣  ¿Quiénes son tus usuarios?
    └─ A quién estás sirviendo

3️⃣  ¿Qué problema resuelves?
    └─ El status quo que cambias

4️⃣  ¿Cuál es tu diferencial?
    └─ Qué te hace único

5️⃣  ¿Cuál es tu horizonte?
    └─ Dónde quieres estar en 12 meses

6️⃣  ¿Cómo medirás éxito?
    └─ Tus KPIs iniciales
```

### Lo que SoftArchitect AI Genera

| Documentoo | Propósito | Uso |
|-----------|-----------|-----|
| **Mi Promesa (Proyecto Manifesto)** | Declaración de identidad | Comunicar visión al equipo |
| **Análisis de Viabilidad** | Evaluación crítica | Identificar riesgos temprano |
| **Matriz de Riesgos** | Mapa de amenazas | Crear plan de mitigación |
| **Análisis de Mercado** | Contexto competitivo | Entender oportunidades |
| **Roadmap 12 Meses** | Hitos principales | Planificar timeline |

### Ejemplo de Salida

```
═════════════════════════════════════════════════════
         EJEMPLO: PLATAFORMA DE BLOG ACADÉMICO
═════════════════════════════════════════════════════

📋 PROYECTO MANIFESTO
───────────────────────
Visión:   Una plataforma que celebra la colaboración académica
Misión:   Validar y compartir investigaciones de calidad
Valores:  Excelencia, Colaboración, Transparencia

📊 VIABILIDAD
───────────────────────
Técnica:     ⚠️ Moderada (6 meses, stack recomendado: Go+React)
Mercado:     ✅ Alta (TAM $2.3B, baja competencia directa)
Financiera:  ✅ Viable (ROI en 18 meses, $200K inversión)

⚠️ RIESGOS TOP 3
───────────────────────
1. Retención de usuarios (estrategia: gamificación)
2. Crecimiento lento inicial (estrategia: partnerships)
3. Escalabilidad técnica (estrategia: arquitectura cloud-native)

📈 OBJETIVOS 12 MESES
───────────────────────
├─ 1000 usuarios activos (MAU)
├─ 5000 artículos publicados
├─ 10 universidades asociadas
└─ NPS > 50
```

### Tiempo Estimado
- Responder preguntas: 15 minutos
- Análisis IA: 20 minutos
- Revisar resultados: 10 minutos
- **Total: 45 minutos**

### Cuándo Usar Esta Fase
✅ **Inicio de un proyecto nuevo**
✅ **Pivote en la dirección estratégica**
✅ **Cambios en el equipo de liderazgo**
✅ **Anualmente (revisión estratégica)**

---

## 🏗️ FASE 2: Análisis y Diseño Arquitectónico

> **Pregunta principal:** ¿CÓMO vamos a construirlo?

### Objetivo
Definir la **arquitectura técnica clara y escalable** del sistema. Transformar la visión en un plan técnico.

### Lo que Respondes (4 Dimensiones)

```
1️⃣  DOMINIOS: ¿Cuáles son las áreas principales?
    └─ Descomposición visual del sistema

2️⃣  PATRONES: ¿Qué patrones arquitectónicos usarás?
    └─ Monolito modular, microservicios, event-driven, etc.

3️⃣  DEPENDENCIAS: ¿Cuáles son las integraciones externas?
    └─ APIs, bases de datos, servicios en la nube

4️⃣  CONSTRAINTS: ¿Qué limitaciones técnicas existen?
    └─ Performance, seguridad, escalabilidad
```

### Lo que SoftArchitect AI Genera

| Documentoo | Propósito | Uso |
|-----------|-----------|-----|
| **Diagrama C4** | Visualización de arquitectura | Comunicar estructura a equipo |
| **Matriz de Patrones** | Decisiones arquitectónicas | Justificar tecnologías elegidas |
| **Análisis de Escalabilidad** | Proyecciones de crecimiento | Dimensionar infraestructura |
| **Evaluación de Riesgos Técnicos** | Amenazas OWASP, performance | Plan de mitigación |
| **Decisiones Técnicas (ADR)** | Registro de porqué | Base para futuras decisiones |

### Ejemplo de Salida (Diagrama C4 Simplificado)

```
NIVEL 1: CONTEXTO DEL SISTEMA
────────────────────────────
[Usuarios] ──→ [Sistema de Blog Académico] ──→ [Email Service]
[Admin]    ──→                          ──→ [Search Index]
                                        ──→ [Auth Provider]

NIVEL 2: CONTENEDOR
────────────────────────────
┌────────────────────────────────┐
│ Sistema de Blog Académico      │
├────────────────────────────────┤
│                                │
│  ┌──────────────────────────┐ │
│  │  Frontend Web (React)    │ │
│  │  - Interfaz de usuario   │ │
│  │  - Gestión de artículos  │ │
│  └──────────────────────────┘ │
│             ↓                  │
│  ┌──────────────────────────┐ │
│  │ Backend API (Go/FastAPI) │ │
│  │ - Autenticación          │ │
│  │ - Lógica de negocio      │ │
│  │ - Integración de datos   │ │
│  └──────────────────────────┘ │
│             ↓                  │
│  ┌──────────────────────────┐ │
│  │ Base de Datos (PostgreSQL)│ │
│  │ - Artículos              │ │
│  │ - Usuarios               │ │
│  │ - Comentarios            │ │
│  └──────────────────────────┘ │
│             ↓                  │
│  ┌──────────────────────────┐ │
│  │ Search Engine (Elastic)  │ │
│  │ - Índices de búsqueda    │ │
│  │ - Full-text search       │ │
│  └──────────────────────────┘ │
│                                │
└────────────────────────────────┘

NIVEL 3: COMPONENTES (Backend)
────────────────────────────────
[Auth Controller] ──→ [Auth Service]  ──→ [User Repository] ──→ [DB]
[Article Controller]──→[Article Service]─→ [Article Repository]──→ [DB]
[Comment Controller]──→[Comment Service]─→ [Comment Repository]──→ [DB]
```

### Patrones Arquitectónicos Comunes

| Patrón | Cuándo Usarlo | Ventajas | Desventajas |
|--------|---------------|----------|------------|
| **Monolito Modular** | Equipos <5, complejidad media | Simple, mantenible | Escalabilidad limitada |
| **Microservicios** | Equipos >8, alta escalabilidad | Escalable, independiente | Complejo, overhead |
| **Event-Driven** | Datos en tiempo real | Reactivo, flexible | Debugging difícil |
| **Serverless** | Carga impredecible | Bajo costo, sin ops | Latencia variable |

### Tiempo Estimado
- Definir dominios: 30 minutos
- Análisis arquitectónico: 40 minutos
- Revisar y refinar: 20 minutos
- **Total: 1.5 horas**

### Cuándo Usar Esta Fase
✅ **Después completar FASE 1**
✅ **Antes de escribir código**
✅ **Cambios significativos en requisitos**
✅ **Cuantiplicación de escala esperada**

---

## 📅 FASE 3: Planificación de Implementación

> **Pregunta principal:** ¿CUÁNDO lo construimos y CON QUÉ recursos?

### Objetivo
Convertir el diseño arquitectónico en un **plan de trabajo concreto** con sprints, estimaciones y asignación de recursos.

### Lo que Respondes (3 Dimensiones)

```
1️⃣  ROADMAP: ¿Cuál es el orden de implementación?
    └─ Fases de desarrollo, dependencias

2️⃣  SPRINTS: ¿Cuáles son los incrementos?
    └─ Historias de usuario, tamaños de sprint

3️⃣  RECURSOS: ¿Quién hace qué y con qué presupuesto?
    └─ Equipo, skills, costos, timeline
```

### Lo que SoftArchitect AI Genera

| Documentoo | Propósito | Uso |
|-----------|-----------|-----|
| **Roadmap Técnico** | Plan de desarrollo | Comunicar timeline a stakeholders |
| **Definición de Sprints** | User stories desglosadas | Asignar trabajo al equipo |
| **Matriz de Capacidad** | Velocidad del equipo | Estimar duración |
| **Presupuesto Detallado** | Costos por fase | Aprobación de inversión |
| **Plan de Riesgos** | Mitigación de retrasos | Contingencias planeadas |

### Ejemplo de Salida (Roadmap Simplificado)

```
ROADMAP TÉCNICO: PLATAFORMA DE BLOG ACADÉMICO
────────────────────────────────────────────────

🏃 SPRINT 0: SETUP INICIAL (2 semanas)
├─ Infraestructura base (Docker, CI/CD)
├─ Setup de base de datos
└─ ✅ ENTREGABLE: Pipeline de desarrollo operativo

🏃 SPRINT 1-3: MVP CORE (6 semanas)
├─ Autenticación y gestión de usuarios
├─ CRUD de artículos
├─ Sistema básico de comentarios
└─ ✅ ENTREGABLE: Blog funcional mínimo

🏃 SPRINT 4-5: CALIDAD Y UX (4 semanas)
├─ Sistema de búsqueda (Elasticsearch)
├─ Diseño responsivo mejorado
├─ Testing automatizado
└─ ✅ ENTREGABLE: Beta pública lista

🏃 SPRINT 6-8: GAMIFICACIÓN (6 semanas)
├─ Sistema de badges y puntos
├─ Recomendaciones personalizadas
├─ Estadísticas y analytics
└─ ✅ ENTREGABLE: Plataforma 1.0

📊 CRONOGRAMA TOTAL: 18 semanas ≈ 4.5 meses

RECURSOS ESTIMADOS:
├─ 2 Backend Engineers (tiempo completo)
├─ 1 Frontend Engineer (tiempo completo)
├─ 1 DevOps/Infrastructure (0.5 tiempo)
├─ 1 QA (0.5 tiempo)
└─ Total: $180K en costos de personal
```

### Métricas de Seguimiento (Burndown)

```
VELOCIDAD DEL EQUIPO: 35 puntos por sprint

Sprint 1:  ████████░░ 35 pts (100%)
Sprint 2:  ██████████ 35 pts (100%)
Sprint 3:  ████████░░ 32 pts (91%)
Sprint 4:  ██████████ 38 pts (109%)  ← Mejora de velocidad
Sprint 5:  ██████████ 36 pts (103%)
```

### Herramientas Recomendadas

- **Planificación:** Jira, Linear, GitHub Proyectos
- **Timeline:** Gantt charts, Roadmap tools
- **Seguimiento:** Burndown, velocity charts
- **Comunicación:** Sprint reviews, retrospectivas

### Tiempo Estimado
- Análisis de historias: 45 minutos
- Estimación y planificación: 50 minutos
- Validación con equipo: 25 minutos
- **Total: 2 horas**

### Cuándo Usar Esta Fase
✅ **Después completar FASE 2**
✅ **Antes de iniciar desarrollo**
✅ **Cada trimestre (replanificación)**
✅ **Cambios significativos en scope**

---

## 📊 FASE 4: Seguimiento y Optimización

> **Pregunta principal:** ¿CÓMO estamos haciendo y QUÉ aprendemos?

### Objetivo
Crear un **sistema de medición y mejora continua** que asegure que el proyecto cumple objetivos y se optimiza constantemente.

### Lo que Medirás (4 Áreas)

```
1️⃣  INDICADORES DE NEGOCIO (Business KPIs)
    └─ MAU, ARR, churn, engagement

2️⃣  INDICADORES TÉCNICOS (Technical KPIs)
    └─ Uptime, latencia, error rate, cobertura de tests

3️⃣  INDICADORES DE EQUIPO (Team KPIs)
    └─ Velocidad, calidad del código, moral

4️⃣  INDICADORES DE MERCADO (Market KPIs)
    └─ NPS, retención, adquisición
```

### Lo que Haces en FASE 4

| Actividad | Frecuencia | Propósito | Salida |
|-----------|-----------|----------|--------|
| **Sprint Review** | Cada 2 semanas | Demostrar progreso | Feedback |
| **Retrospectiva** | Cada 2 semanas | Aprender y mejorar | Action items |
| **Estado Report** | Semanal/mensual | Comunicar estado | Dashboard |
| **Análisis de Datos** | Mensual | Entender comportamiento | Insights |
| **Milestone Revisit** | Trimestral | Ajustar roadmap | Prioridades actualizadas |

### Ejemplo de Dashboard FASE 4

```
═════════════════════════════════════════════════════
    DASHBOARD: PLATAFORMA DE BLOG ACADÉMICO (MES 3)
═════════════════════════════════════════════════════

📈 BUSINESS KPIs
─────────────────────────────
Usuarios activos (MAU):      450/500    ✅ 90% del target
Artículos publicados:        285/300    ✅ 95% del target
Tasa de retención:           78%        ✅ Arriba del 70%
Net Promoter Score:          48         ⚠️ Casi 50 (target)

⚙️ TECHNICAL KPIs
─────────────────────────────
Uptime:                      99.8%      ✅ Excelente
Latencia P95:                320ms      ⚠️ Target 200ms
Error rate:                  0.12%      ✅ Bajo
Test coverage:               82%        ✅ 80% requerido

👥 TEAM KPIs
─────────────────────────────
Velocidad (puntos/sprint):   35         ✅ Consistente
Code review time:            4h         ✅ Dentro de tiempo
Deploy frequency:            3x/week    ✅ Frecuente

🎯 ACCIONES PARA MEJORAR
─────────────────────────────
1. ⚠️ Latencia P95: Optimizar query de búsqueda
2. ⚠️ NPS: Encuestar usuarios con baja puntuación
3. ✅ Mantener velocidad actual
4. ✅ Expandir test coverage a 90%
```

### Cadencia de Reuniones FASE 4

```
SEMANAL (30 min)
└─ Status standup
   └─ Bloqueadores, progreso

CADA 2 SEMANAS (1 h)
├─ Sprint Review (30 min)
│  └─ Demo de features
└─ Retrospectiva (30 min)
   └─ Qué salió bien, qué mejorar

MENSUAL (1 h)
└─ Business review
   └─ KPIs vs. targets

TRIMESTRAL (2 h)
└─ Roadmap review & Planning
   └─ Ajustes estratégicos
```

### Herramientas de Medición

- **Analytics:** Mixpanel, Amplitude, Google Analytics
- **APM:** New Relic, Datadog, Prometheus
- **Surveys:** Typeform, SurveySparrow
- **Dashboards:** Mixpanel, Grafana, Tableau

### Tiempo Estimado
- Ongoing (no es una fase de una sola vez)
- Dedicación continua: 5-10% del tiempo del equipo

### Cuándo Usar Esta Fase
✅ **Durante todo el desarrollo**
✅ **Después de cada sprint**
✅ **Continuamente (no termina)**
✅ **Feedback loop infinito**

---

## 📊 Diagrama Completo: Las 4 Fases

```
╔════════════════════════════════════════════════════════════════════╗
║            MASTER WORKFLOW: LAS 4 FASES DE SOFTARCHITECT AI        ║
╚════════════════════════════════════════════════════════════════════╝

┌──────────────────┐
│ FASE 1           │  ⏱️  45 minutos
│ GOBERNANZA       │  👥 Todos
│ e IDENTIDAD      │  ❓ ¿Quiénes somos?
└──────────────────┘
   6 Preguntas
   └─→ [Project Manifesto]
   └─→ [Análisis Viabilidad]
   └─→ [Matriz Riesgos]
   └─→ [Análisis Mercado]
   └─→ [Roadmap 12m]
        ↓
┌──────────────────┐
│ FASE 2           │  ⏱️  1.5 horas
│ ANÁLISIS Y       │  👥 Líderes técnicos
│ DISEÑO           │  ❓ ¿Cómo lo hacemos?
│ ARQUITECTÓNICO   │
└──────────────────┘
   4 Dimensiones
   └─→ [Diagrama C4]
   └─→ [Matriz Patrones]
   └─→ [Análisis Escalabilidad]
   └─→ [Evaluación Riesgos Técnicos]
   └─→ [Architecture Decision Records]
        ↓
┌──────────────────┐
│ FASE 3           │  ⏱️  2 horas
│ PLANIFICACIÓN    │  👥 Líderes técnicos
│ DE              │  ❓ ¿Cuándo y con qué?
│ IMPLEMENTACIÓN   │
└──────────────────┘
   3 Dimensiones
   └─→ [Roadmap Técnico]
   └─→ [Sprint Planning]
   └─→ [User Stories]
   └─→ [Matriz Capacidad]
   └─→ [Presupuesto Detallado]
        ↓
┌──────────────────┐
│ FASE 4           │  ⏱️  Continuo
│ SEGUIMIENTO      │  👥 Todos
│ y OPTIMIZACIÓN   │  ❓ ¿Cómo vamos?
└──────────────────┘
   4 Áreas
   └─→ [KPIs Negocio]
   └─→ [KPIs Técnicos]
   └─→ [KPIs Equipo]
   └─→ [KPIs Mercado]
   └─→ [Dashboard Vivo]
   └─→ [Retrospectivas]
   └─→ [Análisis Datos]
        │
        └─→ FEEDBACK LOOP (regresa a FASE 1, 2, o 3)
            ↓
            Mejora Continua ♻️
```

---

## 🔄 Feedback Loops: Cómo las Fases se Conectan

```
PROBLEMA TÍPICO: Los usuarios se van después de 2 semanas

DETECCIÓN (FASE 4):
  └─ KPI: Churn = 45% (target: <20%)

ANÁLISIS (FASE 4):
  └─ Surveys: "UI confusa", "Falta feature X"

ACCIÓN (← FASE 2):
  └─ Rediseñar arquitectura UI
  └─ Priorizar Feature X en próximo sprint

IMPLEMENTACIÓN (← FASE 3):
  └─ Actualizar roadmap
  └─ Asignar resources

EJECUCIÓN (FASE 3):
  └─ Desarrollar en Sprint N

MEDICIÓN (← FASE 4):
  └─ Medir nuevo churn en 4 semanas
  └─ ✅ Churn baja a 28% (mejora del 60%)

CICLO COMPLETO: 6-8 semanas
```

---

## 📚 Referencias

Para profundizar en cada fase, consulta:

- **FASE 1:** [Quick Start Guide](01-QUICK_START.md)
- **FASE 2:** [Architectural Patterns Guide](../02-SETUP_DEV/)
- **FASE 3:** [Implementación Planificación](../01-PROJECT_REPORT/)
- **FASE 4:** [KPIs & Metrics](../01-PROJECT_REPORT/)

---

## 🚀 Cómo Comenzar

### Tu Primer Proyecto (¡Hoy!)

1. ✅ **FASE 1:** Responde 6 preguntas (45 min)
2. ⏳ **FASE 2:** Define arquitectura (mañana, 1.5h)
3. ⏳ **FASE 3:** Plan de implementación (después, 2h)
4. ⏳ **FASE 4:** Mide y optimiza (continuamente)

### Estimado Total:
**≈ 5 horas para las 3 primeras fases**
**+ Optimización continua en FASE 4**

---

<p align="center">
  ✅ Entiendes ahora las 4 Fases
  <br/>
  🎯 Listo para: <a href="01-QUICK_START.md"><strong>Crear tu Proyecto</strong></a>
  <br/><br/>
  <a href="03-FIRST_PROJECT.md">← Mi Primer Proyecto</a> |
  <a href="05-CHAT_INTERFACE.md">Chat de la IA →</a>
</p>
