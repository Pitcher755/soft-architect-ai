# 📋 Code Standards & English Compliance

> **Referencia:** AGENTS.md §6 - Regla de Integridad
> **Última Actualización:** 29/01/2026
> **Estado:** ✅ Activo

---

## 📖 Tabla de Contenidos

1. [Regla: Todo en Inglés](#regla-todo-en-inglés)
2. [Ejemplos Válidos vs Inválidos](#ejemplos-válidos-vs-inválidos)
3. [Herramientas de Validación](#herramientas-de-validación)
4. [Checklist Antes de Commit](#checklist-antes-de-commit)
5. [GitHub Actions Integración](#github-actions-integration)
6. [Resolución de Problemas](#resolución-de-problemas)

---

## 🎯 Regla: Todo en Inglés

Según **AGENTS.md §6**, todo lo escrito en el código debe estar en **INGLÉS**:

- ✅ **Nombres de variables, funciones, clases**
- ✅ **Comentarios inline y docstrings**
- ✅ **Documentoación (DartDoc, PyDoc)**
- ✅ **TODO, FIXME, NOTE comments**
- ✅ **Strings de usuario (mensajes, etiquetas)**

---

## 📝 Ejemplos Válidos vs Inválidos

### Dart (Flutter)

#### ❌ INVÁLIDO

```dart
// Obtener usuario por ID
Future<Usuario> obtenerUsuario(String id) async {
  // TODO: Añadir validación
  final resp = await api.fetch(id);
  return Usuario.fromJson(resp);
}

/// Obtiene datos del usuario desde la API
class UsuarioService { ... }
```

#### ✅ VÁLIDO

```dart
/// Fetches a user by ID from the API.
///
/// [userId] The unique identifier for the user.
///
/// Returns a [Future] that resolves to a [User] object.
/// Throws [UserNotFoundException] if the user doesn't exist.
Future<User> getUser(String userId) async {
  // TODO: Add input validation
  final response = await api.fetch(userId);
  return User.fromJson(response);
}

/// Service for managing user operations.
class UserService {
  /// Retrieves user data by ID.
  Future<User> getUserById(String userId) => ...;
}
```

---

### Python

#### ❌ INVÁLIDO

```python
def obtener_usuario(usuario_id: str) -> Usuario:
    # Obtener usuario desde la base de datos
    # TODO: Implementar caché
    usuario = db.query(Usuario).filter_by(id=usuario_id).first()
    return usuario

class ServicioUsuario:
    """Servicio para gestionar usuarios."""
    pass
```

#### ✅ VÁLIDO

```python
def get_user(user_id: str) -> User:
    """
    Fetch user data from the database.

    Args:
        user_id: The unique identifier for the user.

    Returns:
        User: User object with complete data.

    Raises:
        UserNotFoundError: If user does not exist.

    Note:
        TODO: Implement caching for performance improvement
    """
    # Fetch from database with error handling
    user = db.query(User).filter_by(id=user_id).first()
    return user

class UserService:
    """Service for managing user operations."""

    def __init__(self):
        """Initialize the UserService."""
        self.db = get_db_session()

    def get_user_by_id(self, user_id: str) -> User:
        """Retrieve a user by ID."""
        return get_user(user_id)
```

---

## 🛠️ Herramientas de Validación

### Flutter/Dart

#### 1. Flutter Analyzer (Automático)

```bash
cd src/client
flutter analyze
```

Detecta:
- ❌ Variables/funciones mal nombradas
- ❌ Comentarios sin formato
- ❌ Imports desordenados
- ❌ Tipos no especificados

#### 2. Dart Format

```bash
cd src/client
dart format --set-exit-if-changed lib/
```

Asegura:
- ✅ Indentación consistente
- ✅ Espacios alrededor de operadores
- ✅ Saltos de línea apropiados

#### 3. Custom Lints (análisis_options.yaml)

```bash
cd src/client
flutter pub get
flutter analyze
```

**Reglas configuradas:**
- `slash_for_doc_comments` - Usar `///` para documentoación
- `camel_case_types` - Nombres de clases en PascalCase
- `library_names` - Nombres de librerías en snake_case
- `package_api_docs` - Requiere documentoación en APIs públicas
- `public_member_api_docs` - Requiere docs en miembros públicos

---

### Python

#### 1. PyLint (Linting)

```bash
cd src/server
pylint app/ --max-line-length=120
```

Detecta:
- ❌ Variables mal nombradas (español, números)
- ❌ Funciones sin docstring
- ❌ Código duplicado
- ❌ Imports no usados

**Configuración:** `.pylintrc`

#### 2. MyPy (Type Checking)

```bash
cd src/server
mypy app/ --ignore-missing-imports
```

Detecta:
- ❌ Tipos faltantes en funciones
- ❌ Retornos inconsistentes
- ❌ Acceso a atributos inexistentes

**Configuración:** `pyproyecto.toml [tool.mypy]`

#### 3. Black (Format)

```bash
cd src/server
black app/ --check
```

Asegura:
- ✅ Líneas máximo 120 caracteres
- ✅ Comillas dobles en strings
- ✅ Espacios alrededor de operadores

**Configuración:** `pyproyecto.toml [tool.black]`

#### 4. isort (Import Sorting)

```bash
cd src/server
isort app/ --check-only
```

Organiza imports en:
1. Librerías estándar
2. Dependencias externas
3. Módulos locales

**Configuración:** `pyproyecto.toml [tool.isort]`

---

## 🚀 Checklist Antes de Commit

Antes de hacer `git commit`, ejecuta:

```bash
# 1. Flutter
cd src/client
flutter analyze
dart format lib/ --set-exit-if-changed

# 2. Python
cd ../server
pylint app/ --max-line-length=120 --exit-zero
mypy app/ --ignore-missing-imports
black app/ --check
isort app/ --check-only

# 3. Auditoría de inglés
cd ../..
./scripts/audit-english-compliance.sh
```

### Checklist Manual

- [ ] ✅ Código escrito en inglés
- [ ] ✅ Variables en `camelCase` (Dart) / `snake_case` (Python)
- [ ] ✅ Clases en `PascalCase`
- [ ] ✅ Constantes en `UPPER_CASE`
- [ ] ✅ Comentarios en inglés (sin acentos español)
- [ ] ✅ DocStrings presentes y en inglés
- [ ] ✅ `flutter analyze` pasa sin errores
- [ ] ✅ `pylint` score > 8.5 (Python)
- [ ] ✅ `mypy` sin errores críticos
- [ ] ✅ `black` format OK
- [ ] ✅ Pruebas pasan: `flutter prueba` / `pyprueba`
- [ ] ✅ No hay archivos `*.pyc`, `.DS_Store`, etc.

---

## 🔄 GitHub Actions Integración

El proyecto ejecuta validaciones automáticas en cada **push** y **pull request**.

### Workflow: `.github/workflows/lint.yml`

**Jobs:**

1. **dart-lint**
   - Corre `flutter analyze`
   - Verifica formato con `dart format`
   - Ejecuta pruebas unitarias

2. **python-lint**
   - Corre `pylint`
   - Type checking con `mypy`
   - Format check con `black`
   - Import sorting con `isort`

3. **english-compliance**
   - Busca caracteres españoles en comentarios
   - Ejecuta auditoría completa

**Resultadoado:**
- ❌ Si algo falla → PR no se puede mergear
- ⚠️ Si hay warnings → Se muestra en el PR
- ✅ Si todo pasa → PR listo para revisar

---

## 🐛 Resolución de Problemas

### Problema: `flutter analyze` falla

```
ℹ️  line 45: pubspec.yaml:12:0
 - The library `package:path/path.dart` is imported but not used in the file.
```

**Solución:**
```bash
# Elimina imports no usados
dart fix --apply
flutter analyze
```

---

### Problema: `pylint` da score bajo

```
Your code has been rated at 6.5/10
```

**Solución:**
```bash
# Ver errores específicos
pylint app/ --max-line-length=120 | grep -E "^[A-Z][0-9]+"

# Auto-arreglar algunos
black app/
```

---

### Problema: `mypy` reporta errores de tipo

```
error: Argument 1 to "fetch_user" has incompatible type "int"; expected "str"
```

**Solución:**
```python
# ❌ Antes
user = fetch_user(123)

# ✅ Después
user = fetch_user("123")
```

---

### Problema: Nombres en español aparecen

```bash
find src/server/app -name "*.py" | xargs grep "def obtener"
```

**Solución:**
```bash
# Buscar y reemplazar
find src/server/app -name "*.py" -exec sed -i 's/obtener_/get_/g' {} \;
find src/server/app -name "*.py" -exec sed -i 's/usuario/user/g' {} \;

# Verificar cambios
git diff src/server/app/
```

---

## 📊 Métricas Objetivo

| Métrica | Target | Herramienta |
|---------|--------|-------------|
| **Code Coverage** | > 80% | `pyprueba --cov` |
| **Linting Pass** | 100% | `flutter analyze`, `pylint` |
| **English Compliance** | 100% | `audit-english-compliance.sh` |
| **DocStrings** | > 95% | Manual review |
| **Type Safety** | Strict | `mypy --strict` |
| **Format** | 100% | `black`, `dart format` |

---

## 🔗 Referencias

- [AGENTS.md §6 - Code Language Standards](../../AGENTS.md#-6-restricciones-lo-que-está-prohibido)
- [Dart Estilo Guide](https://dart.dev/guides/language/effective-dart/estilo)
- [PEP 257 - Docstring Conventions](https://www.python.org/dev/peps/pep-0257/)
- [Black Code Estilo](https://black.readthedocs.io/)
- [Flutter Lints](https://pub.dev/packages/flutter_lints)

---

**Última revisión:** 29/01/2026 | **Versión:** 1.0 | **Estado:** ✅ Activo
