# 💬 Chat Interface - SoftArchitect AI

> **Fecha:** 02/19/2026
> **Estado:** ✅ Chat usage guide
> **Tiempo de lectura:** 12 minutes

---

## 📖 Tabla de Contenidos

- [Introduction](#introduction)
- [Interface Anatomy](#interface-anatomy)
- [How to Write Effective Prompts](#how-to-write-effective-prompts)
- [Context Management](#context-management)
- [Avanzado Features](#advanced-features)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Conversation Examples](#conversation-examples)

---

## 🎯 Introduction

The chat interface is your gateway to the "brain" of SoftArchitect AI. Through natural conversations, you can:

- ✅ **Design complete software architectures**
- ✅ **Generate automated documentoation** (ADRs, C4 diagrams, etc.)
- ✅ **Explore Tech Packs** and design patterns
- ✅ **Refine decisions** iteratively with intelligent feedback

---

## 🖥️ Interface Anatomy

```
┌────────────────────────────────────────────────────────────┐
│  [←]  Project: Academic Blog Platform   [⚙️] [💾] [🗑️]   │  ← Top bar
├────────────────────────────────────────────────────────────┤
│                                                            │
│  🤖 SoftArchitect AI:                                      │  ← AI messages
│  "Hello! Let's start by defining your project.            │
│   What problem are you trying to solve?"                   │
│                                                            │
│                        👤 You:                             │  ← Your messages
│                        "I need a platform for...           │
│                                                            │
│  🤖 SoftArchitect AI:                                      │
│  "Understood. Now let's talk about requirements..."       │
│                                                            │
│  [📎 C4_DIAGRAM.md] [📎 USER_STORIES.md] ← Files          │  ← Generated files
│                                                            │
├────────────────────────────────────────────────────────────┤
│  [Type your message here...]                    [➤ Send]   │  ← Text input
│  💡 Suggestion: "Add a notifications module"               │  ← Suggestions
└────────────────────────────────────────────────────────────┘
```

### Key Elements

| Element | Function |
|---------|----------|
| **Top bar** | Navigation, settings, quick actions |
| **Message area** | Conversation history |
| **Attached archivos** | Generated documentos (clickable) |
| **Text input** | Writing field with smart suggestions |
| **Send botón** | Send question (or `Ctrl+Enter`) |

---

## 📝 How to Write Effective Prompts

### SPEC Principle (Specific, Precise, Explanatory, Contextual)

#### ❌ Generic Prompt (Bad)
```
"I need a database"
```

**Problem:** Too vague. AI doesn't have enough context.

---

#### ✅ Specific Prompt (Good)
```
"I need a database to store:
- Blog posts (title, content, date)
- Comments (user, text, timestamp)
- Users (name, email, hashed password)

Requirements:
- 1000 concurrent users expected
- Full-text search on posts
- Automated daily backups
- GDPR compliance (data in EU)

Team experience: PostgreSQL and MongoDB

Which do you recommend and why?"
```

**Resultado:** AI has enough context to give a well-founded recommendation.

---

### Recommended Prompt Structure

```markdown
**Context:** [Problem description]
**Constraints:** [Technical/business limitations]
**Goal:** [What you want to achieve]
**Preferences:** [Options you already considered]
```

#### Real Example

```
**Context:** I'm designing a task management app for remote teams.

**Constraints:**
- Budget: $0 (open source preferred)
- Team: 2 junior devs in Python
- Timeline: 3 months for MVP

**Goal:** Decide backend stack (REST API)

**Preferences:**
- We already use Flask in other projects
- Considering FastAPI for performance
- Don't want Node.js (Python-only team)

FastAPI or Flask? Other factors to consider?
```

---

## 🧠 Context Management

### Qué es Context?

**Context** is the conversation "memory". The AI remembers:
- ✅ Anterior messages (last 10 by default)
- ✅ Architectural decisions made
- ✅ Mentioned Tech Packs
- ✅ Generated archivos

### Context Window

```
┌─────────────────────────────────────┐
│  Context (8192 tokens)              │
│  ┌───────────────────────────────┐  │
│  │ Tech Pack: Python-FastAPI     │  │ ← Automatically loaded
│  ├───────────────────────────────┤  │
│  │ Your message 1: "Blog app"    │  │ ← Recent messages
│  │ AI: "Concurrent users?"        │  │
│  │ Your message 2: "1000 users"   │  │
│  └───────────────────────────────┘  │
│                                     │
│  [Last 10 messages included]        │
└─────────────────────────────────────┘
```

### Clear Context

**When to do it:**
- Conversation drifted from original topic
- AI starts giving contradictory responses
- You change fase (e.g., Governance → Architecture)

**How to do it:**
1. Click `[🗑️]` (clear botón)
2. Confirm: "This will eliminar current history"
3. AI restarts with clean context

**⚠️ Warning:** Anterior decisions are NOT eliminard (saved in archivos).

---

## ⚡ Avanzado Features

### 1. **Response Streaming**

Responses appear **word by word** in real time.

**Advantages:**
- Immediate feedback
- Can interrupt if response drifts

**Interrupt streaming:**
Click `[⏹️ Stop]` or press `Esc`

---

### 2. **Inline Generated Archivos**

AI generates Markdown archivos automatically:

```
🤖 SoftArchitect AI:
"I've created a C4 diagram for your architecture."

[📎 C4_CONTEXT_DIAGRAM.md] ← Clickable
```

**Available actions:**
- **Click:** Open in integrated editor
- **Hover:** Quick preview
- **Right-click:** Download, copy link, eliminar

---

### 3. **Smart Suggestions**

System detects patterns and suggests siguiente steps:

```
💡 Suggestion: "It seems you haven't defined non-functional requirements yet.
   Want me to help with that?"

[Yes, help me] [No, thanks]
```

---

### 4. **Multi-Channel Mode**

Parallel conversations per fase:

```
Channels:
├── #governance        (Active)
├── #architecture      (3 messages)
└── #implementation    (Empty)
```

**Switch channel:**
Click on channel name in top bar.

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Function |
|----------|----------|
| `Ctrl + Enter` | Send message |
| `Ctrl + K` | Clear input |
| `Ctrl + L` | Clear context |
| `Esc` | Stop streaming |
| `Ctrl + ↑/↓` | Navigate history |
| `Ctrl + S` | Save conversation |
| `Ctrl + N` | New proyecto |

---

## 💬 Conversation Examples

### Example 1: REST API Design

**👤 You:**
```
I need to design a REST API for a hotel booking system.

Main endpoints:
- GET /rooms (list rooms)
- POST /bookings (create booking)
- GET /bookings/:id (check booking)

What data structure do you recommend for responses?
```

**🤖 SoftArchitect AI:**
```
For a hotel booking REST API, I recommend following the JSONAPI standard
with this structure:

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

Want me to generate the complete OpenAPI contract?
```

---

### Example 2: Architecture Pattern Selection

**👤 You:**
```
I have an ecommerce app with 3 microservices:
- Product catalog
- Order management
- Payments

How should they communicate with each other?
```

**🤖 SoftArchitect AI:**
```
For ecommerce microservices, I recommend:

**Synchronous Communication (REST):**
- Catalog → ? (doesn't need to communicate)

**Asynchronous Communication (Message Broker):**
- Orders → Payments (via RabbitMQ/Kafka)
  - Event: "OrderCreated" → trigger payment
  - Event: "PaymentCompleted" → update order status

**Reasons:**
1. Decoupling: If Payment service goes down, orders queue up
2. Traceability: Auditable events
3. Scalability: Can have multiple consumers

Want me to generate a sequence diagram?
```

---

### Example 3: Iterative Refinement

**👤 You:**
```
Which is better: MongoDB or PostgreSQL for my blog app?
```

**🤖 SoftArchitect AI:**
```
To answer accurately, I need to know:

1. How many concurrent users do you expect?
2. Need full-text search?
3. Complex data relationships? (e.g., users → posts → comments)
4. Team experience with SQL/NoSQL?
```

**👤 You:**
```
1. 1000 concurrent users
2. Yes, search on post title and content
3. Yes, users have posts, posts have comments
4. Team knows basic SQL, don't know NoSQL
```

**🤖 SoftArchitect AI:**
```
**Recommendation: PostgreSQL**

**Reasons:**
✅ Well-defined relationships (users → posts → comments) → SQL is natural
✅ Native full-text search with pg_trgm and ts_vector
✅ ACID guarantees integrity (critical for published content)
✅ Team already knows SQL → low learning curve

MongoDB would be better if:
❌ Very heterogeneous data or no fixed schema
❌ Critical horizontal scalability (sharding)
❌ Read operations > 10:1 vs writes

[📎 POSTGRES_SETUP.md] generated with optimal configuration
```

---

## 📚 Related Documentos

- [Master Workflow](04-MASTER_WORKFLOW.md) - Understand the 4 fases
- [Streaming](06-STREAMING_RESPONSES.md) - Technical streaming details
- [Troubleshooting](08-TROUBLESHOOTING.md) - If AI doesn't respond

---

<p align="center">
  <a href="06-STREAMING_RESPONSES.md">Streaming Responses →</a> |
  <a href="04-MASTER_WORKFLOW.md">← Master Workflow</a>
</p>
