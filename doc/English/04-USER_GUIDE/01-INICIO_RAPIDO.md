# 🚀 Quick Start - SoftArchitect AI

> **Reading Time:** 15 minutos
> **Level:** Beginner
> **Requirements:** Nothing, we'll start from scratch

---

## 📌 What is SoftArchitect AI?

SoftArchitect AI es tu **arquitecto de software personal**. Es una aplicación que te guía paso a paso para **convertir ideas en arquitectura técnica profesional** sin todas las decisiones abrumadoras.

### Instead of:
❌ "What stack should I use? ¿Flutter o React? ¿FastAPI o Django? ¿PostgreSQL o MongoDB?"

### It helps you:
✅ Definir primero **QUÉ** construirás (visión)
✅ Luego **POR QUÉ** en cada decisión (seguridad, escalabilidad)
✅ Luego **CÓMO** (arquitectura técnica)
✅ Finalmente **CUÁNDO** y **CON QUÉ CALIDAD**

---

## ⚡ Installation (2 minutos)

### Opción 1: Docker (Recomendado)

```bash
# 1. Clonar el proyecto
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2. Iniciar servicios
docker compose -f infrastructure/docker-compose.yml --env-file .env up -d

# 3. Abrir la aplicación
# URL: http://localhost:5000
# Esperar 30 segundos para que todo inicie
```

### Opción 2: Instalación Local

```bash
# Requisitos previos: Flutter 3.38.9+ (Dart 3.10.8+), Python 3.12+

# 1. Backend
cd src/server
pip install -r requirements.txt
python -m uvicorn app.main:app --reload

# 2. Frontend (en otra terminal)
cd src/client
flutter run -d windows/macos/linux
```

---

## 🎯 Tu Primer Project (5 minutos)

### Paso 1: Abre la App

Dirígete a **http://localhost:5000** (o ejecuta Flutter)

Verás la pantalla de inicio:

```
┌────────────────────────────┐
│ 🏗️ SoftArchitect AI        │
├────────────────────────────┤
│  + CREAR NUEVO PROYECTO    │
│    Mis Proyectos           │
│    Configuración           │
└────────────────────────────┘
```

### Paso 2: Crea un Project

Haz clic en **"+CREAR NUEVO PROYECTO"**

Completa:
- **Name:** "Mi App de Notas" (o cualquier idea que tengas)
- **Description:** "App para tomar notas colaborativas" (2-3 líneas)

Haz clic en **CREAR**

### Paso 3: Comienza la Conversación

La app te mostrará la vista de chat con un mensaje:

> **SoftArchitect AI:**
> "Hola, veo que quieres create 'Mi App de Notas'. Cuéntame más sobre tu visión: ¿Quién la usará? ¿Qué problema resuelve?"

### Paso 4: Responde

Escribe en el cuadro de chat:

> "Es una app para que mis colegas de trabajo compartan notas durante reuniones. Todos pueden editar al mismo tiempo. Debe ser rápida y segura."

Haz clic en **ENVIAR** (o presiona Ctrl+Enter)

### Paso 5: Observa la Magia 🪄

La IA analizará tu respuesta y generará:

✅ **PROJECT_MANIFESTO.md**
- Tu visión en document profesional
- Principios of the project
- Promesa al usuario

✅ **AGENTS.md**
- Roles in the project
- Responsabilidades

✅ **USER_JOURNEY_MAP.md**
- Cómo usa tu app el usuario final
- Contexto y necesidades

---

## 📚 El Master Workflow (4 Phases)

SoftArchitect te guía por 4 phases secuenciales. Cada una responde una pregunta:

### PHASE 1: Gobernanza e Identidad
**Pregunta:** ¿Cuál es el "Por qué"?
**Duración:** 10-15 minutos
**Documents:** 4 (Manifesto, Agents, Rules, User Journey)
**Result:** Todo el mundo entiende la visión

### PHASE 2: Especificación y Seguridad
**Pregunta:** ¿Cuál es el "Qué"?
**Duración:** 30 minutos
**Documents:** 3 (Requirements, User Stories, Security Policy)
**Result:** Criterios claros de aceptación

### PHASE 3: Arquitectura Técnica
**Pregunta:** ¿Cuál es el "Cómo"?
**Duración:** 45 minutos
**Documents:** 4 (Tech Stack, Structure Map, API Contract, Threat Model)
**Result:** Arquitectura técnica profesional

### PHASE 4: Planificación y Calidad
**Pregunta:** ¿Cuándo? ¿Con qué calidad?
**Duración:** 20 minutos
**Documents:** 2 (Roadmap Phases, Testing Strategy)
**Result:** Plan de ejecución y métricas de éxito

---

## 💡 Consejos Importantes

### ✅ DO's (Hazlo así)

1. **Sé específico en tus respuestas**
   - ❌ "App de chat"
   - ✅ "Chat en tiempo real para equipos remotos de máx 50 personas"

2. **Sigue las phases en orden**
   - No saltes de FASE 1 a FASE 3
   - Cada phase te preparapara la next

3. **Usa el chat para aclaraciones**
   - "¿Por qué recomiendas PostgreSQL y no MongoDB?"
   - La IA explicará sus decisiones

4. **Descarga los documents generados**
   - Úsalos como referencia en tu equipo
   - Son Copyright tuyo, haz lo que quieras

### ❌ DON'Ts (No lo hagas)

1. **No pidas código todavía**
   - Las primeras 3 phases son diseño puro
   - Si pides código ante de FASE 4, la IA te lo dirá (educadamente)

2. **No cambies decisiones sin documentar**
   - Si cambias de Flutter a React en medio, actualiza la FASE 3
   - La consistencia es importante

3. **No ignores las preguntas de clarificación**
   - Si la IA pregunta "¿Cloud o On-premises?", responde
   - Eso afecta toda tu arquitectura

---

## 🎨 Interfaz: Lo que Ves

### El Panel Izquierdo (Sidebar)

```
📁 Mi App de Notas
├─ 📄 FASE 1: Gobernanza ✅ (3 de 4 docs)
├─ 📄 FASE 2: Especificación ⏳ (0 de 3 docs)
├─ 📄 FASE 3: Arquitectura 🔒 (Bloqueada)
├─ 📄 FASE 4: Planificación 🔒 (Bloqueada)
├─ 💬 Historial de Chat
└─ ⚙️ Configuración
```

### El Panel Central (Chat)

- **Mensaje de arriba:** Última pregunta de la IA
- **Historial:** Tu conversación completa (scrolleable)
- **Cuadro de entrada:** Donde escribes
- **Button ENVIAR:** O Ctrl+Enter

### El Panel Derecho (Documents)

- **Preview** del document que la IA acaba de generar
- **Button DESCARGAR**
- **Button EDITAR** (si quieres ajustar manualmente)

---

## 🔑 Teclas de Atajo

| Atajo | Acción |
|-------|--------|
| `Ctrl+Enter` | Enviar mensaje |
| `Ctrl+D` | Descargar document actual |
| `Ctrl+.` | Abrir configuration |
| `Escape` | Cerrar diálogos |

---

## 🚨 Cuando algo No Funciona

### "La IA no entiende mi pregunta"
→ Sé más específico. Ej: En lugar de "quiero escalabilidad", di "Espero 10,000 usuarios concurrentes"

### "El chat está lento"
→ Puede ser que ChromaDB (la memoria) esté indexando (primeros 30 segundos)

### "Se desconectó"
→ Recarga la página (Ctrl+R). Tu chat se guarda automáticamente.

### "Quiero empezar de cero"
→ Crea un nuevo project. El previous se archiva.

---

## 📖 Documentación Completa

Para ir más allá de Quick Start:

- **[Guía de Instalación Completa](02-INSTALLATION.md)** - Todos los pasos para cada SO
- **[Master Workflow Detallado](04-MASTER_WORKFLOW.md)** - Explicación profunda de cada phase
- **[Interfaz de Chat](05-CHAT_INTERFACE.md)** - Cómo usar todas las opciones
- **[Streaming en Tiempo Real](06-STREAMING.md)** - Cómo funciona la IA streaming
- **[Persistencia y Guardado](07-PERSISTENCE.md)** - Dónde se guardan tus projects
- **[Resolución de Problemas](08-TROUBLESHOOTING.md)** - FAQ y soluciones
- **[Video Tutoriales](10-VIDEO_TUTORIALS.md)** - Links a videos paso a paso

---

## 🌟 ¿Qué Sigue?

Ahora que ya sabes:
1. ✅ Instalar la app
2. ✅ Create un project
3. ✅ Completar FASE 1

Tu próximo paso:

**→ Continúa en FASE 2 ("Especificación y Seguridad")**

La IA te pedirá que definas los requisitos funcionales y no-funcionales.

---

## 💬 Soporte

¿Preguntas?

- **GitHub Issues:** [github.com/Pitcher755/soft-architect-ai/issues](https://github.com/Pitcher755/soft-architect-ai/issues)
- **Documentación Técnica:** Ver folder `doc/English/01-PROJECT_REPORT`
- **FAQ:** [08-TROUBLESHOOTING.md](08-TROUBLESHOOTING.md)

---

**¡Bienvenido a SoftArchitect AI! 🚀 Vamos a construir algo extraordinario juntos.**

*Última actualización: 19/02/2026*
