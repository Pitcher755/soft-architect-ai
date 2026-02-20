# 💬 Interfaz de Chat - SoftArchitect AI

> **Date:** 19/02/2026
> **Status:** ✅ Guía de uso del chat
> **Reading Time:** 12 minutos

---

## 📖 Table of Contents

- [Introducción](#introducción)
- [Anatomía de la Interfaz](#anatomía-de-la-interfaz)
- [Cómo Escribir Prompts Efectivos](#cómo-escribir-prompts-efectivos)
- [Gestión de Contexto](#gestión-de-contexto)
- [Funciones Avanzadas](#funciones-avanzadas)
- [Atajos de Teclado](#atajos-de-teclado)
- [Ejemplos de Conversaciones](#ejemplos-de-conversaciones)

---

## 🎯 Introducción

La interfaz de chat es tu puerta de entrada al "cerebro" de SoftArchitect AI. A través de conversaciones naturales, puedes:

- ✅ **Diseñar arquitecturas** de software completas
- ✅ **Generar documentación** automatizada (ADRs, diagramas C4, etc.)
- ✅ **Explorar Tech Packs** y patrones de diseño
- ✅ **Refinar decisiones** iterativamente con feedback inteligente

---

## 🖥️ Anatomía de la Interfaz

```
┌────────────────────────────────────────────────────────────┐
│  [←]  Proyecto: Academic Blog Platform   [⚙️] [💾] [🗑️]   │  ← Barra superior
├────────────────────────────────────────────────────────────┤
│                                                            │
│  🤖 SoftArchitect AI:                                      │  ← Mensajes de la IA
│  "¡Hola! Comencemos definiendo tu proyecto.               │
│   ¿Qué problema estás tratando de resolver?"              │
│                                                            │
│                        👤 Tú:                              │  ← Tus mensajes
│                        "Necesito una plataforma para...    │
│                                                            │
│  🤖 SoftArchitect AI:                                      │
│  "Entendido. Ahora hablemos de requisitos..."             │
│                                                            │
│  [📎 C4_DIAGRAM.md] [📎 USER_STORIES.md] ← Archivos       │  ← Archivos generados
│                                                            │
├────────────────────────────────────────────────────────────┤
│  [Escribe tu mensaje aquí...]                  [➤ Enviar] │  ← Input de texto
│  💡 Sugerencia: "Añadir un módulo de notificaciones"      │  ← Sugerencias
└────────────────────────────────────────────────────────────┘
```

### Elementos Clave

| Elemento | Función |
|----------|---------|
| **Barra superior** | Navegación, configuration, acciones rápidas |
| **Área de mensajes** | Histórico de conversación |
| **Files adjuntos** | Documents generados (clickeables) |
| **Input de texto** | Campo de escritura con sugerencias inteligentes |
| **Button Enviar** | Enviar pregunta (o `Ctrl+Enter`) |

---

## 📝 Cómo Escribir Prompts Efectivos

### Principio SPEC (Específico, Preciso, Explicativo, Contextual)

#### ❌ Prompt Genérico (Malo)
```
"Necesito una base de datos"
```

**Problema:** Demasiado vago. La IA no tiene contexto suficiente.

---

#### ✅ Prompt Específico (Bueno)
```
"Necesito una base de datos para almacenar:
- Posts de blog (título, contenido, fecha)
- Comentarios (usuario, texto, timestamp)
- Usuarios (nombre, email, contraseña hasheada)

Requisitos:
- 1000 usuarios concurrentes esperados
- Búsqueda full-text en posts
- Backups diarios automatizados
- Cumplimiento GDPR (datos en EU)

Experiencia del equipo: PostgreSQL y MongoDB

¿Cuál recomiendas y por qué?"
```

**Result:** La IA tiene contexto suficiente para dar una recomendación fundamentada.

---

### Estructura de Prompts Recomendada

```markdown
**Contexto:** [Descripción del problema]
**Restricciones:** [Limitaciones técnicas/negocio]
**Objetivo:** [Qué quieres lograr]
**Preferencias:** [Opciones que ya consideraste]
```

#### Ejemplo Real

```
**Contexto:** Estoy diseñando una app de gestión de tareas para equipos remotos.

**Restricciones:**
- Presupuesto: $0 (open source preferido)
- Equipo: 2 devs junior en Python
- Plazo: 3 meses para MVP

**Objetivo:** Decidir stack backend (API REST)

**Preferencias:**
- Ya usamos Flask en otros proyectos
- Considerando FastAPI por performance
- No queremos Node.js (equipo Python-only)

¿FastAPI o Flask? ¿Otros factores a considerar?
```

---

## 🧠 Gestión de Contexto

### ¿Qué es el Contexto?

El **contexto** es la "memoria" de la conversación. La IA recuerda:
- ✅ Mensajes previos (últimos 10 por defecto)
- ✅ Decisiones arquitectónicas tomadas
- ✅ Tech Packs mencionados
- ✅ Files generados

### Ventana de Contexto

```
┌─────────────────────────────────────┐
│  Contexto (8192 tokens)             │
│  ┌───────────────────────────────┐  │
│  │ Tech Pack: Python-FastAPI     │  │ ← Cargado automáticamente
│  ├───────────────────────────────┤  │
│  │ Tu mensaje 1: "App de blog"   │  │ ← Mensajes recientes
│  │ IA: "¿Usuarios concurrentes?"  │  │
│  │ Tu mensaje 2: "1000 usuarios"  │  │
│  └───────────────────────────────┘  │
│                                     │
│  [Últimos 10 mensajes incluidos]   │
└─────────────────────────────────────┘
```

### Limpiar Contexto

**Cuándo hacerlo:**
- Conversación se desvió del tema original
- IA empieza a dar respuestas contradictorias
- Cambias de phase (Ej: Governance → Architecture)

**Cómo hacerlo:**
1. Click en `[🗑️]` (button limpiar)
2. Confirmar: "Esto borrará el historial actual"
3. La IA reinicia con contexto limpio

**⚠️ Advertencia:** Decisiones previas NO se borran (están guardadas en files).

---

## ⚡ Funciones Avanzadas

### 1. **Streaming de Respuestas**

Las respuestas aparecen **palabra por palabra** en tiempo real.

**Ventajas:**
- Feedback inmediato
- Puedes interrumpir si la respuesta se desvía

**Interrumpir streaming:**
Click en `[⏹️ Detener]` o presiona `Esc`

---

### 2. **Files Generados Inline**

La IA genera files Markdown automáticamente:

```
🤖 SoftArchitect AI:
"He creado un diagrama C4 para tu arquitectura."

[📎 C4_CONTEXT_DIAGRAM.md] ← Clickeable
```

**Acciones disponibles:**
- **Click:** Abre en editor integrado
- **Hover:** Vista previa rápida
- **Right-click:** Descargar, copiar link, delete

---

### 3. **Sugerencias Inteligentes**

El sistema detecta patrones y sugiere next steps:

```
💡 Sugerencia: "Parece que aún no definiste los requisitos no funcionales.
   ¿Quieres que te ayude con eso?"

[Sí, ayúdame] [No, gracias]
```

---

### 4. **Modo Multi-Canal**

Conversaciones paralelas por phase:

```
Canales:
├── #governance        (Activo)
├── #architecture      (3 mensajes)
└── #implementation    (Vacío)
```

**Cambiar canal:**
Click en el nombre del canal en la barra superior.

---

## ⌨️ Atajos de Teclado

| Atajo | Función |
|-------|---------|
| `Ctrl + Enter` | Enviar mensaje |
| `Ctrl + K` | Limpiar input |
| `Ctrl + L` | Limpiar contexto |
| `Esc` | Detener streaming |
| `Ctrl + ↑/↓` | Navegar historial |
| `Ctrl + S` | Guardar conversación |
| `Ctrl + N` | Nuevo project |

---

## 💬 Ejemplos de Conversaciones

### Ejemplo 1: Diseño de API REST

**👤 Tú:**
```
Necesito diseñar una API REST para un sistema de reservas de hotel.

Endpoints principales:
- GET /rooms (listar habitaciones)
- POST /bookings (crear reserva)
- GET /bookings/:id (consultar reserva)

¿Qué estructura de datos recomiendas para las respuestas?
```

**🤖 SoftArchitect AI:**
```
Para una API REST de reservas de hotel, recomiendo seguir el estándar JSONAPI
con la siguiente estructura:

GET /rooms
{
  "data": [
    {
      "type": "room",
      "id": "101",
      "attributes": {
        "number": 101,
        "type": "double",
        "price": 120.00,
        "available": true
      }
    }
  ],
  "meta": {
    "total": 50,
    "page": 1
  }
}

¿Quieres que te genere el contrato OpenAPI completo?
```

---

### Ejemplo 2: Selección de Patrón de Arquitectura

**👤 Tú:**
```
Tengo una app de ecommerce con 3 microservicios:
- Catálogo de productos
- Gestión de pedidos
- Pagos

¿Cómo deben comunicarse entre sí?
```

**🤖 SoftArchitect AI:**
```
Para microservicios de ecommerce, recomiendo:

**Comunicación Síncrona (REST):**
- Catálogo → ? (no necesita comunicarse)

**Comunicación Asíncrona (Message Broker):**
- Pedidos → Pagos (vía RabbitMQ/Kafka)
  - Evento: "OrderCreated" → trigger pago
  - Evento: "PaymentCompleted" → actualizar estado pedido

**Razones:**
1. Desacoplamiento: Si el servicio de Pagos cae, los pedidos se encolan
2. Trazabilidad: Eventos auditables
3. Escalabilidad: Puedes tener múltiples consumidores

¿Quieres que te genere un diagrama de secuencia?
```

---

### Ejemplo 3: Refinamiento Iterativo

**👤 Tú:**
```
¿Cuál es mejor: MongoDB o PostgreSQL para mi app de blog?
```

**🤖 SoftArchitect AI:**
```
Para responder con precisión, necesito saber:

1. ¿Cuántos usuarios concurrentes esperas?
2. ¿Necesitas búsqueda full-text?
3. ¿Relaciones complejas entre datos? (ej: usuarios → posts → comentarios)
4. ¿Experiencia del equipo con SQL/NoSQL?
```

**👤 Tú:**
```
1. 1000 usuarios concurrentes
2. Sí, búsqueda en título y contenido de posts
3. Sí, usuarios tienen posts, posts tienen comentarios
4. Equipo sabe SQL básico, no sabemos NoSQL
```

**🤖 SoftArchitect AI:**
```
**Recomendación: PostgreSQL**

**Razones:**
✅ Relaciones bien definidas (users → posts → comments) → SQL es natural
✅ Búsqueda full-text nativa con pg_trgm y ts_vector
✅ ACID garantiza integridad (crítico para contenido publicado)
✅ Equipo ya sabe SQL → curva de aprendizaje baja

MongoDB sería mejor si:
❌ Datos muy heterogéneos o sin esquema fijo
❌ Escalabilidad horizontal crítica (sharding)
❌ Operaciones de lectura > 10:1 vs escritura

[📎 POSTGRES_SETUP.md] generado con configuración óptima
```

---

## 📚 Documents Relacionados

- [Master Workflow](04-MASTER_WORKFLOW.md) - Entender las 4 phases
- [Streaming](06-RESPUESTAS_STREAMING.md) - Detalles técnicos del streaming
- [Solución de Problemas](08-SOLUCIÓN_DE_PROBLEMAS.md) - Si la IA no responde

---

<p align="center">
  <a href="06-RESPUESTAS_STREAMING.md">Streaming de Respuestas →</a> |
  <a href="04-MASTER_WORKFLOW.md">← Master Workflow</a>
</p>
