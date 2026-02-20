# 🚀 HU-3.3 QUICK START GUIDE

> **Estado:** 🟢 READY
> **Time to Read:** 5 min
> **Time to First Prueba:** 10 min

---

## 📖 5-Minute Overview

HU-3.3 implementa un **Chat Secuencial** que procesa documentoos grandes en chunks, manteniendo contexto a través de múltiples mensajes usando RAG (Retrieval-Augmented Generation).

**Stack:**
- Backend: Python 3.12 + FastAPI
- Pruebas: pyprueba en `pruebas/python/`
- LLM: Ollama (local) + Groq (cloud fallback)
- Data: ChromaDB (vector store)

**6 Fases TDD:**
1. 🔴 RED: Write failing pruebas
2. 🟢 GREEN: Implement minimum code
3. 🔵 REFACTOR: Optimize & clean
4. 🔗 INTEGRATION: Connect components
5. ✅ VALIDATION: Full prueba suite
6. 📝 DOCUMENTATION: Final docs

---

## ⚡ Get Started in 3 Steps

### Step 1: Validate Environment (2 min)
```bash
# From project root
scripts/validate_tests_migration.sh

# Expected: 5/5 ✅ passed
```

### Step 2: Read Workflow Master (30 min)
```bash
# Complete implementation guide
cat doc/03-HU-TRACKING/HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md

# Or open in editor:
code doc/03-HU-TRACKING/HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md
```

### Step 3: Crear First Prueba (5 min)
```bash
# Create feature branch
git checkout -b feature/hu-3.3-phase-1 develop

# Create test file (based on Workflow Master section 4.2)
code tests/python/unit/services/rag/test_orchestrator.py

# Write RED phase tests (copy from section 4.2.2 of Workflow Master)
# Then run:
cd src/server && pytest ../../tests/python/unit/services/rag/test_orchestrator.py -v
```

---

## 📁 Key Archivos

| Archivo | Purpose | Action |
|------|---------|--------|
| **HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md** | Complete guide | 📖 READ |
| **HU-3.3_READY.md** | Checklist | ✅ CHECK |
| **HU-3.3_DASHBOARD.md** | Estado metrics | 📊 REFERENCE |
| **pruebas/python/README_MIGRATION.md** | Prueba organization | 📚 REFERENCE |

---

## 🧪 Ejecutarning Pruebas

```bash
# All tests
cd src/server && pytest ../../tests/python/ -v

# RAG service tests
pytest ../../tests/python/unit/services/rag/ -v

# With coverage
pytest ../../tests/python/ --cov=services --cov-fail-under=80

# Single test
pytest ../../tests/python/unit/services/rag/test_orchestrator.py::TestOrchestrator::test_method -v
```

---

## 🔍 Critical Sections in Workflow Master

**Section 4.2 - Fase 1 RED:** `[Line 450-550]`
- Basic prueba cases to write
- Prueba archivo structure
- Expected failures

**Section 4.3 - Fase 2 GREEN:** `[Line 550-650]`
- Implementación skeleton
- Database schema
- Error handling setup

**Section 4.4 - Fase 3 REFACTOR:** `[Line 650-750]`
- Code optimization
- Performance improvements
- Security hardening

**Section 5 - Integración & Validation:** `[Line 750-850]`
- End-to-end pruebas
- Docker integration
- Performance benchmarks

---

## ✅ Quality Gates (Before Commit)

```bash
# Type checking
cd src/server && pyright services/ tests/

# Format code
black services/

# Lint
ruff check services/

# Tests
pytest ../../tests/python/ --cov=services --cov-fail-under=80

# All together
./scripts/validate-quality-gates.sh
```

---

## 🎯 First Commit Template

```bash
# After creating test_orchestrator.py with RED phase tests:

git add tests/python/unit/services/rag/test_orchestrator.py
git commit -m "test(rag): RED phase - basic orchestrator tests [HU-3.3]

- test_orchestrator_initialization
- test_query_with_empty_results
- test_error_handling_database_connection
(plus more from Workflow Master section 4.2)"
```

---

## 📞 Help & Reference

**"Where do I find X?"**
- Prueba specifications → Section 4 of Workflow Master
- Implementación details → Section 5 of Workflow Master
- Architecture decisions → context/30-ARCHITECTURE/
- Security requirements → context/SECURITY_HARDENING_POLICY.en.md
- Prueba organization → pruebas/python/README_MIGRATION.md

**"How do I fix Y?"**
- Type errors → Ejecutar `pyright` and read error messages
- Prueba failures → Check assertion messages + read prueba code
- Import errors → Check `pruebas/python/confprueba.py` paths
- CI/CD failures → Check `.github/workflows/backend-ci.yaml`

---

## 🚦 Go / No-Go Checklist

Before starting Fase 1:

- [ ] `validate_pruebas_migration.sh` returns 5/5 ✅
- [ ] Can ejecutar `pyprueba ../../pruebas/python/ -v` successfully
- [ ] Read HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md
- [ ] Understand section 4.2 (Fase 1 RED)
- [ ] Feature branch creard: `feature/hu-3.3-fase-1`
- [ ] Code editor open with proper Python path
- [ ] Pre-commit hooks installed and working

**Resultado:** 🟢 **READY TO WRITE FIRST TEST**

---

## 📊 Expected Timeline

| Fase | Duration | Deliverable |
|-------|----------|-------------|
| RED (Write Pruebas) | 2-3 days | 15-20 failing pruebas |
| GREEN (Implement) | 2-3 days | Basic implementación |
| REFACTOR | 1-2 days | Optimized code |
| INTEGRATION | 2-3 days | Connected components |
| VALIDATION | 1 day | All pruebas passing |
| DOCUMENTATION | 1 day | Complete docs |
| **TOTAL** | **~2 weeks** | **Production-ready** |

---

## 🎓 TDD Reminders

✅ **DO:**
- Write prueba FIRST, then code
- Make pruebas fail before implementing
- Ejecutar pruebas frequently (after every change)
- Commit after each fase
- Documento as you go

❌ **DON'T:**
- Write all pruebas at once
- Skip the RED fase
- Skip type checking
- Commit unpruebaed code
- Ignore linting errors

---

## 🔗 Essential Commands

```bash
# Setup
git checkout -b feature/hu-3.3-phase-1 develop
cd src/server

# Run tests
pytest ../../tests/python/ -v

# Run with coverage
pytest ../../tests/python/ --cov=services --cov-fail-under=80

# Type check
pyright services/

# Format
black services/

# Lint
ruff check services/

# Full quality gate
cd ../../ && scripts/validate-quality-gates.sh

# Commit
git add .
git commit -m "feat(rag): [phase-name] - [description] [HU-3.3]"

# Push (GitHub Actions validates automatically)
git push origin feature/hu-3.3-phase-1
```

---

## 🎉 You're Ready!

**Siguiente Step:** Open the Workflow Master and read section 4.2 (Fase 1 RED).

```bash
# Quick read in terminal
cat doc/03-HU-TRACKING/HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md | head -500

# Or full editor view:
code doc/03-HU-TRACKING/HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md
```

---

> **Estado:** 🟢 **READY FOR PHASE 1 (RED)**
>
> All preparation complete. Environment validated. Pruebas organized.
> Documentoation ready. You have everything needed to start.
>
> **Go write some pruebas! 🧪**
