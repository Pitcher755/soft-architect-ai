# 🧪 Test-Driven Development (TDD) Methodology

> **Fecha:** 30/01/2026
> **Estado:** ✅ MANDATORY
> **Filosofía:** "No escribas código de producción a menos que sea para pasar un test fallido"
> **Ciclo:** Red 🔴 → Green 🟢 → Refactor 🔵
> **Objetivo:** Código confiable, mantenible, documentado por tests

Test-Driven Development es la columna vertebral de la calidad en SoftArchitect. No es una sugerencia.

---

## 📖 Tabla de Contenidos

1. [El Ciclo Sagrado (The Red-Green-Refactor Loop)](#el-ciclo-sagrado-the-red-green-refactor-loop)
2. [Estructura AAA (Arrange-Act-Assert)](#estructura-aaa-arrange-act-assert)
3. [Ejemplos Prácticos](#ejemplos-prácticos)
4. [Testing Piramid](#testing-piramid)
5. [Best Practices por Lenguaje](#best-practices-por-lenguaje)
6. [Métricas de Coverage](#métricas-de-coverage)
7. [Anti-Patterns & Errores Comunes](#anti-patterns--errores-comunes)

---

## El Ciclo Sagrado (The Red-Green-Refactor Loop)

```
┌──────────────────────────────────────────────────────────┐
│                 RED-GREEN-REFACTOR LOOP                  │
├──────────────────────────────────────────────────────────┤
│                                                          │
│   🔴 RED: Test Falla                                    │
│   ├─ Escribir test para feature que NO existe           │
│   ├─ Resultado: Test MUST fail (compilación o assert)   │
│   └─ Propósito: Definir interfaz y comportamiento       │
│                                                          │
│        ↓↓↓ [Implementar código mínimo] ↓↓↓               │
│                                                          │
│   🟢 GREEN: Test Pasa                                   │
│   ├─ Escribir código MÍNIMO para que pase               │
│   ├─ Vale hardcodear, vale código feo                   │
│   ├─ Importante: Ver la barra verde                     │
│   └─ Resultado: Test MUST pass                          │
│                                                          │
│        ↓↓↓ [Mejorar el código] ↓↓↓                       │
│                                                          │
│   🔵 REFACTOR: Optimizar                                │
│   ├─ Mejorar código SIN cambiar comportamiento          │
│   ├─ Aplicar SOLID, Clean Code                          │
│   ├─ Seguridad: El test en verde = puedes refactorizar │
│   └─ Test sigue pasando                                 │
│                                                          │
│        ↓↓↓ [Volver al inicio] ↓↓↓                        │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Estructura AAA (Arrange-Act-Assert)

Cada test tiene 3 fases:

```
┌───────────────────────────┐
│ 1️⃣  ARRANGE (Preparar)    │
│ Configurar fixtures,      │
│ crear mocks, setup datos  │
├───────────────────────────┤
│ 2️⃣  ACT (Actuar)          │
│ Ejecutar código a testear │
├───────────────────────────┤
│ 3️⃣  ASSERT (Afirmar)      │
│ Verificar resultados      │
└───────────────────────────┘
```

### Plantilla Universal

```python
def test_something():
    # 1️⃣ ARRANGE: Setup
    input_data = {"email": "test@test.com"}
    expected_output = User(id=1, email="test@test.com")
    mock_repo = MagicMock()
    service = UserService(mock_repo)

    # 2️⃣ ACT: Ejecutar
    result = service.create_user(input_data)

    # 3️⃣ ASSERT: Verificar
    assert result.id == expected_output.id
    assert result.email == expected_output.email
    mock_repo.save.assert_called_once()
```

---

## Ejemplos Prácticos

### Ejemplo 1: Feature Simple (User Creation)

#### 🔴 RED: Escribir Test Primero

```python
# tests/unit/domain/services/test_user_service.py

import pytest
from unittest.mock import MagicMock, AsyncMock
from src.domain.services.user_service import UserService
from src.domain.models.user import User
from src.domain.exceptions import UserAlreadyExistsError

@pytest.mark.asyncio
async def test_create_user_with_valid_email():
    """
    GIVEN: Email y contraseña válidas
    WHEN: Crear usuario
    THEN: Debe retornar usuario con ID
    """
    # 1️⃣ ARRANGE
    email = "john@example.com"
    password = "SecurePass123!"
    expected_user = User(id=1, email=email, is_active=True)

    # Mock del repositorio
    mock_repo = AsyncMock()
    mock_repo.get_user_by_email.return_value = None  # No existe
    mock_repo.save.return_value = expected_user

    service = UserService(repo=mock_repo)

    # 2️⃣ ACT
    result = await service.create(email=email, password=password)

    # 3️⃣ ASSERT
    assert result.id == 1
    assert result.email == email
    assert result.is_active is True
    mock_repo.get_user_by_email.assert_called_once_with(email)
    mock_repo.save.assert_called_once()


@pytest.mark.asyncio
async def test_create_user_with_existing_email():
    """
    GIVEN: Email que ya existe
    WHEN: Intentar crear usuario
    THEN: Debe lanzar UserAlreadyExistsError
    """
    # 1️⃣ ARRANGE
    email = "existing@example.com"
    existing_user = User(id=1, email=email)

    mock_repo = AsyncMock()
    mock_repo.get_user_by_email.return_value = existing_user

    service = UserService(repo=mock_repo)

    # 2️⃣ ACT & 3️⃣ ASSERT
    with pytest.raises(UserAlreadyExistsError):
        await service.create(email=email, password="ValidPass123!")
```

**Estado:** Test FALLA ❌ (porque `UserService` no existe aún)

#### 🟢 GREEN: Implementación Mínima

```python
# src/domain/services/user_service.py

from typing import Optional
from src.domain.models.user import User
from src.domain.repositories import IUserRepository
from src.domain.exceptions import UserAlreadyExistsError


class UserService:
    def __init__(self, repo: IUserRepository):
        self.repo = repo

    async def create(self, email: str, password: str) -> User:
        """Crear usuario nuevo."""
        # Verificar que email no existe
        existing = await self.repo.get_user_by_email(email)
        if existing:
            raise UserAlreadyExistsError(f"User with {email} already exists")

        # Crear usuario (mínimo necesario)
        new_user = User(id=1, email=email, is_active=True)
        return await self.repo.save(new_user)
```

**Estado:** Test PASA ✅

#### 🔵 REFACTOR: Implementación Real

```python
# src/domain/services/user_service.py

import logging
from typing import Optional
from datetime import datetime
from src.domain.models.user import User
from src.domain.repositories import IUserRepository
from src.domain.exceptions import UserAlreadyExistsError
from src.core.security import hash_password

logger = logging.getLogger(__name__)


class UserService:
    def __init__(self, repo: IUserRepository):
        self.repo = repo

    async def create(self, email: str, password: str) -> User:
        """
        Crear usuario nuevo con contraseña hasheada.

        Args:
            email: Email del usuario (única)
            password: Contraseña en texto plano (será hasheada)

        Returns:
            User: Usuario creado con ID asignado

        Raises:
            UserAlreadyExistsError: Si email ya existe
            ValueError: Si email/password no válidos
        """
        # Validar formato de email
        if not self._is_valid_email(email):
            raise ValueError(f"Invalid email format: {email}")

        # Validar contraseña
        if not self._is_valid_password(password):
            raise ValueError("Password must be >= 12 chars with upper/number/symbol")

        # Verificar que email no existe
        existing = await self.repo.get_user_by_email(email)
        if existing:
            logger.warning(f"Attempt to create user with existing email: {email}")
            raise UserAlreadyExistsError(f"User with {email} already exists")

        # Hash de contraseña
        hashed_password = hash_password(password)

        # Crear usuario
        new_user = User(
            email=email,
            hashed_password=hashed_password,
            is_active=True,
            created_at=datetime.utcnow(),
        )

        # Persistir
        saved_user = await self.repo.save(new_user)
        logger.info(f"User created: {saved_user.id}")

        return saved_user

    @staticmethod
    def _is_valid_email(email: str) -> bool:
        """Validar formato de email básico."""
        import re
        pattern = r'^[\w\.-]+@[\w\.-]+\.\w+$'
        return re.match(pattern, email) is not None

    @staticmethod
    def _is_valid_password(password: str) -> bool:
        """Validar requisitos de contraseña."""
        return (
            len(password) >= 12 and
            any(c.isupper() for c in password) and
            any(c.isdigit() for c in password) and
            any(c in "!@#$%^&*" for c in password)
        )
```

**Estado:** Test SIGUE PASANDO ✅ (comportamiento no cambió, solo interno mejoró)

---

### Ejemplo 2: Error Handling (Flutter)

#### 🔴 RED: Test para Manejo de Errores

```dart
// test/unit/domain/repositories/document_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group('DocumentRepository', () {
    test('getDocuments throws exception when network fails', () async {
      // 1️⃣ ARRANGE
      final mockDatasource = MockRemoteDatasource();
      when(mockDatasource.fetchDocuments()).thenThrow(
        SocketException('Network error'),
      );

      final repository = DocumentRepository(mockDatasource);

      // 2️⃣ ACT & 3️⃣ ASSERT
      expect(
        () => repository.getDocuments(),
        throwsA(isA<SocketException>()),
      );
    });

    test('getDocuments returns cached data on network error', () async {
      // 1️⃣ ARRANGE
      final mockDatasource = MockRemoteDatasource();
      final mockCache = MockLocalCache();

      when(mockDatasource.fetchDocuments()).thenThrow(
        SocketException('Network error'),
      );

      final cachedDocs = [
        Document(id: 1, title: 'Cached Doc'),
      ];
      when(mockCache.getDocuments()).thenAnswer((_) async => cachedDocs);

      final repository = DocumentRepository(
        remoteDatasource: mockDatasource,
        cache: mockCache,
      );

      // 2️⃣ ACT
      final result = await repository.getDocuments();

      // 3️⃣ ASSERT
      expect(result, cachedDocs);
      mockCache.getDocuments.verify().called(1);
    });
  });
}
```

**Estado:** Test FALLA ❌

#### 🟢 GREEN: Implementación Mínima

```dart
// lib/domain/repositories/document_repository.dart

class DocumentRepository {
  final RemoteDatasource _remoteDatasource;
  final LocalCache _cache;

  DocumentRepository({
    required RemoteDatasource remoteDatasource,
    required LocalCache cache,
  })  : _remoteDatasource = remoteDatasource,
        _cache = cache;

  Future<List<Document>> getDocuments() async {
    try {
      return await _remoteDatasource.fetchDocuments();
    } on SocketException {
      // Si falla red, devolver cache
      return await _cache.getDocuments();
    }
  }
}
```

**Estado:** Test PASA ✅

#### 🔵 REFACTOR: Logging y Mejor Handling

```dart
// lib/domain/repositories/document_repository.dart

import 'dart:developer' as developer;

class DocumentRepository {
  final RemoteDatasource _remoteDatasource;
  final LocalCache _cache;
  final Logger _logger;

  DocumentRepository({
    required RemoteDatasource remoteDatasource,
    required LocalCache cache,
    Logger? logger,
  })  : _remoteDatasource = remoteDatasource,
        _cache = cache,
        _logger = logger ?? Logger();

  Future<List<Document>> getDocuments() async {
    try {
      _logger.info('Fetching documents from remote...');
      final documents = await _remoteDatasource.fetchDocuments();
      _logger.info('Successfully fetched ${documents.length} documents');
      return documents;
    } on SocketException catch (e) {
      _logger.warning('Network error, falling back to cache: $e');
      try {
        final cached = await _cache.getDocuments();
        _logger.info('Returning ${cached.length} cached documents');
        return cached;
      } catch (cacheError) {
        _logger.error('Cache also failed: $cacheError');
        rethrow;
      }
    } on Exception catch (e) {
      _logger.error('Unexpected error: $e');
      rethrow;
    }
  }
}
```

**Estado:** Test SIGUE PASANDO ✅

---

## Testing Piramid

La estrategia de cobertura de SoftArchitect:

```
           /\
          /  \
         / 10%\         E2E / Widget Tests
        /  E2E \       (Verificar flow completo)
       /────────\
      /          \
     /    20%     \    Integration Tests
    /  Integration \  (Múltiples componentes)
   /────────────────\
  /                  \
 /        70%         \  Unit Tests
/    Unit Tests        \ (Lógica pura)
/──────────────────────\

Total = 100% cobertura
```

### Requerimientos

| Nivel | Herramienta | Cobertura | Ejemplos |
|:---|:---|:---:|:---|
| **Unit** | pytest / flutter_test | ≥ 70% | Validators, formatters, algorithms |
| **Integration** | pytest + sqlalchemy / flutter test | ≥ 20% | Repository + DB, Riverpod + API mock |
| **E2E** | integration_test / Selenium | ≥ 10% | Login flow, document CRUD end-to-end |

---

## Best Practices por Lenguaje

### Python (pytest)

#### ✅ GOOD: Test completo

```python
# tests/unit/domain/validators/test_email_validator.py

import pytest
from src.domain.validators.email_validator import EmailValidator

class TestEmailValidator:
    """Grupo lógico de tests."""

    @pytest.fixture
    def validator(self):
        """Setup compartido."""
        return EmailValidator()

    def test_valid_email(self, validator):
        """Email válido debe pasar."""
        assert validator.validate("user@example.com") is True

    def test_invalid_format(self, validator):
        """Email sin @ debe fallar."""
        assert validator.validate("invalid_email") is False

    @pytest.mark.parametrize("email", [
        "test@domain.com",
        "user.name+tag@example.co.uk",
        "test_email@subdomain.example.com",
    ])
    def test_multiple_valid_emails(self, validator, email):
        """Testear múltiples casos con parametrización."""
        assert validator.validate(email) is True

    @pytest.mark.asyncio
    async def test_async_validation(self, validator):
        """Test async."""
        result = await validator.async_validate("test@example.com")
        assert result is True
```

#### ❌ BAD: Anti-patterns

```python
# ❌ NO HACER ESTO

def test_everything():
    """Test que testea todo (ilegible)."""
    validator = EmailValidator()
    assert validator.validate("test@example.com")
    assert validator.validate("another@example.com")
    assert validator.validate("third@example.com")

def test_no_name():
    """Nombre no descriptivo."""
    assert something()

def test_with_print():
    """Loguear con print (no usar)."""
    print("Debug info")
    assert True

def test_logic_in_assertion():
    """Lógica compleja en assert."""
    assert all([validator.validate(e) for e in emails]) and len(emails) > 0
```

### Flutter (flutter_test)

#### ✅ GOOD: Widget Test

```dart
// test/features/documents/presentation/screens/document_list_screen_test.dart

void main() {
  group('DocumentListScreen', () {
    testWidgets('displays documents from Riverpod provider', (tester) async {
      // 1️⃣ ARRANGE
      const testDocuments = [
        Document(id: 1, title: 'Doc 1'),
        Document(id: 2, title: 'Doc 2'),
      ];

      final container = ProviderContainer(
        overrides: [
          documentsProvider.overrideWith((_) async => testDocuments),
        ],
      );

      // 2️⃣ ACT
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: DocumentListScreen(),
          ),
        ),
      );

      // 3️⃣ ASSERT
      expect(find.byType(ListTile), findsWidgets);
      expect(find.text('Doc 1'), findsOneWidget);
      expect(find.text('Doc 2'), findsOneWidget);
    });

    testWidgets('shows error message on load failure', (tester) async {
      // Similar a arriba pero con provider que falla
      final container = ProviderContainer(
        overrides: [
          documentsProvider.overrideWith((_) async {
            throw Exception('Network error');
          }),
        ],
      );

      await tester.pumpWidget(...);
      await tester.pumpAndSettle();  // Esperar async

      expect(find.text('Error loading documents'), findsOneWidget);
    });
  });
}
```

---

## Métricas de Coverage

### Medir Coverage

```bash
# Python
pytest --cov=src --cov-report=html tests/
# Abre htmlcov/index.html

# Flutter
flutter test --coverage
# Genera coverage/lcov.info
```

### Mínimos Obligatorios

```
- Backend (Python): ≥ 80% coverage
- Frontend (Flutter): ≥ 75% coverage
- Crítico (auth, payment): ≥ 95% coverage
```

### Reporte en CI/CD

```yaml
# .github/workflows/ci.yml

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage.xml
    fail_ci_if_error: true
    minimum_coverage: 80
```

---

## Anti-Patterns & Errores Comunes

### ❌ Test que No Testea

```python
# ❌ BAD: Test vacío
def test_something():
    pass  # No hay assertions!

# ❌ BAD: Test solo con setup, sin verificaciones
def test_user_creation():
    user = User(email="test@test.com")
    # ... nada más

# ✅ GOOD
def test_user_creation():
    user = User(email="test@test.com")
    assert user.email == "test@test.com"  # Verificar
```

### ❌ Test No Aislados

```python
# ❌ BAD: Dependencia entre tests
test_counter = 0

def test_first():
    global test_counter
    test_counter += 1
    assert test_counter == 1

def test_second():
    global test_counter
    test_counter += 1
    assert test_counter == 2  # Falla si test_first no corrió primero

# ✅ GOOD: Cada test independiente
@pytest.fixture
def counter():
    return 0

def test_first(counter):
    assert counter == 0  # Siempre
```

### ❌ Mocks Innecesarios

```python
# ❌ BAD: Mockear cosas reales y simples
def test_add():
    mock_math = MagicMock()
    mock_math.add = MagicMock(return_value=5)
    assert mock_math.add(2, 3) == 5  # Testeando el mock, no la función

# ✅ GOOD: Test directo para lógica simple
def test_add():
    result = add(2, 3)
    assert result == 5
```

### ❌ Assertions Genéricas

```python
# ❌ BAD: Mensaje de error poco útil
assert user is not None

# ✅ GOOD: Mensaje descriptivo
assert user is not None, f"User should exist for email {email}"
```

---

## Pre-Development Checklist

Antes de empezar a codificar:

```bash
# ✅ 1. Entender el requisito (User Story)
[ ] Leí el description de la HU completo
[ ] Entiendo los criterios de aceptación
[ ] Identifiqué edge cases

# ✅ 2. Escribir tests PRIMERO
[ ] Creé archivo de test (test_*.py / *_test.dart)
[ ] Escribí al menos 3 tests (happy path + 2 errores)
[ ] Tests fallan ❌

# ✅ 3. Implementar código mínimo
[ ] Tests pasan ✅
[ ] Código es feo/hardcoded (está bien en GREEN)

# ✅ 4. Refactorizar
[ ] Mejoré código (limpieza, logging, tipos)
[ ] Tests SIGUEN pasando ✅
[ ] Pasé linter (ruff, flutter analyze)

# ✅ 5. Verificación final
[ ] Coverage ≥ 80%
[ ] Sin print() o debugPrint()
[ ] Commit con mensaje Conventional
```

---

## Conclusión

**TDD es la garantía de calidad:**

1. ✅ **Tests primero:** Definen comportamiento esperado
2. ✅ **Cobertura alta:** Bugs detectados antes
3. ✅ **Refactor seguro:** El test es tu red de seguridad
4. ✅ **Documentación viva:** El test es la especificación

**Dogfooding Validation:** SoftArchitect desarrolla cada feature con TDD. Si el test falla, la feature no existe.
