# 📂 PROJECT STRUCTURE MAP: TaskFlow Pro

> **Project:** TaskFlow Pro - Enterprise Task Management System
> **Document Type:** Project File Organization & Structure Reference
> **Version:** 2.3.0
> **Last Updated:** February 22, 2026
> **Status:** ✅ Active & Enforced
> **Authority:** Lead Architect

---

## 📋 Table of Contents

- [Document Purpose](#document-purpose)
- [Root Directory Overview](#root-directory-overview)
- [Backend Structure (Python/FastAPI)](#backend-structure-pythonfastapi)
- [Frontend Structure (Dart/Flutter)](#frontend-structure-dartflutter)
- [Infrastructure & DevOps](#infrastructure--devops)
- [Documentation (context/)](#documentation-context)
- [Testing Structure](#testing-structure)
- [File Naming Conventions](#file-naming-conventions)
- [Anti-Patterns (Forbidden Locations)](#anti-patterns-forbidden-locations)
- [References](#references)

---

## 🎯 Document Purpose

This document defines the **canonical file structure** for TaskFlow Pro. It serves as:

1. **Structural Authority** - Any file not defined here is considered technical debt
2. **AI Agent Guidance** - AI tools consult this to know where to create files
3. **Onboarding Reference** - New developers understand organization at a glance
4. **Linter Configuration** - Automated tools enforce this structure

**Critical Rule:** If you want to create a new file and it doesn't fit this structure, **propose an amendment to this document first** (see `RULES.md` Section 11).

---

## 📁 Root Directory Overview

```
taskflow-pro/
├── .github/                      # GitHub-specific configurations
│   ├── ISSUE_TEMPLATE/           # Bug/feature templates
│   ├── pull_request_template.md # PR template
│   └── workflows/                # CI/CD pipelines (GitHub Actions)
│       ├── backend-ci.yml        # Python linting, tests, coverage
│       ├── frontend-ci.yml       # Flutter tests, build
│       └── deploy-staging.yml    # Auto-deploy to staging
│
├── .vscode/                      # VS Code workspace settings
│   ├── extensions.json           # Recommended extensions
│   ├── launch.json               # Debug configurations
│   └── settings.json             # Editor preferences
│
├── context/                      # 📖 Living Documentation (24 docs)
│   ├── 00-DISCOVERY/             # Phase 0: Initial interview & brief
│   ├── 10-CONTEXT/               # Phase 1: Vision, promise, journey
│   ├── 20-REQUIREMENTS/          # Phase 2: Functional, security, API
│   ├── 30-ARCHITECTURE/          # Phase 3: ADRs, schemas, diagrams
│   ├── 40-ROADMAP/               # Phase 4: Sprints, user stories
│   └── 50-IMPLEMENTATION/        # Phase 5: First sprint guide
│
├── infrastructure/               # 🐳 DevOps & Infrastructure as Code
│   ├── docker/                   # Dockerfiles for each service
│   ├── kubernetes/               # K8s manifests (if using)
│   ├── terraform/                # Cloud infrastructure (AWS/GCP)
│   ├── monitoring/               # Prometheus, Grafana configs
│   └── docker-compose.yml        # Local development stack
│
├── packages/                     # 📦 Shared libraries (optional)
│   └── common/                   # Code shared by backend + frontend
│       ├── types/                # Shared TypeScript interfaces
│       └── constants/            # API routes, error codes
│
├── scripts/                      # 🛠️ Automation scripts
│   ├── setup-dev-env.sh          # Initialize local environment
│   ├── run-migrations.sh         # Database migration helper
│   ├── seed-database.py          # Test data generation
│   └── backup-prod-db.sh         # Production backup script
│
├── src/                          # 💻 Source code (backend + frontend)
│   ├── client/                   # Flutter desktop application
│   └── server/                   # FastAPI backend services
│
├── tests/                        # 🧪 Integration & E2E tests
│   ├── e2e/                      # End-to-end scenarios
│   ├── integration/              # API integration tests
│   └── fixtures/                 # Test data & mocks
│
├── .env.example                  # Environment variable template
├── .gitignore                    # Git ignore rules
├── .pre-commit-config.yaml       # Pre-commit hooks
├── AGENTS.md                     # Role definitions (links to context/)
├── CHANGELOG.md                  # Release notes (auto-generated)
├── CONTRIBUTING.md               # Contributor guide (links to context/)
├── LICENSE                       # MIT/Apache/Proprietary
├── pyproject.toml                # Python dependencies (Poetry/Rye)
├── pubspec.yaml                  # Dart/Flutter dependencies
├── pyrightconfig.json            # Python type checker config
├── README.md                     # Project overview (links to context/)
└── RULES.md                      # Project constitution (links to context/)
```

---

## 🐍 Backend Structure (Python/FastAPI)

### Full Structure
```
src/server/
├── __init__.py                   # Package marker
├── main.py                       # 🚀 Application entry point
│
├── api/                          # 🌐 API Layer (Controllers/Routers)
│   ├── __init__.py
│   ├── dependencies.py           # FastAPI dependency injections
│   ├── middleware.py             # Request/response middleware
│   │
│   └── v1/                       # API Version 1
│       ├── __init__.py
│       ├── router.py             # Main router aggregator
│       ├── auth.py               # Authentication endpoints
│       ├── users.py              # User management endpoints
│       ├── projects.py           # Project CRUD endpoints
│       ├── tasks.py              # Task CRUD endpoints
│       ├── comments.py           # Comment endpoints
│       └── analytics.py          # Reporting endpoints
│
├── core/                         # ⚙️ Configuration & Cross-Cutting
│   ├── __init__.py
│   ├── config.py                 # Settings (Pydantic Settings)
│   ├── security.py               # JWT, password hashing
│   ├── database.py               # SQLAlchemy engine & session
│   ├── cache.py                  # Redis client configuration
│   ├── logging.py                # Structured logging setup
│   └── exceptions.py             # Custom exception classes
│
├── domain/                       # 🧠 Business Logic (Clean Architecture)
│   ├── __init__.py
│   │
│   ├── models/                   # SQLAlchemy ORM models
│   │   ├── __init__.py
│   │   ├── base.py               # Base model with common fields
│   │   ├── user.py               # User entity
│   │   ├── project.py            # Project entity
│   │   ├── task.py               # Task entity
│   │   ├── comment.py            # Comment entity
│   │   └── attachment.py         # File attachment entity
│   │
│   ├── schemas/                  # Pydantic DTOs (Request/Response)
│   │   ├── __init__.py
│   │   ├── user.py               # UserCreate, UserRead, UserUpdate
│   │   ├── project.py            # ProjectCreate, ProjectRead, etc.
│   │   ├── task.py               # TaskCreate, TaskRead, etc.
│   │   └── auth.py               # LoginRequest, TokenResponse
│   │
│   ├── repositories/             # Data Access Layer (abstractions)
│   │   ├── __init__.py
│   │   ├── base.py               # Generic CRUD repository
│   │   ├── user_repository.py   # User-specific queries
│   │   ├── task_repository.py   # Task-specific queries
│   │   └── project_repository.py # Project-specific queries
│   │
│   └── services/                 # Business Logic Services
│       ├── __init__.py
│       ├── auth_service.py       # Authentication logic
│       ├── task_service.py       # Task business rules
│       ├── project_service.py    # Project business rules
│       ├── notification_service.py # Email/push notifications
│       └── analytics_service.py  # Reporting calculations
│
├── infrastructure/               # 🔌 External Integrations
│   ├── __init__.py
│   ├── email/                    # Email service adapters
│   │   ├── __init__.py
│   │   ├── interface.py          # Abstract email sender
│   │   ├── sendgrid.py           # SendGrid implementation
│   │   └── smtp.py               # SMTP implementation (dev)
│   │
│   ├── storage/                  # File storage adapters
│   │   ├── __init__.py
│   │   ├── interface.py          # Abstract storage
│   │   ├── s3.py                 # AWS S3 implementation
│   │   └── local.py              # Local disk (dev)
│   │
│   └── llm/                      # AI Model integrations
│       ├── __init__.py
│       ├── groq_client.py        # Groq API wrapper
│       └── prompt_templates.py   # Prompt engineering
│
├── migrations/                   # 📊 Database Migrations (Alembic)
│   ├── versions/                 # Migration scripts
│   │   ├── 001_initial_schema.py
│   │   ├── 002_add_task_tags.py
│   │   └── 003_add_user_roles.py
│   ├── env.py                    # Alembic environment config
│   └── alembic.ini               # Alembic configuration
│
├── tests/                        # 🧪 Backend Unit Tests
│   ├── __init__.py
│   ├── conftest.py               # Pytest fixtures
│   │
│   ├── api/                      # API endpoint tests
│   │   ├── test_auth.py
│   │   ├── test_users.py
│   │   └── test_tasks.py
│   │
│   ├── domain/                   # Business logic tests
│   │   ├── test_task_service.py
│   │   └── test_auth_service.py
│   │
│   └── infrastructure/           # Integration tests (external services)
│       ├── test_email_sendgrid.py
│       └── test_storage_s3.py
│
└── utils/                        # 🛠️ Utility Functions
    ├── __init__.py
    ├── datetime_helpers.py       # Timezone conversions
    ├── string_helpers.py         # Sanitization, slugify
    └── validators.py             # Custom Pydantic validators
```

### Key Files Explained

#### 1. `main.py` - Application Entry Point
```python
"""
FastAPI application initialization.
Aggregates routers, configures middleware, sets up CORS.
"""
from fastapi import FastAPI
from src.server.api.v1.router import api_router
from src.server.core.config import settings

app = FastAPI(
    title="TaskFlow Pro API",
    version="1.5.2",
    docs_url="/docs" if settings.ENVIRONMENT == "development" else None,
)

# Include routers
app.include_router(api_router, prefix="/api/v1")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "version": "1.5.2"}
```

#### 2. `api/v1/tasks.py` - API Endpoint Example
```python
"""
Task management endpoints.
Handles CRUD operations for tasks.
"""
from fastapi import APIRouter, Depends, HTTPException
from src.server.core.security import get_current_user
from src.server.domain.schemas.task import TaskCreate, TaskRead
from src.server.domain.services.task_service import TaskService

router = APIRouter(prefix="/tasks", tags=["tasks"])

@router.post("/", response_model=TaskRead)
async def create_task(
    task_data: TaskCreate,
    current_user = Depends(get_current_user),
    task_service: TaskService = Depends(),
):
    """Create a new task."""
    return await task_service.create_task(task_data, user=current_user)
```

#### 3. `domain/models/task.py` - SQLAlchemy Model
```python
"""
Task entity (ORM model).
Represents a task in the database.
"""
from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from src.server.domain.models.base import Base

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True)
    title = Column(String(255), nullable=False)
    description = Column(String(10000), nullable=True)
    status = Column(String(50), default="open")

    # Relationships
    project_id = Column(Integer, ForeignKey("projects.id"))
    project = relationship("Project", back_populates="tasks")

    assignee_id = Column(Integer, ForeignKey("users.id"))
    assignee = relationship("User", foreign_keys=[assignee_id])
```

#### 4. `domain/schemas/task.py` - Pydantic DTO
```python
"""
Task data transfer objects (request/response schemas).
"""
from pydantic import BaseModel, Field
from datetime import datetime

class TaskCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: str | None = Field(None, max_length=10000)
    project_id: int
    assignee_id: int | None = None

class TaskRead(TaskCreate):
    id: int
    status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True  # SQLAlchemy ORM compatibility
```

---

## 📱 Frontend Structure (Dart/Flutter)

### Full Structure
```
src/client/
├── assets/                       # Static resources
│   ├── fonts/                    # Custom fonts
│   │   ├── Roboto-Regular.ttf
│   │   └── Roboto-Bold.ttf
│   ├── images/                   # App icons, logos
│   │   ├── logo.png
│   │   └── placeholder-avatar.png
│   └── icons/                    # Custom icon set
│       └── task_icon.svg
│
├── lib/                          # Dart source code
│   ├── main.dart                 # 🚀 Application entry point
│   │
│   ├── core/                     # Core functionality (shared)
│   │   ├── config/               # App configuration
│   │   │   ├── app_config.dart   # Environment settings
│   │   │   └── theme_config.dart # Material theme definition
│   │   │
│   │   ├── errors/               # Error handling
│   │   │   ├── failures.dart     # Failure types (sealed classes)
│   │   │   └── exceptions.dart   # Custom exceptions
│   │   │
│   │   ├── network/              # HTTP client setup
│   │   │   ├── api_client.dart   # Dio configuration
│   │   │   └── interceptors.dart # Auth token injection
│   │   │
│   │   ├── storage/              # Local persistence
│   │   │   ├── hive_service.dart # Hive database wrapper
│   │   │   └── secure_storage.dart # Encrypted storage
│   │   │
│   │   └── utils/                # Utility functions
│   │       ├── date_formatter.dart
│   │       ├── validators.dart
│   │       └── constants.dart
│   │
│   ├── features/                 # Feature modules (vertical slices)
│   │   │
│   │   ├── auth/                 # Authentication feature
│   │   │   ├── data/             # Data layer
│   │   │   │   ├── datasources/  # API clients
│   │   │   │   │   └── auth_remote_datasource.dart
│   │   │   │   ├── models/       # JSON serialization models
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/ # Repository implementations
│   │   │   │       └── auth_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/           # Domain layer (business logic)
│   │   │   │   ├── entities/     # Domain entities
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/ # Repository interfaces
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/     # Business use cases
│   │   │   │       ├── login_usecase.dart
│   │   │   │       └── logout_usecase.dart
│   │   │   │
│   │   │   └── presentation/     # Presentation layer (UI)
│   │   │       ├── pages/        # Full screen pages
│   │   │       │   ├── login_page.dart
│   │   │       │   └── register_page.dart
│   │   │       ├── widgets/      # Feature-specific widgets
│   │   │       │   ├── login_form.dart
│   │   │       │   └── password_field.dart
│   │   │       └── providers/    # Riverpod state management
│   │   │           └── auth_provider.dart
│   │   │
│   │   ├── tasks/                # Task management feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── task_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── task_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── task_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── task.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── task_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── create_task_usecase.dart
│   │   │   │       ├── update_task_usecase.dart
│   │   │   │       └── delete_task_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── task_list_page.dart
│   │   │       │   └── task_detail_page.dart
│   │   │       ├── widgets/
│   │   │       │   ├── task_card.dart
│   │   │       │   └── task_form.dart
│   │   │       └── providers/
│   │   │           └── task_provider.dart
│   │   │
│   │   ├── projects/             # Project management feature
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── analytics/            # Analytics & reporting feature
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   ├── shared/                   # Shared widgets & components
│   │   ├── widgets/              # Reusable UI components
│   │   │   ├── buttons/
│   │   │   │   ├── primary_button.dart
│   │   │   │   └── secondary_button.dart
│   │   │   ├── cards/
│   │   │   │   └── info_card.dart
│   │   │   ├── dialogs/
│   │   │   │   ├── confirmation_dialog.dart
│   │   │   │   └── error_dialog.dart
│   │   │   └── loading/
│   │   │       ├── shimmer_loader.dart
│   │   │       └── circular_progress.dart
│   │   │
│   │   └── extensions/           # Dart extensions
│   │       ├── context_extensions.dart
│   │       └── string_extensions.dart
│   │
│   └── app.dart                  # App widget configuration
│
├── test/                         # Unit & widget tests
│   ├── core/
│   │   └── network/
│   │       └── api_client_test.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl_test.dart
│   │   │   └── domain/
│   │   │       └── usecases/
│   │   │           └── login_usecase_test.dart
│   │   │
│   │   └── tasks/
│   │       ├── domain/
│   │       │   └── usecases/
│   │       │       └── create_task_usecase_test.dart
│   │       └── presentation/
│   │           └── widgets/
│   │               └── task_card_test.dart
│   │
│   └── helpers/                  # Test utilities
│       ├── mock_data.dart
│       └── test_helpers.dart
│
├── integration_test/             # Integration tests
│   ├── app_test.dart             # Full app flow test
│   └── auth_flow_test.dart       # Login/logout flow
│
├── analysis_options.yaml         # Dart analyzer configuration
├── pubspec.yaml                  # Dependencies & assets
└── README.md                     # Frontend-specific docs
```

### Key Files Explained

#### 1. `main.dart` - Entry Point
```dart
// Application entry point.
// Initializes Riverpod, Hive, and runs the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (local database)
  await HiveService.init();

  // Initialize secure storage
  await SecureStorage.init();

  runApp(
    const ProviderScope(
      child: TaskFlowApp(),
    ),
  );
}
```

#### 2. `features/auth/domain/entities/user.dart` - Domain Entity
```dart
/// User entity (domain layer).
/// Contains core business logic, no serialization.
class User {
  final int id;
  final String email;
  final String fullName;
  final UserRole role;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
}
```

#### 3. `features/auth/data/models/user_model.dart` - Data Model
```dart
/// User model (data layer).
/// Handles JSON serialization (API communication).
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
```

#### 4. `features/tasks/presentation/providers/task_provider.dart` - Riverpod Provider
```dart
/// Task list state provider.
/// Manages task list state with Riverpod.
@riverpod
class TaskList extends _$TaskList {
  @override
  FutureOr<List<Task>> build() async {
    final repository = ref.watch(taskRepositoryProvider);
    return repository.getTasks();
  }

  Future<void> addTask(TaskCreate taskData) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(taskRepositoryProvider);
      await repository.createTask(taskData);
      return repository.getTasks(); // Refresh list
    });
  }
}
```

---

## 🐳 Infrastructure & DevOps

```
infrastructure/
├── docker/
│   ├── Dockerfile.backend         # Python FastAPI image
│   ├── Dockerfile.frontend        # Flutter build image (for web/server)
│   └── Dockerfile.nginx           # Reverse proxy
│
├── kubernetes/                    # K8s manifests (production)
│   ├── deployments/
│   │   ├── backend-deployment.yaml
│   │   └── frontend-deployment.yaml
│   ├── services/
│   │   ├── backend-service.yaml
│   │   └── frontend-service.yaml
│   └── ingress/
│       └── ingress.yaml
│
├── terraform/                     # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── vpc/
│       ├── rds/                   # PostgreSQL database
│       └── s3/                    # File storage
│
├── monitoring/                    # Observability configs
│   ├── prometheus.yml             # Metrics scraping
│   ├── grafana-dashboards/        # Pre-built dashboards
│   │   ├── api-performance.json
│   │   └── database-health.json
│   └── alertmanager.yml           # Alert routing
│
└── docker-compose.yml             # Local development stack
```

### `docker-compose.yml` Example
```yaml
version: '3.9'

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: taskflow
      POSTGRES_PASSWORD: dev_password
      POSTGRES_DB: taskflow_pro
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build:
      context: .
      dockerfile: infrastructure/docker/Dockerfile.backend
    environment:
      DATABASE_URL: postgresql://taskflow:dev_password@postgres/taskflow_pro
      REDIS_URL: redis://redis:6379/0
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - redis

volumes:
  postgres_data:
```

---

## 📖 Documentation (context/)

```
context/
├── 00-DISCOVERY/                  # Phase 0: Initial interview
│   ├── INTERVIEW.md               # Q&A with stakeholders
│   ├── PROJECT_BRIEF.md           # One-page executive summary
│   └── TECH_STACK.md              # Technology choices (initial)
│
├── 10-CONTEXT/                    # Phase 1: Vision & context
│   ├── VISION.md                  # Long-term project vision
│   ├── PROMISE.md                 # Value proposition
│   ├── JOURNEY_MAP.md             # User journey visualization
│   ├── EXECUTIVE_SUMMARY.md       # Stakeholder summary
│   ├── GLOSSARY.md                # Technical terms dictionary
│   ├── DOMAIN_LANGUAGE.md         # Ubiquitous language (DDD)
│   └── PROJECT_MANIFESTO.md       # Core principles
│
├── 20-REQUIREMENTS/               # Phase 2: Requirements
│   ├── FUNCTIONAL.md              # Feature specifications
│   ├── NON_FUNCTIONAL.md          # Performance, scalability
│   ├── ACCESSIBILITY.md           # WCAG 2.1 AA compliance
│   ├── SECURITY.md                # OWASP Top 10, data sovereignty
│   ├── API_CONTRACT.md            # OpenAPI specification
│   ├── DATABASE_SCHEMA.md         # ER diagrams & migrations
│   ├── DOR_DOD.md                 # Definition of Ready/Done
│   ├── REQUIREMENTS_MASTER.md     # Consolidated requirements
│   ├── SECURITY_PRIVACY_POLICY.md # GDPR, CCPA compliance
│   ├── COMPLIANCE_MATRIX.md       # Regulatory checklist
│   └── USER_STORIES_MASTER.json   # Complete backlog
│
├── 30-ARCHITECTURE/               # Phase 3: Architecture
│   ├── SYSTEM_DIAGRAM.md          # C4 model diagrams
│   ├── ADR.md                     # Architecture Decision Records
│   ├── TECH_STACK_DETAILED.md     # Libraries, frameworks, versions
│   ├── DEPLOYMENT.md              # Infrastructure diagram
│   ├── API_INTERFACE_CONTRACT.md  # OpenAPI 3.1.0 spec
│   ├── DATA_MODEL_SCHEMA.md       # Database ER diagram
│   ├── PROJECT_STRUCTURE_MAP.md   # This document
│   ├── SECURITY_THREAT_MODEL.md   # STRIDE analysis
│   └── TECH_STACK_DECISION.md     # Technology rationale
│
├── 35-UX_UI/                      # Phase 3.5: Design
│   ├── ACCESSIBILITY_GUIDE.md     # WCAG checklist
│   ├── DESIGN_SYSTEM.md           # Colors, typography, components
│   └── UI_WIREFRAMES_FLOW.md      # Figma/Sketch links
│
├── 40-ROADMAP/                    # Phase 4: Planning
│   ├── USER_STORIES_MASTER.json   # Backlog (JSON format)
│   ├── SPRINT_PLAN.md             # First 3 sprints detailed
│   ├── CI_CD_PIPELINE.md          # Deployment pipeline
│   ├── DEPLOYMENT_INFRASTRUCTURE.md # Cloud architecture
│   ├── ROADMAP_PHASES.md          # 12-month roadmap
│   └── TESTING_STRATEGY.md        # Test plan & coverage
│
└── 50-IMPLEMENTATION/             # Phase 5: Implementation
    └── FIRST_SPRINT_GUIDE.md      # Code structure, setup steps
```

---

## 🧪 Testing Structure

```
tests/
├── e2e/                           # End-to-end tests (full user flows)
│   ├── conftest.py                # Playwright fixtures
│   ├── test_user_registration_flow.py
│   ├── test_task_creation_flow.py
│   └── test_project_collaboration_flow.py
│
├── integration/                   # API integration tests
│   ├── conftest.py                # FastAPI TestClient setup
│   ├── test_auth_api.py           # /api/v1/auth endpoints
│   ├── test_tasks_api.py          # /api/v1/tasks endpoints
│   └── test_projects_api.py       # /api/v1/projects endpoints
│
├── fixtures/                      # Test data & mocks
│   ├── mock_users.json            # Test user data
│   ├── mock_tasks.json            # Test task data
│   └── factory.py                 # Object factories (FactoryBoy)
│
└── performance/                   # Load & stress tests
    ├── locustfile.py              # Locust load test scenarios
    └── test_api_benchmarks.py     # Performance regression tests
```

---

## 📝 File Naming Conventions

### Python (Backend)
- **Files:** `snake_case.py` (e.g., `task_service.py`, `user_repository.py`)
- **Classes:** `PascalCase` (e.g., `TaskService`, `UserRepository`)
- **Functions:** `snake_case` (e.g., `create_task`, `get_user_by_id`)
- **Constants:** `UPPER_SNAKE_CASE` (e.g., `MAX_TASK_TITLE_LENGTH`)
- **Private:** `_leading_underscore` (e.g., `_internal_method`)

### Dart (Frontend)
- **Files:** `snake_case.dart` (e.g., `task_card.dart`, `auth_provider.dart`)
- **Classes:** `PascalCase` (e.g., `TaskCard`, `AuthProvider`)
- **Methods/Variables:** `camelCase` (e.g., `fetchTasks`, `currentUser`)
- **Constants:** `lowerCamelCase` (e.g., `maxTitleLength`, `apiEndpoint`)
- **Private:** `_leadingUnderscore` (e.g., `_buildTaskList`)

### Documentation (Markdown)
- **Files:** `UPPER_SNAKE_CASE.md` (e.g., `API_CONTRACT.md`, `SECURITY_THREAT_MODEL.md`)
- **Sections:** Title Case with hyphens (e.g., `## User Authentication Flow`)

### Infrastructure
- **Docker:** `Dockerfile.<service>` (e.g., `Dockerfile.backend`, `Dockerfile.nginx`)
- **K8s:** `<resource>-<name>.yaml` (e.g., `deployment-backend.yaml`, `service-frontend.yaml`)
- **Scripts:** `kebab-case.sh` (e.g., `setup-dev-env.sh`, `run-migrations.sh`)

---

## 🚫 Anti-Patterns (Forbidden Locations)

### ❌ DO NOT Create Files Here

#### 1. Root-Level Code Files
```
❌ WRONG:
taskflow-pro/
├── utils.py          # Should be in src/server/utils/
├── helpers.dart      # Should be in lib/core/utils/
└── constants.ts      # Should be in packages/common/constants/

✅ CORRECT:
src/server/utils/string_helpers.py
lib/core/utils/date_formatter.dart
packages/common/constants/api_routes.ts
```

#### 2. Flat Feature Structure
```
❌ WRONG (Flutter):
lib/
├── login_page.dart
├── task_list_page.dart
├── user_service.dart
└── api_client.dart

✅ CORRECT (Feature Slicing):
lib/features/auth/presentation/pages/login_page.dart
lib/features/tasks/presentation/pages/task_list_page.dart
lib/features/auth/domain/usecases/login_usecase.dart
lib/core/network/api_client.dart
```

#### 3. Mixed Test Locations
```
❌ WRONG:
src/server/api/v1/tasks.py
src/server/api/v1/test_tasks.py  # Test next to source

✅ CORRECT:
src/server/api/v1/tasks.py
src/server/tests/api/test_tasks.py  # Tests in tests/
```

#### 4. Documentation Outside context/
```
❌ WRONG:
docs/
├── architecture.md
├── api-spec.md
└── security.md

✅ CORRECT:
context/30-ARCHITECTURE/SYSTEM_DIAGRAM.md
context/20-REQUIREMENTS/API_CONTRACT.md
context/20-REQUIREMENTS/SECURITY.md
```

---

## 🔍 File Location Decision Tree

```mermaid
graph TD
    A[I need to create a file] --> B{What type?}

    B -->|Code| C{Backend or Frontend?}
    C -->|Backend| D{What layer?}
    D -->|API Endpoint| E[src/server/api/v1/]
    D -->|Business Logic| F[src/server/domain/services/]
    D -->|Database Model| G[src/server/domain/models/]
    D -->|External Integration| H[src/server/infrastructure/]

    C -->|Frontend| I{What layer?}
    I -->|UI Component| J[lib/features/{feature}/presentation/]
    I -->|Business Logic| K[lib/features/{feature}/domain/]
    I -->|API Client| L[lib/features/{feature}/data/]
    I -->|Shared Widget| M[lib/shared/widgets/]

    B -->|Documentation| N{Which phase?}
    N -->|Requirements| O[context/20-REQUIREMENTS/]
    N -->|Architecture| P[context/30-ARCHITECTURE/]
    N -->|Planning| Q[context/40-ROADMAP/]

    B -->|Tests| R{Test type?}
    R -->|Unit/Integration| S[src/{backend|client}/tests/]
    R -->|E2E| T[tests/e2e/]

    B -->|Infrastructure| U{What kind?}
    U -->|Docker| V[infrastructure/docker/]
    U -->|Kubernetes| W[infrastructure/kubernetes/]
    U -->|Terraform| X[infrastructure/terraform/]
```

---

## 🔄 Document Maintenance

**Review Frequency:** Monthly (whenever new patterns emerge)
**Owner:** Lead Architect
**Approval Required:** Lead Architect + 1 senior developer

**Version History:**

### v2.3.0 (February 2026)
- Added `packages/` for shared libraries
- Clarified feature slicing for Flutter (data/domain/presentation)
- Added Kubernetes structure

### v2.2.0 (January 2026)
- Split API versioning (`api/v1/`, `api/v2/`)
- Added infrastructure monitoring configs
- Introduced repository pattern in backend

### v2.1.0 (December 2025)
- Initial documented structure
- Established Clean Architecture layers

---

## 📚 References

### Internal Documents
- [RULES.md](../00-ROOT/RULES.md) - Project constitution
- [TECH_STACK_DECISION.md](TECH_STACK_DECISION.md) - Technology choices
- [TESTING_STRATEGY.md](../40-PLANNING/TESTING_STRATEGY.md) - Test requirements

### External Standards
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Feature-Sliced Design](https://feature-sliced.design/)
- [Python PEP 8](https://pep8.org/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

---

**Document Signature:**

```
Approved by:
- Sarah Chen (Lead Architect) - February 22, 2026

Next Review Date: March 22, 2026
```

---

*This document is version-controlled and stored in `context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.md`. Structural changes require ADR approval.*
