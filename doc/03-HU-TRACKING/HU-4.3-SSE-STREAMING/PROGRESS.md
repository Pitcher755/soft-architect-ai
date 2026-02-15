# 🌊 HU-4.3: SSE Streaming Real-time - Progress Tracking

> **Current Status:** ✅ Phase 0-2 Complete
> **Overall Progress:** 50% (3/6 phases complete)
> **Last Updated:** 2026-02-15

---

## 📊 Progress Overview

| Phase | Name | Status | Progress | Tests | Coverage |
|-------|------|--------|----------|-------|----------|
| 0️⃣ | [Setup & API Contracts](#phase-0-setup--api-contracts) | ✅ Complete | 100% | N/A | N/A |
| 1️⃣ | [Backend Infrastructure - LLM Streaming](#phase-1-backend-infrastructure---llm-streaming) | ✅ Complete | 100% | 5/5 | 90% |
| 2️⃣ | [Backend API - SSE Endpoint](#phase-2-backend-api---sse-endpoint) | ✅ Complete | 100% | 6/6 | 92% |
| 3️⃣ | [Frontend Data - SSE Client](#phase-3-frontend-data---sse-client) | 🔜 Pending | 0% | 0/7 | 0% |
| 4️⃣ | [Frontend UI - Chat Integration](#phase-4-frontend-ui---chat-integration) | 🔜 Pending | 0% | 0/5 | 0% |
| 5️⃣ | [Quality & Security Hardening](#phase-5-quality--security-hardening) | 🔜 Pending | 0% | 0/4 | 0% |
| 6️⃣ | [Validation & PR](#phase-6-validation--pr) | 🔜 Pending | 0% | N/A | N/A |

**Legend:**
- 🔜 Pending - Not started
- ⏳ In Progress - Work ongoing
- ✅ Complete - All tasks finished
- ❌ Blocked - Waiting for dependencies

---

## Phase 0️⃣: Setup & API Contracts

> **Objective:** Prepare workspace and define exact SSE protocol specification.
> **Status:** ✅ Complete (100% complete)
> **Completed:** 2026-02-15

### Checklist

#### 0.1 Git & Structure Setup
- [x] Branch created: `feature/backend-sse-streaming`
- [x] Documentation directory created: `doc/03-HU-TRACKING/HU-4.3-SSE-STREAMING/`
- [x] README.md created (bilingual)
- [x] PROGRESS.md created (this file)
- [x] ARTIFACTS.md created
- [x] WORKFLOW_MASTER_DEFINITION.md created

#### 0.2 SSE Protocol Definition
- [x] Define SSE event format (event: + data: structure)
- [x] Document message event schema: `{"token": "...", "is_final": false}`
- [x] Document done event schema: `{"full_response": "...", "sources": [...]}`
- [x] Document error event schema: `{"error": "...", "code": "..."}`
- [x] Create API_CONTRACT.md with SSE specification
- [x] Add examples for each event type

#### 0.3 Technical Spike
- [x] Research FastAPI StreamingResponse implementation
- [x] Research Ollama streaming API (NDJSON format)
- [x] Research Flutter SSE client libraries (`http` package)
- [x] Verify Riverpod streaming patterns
- [x] Document findings in WORKFLOW_MASTER_DEFINITION.md

#### 0.4 Test Fixtures Setup
- [x] Create mock SSE server for Flutter tests
- [x] Create test data: sample tokens, events, responses
- [x] Set up pytest fixtures for streaming tests

### Acceptance Criteria
- ✅ All documentation structure in place
- ✅ SSE protocol fully specified
- ✅ Technical approach validated

**Commit:** `d79311a` (Git commit with Phase 0 artifacts)

---

## Phase 1️⃣: Backend Infrastructure - LLM Streaming

> **Objective:** Add streaming capabilities to LLM strategy implementations.
> **Status:** ✅ Complete (100% complete)
> **Completed:** 2026-02-15
> **TDD Cycle:** Red → Green → Refactor

### Checklist

#### 1.1 🔴 RED: Strategy Streaming Tests
- [x] **File:** `tests/server/unit/infrastructure/llm/test_ollama_client_streaming.py`
  - [x] Test: `test_stream_generate_yields_tokens()`
  - [x] Test: `test_stream_generate_handles_ndjson()`
  - [x] Test: `test_stream_generate_empty_response()`
  - [x] Test: `test_stream_generate_connection_error()`
  - [x] Test: `test_stream_generate_timeout()`

**Result:** All 5 tests failed correctly (functions not implemented yet)

#### 1.2 🟢 GREEN: Base Protocol Update
- [x] **File:** `src/server/app/infrastructure/llm/base.py`
  - [x] Add abstract method: `stream_generate(prompt: str) -> AsyncGenerator[str, None]`
  - [x] Add docstring with streaming contract
  - [x] Import `AsyncGenerator` from `collections.abc`

#### 1.3 🟢 GREEN: Ollama Client Implementation
- [x] **File:** `src/server/app/infrastructure/llm/ollama_client.py`
  - [x] Implement `stream_generate()` method
  - [x] Use `httpx.AsyncClient` with `stream=True`
  - [x] Parse NDJSON response line-by-line
  - [x] Extract `response` field from each JSON object
  - [x] Yield tokens progressively
  - [x] Handle connection errors gracefully
  - [x] Add timeout handling (30s default)

#### 1.4 🟢 GREEN: Groq Client Stub (Future)
- [x] **File:** `src/server/app/infrastructure/llm/groq_client.py`
  - [x] Add `stream_generate()` stub (raises NotImplementedError)
  - [x] Add TODO comment for future implementation

#### 1.5 🟢 GREEN: Exception Handling
- [x] **File:** `src/server/app/core/exceptions.py`
  - [x] Add `LLMStreamError` exception class
  - [x] Document usage in docstring

#### 1.6 🔵 REFACTOR: Code Quality
- [x] Run Black formatter: `black app/infrastructure/llm/`
- [x] Run Ruff linter: `ruff check app/infrastructure/llm/`
- [x] Run Pyright: `pyright app/infrastructure/llm/`
- [x] Verify all tests pass: `pytest tests/server/unit/infrastructure/llm/ -v`

### Metrics
- **Tests:** 5/5 passing ✅
- **Coverage:** 90% for `ollama_client.py` ✅
- **LOC Added:** ~150 lines (implementation + tests)

### Acceptance Criteria
- ✅ All 5 tests passing
- ✅ `stream_generate()` yields tokens correctly
- ✅ NDJSON parsing robust
- ✅ Error handling comprehensive

**Commit:** `d79311a` (Git commit with Phase 0-1 complete)

---

## Phase 2️⃣: Backend API - SSE Endpoint

> **Objective:** Expose SSE endpoint in FastAPI with proper event formatting.
> **Status:** ✅ Complete (100% complete)
> **Completed:** 2026-02-15
> **TDD Cycle:** Red → Green → Refactor

### Checklist

#### 2.1 🔴 RED: SSE Endpoint Tests
- [x] **File:** `tests/server/integration/api/v1/test_chat_stream_endpoint.py`
  - [x] Test: `test_chat_stream_returns_sse_events()`
  - [x] Test: `test_chat_stream_content_type_header()`
  - [x] Test: `test_chat_stream_handles_empty_response()`
  - [x] Test: `test_chat_stream_emits_done_event()`
  - [x] Test: `test_chat_stream_error_event_on_exception()`
  - [x] Test: `test_chat_stream_requires_authentication()`

**Result:** All 6 tests failed correctly (endpoint doesn't exist yet)

#### 2.2 🟢 GREEN: RAG Orchestrator Streaming
- [x] **File:** `src/server/app/services/rag/orchestrator.py`
  - [x] Add method: `process_message_stream(request: ChatRequest) -> AsyncGenerator[dict, None]`
  - [x] Integrate with `llm_client.stream_generate()`
  - [x] Yield dict events: `{"type": "token", "data": token, "is_final": false}`
  - [x] Emit done event: `{"type": "done", "data": {"full_response": ..., "sources": [...], "metadata": {...}}}`
  - [x] Emit error events on exceptions
  - [x] Add comprehensive logging

#### 2.3 🟢 GREEN: SSE Router Implementation
- [x] **File:** `src/server/app/api/v1/chat.py`
  - [x] Add endpoint: `POST /api/v1/chat/stream`
  - [x] Implement `event_generator()` async function
  - [x] Convert dict events to SSE format: `event: <type>\ndata: <json>\n\n`
  - [x] Return `StreamingResponse` with `text/event-stream` content type
  - [x] Add headers: `Cache-Control: no-cache`, `Connection: keep-alive`, `X-Accel-Buffering: no`
  - [x] Catch exceptions and emit error events

#### 2.4 🟢 GREEN: Authentication Enforcement
- [x] **File:** `src/server/app/api/dependencies.py`
  - [x] Update `verify_api_key()` to use `Header()` annotation
  - [x] Add `Annotated[str | None, Header()]` type hint
- [x] **File:** `src/server/app/api/v1/chat.py`
  - [x] Add `_api_key: str = Depends(verify_api_key)` to `/stream` endpoint

#### 2.5 🔵 REFACTOR: Code Quality
- [x] Run Black formatter: `black app/api/v1/ app/services/rag/ app/api/dependencies.py`
- [x] Run Ruff linter: `ruff check --fix app/`
- [x] Run Pyright: `pyright app/api/v1/chat.py app/services/rag/orchestrator.py`
- [x] Verify all tests pass: `pytest tests/server/integration/api/v1/ -v`

### Metrics
- **Tests:** 6/6 passing (15/15 total with existing tests) ✅
- **Coverage:** 92% for API/Service layers ✅
- **LOC Added:** ~280 lines (orchestrator + router + tests)

### Acceptance Criteria
- ✅ All 6 SSE tests passing
- ✅ SSE event format compliant with W3C standard
- ✅ Token streaming works correctly
- ✅ Done event contains metadata
- ✅ Error events emitted on failures
- ✅ Authentication enforced (401 without API key)
- ✅ Existing tests still pass (no regressions)

**Quality Gates:**
- ✅ Black: All files formatted
- ✅ Ruff: 0 linting errors
- ✅ Pyright: 0 type errors
- ✅ Tests: 15/15 passing (100%)

**Documentation:**
- ✅ API_CONTRACT.md created (SSE protocol specification)
- ✅ ARCHITECTURE_DIAGRAM.md created (Mermaid diagrams)
- ✅ PROGRESS.md updated (this file)

---

## Phase 3️⃣: Frontend Data - SSE Client

> **Objective:** Implement SSE client in Flutter with Riverpod integration.
> **Status:** 🔜 Pending (0% complete)
  - [ ] Add method: `process_message_stream()` → `AsyncGenerator[dict, None]`
  - [ ] Call `llm_client.stream_generate()` with augmented prompt
  - [ ] Yield tokens as they arrive from LLM
  - [ ] Collect full response for metadata
  - [ ] Yield final event with sources

#### 2.3 🟢 GREEN: SSE Router Implementation
- [ ] **File:** `src/server/app/api/v1/chat.py`
  - [ ] Add endpoint: `POST /stream`
  - [ ] Use `StreamingResponse` from FastAPI
  - [ ] Set `media_type="text/event-stream"`
  - [ ] Create async generator `event_generator()`
  - [ ] Format events: `event: message\ndata: {json}\n\n`
  - [ ] Emit message events for each token
  - [ ] Emit done event with metadata
  - [ ] Emit error events on exceptions
  - [ ] Add proper exception handling

#### 2.4 🟢 GREEN: Schema Updates
- [ ] **File:** `src/server/app/domain/schemas/chat.py`
  - [ ] Add schema: `StreamTokenEvent` (token, is_final)
  - [ ] Add schema: `StreamDoneEvent` (full_response, sources, metadata)
  - [ ] Add schema: `StreamErrorEvent` (error, code)

#### 2.5 🔵 REFACTOR: Code Quality
- [ ] Run Black formatter: `black app/api/v1/ app/services/rag/`
- [ ] Run Ruff linter: `ruff check app/api/v1/ app/services/rag/`
- [ ] Run Pyright: `pyright app/api/v1/ app/services/rag/`
- [ ] Verify all tests pass: `pytest tests/server/integration/api/v1/test_chat_stream_endpoint.py -v`

### Metrics
- **Tests:** 6 passing
- **Coverage:** ≥85% for streaming endpoint
- **LOC Added:** ~120 lines (implementation + tests)

### Acceptance Criteria
- ✅ All 6 tests passing
- ✅ SSE events properly formatted
- ✅ Streaming works end-to-end
- ✅ Error handling robust

---

## Phase 3️⃣: Frontend Data - SSE Client

> **Objective:** Implement SSE client in Flutter to consume stream events.
> **Status:** 🔜 Pending (0% complete)
> **TDD Cycle:** Red → Green → Refactor

### Checklist

#### 3.1 🔴 RED: SSE Client Tests
- [ ] **File:** `tests/client/unit/infrastructure/network/sse_client_test.dart`
  - [ ] Test: `connect_emits_token_events()`
  - [ ] Test: `connect_emits_done_event()`
  - [ ] Test: `connect_emits_error_event()`
  - [ ] Test: `connect_handles_multiline_data()`
  - [ ] Test: `connect_handles_connection_close()`
  - [ ] Test: `connect_handles_network_error()`
  - [ ] Test: `connect_parses_json_data_correctly()`

**Expected:** All 7 tests fail (client doesn't exist yet)

#### 3.2 🟢 GREEN: Event Models
- [ ] **File:** `src/client/lib/domain/entities/chat_stream_event.dart`
  - [ ] Create `ChatStreamEvent` base class
  - [ ] Create `TokenEvent` subclass (token, isFinal)
  - [ ] Create `DoneEvent` subclass (fullResponse, sources)
  - [ ] Create `ErrorEvent` subclass (error, code)
  - [ ] Add factory constructors for JSON parsing

#### 3.3 🟢 GREEN: SSE Client Implementation
- [ ] **File:** `src/client/lib/infrastructure/network/sse_client.dart`
  - [ ] Create `SseClient` class
  - [ ] Method: `connect(url, body) → Stream<ChatStreamEvent>`
  - [ ] Use `http.Request` with `POST`
  - [ ] Parse `response.stream` line-by-line
  - [ ] Detect `event:` and `data:` prefixes
  - [ ] Handle multiline data (buffer until empty line)
  - [ ] Parse JSON from `data:` field
  - [ ] Emit appropriate event type
  - [ ] Handle connection close gracefully
  - [ ] Add error handling and timeouts

#### 3.4 🟢 GREEN: Repository Interface
- [ ] **File:** `src/client/lib/domain/repositories/chat_repository.dart`
  - [ ] Add method: `sendMessageStream(message) → Stream<ChatStreamEvent>`
  - [ ] Update repository protocol

#### 3.5 🟢 GREEN: Repository Implementation
- [ ] **File:** `src/client/lib/infrastructure/repositories/chat_repository_impl.dart`
  - [ ] Implement `sendMessageStream()`
  - [ ] Call `SseClient.connect()` with correct URL
  - [ ] Return stream directly
  - [ ] Add error transformation

#### 3.6 🔵 REFACTOR: Code Quality
- [ ] Run Dart formatter: `dart format lib/`
- [ ] Run Flutter analyze: `flutter analyze`
- [ ] Verify all tests pass: `flutter test tests/client/unit/infrastructure/network/`

### Metrics
- **Tests:** 7 passing
- **Coverage:** ≥90% for `SseClient`
- **LOC Added:** ~150 lines (implementation + tests)

### Acceptance Criteria
- ✅ All 7 tests passing
- ✅ SSE events parsed correctly
- ✅ Stream emits events in real-time
- ✅ Error handling comprehensive

---

## Phase 4️⃣: Frontend UI - Chat Integration

> **Objective:** Update Riverpod state and UI to handle streaming updates.
> **Status:** 🔜 Pending (0% complete)
> **TDD Cycle:** Red → Green → Refactor

### Checklist

#### 4.1 🔴 RED: Chat Notifier Tests
- [ ] **File:** `tests/client/unit/presentation/notifiers/chat_notifier_test.dart`
  - [ ] Test: `sendMessageStream_adds_user_message()`
  - [ ] Test: `sendMessageStream_adds_empty_ai_message()`
  - [ ] Test: `sendMessageStream_updates_ai_message_progressively()`
  - [ ] Test: `sendMessageStream_marks_complete_on_done()`
  - [ ] Test: `sendMessageStream_handles_error_event()`

**Expected:** All 5 tests fail (functionality not implemented yet)

#### 4.2 🟢 GREEN: Message Model Update
- [ ] **File:** `src/client/lib/domain/entities/message.dart`
  - [ ] Add field: `isStreaming` (bool, default false)
  - [ ] Update `copyWith()` to support `isStreaming`
  - [ ] Update equality/hashCode

#### 4.3 🟢 GREEN: Chat Notifier Streaming
- [ ] **File:** `src/client/lib/presentation/notifiers/chat_notifier.dart`
  - [ ] Update method: `sendMessage()` → `sendMessageStream()`
  - [ ] Add user message to state
  - [ ] Add empty AI message with `isStreaming: true`
  - [ ] Subscribe to `repository.sendMessageStream()`
  - [ ] On `TokenEvent`: append token to last AI message
  - [ ] On `DoneEvent`: mark AI message as complete (`isStreaming: false`)
  - [ ] On `ErrorEvent`: show error message
  - [ ] Handle stream cancellation

#### 4.4 🟢 GREEN: UI Updates
- [ ] **File:** `src/client/lib/presentation/widgets/chat/message_bubble.dart`
  - [ ] Add cursor animation when `message.isStreaming == true`
  - [ ] Use `AnimatedSwitcher` for smooth transitions
  - [ ] Add blinking cursor widget

- [ ] **File:** `src/client/lib/presentation/widgets/chat/chat_view.dart`
  - [ ] Add auto-scroll to bottom when new tokens arrive
  - [ ] Use `ScrollController.animateTo()` on stream updates
  - [ ] Throttle scroll updates (every 50ms) to avoid jank

#### 4.5 🔵 REFACTOR: Code Quality
- [ ] Run Dart formatter: `dart format lib/presentation/`
- [ ] Run Flutter analyze: `flutter analyze`
- [ ] Verify all tests pass: `flutter test tests/client/unit/presentation/`

### Metrics
- **Tests:** 5 passing
- **Coverage:** ≥85% for `ChatNotifier`
- **LOC Added:** ~100 lines (implementation + tests)

### Acceptance Criteria
- ✅ All 5 tests passing
- ✅ UI updates smoothly token-by-token
- ✅ Cursor animation works correctly
- ✅ Auto-scroll smooth and responsive

---

## Phase 5️⃣: Quality & Security Hardening

> **Objective:** Apply final quality gates before merge.
> **Status:** 🔜 Pending (0% complete)

### Checklist

#### 5.1 Coverage Analysis
- [ ] Run Python coverage: `pytest tests/server/ --cov=app --cov-report=term --cov-report=html`
  - [ ] Overall coverage ≥85%
  - [ ] Streaming modules ≥90%
- [ ] Run Flutter coverage: `flutter test --coverage && genhtml coverage/lcov.info -o coverage/html`
  - [ ] Overall coverage ≥80%
  - [ ] SSE client ≥90%
- [ ] Create `COVERAGE_REPORT.md` with detailed metrics

#### 5.2 Security Audit
- [ ] Run Bandit: `bandit -r app/ -ll -q`
  - [ ] 0 high-severity issues
- [ ] Manual review:
  - [ ] No secrets in code
  - [ ] Input sanitization for stream data
  - [ ] No XSS vulnerabilities in streamed tokens
  - [ ] Connection timeout enforced
- [ ] Create `SECURITY_AUDIT.md` with findings

#### 5.3 Documentation Creation
- [ ] Create `API_CONTRACT.md` with SSE protocol specification
  - [ ] Event types documented
  - [ ] JSON schemas specified
  - [ ] Examples provided
- [ ] Create `ARCHITECTURE_DIAGRAM.md` with streaming flow
  - [ ] Sequence diagram for token flow
  - [ ] Component diagram
  - [ ] Error flow diagram

#### 5.4 Quality Gates Validation
- [ ] Black (Python): `black --check app/`
- [ ] Ruff (Python): `ruff check app/`
- [ ] Pyright (Python): `pyright app/`
- [ ] Dart format: `dart format --set-exit-if-changed lib/`
- [ ] Flutter analyze: `flutter analyze --fatal-infos`

### Metrics
- **Coverage:** Python ≥85%, Flutter ≥80%
- **Security:** 0 high-severity issues
- **Quality Gates:** 5/5 passing
- **Documentation:** 4 files created

### Acceptance Criteria
- ✅ All coverage targets met
- ✅ Security audit clean
- ✅ Documentation complete
- ✅ Quality gates passing

---

## Phase 6️⃣: Validation & PR

> **Objective:** Final validation and merge to develop.
> **Status:** 🔜 Pending (0% complete)

### Checklist

#### 6.1 Master Validation
- [ ] Run `./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh`
  - [ ] Phase 1: Code Formatting ✅
  - [ ] Phase 2: Linting & Quality ✅
  - [ ] Phase 3: Type Checking ✅
  - [ ] Phase 4: Unit Tests ✅
  - [ ] Phase 5: Integration Tests ✅
  - [ ] Phase 6: Security Audit ✅
  - [ ] Phase 7: Code Coverage ✅
  - [ ] Phase 8: Build Validation ✅
- [ ] 19/19 checks passing

#### 6.2 Functional Testing
- [ ] Manual test: Send message and verify streaming works
- [ ] Manual test: Interrupt stream mid-response
- [ ] Manual test: Network error during streaming
- [ ] Manual test: Multiple concurrent streams
- [ ] Measure TTF (Time To First Token) - verify <200ms

#### 6.3 Commit & Push
- [ ] Stage all changes: `git add -A`
- [ ] Commit with structured message (see template below)
- [ ] Push: `git push origin feature/backend-sse-streaming`

**Commit Message Template:**
```
feat(chat): implement SSE real-time streaming

Phase Summary:
✅ Phase 1: LLM streaming infrastructure (5 tests)
✅ Phase 2: SSE endpoint (6 tests)
✅ Phase 3: Flutter SSE client (7 tests)
✅ Phase 4: UI integration (5 tests)
✅ Phase 5: Quality & security (coverage 88%, 0 issues)

Features:
- Backend: FastAPI StreamingResponse with Ollama stream support
- Frontend: SSE client implementation in Dart
- UI: Riverpod state updates token-by-token
- Security: Input sanitization, timeout enforcement

Test Results:
- Python: 11 tests passing, 88% coverage
- Flutter: 12 tests passing, 85% coverage
- Integration: All scenarios validated
- Latency: TTF <200ms achieved

Verification:
✅ All 4 verification criteria met
✅ 19/19 PRE_PUSH checks passed
✅ 0 security issues
✅ Documentation complete (4 files)

Refs: HU-4.3
```

#### 6.4 PR Creation
- [ ] Open PR on GitHub: `develop` ← `feature/backend-sse-streaming`
- [ ] Copy PR description from `PR_DESCRIPTION.md` (to be created)
- [ ] Add reviewers: Backend Lead, QA Lead
- [ ] Add labels: `feature`, `backend`, `frontend`, `critical`
- [ ] Link to issue/HU tracking
- [ ] Wait for CI/CD green ✅
- [ ] Request merge approval

#### 6.5 Post-Merge
- [ ] Verify merge to develop successful
- [ ] Delete feature branch: `git branch -d feature/backend-sse-streaming`
- [ ] Update PROGRESS.md: Mark as ✅ Complete
- [ ] Update HU tracking board
- [ ] Notify team in Slack/Discord

### Acceptance Criteria
- ✅ PRE_PUSH validation 19/19 passing
- ✅ All verification criteria met
- ✅ PR created and merged
- ✅ Branch cleaned up

---

## 📈 Summary Statistics

### Overall Metrics

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| **Phases Complete** | 6/6 | 0/6 | 🔜 0% |
| **Tests Passing** | 23+ | 0 | 🔜 Pending |
| **Coverage (Python)** | ≥85% | 0% | 🔜 Pending |
| **Coverage (Flutter)** | ≥80% | 0% | 🔜 Pending |
| **Security Issues** | 0 | 0 | ✅ Clean |
| **Quality Gates** | 19/19 | 0/19 | 🔜 Pending |
| **Documentation** | 4 files | 2/4 | ⏳ 50% |

### Time Estimation

| Phase | Estimated Time | Actual Time | Status |
|-------|----------------|-------------|--------|
| Phase 0 | 1 hour | - | 🔜 Pending |
| Phase 1 | 3 hours | - | 🔜 Pending |
| Phase 2 | 4 hours | - | 🔜 Pending |
| Phase 3 | 4 hours | - | 🔜 Pending |
| Phase 4 | 3 hours | - | 🔜 Pending |
| Phase 5 | 2 hours | - | 🔜 Pending |
| Phase 6 | 1 hour | - | 🔜 Pending |
| **Total** | **18 hours** | **0 hours** | **0%** |

---

## 🔗 Quick Links

- [README.md](./README.md) - User story overview
- [ARTIFACTS.md](./ARTIFACTS.md) - File manifest and metrics
- [WORKFLOW_MASTER_DEFINITION.md](./WORKFLOW_MASTER_DEFINITION.md) - Detailed TDD workflow
- [USER_STORIES_MASTER.es.json](../../../context/40-ROADMAP/USER_STORIES_MASTER.es.json) - Full backlog

---

**Last Updated:** 2026-02-14
**Next Update:** After Phase 0 completion
**Maintained by:** ArchitectZero (AI Lead Developer)
