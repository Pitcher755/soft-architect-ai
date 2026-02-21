# 🚀 HU-3.3 QUICK START GUIDE

> **Status:** 🟢 READY
> **Time to Read:** 5 min
> **Time to First Test:** 10 min

---

## 📖 5-Minute Overview

HU-3.3 implementa un **Chat Secuencial** que procesa documents grandes en chunks, manteniendo contexto a través de múltiples mensajes usando RAG (Retrieval-Augmented Generation).

**Stack:**
- Backend: Python 3.12 + FastAPI
- Tests: pytest en `tests/python/`
- LLM: Ollama (local) + Groq (cloud fallback)
- Data: ChromaDB (vector store)

**6 Phases TDD:**
1. 🔴 RED: Write failing tests
2. 🟢 GREEN: Implement minimum code
3. 🔵 REFACTOR: Optimize & clean
4. 🔗 INTEGRATION: Connect components
5. ✅ VALIDATION: Full test suite
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

### Step 3: Create First Test (5 min)
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

## 📁 Key Files

| File | Purpose | Action |
|------|---------|--------|
| **HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md** | Complete guide | 📖 READ |
| **HU-3.3_READY.md** | Checklist | ✅ CHECK |
| **HU-3.3_DASHBOARD.md** | Status metrics | 📊 REFERENCE |
| **tests/python/README_MIGRATION.md** | Test organization | 📚 REFERENCE |

---

## 🧪 Running Tests

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

**Section 4.2 - Phase 1 RED:** `[Line 450-550]`
- Basic test cases to write
- Test file structure
- Expected failures

**Section 4.3 - Phase 2 GREEN:** `[Line 550-650]`
- Implementation skeleton
- Database schema
- Error handling setup

**Section 4.4 - Phase 3 REFACTOR:** `[Line 650-750]`
- Code optimization
- Performance improvements
- Security hardening

**Section 5 - Integration & Validation:** `[Line 750-850]`
- End-to-end tests
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
- Test specifications → Section 4 of Workflow Master
- Implementation details → Section 5 of Workflow Master
- Architecture decisions → context/30-ARCHITECTURE/
- Security requirements → context/SECURITY_HARDENING_POLICY.en.md
- Test organization → tests/python/README_MIGRATION.md

**"How do I fix Y?"**
- Type errors → Run `pyright` and read error messages
- Test failures → Check assertion messages + read test code
- Import errors → Check `tests/python/conftest.py` paths
- CI/CD failures → Check `.github/workflows/backend-ci.yaml`

---

## 🚦 Go / No-Go Checklist

Before starting Phase 1:

- [ ] `validate_tests_migration.sh` returns 5/5 ✅
- [ ] Can run `pytest ../../tests/python/ -v` successfully
- [ ] Read HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md
- [ ] Understand section 4.2 (Phase 1 RED)
- [ ] Feature branch created: `feature/hu-3.3-phase-1`
- [ ] Code editor open with proper Python path
- [ ] Pre-commit hooks installed and working

**Result:** 🟢 **READY TO WRITE FIRST TEST**

---

## 📊 Expected Timeline

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| RED (Write Tests) | 2-3 days | 15-20 failing tests |
| GREEN (Implement) | 2-3 days | Basic implementation |
| REFACTOR | 1-2 days | Optimized code |
| INTEGRATION | 2-3 days | Connected components |
| VALIDATION | 1 day | All tests passing |
| DOCUMENTATION | 1 day | Complete docs |
| **TOTAL** | **~2 weeks** | **Production-ready** |

---

## 🎓 TDD Reminders

✅ **DO:**
- Write test FIRST, then code
- Make tests fail before implementing
- Run tests frequently (after every change)
- Commit after each phase
- Document as you go

❌ **DON'T:**
- Write all tests at once
- Skip the RED phase
- Skip type checking
- Commit untested code
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

**Next Step:** Open the Workflow Master and read section 4.2 (Phase 1 RED).

```bash
# Quick read in terminal
cat doc/03-HU-TRACKING/HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md | head -500

# Or full editor view:
code doc/03-HU-TRACKING/HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md
```

---

> **Status:** 🟢 **READY FOR PHASE 1 (RED)**
>
> All preparation complete. Environment validated. Tests organized.
> Documentation ready. You have everything needed to start.
>
> **Go write some tests! 🧪**
