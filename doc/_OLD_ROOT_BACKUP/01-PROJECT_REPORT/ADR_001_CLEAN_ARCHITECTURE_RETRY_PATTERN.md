# ADR-001: Clean Architecture + Retry Pattern Separation

> **Date:** 2026-02-16
> **Status:** ✅ Accepted
> **Context:** HU-4.4 Phase 2 - Backend Retry LLM Logic
> **Decision Makers:** ArchitectZero, Development Team

---

## 📋 Context

During implementation of HU-4.4 GAP 2 (Retry Logic for LLM calls), we encountered a **critical architectural dilemma**:

**Initial Implementation (Phase 2):**
```python
@with_retry(max_retries=3, ...)
async def generate(...) -> str:
    async with httpx.AsyncClient() as client:
        response = await client.post(...)  # Throws httpx exceptions
        return response.json()["response"]
```

**Problem:** To allow retry decorator to work, we removed try-except blocks. This violated **Clean Architecture** by letting infrastructure exceptions (httpx.RequestError) leak into domain layer.

**Test Failures:** 5 tests failed expecting domain exceptions (LLMConnectionError) but receiving infrastructure exceptions (httpx.RequestError).

---

## 🎯 Decision

Implement **Layered Retry Architecture** that separates concerns:

### Layer 1: Infrastructure (Retry Logic)
```python
@with_retry(max_retries=3, base_delay=0.5, ...)
async def _generate_with_retry(...) -> str:
    """Internal method: Has retry logic, throws httpx exceptions."""
    async with httpx.AsyncClient() as client:
        response = await client.post(...)
        return response.json()["response"]
```

### Layer 2: Domain Boundary (Exception Mapping)
```python
async def generate(...) -> str:
    """Public wrapper: Converts infrastructure → domain exceptions."""
    try:
        return await self._generate_with_retry(...)
    except RetryExhaustedError as error:
        if "timeout" in str(error).lower():
            raise LLMTimeoutError(...)  # Domain exception
        else:
            raise LLMConnectionError(...)  # Domain exception
```

---

## 🔍 Rationale

### Why This Approach?

1. **Preserves Clean Architecture**
   - Domain layer only sees domain exceptions (LLMConnectionError, LLMTimeoutError)
   - Infrastructure concerns (httpx, retry) isolated in private methods

2. **Maintains Retry Functionality**
   - @with_retry decorator works on internal method
   - 3 retries with exponential backoff (0.5s, 1.0s, 2.0s)
   - Logs warnings on retries, info on success

3. **Single Responsibility Principle**
   - Internal method: Handles network + retry logic
   - Public method: Handles exception translation

4. **Testability**
   - Tests validate domain exceptions (not infrastructure exceptions)
   - Mocking simplified (only need to mock internal method)

---

## ⚠️ Alternatives Considered

### Alternative 1: Remove Retry Logic
- ❌ **Rejected:** Sacrifices resilience
- Impact: Users see "IA no responde" on transient network glitches

### Alternative 2: Custom Retry Decorator for Domain Exceptions
- ❌ **Rejected:** Over-engineering
- Complexity: Need to maintain custom decorator + tests

### Alternative 3: Retry in Caller (Orchestrator)
- ❌ **Rejected:** Violates Single Responsibility
- Problem: Every caller needs to implement retry logic

---

## 📊 Consequences

### Positive
✅ Clean Architecture maintained (domain isolation)
✅ Retry functionality preserved (3x exponential backoff)
✅ All 256 tests pass (0 skipped, 0 warnings)
✅ Clear separation of concerns (retry vs exception mapping)
✅ Easy to test (mock internal method)

### Negative
⚠️ Slightly more code (2 methods instead of 1)
⚠️ Internal method naming convention (underscore prefix)

### Neutral
🔹 Pattern documented in codebase (DartDoc, PyDoc)
🔹 Future LLM clients must follow same pattern

---

## 🧩 Special Case: AsyncGenerators (Streaming)

### Problem with Decorators
```python
@with_retry(...)  # ❌ DOESN'T WORK
async def stream_generate(...) -> AsyncGenerator[str, None]:
    yield "token"  # Decorator can't handle generators
```

**Why?** AsyncGenerators execute lazily (on first `anext()`). Decorator tries to retry before generator starts.

### Solution: Manual Retry Loop
```python
async def stream_generate(...) -> AsyncGenerator[str, None]:
    """Stream with manual retry logic (no decorator)."""
    max_retries = 3
    base_delay = 0.5

    for attempt in range(max_retries):
        try:
            async with httpx.AsyncClient().stream(...) as response:
                async for line in response.aiter_lines():
                    yield line  # ✅ Works perfectly
            return  # Stream completed successfully
        except (httpx.RequestError, httpx.TimeoutException) as error:
            if attempt == max_retries - 1:
                raise LLMConnectionError(...)  # Last attempt failed
            await asyncio.sleep(base_delay * (2 ** attempt))  # Backoff
```

**Benefits:**
- ✅ Retry logic applies to **connection phase only**
- ✅ Once stream starts, failures propagate immediately (no retry mid-stream)
- ✅ AsyncGenerator works naturally
- ✅ Same exponential backoff as synchronous method

---

## 🎓 Lessons Learned

1. **Clean Architecture is Non-Negotiable**
   - Domain layer must never depend on infrastructure
   - Exception mapping is a **domain boundary responsibility**

2. **Decorators Have Limitations**
   - Don't work with AsyncGenerators (lazy evaluation)
   - Manual retry loops are sometimes cleaner

3. **Test Failures Are Design Feedback**
   - 5 failing tests revealed architectural violation
   - Tests expected domain exceptions → fixed by layered approach

4. **Pragmatism Over Purity**
   - Used decorator where it works (generate)
   - Used manual loop where decorator fails (stream_generate)

---

## 📝 Related Documents

- [HU-4.4 PROGRESS.md](../03-HU-TRACKING/HU-4.4-RAG-LLM-RESILIENCE/PROGRESS.md)
- [Clean Architecture Principles](../30-ARCHITECTURE/CLEAN_ARCHITECTURE_RULES.md)
- [AGENTS.md](../../AGENTS.md) - Section 8 (CI/CD Rules)

---

## 🔄 Review & Evolution

**Next Review:** 2026-03-15 (1 month)

**Future Considerations:**
- Monitor retry success rate in production
- Evaluate if 3 retries is optimal (increase to 5?)
- Consider circuit breaker pattern if Ollama fails frequently

---

**Signed-off by:** ArchitectZero (Lead Architect)
**Approved by:** Development Team
**Implementation:** [Commit ec32cae](https://github.com/Pitcher755/soft-architect-ai/commit/ec32cae)
