# 📏 Tech Governance Rules: {{TECH_NAME}}

> **Versión:** 1.0
> **Fecha:** {{CREATION_DATE}}
> **Mantenedor:** {{MAINTAINER}}
> **Estado:** ✅ Activo

---

## 📖 Tabla de Contenidos

- [Introducción](#introducción)
- [Convenciones de Naming](#convenciones-de-naming)
- [Principios Arquitectónicos](#principios-arquitectónicos)
- [Patrones de Seguridad](#patrones-de-seguridad)
- [Testing & Quality](#testing--quality)
- [Performance Rules](#performance-rules)
- [Linting & Formatting](#linting--formatting)
- [Enforcement](#enforcement)

---

## 📝 Introducción

Estas son las reglas estáticas de calidad y estilo para **{{TECH_NAME}}**.

### Propósito

Garantizar que:
- ✅ Todo código sea consistente y legible
- ✅ Seguridad desde diseño (Security by Design)
- ✅ Performance optimizado
- ✅ Mantenibilidad a largo plazo

### Scope

Aplicable a:
- {{SCOPE_1}} (Ej: Código de producción)
- {{SCOPE_2}} (Ej: Tests)
- {{SCOPE_3}} (Ej: Documentación)

---

## 1. Convenciones de Naming (Nomenclatura)

### Archivos y Directorios

| Elemento | Convención | Ejemplo | Justificación |
|----------|-----------|---------|---------------|
| **Archivos Código** | {{NAMING_FILE_PATTERN}} | `{{EXAMPLE_FILE}}` | {{NAMING_FILE_REASON}} |
| **Directorios** | {{NAMING_DIR_PATTERN}} | `{{EXAMPLE_DIR}}` | {{NAMING_DIR_REASON}} |
| **Test Files** | {{NAMING_TEST_PATTERN}} | `{{EXAMPLE_TEST_FILE}}` | {{NAMING_TEST_REASON}} |
| **Config Files** | {{NAMING_CONFIG_PATTERN}} | `{{EXAMPLE_CONFIG}}` | {{NAMING_CONFIG_REASON}} |

### Elementos de Código

| Elemento | Convención | Ejemplo | Regla Adicional |
|----------|-----------|---------|-----------------|
| **Clases** | {{NAMING_CLASS}} | `{{EXAMPLE_CLASS}}` | {{CLASS_RULE}} |
| **Funciones/Métodos** | {{NAMING_FUNC}} | `{{EXAMPLE_FUNC}}` | {{FUNC_RULE}} |
| **Variables** | {{NAMING_VAR}} | `{{EXAMPLE_VAR}}` | {{VAR_RULE}} |
| **Constantes** | {{NAMING_CONST}} | `{{EXAMPLE_CONST}}` | {{CONST_RULE}} |
| **Interfaces/Traits** | {{NAMING_INTERFACE}} | `{{EXAMPLE_INTERFACE}}` | {{INTERFACE_RULE}} |
| **Enums** | {{NAMING_ENUM}} | `{{EXAMPLE_ENUM}}` | {{ENUM_RULE}} |

### Reglas de Naming Globales

1. **Lenguaje:** {{NAMING_LANG}} (Ej: Inglés solamente)
2. **Longitud máxima:** {{NAMING_MAX_LENGTH}} caracteres
3. **Caracteres especiales:** {{NAMING_SPECIAL_CHARS}} permitidos
4. **Abreviaturas:** {{NAMING_ABBREVIATIONS}} (Ej: No usar excepto en constantes estándar)

---

## 2. Principios Arquitectónicos

### 2.1 Estructura de Proyecto

**Obligación:** Seguir estrictamente `PROJECT_STRUCTURE_MAP.md`

```
{{ARCH_STRUCTURE_EXAMPLE}}
```

**Reglas:**
- {{STRUCT_RULE_1}}
- {{STRUCT_RULE_2}}
- {{STRUCT_RULE_3}}

### 2.2 Acoplamiento y Cohesión

| Regla | Descripción | Anti-Patrón |
|-------|-------------|-------------|
| **DI** | {{DI_RULE}} | {{DI_ANTI}} |
| **SOLID - Single Responsibility** | {{SOLID_S_RULE}} | {{SOLID_S_ANTI}} |
| **SOLID - Open/Closed** | {{SOLID_OC_RULE}} | {{SOLID_OC_ANTI}} |
| **SOLID - Liskov** | {{SOLID_L_RULE}} | {{SOLID_L_ANTI}} |
| **SOLID - Interface Segregation** | {{SOLID_I_RULE}} | {{SOLID_I_ANTI}} |
| **SOLID - Dependency Inversion** | {{SOLID_D_RULE}} | {{SOLID_D_ANTI}} |

### 2.3 Gestión de Estado

**Estado Mutable:**
- {{STATE_MUTABLE_RULE}} (Ej: Mantener local al máximo)

**Estado Compartido:**
- {{STATE_SHARED_RULE}} (Ej: Usar patterns como Redux/MobX)

**Async/Concurrency:**
- {{STATE_ASYNC_RULE}} (Ej: Usar Streams/Observables)

---

## 3. Patrones de Seguridad (Hardening)

### 3.1 Input Validation

**Regla:** Validar SIEMPRE en los límites (boundaries).

```{{TECH_CODE_LANG}}
// ✅ GOOD: Validación en el boundary
{{CODE_VALIDATION_GOOD}}

// ❌ BAD: Sin validación
{{CODE_VALIDATION_BAD}}
```

**Herramientas recomendadas:**
- {{VALIDATION_TOOL_1}}
- {{VALIDATION_TOOL_2}}

### 3.2 Secrets Management

**Regla:** {{SECRETS_RULE}} (Ej: Nunca en código fuente, siempre desde env vars)

```{{TECH_CODE_LANG}}
// ✅ GOOD
{{CODE_SECRETS_GOOD}}

// ❌ BAD
{{CODE_SECRETS_BAD}}
```

**Herramientas:**
- {{SECRETS_TOOL_1}}
- {{SECRETS_TOOL_2}}

### 3.3 Autenticación y Autorización

**Patrón:** {{AUTH_PATTERN}} (Ej: JWT + Roles)

**Implementación:** {{AUTH_IMPLEMENTATION}}

### 3.4 SQL Injection / NoSQL Injection

**Regla:** Siempre usar {{INJECTION_PREVENTION}} (Ej: Prepared Statements / Parameterized Queries)

```{{TECH_CODE_LANG}}
// ✅ GOOD: Parameterized
{{CODE_INJECTION_GOOD}}

// ❌ BAD: String concatenation
{{CODE_INJECTION_BAD}}
```

### 3.5 CORS / CSRF Protection

**CORS:** {{CORS_RULE}}

**CSRF:** {{CSRF_RULE}}

---

## 4. Testing & Quality

### 4.1 Cobertura de Tests

**Objetivo:** {{TEST_COVERAGE_TARGET}}% (Ej: 80% mínimo)

**Pirámide de Tests:**

```
        /\
       /  \  E2E Tests (~10%)
      /____\
     /      \
    /  I&T   \  Integration Tests (~20%)
   /________  \
  /          \ \
 /   Unit     \ \  Unit Tests (~70%)
/______________\
```

### 4.2 Estructura de Tests

**Naming:** {{TEST_NAMING}} (Ej: `test_{{function_name}}_{{scenario}}_{{expected}}`)

**Estructura AAA:**

```{{TECH_CODE_LANG}}
// Arrange: Setup
{{CODE_TEST_ARRANGE}}

// Act: Ejecutar
{{CODE_TEST_ACT}}

// Assert: Verificar
{{CODE_TEST_ASSERT}}
```

### 4.3 Mocking & Stubbing

**Librería:** {{MOCK_LIBRARY}}

**Regla:** {{MOCK_RULE}}

---

## 5. Performance Rules

### 5.1 Optimización de Recursos

| Recurso | Límite | Acción |
|---------|--------|--------|
| **Memoria** | {{MEM_LIMIT}} | {{MEM_ACTION}} |
| **CPU** | {{CPU_LIMIT}} | {{CPU_ACTION}} |
| **Latencia** | {{LATENCY_LIMIT}} | {{LATENCY_ACTION}} |

### 5.2 Logging

**Nivel recomendado:** {{LOG_LEVEL}} (Producción)

```{{TECH_CODE_LANG}}
// ✅ GOOD: Structured logging
{{CODE_LOG_GOOD}}

// ❌ BAD: String concatenation
{{CODE_LOG_BAD}}
```

### 5.3 Caching

**Estrategia:** {{CACHING_STRATEGY}} (Ej: Cache-Aside)

**TTL:** {{CACHING_TTL}} (Ej: 1 hora para datos públicos)

---

## 6. Linting & Formatting

### 6.1 Herramientas Obligatorias

| Herramienta | Versión | Propósito |
|-----------|---------|----------|
| {{LINTER_NAME}} | {{LINTER_VERSION}} | {{LINTER_PURPOSE}} |
| {{FORMATTER_NAME}} | {{FORMATTER_VERSION}} | {{FORMATTER_PURPOSE}} |
| {{TYPE_CHECKER}} | {{TYPE_VERSION}} | {{TYPE_PURPOSE}} |

### 6.2 Configuración Base

**Archivo:** `{{CONFIG_FILE}}` (Ej: `.eslintrc.json`, `pyproject.toml`)

```{{CONFIG_LANG}}
{{CONFIG_TEMPLATE}}
```

### 6.3 Pre-commit Hooks

**Herramienta:** {{PRECOMMIT_TOOL}} (Ej: husky, pre-commit)

**Hooks obligatorios:**
1. Linting check
2. Formatting check
3. Type checking (si aplica)
4. Tests (mínimo unit tests)

---

## 7. Enforcement

### Responsabilidades

| Rol | Responsabilidad |
|-----|-----------------|
| **Developer** | Seguir reglas en desarrollo local |
| **CI/CD** | Validar reglas en cada PR |
| **Code Reviewer** | Verificar cumplimiento en review |
| **Tech Lead** | Actualizar reglas cuando sea necesario |

### CI/CD Validation

```yaml
# .github/workflows/lint.yml example
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run linter
        run: {{LINTER_COMMAND}}
      - name: Run formatter check
        run: {{FORMATTER_COMMAND}}
      - name: Type check
        run: {{TYPE_COMMAND}}
```

### Violaciones y Sanciones

| Violación | Acción |
|-----------|--------|
| **Linting failed** | PR bloqueado |
| **Cobertura < {{TEST_COVERAGE_TARGET}}%** | PR bloqueado |
| **Tests fallados** | PR bloqueado |
| **Security issues** | Requerida remediación |

---

## 📋 Checklist para Desarrolladores

Antes de commitear:

- [ ] Código sigue convenciones de naming
- [ ] Linter pasa sin warnings
- [ ] Formatter aplicado
- [ ] Tests pasan (>{{TEST_COVERAGE_TARGET}}% coverage)
- [ ] Type checking pasa (si aplica)
- [ ] No hardcoded secrets
- [ ] No archivos temporales commiteados
- [ ] Commit message sigue Conventional Commits

---

**Última Actualización:** {{UPDATE_DATE}}
**Status:** ✅ Activo y Reforzado
