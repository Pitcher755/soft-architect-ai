# 🏗️ NestJS Module Architecture

> **Pattern:** Domain-Driven Module Design
> **Principio:** One Module = One Domain Aggregate
> **Nivel:** Enterprise-Grade Modular Monolith

Cómo estructurar una feature completa en NestJS manteniendo límites de módulos claros.

---

## 📖 Tabla de Contenidos

1. [The Triad: Module - Controller - Service](#the-triad-module---controller---service)
2. [Repository Pattern](#repository-pattern)
3. [DTOs: Input & Output](#dtos-input--output)
4. [Entity & Domain Model](#entity--domain-model)
5. [Módulos Anidados](#módulos-anidados)
6. [Best Practices](#best-practices)

---

## The Triad: Module - Controller - Service

Cada feature sigue el patrón: **Module** → **Controller** → **Service** → **Repository** → **Entity**.

### 1. Entity: La Base de Datos

```typescript
// src/features/users/entities/user.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'varchar', unique: true })
  email: string;

  @Column({ type: 'varchar', length: 255 })
  password: string; // Hashed

  @Column({ type: 'varchar', array: true, default: [] })
  roles: string[];

  @CreateDateColumn()
  createdAt: Date;
}
```

### 2. DTO: Data Transfer Object (Validación)

DTOs definen qué datos acepta la API y los validan automáticamente.

```typescript
// src/features/users/dtos/create-user.dto.ts
import { IsEmail, IsString, MinLength, IsArray, IsOptional } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @MinLength(3)
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;

  @IsOptional()
  @IsArray()
  roles?: string[];
}

// src/features/users/dtos/update-user.dto.ts
import { PartialType } from '@nestjs/mapped-types';

export class UpdateUserDto extends PartialType(CreateUserDto) {}

// src/features/users/dtos/user.dto.ts (Response)
export class UserDto {
  id: string;
  name: string;
  email: string;
  roles: string[];
  createdAt: Date;
  // ← Nota: NO incluimos password en la respuesta
}
```

### 3. Repository: Acceso a Datos

```typescript
// src/features/users/repositories/user.repository.ts
import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';
import { User } from '../entities/user.entity';

@Injectable()
export class UserRepository extends Repository<User> {
  constructor(private dataSource: DataSource) {
    super(User, dataSource.createEntityManager());
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.findOne({ where: { email } });
  }

  async findWithRoles(roles: string[]): Promise<User[]> {
    return this.query(
      `SELECT * FROM users WHERE roles && $1`,
      [roles]
    );
  }
}
```

### 4. Service: Lógica de Negocio

```typescript
// src/features/users/services/users.service.ts
import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { CreateUserDto, UpdateUserDto } from '../dtos';
import { User } from '../entities/user.entity';
import { UserRepository } from '../repositories/user.repository';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class UsersService {
  constructor(private userRepository: UserRepository) {}

  async create(createUserDto: CreateUserDto): Promise<User> {
    // Verificar que el email no existe
    const existing = await this.userRepository.findByEmail(createUserDto.email);
    if (existing) {
      throw new ConflictException('Email already exists');
    }

    // Hashear contraseña
    const hashedPassword = await bcrypt.hash(createUserDto.password, 10);

    // Crear usuario
    const user = this.userRepository.create({
      ...createUserDto,
      password: hashedPassword,
    });

    return this.userRepository.save(user);
  }

  async findAll(): Promise<User[]> {
    return this.userRepository.find();
  }

  async findOne(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User #${id} not found`);
    }
    return user;
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    await this.findOne(id); // Verificar que existe

    await this.userRepository.update(id, updateUserDto);
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    const user = await this.findOne(id);
    await this.userRepository.remove(user);
  }

  async validatePassword(email: string, password: string): Promise<User | null> {
    const user = await this.userRepository.findByEmail(email);
    if (!user) return null;

    const isMatch = await bcrypt.compare(password, user.password);
    return isMatch ? user : null;
  }
}
```

### 5. Controller: HTTP Routes

```typescript
// src/features/users/controllers/users.controller.ts
import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Put,
  Delete,
  UseGuards,
  Req,
} from '@nestjs/common';
import { UsersService } from '../services/users.service';
import { CreateUserDto, UpdateUserDto, UserDto } from '../dtos';
import { JwtAuthGuard } from '../../../core/auth/jwt.guard';
import { plainToInstance } from 'class-transformer';

@Controller('users')
@UseGuards(JwtAuthGuard) // Guard global para esta ruta
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Post()
  async create(@Body() createUserDto: CreateUserDto): Promise<UserDto> {
    const user = await this.usersService.create(createUserDto);
    return plainToInstance(UserDto, user);
  }

  @Get()
  async findAll(): Promise<UserDto[]> {
    const users = await this.usersService.findAll();
    return plainToInstance(UserDto, users);
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<UserDto> {
    const user = await this.usersService.findOne(id);
    return plainToInstance(UserDto, user);
  }

  @Put(':id')
  async update(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
  ): Promise<UserDto> {
    const user = await this.usersService.update(id, updateUserDto);
    return plainToInstance(UserDto, user);
  }

  @Delete(':id')
  async remove(@Param('id') id: string): Promise<void> {
    await this.usersService.remove(id);
  }
}
```

### 6. Module: El Contenedor

```typescript
// src/features/users/users.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './controllers/users.controller';
import { UsersService } from './services/users.service';
import { UserRepository } from './repositories/user.repository';
import { User } from './entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService, UserRepository],
  exports: [UsersService], // ← Otros módulos pueden usar este servicio
})
export class UsersModule {}
```

---

## Repository Pattern

El **Repository** es la abstracción entre la lógica de negocio y la base de datos.

```typescript
// Beneficio: Si cambias de DB (TypeORM → Prisma), solo cambias el Repository
@Injectable()
export class UserRepository {
  // Métodos custom específicos del dominio
  async findActiveUsers(): Promise<User[]> {
    return this.find({ where: { status: 'active' } });
  }

  async findByRole(role: string): Promise<User[]> {
    return this.query(
      `SELECT * FROM users WHERE roles @> $1`,
      [role]
    );
  }

  async countByRole(role: string): Promise<number> {
    return this.count({ where: { roles: Like(`%${role}%`) } });
  }
}
```

---

## DTOs: Input & Output

### Validación Automática

```typescript
// src/features/users/dtos/create-user.dto.ts
import {
  IsEmail,
  IsString,
  MinLength,
  MaxLength,
  IsEnum,
  IsOptional,
} from 'class-validator';

enum UserRole {
  USER = 'user',
  ADMIN = 'admin',
  SUPERADMIN = 'superadmin',
}

export class CreateUserDto {
  @IsString()
  @MinLength(3)
  @MaxLength(100)
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  password: string;

  @IsOptional()
  @IsEnum(UserRole, { each: true })
  roles?: UserRole[];
}

// Uso en Controller:
@Post()
async create(@Body() createUserDto: CreateUserDto) { // ← Validado automáticamente
  return this.usersService.create(createUserDto);
}

// Si el cliente envía JSON inválido:
// POST /users
// { "email": "invalid-email" }
// Respuesta:
// {
//   "statusCode": 400,
//   "message": ["email must be an email"],
//   "error": "Bad Request"
// }
```

### Response DTO (Serialización)

```typescript
// src/features/users/dtos/user.dto.ts
import { Exclude } from 'class-transformer';

export class UserDto {
  id: string;
  name: string;
  email: string;
  roles: string[];
  createdAt: Date;

  @Exclude() // ← NO incluir en la respuesta
  password: string;
}

// En Controller:
@Get(':id')
async findOne(@Param('id') id: string): Promise<UserDto> {
  const user = await this.usersService.findOne(id);
  return plainToInstance(UserDto, user); // ← Transforma y excluye password
}
```

---

## Entity & Domain Model

### Entity (Persistencia)

```typescript
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  // Relaciones
  @OneToMany(() => Post, post => post.author)
  posts: Post[];

  @ManyToMany(() => Group)
  @JoinTable()
  groups: Group[];
}
```

### Domain Model (Lógica)

```typescript
// Métodos de dominio: Lógica que pertenece al modelo
export class User extends BaseEntity {
  isAdmin(): boolean {
    return this.roles.includes('admin');
  }

  canEditPost(post: Post): boolean {
    return post.authorId === this.id || this.isAdmin();
  }

  addRole(role: string): void {
    if (!this.roles.includes(role)) {
      this.roles.push(role);
    }
  }
}

// Uso en Service:
async grantAdminAccess(userId: string): Promise<User> {
  const user = await this.userRepository.findOne(userId);
  user.addRole('admin'); // ← Lógica de dominio
  return this.userRepository.save(user);
}
```

---

## Módulos Anidados

Módulos pueden importar otros módulos para compartir servicios.

```typescript
// src/features/posts/posts.module.ts
import { Module } from '@nestjs/common';
import { UsersModule } from '../users/users.module';
import { PostsService } from './services/posts.service';
import { PostsController } from './controllers/posts.controller';

@Module({
  imports: [UsersModule], // ← Importa UsersModule para acceder a UsersService
  providers: [PostsService],
  controllers: [PostsController],
})
export class PostsModule {}

// src/features/posts/services/posts.service.ts
@Injectable()
export class PostsService {
  constructor(private usersService: UsersService) {} // ← Inyectado desde UsersModule

  async createPost(userId: string, title: string): Promise<Post> {
    // Verificar que el usuario existe
    const user = await this.usersService.findOne(userId);

    return this.postRepository.create({
      title,
      author: user,
    });
  }
}
```

---

## Best Practices

### ✅ 1. Separa Responsabilidades

```typescript
// ❌ BAD: Service con lógica de HTTP
@Injectable()
export class UsersService {
  async create(req: Request): Promise<any> { // ← Acoplado a HTTP
    const data = req.body;
    // ...
  }
}

// ✅ GOOD: Service agnóstico de HTTP
@Injectable()
export class UsersService {
  async create(createUserDto: CreateUserDto): Promise<User> {
    // Pura lógica de negocio
  }
}

@Controller('users')
export class UsersController {
  @Post()
  async create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }
}
```

### ✅ 2. Usa DTOs para Validación

```typescript
// ❌ BAD: Sin validación
@Post()
async create(@Body() data: any) { // ← data puede ser cualquier cosa
  return this.usersService.create(data);
}

// ✅ GOOD: DTO con validación
@Post()
async create(@Body() createUserDto: CreateUserDto) { // ← Validado
  return this.usersService.create(createUserDto);
}
```

### ✅ 3. Exporta Servicios para Otros Módulos

```typescript
@Module({
  providers: [UsersService],
  exports: [UsersService] // ← Permitir que otros módulos lo usen
})
export class UsersModule {}
```

### ✅ 4. Usa Repository Pattern

```typescript
// Facilita testing y cambios de DB
@Injectable()
export class UsersService {
  constructor(private userRepository: UserRepository) {}

  async findOne(id: string): Promise<User> {
    return this.userRepository.findOne(id);
  }
}
```

---

## Checklist: Módulo Bien Formado

```bash
# ✅ 1. Structure
[ ] Entity definida (@Entity)
[ ] DTOs para Input y Output
[ ] Repository para acceso a datos
[ ] Service para lógica de negocio
[ ] Controller para HTTP
[ ] Module que encapsula todo

# ✅ 2. Validación
[ ] class-validator en DTOs
[ ] ValidationPipe global activado
[ ] Error messages descriptivos

# ✅ 3. Security
[ ] Guards en rutas protegidas
[ ] Password hasheado (bcrypt)
[ ] Input sanitizado
[ ] No exponer datos sensibles en DTOs

# ✅ 4. Error Handling
[ ] Exception Filters globales
[ ] Errores tipados (NotFoundException, ConflictException)
[ ] HTTP status codes correctos

# ✅ 5. Testing
[ ] Unit tests para Service
[ ] Integration tests para Controller
[ ] Cobertura >80%

# ✅ 6. Documentation
[ ] @ApiTags, @ApiOperation decoradores
[ ] Swagger auto-generado
[ ] README en el directorio del módulo
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ MODULAR ARCHITECTURE READY
**Responsable:** ArchitectZero AI Agent
