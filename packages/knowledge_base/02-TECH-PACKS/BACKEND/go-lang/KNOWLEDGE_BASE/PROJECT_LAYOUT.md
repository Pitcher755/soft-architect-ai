# 🏗️ Standard Go Project Layout

> **Estándar:** golang-standards/project-layout
> **Filosofía:** Opinión sobre estructura de carpetas
> **Date:** 30 de Enero de 2026

Go es opinionado. La comunidad ha convergido en una estructura de directorios clara. Síguelo.

---

## 📖 Table of Contents

1. [El Estándar](#el-estándar)
2. [Estructura Detallada](#estructura-detallada)
3. [Reglas de Importación](#reglas-de-importación)
4. [Paquetes por Dominio](#paquetes-por-dominio)
5. [Anti-Patterns](#anti-patterns)

---

## El Estándar

La estructura recomendada por la comunidad Go (https://github.com/golang-standards/project-layout):

```text
myapp/
├── cmd/
│   └── myapp/
│       └── main.go              # Entry point (solo main())
│
├── internal/                    # 🔒 Código privado del proyecto
│   ├── app/
│   │   └── service.go
│   ├── domain/
│   │   ├── user.go
│   │   └── order.go
│   ├── infrastructure/
│   │   ├── database.go
│   │   └── http.go
│   └── platform/
│       ├── config.go
│       └── logger.go
│
├── pkg/                         # 🔓 Código público (librerías reutilizables)
│   └── validation/
│       └── email.go
│
├── api/
│   ├── openapi.yaml
│   └── proto/
│       └── user.proto           # gRPC definitions
│
├── build/
│   ├── docker/
│   │   └── Dockerfile
│   └── scripts/
│       └── install.sh
│
├── configs/
│   ├── dev.yaml
│   ├── prod.yaml
│   └── test.yaml
│
├── test/
│   ├── integration/
│   └── fixtures/
│
├── scripts/
│   ├── deploy.sh
│   └── migrate.sh
│
├── go.mod
├── go.sum
├── Makefile
└── README.md
```

---

## Estructura Detallada

### `cmd/` - Entry Points

```go
// myapp/cmd/myapp/main.go
package main

import (
    "log"
    "myapp/internal/app"
)

func main() {
    service := app.NewService()
    if err := service.Start(); err != nil {
        log.Fatal(err)
    }
}
```

**Regla:** `main()` es SOLO punto de entrada. NUNCA lógica de negocio aquí.

```bash
# Compilar
go build -o myapp ./cmd/myapp

# Ejecutar
./myapp
```

### `internal/` - Código Privado (El Compilador lo Refuerza)

El compilador de Go **prohíbe** importar paquetes dentro de `internal/` desde fuera del módulo raíz.

```go
// ✅ OK: Importar desde dentro del módulo
// myapp/internal/app/service.go
package app
import "myapp/internal/domain"

// ✅ OK: Importar desde cmd/
// myapp/cmd/myapp/main.go
package main
import "myapp/internal/app"

// ❌ ERROR: Otro módulo NO puede importar internal/
// OTHER_MODULE/main.go
package main
import "myapp/internal/app"  // Compilation error!
```

**Estructura Recomendada dentro de `internal/`:**

```text
internal/
├── app/                     # Application services
│   ├── user_service.go      # Business logic
│   ├── order_service.go
│   └── payment_service.go
│
├── domain/                  # Domain entities & interfaces
│   ├── user.go              # User entity
│   ├── order.go
│   └── repository.go        # Interfaces (contracts)
│
├── infrastructure/          # External services
│   ├── database.go
│   ├── cache.go
│   ├── http.go
│   └── email.go
│
├── platform/                # Cross-cutting concerns
│   ├── config.go
│   ├── logger.go
│   ├── tracing.go
│   └── metrics.go
│
└── api/                     # HTTP handlers (web layer)
    ├── user_handler.go
    ├── order_handler.go
    └── middleware.go
```

### `pkg/` - Código Público (Reutilizable)

Paquetes que pueden ser importados por OTROS módulos.

```go
// myapp/pkg/validation/email.go
package validation

func IsValidEmail(email string) bool {
    // ...
}
```

**Otros módulos pueden usarlo:**

```go
// other_project/main.go
package main

import "github.com/myusername/myapp/pkg/validation"

func main() {
    if validation.IsValidEmail("test@example.com") {
        // ...
    }
}
```

**Regla:** Incluir en `pkg/` solo código que **verdaderamente** es reutilizable.

### `api/` - Definiciones de API

```yaml
# myapp/api/openapi.yaml
openapi: 3.0.0
info:
  title: My API
  version: 1.0.0
paths:
  /users:
    get:
      summary: List users
      responses:
        '200':
          description: List of users
```

```protobuf
# myapp/api/proto/user.proto
syntax = "proto3";

message User {
  string id = 1;
  string name = 2;
  string email = 3;
}
```

### `configs/` - Configuration

```yaml
# myapp/configs/dev.yaml
database:
  url: "postgres://localhost:5432/myapp_dev"
  maxOpenConns: 10

server:
  port: 8080
  debug: true
```

```yaml
# myapp/configs/prod.yaml
database:
  url: "${DATABASE_URL}"
  maxOpenConns: 100

server:
  port: 8080
  debug: false
```

---

## Reglas de Importación

### Import Order

```go
// ✅ GOOD: Standard library, 3rd party, then local
package main

import (
    // Standard library
    "fmt"
    "log"
    "os"

    // 3rd party
    "github.com/gorilla/mux"
    "github.com/lib/pq"

    // Local
    "myapp/internal/app"
    "myapp/internal/domain"
)
```

### Naming Imports

```go
// ✅ GOOD: Si hay conflicto, usar alias
import (
    "database/sql"
    pq "github.com/lib/pq"  // Alias
)

// ✅ GOOD: Usar dot import SOLO en tests
import (
    . "testing"  // OK en tests
)
```

---

## Paquetes por Dominio

### Anti-pattern: "Carpetas Genéricas"

```text
❌ BAD:
myapp/
├── models/
├── utils/
├── helpers/
├── common/
└── constants/

Por qué: "Package names should describe what they PROVIDE, not what they CONTAIN"
```

### Patrón: "Paquetes por Dominio"

```text
✅ GOOD:
myapp/internal/
├── user/
│   ├── service.go
│   ├── repository.go
│   └── entity.go
├── order/
│   ├── service.go
│   ├── repository.go
│   └── entity.go
└── payment/
    ├── service.go
    └── entity.go

Importar:
import "myapp/internal/user"
// Claro: user package proporciona servicios de usuario
```

### Estructura Plana Preferida

```go
// ✅ GOOD: Paquete small es mejor
// myapp/internal/user/service.go
package user

type Service struct { }
func (s *Service) FindUser(id string) (*User, error) { }

// myapp/cmd/myapp/main.go
package main

import "myapp/internal/user"

func main() {
    userService := user.NewService()
}

// ❌ BAD: Paquete huge
// myapp/internal/app/user_service.go
// myapp/internal/app/user_repository.go
// myapp/internal/app/order_service.go
// myapp/internal/app/payment_service.go
// (todo mezclado)
```

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: Carpetas Genéricas

```text
❌ myapp/utils/     (qué utilities? vago)
❌ myapp/helpers/   (qué helpers?)
❌ myapp/common/    (qué es common?)
❌ myapp/models/    ("models" describe el contenido, no el propósito)

✅ myapp/internal/user/     (proporciona user services)
✅ myapp/internal/order/    (proporciona order services)
✅ myapp/pkg/validation/    (proporciona validation utilities)
```

### ❌ ANTI-PATTERN 2: Lógica en main()

```go
// ❌ BAD
package main

import "fmt"

func main() {
    users := []string{"Alice", "Bob", "Charlie"}
    for _, u := range users {
        fmt.Println(u)
    }
}

// ✅ GOOD
// internal/user/service.go
package user

type Service struct { }
func (s *Service) ListUsers() []string { ... }

// cmd/myapp/main.go
package main

import "myapp/internal/user"

func main() {
    svc := user.NewService()
    users := svc.ListUsers()
    for _, u := range users {
        println(u)
    }
}
```

### ❌ ANTI-PATTERN 3: Deep Nesting

```text
❌ TOO DEEP:
internal/
├── domain/
│   ├── entities/
│   │   ├── user/
│   │   │   └── user.go

✅ GOOD:
internal/
├── user/
│   └── entity.go
```

### ❌ ANTI-PATTERN 4: Circular Imports

```go
// ❌ BAD: user imports order, order imports user
// internal/user/service.go
package user
import "myapp/internal/order"  // ← Circular

// internal/order/service.go
package order
import "myapp/internal/user"  // ← Circular

// ✅ GOOD: Define interfaces en domain, implementa en packages
// internal/domain/repository.go
package domain
type UserRepository interface {
    FindUser(id string) (*User, error)
}

// internal/user/repository.go
package user
import "myapp/internal/domain"
type sqlRepository struct { }
func (r *sqlRepository) FindUser(id string) (*domain.User, error) { }
```

---

## Checklist: Go Project Layout

```bash
# ✅ 1. Estructura
[ ] cmd/ solo contiene main.go
[ ] internal/ código privado
[ ] pkg/ código público
[ ] api/ especificaciones (OpenAPI, gRPC)

# ✅ 2. Convenciones
[ ] Paquetes por dominio (user/, order/, payment/)
[ ] NO carpetas genéricas (utils, helpers, common)
[ ] Nombres descriptos (qué proporciona)

# ✅ 3. Imports
[ ] Importar desde internal/ (privado)
[ ] Exponer solo pkg/ (público)
[ ] NO circular imports

# ✅ 4. Configuration
[ ] configs/ con archivos por ambiente
[ ] Usar environment variables en prod
[ ] Health checks en main

# ✅ 5. Testing
[ ] test/ para integration tests
[ ] *_test.go files junto al código
[ ] fixtures para test data

# ✅ 6. Build
[ ] Makefile o scripts/ para automatización
[ ] build/ con Dockerfile
[ ] Cross-compile para múltiples plataformas
```

---

**Date:** 30 de Enero de 2026
**Status:** ✅ GOLANG PROJECT LAYOUT READY
**Responsable:** ArchitectZero AI Agent
