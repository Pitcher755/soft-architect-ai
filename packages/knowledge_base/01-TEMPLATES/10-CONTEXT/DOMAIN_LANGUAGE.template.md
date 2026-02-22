# 🗣️ Domain Language (Ubiquitous Language)

<!--
════════════════════════════════════════════════════════════════════════════════
📘 TEMPLATE GUIDE: How to Fill Out This Document
════════════════════════════════════════════════════════════════════════════════

PURPOSE:
The Domain Language establishes THE SINGLE SOURCE OF TRUTH for business terms.
This document prevents:
- Code-UI terminology mismatches ("Order" in code vs "Purchase" in UI)
- Database schema confusion ("user" table vs "customer" table)
- Developer-stakeholder communication breakdown

WHY THIS MATTERS:
- Eliminates "lost in translation" bugs (40% of defects!)
- New developers onboard 3x faster with clear vocabulary
- Database, code, UI, docs ALL use identical terms
- SoftArchitect AI uses this to generate consistent naming

WHEN TO CREATE:
- **Generation Order:** 5/24
- **Phase:** 1 - Context
- **Prerequisites:** AGENTS.md, README.md, RULES.md, PROJECT_MANIFESTO.md
- **Duration:** ~35 minutes

INSTRUCTIONS:
1. Replace {{PLACEHOLDERS}} with YOUR project's terms
2. For each term, define EXACTLY:
   - Code name (PascalCase class/model)
   - Business name (what stakeholders call it)
   - Strict definition (no ambiguity)
3. Add disambiguation section for confusing term pairs
4. Keep terms measurable (avoid vague words like "process", "handle")
5. Remove TEMPLATE GUIDE before committing

CRITICAL RULES:
❌ NEVER use different terms for same concept (e.g., "User" vs "Account")
❌ NEVER leave terms vague ("Order" - what kind of order?)
✅ ALWAYS use Code name in: Classes, DB tables, API endpoints
✅ ALWAYS use Business name in: UI labels, emails, support docs

BEST PRACTICES:
- Start with 10-20 core terms (not 100+)
- Include Action Verbs (not just nouns)
- Add "What it's NOT" for confusing terms
- Link to entity relationship diagrams

RELATED DOCS:
- PROJECT_MANIFESTO.md (defines scope)
- DATA_MODEL_SCHEMA.md (implements this vocabulary)
- API_INTERFACE_CONTRACT.md (uses these terms in endpoints)
════════════════════════════════════════════════════════════════════════════════
-->

> **Last Updated:** {{DATE}}
> **Owner:** {{DOMAIN_EXPERT_NAME}}  <!-- e.g., Product Owner, Business Analyst -->
> **Enforcement:** Code reviews reject PRs with non-standard terms

---

## 📖 Table of Contents

- [Core Entities](#core-entities)
- [Actions & Events](#actions--events)
- [Value Objects](#value-objects)
- [Aggregates & Boundaries](#aggregates--boundaries)
- [Lifecycle States](#lifecycle-states)
- [Important Distinctions](#important-distinctions)
- [Forbidden Terms](#forbidden-terms)
- [Domain Glossary](#domain-glossary)

---

## 🏛️ Core Entities

**Entities** are objects with unique identity that persist over time.

| Code Name | Business Name | Definition | Example |
|-----------|---------------|------------|---------|
| `{{ENTITY_1_CODE}}` | {{ENTITY_1_BIZ}} | {{ENTITY_1_DEF}} | {{ENTITY_1_EXAMPLE}} |
| `{{ENTITY_2_CODE}}` | {{ENTITY_2_BIZ}} | {{ENTITY_2_DEF}} | {{ENTITY_2_EXAMPLE}} |
| `{{ENTITY_3_CODE}}` | {{ENTITY_3_BIZ}} | {{ENTITY_3_DEF}} | {{ENTITY_3_EXAMPLE}} |

<!-- EXAMPLE ROW:
| `User` | User Account | A person with login credentials and permissions | john@example.com (ID: 42) |
| `Project` | Software Project | A codebase with Git repo, backlog, and team | "TaskFlow Pro" (ID: 789) |
| `Invoice` | Customer Invoice | A payable document with line items and total | INV-2024-001 ($1,250.00) |
-->

**Invariants (Business Rules):**

For `{{ENTITY_1_CODE}}`:
- {{INVARIANT_1}}  <!-- e.g., "Email must be unique across all Users" -->
- {{INVARIANT_2}}  <!-- e.g., "User cannot delete their own account" -->

For `{{ENTITY_2_CODE}}`:
- {{INVARIANT_3}}
- {{INVARIANT_4}}

---

## ⚡ Actions & Events

**Actions** are commands (imperative). **Events** are facts (past tense).

### Actions (Commands)

| Code Name | Business Name | Definition | Triggered By |
|-----------|---------------|------------|--------------|
| `{{ACTION_1_CODE}}` | {{ACTION_1_BIZ}} | {{ACTION_1_DEF}} | {{ACTION_1_TRIGGER}} |
| `{{ACTION_2_CODE}}` | {{ACTION_2_BIZ}} | {{ACTION_2_DEF}} | {{ACTION_2_TRIGGER}} |

<!-- EXAMPLE:
| `CreateProject` | Start New Project | Initialize Git repo, create backlog | User clicks "New Project" |
| `SubmitInvoice` | Send Invoice to Customer | Generate PDF, email to recipient | User clicks "Send Invoice" |
-->

### Domain Events

| Event Name | Business Meaning | Consequences |
|------------|------------------|--------------|
| `{{EVENT_1_NAME}}` | {{EVENT_1_MEANING}} | {{EVENT_1_CONSEQUENCES}} |
| `{{EVENT_2_NAME}}` | {{EVENT_2_MEANING}} | {{EVENT_2_CONSEQUENCES}} |

<!-- EXAMPLE:
| `ProjectCreated` | Project successfully initialized | Send welcome email, create default tasks |
| `InvoicePaid` | Customer completed payment | Mark invoice as settled, trigger receipt |
-->

---

## 💎 Value Objects

**Value Objects** have no identity (equality = same fields). Immutable.

| Code Name | Business Name | Definition | Format |
|-----------|---------------|------------|--------|
| `{{VO_1_CODE}}` | {{VO_1_BIZ}} | {{VO_1_DEF}} | {{VO_1_FORMAT}} |
| `{{VO_2_CODE}}` | {{VO_2_BIZ}} | {{VO_2_DEF}} | {{VO_2_FORMAT}} |

<!-- EXAMPLE:
| `Email` | Email Address | RFC-compliant email identifier | `user@domain.com` |
| `Money` | Monetary Amount | Decimal value with currency code | `$1,250.00 USD` |
| `DateRange` | Period of Time | Start date + end date (inclusive) | `2024-01-15 to 2024-03-20` |
-->

---

## 🏗️ Aggregates & Boundaries

**Aggregates** are consistency boundaries (transactional units).

```mermaid
graph TB
    subgraph "{{AGGREGATE_1_ROOT}} Aggregate"
        Root1[{{AGGREGATE_1_ROOT}}]
        Child1A[{{AGGREGATE_1_CHILD_A}}]
        Child1B[{{AGGREGATE_1_CHILD_B}}]
        Root1 --> Child1A
        Root1 --> Child1B
    end

    subgraph "{{AGGREGATE_2_ROOT}} Aggregate"
        Root2[{{AGGREGATE_2_ROOT}}]
        Child2A[{{AGGREGATE_2_CHILD_A}}]
        Root2 --> Child2A
    end

    Root1 -.reference by ID.-> Root2
```

<!-- EXAMPLE:
subgraph "Project Aggregate"
    Project --> Task
    Project --> Milestone
end

subgraph "User Aggregate"
    User --> Profile
    User --> Permissions
end

Project -.references.-> User (via assignedUserId)
-->

**Rules:**
- External objects can ONLY reference the aggregate root (e.g., `{{AGGREGATE_1_ROOT}}`).
- Changes to `{{AGGREGATE_1_CHILD_A}}` MUST go through `{{AGGREGATE_1_ROOT}}`.

---

## 🔄 Lifecycle States

| Entity | Valid States | Transitions |
|--------|--------------|-------------|
| `{{ENTITY_1_CODE}}` | {{ENTITY_1_STATES}} | {{ENTITY_1_TRANSITIONS}} |
| `{{ENTITY_2_CODE}}` | {{ENTITY_2_STATES}} | {{ENTITY_2_TRANSITIONS}} |

<!-- EXAMPLE:
| `Project` | Draft → Active → Archived | Draft →(publish)→ Active →(complete)→ Archived |
| `Invoice` | Draft → Sent → Paid → Void | Draft →(send)→ Sent →(payment)→ Paid |
-->

**State Diagram for `{{MAIN_ENTITY}}`:**

```mermaid
stateDiagram-v2
    [*] --> {{STATE_1}}
    {{STATE_1}} --> {{STATE_2}}: {{TRANSITION_1_2}}
    {{STATE_2}} --> {{STATE_3}}: {{TRANSITION_2_3}}
    {{STATE_2}} --> {{STATE_FAILED}}: {{TRANSITION_ERROR}}
    {{STATE_3}} --> [*]

    note right of {{STATE_2}}
        {{STATE_2_NOTE}}
    end note
```

<!-- EXAMPLE:
stateDiagram-v2
    [*] --> Draft
    Draft --> Published: User clicks "Publish"
    Published --> Archived: User clicks "Archive"
    Published --> Canceled: System detects violation
    Archived --> [*]
-->

---

## 🔍 Important Distinctions (Disambiguation)

**Confusing Term Pairs:**

### {{TERM_A}} vs {{TERM_B}}

**What {{TERM_A}} IS:**
- {{TERM_A_IS_1}}
- {{TERM_A_IS_2}}

**What {{TERM_A}} IS NOT:**
- {{TERM_A_IS_NOT_1}}
- {{TERM_A_IS_NOT_2}}

**Example:**
> {{TERM_A_EXAMPLE}}

**What {{TERM_B}} IS:**
- {{TERM_B_IS_1}}
- {{TERM_B_IS_2}}

**Example:**
> {{TERM_B_EXAMPLE}}

<!-- EXAMPLE:
### User vs Account

**What User IS:**
- A human person with login credentials
- Can own multiple Projects
- Has ONE email, ONE password

**What User IS NOT:**
- NOT the same as Profile (Profile = display name, bio)
- NOT an API token or service account

**Example:** john@example.com (User ID 42)

**What Account IS:**
- A billing entity (company or individual)
- Can have multiple Users (team members)
- Has payment method and subscription

**Example:** "Acme Corp" (Account ID 7, with 5 Users)
-->

---

## 🚫 Forbidden Terms (Anti-Patterns)

**DO NOT USE these vague words in code or docs:**

| Forbidden Term | Why Forbidden | Use Instead |
|----------------|---------------|-------------|
| `{{FORBIDDEN_1}}` | {{FORBIDDEN_1_REASON}} | `{{FORBIDDEN_1_REPLACEMENT}}` |
| `{{FORBIDDEN_2}}` | {{FORBIDDEN_2_REASON}} | `{{FORBIDDEN_2_REPLACEMENT}}` |

<!-- EXAMPLE:
| `data` | Too generic | `User`, `Project`, `Invoice` (be specific) |
| `process` | Vague verb | `CalculateTotal`, `SendEmail`, `ValidateInput` |
| `handle` | Meaningless | `ProcessPayment`, `CreateUser`, `DeleteProject` |
| `manager` | God object smell | `ProjectRepository`, `InvoiceService` |
-->

---

## 📚 Domain Glossary (A-Z)

**Quick Reference (Alphabetical):**

| Term | Type | Definition |
|------|------|------------|
| {{TERM_A_ALPHA}} | {{TERM_A_TYPE}} | {{TERM_A_SHORT_DEF}} |
| {{TERM_B_ALPHA}} | {{TERM_B_TYPE}} | {{TERM_B_SHORT_DEF}} |
| {{TERM_C_ALPHA}} | {{TERM_C_TYPE}} | {{TERM_C_SHORT_DEF}} |

<!-- EXAMPLE:
| Account | Entity | Billing entity with payment method |
| CreateProject | Action | Initialize new Git repo with backlog |
| Email | Value Object | RFC-compliant email address |
| Invoice | Entity | Payable document with line items |
| InvoicePaid | Event | Payment completed successfully |
| Money | Value Object | Decimal amount with currency |
| Project | Entity | Software codebase with team |
| User | Entity | Person with login credentials |
-->

---

## 🎯 Usage Examples

### In Code (Backend)

```python
# ✅ CORRECT: Uses Domain Language
class {{ENTITY_1_CODE}}:
    """{{ENTITY_1_BIZ}}: {{ENTITY_1_DEF}}"""

    def {{ACTION_1_CODE}}(self, {{PARAM_1}}: {{VO_1_CODE}}) -> None:
        """{{ACTION_1_DEF}}"""
        event = {{EVENT_1_NAME}}(entity_id=self.id)
        self._raise_event(event)

# ❌ WRONG: Generic names
class Data:
    def process(self, input: str):
        ...
```

### In Database Schema

```sql
-- ✅ CORRECT
CREATE TABLE {{ENTITY_1_CODE}} (
    id UUID PRIMARY KEY,
    {{FIELD_1}} VARCHAR(255),
    {{FIELD_2}} DECIMAL(10, 2)
);

-- ❌ WRONG
CREATE TABLE data (
    id INT,
    value TEXT
);
```

### In API Endpoints

```
✅ CORRECT:
POST /{{ENTITY_1_CODE}}/{{ACTION_1_CODE}}
GET  /{{ENTITY_1_CODE}}/{id}

❌ WRONG:
POST /api/process
GET  /api/data/{id}
```

### In UI Labels

```typescript
// ✅ CORRECT: Uses Business Name
<button>{{ACTION_1_BIZ}}</button>
<h2>{{ENTITY_1_BIZ}} Details</h2>

// ❌ WRONG: Uses Code Name or weird casing
<button>{{ACTION_1_CODE}}</button>
<h2>{{ENTITY_1_CODE}}</h2>
```

---

## 🔄 Evolution Process

**When to Update This Document:**
- New feature introduces new entities/actions
- Stakeholders request terminology change
- Ambiguity discovered during code review

**Update Process:**
1. Propose change via PR (tag `@{{DOMAIN_EXPERT}}`)
2. Discuss in team meeting
3. Update code + database migrations in same PR
4. Announce change in team chat

**Version History:**

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| v1.0 | {{INITIAL_DATE}} | Initial domain language | {{AUTHOR}} |

---

## 🔗 Related Documents

- [PROJECT_MANIFESTO.md](PROJECT_MANIFESTO.md) - Business vision
- [DATA_MODEL_SCHEMA.md](../30-ARCHITECTURE/DATA_MODEL_SCHEMA.md) - Implements this vocabulary
- [API_INTERFACE_CONTRACT.md](../30-ARCHITECTURE/API_INTERFACE_CONTRACT.md) - Uses these terms in API
- [REQUIREMENTS_MASTER.md](../20-REQUIREMENTS/REQUIREMENTS_MASTER.md) - Requirements use these terms

---

> **Remember:** Consistency is KEY. If in doubt, refer to this document. NO exceptions.
