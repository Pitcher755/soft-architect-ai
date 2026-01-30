# 🛡️ NestJS Guards & Pipes: Seguridad y Validación Declarativa

> **Patrón:** Aspect-Oriented Programming (AOP)
> **Paradigma:** Decoradores para Seguridad & Validación
> **Nivel:** Enterprise Security

Guards y Pipes son mecanismos de NestJS para aplicar seguridad y validación de forma declarativa sin contaminar la lógica de negocio.

---

## 📖 Tabla de Contenidos

1. [Pipes: Validación y Transformación](#pipes-validación-y-transformación)
2. [Guards: Autenticación y Autorización](#guards-autenticación-y-autorización)
3. [Exception Filters: Error Handling](#exception-filters-error-handling)
4. [Interceptors: Response Transformation](#interceptors-response-transformation)
5. [Orden de Ejecución](#orden-de-ejecución)
6. [Patrones de Seguridad](#patrones-de-seguridad)

---

## Pipes: Validación y Transformación

### ¿Qué es un Pipe?

Un **Pipe** es middleware que:
1. **Valida** los datos entrantes
2. **Transforma** los datos si es necesario
3. **Rechaza** si la validación falla

### ValidationPipe Global (Obligatorio)

```typescript
// src/main.ts
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,                  // Elimina propiedades no decoradas
      forbidNonWhitelisted: true,       // Lanza error si envían basura extra
      transform: true,                  // Transforma tipos automáticamente
      transformOptions: {
        enableImplicitConversion: true,
      },
    })
  );

  await app.listen(3000);
}

bootstrap();
```

### DTOs con Validadores

```typescript
// src/features/users/dtos/create-user.dto.ts
import {
  IsEmail,
  IsString,
  MinLength,
  MaxLength,
  IsEnum,
  IsOptional,
  ValidateIf,
  Matches,
} from 'class-validator';

enum UserRole {
  USER = 'user',
  ADMIN = 'admin',
}

export class CreateUserDto {
  @IsString()
  @MinLength(3, { message: 'Name must be at least 3 characters' })
  @MaxLength(100)
  name: string;

  @IsEmail({}, { message: 'Invalid email format' })
  email: string;

  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, {
    message: 'Password must contain lowercase, uppercase, and number',
  })
  password: string;

  @IsOptional()
  @IsEnum(UserRole, { each: true })
  roles?: UserRole[];

  @IsOptional()
  @ValidateIf(o => o.phone !== undefined) // Validar solo si está presente
  @Matches(/^\d{10}$/, { message: 'Phone must be 10 digits' })
  phone?: string;
}

// Uso en Controller:
@Post()
async create(@Body() createUserDto: CreateUserDto) {
  // Si la validación falla, NestJS responde automáticamente con 400
  // {
  //   "statusCode": 400,
  //   "message": [
  //     "Password must contain lowercase, uppercase, and number"
  //   ],
  //   "error": "Bad Request"
  // }
  return this.usersService.create(createUserDto);
}
```

### Custom Pipes

```typescript
// src/pipes/parse-date.pipe.ts
import { Injectable, PipeTransform, BadRequestException } from '@nestjs/common';

@Injectable()
export class ParseDatePipe implements PipeTransform {
  transform(value: any): Date {
    const date = new Date(value);
    if (isNaN(date.getTime())) {
      throw new BadRequestException(`${value} is not a valid date`);
    }
    return date;
  }
}

// Uso:
@Get(':date')
async getEventsOnDate(@Param('date', ParseDatePipe) date: Date) {
  return this.eventService.findByDate(date);
}

// GET /events/2026-01-30 → date es Date object (transformado)
// GET /events/invalid-date → Error 400
```

---

## Guards: Autenticación y Autorización

### ¿Qué es un Guard?

Un **Guard** decide si una petición puede continuar o debe ser rechazada.

### 1. JWT Authentication Guard

```typescript
// src/core/auth/jwt.guard.ts
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request>();
    const token = this.extractToken(request);

    if (!token) {
      throw new UnauthorizedException('No token provided');
    }

    try {
      const payload = this.jwtService.verify(token, {
        secret: process.env.JWT_SECRET,
      });
      request['user'] = payload; // ← Disponible en @Req()
      return true;
    } catch (error) {
      throw new UnauthorizedException('Invalid token');
    }
  }

  private extractToken(request: Request): string | null {
    const authHeader = request.headers.authorization;
    return authHeader?.split(' ')[1] || null; // "Bearer TOKEN"
  }
}

// Uso:
@Controller('users')
export class UsersController {
  @UseGuards(JwtAuthGuard)
  @Get('me')
  getProfile(@Req() req: Request) {
    return req['user'];
  }
}
```

### 2. Roles Guard (Autorización)

```typescript
// src/core/auth/roles.decorator.ts
import { SetMetadata } from '@nestjs/common';

export const Roles = (...roles: string[]) => SetMetadata('roles', roles);

// src/core/auth/roles.guard.ts
import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.get<string[]>(
      'roles',
      context.getHandler(),
    );

    if (!requiredRoles) {
      return true; // ← Sin @Roles(), permitir acceso
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('No user in request');
    }

    const hasRole = requiredRoles.some(role => user.roles?.includes(role));

    if (!hasRole) {
      throw new ForbiddenException(
        `Required roles: ${requiredRoles.join(', ')}`
      );
    }

    return true;
  }
}

// Uso:
@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  @Delete(':id')
  @Roles('admin', 'superadmin')
  async remove(@Param('id') id: string) {
    return this.usersService.remove(id);
  }
}

// Solo admins pueden eliminar usuarios
```

### 3. Optional Auth Guard

```typescript
// src/core/auth/optional-jwt.guard.ts
import { Injectable } from '@nestjs/common';
import { JwtAuthGuard } from './jwt.guard';
import { ExecutionContext } from '@nestjs/common';

@Injectable()
export class OptionalJwtAuthGuard extends JwtAuthGuard {
  canActivate(context: ExecutionContext) {
    try {
      return super.canActivate(context);
    } catch {
      // Si falla el JWT, continúa sin usuario
      return true;
    }
  }
}

// Uso: Para endpoints que funcionan con o sin autenticación
@Get('posts')
@UseGuards(OptionalJwtAuthGuard)
async getPosts(@Req() req: Request) {
  // Si está autenticado, filtrar por usuario
  // Si no, mostrar posts públicos
  const userId = req['user']?.id;
  return this.postsService.find(userId);
}
```

---

## Exception Filters: Error Handling

### Global Exception Filter

```typescript
// src/core/exceptions/http-exception.filter.ts
import { ExceptionFilter, Catch, ArgumentsHost, HttpException } from '@nestjs/common';
import { Response } from 'express';

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const status = exception.getStatus();
    const exceptionResponse = exception.getResponse();

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: host.switchToHttp().getRequest().url,
      message: exceptionResponse['message'] || exception.message,
      ...(typeof exceptionResponse === 'object' && exceptionResponse),
    });
  }
}

// Registrar en main.ts:
app.useGlobalFilters(new HttpExceptionFilter());
```

### Custom Exception

```typescript
// src/core/exceptions/business.exception.ts
import { HttpException, HttpStatus } from '@nestjs/common';

export class BusinessException extends HttpException {
  constructor(message: string) {
    super(
      {
        statusCode: HttpStatus.UNPROCESSABLE_ENTITY,
        message,
        error: 'Business Logic Error',
      },
      HttpStatus.UNPROCESSABLE_ENTITY,
    );
  }
}

// Uso:
@Injectable()
export class UsersService {
  async create(createUserDto: CreateUserDto): Promise<User> {
    const existing = await this.userRepository.findByEmail(createUserDto.email);

    if (existing) {
      throw new BusinessException('Email already registered');
      // Respuesta: 422 Unprocessable Entity
    }

    return this.userRepository.save(createUserDto);
  }
}
```

---

## Interceptors: Response Transformation

### Logging Interceptor

```typescript
// src/core/interceptors/logging.interceptor.ts
import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, url } = request;
    const now = Date.now();

    return next.handle().pipe(
      tap(() => {
        const response = context.switchToHttp().getResponse();
        const duration = Date.now() - now;
        console.log(
          `${method} ${url} - ${response.statusCode} (${duration}ms)`
        );
      }),
    );
  }
}

// Registrar:
app.useGlobalInterceptors(new LoggingInterceptor());
```

### Transform Response Interceptor

```typescript
// src/core/interceptors/transform.interceptor.ts
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable()
export class TransformInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      map(data => ({
        statusCode: context.switchToHttp().getResponse().statusCode,
        timestamp: new Date().toISOString(),
        data,
      })),
    );
  }
}

// Todas las respuestas tendrán este formato:
// {
//   "statusCode": 200,
//   "timestamp": "2026-01-30T10:00:00.000Z",
//   "data": { ... }
// }
```

---

## Orden de Ejecución

NestJS ejecuta en este orden:

```
Request
  ↓
Middleware (express)
  ↓
Guards (¿puedo continuar?)
  ↓
Interceptors - Pre (antes de handler)
  ↓
Pipes (¿los datos son válidos?)
  ↓
Controller Handler
  ↓
Interceptors - Post (después de handler)
  ↓
Exception Filters (si hay error)
  ↓
Response
```

### Ejemplo Completo:

```typescript
@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
@UseInterceptors(LoggingInterceptor)
export class UsersController {
  @Post()
  @Roles('admin')
  async create(@Body() createUserDto: CreateUserDto) {
    // Orden de ejecución:
    // 1. LoggingInterceptor (inicio)
    // 2. JwtAuthGuard (verificar token)
    // 3. RolesGuard (verificar roles)
    // 4. ValidationPipe (validar DTO)
    // 5. Controller handler (create)
    // 6. LoggingInterceptor (fin)
    return this.usersService.create(createUserDto);
  }
}
```

---

## Patrones de Seguridad

### ✅ 1. JWT + Roles

```typescript
@UseGuards(JwtAuthGuard, RolesGuard)
@Delete(':id')
@Roles('admin', 'superadmin')
async remove(@Param('id') id: string) {
  // Solo admins
}
```

### ✅ 2. Rate Limiting

```typescript
// npm install @nestjs/throttler
import { ThrottlerGuard, Throttle } from '@nestjs/throttler';

@UseGuards(ThrottlerGuard)
@Throttle({ default: { limit: 10, ttl: 60000 } }) // 10 requests por minuto
@Post('/login')
async login(@Body() credentials: LoginDto) {
  return this.authService.login(credentials);
}
```

### ✅ 3. Permission-Based Access

```typescript
// src/core/auth/permission.guard.ts
export class PermissionGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const requiredPermission = this.reflector.get('permission', context.getHandler());

    return user.permissions?.includes(requiredPermission);
  }
}

// Uso:
@UseGuards(JwtAuthGuard, PermissionGuard)
@Put(':id')
@Permission('users:edit')
async update(@Param('id') id: string, @Body() dto: UpdateUserDto) {
  return this.usersService.update(id, dto);
}
```

---

## Checklist: Seguridad Bien Implementada

```bash
# ✅ 1. Validación
[ ] ValidationPipe global activado
[ ] DTOs con class-validator decorators
[ ] forbidNonWhitelisted: true
[ ] transform: true

# ✅ 2. Autenticación
[ ] JwtAuthGuard implementado
[ ] Tokens en header Authorization
[ ] Refresh tokens si es necesario

# ✅ 3. Autorización
[ ] RolesGuard para roles
[ ] PermissionGuard para permisos granulares
[ ] @Roles() decoradores en endpoints

# ✅ 4. Error Handling
[ ] Exception Filters globales
[ ] HTTP status codes correctos
[ ] Mensajes de error no exponen detalles sensibles

# ✅ 5. Rate Limiting
[ ] ThrottlerGuard en endpoints críticos
[ ] Limites en login/registro

# ✅ 6. Logging
[ ] LoggingInterceptor implementado
[ ] Eventos de seguridad loguedos
[ ] No loguear información sensible

# ✅ 7. CORS & Headers
[ ] CORS configurado correctamente
[ ] Helmet para headers de seguridad
[ ] CSP headers

# ✅ 8. Data Sensitivity
[ ] Passwords hasheados con bcrypt
[ ] DTOs excluyen datos sensibles
[ ] Sanitización de inputs
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ ENTERPRISE SECURITY PATTERNS
**Responsable:** ArchitectZero AI Agent
