# 🧠 Context Generator Prompt: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Meta-Documentación
> **Purpose:** How to generate context for SoftArchitect AI projects
> **Audience:** Architects, Project Leads, AI Assistants

---

## 📖 Tabla de Contenidos

1. [What is Context?](#what-is-context)
2. [Context Generation Framework](#context-generation-framework)
3. [Template System](#template-system)
4. [Example Workflow](#example-workflow)
5. [Best Practices](#best-practices)

---

## What is Context?

### Definition

**Context** = Complete, structured documentation that enables developers to understand and execute on a project **without asynchronous communication delays**.

```
Context is NOT:
  ❌ Ambiguous requirements
  ❌ Incomplete user stories
  ❌ Diagram without explanation
  ❌ "Figure it out" instructions

Context IS:
  ✅ Clear, detailed specifications
  ✅ Examples and acceptance criteria
  ✅ Architecture diagrams + rationale
  ✅ Actionable, measurable outcomes
```

### Problem Context Solves

```
WITHOUT Context:          WITH Context:
───────────────────────   ──────────────────────
Dev: "What do I build?"   Dev: Reads spec → understands
Manager: "Build this"     Manager: Reviews context → approves
[Back-and-forth for 1h]   [No delays, clear direction]
Dev: "Is this right?"
Manager: "Not quite..."
[Rewrite, rework]         [Dev builds correctly first time]
```

---

## Context Generation Framework

### The "Context Layers" Model

```
┌─────────────────────────────────────────────────┐
│  LAYER 1: VISION & STRATEGY                     │
├─────────────────────────────────────────────────┤
│  "Why this project?"                            │
│  - Problem statement                            │
│  - Target users                                 │
│  - Success metrics                              │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  LAYER 2: REQUIREMENTS & DESIGN                 │
├─────────────────────────────────────────────────┤
│  "What exactly to build?"                       │
│  - Functional requirements                      │
│  - Technical specifications                     │
│  - User workflows                               │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  LAYER 3: IMPLEMENTATION & EXECUTION            │
├─────────────────────────────────────────────────┤
│  "How to build it?"                             │
│  - Architecture decisions                       │
│  - Code structure                               │
│  - Testing strategy                             │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  LAYER 4: DEPLOYMENT & OPERATIONS               │
├─────────────────────────────────────────────────┤
│  "How to ship it?"                              │
│  - CI/CD pipeline                               │
│  - Monitoring & alerting                        │
│  - Runbooks & escalation                        │
└─────────────────────────────────────────────────┘
```

### Context Checklist

```
✅ LAYER 1 - VISION
  [ ] Problem statement (1-2 sentences)
  [ ] Target audience (personas)
  [ ] Success metrics (3-5 KPIs)
  [ ] Constraints (time, budget, resources)

✅ LAYER 2 - REQUIREMENTS
  [ ] Functional requirements (user can do X)
  [ ] Non-functional requirements (performance, security)
  [ ] Acceptance criteria (how to verify)
  [ ] Wireframes/mockups (if UI involved)

✅ LAYER 3 - ARCHITECTURE
  [ ] Technology choices (why this stack?)
  [ ] Architecture diagram (boxes + connections)
  [ ] Data model (entities + relationships)
  [ ] API contract (endpoints, request/response)
  [ ] Security considerations (threats + mitigations)

✅ LAYER 4 - OPERATIONS
  [ ] Deployment topology (where it runs)
  [ ] Monitoring & logging (what to watch)
  [ ] Incident response (what if it fails?)
  [ ] Scaling plan (how to grow)
```

---

## Template System

### Template Purpose

**Templates** = Standardized forms that ensure complete, consistent context capture.

```
Benefits of Templates:
  ✅ Consistency → Everyone follows same structure
  ✅ Completeness → No critical info forgotten
  ✅ Automation → Can generate docs from templates
  ✅ Reusability → Copy-paste for similar projects
  ✅ Quality → Forces critical thinking
```

### Template Categories

```
01-TEMPLATES/
├─ 00-ROOT/           # Project structure, governance
├─ 10-CONTEXT/        # Domain, vision, user research
├─ 20-REQUIREMENTS/   # Specs, compliance, stories
├─ 30-ARCHITECTURE/   # Technical design, ADRs
├─ 35-UX_UI/         # Design system, wireframes
├─ 40-PLANNING/      # Roadmap, testing, deployment
└─ 99-META/          # Meta-documentation
```

### Using Templates

```bash
# 1. Copy template
cp packages/knowledge_base/01-TEMPLATES/30-ARCHITECTURE/API_INTERFACE_CONTRACT.template.md \
   doc/MY_API_CONTRACT.md

# 2. Edit with your project details
vim doc/MY_API_CONTRACT.md

# 3. Verify completeness
grep "TODO\|FIXME\|???" doc/MY_API_CONTRACT.md

# 4. Get review
git add doc/MY_API_CONTRACT.md
git commit -m "docs: Add API contract for service X"
git push
# → Create PR for review
```

---

## Example Workflow

### Scenario: "Create Context for New Microservice"

#### Step 1: Use Vision Template

```markdown
# Vision

**Project:** User Authentication Microservice
**Problem:** Users need centralized auth
**Target Users:** Internal developers, service teams
**Success Metrics:**
  - Zero auth service downtime (99.99%)
  - Login latency < 100ms
  - 90% adoption by microservices
```

#### Step 2: Use Requirements Template

```markdown
# Functional Requirements

1. **User Registration**
   - Users can register with email + password
   - Email verification required
   - Acceptance: Email sent within 5 seconds

2. **User Login**
   - Users can login with email + password
   - JWT token issued
   - Acceptance: Token valid for 24 hours
```

#### Step 3: Use Architecture Template

```markdown
# Architecture

**Decision:** Use FastAPI + PostgreSQL + Redis

**Rationale:**
- FastAPI for async performance
- PostgreSQL for user data (ACID)
- Redis for token caching (sub-100ms lookups)

**Diagram:**
┌──────────────┐
│  API Gateway │
└──────┬───────┘
       ↓
┌──────────────────┐
│  Auth Service    │
│  (FastAPI)       │
└──┬──────────┬────┘
   ↓          ↓
┌──────┐  ┌──────┐
│ PgSQL│  │Redis │
└──────┘  └──────┘
```

#### Step 4: Use Testing Template

```markdown
# Testing Strategy

**Unit Tests:**
- Password hashing correctness
- JWT generation/validation
- Email format validation

**Integration Tests:**
- Full registration flow
- Full login flow
- Token refresh

**E2E Tests:**
- User creates account → receives email → clicks link → logs in
```

#### Step 5: Review Context

```bash
✅ LAYER 1: Vision complete (problem, users, metrics)
✅ LAYER 2: Requirements complete (3 functional)
✅ LAYER 3: Architecture complete (tech stack, diagram, data model)
✅ LAYER 4: Operations complete (testing, deployment)

→ Context ready for development!
```

---

## Best Practices

### Do's ✅

```
✅ Be Specific
   GOOD: "API response time < 100ms (p95)"
   BAD: "API should be fast"

✅ Include Examples
   GOOD: "Request: POST /auth/login with {email, password}"
   BAD: "Accept login requests"

✅ Document Decisions
   GOOD: "We chose PostgreSQL because ACID guarantees..."
   BAD: "Using PostgreSQL"

✅ Link Related Docs
   GOOD: "[See API Contract](../API_INTERFACE_CONTRACT.md)"
   BAD: "See the API documentation"

✅ Update When Context Changes
   GOOD: "Specification v1.2 (updated 2026-01-30)"
   BAD: "Initial spec (outdated)"
```

### Don'ts ❌

```
❌ Write Vague Requirements
   BAD: "Build an awesome dashboard"
   GOOD: "Build dashboard showing 5 KPIs with 60s refresh"

❌ Assume Shared Knowledge
   BAD: "Use the usual architecture"
   GOOD: "Use N-tier architecture: UI layer, API layer, DB layer"

❌ Forget Non-Functional Requirements
   BAD: "Build authentication" (missing performance, security)
   GOOD: "Build auth with < 100ms latency, TLS 1.3, 2FA support"

❌ Leave Ambiguous Success Criteria
   BAD: "The feature should work well"
   GOOD: "Feature complete when: all tests pass, 0 critical bugs, response time < 200ms"
```

### Context Review Checklist

```
Before marking context "READY":

Clarity:
  [ ] No ambiguous language ("should", "maybe", "probably")
  [ ] Every requirement has acceptance criteria
  [ ] All diagrams labeled with explanations

Completeness:
  [ ] All 4 layers covered (vision, requirements, architecture, ops)
  [ ] No "TBD" or "TODO" remaining
  [ ] Edge cases documented

Consistency:
  [ ] No contradictions between sections
  [ ] Terminology consistent (use domain language)
  [ ] Examples match requirements

Actuality:
  [ ] Links valid (no 404s)
  [ ] Dates current
  [ ] Aligned with latest decisions
```

---

## Context Maintenance

### Version Control

```
CONTEXT_CHANGELOG.md

## v1.2 (2026-01-30)
- Updated API contract to include rate limiting
- Added deployment infrastructure section
- Fixed typo in architecture diagram

## v1.1 (2026-01-20)
- Added security threat model
- Updated technology stack rationale
- Clarified user workflows

## v1.0 (2026-01-15)
- Initial context documentation
```

### Context Lifecycle

```
DRAFT → REVIEW → APPROVED → IMPLEMENTATION → MAINTENANCE → ARCHIVE

┌─────────────────────────────────────────┐
│ DRAFT (Writing)                         │
│ - Author writes context                 │
│ - Internal consistency checks           │
│ - Ready for review                      │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│ REVIEW (Feedback)                       │
│ - Tech leads review architecture        │
│ - Product reviews requirements          │
│ - Questions addressed                   │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│ APPROVED (Signed-off)                   │
│ - Stakeholders sign off                 │
│ - Ready for development                 │
│ - Status: APPROVED                      │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│ IMPLEMENTATION (In-progress)            │
│ - Developers build per context          │
│ - Context remains source of truth       │
│ - Questions reference context           │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│ MAINTENANCE (Living doc)                │
│ - Update as project evolves             │
│ - Track actual vs planned               │
│ - Lessons learned                       │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│ ARCHIVE (Historical)                    │
│ - Project complete                      │
│ - Preserved for lessons learned         │
│ - Reference for future projects         │
└─────────────────────────────────────────┘
```

---

## Tools & Automation

### Context Generation Tools

```bash
# 1. AI-Assisted Generation
# Prompt AI with: "Generate context for [project] using [template]"
# AI fills in template structure, you validate/refine

# 2. Template Validation
# Check that all required sections completed
grep -r "TODO\|FIXME\|???" packages/knowledge_base/03-EXAMPLES/ | wc -l

# 3. Link Validation
# Check all internal links work
mdl packages/knowledge_base/03-EXAMPLES/

# 4. Consistency Checker
# Verify terminology consistent across docs
grep -r "User Story\|Story\|US-" packages/knowledge_base/
# → Should see consistent naming
```

---

**Context Generator Prompt** es la meta-documentación que explica cómo SoftArchitect AI genera contexto completo. 🧠
