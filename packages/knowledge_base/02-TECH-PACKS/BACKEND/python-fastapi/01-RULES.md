# 📏 Tech Governance Rules: Python FastAPI

> **Framework:** FastAPI 0.100.0+
> **Python:** 3.12.3
> **Goal:** Asegurar código limpio, seguro y mantenible en SoftArchitect AI

Reglas estáticas de calidad para proyectos Python en SoftArchitect. **Estas son obligatorias, no opcionales.**

---

## 📖 Table of Contents

- [1. Convenciones de Naming (PEP 8 Extendido)](#1-convenciones-de-naming-pep-8-extendido)
- [2. Principios Arquitectónicos](#2-principios-arquitectónicos)
- [3. Patterns de Security (Hardening)](#3-patrones-de-seguridad-hardening)
- [4. Linting & Formatting](#4-linting--formatting)
- [5. Developer Checklist](#5-developer-checklist)

---

## 1. Convenciones de Naming (PEP 8 Extendido)

### Tabla de Convenciones

| Elemento | Convención | Ejemplo | Descripción |
|:---|:---|:---|:---|
| **Archivos Python** | `snake_case.py` | `user_service.py` | Minúsculas, guiones bajos. |
| **Clases** | `PascalCase` | `UserRepository` | Siempre con mayúscula inicial. |
| **Funciones** | `snake_case()` | `get_user_by_id()` | Verbo + descripción. |
| **Variables** | `snake_case` | `user_id`, `is_active` | Descriptivo, minúsculas. |
| **Constantes** | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` | Globales y configurables. |
| **Pydantic Models** | `PascalCase` | `UserResponseDTO` | Suffix con `DTO` o `Request`/`Response`. |
| **Excepciones** | `PascalCase` (suffix `Error`) | `UserNotFoundError` | Siempre heredan de `Exception`. |
| **Database Columns** | `snake_case` | `created_at`, `user_id` | Coherente con tablas SQL. |

### Examples Expandidos

```python
# ✅ GOOD: Naming correcto
class UserRepository:
    async def get_user_by_id(self, user_id: int) -> Optional[User]:
        pass

class UserCreateRequest(BaseModel):
    email: EmailStr
    password_hash: str

MAX_CONCURRENT_REQUESTS = 1000

# ❌ BAD: Violaciones de naming
class user_repo:  # Clase debe ser PascalCase
    def GetUser(self, uID: int):  # Función debe ser snake_case, variable con nombres claros
        pass

class userCreated(BaseModel):  # Inconsistencia: debe ser UserCreateRequest
    emailAddres: str  # emailAddress: camelCase no permitido en Python
```

---

## 2. Principios Arquitectónicos

### Regla #1: Type Hints Mandatorys

**Definición:** Toda función, clase y variable debe tener Type Hints explícitos.

```python
# ✅ GOOD: Type Hints completos
async def get_user(
    user_id: int,
    service: UserService = Depends()
) -> UserResponse:
    return await service.get_by_id(user_id)

# ❌ BAD: Sin Type Hints
async def get_user(user_id, service):
    return service.get_by_id(user_id)
```

**Enforcement:** Pre-commit hook ejecuta `pyright --strict` en todo PR.

### Regla #2: Async/Await Consciente

**Definición:** Elegir entre `async def` y `def` según el I/O.

```python
# ✅ GOOD: Async para I/O
async def fetch_from_db(user_id: int) -> User:
    return await db.session.get(User, user_id)  # Operación I/O

# ✅ GOOD: Sync para CPU-bound (dentro de thread pool)
def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()

# ❌ BAD: Sync bloqueante en async context
async def get_user(user_id: int):
    return db.query(User).filter(User.id == user_id).first()  # BLOQUEANTE!

# ❌ BAD: Await innecesario
async def suma(a: int, b: int) -> int:
    return a + b  # No es I/O, no necesita async
```

### Regla #3: Separación de Capas

**Domain Layer** (Lógica pura)
```python
# services/user_service.py - DEBE SER AGNÓSTICO DE FRAMEWORK
class UserService:
    def __init__(self, repository: IUserRepository):
        self.repository = repository

    async def create_user(self, email: str, password: str) -> User:
        # Lógica pura, sin acceso a HTTP, DB, etc.
        if not self._is_valid_email(email):
            raise ValueError("Invalid email")
        return await self.repository.create(...)

    def _is_valid_email(self, email: str) -> bool:
        return "@" in email  # Simplificado; usar regex en producción
```

**Presentation Layer** (Controllers/Endpoints)
```python
# api/v1/endpoints/users.py - ENDPOINTS SOLO ORQUESTAN
from fastapi import APIRouter, Depends

@router.post("/users", response_model=UserResponse)
async def create_user_endpoint(
    request: UserCreateRequest,
    service: UserService = Depends(get_user_service)
):
    user = await service.create_user(request.email, request.password)
    return UserResponse.from_orm(user)
```

---

## 3. Patterns de Security (Hardening)

### 🔒 Patrón #1: Validación Pydantic V2

**Mandatory:** Validar TODOS los inputs vía Pydantic Models.

```python
# ✅ GOOD: Validación con Pydantic
class UserCreateRequest(BaseModel):
    email: EmailStr  # Valida email automáticamente
    password: str = Field(min_length=8, max_length=128)
    age: int = Field(ge=0, le=150)  # Greater-equal 0, less-equal 150

    model_config = ConfigDict(validate_assignment=True)

# ❌ BAD: Sin validación
@router.post("/users")
async def create_user(data: dict):
    email = data.get("email")  # ¿Y si no viene? ¿Y si es "abc"?
    password = data.get("password")  # ¿Y si tiene 2 caracteres?

# ❌ BAD: Acceso a request.json() crudo
@router.post("/users")
async def create_user(request: Request):
    data = await request.json()  # Sin validación
    user = User(**data)  # SQLInjection risk
```

### 🔒 Patrón #2: SQL Injection Prevention

**Mandatory:** Usar siempre ORM o parámetros. NUNCA f-strings.

```python
# ✅ GOOD: SQLAlchemy ORM
user = await db.session.execute(
    select(User).where(User.email == email)
)

# ✅ GOOD: Parámetros nombrados
user = await db.session.execute(
    text("SELECT * FROM users WHERE email = :email"),
    {"email": email}
)

# ❌ BAD: F-string SQL (SQL INJECTION!)
user = db.session.execute(f"SELECT * FROM users WHERE email = '{email}'")

# ❌ BAD: Concatenación (INJECTION!)
user = db.session.execute("SELECT * FROM users WHERE email = '" + email + "'")
```

### 🔒 Patrón #3: Secrets Management

**Mandatory:** Usar `pydantic-settings` + `.env` (NUNCA en código).

```python
# core/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    jwt_secret: str
    api_key: str

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True

settings = Settings()  # Carga automáticamente de .env

# ✅ GOOD: Uso desde settings
def create_jwt_token(user_id: int, settings: Settings = Depends(get_settings)):
    token = jwt.encode({"sub": user_id}, settings.jwt_secret)
    return token

# ❌ BAD: Hardcoded secret
JWT_SECRET = "super-secret-key-123"  # EXPOSICIÓN DE SECRETOS

# ❌ BAD: os.getenv disperso
password = os.getenv("DB_PASSWORD")  # Poco mantenible, difícil trackear
```

### 🔒 Patrón #4: Logging (NUNCA print())

**Mandatory:** Usar `logging` estructurado. `print()` está **PROHIBIDO** en src/.

```python
# core/logger.py
import logging
import json
from datetime import datetime

logger = logging.getLogger(__name__)

# ✅ GOOD: Structured logging
def log_user_created(user_id: int, email: str):
    logger.info(
        "User created",
        extra={
            "user_id": user_id,
            "email": email,
            "timestamp": datetime.utcnow().isoformat()
        }
    )

# ❌ BAD: print()
print(f"User created: {user_id}")  # No se puede hacer grep, no es estructurado

# ❌ BAD: string concatenation en logs
logger.info("User " + str(user_id) + " created")  # Difícil de parsear
```

---

## 4. Linting & Formatting

### Tool Chain (Mandatory)

| Tool | Propósito | Config |
|:---|:---|:---|
| **Ruff** | Linting (reemplaza Flake8, Isort) | `pyproject.toml`: line-length=100 |
| **Pyright** | Type checking (strict mode) | `pyrightconfig.json`: `strict` |
| **Black** | Code formatter (opcional, Ruff lo hace) | Implícito en Ruff |
| **Pre-commit** | Git hooks | `.pre-commit-config.yaml` |

### Verificación Local

```bash
# Lint
ruff check src/

# Type check (strict)
pyright --strict src/

# Format
ruff format src/

# Todos juntos
ruff check --fix src/ && pyright --strict src/ && ruff format src/
```

### Pre-commit Hook (Automático)

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/RohanAgarwal/pre-commit-pyright
    rev: 1.1.337
    hooks:
      - id: pyright
        args: ["--outputjson"]
```

---

## 5. Developer Checklist

**Antes de hacer PUSH, verifica:**

- [ ] ✅ Todos los argumentos y retornos tienen Type Hints
- [ ] ✅ Ejecuté `ruff check --fix` sin errores
- [ ] ✅ Ejecuté `pyright --strict` sin errores
- [ ] ✅ Usé Pydantic para validar inputs
- [ ] ✅ NO usé `print()` en código
- [ ] ✅ Secrets están en `.env`, NO en código
- [ ] ✅ Separé Domain de Presentation layers
- [ ] ✅ Inyecté dependencias vía `Depends()`
- [ ] ✅ Escribí tests unitarios (AAA pattern)
- [ ] ✅ Documenté funciones públicas con docstring

---

**Última Actualización:** 30/01/2026
**Versión de Reglas:** 1.0
**Enforcement:** Pre-commit + CI/CD
