# 🔥 Firestore Data Modeling: NoSQL Principles

> **Motor:** Google Cloud Firestore (Document Store NoSQL)
> **Filosofía:** "Duplica datos, ahorra lecturas"
> **Paradigma:** Desnormalización (Opposite of SQL)
> **Date:** 30 de Enero de 2026

NoSQL requiere un cambio de mentalidad. Optimizamos para lectura, no para normalización.

---

## 📖 Table of Contents

1. [SQL vs NoSQL Mindset](#sql-vs-nosql-mindset)
2. [Colecciones vs Subcolecciones](#colecciones-vs-subcolecciones)
3. [Desnormalización: El Arte de Copiar](#desnormalización-el-arte-de-copiar)
4. [Patterns de Consulta](#patrones-de-consulta)
5. [Optimization de Escritura](#optimización-de-escritura)
6. [Anti-Patterns](#anti-patterns)

---

## SQL vs NoSQL Mindset

### Comparación Mental

| Concepto | SQL (Relacional) | Firestore (NoSQL) |
|:---|:---|:---|
| **Diseño** | Normalización (evitar duplicados) | **Desnormalización** (lectura rápida) |
| **Cambio de Datos** | Actualizar UN lugar (1 INSERT = todos ven cambio) | Múltiples lugares (eventual consistency) |
| **Queries Complejas** | `JOIN` con índices | Pre-unir datos en documento |
| **Esquema** | Rígido (migrations) | Flexible (JSON documents) |
| **Transacciones** | ACID garantizado | Limited (hasta 500 writes/transaction) |
| **Escalabilidad** | Vertical (servidor más grande) | **Horizontal** (cualquier cantidad de docs) |

### Regla de Oro

> **En SQL normalizas para NO duplicar datos.**
> **En NoSQL duplicas para lectura rápida.**

```typescript
// ❌ SQL Mindset (MAL en NoSQL)
// users/{userId}
{
  id: 'user-1',
  name: 'Ana',
  createdAt: '2026-01-30'
}

// posts/{postId}
{
  id: 'post-1',
  authorId: 'user-1',  // ← Referencia (JOIN necesario)
  content: 'Hello'
}

// Para mostrar un post CON el nombre del autor, necesitas:
// 1. Fetch post
// 2. Fetch user (segunda lectura)
// = 2 lecturas

// ✅ NoSQL Mindset (BIEN)
// posts/{postId}
{
  id: 'post-1',
  authorId: 'user-1',
  authorName: 'Ana',      // ← Duplicado (1 lectura)
  content: 'Hello'
}

// Mostrar post = 1 lectura (rápido)
// PERO: Si Ana cambia de nombre, actualizar TODOS sus posts (lento)
// Usa Cloud Functions para actualizaciones en batch
```

---

## Colecciones vs Subcolecciones

### Decisión: ¿Dónde guardo los Comentarios?

#### Opción A: Subcolección

```typescript
// Ruta: posts/{postId}/comments/{commentId}

// Estructura en Firestore:
collection('posts').doc('post-1').collection('comments').doc('comment-1')

// Documento:
{
  id: 'comment-1',
  text: 'Great post!',
  authorId: 'user-2',
  createdAt: timestamp
}
```

**Ventajas:**
- ✅ Escalabilidad infinita (sin límite de subcollections)
- ✅ Borrar post borra automáticamente comentarios
- ✅ Permisos granulares por post

**Desventajas:**
- ❌ Difícil query: "Todos los comentarios del usuario X" (Collection Group Query)
- ❌ Ruta anidada compleja

**Uso:** Cuando los comentarios PERTENECEN EXCLUSIVAMENTE al post.

#### Opción B: Top-Level Collection

```typescript
// Ruta: comments/{commentId}

// Documento:
{
  id: 'comment-1',
  postId: 'post-1',     // ← Referencia al post
  text: 'Great post!',
  authorId: 'user-2',
  createdAt: timestamp
}

// Índice compuesto: postId + createdAt
```

**Ventajas:**
- ✅ Query fácil: "Todos los comentarios del usuario X"
- ✅ Ruta simple
- ✅ Reutilizar comentarios (ej: citar en otro post)

**Desventajas:**
- ❌ Borrar post NO borra comentarios (limpieza manual)
- ❌ Sin límite de permisos por post

**Uso:** Cuando los comentarios son entidades propias (panel de moderación, análisis global).

### Recomendación SoftArchitect

```typescript
// Usar SUBCOLECCIONES para:
// - Comentarios de un post
// - Respuestas en un hilo
// - Detalles de una orden (order/{id}/items/{id})

// Usar TOP-LEVEL para:
// - Usuarios, Posts, Productos (entidades raíz)
// - Datos que necesitas queryear globalmente
// - Auditoría o logs
```

---

## Desnormalización: El Arte de Copiar

### Patrón 1: Autor en Post

**Problema:** Mostrar 100 posts con nombre del autor. Sin desnormalización = 101 lecturas.

```typescript
// ❌ Normalizado (Lento)
// posts/{id}
{
  authorId: 'user-1',  // Solo referencia
  content: 'Hello'
}

// Para renderizar: Fetch post + Fetch user = 2 lecturas por post = 200 lecturas

// ✅ Desnormalizado (Rápido)
// posts/{id}
{
  authorId: 'user-1',
  authorName: 'Ana',           // ← Copia
  authorAvatar: 'url...',      // ← Copia
  content: 'Hello'
}

// Para renderizar: 1 lectura por post = 100 lecturas
```

**Costo:** Si Ana cambia de nombre, actualizar todos sus posts con Cloud Function.

### Patrón 2: Últimos Comentarios en Post

```typescript
// En lugar de queryear posts/{id}/comments cada vez

// ✅ GOOD: Guardar últimos 3 comentarios en el post
// posts/{id}
{
  content: 'Hello World',
  lastComments: [
    { author: 'Bob', text: 'Nice!', createdAt: timestamp },
    { author: 'Alice', text: 'Thanks', createdAt: timestamp },
    { author: 'Charlie', text: 'Cool', createdAt: timestamp }
  ],
  commentCount: 42  // Contador para "Ver 39 más comentarios"
}

// Lectura: 1 documento = los últimos comentarios GRATIS
```

### Patrón 3: Estadísticas Precalculadas

```typescript
// ❌ SLOW: Calcular cada vez
// Para mostrar "Usuarios Activos Hoy", query todos los posts de hoy
// = lectura lenta

// ✅ FAST: Precalcular con Cloud Function
// stats/{date}
{
  date: '2026-01-30',
  activeUsers: 1542,
  postsCreated: 4821,
  commentsCreated: 15320,
  lastUpdated: timestamp
}

// Lectura: 1 documento = estadísticas INSTANT
```

---

## Patterns de Consulta

### Query Simple

```typescript
// Obtener posts de un usuario
const userPosts = await db
  .collection('posts')
  .where('authorId', '==', userId)
  .orderBy('createdAt', 'desc')
  .limit(10)
  .get()

const posts = userPosts.docs.map(doc => doc.data())
```

### Query Compuesta (Índice Requerido)

```typescript
// Obtener posts de usuario, solo sin replied
const unrepliedPosts = await db
  .collection('posts')
  .where('authorId', '==', userId)
  .where('replied', '==', false)
  .orderBy('createdAt', 'desc')
  .get()

// Firestore pedirá crear un índice compuesto
```

### Paginación (Cursor-Based)

```typescript
const PAGE_SIZE = 10

async function getPosts(lastDocument?: any) {
  let query = db
    .collection('posts')
    .orderBy('createdAt', 'desc')
    .limit(PAGE_SIZE + 1)

  if (lastDocument) {
    query = query.startAfter(lastDocument)
  }

  const snapshot = await query.get()
  const docs = snapshot.docs

  const hasMore = docs.length > PAGE_SIZE
  const posts = docs
    .slice(0, PAGE_SIZE)
    .map(doc => ({ id: doc.id, ...doc.data() }))

  return {
    posts,
    hasMore,
    lastDocument: docs[PAGE_SIZE - 1],  // Para siguiente página
  }
}
```

---

## Optimization de Escritura

### Batch Writes (Economizar escrituras)

```typescript
// ❌ SLOW: Escritura por escritura
await db.collection('posts').doc('post-1').update({ likes: 50 })
await db.collection('users').doc('user-1').update({ likeCount: 50 })

// 2 escrituras = 2 dineros

// ✅ FAST: Batch (1 escritura)
const batch = db.batch()

batch.update(db.collection('posts').doc('post-1'), { likes: 50 })
batch.update(db.collection('users').doc('user-1'), { likeCount: 50 })

await batch.commit()  // 1 escritura
```

### Increment Operator (Evitar Lectura-Escritura)

```typescript
// ❌ SLOW: Leer antes de escribir
const doc = await db.collection('posts').doc('post-1').get()
const currentLikes = doc.data().likes
await db.collection('posts').doc('post-1').update({
  likes: currentLikes + 1  // 1 lectura + 1 escritura
})

// ✅ FAST: Increment (solo escritura)
await db.collection('posts').doc('post-1').update({
  likes: increment(1)  // 1 escritura, sin lectura
})
```

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: Normalizar Todo

```typescript
// ❌ BAD: Demasiadas referencias
// posts/{id}
{
  authorId: 'user-1',           // Fetch user
  categoryId: 'cat-5',          // Fetch category
  tagIds: ['tag-1', 'tag-2'],   // Fetch tags
  content: 'Hello'
}

// Para renderizar: 1 + 1 + N lecturas = lento

// ✅ GOOD: Desnormalizar (copiar datos útiles)
{
  authorId: 'user-1',
  authorName: 'Ana',             // ← Copia
  category: { id: 'cat-5', name: 'Tech' },  // ← Copia
  tags: [{ id: 'tag-1', name: 'Vue' }],     // ← Copias
  content: 'Hello'
}
```

### ❌ ANTI-PATTERN 2: Arrayos Ilimitados

```typescript
// ❌ BAD: Array que crece infinito
// posts/{id}
{
  comments: [
    { text: 'comment 1' },
    { text: 'comment 2' },
    // ... 10,000 comentarios
  ]
}

// Firestore tiene límite de 1MB por documento
// Además, cada lectura = descargar todos los comentarios

// ✅ GOOD: Usar subcolecciones + últimos N en array
// posts/{id}
{
  commentCount: 10000,
  lastComments: [  // Solo últimos 3
    { text: 'comment 9998' },
    { text: 'comment 9999' },
    { text: 'comment 10000' }
  ]
}

// posts/{id}/comments/{id}  (subcolección para el resto)
```

### ❌ ANTI-PATTERN 3: Queries Complejas Sin Indexes

```typescript
// ❌ BAD: Query sin índice compuesto
const results = await db
  .collection('users')
  .where('active', '==', true)
  .where('country', '==', 'ES')
  .where('premiumTier', '==', 'gold')
  .get()

// Firestore lanza error y pide crear índice

// ✅ GOOD: Crear índice compuesto PRIMERO
// En Firebase Console: Firestore → Indexes
// O dejar que Firestore sugiera automáticamente
```

### ❌ ANTI-PATTERN 4: No Usar Timestamps

```typescript
// ❌ BAD: Strings como fechas
{
  createdAt: '2026-01-30'  // String no es ordenable correctamente
}

// ✅ GOOD: Usar Firestore Timestamp
import { serverTimestamp } from 'firebase/firestore'

{
  createdAt: serverTimestamp()  // Server timestamp, ordenable
}

// Query:
.orderBy('createdAt', 'desc')
```

---

## Checklist: Data Modeling Bien Formado

```bash
# ✅ 1. Design
[ ] Desnormalizar para lectura rápida
[ ] Colecciones vs subcolecciones decididas
[ ] Top-level para entidades raíz

# ✅ 2. Queries
[ ] Queries por campo principal (authorId, categoryId)
[ ] Indexes compuestos creados para multi-field queries
[ ] Paginación cursor-based implementada

# ✅ 3. Optimization
[ ] Batch writes para múltiples operaciones
[ ] Increment operator en contadores
[ ] Arrays limitados a N documentos

# ✅ 4. Consistency
[ ] Timestamps en todos los documentos
[ ] Lastupdate fields para sincronización
[ ] Cloud Functions para updates en batch

# ✅ 5. Scalability
[ ] Estructura escala sin JOIN
[ ] Sin hot collections (evitar contentión)
[ ] Sharding si es necesario

# ✅ 6. Security
[ ] Firestore Rules por colección
[ ] Datos sensibles en subcollections restringidas
```

---

**Date:** 30 de Enero de 2026
**Status:** ✅ NOSQL ARCHITECTURE READY
**Responsable:** ArchitectZero AI Agent
