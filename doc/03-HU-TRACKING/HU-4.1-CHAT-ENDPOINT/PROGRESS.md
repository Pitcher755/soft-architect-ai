# 🧠 HU-4.1: Progress Tracking - Backend Chat Endpoint & RAG Orchestration

> **Last Updated:** 2026-02-13
> **Status:** 🚧 In Progress (Phase 4 - FastAPI Endpoint pending)
> **Branch:** `feature/backend-chat-endpoint`

---

## 📊 Progress Summary

| Phase | Status | Progress | Start Date | End Date |
|-------|--------|----------|------------|----------|
| **Phase 0:** Setup & Contracts | ✅ Completed | 100% | 2026-02-13 | 2026-02-13 |
| **Phase 1:** Domain & Security (TDD Red) | ✅ Completed | 100% | 2026-02-13 | 2026-02-13 |
| **Phase 2:** Infrastructure (TDD Green) | ✅ Completed | 100% | 2026-02-13 | 2026-02-13 |
| **Phase 3:** RAG Orchestrator (TDD Refactor) | ✅ Completed | 100% | 2026-02-13 | 2026-02-13 |
| **Phase 4:** FastAPI Endpoint | ⏳ Pending | 0% | - | - |
| **Phase 5:** Quality & Security Hardening | ⏳ Pending | 0% | - | - |
| **Phase 6:** Validation & PR | ⏳ Pending | 0% | - | - |

**Overall Progress:** 57% (4/7 phases)

### ✅ Execution Evidence (2026-02-13)

- **Phase 2 validated:**
  - `pytest tests/server/unit/infrastructure/llm -q --cov=src/server/app/infrastructure/llm --cov-fail-under=90` → `13 passed`, `98.94%`.
  - `python -m pyright app/infrastructure/llm --pythonpath venv/bin/python` → `0 errors`.
  - Commits RED/GREEN/REFACTOR present: `b829164`, `3ab815d`, `bdd7c26`.

- **Phase 3 validated:**
  - `pytest tests/server/unit/services/rag -v --cov=src/server/app/services/rag --cov-fail-under=85` → `20 passed`, `91.34%`.
  - `python -m pyright app/services/rag --pythonpath venv/bin/python` → `0 errors`.
  - Implemented `RAGOrchestrator` with dependency injection + protocol stubs.

---

## 📝 Detailed Phase Checklist

### Phase 0: Setup & Contracts (API Design)

**Objective:** Prepare branch, tracking, and define exact API contracts before coding.

#### Checklist
- [x] Create branch `feature/backend-chat-endpoint` from `develop`
- [x] Create tracking directory `doc/03-HU-TRACKING/HU-4.1-CHAT-ENDPOINT/`
- [x] Create README.md (bilingual)
- [x] Create PROGRESS.md
- [x] Create ARTIFACTS.md
- [x] Create WORKFLOW_MASTER_DEFINITION.md
- [ ] Define Pydantic schemas skeleton (`src/server/app/domain/schemas/chat.py`)
  - [ ] `ChatRequest` class
  - [ ] `ChatResponse` class
  - [ ] `RAGContext` class (internal DTO)
- [ ] Document API contract in Swagger/OpenAPI format
- [ ] Review API contract with team (self-review if solo)
- [ ] Commit initial documentation: `docs: init HU-4.1 tracking and API contracts`

**Exit Criteria:**
- ✅ Branch created and tracking docs committed
- ⏳ API schemas defined (not implemented, just structure)
- ⏳ All team members (or self) reviewed and approved contracts

---

### Phase 1: Domain & Security (TDD Red)

**Objective:** Implement domain layer with security-first validation using TDD Red phase.

#### Checklist
- [ ] **TDD Cycle 1: Input Validation**
  - [ ] Write failing test: `test_chat_request_rejects_over_2000_chars()`
  - [ ] Write failing test: `test_chat_request_sanitizes_html_tags()`
  - [ ] Write failing test: `test_chat_request_validates_uuid_format()`
  - [ ] Implement `ChatRequest` with validators (make tests pass)
  - [ ] Refactor: Extract sanitizer to utility function

- [ ] **TDD Cycle 2: Response Schema**
  - [ ] Write failing test: `test_chat_response_has_required_fields()`
  - [ ] Write failing test: `test_chat_response_sources_is_list()`
  - [ ] Implement `ChatResponse` schema
  - [ ] Refactor: Add optional fields (metadata, debug_info)

- [ ] **Security Tests**
  - [ ] Test XSS prevention: `test_prevents_javascript_injection()`
  - [ ] Test SQL injection attempts: `test_prevents_sql_injection_patterns()`
  - [ ] Test prompt injection: `test_prevents_llm_prompt_hijacking()`
  - [ ] Test DOS prevention: `test_rate_limits_large_inputs()`

- [ ] **Type Safety Validation**
  - [ ] Run Pyright: `python -m pyright app/domain/schemas/chat.py`
  - [ ] Ensure 0 type errors
  - [ ] Add type hints to ALL functions

- [ ] Commit: `feat(domain): implement ChatRequest/ChatResponse with security validation`

**Exit Criteria:**
- ✅ All domain tests pass (>95% coverage)
- ✅ Pyright reports 0 errors
- ✅ Security tests pass (XSS, SQL injection, prompt injection)

---

### Phase 2: Infrastructure (TDD Green)

**Objective:** Implement LLM client abstractions using Strategy pattern (TDD Green phase).

#### Checklist
- [ ] **TDD Cycle 3: BaseLLMClient Interface**
  - [ ] Write failing test: `test_base_llm_client_is_abstract()`
  - [ ] Create abstract class `BaseLLMClient` in `app/infrastructure/llm/base.py`
    - [ ] Define `async def generate(prompt: str, context: list[str]) -> str`
    - [ ] Define `async def health_check() -> bool`

- [ ] **TDD Cycle 4: OllamaClient Implementation**
  - [ ] Write failing test: `test_ollama_client_generates_response()`
    - [ ] Mock `httpx.AsyncClient.post()`
    - [ ] Assert correct URL and payload
  - [ ] Write failing test: `test_ollama_client_handles_connection_error()`
  - [ ] Implement `OllamaClient(BaseLLMClient)`
    - [ ] HTTP client to Ollama REST API
    - [ ] Error handling (ConnectionError, TimeoutError)
    - [ ] Retry logic (3x with exponential backoff)
  - [ ] Refactor: Extract retry decorator

- [ ] **TDD Cycle 5: GroqClient Stub**
  - [ ] Write failing test: `test_groq_client_generates_response()`
  - [ ] Implement `GroqClient(BaseLLMClient)` (stub implementation)
    - [ ] Return `"Groq not implemented yet"`
    - [ ] Log warning when called

- [ ] **Type Safety Validation**
  - [ ] Run Pyright: `python -m pyright app/infrastructure/llm/`
  - [ ] Ensure all implementations respect `BaseLLMClient` contract

- [ ] Commit: `feat(infrastructure): implement LLM client Strategy pattern (Ollama + Groq stub)`

**Exit Criteria:**
- ✅ All LLM client tests pass (>90% coverage)
- ✅ OllamaClient successfully calls local Ollama instance
- ✅ Pyright reports 0 errors

---

### Phase 3: RAG Orchestrator (TDD Refactor)

**Objective:** Implement the brain - RAG orchestration service (TDD Refactor phase).

#### Checklist
- [ ] **TDD Cycle 6: VectorStore Integration**
  - [ ] Write failing test: `test_orchestrator_searches_vectorstore()`
    - [ ] Mock `VectorStore.search()`
    - [ ] Assert query passed correctly
  - [ ] Implement `RAGOrchestrator.__init__()` with VectorStore injection
  - [ ] Implement `_search_knowledge_base(query: str) -> list[str]`

- [ ] **TDD Cycle 7: Template Loader Integration**
  - [ ] Write failing test: `test_orchestrator_loads_template_by_phase()`
    - [ ] Mock `TemplateLoader.load()`
    - [ ] Assert correct template loaded for project phase
  - [ ] Implement `_load_template(phase_id: str) -> str`
  - [ ] Integrate with existing `TemplateLoader` from HU-2.2

- [ ] **TDD Cycle 8: Context Injection**
  - [ ] Write failing test: `test_orchestrator_injects_context_into_template()`
    - [ ] Assert RAG results + user input in final prompt
  - [ ] Implement `_build_prompt(template: str, context: list[str], user_input: str) -> str`
  - [ ] Use Jinja2 or f-string templating

- [ ] **TDD Cycle 9: LLM Invocation**
  - [ ] Write failing test: `test_orchestrator_calls_llm_with_prompt()`
    - [ ] Mock `BaseLLMClient.generate()`
    - [ ] Assert correct prompt passed
  - [ ] Implement `process_message(message: str, project_id: UUID) -> ChatResponse`
    - [ ] Chain: search → load_template → build_prompt → call_llm
    - [ ] Handle errors (fallback to generic response)

- [ ] **Refactor: Error Handling**
  - [ ] Extract error handling to decorators
  - [ ] Add logging with request tracing
  - [ ] Implement fallback strategy (RAG fails → use LLM without context)

- [ ] **Type Safety Validation**
  - [ ] Run Pyright: `python -m pyright app/services/rag/orchestrator.py`
  - [ ] Ensure all async types are correct

- [ ] Commit: `feat(rag): implement RAGOrchestrator with full context injection pipeline`

**Exit Criteria:**
- ✅ All orchestrator tests pass (>90% coverage)
- ✅ End-to-end orchestration flow works (mocked external services)
- ✅ Pyright reports 0 errors

---

### Phase 4: FastAPI Endpoint

**Objective:** Expose the RAG functionality via REST API endpoint.

#### Checklist
- [ ] **TDD Cycle 10: Endpoint Integration**
  - [ ] Write failing test: `test_chat_endpoint_returns_200_and_schema()`
    - [ ] Use `httpx.AsyncClient` to test endpoint
    - [ ] Mock `RAGOrchestrator` using `app.dependency_overrides`
  - [ ] Write failing test: `test_chat_endpoint_handles_invalid_input()`
    - [ ] Test 422 response for bad request
  - [ ] Write failing test: `test_chat_endpoint_handles_llm_failure()`
    - [ ] Test 503 response when LLM unavailable

- [ ] **Endpoint Implementation**
  - [ ] Create `app/api/v1/chat.py`
  - [ ] Implement POST `/api/v1/chat/message`
    - [ ] Use dependency injection for `RAGOrchestrator`
    - [ ] Add request validation (Pydantic)
    - [ ] Add error handling (custom exceptions)
    - [ ] Add logging (request ID, duration, status)
  - [ ] Register router in `app/main.py`

- [ ] **Error Handling**
  - [ ] Implement custom exception handlers
    - [ ] `LLMConnectionError` → 503
    - [ ] `RAGRetrievalError` → 500 with fallback
    - [ ] `ValidationError` → 422
  - [ ] Never expose stack traces to client

- [ ] **API Documentation**
  - [ ] Add docstrings to endpoint
  - [ ] Test Swagger UI at `/docs`
  - [ ] Add example request/response in docs

- [ ] Commit: `feat(api): implement POST /api/v1/chat/message with RAG integration`

**Exit Criteria:**
- ✅ Endpoint tests pass (>80% coverage)
- ✅ Manual test with Postman/curl succeeds
- ✅ Swagger docs generated correctly

---

### Phase 5: Quality & Security Hardening

**Objective:** Ensure code meets all quality gates and security standards.

#### Checklist
- [ ] **Code Formatting**
  - [ ] Run Black: `black src/server/app/ tests/server/`
  - [ ] Verify: `black --check src/server/`

- [ ] **Linting**
  - [ ] Run Ruff: `ruff check --fix src/server/app/ tests/server/`
  - [ ] Verify: `ruff check src/server/`
  - [ ] Address all security warnings (S-codes)

- [ ] **Type Checking**
  - [ ] Run Pyright: `python -m pyright src/server/app/`
  - [ ] Ensure 0 errors
  - [ ] Fix all type hints

- [ ] **Testing**
  - [ ] Run unit tests: `pytest tests/server/unit/ --cov=app --cov-fail-under=80`
  - [ ] Run integration tests: `pytest tests/server/integration/`
  - [ ] Verify coverage >80% for all modules

- [ ] **Security Audit**
  - [ ] Run Bandit: `bandit -r src/server/app/`
  - [ ] Address all high-severity issues
  - [ ] Document any accepted risks (noqa with justification)

- [ ] **Performance Profiling**
  - [ ] Test endpoint response time (<500ms target)
  - [ ] Profile slow queries/operations
  - [ ] Optimize if needed

- [ ] **Documentation**
  - [ ] Update API docs (Swagger)
  - [ ] Update README.md (usage examples)
  - [ ] Create architecture diagram (RAG flow)
  - [ ] Document error codes

- [ ] Commit: `chore: quality gates passed - formatting, linting, types, tests, security`

**Exit Criteria:**
- ✅ Black formatted (no changes)
- ✅ Ruff clean (no violations)
- ✅ Pyright clean (0 errors)
- ✅ Tests pass >80% coverage
- ✅ Bandit clean (no high-severity issues)
- ✅ Response time <500ms verified

---

### Phase 6: Validation & PR

**Objective:** Final validation and pull request submission.

#### Checklist
- [ ] **Pre-Push Validation**
  - [ ] Run master script: `./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh`
  - [ ] Verify exit code 0 (all checks pass)
  - [ ] Fix any issues reported

- [ ] **Git Hygiene**
  - [ ] Review all commits (squash if needed)
  - [ ] Ensure commit messages follow convention
    - [ ] `feat:` for new features
    - [ ] `fix:` for bug fixes
    - [ ] `docs:` for documentation
    - [ ] `test:` for test additions
  - [ ] No hardcoded credentials or secrets

- [ ] **Documentation Updates**
  - [ ] Update PROGRESS.md (mark all phases ✅)
  - [ ] Update README.md (add completion status)
  - [ ] Update ARTIFACTS.md (list all created files)

- [ ] **Push & PR**
  - [ ] Push branch: `git push origin feature/backend-chat-endpoint`
  - [ ] Open PR to `develop`
  - [ ] Fill PR template:
    - [ ] Description of changes
    - [ ] Testing evidence
    - [ ] Screenshots (if UI changes)
    - [ ] Breaking changes (if any)
  - [ ] Link PR to HU-4.1 issue

- [ ] **CI/CD Validation**
  - [ ] Verify GitHub Actions pass (Backend CI)
  - [ ] Check coverage report
  - [ ] Review Pyright output

- [ ] **Code Review**
  - [ ] Self-review code changes
  - [ ] Address review comments
  - [ ] Approve and merge to `develop`

**Exit Criteria:**
- ✅ PRE_PUSH_VALIDATION_MASTER script passes
- ✅ All GitHub Actions pass
- ✅ PR approved and merged
- ✅ HU-4.1 marked as ✅ Complete

---

## 🎯 Success Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| **Test Coverage** | >80% | - | ⏳ |
| **Response Time** | <500ms | - | ⏳ |
| **Pyright Errors** | 0 | - | ⏳ |
| **Ruff Violations** | 0 | - | ⏳ |
| **Bandit Issues** | 0 high | - | ⏳ |
| **API Uptime** | >99% | - | ⏳ |

---

## 📝 Notes & Blockers

### Current Blockers
- ⏳ None yet

### Important Decisions
- Using Ollama as primary LLM (local-first approach)
- Groq integration deferred to future sprint
- Template selection based on project phase ID (from HU-2.2)

### Lessons Learned
- (To be filled during development)

---

**Last Sync:** 2026-02-13 | **Next Review:** After Phase 1 completion
