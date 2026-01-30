# 🆔 Tech Profile: NestJS

> **Categoría:** Enterprise Node.js Framework
> **Filosofía:** "Angular para el Backend"
> **Stack Base:** Express o Fastify (Abstracted)
> **Paradigma:** Inyección de Dependencias + Decoradores
> **Versión Objetivo:** NestJS 10+

NestJS es el framework estándar para arquitecturas escalables en Node.js. Si Angular es el estándar frontend enterprise, NestJS es su contraparte backend.

---

## 📖 Tabla de Contenidos

1. [¿Por Qué NestJS?](#por-qué-nestjs)
2. [NestJS vs Express vs Fastify](#nestjs-vs-express-vs-fastify)
3. [Casos de Uso](#casos-de-uso)
4. [Pilares Técnicos](#pilares-técnicos)
5. [Stack SoftArchitect para Backend](#stack-softarchitect-para-backend)

---

## ¿Por Qué NestJS?

### El Problema: Express es Demasiado Flexible

Express es minimalista, flexible... y caótico. Cada equipo escribe código diferente.

```javascript
// ❌ Express: Sin convención
const express = require('express');
const app = express();

// ¿Dónde va la validación? ¿Dónde van los guards? ¿Dónde va el error handling?
app.post('/users', (req, res, next) => {
  if (!req.body.email) {
    return res.status(400).json({ error: 'Email required' });
  }

  // Validación manual 💀
  // Error handling manual 💀
  // Logging manual 💀

  const user = new User(req.body);
  user.save().then(u => res.json(u)).catch(err => {
    console.log(err); // ← Inconsistente
    res.status(500).json({ error: 'Server error' });
  });
});
```

### La Solución: NestJS

```typescript
// ✅ NestJS: Convención y Estructura
@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Post()
  @UseGuards(JwtAuthGuard)           // Seguridad declarativa
  @UsePipes(ValidationPipe)          // Validación automática
  create(@Body() createUserDto: CreateUserDto) {
    // Lógica pura: validación y error handling se hacen automáticamente
    return this.usersService.create(createUserDto);
  }
}
```

**Ventajas:**
- ✅ Estructura predecible (todos los equipos siguen el mismo patrón)
- ✅ Seguridad declarativa (Guards, Pipes)
- ✅ Validación automática (Decoradores)
- ✅ Error handling estándar (Exception Filters)
- ✅ DI integrado (inyección de dependencias)
- ✅ TypeScript first (tipos en todo)

---

## NestJS vs Express vs Fastify

| Aspecto | NestJS | Express | Fastify |
|:---|:---:|:---:|:---:|
| **Arquitectura** | Opinions + Modular | Minimal | Minimal |
| **Learning Curve** | Steep (pero predecible) | Gradual | Gradual |
| **Performance** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| **TypeScript** | ✅ Native | ⚠️ Manual | ⚠️ Manual |
| **Decoradores** | ✅ Native | ❌ No | ❌ No |
| **Dependency Injection** | ✅ Built-in | ❌ Manual | ❌ Manual |
| **Middleware** | ✅ Declarativa | ✅ Funcional | ✅ Funcional |
| **Validación** | ✅ Built-in | ❌ External | ❌ External |
| **Monolitos** | ✅ Perfecto | ✅ Sí | ✅ Sí |
| **Microservicios** | ✅ Native (gRPC, RabbitMQ) | ⚠️ Manual | ⚠️ Manual |
| **GraphQL** | ✅ Integrado | ❌ Externo | ❌ Externo |

### Decisión Simple

- ¿Prototipo rápido? → **Express** o **Fastify**
- ¿Equipo enterprise? → **NestJS**
- ¿Microservicios complejos? → **NestJS**
- ¿API REST simple? → **Express** (más ligero)

---

## Casos de Uso

### ✅ Ideal Para

| Caso | Por Qué |
|:---|:---|
| **Monolitos Modulares** | Sistemas grandes donde la organización de código es crítica. NestJS impone estructura. |
| **Equipos Múltiples** | Convención estándar previene "wild west code". |
| **APIs Empresariales** | Validación, auth, error handling automáticos. |
| **Microservicios** | Soporte nativo para transporte gRPC, RabbitMQ, Kafka, NATS. |
| **Fullstack Angular** | La curva de aprendizaje es casi nula si el equipo ya conoce Angular. |
| **GraphQL APIs** | Integración nativa con @nestjs/graphql. |

### ❌ No Usar Para

| Caso | Por Qué |
|:---|:---|
| **Serverless / AWS Lambda** | El Cold Start de NestJS (DI + Decoradores) puede ser alto. Mejor Express. |
| **Prototipos Hackathon** | Demasiado boilerplate para "Hola Mundo". Express es más rápido. |
| **APIs Ultra-Simples** | 3 endpoints CRUD? Express/Fastify son más directos. |
| **Máxima Performance Baja Latencia** | Fastify es más rápido (pero diferencia es microsegundos). |

---

## Pilares Técnicos

### 1. Decoradores

Metaprogramación para definir rutas, servicios y comportamientos sin código boilerplate.

```typescript
@Controller('users')                    // Define ruta base
export class UsersController {
  constructor(private service: UsersService) {} // DI automática

  @Get(':id')                          // GET /users/:id
  @UseGuards(JwtAuthGuard)             // Seguridad
  @UseInterceptors(LoggingInterceptor) // Logging
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }
}
```

### 2. Módulos

Encapsulamiento lógico. Un módulo exporta servicios que otros módulos pueden usar.

```typescript
@Module({
  imports: [DatabaseModule],           // Dependencias
  controllers: [UsersController],       // Rutas
  providers: [UsersService],           // Servicios (inyectables)
  exports: [UsersService]              // Lo que otros módulos pueden importar
})
export class UsersModule {}

// App.module.ts
@Module({
  imports: [UsersModule, AuthModule]   // Compone módulos
})
export class AppModule {}
```

### 3. Inyección de Dependencias

El framework crea instancias y las pasa automáticamente.

```typescript
// Sin DI: Acoplamiento fuerte
class UsersService {
  private db = new Database(); // ← Acoplado
}

// Con DI: Desacoplado
@Injectable()
class UsersService {
  constructor(private db: Database) {} // ← Inyectado
}

// El framework resuelve automáticamente
// const service = new UsersService(new Database());
```

---

## Stack SoftArchitect para Backend

```
Stack Recomendado (TRAMA 5.2 - NestJS Backend)
├── Framework: NestJS 10+
├── API: REST (default) o GraphQL (@nestjs/graphql)
├── ORM: TypeORM (@nestjs/typeorm)
├── Base de Datos: PostgreSQL (Relacional)
├── Authentication: JWT (@nestjs/jwt)
├── Validación: class-validator, class-transformer
├── Serialización: class-transformer
├── Testing: Jest (integrado)
├── Logging: Logger nativo (o Winston)
├── Documentación: Swagger (@nestjs/swagger)
└── Deployment: Docker + Kubernetes (opcional)
```

---

## Decisión de Adopción

✅ **SoftArchitect adopta NestJS como estándar para Backend Enterprise** bajo estas condiciones:

1. **Architecture:** Modular, Controllers → Services → Repositories
2. **Validation:** class-validator en todos los DTOs
3. **Authentication:** JWT con Guards declarativos
4. **Error Handling:** Exception Filters estándar
5. **Database:** TypeORM con Migrations
6. **Testing:** Jest con cobertura >80%
7. **Documentation:** Swagger auto-generado

---

## Ventajas Competitivas para SoftArchitect

1. **Simetría Frontend-Backend:** Angular ↔ NestJS (mismos principios: DI, Decoradores, Módulos)
2. **Enterprise Ready:** Seguridad, validación, error handling OOTB
3. **Microservicios:** Transporte nativo (gRPC, RabbitMQ, Kafka)
4. **Escalabilidad:** Estructura predecible permite crecimiento sin "refactoring catastrophe"
5. **TypeScript Puro:** 100% tipado, incluyendo tipos de DB

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ ADOPTED (Backend Standard)
**Responsable:** ArchitectZero AI Agent
