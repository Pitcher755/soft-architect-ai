# 🎟️ HU-5.0: AI Architect Refinement (Groq Era) & Complete Master Workflow

> **Status:** 🚧 In Progress
> **Priority:** 🔴 Critical
> **Estimation:** L (5-7 days intensive development)
> **Sprint:** Sprint 5
> **Branch:** `feature/hu-5.0-full-workflow-refinement`

---

## 📋 Table of Contents

- [Overview](#overview)
- [User Story](#user-story)
- [Goals](#goals)
- [Dependencies](#dependencies)
- [Verification Criteria](#verification-criteria)
- [Technical Tasks](#technical-tasks)
- [Master Workflow (24 Documents)](#master-workflow-24-documents)
- [System Prompt Rules](#system-prompt-rules)
- [Deployment Targets](#deployment-targets)
- [Documentation](#documentation)

---

## 🎯 Overview

This **CRITICAL** user story refines the AI Architect behavior to deliver **professional, coherent, and complete software engineering documentation** following the Master Workflow of 24 documents (from initial vision to root repository files).

**Why CRITICAL for TFM Presentation:**
- Target audience: International academic committee + industry professionals
- Must demonstrate **production-ready AI-guided project creation** without placeholders or broken UI
- Showcases **full workflow automation** (0→24 docs) in <15 minutes
- Homelab deployment with Groq Cloud API enables **live demo without Ollama dependency**

**Key Innovations:**
1. **Proactivity Rules:** LLM fills missing data with industry standards (no placeholders)
2. **Visual Excellence:** Mandatory Markdown richness (emojis, tree blocks, code, tables, color palettes)
3. **Strict Validation:** Blocks next document generation until previous is validated by user
4. **Zero Robotic Prefixes:** Natural conversation without "Chat:", "Robot:", "Assistant:"
5. **Template Obedience:** Original format preserved (e.g., JSON must be valid parseable JSON)

---

## 📖 User Story

```gherkin
Feature: AI Architect Guided Master Workflow

  As a SoftArchitect user
  I want the AI to guide my project through a structured 24-document flow
  (from initial vision to root repository files)
  Following strict rules of proactivity, visual formatting, and step-by-step validation
  So that I get professional, coherent, complete software engineering documentation
  Without the AI getting lost or breaking the interface
```

---

## 🎯 Goals

### Primary Goals
1. **Refine System Prompt:** Implement 10 strict behavioral rules for the AI Architect
2. **Temperature Adjustment:** Increase creativity (0.6-0.7) while maintaining coherence
3. **Username Injection:** Personalize responses dynamically from Flutter to FastAPI
4. **Master Workflow Enforcement:** 24-document sequential flow with validation checkpoints
5. **Homelab Deployment:** Production-ready deployment with Groq Cloud API integration

### Secondary Goals
6. **Testing Coverage:** 15+ unit tests for each system prompt rule
7. **E2E Validation:** Complete workflow (0→24 docs) executable in <15 minutes
8. **Knowledge Base Examples:** Update with real examples of each workflow document

---

## 🔗 Dependencies

| Dependency | Status | Reason |
|------------|--------|--------|
| **HU-4.1** | ✅ Completed | Chat endpoint with RAG orchestration |
| **HU-4.3** | ✅ Completed | SSE streaming for real-time UI updates |
| **HU-4.4** | ✅ Completed | RAG/LLM resilience extensions |

**Soft Dependencies:**
- Knowledge Base fully populated (HU-2.0)
- Groq Client implementation functional

---

## ✅ Verification Criteria

### System Prompt Rules (10/10)
- [ ] **RULE-01:** Anti-Manifesto Automatic (ask 2-3 key questions if prompt <50 chars)
- [ ] **RULE-02:** Total Proactivity (no placeholders, complete drafts only)
- [ ] **RULE-03:** WOW Effect (intensive Markdown: emojis, tree, code, tables, HEX palettes)
- [ ] **RULE-04:** Extreme `<document>` Cleanup (only pure content inside tags, all conversation outside)
- [ ] **RULE-05:** Directory Dictatorship (everything under `context/` except `00-ROOT/` in root)
- [ ] **RULE-06:** Validation Blocking (refuse to generate next doc without "I validated and saved...")
- [ ] **RULE-07:** Zero Robotic Prefixes (forbidden: "Chat:", "Robot:", "Assistant:")
- [ ] **RULE-08:** Template Obedience (maintain original format, e.g., JSON must be valid)
- [ ] **RULE-09:** userName Injection (personalize responses with real name from Flutter)
- [ ] **RULE-10:** Sequential Flow 24 Docs (don't skip documents, validate order)

### Technical Validation
- [ ] LLM temperature adjusted (0.6 or 0.7) in `groq_client.py`
- [ ] userName injection endpoint implemented (Flutter → FastAPI)
- [ ] Short prompt detection triggers 3 key questions (Target, Stack, Features)
- [ ] `<document>` tag validator implemented (sanitize conversation outside tags)
- [ ] Validation history middleware (block if no "I validated..." detected)
- [ ] Anti-robotic prefix filter in post-processing LLM

### Testing & Quality
- [ ] 15+ unit tests for system prompt rules passing
- [ ] 5 E2E tests for complete 24-document flow
- [ ] 3 smoke tests (short prompt, validation, document tags)
- [ ] Backend coverage ≥85%, Frontend ≥80%

### Deployment
- [ ] `docker-compose.homelab.yml` configuration with Groq API key injection
- [ ] Homelab deployment script (`deploy-homelab.sh`) functional
- [ ] Successful deployment: `docker-compose up -d && curl /health` returns 200
- [ ] Documentation for homelab/demo deployment scenarios

---

## 🛠️ Technical Tasks

### Backend Adjustments
1. **Adjust LLM Temperature**
   - File: `src/server/app/infrastructure/llm/groq_client.py`
   - Change: Temperature 0.6 or 0.7 (from current 0.5)
   - Reason: Allow creativity to fill missing data with industry standards

2. **System Prompt Refinement**
   - File: `packages/knowledge_base/01-TEMPLATES/SYSTEM_PROMPTS/MASTER_WORKFLOW_SYSTEM_PROMPT.md`
   - Change: Implement 10 strict behavioral rules
   - Reason: Enforce proactivity, visual excellence, validation blocking

3. **Username Injection**
   - Files:
     - Flutter: Add `userName` parameter to ChatRepository
     - FastAPI: Modify `/chat/message` endpoint to accept `userName`
     - Orchestrator: Inject `{userName}` placeholder in system prompt
   - Reason: Personalize AI responses ("Hello, Juan!" instead of "Hello, user!")

4. **Short Prompt Detection**
   - File: `src/server/app/services/rag/template_builder.py`
   - Change: Add logic to detect prompt <50 chars and generate 3 key questions
   - Reason: Prevent automatic manifesto generation without context

5. **Document Tag Validator**
   - File: `src/server/app/services/rag/document_sanitizer.py` (new)
   - Change: Extract content inside `<document>` tags, strip conversation outside
   - Reason: Clean document generation without conversational artifacts

6. **Validation History Middleware**
   - File: `src/server/app/services/rag/validation_checker.py` (new)
   - Change: Search chat history for "I validated and saved the document in..."
   - Reason: Block next document generation until previous is validated

### Frontend Adjustments
7. **Username Provider**
   - File: `src/client/lib/features/settings/domain/entities/user_profile.dart`
   - Change: Add `userName` field to user profile
   - Reason: Capture and persist user name for injection

8. **Validation Button Enhancement**
   - File: `src/client/lib/features/chat/presentation/widgets/smart_message_renderer.dart`
   - Change: Add explicit "I validated and saved" button after :::save-document blocks
   - Reason: Simplify validation workflow for users

### Knowledge Base Updates
9. **Real Document Examples**
   - Files: `packages/knowledge_base/01-TEMPLATES/WORKFLOW_STAGES/*.md`
   - Change: Add 24 complete real-world examples (one per document)
   - Reason: RAG can retrieve realistic patterns for each workflow stage

### Testing
10. **System Prompt Rule Tests**
    - File: `tests/server/unit/services/test_system_prompt_rules.py` (new)
    - Change: Create 15 tests (minimum 1 per rule, some rules need 2-3 tests)
    - Reason: Validate each behavioral rule is enforced correctly

11. **E2E Workflow Tests**
    - File: `tests/server/integration/test_master_workflow_e2e.py` (new)
    - Change: Create 5 tests covering full 24-document flow
    - Reason: Validate complete user journey from vision to root files

### Deployment
12. **Homelab Configuration**
    - File: `infrastructure/docker-compose.homelab.yml` (new)
    - Change: Add Groq API key injection, chromadb persistence, reverse proxy config
    - Reason: Production-ready homelab deployment

13. **Deployment Script**
    - File: `scripts/devops/deploy-homelab.sh` (new)
    - Change: Automated deployment script with health checks
    - Reason: One-command deployment for TFM demo

---

## 📚 Master Workflow (24 Documents)

### Phase 00: DISCOVERY (3 documents)
**Goal:** Initial interview and scope definition

| # | Document | Saved To | Description |
|---|----------|----------|-------------|
| 01 | Initial Interview Q&A | `context/00-DISCOVERY/INTERVIEW.md` | Structured questions about Target, Stack, Features |
| 02 | Project Brief | `context/00-DISCOVERY/PROJECT_BRIEF.md` | One-pager executive summary |
| 03 | Tech Stack Decision | `context/00-DISCOVERY/TECH_STACK.md` | Technology choices with justification |

### Phase 10: CONTEXT (5 documents)
**Goal:** Vision, promise, journey map, executive summary

| # | Document | Saved To | Description |
|---|----------|----------|-------------|
| 04 | Vision Statement | `context/10-CONTEXT/VISION.md` | Long-term project vision |
| 05 | Value Promise | `context/10-CONTEXT/PROMISE.md` | User value proposition |
| 06 | User Journey Map | `context/10-CONTEXT/JOURNEY_MAP.md` | End-to-end user flows |
| 07 | Executive Summary | `context/10-CONTEXT/EXECUTIVE_SUMMARY.md` | Stakeholder-facing summary |
| 08 | Glossary | `context/10-CONTEXT/GLOSSARY.md` | Technical terms dictionary |

### Phase 20: REQUIREMENTS (7 documents)
**Goal:** Functional, non-functional, accessibility, security requirements

| # | Document | Saved To | Description |
|---|----------|----------|-------------|
| 09 | Functional Requirements | `context/20-REQUIREMENTS/FUNCTIONAL.md` | Feature specifications |
| 10 | Non-Functional Requirements | `context/20-REQUIREMENTS/NON_FUNCTIONAL.md` | Performance, scalability, reliability |
| 11 | Accessibility Checklist | `context/20-REQUIREMENTS/ACCESSIBILITY.md` | WCAG 2.1 AA compliance |
| 12 | Security Requirements | `context/20-REQUIREMENTS/SECURITY.md` | OWASP Top 10, data sovereignty |
| 13 | API Contract | `context/20-REQUIREMENTS/API_CONTRACT.md` | RESTful/GraphQL API specification |
| 14 | Database Schema | `context/20-REQUIREMENTS/DATABASE_SCHEMA.md` | ER diagrams, migrations |
| 15 | Definition of Ready/Done | `context/20-REQUIREMENTS/DOR_DOD.md` | Acceptance criteria standards |

### Phase 30: ARCHITECTURE (4 documents)
**Goal:** Architecture diagrams, technical decisions, tech stack

| # | Document | Saved To | Description |
|---|----------|----------|-------------|
| 16 | System Architecture | `context/30-ARCHITECTURE/SYSTEM_DIAGRAM.md` | C4 model diagrams |
| 17 | Technical Decisions | `context/30-ARCHITECTURE/ADR.md` | Architecture Decision Records |
| 18 | Tech Stack Detailed | `context/30-ARCHITECTURE/TECH_STACK_DETAILED.md` | Libraries, frameworks, versions |
| 19 | Deployment Architecture | `context/30-ARCHITECTURE/DEPLOYMENT.md` | Infrastructure diagram |

### Phase 40: ROADMAP (2 documents)
**Goal:** User stories master, sprint planning

| # | Document | Saved To | Description |
|---|----------|----------|-------------|
| 20 | User Stories Master | `context/40-ROADMAP/USER_STORIES_MASTER.json` | Complete backlog (JSON format) |
| 21 | Sprint Planning | `context/40-ROADMAP/SPRINT_PLAN.md` | First 3 sprints detailed |

### Phase 50: IMPLEMENTATION (1 document)
**Goal:** First sprint implementation guide

| # | Document | Saved To | Description |
|---|----------|----------|-------------|
| 22 | Implementation Guide | `context/50-IMPLEMENTATION/FIRST_SPRINT_GUIDE.md` | Code structure, setup instructions |

### Phase 00-ROOT: Root Files (2 documents)
**Goal:** README and CONTRIBUTING in repository root

| # | Document | Saved To | Description |
|---|----------|----------|-------------|
| 23 | README.md | `README.md` | Project introduction, setup, usage |
| 24 | CONTRIBUTING.md | `CONTRIBUTING.md` | Contribution guidelines |

---

## 🧠 System Prompt Rules

### RULE-01: Anti-Manifesto Automatic
**Trigger:** User prompt <50 characters
**Behavior:** Don't start generating. Ask 2-3 key questions:
- "What type of application are you building? (web, mobile, desktop, API)"
- "What is your preferred tech stack? (e.g., React+Node, Flutter+Python)"
- "What are the 3 main features of your project?"

**Test:** `test_short_prompt_triggers_questions()`

---

### RULE-02: Total Proactivity (No Placeholders)
**Forbidden:** `[Insert your text here]`, `[TODO: Add description]`, `TBD`, `...`
**Required:** Complete realistic drafts using industry standards
**Example:** Instead of `[Project Name]`, use real name from context or realistic placeholder like `"MyAwesomeApp"`

**Test:** `test_no_placeholders_in_generated_docs()`

---

### RULE-03: WOW Effect (Visual Excellence)
**Mandatory:**
- Emojis in all section headers (📋, 🎯, 🚀, ✅, ⚠️, etc.)
- Tree blocks for directory structures:
  ```tree
  project-root/
  ├── src/
  │   ├── client/
  │   └── server/
  ├── tests/
  └── README.md
  ```
- Code blocks with language tags: ` ```python`, ` ```json`, ` ```bash`
- Tables for comparisons, requirements, API endpoints
- Visible HEX codes for color palettes: `#FF5733`, `#3498DB`

**Test:** `test_wow_effect_elements_present()`

---

### RULE-04: Extreme `<document>` Cleanup
**Inside `<document>` tags:** ONLY pure document content + initial save path
**Outside tags:** All conversation, suggestions, explanations, greetings

**Example:**
```markdown
Here's the Vision Statement for your project:

<document>
<!-- SAVE TO: context/10-CONTEXT/VISION.md -->

# 🎯 Vision Statement

Our vision is to revolutionize...
[rest of document content]
</document>

Would you like me to proceed with the Value Promise next?
```

**Test:** `test_document_tags_only_content()`

---

### RULE-05: Directory Dictatorship
**Rule:** All documents MUST be saved under `context/{PHASE}/` except phase `00-ROOT/`
**Exception:** `README.md` and `CONTRIBUTING.md` go in repository root

**Enforcement:** System prompt must include directory mapping table for all 24 documents

**Test:** `test_all_docs_under_context_except_root()`

---

### RULE-06: Validation Blocking
**Trigger:** User tries to request document N+1
**Check:** Search chat history for exact string: `"He validado y guardado el documento en"` (Spanish) or `"I validated and saved the document in"` (English)
**Action:** If not found for document N, refuse politely:
> "I cannot generate the next document until you validate and save the previous one. Please click the 'Save Document' button and confirm."

**Test:** `test_validation_blocking_without_confirmation()`

---

### RULE-07: Zero Robotic Prefixes
**Forbidden starts:** `"Chat:"`, `"Robot:"`, `"IA:"`, `"Asistente:"`, `"Assistant:"`
**Allowed:** Direct natural language: `"Here's the..."`, `"I've generated..."`, `"The next step is..."`

**Test:** `test_no_robotic_prefixes_in_responses()`

---

### RULE-08: Template Obedience
**Rule:** Original template format MUST be preserved
**Examples:**
- `USER_STORIES_MASTER.json` → Valid JSON parseable with `jq`
- Tables → Must maintain column alignment
- Code blocks → Must have correct syntax highlighting
- Lists → Consistent bullet/number style

**Test:** `test_json_documents_are_valid_json()`

---

### RULE-09: userName Injection
**Source:** Flutter client sends `userName` field in `/chat/message` request
**Injection:** System prompt replaces `{userName}` placeholder
**Example:** `"Hello, {userName}! Let's build your project."` → `"Hello, Juan! Let's build your project."`

**Test:** `test_username_injection_in_responses()`

---

### RULE-10: Sequential Flow 24 Docs
**Rule:** Documents must be generated in order (01→24)
**Validation:** Check current document number before generating next
**Blocking:** Don't allow skipping (e.g., generating doc 05 without completing 01-04)

**Test:** `test_sequential_document_generation_enforced()`

---

## 🚀 Deployment Targets

### 1. Homelab (Primary for TFM Demo)
**Infrastructure:**
- Proxmox VM (8GB RAM, 4 vCPUs)
- Docker 24.x + Docker Compose v2
- Reverse proxy (Nginx/Traefik) with HTTPS (Let's Encrypt)
- Groq API Key (environment variable)
- ChromaDB persistent volume

**Configuration:**
```yaml
# docker-compose.homelab.yml
version: '3.8'
services:
  backend:
    image: softarchitect-backend:latest
    environment:
      - LLM_PROVIDER=groq
      - GROQ_API_KEY=${GROQ_API_KEY}
      - CHROMA_PERSIST_DIRECTORY=/data/chroma
    volumes:
      - chroma_data:/data/chroma

  frontend:
    image: softarchitect-frontend:latest
    ports:
      - "80:80"
      - "443:443"
```

**Deployment:**
```bash
# One-command deployment
./scripts/devops/deploy-homelab.sh --api-key ${GROQ_API_KEY}

# Health check
curl https://softarchitect.homelab.local/health
# Expected: {"status": "healthy", "llm_provider": "groq"}
```

---

### 2. Demo Cloud (Backup for TFM)
**Platforms:** Cloud Run / Railway / Render (serverless)
**Requirements:**
- Groq API Key in secrets manager
- ChromaDB in-memory or Chroma Cloud
- HTTPS obligatory
- Automatic scaling (0→N instances)

**Ideal for:**
- Temporary TFM presentation deployment
- Multi-region redundancy
- Zero infrastructure management

---

## 📖 Documentation

| Document | Language | Description |
|----------|----------|-------------|
| [README.md](README.md) | English | This file |
| [README.md](../../Español/03-HU-TRACKING/HU-5.0-ARCHITECT-AI-REFINEMENT/README.md) | Español | Spanish version |
| [PROGRESS.md](PROGRESS.md) | English | Implementation progress tracking |
| [WORKFLOW.md](WORKFLOW.md) | English | Detailed implementation workflow |
| [ARTIFACTS.md](ARTIFACTS.md) | English | Deliverable artifacts checklist |

---

## 🎯 Success Criteria

**Minimum Viable:**
- [ ] 10/10 system prompt rules implemented and tested
- [ ] Temperature adjusted (0.6-0.7)
- [ ] userName injection functional
- [ ] Homelab deployment successful
- [ ] 15+ unit tests passing
- [ ] Backend coverage ≥85%, Frontend ≥80%

**Stretch Goals:**
- [ ] 5 E2E tests for complete workflow
- [ ] Cloud demo deployment (Railway/Render)
- [ ] Knowledge base updated with 24 real examples
- [ ] Video demo recorded (<5 min)

---

## 📅 Timeline (5-7 Days)

| Day | Focus | Deliverable |
|-----|-------|-------------|
| **Day 1** | System Prompt Rules 1-5 | Temperature adjust, proactivity, WOW effect |
| **Day 2** | System Prompt Rules 6-10 | Validation blocking, userName injection |
| **Day 3** | Testing Suite | 15+ unit tests implemented |
| **Day 4** | Homelab Deployment | docker-compose.homelab.yml + deploy script |
| **Day 5** | E2E Testing | 5 E2E tests + smoke tests |
| **Day 6** | Knowledge Base | Update with 24 real document examples |
| **Day 7** | Final Validation | Full workflow 0→24 docs, video demo |

---

**🎯 Target Presentation Date:** TFM Defense (Final Master Thesis Defense)
**🚀 Status:** 🚧 In Progress
**👤 Owner:** Development Team + ArchitectZero Agent
