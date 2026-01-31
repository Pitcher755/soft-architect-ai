# 🤝 Contributing Guide: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Definido

---

## 📖 Tabla de Contenidos

1. [Cómo Contribuir](#cómo-contribuir)
2. [Flujo de Trabajo](#flujo-de-trabajo)
3. [Standards de Código](#standards-de-código)
4. [Proceso de Review](#proceso-de-review)
5. [Reporting Issues](#reporting-issues)

---

## Cómo Contribuir

### Tipos de Contribuciones

```
✅ Aceptamos:
  └─ Bug fixes (con test)
  └─ Feature implementations (con documentación)
  └─ Documentation improvements
  └─ Test coverage increases
  └─ Performance optimizations
  └─ Translations (bilingual support)

❌ NO aceptamos:
  └─ Breaking changes sin ADR
  └─ Código sin tests
  └─ Documentación desactualizada
  └─ Vendetta personal o spam
```

### Flujo General

```
1. Fork el repositorio
   └─ git clone https://github.com/YOU/soft-architect-ai.git

2. Crea rama de feature
   └─ git checkout -b feature/tu-feature-name

3. Implement + tests + docs
   └─ Código + Tests + Documentation

4. Commit con mensaje descriptivo
   └─ git commit -m "📝 descripción clara"

5. Push a tu fork
   └─ git push origin feature/tu-feature-name

6. Abre Pull Request
   └─ Contra develop (nunca main)
   └─ Rellena PR template

7. Address review comments
   └─ Itera hasta ✅ aprobado

8. Merge automático
   └─ Code owners aprueban → auto-merge
```

---

## Flujo de Trabajo

### Branch Naming

```
feature/descripcion-clara          # Nuevas features
bugfix/problema-resuelto           # Bug fixes
docs/seccion-mejorada              # Documentación
chore/mantenimiento                # Refactoring, deps
```

### Commit Messages

```
Format:
  [TYPE] descripción clara (imperativo)

  Cuerpo detallado si es necesario

  Fixes: #123

Tipos:
  📝 docs:    Documentación
  🎨 style:   Formatting, linting
  ✨ feat:    Nueva feature
  🐛 fix:     Bug fix
  🧪 test:    Tests
  ♻️  refactor: Código limpieza
  ⚡ perf:    Performance
  🔒 security: Security fix
  🚀 deploy:  Deployment config

Ejemplos:
  ✨ feat: add RAG pipeline orchestration
  🐛 fix: handle null embeddings in ChromaDB
  📝 docs: add Flask to backend alternatives
  🧪 test: increase coverage to 85%
```

### Pull Request Template

```markdown
## Descripción
Qué cambias y por qué

## Tipo de cambio
- [ ] Bug fix
- [ ] Feature
- [ ] Breaking change
- [ ] Documentation

## Checklist
- [ ] Tests escritos y pasando
- [ ] Coverage ≥80%
- [ ] Documentación actualizada
- [ ] No hay linting errors
- [ ] Commit messages claros
- [ ] Revisé mis propios cambios

## Testing Realizado
Describe cómo probaste

## Screenshots (si aplica)
Visuales del cambio
```

---

## Standards de Código

### Python

```python
# Linting: flake8 + black
flake8 src/server --max-line-length=100
black src/server --line-length=100

# Type checking: pyright
pyright src/server

# Tests: pytest
pytest tests/ --cov=src --cov-fail-under=80

# Security: bandit
bandit -r src/server

# Dependencies: pip-audit
pip-audit

# Pre-commit
pre-commit run --all-files
```

### Dart/Flutter

```dart
// Linting: flutter analyze
flutter analyze

// Format: dart format
dart format lib/ test/

// Tests
flutter test

// Coverage
flutter test --coverage
```

### Documentación

```markdown
- Markdown format
- Bilingual (EN + ES cuando aplica)
- Table of contents at top
- Metadata headers
- Code examples executable
- Links funcionando
- SEO-friendly headers
```

---

## Proceso de Review

### Quién puede revisar

```
Code Owners:
  ├─ Backend: @ArchitectZero
  ├─ Frontend: @ArchitectZero
  ├─ Docs: @Community
  └─ DevOps: @ArchitectZero

1+ approval requerido antes de merge
```

### Criterios de Aprobación

```
✅ MUST HAVE:
  ├─ Tests pasando
  ├─ Coverage ≥80%
  ├─ No breaking changes
  ├─ Documentación actualizada
  └─ Code review aprobado

⚠️ NICE TO HAVE:
  ├─ Performance benchmarks
  ├─ Security audit (si aplica)
  └─ Ejemplo de uso
```

### Feedback

```
Esperamos:
  ✅ Constructivo
  ✅ Respetuoso
  ✅ Accionable

Evitamos:
  ❌ Comentarios personales
  ❌ Sarcasmo
  ❌ Pedantería
```

---

## Reporting Issues

### Bug Report Template

```markdown
## Descripción
Qué está mal

## Pasos para reproducir
1. Hice X
2. Luego Y
3. Se vio Z

## Comportamiento esperado
Qué debería pasar

## Comportamiento actual
Qué pasó

## Ambiente
- OS: [e.g., Windows 11]
- Python: [e.g., 3.12.3]
- Flutter: [e.g., 3.16]

## Logs/Screenshots
Adjunta si aplica
```

### Feature Request Template

```markdown
## Descripción
Qué feature

## Caso de uso
Por qué es importante

## Solución propuesta
Cómo lo implementarías

## Alternativas consideradas
Otros enfoques

## Contexto adicional
Lo que sea útil
```

---

## Código de Conducta

### Principios

```
✅ Inclusivo
✅ Respetuoso
✅ Transparente
✅ Colaborativo
❌ Tolerancia cero: harassment, discrimination
```

### Reportar Violaciones

```
Email: [security contact]
Privacidad garantizada
Respuesta en 48h
```

---

## Reconocimiento

### Contributors

```
Todos los contributors aparecen en:
  - README.md
  - CONTRIBUTORS.md
  - GitHub (automático)

Tipos de reconocimiento:
  - 1-5 PRs:   Mención en PR
  - 5-20 PRs:  Mención en CONTRIBUTORS
  - 20+ PRs:   Core contributor status
  - Mantenedor: Github team perms
```

---

**Contributing** hace a SoftArchitect AI un proyecto comunitario auténtico. 🌟

¡Gracias por considerar contribuir!
