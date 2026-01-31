# Best Practices & Golden Standards for {{TECH_NAME}}

> **State:** ✅ Complete
> **Tech Stack:** {{TECH_STACK}}
> **Version:** {{TECH_VERSION}}
> **Last Updated:** {{BEST_PRACTICES_DATE}}

---

## 📖 Table of Contents

- [1. Error Handling Pattern](#1-error-handling-pattern)
- [2. Dependency Injection Pattern](#2-dependency-injection-pattern)
- [3. Configuration Management](#3-configuration-management)
- [4. Logging & Observability](#4-logging--observability)
- [5. Testing Golden Standard](#5-testing-golden-standard)
- [6. API Response Format](#6-api-response-format)
- [7. Security Patterns](#7-security-patterns)
- [8. Performance Optimization](#8-performance-optimization)

---

## 1. Error Handling Pattern

### ❌ Anti-Pattern (Avoid)

```python
# BAD: Generic exceptions, poor error handling
def get_user(user_id):
    try:
        result = db.query(f"SELECT * FROM users WHERE id = {user_id}")
        return result
    except:
        return None
```

### ✅ Golden Standard

```python
# GOOD: Custom exceptions with context
from enum import Enum
from dataclasses import dataclass
from typing import Optional

class ErrorCode(str, Enum):
    """Error codes for domain exceptions."""
    USER_NOT_FOUND = "USER_NOT_FOUND"
    INVALID_INPUT = "INVALID_INPUT"
    DB_CONNECTION_ERROR = "DB_CONNECTION_ERROR"
    PERMISSION_DENIED = "PERMISSION_DENIED"

@dataclass
class DomainError(Exception):
    """Base domain error with structured data."""
    code: ErrorCode
    message: str
    details: Optional[dict] = None
    status_code: int = 400

    def to_dict(self):
        """Convert to API response format."""
        return {
            "error": {
                "code": self.code.value,
                "message": self.message,
                "details": self.details,
            }
        }

# Usage
class UserRepository:
    def get_by_id(self, user_id: str) -> User:
        """Get user by ID or raise structured exception."""
        user = self.db.query(User).filter_by(id=user_id).first()
        if not user:
            raise DomainError(
                code=ErrorCode.USER_NOT_FOUND,
                message=f"User with id {user_id} not found",
                status_code=404
            )
        return user
```

### Error Handling in API Controllers

```python
# FastAPI / Flask route
@router.get("/users/{user_id}")
async def get_user_endpoint(user_id: str):
    try:
        user = user_service.get_user(user_id)
        return {"data": user.dict()}
    except DomainError as e:
        logger.error(f"Domain error: {e.code}", extra={"user_id": user_id})
        return {"error": e.to_dict()}, e.status_code
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}", exc_info=True)
        return {"error": {"code": "INTERNAL_ERROR", "message": "An unexpected error occurred"}}, 500
```

---

## 2. Dependency Injection Pattern

### ❌ Anti-Pattern (Avoid)

```python
# BAD: Hard-coded dependencies, difficult to test
class UserService:
    def __init__(self):
        self.repository = UserRepository()  # Hard-coded!
        self.db = Database()  # Hard-coded!

    def get_user(self, user_id: str):
        return self.repository.get_by_id(user_id)
```

### ✅ Golden Standard

```python
# GOOD: Dependency injection via constructor
from abc import ABC, abstractmethod

class IUserRepository(ABC):
    """Repository interface (contract)."""
    @abstractmethod
    def get_by_id(self, user_id: str) -> User:
        pass

class UserService:
    def __init__(self, repository: IUserRepository):
        """Dependencies injected at construction."""
        self.repository = repository

    def get_user(self, user_id: str) -> User:
        return self.repository.get_by_id(user_id)

# Dependency Container (Registry)
class Container:
    def __init__(self):
        self.db = Database()
        self.user_repo = UserRepository(self.db)
        self.user_service = UserService(self.user_repo)

    @property
    def get_user_service(self) -> UserService:
        return self.user_service

# FastAPI with dependency injection
from fastapi import Depends

container = Container()

def get_user_service() -> UserService:
    return container.get_user_service

@router.get("/users/{user_id}")
async def get_user(user_id: str, service: UserService = Depends(get_user_service)):
    user = service.get_user(user_id)
    return {"data": user.dict()}
```

---

## 3. Configuration Management

### ✅ Golden Standard

```python
# config/settings.py
from pydantic import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    """Application settings from environment variables."""

    # App
    app_name: str = "{{PROJECT_NAME}}"
    debug: bool = False
    environment: str = "development"

    # Database
    database_url: str
    database_pool_size: int = 10

    # API
    api_key_secret: str
    api_rate_limit: int = 100

    # Logging
    log_level: str = "INFO"

    # Security
    cors_origins: list = ["http://localhost:3000"]
    jwt_secret: str
    jwt_algorithm: str = "HS256"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True

# Usage
settings = Settings()

# In main.py
from config.settings import settings

app = FastAPI(title=settings.app_name)

@app.on_event("startup")
async def startup():
    logger.info(f"Starting {settings.app_name} in {settings.environment} mode")
```

### .env.example

```env
# App Configuration
APP_NAME={{PROJECT_NAME}}
DEBUG=false
ENVIRONMENT=development

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/db_name
DATABASE_POOL_SIZE=10

# API
API_KEY_SECRET=your-secret-key-change-in-prod
API_RATE_LIMIT=100

# Logging
LOG_LEVEL=INFO

# Security
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080"]
JWT_SECRET=your-jwt-secret-change-in-prod
JWT_ALGORITHM=HS256
```

---

## 4. Logging & Observability

### ✅ Golden Standard

```python
# core/logger.py
import logging
import json
from datetime import datetime

class StructuredFormatter(logging.Formatter):
    """Structured logging formatter (JSON)."""

    def format(self, record):
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name,
            "function": record.funcName,
            "line": record.lineno,
        }

        # Add extra fields
        if hasattr(record, 'user_id'):
            log_data["user_id"] = record.user_id
        if hasattr(record, 'request_id'):
            log_data["request_id"] = record.request_id

        # Add exception info if present
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
logger.info("User fetched", extra={"user_id": "123", "request_id": "abc"})
logger.error("Database connection failed", exc_info=True)
```

---

## 5. Testing Golden Standard

### ✅ Unit Test Pattern (AAA)

```python
# tests/unit/domain/test_user_service.py
import pytest
from unittest.mock import Mock, MagicMock

class TestUserService:
    """Test suite for UserService."""

    @pytest.fixture
    def mock_repository(self):
        """Fixture: mock repository."""
        return Mock()

    @pytest.fixture
    def user_service(self, mock_repository):
        """Fixture: service with mocked repository."""
        return UserService(repository=mock_repository)

    def test_get_user_returns_user_when_exists(self, user_service, mock_repository):
        """Test: Get existing user."""
        # Arrange
        user_id = "123"
        expected_user = User(id=user_id, name="John Doe")
        mock_repository.get_by_id.return_value = expected_user

        # Act
        result = user_service.get_user(user_id)

        # Assert
        assert result.id == user_id
        assert result.name == "John Doe"
        mock_repository.get_by_id.assert_called_once_with(user_id)

    def test_get_user_raises_error_when_not_found(self, user_service, mock_repository):
        """Test: Get non-existent user raises exception."""
        # Arrange
        user_id = "999"
        mock_repository.get_by_id.side_effect = DomainError(
            code=ErrorCode.USER_NOT_FOUND,
            message="User not found"
        )

        # Act & Assert
        with pytest.raises(DomainError) as exc_info:
            user_service.get_user(user_id)

        assert exc_info.value.code == ErrorCode.USER_NOT_FOUND
```

### ✅ Integration Test Pattern

```python
# tests/integration/test_user_flow.py
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_and_get_user(app, async_client: AsyncClient):
    """Test: Full user creation and retrieval flow."""
    # Arrange
    user_data = {"name": "Jane Doe", "email": "jane@example.com"}

    # Act: Create user
    response = await async_client.post("/api/v1/users", json=user_data)
    assert response.status_code == 201
    created_user = response.json()["data"]
    user_id = created_user["id"]

    # Act: Get user
    response = await async_client.get(f"/api/v1/users/{user_id}")
    assert response.status_code == 200
    retrieved_user = response.json()["data"]

    # Assert
    assert retrieved_user["name"] == user_data["name"]
    assert retrieved_user["email"] == user_data["email"]
```

---

## 6. API Response Format

### ✅ Standardized Response Format

```python
# core/api_response.py
from dataclasses import dataclass, asdict
from typing import Generic, TypeVar, Optional

T = TypeVar('T')

@dataclass
class ApiResponse(Generic[T]):
    """Standard API response wrapper."""
    data: Optional[T] = None
    error: Optional[dict] = None
    meta: Optional[dict] = None

    def to_dict(self):
        return asdict(self)

# Success Response
def success_response(data, meta=None):
    return ApiResponse(data=data, meta=meta).to_dict()

# Error Response
def error_response(error_code: str, message: str, status_code=400):
    return {
        "data": None,
        "error": {
            "code": error_code,
            "message": message,
        }
    }, status_code

# Usage in FastAPI
@router.get("/users/{user_id}")
async def get_user(user_id: str):
    try:
        user = user_service.get_user(user_id)
        return success_response(data=user.dict())
    except DomainError as e:
        return error_response(e.code.value, e.message, e.status_code)
```

### Response Examples

```json
// Success (200)
{
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "error": null,
  "meta": {
    "timestamp": "2024-01-30T10:00:00Z"
  }
}

// Error (404)
{
  "data": null,
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User with id 999 not found"
  },
  "meta": null
}
```

---

## 7. Security Patterns

### ✅ Input Validation

```python
# Pydantic models automatically validate
from pydantic import BaseModel, EmailStr, Field

class CreateUserRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr  # Validates email format
    age: int = Field(..., ge=0, le=150)

    class Config:
        schema_extra = {
            "example": {
                "name": "John Doe",
                "email": "john@example.com",
                "age": 30
            }
        }

# Use in route
@router.post("/users")
async def create_user(user_data: CreateUserRequest):
    # user_data is already validated
    return user_service.create_user(user_data)
```

### ✅ JWT Authentication

```python
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthenticationCredentials
import jwt
from datetime import datetime, timedelta

security = HTTPBearer()

def verify_jwt(credentials: HTTPAuthenticationCredentials = Depends(security)):
    """Verify JWT token."""
    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid token")
        return user_id
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

# Protected route
@router.get("/users/profile")
async def get_profile(user_id: str = Depends(verify_jwt)):
    return user_service.get_user(user_id)
```

---

## 8. Performance Optimization

### ✅ Database Query Optimization

```python
# BAD: N+1 query problem
def get_users_with_posts():
    users = db.query(User).all()
    for user in users:
        user.posts = db.query(Post).filter_by(user_id=user.id).all()  # 1 + N queries!
    return users

# GOOD: Eager loading with joins
def get_users_with_posts():
    return db.query(User).options(joinedload(User.posts)).all()  # 1 query!

# GOOD: Limit fields returned
def get_users_summary():
    return db.query(User.id, User.name, User.email).all()
```

### ✅ Caching Strategy

```python
from functools import lru_cache
from datetime import timedelta

class UserService:
    def __init__(self, repository, cache):
        self.repository = repository
        self.cache = cache

    def get_user(self, user_id: str) -> User:
        """Get user with caching."""
        # Try cache first
        cached = self.cache.get(f"user:{user_id}")
        if cached:
            return cached

        # Query database
        user = self.repository.get_by_id(user_id)

        # Store in cache (TTL: 5 minutes)
        self.cache.set(f"user:{user_id}", user, ttl=timedelta(minutes=5))

        return user

    def invalidate_user_cache(self, user_id: str):
        """Invalidate user cache after update."""
        self.cache.delete(f"user:{user_id}")
```

---

## 📋 Checklist: Before Production

- [ ] All exceptions are structured (inherit from DomainError)
- [ ] Dependencies are injected (no hard-coded instances)
- [ ] Configuration comes from environment variables
- [ ] Logging is structured (JSON format)
- [ ] All tests follow AAA pattern (Arrange, Act, Assert)
- [ ] API responses use standardized format
- [ ] Input validation using Pydantic/validators
- [ ] Authentication/Authorization implemented
- [ ] Database queries are optimized (no N+1)
- [ ] Caching strategy in place for read-heavy operations
- [ ] Error handling covers all paths (success, error, unknown)
- [ ] No hardcoded secrets in code

---

**Best Practices Version:** 1.0
**Framework:** {{TECH_NAME}}
**Status:** ✅ Ready for Implementation
**Next Review:** {{REVIEW_DATE}}
