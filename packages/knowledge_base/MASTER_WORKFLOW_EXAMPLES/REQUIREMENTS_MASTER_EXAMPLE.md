# 📋 Requirements Master - SoftArchitect AI

> **Document Type:** Consolidated Requirements Specification
> **Last Updated:** 2025-01-15
> **Product Owner:** @ArchitectZero
> **Status:** ✅ Baselined
> **Version:** 2.3.0

---

## 📖 Table of Contents

- [Document Purpose](#document-purpose)
- [Functional Requirements](#functional-requirements)
- [Non-Functional Requirements](#non-functional-requirements)
- [Quality Attributes](#quality-attributes)
- [Constraints & Assumptions](#constraints--assumptions)
- [Requirements Traceability Matrix](#requirements-traceability-matrix)
- [Prioritization (MoSCoW)](#prioritization-moscow)
- [Acceptance Criteria](#acceptance-criteria)
- [Requirements Verification](#requirements-verification)

---

## 📋 Generation Metadata

> **Order:** 10/24 | **Phase:** 2 - Requirements | **Duration:** ~45 mins
> **Prerequisites:** USER_STORIES_MASTER, Phase 1 complete
> **Generates:** SECURITY_PRIVACY_POLICY → COMPLIANCE_MATRIX

**Purpose:** Consolidate all functional and non-functional requirements.

---

## 🎯 Document Purpose

This **Requirements Master** consolidates all functional, non-functional, and quality requirements for SoftArchitect AI into a single source of truth.

### Scope

**In Scope:**
- Project management features
- RAG-powered AI assistance
- Master Workflow document generation
- Local-first architecture
- Desktop UI (Flutter)

**Out of Scope:**
- Web-based deployment
- Multi-user collaboration (team features)
- Mobile apps (iOS/Android)
- Cloud-hosted version

---

## ⚙️ Functional Requirements

### FR-001: Project Management

#### FR-001.1: Create Project
**Description:** User can create a new software project.

**Preconditions:**
- Application launched

**Inputs:**
- Project name (3-50 characters, alphanumeric + spaces/hyphens)
- Tech stack selection (backend, frontend, database, deployment)

**Process:**
1. Validate project name (uniqueness, allowed characters)
2. Generate unique project ID (UUID)
3. Create project directory: `~/.soft-architect-ai/projects/{project-id}/`
4. Save project metadata: `project.json`
5. Initialize empty documents list

**Outputs:**
- New project created
- Project dashboard displayed

**Acceptance Criteria:**
```gherkin
Given the user is on the dashboard
When they click "Create New Project"
And enter name "MyApp" and select tech stack "Python + Flutter"
Then a new project "MyApp" appears in the project list
And the project ID is a valid UUID
And the project directory exists on disk
```

**Priority:** 🔴 Must Have (P0)

---

#### FR-001.2: List Projects
**Description:** User can view all their projects.

**Inputs:** None

**Process:**
1. Scan `~/.soft-architect-ai/projects/` directory
2. Load project metadata (`project.json`) for each subdirectory
3. Sort by last modified date (descending)

**Outputs:**
- List of projects with:
  - Project name
  - Tech stack
  - Creation date
  - Progress (X/24 documents)

**Acceptance Criteria:**
```gherkin
Given the user has 3 projects (A, B, C)
When they navigate to the dashboard
Then all 3 projects are displayed
And projects are sorted by last modified date
And each project shows name, tech stack, creation date, and progress
```

**Priority:** 🔴 Must Have (P0)

---

#### FR-001.3: Open Project
**Description:** User can open an existing project.

**Inputs:**
- Project ID (selected from list)

**Process:**
1. Load project metadata
2. Load all generated documents
3. Display project workspace (document list, actions)

**Outputs:**
- Project workspace view

**Acceptance Criteria:**
```gherkin
Given the user has a project "MyApp"
When they click on "MyApp" in the project list
Then the project workspace opens
And all generated documents are visible
And the project name is displayed in the header
```

**Priority:** 🔴 Must Have (P0)

---

#### FR-001.4: Delete Project
**Description:** User can permanently delete a project.

**Inputs:**
- Project ID
- Confirmation (prevent accidental deletion)

**Process:**
1. Show confirmation dialog: "Delete 'ProjectName'? This cannot be undone."
2. If confirmed:
   - Delete project directory (`rm -rf ~/.soft-architect-ai/projects/{id}/`)
   - Remove from ChromaDB (if documents ingested)
3. Refresh project list

**Outputs:**
- Project deleted
- Confirmation message

**Acceptance Criteria:**
```gherkin
Given the user has a project "MyApp"
When they right-click "MyApp" and select "Delete"
And confirm the deletion in the dialog
Then "MyApp" is removed from the project list
And the project directory is deleted from disk
```

**Priority:** 🟡 Should Have (P1)

---

### FR-002: Interview & Configuration

#### FR-002.1: Conduct Interview
**Description:** AI conducts structured interview to gather project context.

**Inputs:**
- Project ID

**Process:**
1. Load interview template (10 questions)
2. Display questions one at a time
3. Validate answers (non-empty, min 10 characters)
4. Save answers to `project.json`

**Questions:**
1. What type of application? (Web, Mobile, Desktop, API, Data Pipeline)
2. Primary tech stack? (e.g., Python + React, Java + Angular)
3. Main features? (List 3-5 features)
4. Target users? (Demographics, pain points)
5. Biggest technical concern? (Scalability, security, UX, performance)
6. Database requirements? (Relational, NoSQL, none)
7. Authentication method? (OAuth, JWT, none)
8. Deployment target? (Cloud, on-premise, hybrid)
9. Team size? (Solo, small <5, medium 5-20, large >20)
10. Timeline? (Weeks, months, years)

**Outputs:**
- Interview Q&A saved
- Interview document generated (`INTERVIEW.md`)

**Acceptance Criteria:**
```gherkin
Given a new project "MyApp"
When the user starts the interview
Then 10 questions are presented one at a time
And the user provides answers to all questions
Then the interview is saved
And the first document "INTERVIEW.md" is generated
```

**Priority:** 🔴 Must Have (P0)

---

### FR-003: Master Workflow

#### FR-003.1: Generate Document
**Description:** AI generates a project document based on template + interview context.

**Inputs:**
- Document type (e.g., API_INTERFACE_CONTRACT)
- Project context (interview answers, previous documents)

**Process:**
1. Load template: `01-TEMPLATES/{category}/{type}.template.md`
2. Construct prompt:
   ```
   System: You are an expert software architect.
   User: Generate an API contract for a project:
   - Type: Web Application
   - Tech Stack: Python FastAPI
   - Main Features: User auth, project management, RAG queries
   - Context: {interview_answers}

   Fill this template: {template_content}
   ```
3. Send to LLM (Ollama or Groq)
4. Validate output (no unfilled placeholders)
5. Save document: `~/.soft-architect-ai/projects/{id}/documents/{type}.md`

**Outputs:**
- Document generated
- Document added to project's document list
- Progress updated (e.g., 5/24 → 6/24)

**Acceptance Criteria:**
```gherkin
Given a project with interview completed
When the user clicks "Generate API Contract"
Then the AI generates the document in <10 seconds
And the document has no placeholder text ({{VARIABLE}})
And the document appears in the project's document list
And the progress bar updates
```

**Priority:** 🔴 Must Have (P0)

---

#### FR-003.2: View Document
**Description:** User can read a generated document.

**Inputs:**
- Document ID

**Process:**
1. Load document content from disk
2. Render Markdown to HTML
3. Display in viewer pane

**Outputs:**
- Document displayed with formatted Markdown

**Acceptance Criteria:**
```gherkin
Given a project with "API Contract" generated
When the user clicks on "API Contract" in the document list
Then the document content is displayed
And Markdown is rendered (headings, tables, code blocks)
And the user can scroll through the document
```

**Priority:** 🔴 Must Have (P0)

---

#### FR-003.3: Edit Document
**Description:** User can manually edit a generated document.

**Inputs:**
- Document ID
- Edited content (Markdown)

**Process:**
1. Open document in editor mode
2. Allow text editing (Markdown syntax highlighting)
3. Auto-save on change (every 2 seconds)

**Outputs:**
- Document updated on disk
- "Auto-saved" indicator shown

**Acceptance Criteria:**
```gherkin
Given a project with "API Contract" generated
When the user clicks "Edit" on the document
Then an editable text area appears
And the user can modify the content
Then the document is auto-saved after 2 seconds
And "Last saved: 2s ago" is displayed
```

**Priority:** 🟡 Should Have (P1)

---

#### FR-003.4: Export Document
**Description:** User can export a single document as Markdown or PDF.

**Inputs:**
- Document ID
- Format (Markdown, PDF)

**Process:**
1. Load document content
2. If Markdown: Copy file to user-selected location
3. If PDF: Convert Markdown → HTML → PDF (using Pandoc or similar)
4. Save to user-selected location

**Outputs:**
- File saved
- Success notification

**Acceptance Criteria:**
```gherkin
Given a project with "API Contract" generated
When the user clicks "Export" → "PDF"
And selects save location
Then a PDF file is created
And the file opens in the default PDF viewer
```

**Priority:** 🟢 Could Have (P2)

---

### FR-004: RAG Knowledge Base

#### FR-004.1: Ingest Documents
**Description:** User can import existing documentation into the RAG knowledge base.

**Inputs:**
- File paths or folder (Markdown, PDF, TXT files)

**Process:**
1. Read files from disk
2. Extract text (use `pdfplumber` for PDFs)
3. Chunk text (1000 characters with 200-character overlap)
4. Generate embeddings (Ollama `nomic-embed-text`)
5. Store in ChromaDB collection

**Outputs:**
- X documents ingested
- Success notification

**Acceptance Criteria:**
```gherkin
Given the user has a folder with 10 Markdown files
When they click "Import Documentation"
And select the folder
Then 10 files are ingested into the knowledge base
And embeddings are stored in ChromaDB
And "10 documents indexed successfully" message appears
```

**Priority:** 🔴 Must Have (P0)

---

#### FR-004.2: Query Knowledge Base
**Description:** User can ask questions and get answers from the RAG system.

**Inputs:**
- Query text (natural language question)

**Process:**
1. Generate query embedding
2. Perform similarity search in ChromaDB (top 5 results)
3. Construct augmented prompt:
   ```
   Context:
   {document_1_content}
   {document_2_content}
   ...

   Question: {user_query}

   Answer based on the context above.
   ```
4. Send to LLM
5. Stream response to UI

**Outputs:**
- AI-generated answer
- Source documents cited (with links)

**Acceptance Criteria:**
```gherkin
Given the user has ingested "Clean Architecture" documentation
When they type "What is the dependency rule?"
And press Enter
Then the AI responds with an answer in <2 seconds
And the answer cites source documents
And the answer is factually correct
```

**Priority:** 🔴 Must Have (P0)

---

### FR-005: Settings & Configuration

#### FR-005.1: Configure LLM Provider
**Description:** User can choose between Ollama (local) and Groq (cloud).

**Inputs:**
- Provider selection (Ollama, Groq, OpenAI)
- API key (if cloud provider)

**Process:**
1. Display settings panel
2. User selects provider
3. If Groq/OpenAI: Prompt for API key
4. Validate API key (test request)
5. Encrypt and save API key (AES-256)

**Outputs:**
- Settings saved
- Provider active

**Acceptance Criteria:**
```gherkin
Given the user is in Settings
When they select "Groq" as LLM provider
And enter API key "gsk_abc123..."
And click Save
Then the settings are validated
And the API key is encrypted
And future queries use Groq
```

**Priority:** 🟡 Should Have (P1)

---

## 🏗️ Non-Functional Requirements

### NFR-001: Performance

| Requirement | Target | Measurement Method |
|-------------|--------|-------------------|
| **NFR-001.1:** UI responsiveness | <200ms | Button click → visual feedback |
| **NFR-001.2:** RAG query latency (Ollama) | <2s | Query submission → first token streamed |
| **NFR-001.3:** RAG query latency (Groq) | <1s | Query submission → first token streamed |
| **NFR-001.4:** Document generation | <10s | Request → saved file |
| **NFR-001.5:** Application startup | <3s | Launch → UI ready |
| **NFR-001.6:** Project load time | <1s | Open project → workspace displayed |

**Verification:**
```python
# Automated performance test
def test_rag_query_latency():
    start = time.perf_counter()
    response = rag_service.query("Clean Architecture principles")
    latency = time.perf_counter() - start
    assert latency < 2.0, f"Query too slow: {latency:.2f}s"
```

---

### NFR-002: Scalability

| Requirement | Target | Notes |
|-------------|--------|-------|
| **NFR-002.1:** Max projects per user | 100 | Tested with 100 mock projects |
| **NFR-002.2:** Max documents per project | 50 | Beyond 24 Master Workflow docs |
| **NFR-002.3:** RAG knowledge base size | 10,000 documents | ~50MB text corpus |
| **NFR-002.4:** Max concurrent users | 1 | Single-user local application |

---

### NFR-003: Reliability

| Requirement | Target | Priority |
|-------------|--------|----------|
| **NFR-003.1:** Uptime | 99% (excluding crashes) | 🔴 P0 |
| **NFR-003.2:** Data loss prevention | 0% (auto-save every 2s) | 🔴 P0 |
| **NFR-003.3:** Crash recovery | Graceful (last state restored) | 🟡 P1 |
| **NFR-003.4:** Offline capability | 100% (no internet required for Ollama) | 🔴 P0 |

**Verification:**
```bash
# Simulate crash
$ kill -9 $(pidof soft_architect_ai)

# Restart app
$ ./soft_architect_ai

# Expected: All unsaved data from last 2s is present
```

---

### NFR-004: Security

| Requirement | Description | Priority |
|-------------|-------------|----------|
| **NFR-004.1:** Encryption at rest | AES-256 for API keys | 🔴 P0 |
| **NFR-004.2:** No plaintext secrets | No hardcoded keys in code | 🔴 P0 |
| **NFR-004.3:** Input validation | All user inputs sanitized | 🔴 P0 |
| **NFR-004.4:** HTTPS-only | No HTTP requests (except localhost) | 🔴 P0 |
| **NFR-004.5:** Dependency scanning | Automated CVE checks (Dependabot) | 🟡 P1 |

---

### NFR-005: Usability

| Requirement | Description | Priority |
|-------------|-------------|----------|
| **NFR-005.1:** Keyboard navigation | All features accessible via keyboard | 🔴 P0 |
| **NFR-005.2:** Screen reader support | ARIA labels, semantic HTML | 🟡 P1 |
| **NFR-005.3:** Color contrast | WCAG 2.1 AA (4.5:1 ratio) | 🟡 P1 |
| **NFR-005.4:** Error messages | Clear, actionable guidance | 🔴 P0 |
| **NFR-005.5:** Undo/Redo | For document editing | 🟢 P2 |

---

### NFR-006: Maintainability

| Requirement | Description | Priority |
|-------------|-------------|----------|
| **NFR-006.1:** Code coverage | ≥85% for core logic | 🔴 P0 |
| **NFR-006.2:** Test pyramid | 60% unit, 30% integration, 10% E2E | 🔴 P0 |
| **NFR-006.3:** Documentation | All public APIs documented (docstrings/DartDoc) | 🔴 P0 |
| **NFR-006.4:** Code style | Black (Python), dart format (Flutter) | 🔴 P0 |
| **NFR-006.5:** Dependency freshness | Update dependencies quarterly | 🟡 P1 |

---

### NFR-007: Portability

| Requirement | Target | Priority |
|-------------|--------|----------|
| **NFR-007.1:** Supported OS | Linux (Ubuntu 20.04+), macOS 12+, Windows 10+ | 🔴 P0 |
| **NFR-007.2:** Flutter version | 3.24.0+ | 🔴 P0 |
| **NFR-007.3:** Python version | 3.12+ | 🔴 P0 |
| **NFR-007.4:** Docker version | 24.0+ (for ChromaDB) | 🔴 P0 |

---

## 💎 Quality Attributes

### QA-001: Privacy

**Description:** User data never leaves the local machine (unless explicitly opted into cloud LLM).

**Evidence:**
- No telemetry code (`grep -r "analytics" src/` → 0 results)
- No cloud sync
- No external API calls (except opt-in Groq/OpenAI)

**Verification:**
```bash
# Run app in isolated network
$ sudo iptables -A OUTPUT -j DROP  # Block all outbound traffic
$ ./soft_architect_ai

# Expected: App works fully (project creation, RAG with Ollama)
```

---

### QA-002: Latency

**Description:** Fast responses create delightful UX.

**Targets:** See NFR-001 (Performance)

**Optimization Strategies:**
- Lazy loading (don't load all projects on startup)
- Caching (cache embeddings, avoid re-computation)
- Streaming (stream LLM responses token-by-token)

---

### QA-003: Learnability

**Description:** New users can complete their first project setup in <30 minutes.

**Onboarding Flow:**
1. Install app (5 min)
2. Start Docker (ChromaDB) (2 min)
3. Create first project (1 min)
4. Complete interview (5 min)
5. Generate first 5 documents (10 min)
6. Query RAG system (2 min)

**Total:** 25 minutes

**Measurement:**
- User testing with 10 new users
- Track time-to-first-success
- Target: 90% complete in <30 minutes

---

## 🔒 Constraints & Assumptions

### Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| **C-001:** Single-user application | No collaboration features | Future: Implement multi-user in v2.0 |
| **C-002:** Desktop-only (no web) | Cannot run in browser | Acceptable trade-off (local-first) |
| **C-003:** Requires Docker | Barrier for some users | Provide pre-built binaries |
| **C-004:** English-only (v1.0) | Excludes non-English speakers | Roadmap: i18n in v1.5 |

### Assumptions

| Assumption | Verification | Risk if Wrong |
|------------|--------------|---------------|
| **A-001:** Users have 8GB+ RAM | Check system requirements | App crashes on low-memory systems |
| **A-002:** Users are developers | Survey audience | UX too technical for non-devs |
| **A-003:** Ollama models available | Check model availability | RAG fails if model not pulled |
| **A-004:** Users trust local AI | User interviews | Privacy concerns drive users to cloud LLMs |

---

## 🔗 Requirements Traceability Matrix

### FR → Test Mapping

| Requirement | Test Case | Status |
|-------------|-----------|--------|
| FR-001.1 | `test_create_project.py` | ✅ Passing |
| FR-001.2 | `test_list_projects.py` | ✅ Passing |
| FR-001.3 | `test_open_project.py` | ✅ Passing |
| FR-001.4 | `test_delete_project.py` | ✅ Passing |
| FR-002.1 | `test_interview_flow.py` | ✅ Passing |
| FR-003.1 | `test_generate_document.py` | ⚠️ Flaky |
| FR-003.2 | `test_view_document.py` | ✅ Passing |
| FR-003.3 | `test_edit_document.py` | ✅ Passing |
| FR-003.4 | `test_export_document.py` | ❌ Not Implemented |
| FR-004.1 | `test_ingest_documents.py` | ✅ Passing |
| FR-004.2 | `test_rag_query.py` | ✅ Passing |
| FR-005.1 | `test_configure_llm.py` | ✅ Passing |

### NFR → Metric Mapping

| Requirement | Metric | Target | Current | Status |
|-------------|--------|--------|---------|--------|
| NFR-001.1 | UI responsiveness | <200ms | 120ms | ✅ |
| NFR-001.2 | RAG latency (Ollama) | <2s | 1.3s | ✅ |
| NFR-001.3 | RAG latency (Groq) | <1s | 0.6s | ✅ |
| NFR-003.1 | Uptime | 99% | 97% | ⚠️ |
| NFR-006.1 | Code coverage | ≥85% | 88% | ✅ |

---

## 🎯 Prioritization (MoSCoW)

### Must Have (P0) - MVP Release

**Features:**
- FR-001: Project Management (create, list, open, delete)
- FR-002: Interview
- FR-003: Document generation (24 documents)
- FR-004: RAG (ingest, query)

**Non-Functional:**
- NFR-001: Performance targets
- NFR-003: Reliability (offline mode)
- NFR-004: Security (encryption, validation)

**Target Date:** 2025-02-15 (4 weeks)

---

### Should Have (P1) - v1.1 Release

**Features:**
- FR-003.3: Document editing
- FR-005: LLM provider configuration (Groq/OpenAI)

**Non-Functional:**
- NFR-005: Usability (keyboard nav, screen reader)

**Target Date:** 2025-03-30 (6 weeks after MVP)

---

### Could Have (P2) - v1.2 Release

**Features:**
- FR-003.4: Document export (PDF)
- User preferences (theme, font size)

**Non-Functional:**
- NFR-005.5: Undo/Redo

**Target Date:** 2025-05-15 (8 weeks after v1.1)

---

### Won't Have (Future)

**Features:**
- Multi-user collaboration
- Web-based deployment
- Mobile apps
- Real-time co-editing

**Reason:** Out of scope for local-first architecture

---

## ✅ Acceptance Criteria

### Definition of Done (DoD)

**Feature is done when:**
1. ✅ Code implemented
2. ✅ Unit tests written (≥90% coverage)
3. ✅ Integration test written (if applicable)
4. ✅ Documentation updated (user guide + API docs)
5. ✅ Code reviewed (1 approval)
6. ✅ Manual testing passed
7. ✅ Performance benchmark met (if applicable)
8. ✅ Accessibility checked (WCAG 2.1)
9. ✅ Security reviewed (no hardcoded secrets)
10. ✅ Merged to `develop` branch

### User Story Acceptance Template

```gherkin
Feature: {Feature Name}

  Scenario: {Specific Use Case}
    Given {precondition}
    When {user action}
    Then {expected outcome}
    And {additional verification}

  Scenario: {Edge Case}
    Given {edge case setup}
    When {edge case trigger}
    Then {graceful handling}
```

---

## 🧪 Requirements Verification

### Verification Methods

| Method | When to Use | Example |
|--------|-------------|---------|
| **Inspection** | Design-time verification | Code review checks for hardcoded secrets |
| **Analysis** | Static verification | Pylance type checks prevent runtime errors |
| **Test** | Runtime verification | Unit test verifies RAG query returns results |
| **Demo** | User acceptance | Product owner approves feature in sprint review |

### Verification Evidence

**FR-001.1 (Create Project):**
- Test: `test_create_project.py` (✅ 5/5 assertions pass)
- Demo: Video recording of project creation flow
- Analysis: Type hints ensure `ProjectName` validation

**NFR-001.2 (RAG Latency):**
- Test: `test_rag_query_performance.py` (✅ 100/100 queries <2s)
- Analysis: Profiler shows 80% time in embedding, 20% in LLM
- Demo: Live demo of 1.3s query response

---

## 📞 Stakeholders

| Role | Name | Responsibilities |
|------|------|------------------|
| **Product Owner** | @ArchitectZero | Prioritization, requirements approval |
| **Tech Lead** | @ArchitectZero | NFR definition, architecture |
| **QA Lead** | @TestTeam | Acceptance criteria, testing strategy |
| **Users** | Community | Feedback, bug reports, feature requests |

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-08-01 | Initial requirements (FR-001 to FR-003) |
| 2.0.0 | 2024-11-15 | Added RAG requirements (FR-004), NFRs |
| 2.1.0 | 2024-12-20 | Added traceability matrix, MoSCoW prioritization |
| 2.2.0 | 2025-01-10 | Added quality attributes, constraints |
| 2.3.0 | 2025-01-15 | Added acceptance criteria, verification methods |

---

> **"A requirement is not understood until it is tested."**
> — Grady Booch
