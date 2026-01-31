# 📋 Reglas y Estándares del Proyecto SoftArchitect AI

> **Versión:** 1.0
> **Última Actualización:** 30/01/2026
> **Aplicable a:** Todos los contribuidores

---

## 📚 Tabla de Contenidos

1. [Principios Fundamentales](#principios-fundamentales)
2. [Estándares de Código](#estándares-de-código)
3. [Documentación](#documentación)
4. [Git Workflow](#git-workflow)
5. [Testing y Calidad](#testing-y-calidad)
6. [Security](#security)

---

## Principios Fundamentales

### 1. **Local-First, Privacy-First**

```
Regla de Oro: Un byte de dato de usuario NUNCA sale del dispositivo del usuario
sin consentimiento explícito y encriptado.

Aplicación:
  ❌ Enviar queries a CloudFlare sin permiso
  ✅ Usar Ollama local, o Groq con consentimiento
  ✅ Encriptar todo en tránsito
```

### 2. **Pragmatismo sobre Purismo**

```
Si una herramienta hace el trabajo 10x mejor, la usamos.
Incluso si no es "la más elegante".

Ejemplo:
  Preferimos: "Django es feo pero rápido para CRUD" (pragmático)
  Sobre: "Vamos a escribir un ORM perfecto en 3 meses" (puro)
```

### 3. **Documentation as Code**

```
Todo debe estar documentado antes o después (preferiblemente antes).
La documentación es TAN importante como el código.

Estructura:
  ✅ Inline comments (EXPLICAR el "por qué", no el "qué")
  ✅ Docstrings en cada función/clase
  ✅ README per directory
  ✅ ADRs (Architecture Decision Records) para decisiones
```

### 4. **Clean Architecture**

```
Dependencias SIEMPRE apuntan hacia adentro:

  Presentation Layer
        ↓
  Domain Layer (Entities, Use Cases)
        ↓
  Data Layer (Repositories, DTOs)
        ↓
  Infrastructure Layer (DB, APIs, LLM)

Regla: Domain NUNCA conoce Presentation/Data/Infrastructure.
```

---

## Estándares de Código

### Dart (Flutter)

```yaml
Linter: flutter_lints (strict mode)

Naming:
  Classes: PascalCase
  Methods: camelCase
  Constants: lowerCamelCase (NO SCREAMING_SNAKE_CASE)

Example:
  class UserRepository extends Repository { }
  Future<User> getUser(String id) { }
  const defaultTimeout = Duration(seconds: 30);

Formatting:
  Line length: 80 chars
  Command: dart format .
```

### Python (FastAPI)

```yaml
Linter: flake8 + black + isort

Naming:
  Classes: PascalCase
  Functions/Methods: snake_case
  Constants: SCREAMING_SNAKE_CASE

Typing:
  ✅ OBLIGATORIO: Todos los functions deben tener type hints
  ❌ NO: def get_user(id):
  ✅ SÍ: def get_user(id: str) -> User:

Formatting:
  Line length: 100 chars
  Command: black . && isort .
```

### Commit Messages

```
Formato: <emoji> <type>(<scope>): <subject>

Ejemplos:
  🎨 feat(ui): agregar dark mode toggle
  🐛 fix(rag): corregir embeddings de ChromaDB
  📚 docs(readme): actualizar setup instructions
  ♻️ refactor(api): simplificar service layer
  ✅ test(backend): agregar tests para RAG service
  🚀 perf(frontend): optimizar renderizado de widgets

Emojis:
  🎨 feat       (feature nueva)
  🐛 fix        (bug fix)
  📚 docs       (documentación)
  ♻️ refactor   (refactoring sin cambios funcionales)
  ✅ test       (tests nuevos)
  🚀 perf       (performance improvements)
  🔒 security   (security fixes)
  ⬆️  deps      (actualizar dependencias)
  ⚙️ config     (cambios en configuración

Longitud:
  Subject: < 50 caracteres
  Body: < 72 caracteres por línea
```

---

## Documentación

### En Código (Docstrings)

```python
# ❌ INCORRECTO (no dice nada útil)
def get_embeddings(text):
    """Get embeddings."""
    return model.embed(text)

# ✅ CORRECTO (explica el "por qué")
def get_embeddings(text: str) -> np.ndarray:
    """
    Generate embeddings using the loaded model.

    Uses Ollama's mistral model for consistency across the RAG engine.
    Embeddings are cached in ChromaDB for performance.

    Args:
        text: Input text to embed (max 2048 tokens)

    Returns:
        1536-dimensional embedding vector

    Raises:
        ModelNotLoadedError: If model hasn't been initialized
        TextTooLongError: If text exceeds 2048 tokens

    Example:
        >>> embeddings = get_embeddings("What is FastAPI?")
        >>> embeddings.shape
        (1536,)
    """
    if not self.model:
        raise ModelNotLoadedError("Initialize model first with load_model()")

    if len(text.split()) > 2048:
        raise TextTooLongError(f"Text too long: {len(text.split())} tokens")

    # Use cached embeddings if available (10x faster)
    cache_key = hashlib.md5(text.encode()).hexdigest()
    if cache_key in self.embedding_cache:
        return self.embedding_cache[cache_key]

    embedding = self.model.embed(text)
    self.embedding_cache[cache_key] = embedding
    return embedding
```

### Markdown Documentation

```
Estructura OBLIGATORIA:

# 📖 Título Descriptivo

> **Estado:** ✅ Establecido
> **Última Actualización:** 30/01/2026

## Tabla de Contenidos

## Sección 1

## Sección 2

### Subsección 2.1

---

Notas:
- Usar emojis consistentemente (📖, 🚀, ⚠️, etc)
- Incluir ejemplos EJECUTABLES (copiar/pegar)
- Explicar trade-offs, no solo ventajas
- Incluir costos si aplica
```

---

## Git Workflow

### Ramas

```
main              (Producción - protected)
  ↑
develop           (Staging - base para desarrollo)
  ↑
feature/*         (Nuevas features)
bugfix/*          (Bug fixes)
docs/*            (Documentación)
chore/*           (Mantenimiento)

Ejemplo:
  git checkout -b feature/rag-optimization
  git checkout -b bugfix/chromadb-connection
  git checkout -b docs/setup-guide
```

### Pull Request Process

```
1. Create Feature Branch
   git checkout -b feature/new-feature

2. Commit Regularly (con mensajes claros)
   git commit -m "🎨 feat(rag): agregar soporte para GPT-4 embeddings"

3. Push
   git push origin feature/new-feature

4. Open PR
   - Title: Corto y descriptivo
   - Description: Link a issues, explica cambios
   - Include: Screenshots si es UI
   - Include: Benchmark results si es performance

5. Code Review
   - Mínimo 1 approval
   - Todos los tests deben pasar

6. Merge (Squash commits si son muchos)
   - Delete branch después

7. Deploy
   - Merging a develop = auto-deploy a staging
   - Merging a main = auto-deploy a producción
```

---

## Testing y Calidad

### Coverage Requerido

```
Lógica de negocio (Domain layer):     > 90% coverage
API endpoints (Presentation layer):   > 80% coverage
Utilidades (Infrastructure):          > 70% coverage
```

### Tipos de Tests

```
1. Unit Tests (Pytest, Flutter test)
   - Mock todas las dependencias
   - Rápidos (ms)
   - Corren en cada commit

2. Integration Tests
   - Bases de datos reales (o mock containers)
   - APIs reales (o stubs)
   - Lentos (segundos)
   - Corren en CI/CD

3. E2E Tests
   - Usuario interactúa con toda la app
   - Solo happy paths críticos
   - Muy lentos (minutos)
   - Corren antes de merge a main
```

### Commands

```bash
# Python (FastAPI)
pytest                           # Correr todos
pytest --cov=.                   # Con coverage
pytest -k "test_rag"             # Solo tests específicos
pytest -v                        # Verbose

# Dart (Flutter)
flutter test                     # Correr todos
flutter test --coverage          # Con coverage
flutter test -k "user_test"      # Solo tests específicos
```

---

## Security

### 1. Secrets Management

```
❌ NUNCA:
  - Commitear .env files
  - Hardcodear API keys
  - Guardar passwords en plaintext

✅ SIEMPRE:
  - Usar .env.example (sin valores)
  - Inyectar en runtime desde env vars
  - Usar Azure Key Vault / AWS Secrets Manager
  - Rotar secrets cada 90 días
```

### 2. Dependency Auditing

```bash
# Python
pip-audit                        # Buscar vulnerabilidades
pip-audit --fix                  # Arreglar automático

# Dart
pub outdated                     # Ver dependencias viejas
pub upgrade                      # Actualizar
```

### 3. Code Analysis

```bash
# Python
bandit -r src/                   # Security linting

# Dart
flutter analyze                  # Dart analyzer
```

### 4. Data Privacy

```
Si tu feature toca datos de usuario:
  1. Audit con OWASP Top 10 checklist
  2. Encriptar en tránsito (HTTPS)
  3. Encriptar en reposo (si sensible)
  4. Anonymize en logs
  5. Retention policy (<30 días si posible)
  6. Documentar en SECURITY_PRIVACY_POLICY.md
```

---

## Checklist de PR

Antes de hacer merge, verifica:

```
✅ Código
  [ ] Sigue estándares de código (linter clean)
  [ ] Incluye docstrings/comments
  [ ] No tiene console.log/print debug
  [ ] Type hints/types completos

✅ Tests
  [ ] Tests nuevos para nuevas features
  [ ] Todos los tests pasan localmente
  [ ] Coverage >= requerida
  [ ] Incluye tests para edge cases

✅ Documentación
  [ ] README actualizado (si aplica)
  [ ] Docstrings actualizado (si aplica)
  [ ] Ejemplos de código actualizados (si aplica)
  [ ] ADR creado (si es decisión mayor)

✅ Git
  [ ] Commits tienen mensajes claros
  [ ] Branch está actualizado con develop
  [ ] No hay conflictos
  [ ] No hay unfinished work (WIP)

✅ Performance
  [ ] Sin nuevos N+1 queries
  [ ] Sin memory leaks detectados
  [ ] API latency no degradó
```

---

**Resumen**: Somos pragmáticos pero estrictos. La calidad ahora = menos deuda técnica después. 🎯
