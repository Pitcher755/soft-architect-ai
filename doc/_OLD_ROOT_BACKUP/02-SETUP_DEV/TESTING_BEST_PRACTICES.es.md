# Mejores Prácticas de Testing

> **Fecha:** 10/02/2026
> **Estado:** ✅ COMPLETE
> **Responsable:** ArchitectZero (Ingeniería de QA)

---

## 📖 Tabla de Contenidos

1. [Filosofía de Testing](#filosofía-de-testing)
2. [Estructura y Organización de Tests](#estructura-y-organización-de-tests)
3. [Convenciones de Nombrado](#convenciones-de-nombrado)
4. [Mocks vs Dependencias Reales](#mocks-vs-dependencias-reales)
5. [Gestión de Fixtures](#gestión-de-fixtures)
6. [Integración CI/CD](#integración-cicd)
7. [Patrones Comunes](#patrones-comunes)
8. [Solución de Problemas](#solución-de-problemas)

---

## Filosofía de Testing

### Ciclo TDD: Rojo → Verde → Refactorización

**Paso 1: ROJO - Escribir test que falla**
```python
def test_create_project_with_duplicate_id_fails():
    """La creación de proyecto debería fallar si ID ya existe."""
    with pytest.raises(ValidationError):
        repo.create_project(project)  # ← Esto falla (todavía no existe)
```

**Paso 2: VERDE - Implementar código mínimo**
```python
def create_project(self, project: Project) -> None:
    if self._project_exists(project.id):
        raise ValidationError("Project ID already exists")
    # ... resto de implementación
```

**Paso 3: REFACTORIZACIÓN - Optimizar sin cambiar comportamiento**
```python
def _validate_unique_id(self, project_id: str) -> None:
    """Separar preocupación de validación."""
    if self._project_exists(project_id):
        raise ValidationError("[VALIDATION_001_ID] Project ID already exists")
```

### Objetivos de Cobertura

```
Lógica de Negocio Crítica: 100%
  ├─ Modelos de dominio
  ├─ Casos de uso
  └─ Reglas de validación

Adaptadores Capa Datos: >90%
  ├─ Operaciones BD
  ├─ Manejo de errores
  └─ Casos borde

Endpoints API: >85%
  ├─ Caso feliz
  ├─ Casos de error
  └─ Validación de entrada

Componentes UI: >70% (Flutter)
  ├─ Renderizado de widgets
  ├─ Interacciones usuario
  └─ Cambios de estado
```

---

## Estructura y Organización de Tests

### Organización de Archivos

```
tests/
├── python/
│   ├── unit/                    # Tests rápidos, aislados
│   │   ├── domain/
│   │   │   └── test_models.py
│   │   ├── data/
│   │   │   └── test_repository.py
│   │   └── services/
│   │       └── test_rag_service.py
│   │
│   ├── integration/             # Tests interacciones, más lentos
│   │   ├── test_sqlite_performance.py
│   │   ├── test_security_sql_injection.py
│   │   └── test_api_endpoints.py
│   │
│   ├── e2e/                     # End-to-end, más lentos
│   │   └── test_complete_workflow.py
│   │
│   └── conftest.py              # Fixtures compartidos
│
└── dart/
    ├── unit/
    │   └── domain_test.dart
    ├── integration/
    │   └── provider_test.dart
    └── widget/
        └── layout_test.dart
```

### Organización de Clases de Test

```python
# ✅ BUEN - Organización clara
class TestSQLiteRepository:
    """Tests de repositorio SQLite."""

    # Setup & Teardown
    @pytest.fixture
    def repo(self, temp_db):
        """Crear repositorio con BD temporal."""
        return SQLiteRepository(TransactionManager(temp_db))

    # Tests CRUD
    class TestCreate:
        def test_create_project_success(self, repo): ...
        def test_create_duplicate_fails(self, repo): ...

    class TestRead:
        def test_get_project_found(self, repo): ...
        def test_get_project_not_found(self, repo): ...

    # Tests Casos Borde
    class TestEdgeCases:
        def test_empty_name_validation(self, repo): ...
        def test_special_characters_handled(self, repo): ...
```

---

## Convenciones de Nombrado

### Formato: `test_{método}_{escenario}_{resultado_esperado}`

**Análisis de Patrón:**

```
MÉTODO         → Qué función/método se prueba
ESCENARIO      → Condición de entrada o contexto
RESULTADO_ESPERADO → Qué debería suceder
```

### Ejemplos (✅ BUENOS)

```python
# ✅ Capa dominio
def test_project_validate_rejects_empty_name():
def test_project_validate_enforces_max_length():
def test_project_validate_accepts_valid_input():

# ✅ Capa datos
def test_repository_create_inserts_record():
def test_repository_get_by_id_returns_none_when_not_found():
def test_repository_update_modifies_existing():

# ✅ Integración
def test_api_list_projects_returns_200_with_data():
def test_api_create_project_rejects_invalid_input():
def test_security_sql_injection_in_name_prevented():

# ✅ Rendimiento
def test_bulk_insert_1000_records_within_target():
def test_query_by_name_sub_millisecond():
```

### Ejemplos (❌ MALOS)

```python
# ❌ Vago
def test_project():
def test_works():
def test_valid():

# ❌ Muy específico detalles impl
def test_sqlite_connection_open_close():
def test_cursor_execute_select():

# ❌ Múltiples escenarios
def test_create_and_delete():
def test_validation_and_persistence():
```

---

## Mocks vs Dependencias Reales

### Árbol de Decisión

```
┌─ ¿Es esta dependencia externa?
│  ├─ SÍ → Mock-earlo (a no ser que sea integration test)
│  └─ NO  ↓
└─ ¿Es lento/no determinista?
   ├─ SÍ → Mock-earlo
   └─ NO  ↓
      └─ Usar REAL para integration tests
```

### Ejemplo: Unit Test (Mock-eado)

```python
from unittest.mock import MagicMock, patch

class TestUserService:
    """Unit test con repositorio mock-eado."""

    def test_get_user_returns_user_dto(self):
        # MOCK el repositorio (dependencia externa)
        mock_repo = MagicMock(spec=UserRepository)
        mock_repo.get_user.return_value = User(id="1", name="Alice")

        service = UserService(mock_repo)
        user = service.get_user("1")

        assert user.name == "Alice"
        mock_repo.get_user.assert_called_once_with("1")
```

### Ejemplo: Integration Test (BD Real)

```python
class TestUserRepositoryIntegration:
    """Integration test con BD SQLite real."""

    @pytest.fixture
    def repo(self, temp_db):
        # Conexión BD REAL (no mock-eada)
        tx_manager = TransactionManager(temp_db)
        return UserRepository(tx_manager)

    def test_create_and_retrieve_user(self, repo):
        user = User(id="1", name="Bob")

        # Operaciones BD reales
        repo.create_user(user)
        retrieved = repo.get_user("1")

        assert retrieved.name == "Bob"
```

---

## Gestión de Fixtures

### Alcance de Fixtures (Scope) Mejores Prácticas

```python
# ✅ FUNCTION SCOPE - Instancia fresca por test
@pytest.fixture
def repo():  # ← Scope por defecto
    """Crear repositorio nuevo para cada test."""
    return SQLiteRepository(TransactionManager(":memory:"))

# ✅ MODULE SCOPE - Compartido entre tests del mismo archivo
@pytest.fixture(scope="module")
def static_data():
    """Cargar datos de referencia una vez por módulo."""
    return load_test_data()

# ❌ EVITAR SESSION SCOPE - Puede causar contaminación
@pytest.fixture(scope="session")
def db():  # ← No usar a no ser que sea necesario
    """BD compartida entre todos los tests."""
    pass
```

### Fixtures Parametrizados

```python
@pytest.mark.parametrize("input,expected", [
    ("valid-id", True),
    ("", False),
    ("..." * 100, False),
    ("\x00null", False),
])
def test_id_validation(input, expected):
    """Probar validación ID con múltiples inputs."""
    assert validate_id(input) == expected
```

### Composición de Fixtures

```python
@pytest.fixture
def temp_db(tmp_path):  # ← Componer fixtures
    """Crear BD SQLite temporal."""
    db_path = tmp_path / "test.db"
    return str(db_path)

@pytest.fixture
def repo(temp_db):  # ← Depende de temp_db
    """Repositorio usando BD temporal."""
    tx_manager = TransactionManager(temp_db)
    return SQLiteRepository(tx_manager)

@pytest.fixture
def populated_repo(repo):  # ← Depende de repo
    """Repositorio con datos de muestra."""
    repo.create_project(Project(id="1", name="Test"))
    return repo
```

---

## Integración CI/CD

### Pre-commit Hooks (Validación Local)

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Corriendo tests antes de commit..."

# 1. Unit tests
pytest tests/python/unit --cov=services --cov-fail-under=80 -q

# 2. Verificación tipos
pyright services/ core/

# 3. Verificación formato
black --check src/server/

# 4. Lint
ruff check src/server/

echo "✅ ¡Todos los checks pasaron!"
exit 0
```

### GitHub Actions Pipeline

```yaml
# .github/workflows/python-tests.yaml
name: Python Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: self-hosted

    steps:
      - name: Correr unit tests
        run: pytest tests/python/unit -v --cov=services --cov-fail-under=80

      - name: Correr integration tests
        run: pytest tests/python/integration -v

      - name: Subir coverage
        run: codecov --files coverage.xml
```

---

## Patrones Comunes

### Patrón 1: AAA (Arrange-Act-Assert)

```python
def test_create_project_success(self, repo):
    # ARRANGE - Setup
    project = Project(id="proj-001", name="Test", path="/tmp")

    # ACT - Ejecutar
    repo.create_project(project)

    # ASSERT - Verificar
    retrieved = repo.get_project("proj-001")
    assert retrieved.name == "Test"
```

### Patrón 2: Context Managers para Setup/Teardown

```python
def test_transaction_rollback_on_error(self, temp_db):
    # Setup con context manager
    with TransactionManager(temp_db) as tx_manager:
        # ACT
        with pytest.raises(ValidationError):
            tx_manager.execute_transaction([
                ("INSERT INTO ...", (bad_data,))
            ])

        # ASSERT - Verificar rollback
        remaining = tx_manager.execute_transaction([("SELECT COUNT(*) ...",)])
        assert remaining == 0
```

---

## Solución de Problemas

### Problema 1: "Fixture 'repo' not found"

**Causa:** Fixture definido en archivo diferente, no importado

**Solución:**
```python
# Opción 1: Mover fixture a conftest.py
# tests/conftest.py
@pytest.fixture
def repo(temp_db):
    return SQLiteRepository(TransactionManager(temp_db))

# Opción 2: Definir localmente en archivo test
@pytest.fixture
def repo(self, temp_db):
    return SQLiteRepository(TransactionManager(temp_db))
```

### Problema 2: "Test pasa localmente pero falla en CI"

**Causa:** Test depende del ambiente (tiempo, filesystem, SO)

**Solución:**
```python
# ✅ Usar fixtures para dependencias ambientales
def test_with_database(self, temp_db):  # ← BD temporal, no /var/lib/db
    """Test usa BD aislada."""
    pass

# ✅ Mock tiempo
@patch('time.time', return_value=1000.0)
def test_with_mocked_time(self, mock_time):
    """Test no depende de tiempo real."""
    pass
```

---

**Versión:** 1.0
**Estado:** ✅ COMPLETE
**Última Actualización:** 10/02/2025
