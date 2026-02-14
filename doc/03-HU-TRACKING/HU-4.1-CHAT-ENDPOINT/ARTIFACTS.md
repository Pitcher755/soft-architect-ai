# 🧠 HU-4.1: Artifacts Manifest - Backend Chat Endpoint & RAG Orchestration

> **Purpose:** Complete inventory of all files created, modified, or related to HU-4.1
> **Last Updated:** 2026-02-14
> **Status:** 🚧 In Progress (Phase 6 in progress)

---

## 📋 Table of Contents
- [📝 Documentation Files](#-documentation-files)
- [🧩 Domain Layer](#-domain-layer)
- [🏗️ Infrastructure Layer](#️-infrastructure-layer)
- [🔧 Service Layer](#-service-layer)
- [🌐 API Layer](#-api-layer)
- [🧪 Test Files](#-test-files)
- [⚙️ Configuration Files](#️-configuration-files)
- [📊 Metrics & Reports](#-metrics--reports)

---

## 📝 Documentation Files

### Tracking Documentation
| File | Status | Purpose |
|------|--------|---------|
| `doc/03-HU-TRACKING/HU-4.1-CHAT-ENDPOINT/README.md` | ✅ Created | Bilingual HU description |
| `doc/03-HU-TRACKING/HU-4.1-CHAT-ENDPOINT/PROGRESS.md` | ✅ Created | Phase tracking checklist |
| `doc/03-HU-TRACKING/HU-4.1-CHAT-ENDPOINT/ARTIFACTS.md` | ✅ Created | This file - artifacts inventory |
| `doc/03-HU-TRACKING/HU-4.1-CHAT-ENDPOINT/WORKFLOW_MASTER_DEFINITION.md` | ✅ Created | Complete TDD workflow |

### Architecture Documentation
| File | Status | Purpose |
|------|--------|---------|
| `doc/01-PROJECT_REPORT/HU-4.1/API_CONTRACT.md` | ⏳ Pending | OpenAPI/Swagger specification |
| `doc/01-PROJECT_REPORT/HU-4.1/ARCHITECTURE_DIAGRAM.md` | ⏳ Pending | RAG flow diagram |
| `doc/01-PROJECT_REPORT/HU-4.1/ERROR_CODES.md` | ⏳ Pending | Custom error codes documentation |

---

## 🧩 Domain Layer

### Schemas (Pydantic Models)
| File | Status | Purpose | Test Coverage |
|------|--------|---------|---------------|
| `src/server/app/domain/schemas/chat.py` | ✅ Implemented | Request/Response models | ✅ Covered |

**Classes to Implement:**
```python
# src/server/app/domain/schemas/chat.py
- ChatRequest        # Input validation (conversation_id, message, project_id)
- ChatResponse       # Output format (ai_response, template_used, sources)
- RAGContext         # Internal DTO (template, vectorstore_results, prompt)
```

### Domain Exceptions
| File | Status | Purpose |
|------|--------|---------|
| `src/server/app/core/exceptions.py` | ✅ Implemented | Custom chat/RAG/LLM domain exceptions |

**Exceptions to Define:**
```python
# src/server/app/core/exceptions.py
- class LLMConnectionError(BaseAppError)
- class LLMTimeoutError(BaseAppError)
- class RAGRetrievalError(BaseAppError)
- class PromptInjectionDetected(BaseAppError)
- class TemplateMissingError(BaseAppError)
```

---

## 🏗️ Infrastructure Layer

### LLM Clients (Strategy Pattern)
| File | Status | Purpose | Test Coverage |
|------|--------|---------|---------------|
| `src/server/app/infrastructure/llm/base.py` | ✅ Implemented | Abstract base class | ✅ 100% |
| `src/server/app/infrastructure/llm/ollama_client.py` | ✅ Implemented | Ollama integration | ✅ 100% |
| `src/server/app/infrastructure/llm/groq_client.py` | ✅ Implemented | Groq stub (future) | ✅ 100% |
| `src/server/app/infrastructure/llm/factory.py` | ✅ Implemented | Runtime provider switching | ✅ 95% |
| `src/server/app/infrastructure/llm/__init__.py` | ✅ Implemented | Exports & factory | ✅ 100% |

**Classes to Implement:**
```python
# base.py
- class BaseLLMClient(ABC)
  - async def generate(prompt: str, max_tokens: int | None, temperature: float | None) -> str

# ollama_client.py
- class OllamaClient(BaseLLMClient)
  - _http_client: httpx.AsyncClient
  - _base_url: str
  - _model_name: str

# groq_client.py
- class GroqClient(BaseLLMClient)
  - (Stub implementation)
```

### Utilities
| File | Status | Purpose |
|------|--------|---------|
| `src/server/app/infrastructure/llm/retry.py` | ⏳ Pending | Retry decorator with backoff |
| `src/server/app/infrastructure/llm/sanitizer.py` | ⏳ Pending | Input sanitization utilities |

---

## 🔧 Service Layer

### RAG Orchestrator
| File | Status | Purpose | Test Coverage |
|------|--------|---------|---------------|
| `src/server/app/services/rag/orchestrator.py` | ✅ Implemented | Main orchestration logic | ✅ 100% |
| `src/server/app/services/rag/vector_store_protocol.py` | ✅ Implemented | Vector store protocol stub | ✅ 100% |
| `src/server/app/services/rag/template_builder_protocol.py` | ✅ Implemented | Template builder protocol stub | ✅ 100% |
| `src/server/app/services/rag/__init__.py` | ✅ Implemented | Exports | ✅ Covered |

**Class Structure:**
```python
# orchestrator.py
- class RAGOrchestrator:
  - __init__(vector_store, template_builder, llm_client)
  - async def process_message(request: ChatRequest) -> ChatResponse
```

---

## 🌐 API Layer

### Endpoints
| File | Status | Purpose | Test Coverage |
|------|--------|---------|---------------|
| `src/server/app/api/v1/chat.py` | ✅ Implemented | POST /api/v1/chat/message endpoint | ✅ Covered by integration tests |
| `src/server/app/api/v1/__init__.py` | ✅ Exists | Router registration | - |

**Endpoint Signature:**
```python
# chat.py
@router.post("/message", response_model=ChatResponse)
async def send_message(
    request: ChatRequest,
    orchestrator: RAGOrchestrator = Depends(get_rag_orchestrator)
) -> ChatResponse:
    """
    Send a chat message and receive AI response with RAG context.

    Args:
        request: ChatRequest with conversation_id, message, project_id
        orchestrator: Injected RAG orchestration service

    Returns:
        ChatResponse with ai_response, template_used, sources

    Raises:
        HTTPException(503): LLM connection failed
        HTTPException(500): RAG retrieval error (fallback response)
        HTTPException(422): Invalid input
    """
```

### Dependency Injection
| File | Status | Purpose |
|------|--------|---------|
| `src/server/app/api/dependencies.py` | ✅ Implemented | `get_rag_orchestrator()` DI container + stubs |

---

## 🧪 Test Files

### Unit Tests - Domain

Layer
| File | Status | Purpose | Coverage Target |
|------|--------|---------|-----------------|
| `tests/server/unit/domain/schemas/test_chat_schemas.py` | ⏳ Pending | Schema validation tests | >95% |

**Test Cases:**
```python
# test_chat_schemas.py (10+ tests)
- test_chat_request_rejects_over_2000_chars
- test_chat_request_sanitizes_html_tags
- test_chat_request_validates_uuid_format
- test_chat_request_prevents_xss
- test_chat_request_prevents_sql_injection
- test_chat_response_has_required_fields
- test_chat_response_sources_is_list
- test_rag_context_serialization
```

### Unit Tests - Infrastructure Layer
| File | Status | Purpose | Coverage Target |
|------|--------|---------|-----------------|
| `tests/server/unit/infrastructure/llm/test_llm_clients.py` | ✅ Implemented | Base/Ollama/Groq client tests | ✅ >90% |
| `tests/server/unit/infrastructure/llm/test_llm_factory.py` | ✅ Implemented | Factory selection tests | ✅ Covered |

**Test Cases:**
```python
# test_ollama_client.py (15+ tests)
- test_ollama_client_generates_response
- test_ollama_client_handles_connection_error
- test_ollama_client_handles_timeout
- test_ollama_client_retries_on_failure
- test_ollama_client_health_check
- test_ollama_client_validates_model_name
```

### Unit Tests - Service Layer
| File | Status | Purpose | Coverage Target |
|------|--------|---------|-----------------|
| `tests/server/unit/services/rag/test_orchestrator.py` | ✅ Implemented | RAGOrchestrator business logic tests | ✅ 100% (module) |
| `tests/server/unit/services/rag/test_sequential_orchestrator.py` | ✅ Preserved | Legacy sequential orchestrator regression tests | ✅ Covered |

**Test Cases:**
```python
# test_orchestrator.py (20+ tests)
- test_orchestrator_builds_context_and_calls_llm
- test_orchestrator_searches_vectorstore
- test_orchestrator_loads_template_by_phase
- test_orchestrator_injects_context_into_template
- test_orchestrator_handles_rag_failure_gracefully
- test_orchestrator_handles_llm_timeout
- test_orchestrator_logs_request_trace
```

### Integration Tests - API Layer
| File | Status | Purpose | Coverage Target |
|------|--------|---------|-----------------|
| `tests/server/integration/api/v1/test_chat_endpoints.py` | ✅ Implemented | E2E endpoint tests (success/422/503/500) | ✅ Passing |

**Test Cases:**
```python
# test_chat_endpoint.py (10+ tests)
- test_chat_endpoint_returns_200_and_schema
- test_chat_endpoint_handles_invalid_input
- test_chat_endpoint_handles_llm_failure
- test_chat_endpoint_response_time_under_500ms
- test_chat_endpoint_includes_sources
- test_chat_endpoint_uses_correct_template
```

### Performance & Security Tests
| File | Status | Purpose |
|------|--------|---------|
| `tests/server/security/test_prompt_injection.py` | ⏳ Pending | Prompt injection prevention |
| `tests/server/performance/test_chat_latency.py` | ⏳ Pending | Response time profiling |

---

## ⚙️ Configuration Files

| File | Status | Purpose |
|------|--------|---------|
| `.env.example` | ⏳ Modified | Add Ollama/Groq config vars |
| `src/server/app/core/config.py` | ⏳ Modified | Add LLM settings |

**Config Variables to Add:**
```bash
# LLM Configuration
LLM_PROVIDER=ollama  # ollama | groq
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL_NAME=llama2
GROQ_API_KEY=<optional>
GROQ_MODEL_NAME=mixtral-8x7b-32768

# RAG Configuration
RAG_TOP_K=5          # Number of documents to retrieve
RAG_MIN_SIMILARITY=0.7  # Minimum similarity threshold
```

---

## 📊 Metrics & Reports

### Generated Reports
| File | Status | Purpose |
|------|--------|---------|
| `doc/03-HU-TRACKING/HU-4.1-CHAT-ENDPOINT/COVERAGE_REPORT.md` | ⏳ Pending | Test coverage summary |
| `doc/03-HU-TRACKING/HU-4.1-CHAT-ENDPOINT/PERFORMANCE_REPORT.md` | ⏳ Pending | Response time profiling |
| `doc/03-HU-TRACKING/HU-4.1-CHAT-ENDPOINT/SECURITY_AUDIT.md` | ⏳ Pending | Bandit scan results |

### Validation Logs
| File | Status | Purpose |
|------|--------|---------|
| `doc/03-HU-TRACKING/HU-4.1-CHAT-ENDPOINT/PRE_PUSH_LOG.txt` | ⏳ Pending | Output of PRE_PUSH_VALIDATION_MASTER.sh |
| `doc/03-HU-TRACKING/HU-4.1-CHAT-ENDPOINT/CI_CD_LOG.txt` | ⏳ Pending | GitHub Actions output |

---

## 📈 Summary Statistics

| Category | Total Files | Created | Modified | Tests |
|----------|-------------|---------|----------|-------|
| **Documentation** | 7 | 4 | 3 | - |
| **Domain Layer** | 2 | 2 | 0 | 1 |
| **Infrastructure** | 7 | 7 | 0 | 4 |
| **Service Layer** | 2 | 2 | 0 | 1 |
| **API Layer** | 2 | 1 | 1 | 1 |
| **Tests** | 8 | 8 | 0 | - |
| **Configuration** | 2 | 0 | 2 | - |
| **Reports** | 5 | 0 | 0 | - |
| **TOTAL** | **35** | **24** | **6** | **7** |

---

## 🔍 File Dependency Graph

```mermaid
graph TD
    A[chat.py - Endpoint] --> B[orchestrator.py - Service]
    B --> C[vector_store.py - HU-2.2]
    B --> D[template_loader.py - HU-2.2]
    B --> E[ollama_client.py - LLM]
    E --> F[base.py - Abstract]
    A --> G[chat.py - Schemas]
    G --> H[base.py - Exceptions]
    A --> I[dependencies.py - DI]

    style A fill:#ff6b6b
    style B fill:#4ecdc4
    style E fill:#ffe66d
    style G fill:#a8dadc
```

---

## ✅ Completion Checklist

- [x] README.md created
- [x] PROGRESS.md created
- [x] ARTIFACTS.md created (this file)
- [x] WORKFLOW_MASTER_DEFINITION.md created
- [ ] All domain files created
- [ ] All infrastructure files created
- [ ] All service files created
- [ ] All API files created
- [ ] All tests written and passing
- [ ] All reports generated
- [ ] PR opened and merged

---

**Last Update:** 2026-02-14 | **Next Review:** Phase 6 (Validation & PR)
