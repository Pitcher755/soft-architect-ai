# 📏 Tech Governance Rules: {{TECH_NAME}}

> **Version:** 1.0
> **Date:** {{CREATION_DATE}}
> **Maintainer:** {{MAINTAINER}}
> **Status:** ✅ Active

---

## 📖 Table of Contents

- [Introduction](#introduction)
- [Naming Conventions](#naming-conventions)
- [Architectural Principles](#architectural-principles)
- [Security Patterns](#security-patterns)
- [Testing & Quality](#testing--quality)
- [Performance Rules](#performance-rules)
- [Linting & Formatting](#linting--formatting)
- [Enforcement](#enforcement)

---

## 📝 Introduction

These are the static quality and style rules for **{{TECH_NAME}}**.

### Purpose

To ensure that:
- ✅ All code is consistent and readable
- ✅ Security by Design
- ✅ Optimized performance
- ✅ Long-term maintainability

### Scope

Applicable to:
- {{SCOPE_1}} (e.g., Production code)
- {{SCOPE_2}} (e.g., Tests)
- {{SCOPE_3}} (e.g., Documentation)

---

## 1. Naming Conventions (Nomenclature)

### Files and Directories

| Element | Convention | Example | Justification |
|---------|-----------|---------|---------------|
| **Code Files** | {{NAMING_FILE_PATTERN}} | `{{EXAMPLE_FILE}}` | {{NAMING_FILE_REASON}} |
| **Directories** | {{NAMING_DIR_PATTERN}} | `{{EXAMPLE_DIR}}` | {{NAMING_DIR_REASON}} |
| **Test Files** | {{NAMING_TEST_PATTERN}} | `{{EXAMPLE_TEST_FILE}}` | {{NAMING_TEST_REASON}} |
| **Config Files** | {{NAMING_CONFIG_PATTERN}} | `{{EXAMPLE_CONFIG}}` | {{NAMING_CONFIG_REASON}} |

### Code Elements

| Element | Convention | Example | Additional Rule |
|---------|-----------|---------|-----------------|
| **Classes** | {{NAMING_CLASS}} | `{{EXAMPLE_CLASS}}` | {{CLASS_RULE}} |
| **Functions/Methods** | {{NAMING_FUNC}} | `{{EXAMPLE_FUNC}}` | {{FUNC_RULE}} |
| **Variables** | {{NAMING_VAR}} | `{{EXAMPLE_VAR}}` | {{VAR_RULE}} |
| **Constants** | {{NAMING_CONST}} | `{{EXAMPLE_CONST}}` | {{CONST_RULE}} |
| **Interfaces/Traits** | {{NAMING_INTERFACE}} | `{{EXAMPLE_INTERFACE}}` | {{INTERFACE_RULE}} |
| **Enums** | {{NAMING_ENUM}} | `{{EXAMPLE_ENUM}}` | {{ENUM_RULE}} |

### Global Naming Rules

1. **Language:** {{NAMING_LANG}} (e.g., English only)
2. **Maximum length:** {{NAMING_MAX_LENGTH}} characters
3. **Special characters:** {{NAMING_SPECIAL_CHARS}} allowed
4. **Abbreviations:** {{NAMING_ABBREVIATIONS}} (e.g., Don't use except for standard constants)

---

## 2. Architectural Principles

### 2.1 Project Structure

**Requirement:** Strictly follow `PROJECT_STRUCTURE_MAP.md`

```
{{ARCH_STRUCTURE_EXAMPLE}}
```

**Rules:**
- {{STRUCT_RULE_1}}
- {{STRUCT_RULE_2}}
- {{STRUCT_RULE_3}}

### 2.2 Coupling and Cohesion

| Rule | Description | Anti-Pattern |
|------|-------------|--------------|
| **DI** | {{DI_RULE}} | {{DI_ANTI}} |
| **SOLID - Single Responsibility** | {{SOLID_S_RULE}} | {{SOLID_S_ANTI}} |
| **SOLID - Open/Closed** | {{SOLID_OC_RULE}} | {{SOLID_OC_ANTI}} |
| **SOLID - Liskov** | {{SOLID_L_RULE}} | {{SOLID_L_ANTI}} |
| **SOLID - Interface Segregation** | {{SOLID_I_RULE}} | {{SOLID_I_ANTI}} |
| **SOLID - Dependency Inversion** | {{SOLID_D_RULE}} | {{SOLID_D_ANTI}} |

### 2.3 State Management

**Mutable State:**
- {{STATE_MUTABLE_RULE}} (e.g., Keep local to the maximum extent)

**Shared State:**
- {{STATE_SHARED_RULE}} (e.g., Use patterns like Redux/MobX)

**Async/Concurrency:**
- {{STATE_ASYNC_RULE}} (e.g., Use Streams/Observables)

---

## 3. Security Patterns (Hardening)

### 3.1 Input Validation

**Rule:** ALWAYS validate at boundaries.

```{{TECH_CODE_LANG}}
// ✅ GOOD: Validation at boundary
{{CODE_VALIDATION_GOOD}}

// ❌ BAD: Without validation
{{CODE_VALIDATION_BAD}}
```

**Recommended tools:**
- {{VALIDATION_TOOL_1}}
- {{VALIDATION_TOOL_2}}

### 3.2 Secrets Management

**Rule:** {{SECRETS_RULE}} (e.g., Never in source code, always from env vars)

```{{TECH_CODE_LANG}}
// ✅ GOOD
{{CODE_SECRETS_GOOD}}

// ❌ BAD
{{CODE_SECRETS_BAD}}
```

**Tools:**
- {{SECRETS_TOOL_1}}
- {{SECRETS_TOOL_2}}

### 3.3 Authentication and Authorization

**Pattern:** {{AUTH_PATTERN}} (e.g., JWT + Roles)

**Implementation:** {{AUTH_IMPLEMENTATION}}

### 3.4 SQL Injection / NoSQL Injection

**Rule:** Always use {{INJECTION_PREVENTION}} (e.g., Prepared Statements / Parameterized Queries)

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

### 4.1 Test Coverage

**Target:** {{TEST_COVERAGE_TARGET}}% (e.g., 80% minimum)

**Test Pyramid:**

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

### 4.2 Test Structure

**Naming:** {{TEST_NAMING}} (e.g., `test_{{function_name}}_{{scenario}}_{{expected}}`)

**AAA Structure:**

```{{TECH_CODE_LANG}}
// Arrange: Setup
{{CODE_TEST_ARRANGE}}

// Act: Execute
{{CODE_TEST_ACT}}

// Assert: Verify
{{CODE_TEST_ASSERT}}
```

### 4.3 Mocking & Stubbing

**Library:** {{MOCK_LIBRARY}}

**Rule:** {{MOCK_RULE}}

---

## 5. Performance Rules

### 5.1 Resource Optimization

| Resource | Limit | Action |
|----------|-------|--------|
| **Memory** | {{MEM_LIMIT}} | {{MEM_ACTION}} |
| **CPU** | {{CPU_LIMIT}} | {{CPU_ACTION}} |
| **Latency** | {{LATENCY_LIMIT}} | {{LATENCY_ACTION}} |

### 5.2 Logging

**Recommended level:** {{LOG_LEVEL}} (Production)

```{{TECH_CODE_LANG}}
// ✅ GOOD: Structured logging
{{CODE_LOG_GOOD}}

// ❌ BAD: String concatenation
{{CODE_LOG_BAD}}
```

### 5.3 Caching

**Strategy:** {{CACHING_STRATEGY}} (e.g., Cache-Aside)

**TTL:** {{CACHING_TTL}} (e.g., 1 hour for public data)

---

## 6. Linting & Formatting

### 6.1 Mandatory Tools

| Tool | Version | Purpose |
|------|---------|---------|
| {{LINTER_NAME}} | {{LINTER_VERSION}} | {{LINTER_PURPOSE}} |
| {{FORMATTER_NAME}} | {{FORMATTER_VERSION}} | {{FORMATTER_PURPOSE}} |
| {{TYPE_CHECKER}} | {{TYPE_VERSION}} | {{TYPE_PURPOSE}} |

### 6.2 Base Configuration

**File:** `{{CONFIG_FILE}}` (e.g., `.eslintrc.json`, `pyproject.toml`)

```{{CONFIG_LANG}}
{{CONFIG_TEMPLATE}}
```

### 6.3 Pre-commit Hooks

**Tool:** {{PRECOMMIT_TOOL}} (e.g., husky, pre-commit)

**Mandatory hooks:**
1. Linting check
2. Formatting check
3. Type checking (if applicable)
4. Tests (minimum unit tests)

---

## 7. Enforcement

### Responsibilities

| Role | Responsibility |
|------|----------------|
| **Developer** | Follow rules in local development |
| **CI/CD** | Validate rules on every PR |
| **Code Reviewer** | Verify compliance in review |
| **Tech Lead** | Update rules when necessary |

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

### Violations and Sanctions

| Violation | Action |
|-----------|--------|
| **Linting failed** | PR blocked |
| **Coverage < {{TEST_COVERAGE_TARGET}}%** | PR blocked |
| **Failed tests** | PR blocked |
| **Security issues** | Remediation required |

---

## 📋 Developer Checklist

Before committing:

- [ ] Code follows naming conventions
- [ ] Linter passes without warnings
- [ ] Formatter applied
- [ ] Tests pass (>{{TEST_COVERAGE_TARGET}}% coverage)
- [ ] Type checking passes (if applicable)
- [ ] No hardcoded secrets
- [ ] No temporary files committed
- [ ] Commit message follows Conventional Commits

---

**Last Updated:** {{UPDATE_DATE}}
**Status:** ✅ Active and Enforced
