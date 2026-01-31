# 🌟 Best Practices: Python FastAPI

> **Versión:** 1.0
> **Framework:** FastAPI 0.100.0+ + Pydantic V2
> **Objetivo:** Patrones de oro para generación automática de código

Snippets de referencia producción-ready. El RAG usa estos para entender cómo escribir FastAPI "The SoftArchitect Way".

---

## 📖 Tabla de Contenidos

- [1. Inyección de Dependencias (Dependency Injection)](#1-inyección-de-dependencias-dependency-injection)
- [2. Validación de Datos (Pydantic V2)](#2-validación-de-datos-pydantic-v2)
- [3. Repository Pattern](#3-repository-pattern)
- [4. Manejo de Errores Centralizado](#4-manejo-de-errores-centralizado)
- [5. Configuración (Settings)](#5-configuración-settings)
- [6. Logging Estructurado](#6-logging-estructurado)
- [7. Testing (AAA Pattern)](#7-testing-aaa-pattern)
- [8. Async/Await Patterns](#8-asyncawait-patterns)

---

## 1. Inyección de Dependencias (Dependency Injection)

### ❌ Anti-Pattern (Evitar)

```python
# BAD: Hard-coded dependency
class UserEndpoint:
    def __init__(self):
        self.service = UserService()  # HARD-CODED! No testable

    @router.get("/users/{user_id}")
    async def get_user(self, user_id: int):
        return self.service.get(user_id)
```

### ✅ Golden Standard

```python
# GOOD: Dependency injection via Depends()
from typing import Annotated
from fastapi import APIRouter, Depends
from app.domain.services.user_service import UserService
from app.infrastructure.repositories.user_repository import UserRepository
from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter()

# Dependency functions
async def get_db() -> AsyncSession:
    """Yield database session."""
    async with SessionLocal() as session:
        yield session

def get_user_repository(db: Annotated[AsyncSession, Depends(get_db)]) -> UserRepository:
    """Create repository with injected DB session."""
    return UserRepository(db)

def get_user_service(
    repository: Annotated[UserRepository, Depends(get_user_repository)]
) -> UserService:
    """Create service with injected repository."""
    return UserService(repository)

# Endpoint with full dependency chain
@router.get("/users/{user_id}")
async def get_user_endpoint(
    user_id: int,
    service: Annotated[UserService, Depends(get_user_service)]
) -> UserResponse:
    """Get user by ID. Dependencies auto-injected by FastAPI."""
    user = await service.get_by_id(user_id)
    return UserResponse.from_orm(user)
```

### Benefit: Testability

```python
# Test: Mock repository, inject into service
class MockUserRepository:
    async def get_by_id(self, user_id: int):
        return User(id=1, email="test@example.com")

async def test_get_user():
    # Arrange
    mock_repo = MockUserRepository()
    service = UserService(mock_repo)

    # Act
    user = await service.get_by_id(1)

    # Assert
    assert user.email == "test@example.com"
```

---

## 2. Validación de Datos (Pydantic V2)

### ❌ Anti-Pattern (Evitar)

```python
# BAD: No validation
@router.post("/users")
async def create_user(data: dict):
    email = data.get("email")  # ¿Y si no existe? ¿Y si es None?
    password = data.get("password", "")  # Weak default

    if not email or len(password) < 8:  # Manual validation (error-prone)
        raise ValueError("Invalid input")

    user = User(email=email, password=password)  # No hash!
    return user
```

### ✅ Golden Standard

```python
# GOOD: Pydantic V2 validation
from pydantic import BaseModel, EmailStr, Field, field_validator
from pydantic.config import ConfigDict

class UserCreateRequest(BaseModel):
    """Request schema for creating a user."""
    email: EmailStr  # Automatic email validation
    password: str = Field(
        ...,
        min_length=8,
        max_length=128,
        description="Password must be 8-128 characters"
    )
    age: int = Field(ge=0, le=150, description="Age must be 0-150")
    full_name: str = Field(..., min_length=2, max_length=100)

    model_config = ConfigDict(
        validate_assignment=True,
        str_strip_whitespace=True,
        json_schema_extra={
            "example": {
                "email": "john@example.com",
                "password": "SecurePass123!",
                "age": 30,
                "full_name": "John Doe"
            }
        }
    )

    @field_validator("password")
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        """Custom validator: password must contain uppercase + digit."""
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain uppercase letter")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain digit")
        return v

class UserResponse(BaseModel):
    """Response schema for user."""
    id: int
    email: EmailStr
    full_name: str
    created_at: datetime
    # NEVER include password in response!

    model_config = ConfigDict(from_attributes=True)

# Endpoint: FastAPI auto-validates
@router.post("/users", response_model=UserResponse)
async def create_user(
    request: UserCreateRequest,  # Auto-validated by Pydantic
    service: Annotated[UserService, Depends(get_user_service)]
) -> UserResponse:
    """Create a new user. Validation automatic."""
    user = await service.create_user(
        email=request.email,
        password=request.password,
        full_name=request.full_name,
        age=request.age
    )
    return UserResponse.from_orm(user)
```

### Automatic Swagger Documentation

```python
# Pydantic + FastAPI = OpenAPI 3.0 schema auto-generated!
# Available at: http://localhost:8000/docs

# Swagger shows:
# - Field descriptions (from Field(..., description="..."))
# - Type validation rules (min_length, max_length, etc)
# - Example JSON (from model_config json_schema_extra)
```

---

## 3. Repository Pattern

### Purpose: Abstraction over data source

```python
# GOOD: Repository abstraction
from abc import ABC, abstractmethod

class IUserRepository(ABC):
    """Contract for user data access."""
    @abstractmethod
    async def get_by_id(self, user_id: int) -> Optional[User]:
        pass

    @abstractmethod
    async def get_by_email(self, email: str) -> Optional[User]:
        pass

    @abstractmethod
    async def create(self, **kwargs) -> User:
        pass

# GOOD: SQLAlchemy implementation
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

class UserRepository(IUserRepository):
    """SQLAlchemy-based user repository."""
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_id(self, user_id: int) -> Optional[User]:
        """Get user by ID."""
        stmt = select(User).where(User.id == user_id)
        result = await self.db.execute(stmt)
        return result.scalars().first()

    async def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email."""
        stmt = select(User).where(User.email == email)
        result = await self.db.execute(stmt)
        return result.scalars().first()

    async def create(self, email: str, password_hash: str, **kwargs) -> User:
        """Create new user."""
        user = User(email=email, password_hash=password_hash, **kwargs)
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        return user

# GOOD: Service uses repository (testable)
class UserService:
    def __init__(self, repository: IUserRepository):
        self.repository = repository

    async def get_user(self, user_id: int) -> User:
        user = await self.repository.get_by_id(user_id)
        if not user:
            raise UserNotFoundError(f"User {user_id} not found")
        return user
```

---

## 4. Manejo de Errores Centralizado

### ❌ Anti-Pattern (Evitar)

```python
# BAD: Scattered error handling
@router.get("/users/{user_id}")
async def get_user(user_id: int):
    try:
        user = await db.get_user(user_id)
        if not user:
            return {"error": "Not found"}  # Inconsistent format
        return user
    except Exception as e:
        return {"message": str(e)}  # Leaks stack trace!
```

### ✅ Golden Standard

```python
# GOOD: Custom exception hierarchy
class DomainError(Exception):
    """Base domain exception."""
    code: str
    status_code: int = 400

    def __init__(self, message: str, code: str = None, status_code: int = None):
        self.message = message
        self.code = code or self.code
        if status_code:
            self.status_code = status_code
        super().__init__(self.message)

class UserNotFoundError(DomainError):
    code = "USER_NOT_FOUND"
    status_code = 404

class InvalidCredentialsError(DomainError):
    code = "INVALID_CREDENTIALS"
    status_code = 401

# GOOD: Global exception handler
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()

@app.exception_handler(DomainError)
async def domain_exception_handler(request, exc: DomainError):
    """Handle domain errors with standardized response."""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.code,
                "message": exc.message
            }
        }
    )

@app.exception_handler(Exception)
async def general_exception_handler(request, exc: Exception):
    """Handle unexpected errors (log + return generic response)."""
    logger.error(f"Unexpected error: {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "error": {
                "code": "INTERNAL_ERROR",
                "message": "An unexpected error occurred"
            }
        }
    )

# GOOD: Service raises domain exceptions
class UserService:
    async def get_user(self, user_id: int) -> User:
        user = await self.repository.get_by_id(user_id)
        if not user:
            raise UserNotFoundError(f"User {user_id} not found")  # Caught by handler
        return user

    async def authenticate(self, email: str, password: str) -> User:
        user = await self.repository.get_by_email(email)
        if not user or not verify_password(password, user.password_hash):
            raise InvalidCredentialsError("Invalid email or password")  # Generic message
        return user

# GOOD: Endpoint is clean
@router.get("/users/{user_id}")
async def get_user(
    user_id: int,
    service: Annotated[UserService, Depends(get_user_service)]
) -> UserResponse:
    """Get user. Exceptions handled globally."""
    user = await service.get_user(user_id)
    return UserResponse.from_orm(user)
```

### Response Format (Consistent)

```json
{
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User 123 not found"
  }
}
```

---

## 5. Configuración (Settings)

### ✅ Golden Standard

```python
# core/config.py
from pydantic_settings import BaseSettings
from pydantic import Field

class Settings(BaseSettings):
    """Application settings from environment variables."""

    # App
    app_name: str = "SoftArchitect"
    debug: bool = False
    environment: str = Field(default="development", validation_alias="ENV")

    # Database
    database_url: str = Field(..., validation_alias="DATABASE_URL")
    database_pool_size: int = 10
    database_echo: bool = False  # Log SQL statements

    # Security
    jwt_secret: str = Field(..., validation_alias="JWT_SECRET")
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    # API
    api_key: str = Field(..., validation_alias="API_KEY")
    cors_origins: list = ["http://localhost:3000"]

    # Logging
    log_level: str = "INFO"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True

# Load at startup
settings = Settings()

# Usage in app
from core.config import settings

app = FastAPI(title=settings.app_name, debug=settings.debug)

@app.on_event("startup")
async def startup():
    logger.info(f"Starting {settings.app_name} in {settings.environment}")
```

### .env.example

```env
# App
APP_NAME=SoftArchitect
DEBUG=false
ENV=development

# Database
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/softarchitect
DATABASE_POOL_SIZE=10
DATABASE_ECHO=false

# Security
JWT_SECRET=your-super-secret-key-change-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# API
API_KEY=your-api-key-here

# Logging
LOG_LEVEL=INFO
```

---

## 6. Logging Estructurado

### ✅ Golden Standard

```python
# core/logger.py
import logging
import json
from datetime import datetime
from typing import Any, Dict

class StructuredFormatter(logging.Formatter):
    """JSON-structured logging formatter."""

    def format(self, record: logging.LogRecord) -> str:
        log_data: Dict[str, Any] = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name,
            "function": record.funcName,
            "line": record.lineno,
        }

        # Add extra fields
        if hasattr(record, "user_id"):
            log_data["user_id"] = record.user_id
        if hasattr(record, "request_id"):
            log_data["request_id"] = record.request_id

        # Add exception if present
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)

        return json.dumps(log_data)

def get_logger(name: str) -> logging.Logger:
    """Get configured logger."""
    logger = logging.getLogger(name)
    handler = logging.StreamHandler()
    handler.setFormatter(StructuredFormatter())
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger

# Usage
logger = get_logger(__name__)

# Log with context
logger.info("User authenticated", extra={"user_id": "123"})
logger.error("Database error", exc_info=True, extra={"request_id": "abc-123"})
```

---

## 7. Testing (AAA Pattern)

### ✅ Unit Test

```python
# tests/unit/domain/test_user_service.py
import pytest
from unittest.mock import AsyncMock, Mock

class TestUserService:
    """Test suite for UserService."""

    @pytest.fixture
    def mock_repository(self):
        """Fixture: mock repository."""
        return AsyncMock()

    @pytest.fixture
    def user_service(self, mock_repository):
        """Fixture: service with mocked repository."""
        return UserService(repository=mock_repository)

    @pytest.mark.asyncio
    async def test_get_user_returns_user_when_exists(self, user_service, mock_repository):
        """Test: Get existing user."""
        # Arrange
        user_id = 1
        expected_user = User(id=user_id, email="john@example.com", full_name="John Doe")
        mock_repository.get_by_id.return_value = expected_user

        # Act
        user = await user_service.get_user(user_id)

        # Assert
        assert user.id == user_id
        assert user.email == "john@example.com"
        mock_repository.get_by_id.assert_called_once_with(user_id)

    @pytest.mark.asyncio
    async def test_get_user_raises_error_when_not_found(self, user_service, mock_repository):
        """Test: Get non-existent user raises exception."""
        # Arrange
        user_id = 999
        mock_repository.get_by_id.return_value = None

        # Act & Assert
        with pytest.raises(UserNotFoundError):
            await user_service.get_user(user_id)
```

### ✅ Integration Test

```python
# tests/integration/test_user_flow.py
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_and_get_user(app, async_client: AsyncClient):
    """Test: Full user creation and retrieval flow."""
    # Arrange
    user_data = {
        "email": "jane@example.com",
        "password": "SecurePass123!",
        "full_name": "Jane Doe",
        "age": 28
    }

    # Act: Create user
    response = await async_client.post("/api/v1/users", json=user_data)
    assert response.status_code == 201
    created_user = response.json()
    user_id = created_user["id"]

    # Act: Get user
    response = await async_client.get(f"/api/v1/users/{user_id}")
    assert response.status_code == 200
    retrieved_user = response.json()

    # Assert
    assert retrieved_user["email"] == user_data["email"]
    assert retrieved_user["full_name"] == user_data["full_name"]
    assert "password" not in retrieved_user  # Never leak password!
```

---

## 8. Async/Await Patterns

### ✅ Golden Standard

```python
# GOOD: Async for I/O operations
async def fetch_user_with_posts(user_id: int) -> User:
    """Fetch user and all their posts concurrently."""
    user_task = db.execute(select(User).where(User.id == user_id))
    posts_task = db.execute(select(Post).where(Post.user_id == user_id))

    # Execute both queries concurrently
    user = (await user_task).scalars().first()
    posts = (await posts_task).scalars().all()

    user.posts = posts
    return user

# GOOD: Using asyncio.gather for multiple operations
async def process_documents(document_ids: list[int]) -> list[dict]:
    """Process multiple documents in parallel."""
    tasks = [index_document_to_chroma(doc_id) for doc_id in document_ids]
    results = await asyncio.gather(*tasks)
    return results

# GOOD: Async context managers for cleanup
async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    """Yield DB session with automatic cleanup."""
    async with SessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()

# ❌ BAD: Blocking in async context
async def get_user(user_id: int):
    time.sleep(1)  # BLOCKS! Use await asyncio.sleep(1)
    return db.get_user(user_id)  # Synchronous call!

# ❌ BAD: Creating new event loop inside async
async def process():
    loop = asyncio.new_event_loop()  # Never do this!
    result = loop.run_until_complete(fetch_data())
```

---

## 📋 Pre-Commit Checklist

Before pushing code:

- [ ] ✅ Type hints: `pyright --strict` passes
- [ ] ✅ Lint: `ruff check --fix` passes
- [ ] ✅ Format: `ruff format` applied
- [ ] ✅ Tests: `pytest tests/` all green
- [ ] ✅ No `print()` statements (use logger)
- [ ] ✅ No hardcoded secrets (use `.env`)
- [ ] ✅ Database queries use ORM (no raw SQL)
- [ ] ✅ All endpoints have Type Hints + docstring
- [ ] ✅ Response DTOs exclude sensitive fields (passwords, tokens)
- [ ] ✅ Async functions for I/O, sync for pure logic

---

**Versión:** 1.0
**Framework:** FastAPI + Pydantic V2 + SQLAlchemy 2.0
**Última Actualización:** 30/01/2026
**Validado Por:** ArchitectZero (Dogfooding ✨)
