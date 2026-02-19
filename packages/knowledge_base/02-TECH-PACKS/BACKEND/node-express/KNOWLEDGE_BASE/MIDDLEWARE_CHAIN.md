# 🚂 Express Middleware Chain: The Art of Composition

> **Framework:** Express.js (Node.js)
> **Filosofía:** Middleware-First (Everything is middleware)
> **Version:** Express 4.18+
> **Paradigma:** Functional Composition

Express es un framework minimalista. La magia está en el orden de los middleware.

---

## 📖 Table of Contents

1. [Anatomía del Middleware](#anatomía-del-middleware)
2. [The Chain Order](#the-chain-order)
3. [Async Handler Wrapper](#async-handler-wrapper)
4. [Error Handling](#error-handling)
5. [Custom Middleware](#custom-middleware)
6. [Anti-Patterns](#anti-patterns)

---

## Anatomía del Middleware

### ¿Qué es un Middleware?

Una función con acceso a `req` (Request), `res` (Response), y `next` (Pasar la bola).

```typescript
import { Request, Response, NextFunction } from 'express'

// ✅ GOOD: Middleware básico
const logger = (req: Request, res: Response, next: NextFunction) => {
  console.log(`${req.method} ${req.path}`)
  next() // ← IMPORTANTE: Pasar el control al siguiente middleware
}

// ❌ BAD: Middleware que no llama next()
const badMiddleware = (req: Request, res: Response) => {
  console.log('Me olvidé de next()')
  // La request se queda "colgada"
}
```

### Terminar la Cadena

```typescript
// ✅ GOOD: Terminar con respuesta
const helloWorld = (req: Request, res: Response) => {
  res.json({ message: 'Hello World' })
  // No llamar next() si terminas la respuesta
}

// ✅ GOOD: Terminar con error
const errorHandler = (req: Request, res: Response) => {
  res.status(404).json({ error: 'Not Found' })
}
```

---

## The Chain Order

El **orden importa**. Express ejecuta middleware de arriba a abajo.

### Estructura Correcta

```typescript
import express, { Express, Request, Response, NextFunction } from 'express'
import cors from 'cors'
import helmet from 'helmet'
import morgan from 'morgan'

const app: Express = express()

// ============ 1. GLOBAL MIDDLEWARE (Antes de cualquier ruta) ============
app.use(cors())                    // CORS
app.use(helmet())                  // Security headers
app.use(express.json())            // Parse JSON body
app.use(express.urlencoded({ extended: true })) // Parse form data
app.use(morgan('combined'))        // HTTP logging

// ============ 2. MIDDLEWARES PERSONALIZADOS ============
const auth = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1]
  if (token) {
    req.user = verifyToken(token)  // Adjuntar user a request
  }
  next()
}

app.use(auth)

// ============ 3. RUTAS ============
app.get('/', (req, res) => {
  res.json({ message: 'Home' })
})

app.get('/api/users', (req, res) => {
  res.json({ users: [] })
})

// ============ 4. 404 HANDLER (Última ruta, se ejecuta si ninguna coincidió) ============
app.use((req: Request, res: Response) => {
  res.status(404).json({ error: 'Not Found', path: req.path })
})

// ============ 5. ERROR HANDLER (Debe tener 4 argumentos) ============
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error(err)
  res.status(500).json({
    error: err.message,
    timestamp: new Date().toISOString(),
  })
})

export default app
```

---

## Async Handler Wrapper

Express 4 **NO captura automáticamente** errores en funciones `async`. Usa un wrapper.

### Problema: Sin Wrapper

```typescript
// ❌ BAD: El error no se captura
app.get('/users', async (req, res) => {
  const users = await db.getUsers()  // Si falla aquí, Express NO lo captura
  res.json(users)
})

// El cliente recibe: "Internal Server Error" genérico
```

### Solución: AsyncHandler Wrapper

```typescript
// ✅ GOOD: Wrapper para capturar errores async
const asyncHandler =
  (fn: Function) => (req: Request, res: Response, next: NextFunction) =>
    Promise.resolve(fn(req, res, next)).catch(next)

app.get('/users', asyncHandler(async (req, res) => {
  const users = await db.getUsers()  // Si falla, se pasa a Error Handler
  res.json(users)
}))

// Alternativa: usar try/catch manualmente
app.get('/users', async (req, res, next) => {
  try {
    const users = await db.getUsers()
    res.json(users)
  } catch (err) {
    next(err)  // Pasar al Error Handler
  }
})
```

### Librería: `express-async-errors`

```typescript
// ✅ GOOD: Usar librería (más limpio)
import 'express-async-errors'

app.get('/users', async (req, res) => {
  const users = await db.getUsers()  // Los errores se capturan automáticamente
  res.json(users)
})
```

---

## Error Handling

### Global Error Handler

```typescript
// ✅ GOOD: Error handler centralizado
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  // Log del error
  console.error({
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  })

  // Responder al cliente
  res.status(500).json({
    error: {
      message: err.message || 'Internal Server Error',
      timestamp: new Date().toISOString(),
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    },
  })
})
```

### Custom Error Classes

```typescript
// ✅ GOOD: Errores tipados
export class NotFoundError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'NotFoundError'
  }
}

export class ValidationError extends Error {
  constructor(public errors: string[]) {
    super('Validation failed')
    this.name = 'ValidationError'
  }
}

// Usar en routes
app.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await db.user.findById(req.params.id)
  if (!user) {
    throw new NotFoundError(`User ${req.params.id} not found`)
  }
  res.json(user)
}))

// Error handler mejora do
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof NotFoundError) {
    return res.status(404).json({ error: err.message })
  }
  if (err instanceof ValidationError) {
    return res.status(422).json({ errors: err.errors })
  }
  res.status(500).json({ error: err.message })
})
```

---

## Custom Middleware

### Logger Personalizado

```typescript
// ✅ GOOD: Logger que registra timing
const requestLogger = (req: Request, res: Response, next: NextFunction) => {
  const start = Date.now()

  // Interceptar res.json para loguear respuesta
  const originalJson = res.json

  res.json = function(data: any) {
    const duration = Date.now() - start
    console.log({
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration: `${duration}ms`,
      timestamp: new Date().toISOString(),
    })
    return originalJson.call(this, data)
  }

  next()
}

app.use(requestLogger)
```

### Autenticación Middleware

```typescript
// ✅ GOOD: Auth middleware
const authenticate = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1]

  if (!token) {
    return res.status(401).json({ error: 'No token provided' })
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!)
    req.user = payload  // Adjuntar user a request
    next()
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' })
  }
}

app.get('/protected', authenticate, (req, res) => {
  res.json({ message: `Hello ${req.user?.id}` })
})
```

### Rate Limiting Middleware

```typescript
// ✅ GOOD: Simple rate limiter
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutos
  max: 100,                   // 100 requests máximo
  message: 'Too many requests from this IP',
})

app.use(limiter)

// O solo para ciertas rutas
app.post('/auth/login', rateLimit({ max: 5 }), (req, res) => {
  // ...
})
```

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: Olvidar `next()`

```typescript
// ❌ BAD: El middleware no pasa control
app.use((req, res, next) => {
  console.log('Request')
  // Se olvidó next()
})

app.get('/', (req, res) => {
  res.json({ message: 'Home' })  // Nunca se ejecuta
})

// ✅ GOOD: Llamar next()
app.use((req, res, next) => {
  console.log('Request')
  next()  // ← IMPORTANTE
})
```

### ❌ ANTI-PATTERN 2: Error Handler en Posición Equivocada

```typescript
// ❌ BAD: Error handler antes de rutas
app.use((err, req, res, next) => {
  res.status(500).json({ error: err.message })
})

app.get('/', (req, res) => {
  res.json({ message: 'Home' })
})

// ✅ GOOD: Error handler al final
app.get('/', (req, res) => {
  res.json({ message: 'Home' })
})

app.use((err, req, res, next) => {
  res.status(500).json({ error: err.message })
})
```

### ❌ ANTI-PATTERN 3: No Capturar Errores Async

```typescript
// ❌ BAD: Sin captura de errores
app.get('/users', async (req, res) => {
  const users = await db.getUsers()  // Error no capturado
  res.json(users)
})

// ✅ GOOD: Con captura
import 'express-async-errors'

app.get('/users', async (req, res) => {
  const users = await db.getUsers()
  res.json(users)
})
```

### ❌ ANTI-PATTERN 4: Middleware Global Innecesario

```typescript
// ❌ BAD: Aplicar middleware a todas las rutas
app.use(authenticateUser)
app.use(checkAdminRole)

app.get('/public', (req, res) => {
  res.json({ message: 'Public data' })  // No necesita auth
})

// ✅ GOOD: Aplicar solo donde sea necesario
app.get('/public', (req, res) => {
  res.json({ message: 'Public data' })
})

app.get('/admin', authenticateUser, checkAdminRole, (req, res) => {
  res.json({ message: 'Admin area' })
})
```

---

## Checklist: Express Middleware Bien Formada

```bash
# ✅ 1. Setup
[ ] Global middleware al inicio (CORS, JSON, Logger)
[ ] Rutas definidas en el medio
[ ] 404 handler antes de error handler
[ ] Error handler al final

# ✅ 2. Async Handling
[ ] express-async-errors importado
[ ] O usar asyncHandler wrapper
[ ] O try/catch manual con next(err)

# ✅ 3. Error Handling
[ ] Custom error classes
[ ] Error handler centralizado (4 params)
[ ] HTTP status codes correctos

# ✅ 4. Logging
[ ] Morgan o custom logger
[ ] Logging de errors
[ ] Timing incluido

# ✅ 5. Security
[ ] CORS configurado
[ ] Helmet para headers
[ ] Rate limiting en endpoints críticos
[ ] JWT en rutas protegidas

# ✅ 6. Performance
[ ] Middleware mínimos
[ ] No blocking operations
[ ] Compression para responses
```

---

**Date:** 30 de Enero de 2026
**Status:** ✅ MIDDLEWARE PATTERNS READY
**Responsable:** ArchitectZero AI Agent
