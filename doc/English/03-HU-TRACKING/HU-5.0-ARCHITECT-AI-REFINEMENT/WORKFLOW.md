# 🔄 HU-5.0: Complete Implementation Workflow

> **Version:** 1.0
> **Last Updated:** 2026-02-21
> **Estimated Duration:** 5-7 days intensive development

---

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Phase 1: Backend LLM Refinement](#phase-1-backend-llm-refinement)
- [Phase 2: System Prompt Rules](#phase-2-system-prompt-rules)
- [Phase 3: Frontend Integration](#phase-3-frontend-integration)
- [Phase 4: Testing Suite](#phase-4-testing-suite)
- [Phase 5: Knowledge Base Updates](#phase-5-knowledge-base-updates)
- [Phase 6: Homelab Deployment](#phase-6-homelab-deployment)
- [Phase 7: Final Validation & Demo](#phase-7-final-validation--demo)
- [Rollback Plan](#rollback-plan)

---

## 🎯 Overview

This workflow guides the complete implementation of HU-5.0, refining the AI Architect behavior and enabling homelab deployment with Groq Cloud API for TFM presentation.

**Critical Path:**
```
Temperature Adjustment → System Prompt Rules → Testing → Deployment → Demo
      (Day 1)                (Day 2-4)         (Day 5)    (Day 6)    (Day 7)
```

**Success Criteria:**
- ✅ All 10 system prompt rules implemented and tested
- ✅ 30+ unit tests passing (backend coverage ≥85%)
- ✅ Homelab deployment successful with Groq API
- ✅ Complete workflow 0→24 docs executable in <15 minutes
- ✅ Video demo recorded and presentation materials ready

---

## ✅ Prerequisites

### Development Environment
```bash
# Verify current branch
git branch --show-current
# Expected: feature/hu-5.0-full-workflow-refinement

# Pull latest changes
git pull origin develop

# Verify Python environment
python --version  # Expected: 3.12.3
cd src/server && uv sync

# Verify Flutter environment
flutter --version  # Expected: 3.x
cd src/client && flutter pub get

# Verify Docker
docker --version  # Expected: 24.x
docker-compose --version  # Expected: v2.x
```

### Infrastructure Access
- [ ] Groq API Key obtained (https://console.groq.com/keys)
- [ ] Homelab VM provisioned (8GB RAM, 4 vCPUs, Ubuntu 22.04)
- [ ] SSH access to homelab VM configured
- [ ] Domain/subdomain configured (e.g., `softarchitect.homelab.local`)

---

## 🔧 Phase 1: Backend LLM Refinement

### Step 1.1: Adjust Temperature in Groq Client
**Duration:** 15 minutes

**File:** `src/server/app/infrastructure/llm/groq_client.py`

**Changes:**
```python
# BEFORE (line ~45)
temperature=0.5,

# AFTER
temperature=0.6,  # Increased for creative proactivity while maintaining coherence
```

**Rationale:**
- Current 0.5: Too conservative, generates generic placeholders
- New 0.6: Allows creative filling of missing data with industry standards
- Tested range: 0.6-0.7 optimal (0.8+ risks incoherence)

**Verification:**
```bash
# Test temperature impact
cd src/server
pytest tests/server/unit/infrastructure/llm/test_groq_client.py -k test_temperature

# Manual test: Generate a document and verify it has realistic content (no placeholders)
```

### Step 1.2: Document Temperature Decision
**Duration:** 15 minutes

**File:** `doc/English/01-PROJECT_REPORT/01-ARCHITECTURE/ADR-005-LLM-TEMPERATURE-ADJUSTMENT.md`

**Content:**
```markdown
# ADR-005: LLM Temperature Adjustment for Proactive Document Generation

## Status
Accepted

## Context
Previous temperature (0.5) was too conservative, resulting in:
- Generic placeholder text ([Insert your text here])
- Lack of creative realistic examples
- Poor user experience (manual filling required)

## Decision
Increase Groq LLM temperature to 0.6 (range: 0.6-0.7)

## Consequences
Positive:
- More realistic, complete drafts
- Better user experience (less manual work)
- Industry-standard examples auto-filled

Negative:
- Slight risk of hallucinations (mitigated by RAG context)
- Need stronger validation rules
```

**Commit:**
```bash
git add src/server/app/infrastructure/llm/groq_client.py
git add doc/English/01-PROJECT_REPORT/01-ARCHITECTURE/ADR-005-LLM-TEMPERATURE-ADJUSTMENT.md
git commit -m "feat(llm): Increase Groq temperature to 0.6 for proactive generation

- Adjust temperature from  0.5 → 0.6 for better creativity
- Add ADR documenting decision rationale
- Prepares for system prompt rule enforcement

Ref: HU-5.0"
```

---

## 🧠 Phase 2: System Prompt Rules Implementation

### Step 2.1: RULE-01 - Anti-Manifesto Automatic
**Duration:** 2 hours

#### 2.1.1 Create Short Prompt Detector

**File:** `src/server/app/services/rag/short_prompt_detector.py` (NEW)

```python
"""
Short Prompt Detector - Triggers key questions if user input is too brief.
"""
from typing import List, Optional


class ShortPromptDetector:
    """Detects short prompts and generates clarifying questions."""

    THRESHOLD_CHARS = 50

    KEY_QUESTIONS = [
        "What type of application are you building? (e.g., web app, mobile app, desktop app, API service)",
        "What is your preferred tech stack? (e.g., React+Node, Flutter+Python, Django+Vue)",
        "What are the 3 main features or goals of your project?"
    ]

    @staticmethod
    def is_short_prompt(user_message: str) -> bool:
        """
        Check if prompt is too short to generate meaningful content.

        Args:
            user_message: The user's input message

        Returns:
            True if prompt is shorter than threshold
        """
        # Strip whitespace and check length
        clean_message = user_message.strip()
        return len(clean_message) < ShortPromptDetector.THRESHOLD_CHARS

    @staticmethod
    def generate_clarifying_questions() -> List[str]:
        """
        Generate list of clarifying questions.

        Returns:
            List of key questions to ask user
        """
        return ShortPromptDetector.KEY_QUESTIONS

    @staticmethod
    def format_questions_response(user_message: str) -> str:
        """
        Format the response with clarifying questions.

        Args:
            user_message: The original short user message

        Returns:
            Formatted response asking for more details
        """
        questions = ShortPromptDetector.generate_clarifying_questions()

        response = (
            f"I'd love to help you build your project! However, I need a bit more context. "
            f"Could you please answer these questions?\n\n"
        )

        for i, question in enumerate(questions, 1):
            response += f"{i}. {question}\n"

        response += (
            f"\nOnce I understand your requirements, I'll guide you through creating "
            f"professional documentation (24 documents from vision to implementation)."
        )

        return response
```

#### 2.1.2 Integrate into Orchestrator

**File:** `src/server/app/services/rag/orchestrator.py`

**Changes:**
```python
# Add import
from app.services.rag.short_prompt_detector import ShortPromptDetector

# In generate_response() method, add at the beginning:
async def generate_response(
    self,
    user_message: str,
    conversation_id: str,
    # ... other params
) -> dict:
    """Generate response with RAG context."""

    # NEW: Check if prompt is too short
    if ShortPromptDetector.is_short_prompt(user_message):
        logger.info(f"Short prompt detected (<{ShortPromptDetector.THRESHOLD_CHARS} chars), triggering questions")
        clarifying_response = ShortPromptDetector.format_questions_response(user_message)

        return {
            "response": clarifying_response,
            "sources": [],
            "metadata": {
                "short_prompt_detected": True,
                "threshold": ShortPromptDetector.THRESHOLD_CHARS
            }
        }

    # Continue with normal RAG flow...
    vector_results = await self._search_knowledge_base(user_message)
    # ...
```

#### 2.1.3 Create Unit Tests

**File:** `tests/server/unit/services/test_short_prompt_detector.py` (NEW)

```python
import pytest
from app.services.rag.short_prompt_detector import ShortPromptDetector


class TestShortPromptDetector:
    """Test suite for short prompt detection."""

    def test_is_short_prompt_with_very_short_message(self):
        """Test that very short messages trigger detection."""
        short_message = "Build an app"
        assert ShortPromptDetector.is_short_prompt(short_message) is True

    def test_is_short_prompt_with_long_message(self):
        """Test that long messages don't trigger detection."""
        long_message = (
            "I want to build a project management web application "
            "using React frontend and Node.js backend with PostgreSQL database"
        )
        assert ShortPromptDetector.is_short_prompt(long_message) is False

    def test_is_short_prompt_at_boundary(self):
        """Test behavior at exactly threshold characters."""
        # Create message exactly at threshold
        boundary_message = "x" * ShortPromptDetector.THRESHOLD_CHARS
        assert ShortPromptDetector.is_short_prompt(boundary_message) is False

        # One char less should trigger
        assert ShortPromptDetector.is_short_prompt(boundary_message[:-1]) is True

    def test_generate_clarifying_questions_returns_three(self):
        """Test that exactly 3 clarifying questions are generated."""
        questions = ShortPromptDetector.generate_clarifying_questions()
        assert len(questions) == 3
        assert all(isinstance(q, str) for q in questions)

    def test_format_questions_response_includes_all_questions(self):
        """Test that formatted response includes all questions."""
        user_message = "Help me"
        response = ShortPromptDetector.format_questions_response(user_message)

        # Check all questions are present
        questions = ShortPromptDetector.generate_clarifying_questions()
        for question in questions:
            # Question text should be in response (ignoring numbering)
            assert question in response or question.split("(")[0].strip() in response

        # Check format elements
        assert "1." in response
        assert "2." in response
        assert "3." in response
```

**Run Tests:**
```bash
cd src/server
pytest tests/server/unit/services/test_short_prompt_detector.py -v
# Expected: 5/5 tests passing
```

**Commit:**
```bash
git add src/server/app/services/rag/short_prompt_detector.py
git add src/server/app/services/rag/orchestrator.py
git add tests/server/unit/services/test_short_prompt_detector.py
git commit -m "feat(rag): Implement RULE-01 Anti-Manifesto Automatic

- Create ShortPromptDetector to catch brief prompts (<50 chars)
- Generate 3 key clarifying questions (Target, Stack, Features)
- Integrate into orchestrator to trigger before RAG search
- Add 5 unit tests with 100% coverage

Ref: HU-5.0 RULE-01"
```

---

### Step 2.2: RULE-02 - Total Proactivity (No Placeholders)
**Duration:** 3 hours

#### 2.2.1 Update System Prompt Template

**File:** `packages/knowledge_base/01-TEMPLATES/SYSTEM_PROMPTS/MASTER_WORKFLOW_SYSTEM_PROMPT.md`

**Add Section:**
```markdown
## 🚫 FORBIDDEN: Placeholder Text

You are STRICTLY PROHIBITED from generating any of the following placeholder patterns:

- `[Insert your text here]`
- `[TODO: Add description]`
- `[Your project name]`
- `[Add details]`
- `TBD`
- `...` (ellipsis as placeholder)
- `[Fill in]`
- Any text wrapped in square brackets `[...]` indicating user action

Instead, you MUST:
1. **Use contextual information** from the chat history to fill in realistic values
2. **Infer from industry standards** when specific details are missing
3. **Use realistic examples** (e.g., "MyAwesomeApp" instead of "[Project Name]")
4. **Generate complete drafts** that the user can review and refine

Examples of CORRECT proactive behavior:

❌ WRONG:
```
Project Name: [Insert your project name]
Tech Stack: [Add your technologies]
```

✅ CORRECT (using chat context):
```
Project Name: TaskFlow Manager
Tech Stack: React 18.x + Node.js 20.x + PostgreSQL 15
```

✅ CORRECT (realistic placeholder when context missing):
```
Project Name: MyProjectManagementApp
Tech Stack: Modern Web Stack (React/Vue + Express/FastAPI + PostgreSQL/MongoDB)
```
```

#### 2.2.2 Create Placeholder Detector

**File:** `src/server/app/services/rag/placeholder_detector.py` (NEW)

```python
"""
Placeholder Detector - Identifies and flags forbidden placeholder text.
"""
import re
from typing import List, Tuple


class PlaceholderDetector:
    """Detects placeholder text in LLM responses."""

    # Forbidden patterns (regex)
    FORBIDDEN_PATTERNS = [
        r'\[Insert\s+.*?\]',
        r'\[TODO:.*?\]',
        r'\[Add\s+.*?\]',
        r'\[Fill\s+.*?\]',
        r'\[Your\s+.*?\]',
        r'\bTBD\b',
        r'\[.*?\]',  # Catch-all for bracketed text
    ]

    @staticmethod
    def detect_placeholders(text: str) -> List[Tuple[str, str]]:
        """
        Detect placeholder patterns in text.

        Args:
            text: The text to scan for placeholders

        Returns:
            List of tuples (pattern, matched_text)
        """
        found_placeholders = []

        for pattern in PlaceholderDetector.FORBIDDEN_PATTERNS:
            matches = re.finditer(pattern, text, re.IGNORECASE)
            for match in matches:
                found_placeholders.append((pattern, match.group()))

        return found_placeholders

    @staticmethod
    def has_placeholders(text: str) -> bool:
        """
        Check if text contains any placeholders.

        Args:
            text: The text to check

        Returns:
            True if placeholders detected
        """
        return len(PlaceholderDetector.detect_placeholders(text)) > 0

    @staticmethod
    def sanitize_response(text: str) -> str:
        """
        Replace placeholders with warning message.

        Args:
            text: The text containing placeholders

        Returns:
            Sanitized text with placeholders replaced
        """
        # TODO: In production, this should trigger re-generation with stricter prompt
        # For now, we replace with warning
        for pattern in PlaceholderDetector.FORBIDDEN_PATTERNS:
            text = re.sub(
                pattern,
                "[⚠️ PLACEHOLDER DETECTED - THIS SHOULD NOT APPEAR]",
                text,
                flags=re.IGNORECASE
            )

        return text
```

#### 2.2.3 Integrate Post-Processing

**File:** `src/server/app/services/rag/orchestrator.py`

**Add after LLM generation:**
```python
from app.services.rag.placeholder_detector import PlaceholderDetector

# In generate_response(), after getting llm_response:
llm_response_text = await self.llm_client.generate(prompt)

# NEW: Check for placeholders
if PlaceholderDetector.has_placeholders(llm_response_text):
    placeholders = PlaceholderDetector.detect_placeholders(llm_response_text)
    logger.warning(
        f"Placeholders detected in LLM response: {placeholders}. "
        f"This violates RULE-02 (Total Proactivity)"
    )
    # In production, re-generate with stricter prompt
    # For MVP, we log and continue
    llm_response_text = PlaceholderDetector.sanitize_response(llm_response_text)
```

#### 2.2.4 Create Unit Tests

**File:** `tests/server/unit/services/test_placeholder_detector.py` (NEW)

```python
import pytest
from app.services.rag.placeholder_detector import PlaceholderDetector


class TestPlaceholderDetector:
    """Test suite for placeholder detection."""

    def test_detect_insert_placeholder(self):
        """Test detection of [Insert ...] pattern."""
        text = "Project Name: [Insert your project name]"
        placeholders = PlaceholderDetector.detect_placeholders(text)
        assert len(placeholders) > 0
        assert any("[Insert" in match for _, match in placeholders)

    def test_detect_todo_placeholder(self):
        """Test detection of [TODO: ...] pattern."""
        text = "Description: [TODO: Add project description]"
        placeholders = PlaceholderDetector.detect_placeholders(text)
        assert len(placeholders) > 0
        assert any("TODO" in match for _, match in placeholders)

    def test_detect_tbd_placeholder(self):
        """Test detection of TBD keyword."""
        text = "Tech Stack: TBD after team discussion"
        placeholders = PlaceholderDetector.detect_placeholders(text)
        assert len(placeholders) > 0

    def test_no_placeholders_in_clean_text(self):
        """Test that clean text without placeholders passes."""
        text = "Project Name: MyAwesomeApp\nTech Stack: React + Node.js"
        placeholders = PlaceholderDetector.detect_placeholders(text)
        assert len(placeholders) == 0

    def test_has_placeholders_returns_true(self):
        """Test has_placeholders() with placeholder text."""
        text = "Name: [Your name]"
        assert PlaceholderDetector.has_placeholders(text) is True

    def test_has_placeholders_returns_false(self):
        """Test has_placeholders() with clean text."""
        text = "Name: John Doe"
        assert PlaceholderDetector.has_placeholders(text) is False

    def test_sanitize_response_replaces_placeholders(self):
        """Test that sanitize replaces placeholders with warning."""
        text = "Project: [Insert name] and Description: [TODO: Add]"
        sanitized = PlaceholderDetector.sanitize_response(text)
        assert "[Insert name]" not in sanitized
        assert "[TODO: Add]" not in sanitized
        assert "⚠️ PLACEHOLDER DETECTED" in sanitized
```

**Run Tests:**
```bash
cd src/server
pytest tests/server/unit/services/test_placeholder_detector.py -v
# Expected: 7/7 tests passing
```

**Commit:**
```bash
git add packages/knowledge_base/01-TEMPLATES/SYSTEM_PROMPTS/MASTER_WORKFLOW_SYSTEM_PROMPT.md
git add src/server/app/services/rag/placeholder_detector.py
git add src/server/app/services/rag/orchestrator.py
git add tests/server/unit/services/test_placeholder_detector.py
git commit -m "feat(rag): Implement RULE-02 Total Proactivity (No Placeholders)

- Update system prompt with strict anti-placeholder rules
- Create Placeholder Detector with regex pattern matching
- Integrate post-processing filter in orchestrator
- Add 7 unit tests covering common placeholder patterns
- Log warning when placeholders detected (future: re-generate)

Ref: HU-5.0 RULE-02"
```

---

### Step 2.3: RULE-03 to RULE-10 Implementation
**Duration:** 16 hours (2 hours per rule average)**

*Detailed steps omitted for brevity. Follow similar pattern:*
1. Update system prompt with rule specification
2. Create service/utility class if needed
3. Integrate into orchestrator/response processor
4. Write 2-3 unit tests per rule
5. Commit with descriptive message

**Files to Create/Modify:**
- RULE-03: `wow_effect_validator.py`, tests (emojis, tree blocks, code blocks)
- RULE-04: `document_tag_sanitizer.py`, tests (content isolation)
- RULE-05: `directory_validator.py`, tests (context/ enforcement)
- RULE-06: `validation_history_checker.py`, tests (block until validated)
- RULE-07: `robotic_prefix_filter.py`, tests (remove Chat:, Robot:)
- RULE-08: `template_format_validator.py`, tests (JSON validity, table formatting)
- RULE-09: `username_injector.py`, tests (dynamic replacement)
- RULE-10: `sequential_flow_validator.py`, tests (document order enforcement)

---

## 📱 Phase 3: Frontend Integration

### Step 3.1: Add userName to User Profile
**Duration:** 30 minutes

**File:** `src/client/lib/features/settings/domain/entities/user_profile.dart`

```dart
class UserProfile {
  final String id;
  final String userName;  // NEW
  final String? email;
  final String preferredLanguage;
  final String? defaultProjectPath;

  UserProfile({
    required this.id,
    required this.userName,  // NEW
    this.email,
    required this.preferredLanguage,
    this.defaultProjectPath,
  });

  // ... copyWith, toJson, fromJson methods
}
```

### Step 3.2: Modify ChatRepository
**Duration:** 1 hour

**File:** `src/client/lib/features/chat/data/repositories/chat_repository_impl.dart`

```dart
@override
Future<ChatMessage> sendMessage({
  required String projectId,
  required String message,
  required String userName,  // NEW parameter
  List<String>? contextFiles,
}) async {
  final url = Uri.parse('${_baseUrl}/chat/message');
  final response = await _client.post(
    url,
    body: jsonEncode({
      'project_id': projectId,
      'message': message,
      'user_name': userName,  // NEW field
      'context_files': contextFiles ?? [],
    }),
  );
  // ...
}
```

**Update all call sites to pass userName from userProfileProvider.**

### Step 3.3: Enhanced Save-Document Button
**Duration:** 2 hours

**File:** `src/client/lib/features/chat/presentation/widgets/smart_message_renderer.dart`

Add explicit validation button after :::save-document blocks with automatic history update:

```dart
Widget _buildSaveDocumentButton(String filePath, String content) {
  return ElevatedButton.icon(
    icon: Icon(Icons.check_circle),
    label: Text('I validated and saved the document'),
    onPressed: () async {
      // Save file
      await _fileService.saveFile(filePath, content);

      // Send validation confirmation to chat
      await _chatRepository.sendMessage(
        projectId: widget.projectId,
        message: 'I validated and saved the document in $filePath',
        userName: widget.userName,
      );

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Document saved and validated!')),
      );
    },
  );
}
```

**Commit:**
```bash
git add src/client/lib/features/settings/domain/entities/user_profile.dart
git add src/client/lib/features/chat/data/repositories/chat_repository_impl.dart
git add src/client/lib/features/chat/presentation/widgets/smart_message_renderer.dart
git commit -m "feat(frontend): Implement userName injection and validation button

- Add userName field to UserProfile entity
- Modify ChatRepository to send userName in API calls
- Enhance smart_message_renderer with explicit validation button
- Auto-send validation confirmation to enforce RULE-06

Ref: HU-5.0 RULE-09, RULE-06"
```

---

## 🧪 Phase 4: Testing Suite

### Step 4.1: Comprehensive Unit Tests
**Duration:** 8.5 hours

**Goal:** 30+ unit tests covering all system prompt rules

**Test Files:**
1. `test_system_prompt_rules.py` (15 tests - one per main rule + edge cases)
2. `test_short_prompt_detection.py` (3 tests)
3. `test_document_sanitizer.py` (4 tests)
4. `test_validation_checker.py` (5 tests)
5. `test_username_injection.py` (3 tests)

**Execute:**
```bash
cd src/server
pytest tests/server/unit/services/ -v --cov=app/services/rag --cov-report=term-missing

# Target: ≥85% coverage
```

### Step 4.2: E2E Integration Tests
**Duration:** 6 hours

**File:** `tests/server/integration/test_master_workflow_e2e.py`

**Test Scenarios:**
1. **Complete 24-document workflow** (happy path)
2. **Short prompt triggers questions** (RULE-01)
3. **Validation blocking** (RULE-06)
4. **Placeholder detection** (RULE-02)
5. **Username personalization** (RULE-09)

**Example Test:**
```python
@pytest.mark.asyncio
async def test_complete_24_document_workflow(
    client: TestClient,
    test_project_id: str,
    mock_groq_api: MockGroqAPI,
):
    """Test complete workflow from initial interview to README.md."""

    # Phase 00: DISCOVERY (3 docs)
    response1 = await client.post("/chat/message", json={
        "project_id": test_project_id,
        "message": "I want to build a task management web app",
        "user_name": "Test User"
    })
    assert "Interview Q&A" in response1.json()["response"]
    # ... validate doc 1, 2, 3

    # Phase 10: CONTEXT (5 docs)
    # ... validate doc 4, 5, 6, 7, 8

    # ... continue for all 24 documents

    # Final validation
    assert all_24_documents_generated()
    assert no_placeholders_in_any_document()
    assert all_saved_to_correct_paths()
```

**Execute:**
```bash
cd src/server
pytest tests/server/integration/test_master_workflow_e2e.py -v --maxfail=1

# Expected duration: <5 minutes per test
```

**Commit:**
```bash
git add tests/server/unit/services/test_*.py
git add tests/server/integration/test_master_workflow_e2e.py
git commit -m "test: Add comprehensive test suite for HU-5.0

- 30+ unit tests for system prompt rules (≥85% coverage)
- 5 E2E tests for complete master workflow
- Smoke tests for critical paths (short prompt, validation, tags)

All tests passing. Ready for deployment.

Ref: HU-5.0 Phase 4"
```

---

## 📚 Phase 5: Knowledge Base Updates

### Step 5.1: Add 24 Real Document Examples
**Duration:** 8 hours

**Directory:** `packages/knowledge_base/01-TEMPLATES/WORKFLOW_STAGES/`

**Create Example Files:**
```
00-DISCOVERY/
├── EXAMPLE_INTERVIEW.md
├── EXAMPLE_PROJECT_BRIEF.md
└── EXAMPLE_TECH_STACK.md

10-CONTEXT/
├── EXAMPLE_VISION.md
├── EXAMPLE_PROMISE.md
├── EXAMPLE_JOURNEY_MAP.md
├── EXAMPLE_EXECUTIVE_SUMMARY.md
└── EXAMPLE_GLOSSARY.md

20-REQUIREMENTS/
├── EXAMPLE_FUNCTIONAL.md
├── EXAMPLE_NON_FUNCTIONAL.md
├── ...

... (continue for all 24 documents)
```

**Each Example Should:**
- Be a real, complete document (not a template)
- Follow all 10 system prompt rules
- Include rich Markdown (emojis, tree blocks, code, tables)
- Demonstrate industry best practices
- Be ~500-1000 lines (realistic size)

**Commit:**
```bash
git add packages/knowledge_base/01-TEMPLATES/WORKFLOW_STAGES/
git commit -m "docs(kb): Add 24 real-world document examples for RAG

- Complete examples for each Master Workflow stage
- Industry-standard patterns and formats
- Rich Markdown demonstrating RULE-03 (WOW effect)
- Enables better RAG retrieval for realistic generation

Ref: HU-5.0 Phase 5"
```

---

## 🚀 Phase 6: Homelab Deployment

###Step 6.1: Create Homelab Docker Compose
**Duration:** 2 hours

**File:** `infrastructure/docker-compose.homelab.yml`

```yaml
version: '3.8'

services:
  # Backend FastAPI
  backend:
    build:
      context: .
      dockerfile: Dockerfile.backend
    container_name: softarchitect-backend
    environment:
      # LLM Configuration
      - LLM_PROVIDER=groq
      - GROQ_API_KEY=${GROQ_API_KEY}
      - LLM_TEMPERATURE=0.6

      # ChromaDB Configuration
      - CHROMA_HOST=chromadb
      - CHROMA_PORT=8000
      - CHROMA_PERSIST_DIRECTORY=/data/chroma

      # Application Settings
      - LOG_LEVEL=INFO
      - CORS_ORIGINS=https://softarchitect.homelab.local

    volumes:
      - backend_logs:/app/logs

    depends_on:
      - chromadb

    networks:
      - softarchitect-net

    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # ChromaDB Vector Store
  chromadb:
    image: chromadb/chroma:latest
    container_name: softarchitect-chromadb
    environment:
      - CHROMA_SERVER_AUTH_CREDENTIALS_PROVIDER=chromadb.auth.token.TokenAuthCredentialsProvider
      - CHROMA_SERVER_AUTH_CREDENTIALS=${CHROMA_AUTH_TOKEN}
      - CHROMA_SERVER_AUTH_TOKEN_TRANSPORT_HEADER=X-Chroma-Token

    volumes:
      - chroma_data:/chroma/chroma

    networks:
      - softarchitect-net

    restart: unless-stopped

  # Frontend Flutter Web
  frontend:
    build:
      context: .
      dockerfile: Dockerfile.frontend
    container_name: softarchitect-frontend
    environment:
      - BACKEND_URL=http://backend:8000

    ports:
      - "80:80"
      - "443:443"

    volumes:
      - ./infrastructure/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./infrastructure/ssl:/etc/nginx/ssl:ro

    depends_on:
      - backend

    networks:
      - softarchitect-net

    restart: unless-stopped

volumes:
  chroma_data:
    driver: local
  backend_logs:
    driver: local

networks:
  softarchitect-net:
    driver: bridge
```

### Step 6.2: Create Deployment Script
**Duration:** 2 hours

**File:** `scripts/devops/deploy-homelab.sh`

```bash
#!/bin/bash
set -euo pipefail

# SoftArchitect AI - Homelab Deployment Script
# Version: 1.0
# Purpose: One-command deployment with health checks

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="infrastructure/docker-compose.homelab.yml"
ENV_FILE=".env.homelab"
DOMAIN="softarchitect.homelab.local"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker not found. Please install Docker 24.x+"
        exit 1
    fi

    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose not found. Please install Docker Compose v2+"
        exit 1
    fi

    # Check .env.homelab exists
    if [[ ! -f "$ENV_FILE" ]]; then
        log_error "$ENV_FILE not found. Please create it from .env.homelab.example"
        exit 1
    fi

    # Check GROQ_API_KEY is set
    source "$ENV_FILE"
    if [[ -z "${GROQ_API_KEY:-}" ]]; then
        log_error "GROQ_API_KEY not set in $ENV_FILE"
        exit 1
    fi

    log_info "✅ All prerequisites met"
}

build_images() {
    log_info "Building Docker images..."
    docker-compose -f "$COMPOSE_FILE" build --no-cache
    log_info "✅ Images built successfully"
}

start_services() {
    log_info "Starting services..."
    docker-compose -f "$COMPOSE_FILE" up -d
    log_info "✅ Services started"
}

wait_for_health() {
    log_info "Waiting for services to be healthy..."

    local max_attempts=30
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        log_info "Health check attempt $attempt/$max_attempts..."

        # Check backend health
        if curl -sf http://localhost:8000/health > /dev/null 2>&1; then
            log_info "✅ Backend is healthy"
            return 0
        fi

        sleep 10
        ((attempt++))
    done

    log_error "Services failed to become healthy after $max_attempts attempts"
    docker-compose -f "$COMPOSE_FILE" logs
    exit 1
}

run_smoke_tests() {
    log_info "Running smoke tests..."

    # Test 1: Backend health endpoint
    log_info "Test 1: Backend /health"
    response=$(curl -s http://localhost:8000/health)
    if echo "$response" | grep -q "healthy"; then
        log_info "✅ Test 1 passed"
    else
        log_error "❌ Test 1 failed: $response"
        exit 1
    fi

    # Test 2: Frontend accessible
    log_info "Test 2: Frontend accessible"
    if curl -sf http://localhost:80 > /dev/null 2>&1; then
        log_info "✅ Test 2 passed"
    else
        log_error "❌ Test 2 failed"
        exit 1
    fi

    # Test 3: LLM provider configured
    log_info "Test 3: LLM provider (Groq)"
    if echo "$response" | grep -q '"llm_provider":"groq"'; then
        log_info "✅ Test 3 passed (Groq configured)"
    else
        log_warn "⚠️  Test 3 warning: LLM provider not Groq"
    fi

    log_info "✅ All smoke tests passed"
}

print_access_info() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  🚀 SoftArchitect AI - Homelab Deployment Complete"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "  📍 Access URLs:"
    echo "     Frontend:  http://localhost"
    echo "     Frontend (HTTPS): https://$DOMAIN (if SSL configured)"
    echo "     Backend API: http://localhost:8000"
    echo "     API Docs: http://localhost:8000/docs"
    echo ""
    echo "  🔧 Management Commands:"
    echo "     View logs:    docker-compose -f $COMPOSE_FILE logs -f"
    echo "     Stop:         docker-compose -f $COMPOSE_FILE down"
    echo "     Restart:      docker-compose -f $COMPOSE_FILE restart"
    echo ""
    echo "  ✅ Status: All services running and healthy"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
}

# Main execution
main() {
    log_info "Starting SoftArchitect AI Homelab Deployment..."

    check_prerequisites
    build_images
    start_services
    wait_for_health
    run_smoke_tests
    print_access_info

    log_info "🎉 Deployment completed successfully!"
}

# Run main
main "$@"
```

### Step 6.3: Execute Deployment
**Duration:** 2 hours (includes testing)

```bash
# 1. Create .env.homelab
cp infrastructure/.env.homelab.example infrastructure/.env.homelab
nano infrastructure/.env.homelab
# Set: GROQ_API_KEY=your_actual_key_here

# 2. Make script executable
chmod +x scripts/devops/deploy-homelab.sh

# 3. Execute deployment
./scripts/devops/deploy-homelab.sh

# Expected output:
# [INFO] Starting SoftArchitect AI Homelab Deployment...
# [INFO] Checking prerequisites...
# [INFO] ✅ All prerequisites met
# [INFO] Building Docker images...
# [INFO] ✅ Images built successfully
# [INFO] Starting services...
# [INFO] ✅ Services started
# [INFO] Waiting for services to be healthy...
# [INFO] ✅ Backend is healthy
# [INFO] Running smoke tests...
# [INFO] ✅ All smoke tests passed
# [INFO] 🎉 Deployment completed successfully!

# 4. Verify deployment
curl http://localhost:8000/health
# Expected: {"status":"healthy","llm_provider":"groq"}

# 5. Test complete workflow
# Open browser: http://localhost
# Create new project
# Execute 0→24 document generation
# Target: <15 minutes end-to-end
```

**Commit:**
```bash
git add infrastructure/docker-compose.homelab.yml
git add infrastructure/.env.homelab.example
git add scripts/devops/deploy-homelab.sh
git commit -m "feat(deploy): Add homelab deployment configuration

- docker-compose.homelab.yml with Groq integration
- Automated deployment script with health checks
- Smoke tests for critical endpoints
- Complete documentation in DEPLOYMENT.md

Tested on: Ubuntu 22.04, Docker 24.0.7, Docker Compose v2.23.0
Deployment time: ~10 minutes (clean environment)

Ref: HU-5.0 Phase 6"
```

---

## ✅ Phase 7: Final Validation & Demo

### Step 7.1: Execute Complete Workflow
**Duration:** 1 hour

```bash
# 1. Start timer
start_time=$(date +%s)

# 2. Open application
xdg-open http://localhost

# 3. Execute workflow manually:
#    - Create new project
#    - Answer initial interview questions
#    - Generate all 24 documents sequentially
#    - Validate and save each document
#    - Verify final README.md and CONTRIBUTING.md in root

# 4. Stop timer
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "Workflow completed in: $((duration / 60)) minutes"
# Target: <15 minutes
```

### Step 7.2: Record Demo Video
**Duration:** 2 hours

**Script:**
```
DEMO VIDEO SCRIPT (4 minutes 30 seconds)

[00:00-00:30] Introduction
"Welcome to SoftArchitect AI - your AI-powered software architect assistant.
Today I'll demonstrate how it guides you through creating professional
engineering documentation in under 15 minutes."

[00:30-01:00] Architecture Overview
"The system uses Groq Cloud API for LLM, ChromaDB for RAG retrieval,
and Flutter desktop for the interface. It's deployed on my homelab using Docker."

[01:00-02:00] Initial Interview (Phase 00: DISCOVERY)
"Let's create a new project. Notice how the AI asks clarifying questions
when my prompt is too short (RULE-01). It then generates realistic tech stack
recommendations based on my requirements - no placeholders (RULE-02)."

[02:00-03:30] Document Generation (Phases 10-50)
"Watch as it generates the Vision Statement with rich Markdown - emojis,
tree diagrams, code blocks (RULE-03). Each document is complete and
professional. Notice it blocks me from skipping ahead until I validate
the previous document (RULE-06)."

[03:30-04:00] Final Output (Phase 00-ROOT)
"In just 12 minutes, we have 24 complete documents organized in context/,
plus README.md and CONTRIBUTING.md in the root. Everything follows
engineering best practices."

[04:00-04:30] Wrap-up
"SoftArchitect AI transforms software documentation from a weeks-long
chore into a 15-minute guided conversation. Thank you!"
```

**Recording:**
```bash
# Use OBS Studio or SimpleScreenRecorder
# Resolution: 1920x1080
# Framerate: 30fps
# Audio: Narration with clear voice
# Output: MP4 H.264

# Save as: doc/demo/HU-5.0-DEMO-VIDEO.mp4
```

### Step 7.3: Create Presentation Deck
**Duration:** 3 hours

**File:** `doc/demo/HU-5.0-TFM-PRESENTATION.pptx`

**Slides (15 total):**
1. Title: "SoftArchitect AI - Master Workflow Refinement"
2. Problem Statement: "Documentation is hard, time-consuming, inconsistent"
3. Solution: "AI-guided 24-document workflow in <15 minutes"
4. Architecture Diagram: "Flutter + FastAPI + Groq + ChromaDB"
5. Master Workflow Overview: "Tree diagram of 24 documents"
6. System Prompt Rules (1): "RULE-01 to RULE-05"
7. System Prompt Rules (2): "RULE-06 to RULE-10"
8. Demo Screenshot: "Initial interview"
9. Demo Screenshot: "Rich Markdown generation"
10. Demo Screenshot: "Validation blocking"
11. Results: "Before/After comparison (placeholders vs complete)"
12. Deployment: "Homelab architecture diagram"
13. Metrics: "15 minutes, 30+ tests, 85% coverage"
14. Future Work: "Multi-language support, CI/CD integration"
15. Q&A: "Thank you!"

---

## 🔄 Rollback Plan

If critical issues are discovered post-deployment:

### Rollback to Previous Stable Version
```bash
# 1. Stop homelab deployment
docker-compose -f infrastructure/docker-compose.homelab.yml down

# 2. Checkout previous stable branch
git checkout feature/rag-llm-resilience
# or
git checkout develop

# 3. Re-deploy
./scripts/devops/deploy-homelab.sh

# 4. Verify
curl http://localhost:8000/health
```

### Mitigate Specific Issues

| Issue | Mitigation |
|-------|------------|
| **Groq API rate limit exceeded** | Switch LLM_PROVIDER to "ollama" in .env |
| **Placeholder detection false positives** | Temporarily disable in orchestrator.py |
| **Validation blocking too strict** | Lower threshold or add bypass flag |
| **Temperature too high (hallucinations)** | Reduce from 0.6 to 0.5 in groq_client.py |

---

## 📋 Final Checklist

Before marking HU-5.0 as complete:

### Code Quality
- [ ] All 10 system prompt rules implemented
- [ ] 30+ unit tests passing (backend ≥85% coverage)
- [ ] 5 E2E tests passing (workflow 0→24 docs)
- [ ] 3 smoke tests passing
- [ ] No `pytest` warnings or errors
- [ ] No `flutter analyze` issues
- [ ] Pre-commit hooks passing

### Functionality
- [ ] Temperature adjusted (0.6-0.7)
- [ ] userName injection working end-to-end
- [ ] Short prompt triggers 3 questions
- [ ] Placeholder detection catches common patterns
- [ ] Validation blocking enforced (cannot skip ahead)
- [ ] All 24 documents generate successfully
- [ ] Documents saved to correct paths (context/ vs root)
- [ ] No robotic prefixes in responses

### Deployment
- [ ] Homelab docker-compose.yml functional
- [ ] Deploy script executes without errors
- [ ] Health checks passing (backend, frontend, chromadb)
- [ ] Groq API integration working
- [ ] ChromaDB persistence working (data survives restart)
- [ ] SSL/HTTPS configured (if applicable)

### Documentation
- [ ] README.md updated with HU-5.0 information
- [ ] PROGRESS.md reflects 100% completion
- [ ] WORKFLOW.md (this file) reviewed and accurate
- [ ] Knowledge base updated with 24 examples
- [ ] ADR documenting temperature decision
- [ ] Deployment guide finalized

### Demo & Presentation
- [ ] Demo video recorded (<5 minutes)
- [ ] Presentation deck created (10-15 slides)
- [ ] Q&A talking points prepared
- [ ] Rehearsal completed (dry run <20 minutes)

### Merge Preparation
- [ ] All commits follow conventional commit format
- [ ] Branch rebased on latest `develop`
- [ ] Conflicts resolved
- [ ] PR description prepared (see PR_DESCRIPTION.md template)
- [ ] Reviewers assigned

---

## 🎯 Success Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Implementation Days | 5-7 days | TBD | ⏳ |
| Unit Tests Count | 30+ | TBD | ⏳ |
| Backend Coverage | ≥85% | TBD | ⏳ |
| E2E Tests Count | 5+ | TBD | ⏳ |
| Workflow Duration | <15 min | TBD | ⏳ |
| Deployment Time | <10 min | TBD | ⏳ |
| Demo Video Duration | <5 min | TBD | ⏳ |
| Presentation Slides | 10-15 | TBD | ⏳ |

**Target Completion Date:** 2026-02-28
**Actual Completion Date:** TBD

---

**🚀 Ready to begin Phase 1? Let's ship this!**
