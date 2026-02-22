# 🏃 First Sprint Plan - SoftArchitect AI

> **Project:** SoftArchitect AI
> **Sprint Number:** Sprint 1 (Foundation Sprint)
> **Duration:** 2 weeks (10 working days)
> **Dates:** February 5 - February 18, 2026
> **Team Size:** 2 developers (1 full-stack, 1 backend-focused)
> **Velocity Target:** 31 story points (conservative first sprint)

---

## 📖 Table of Contents

1. [Sprint Goal](#-sprint-goal)
2. [Selected User Stories](#-selected-user-stories)
3. [Sprint Backlog](#-sprint-backlog)
4. [Task Breakdown](#-task-breakdown)
5. [Resource Allocation](#-resource-allocation)
6. [Risk Register](#-risk-register)
7. [Daily Standup Schedule](#-daily-standup-schedule)
8. [Definition of Done](#-definition-of-done)
9. [Sprint Ceremonies](#-sprint-ceremonies)

---

## 🎯 Sprint Goal

> **"Deliver a functional project creation + chat interface with Ollama integration, allowing users to create a project and have a basic conversation with the AI assistant."**

### Success Criteria

1. ✅ Users can create a new project with name + directory selection
2. ✅ Users can open an existing project from the workspace screen
3. ✅ Users can send messages and receive streaming AI responses (Ollama)
4. ✅ Chat history persists to SQLite and survives app restart
5. ✅ All 4 committed user stories pass acceptance criteria
6. ✅ Zero critical bugs blocking demo at sprint review

### Out of Scope (Deferred to Sprint 2)

- ❌ Document generation (Phase 1 features)
- ❌ Groq cloud LLM integration (only Ollama)
- ❌ Workflow state machine (Phase 0 tracking)
- ❌ Knowledge base RAG (ChromaDB integration)

---

## 📋 Selected User Stories

### Summary Table

| Story ID | Title | Points | Priority | Assignee | Status |
|----------|-------|--------|----------|----------|--------|
| **HU-1.1** | Create New Project | 8 | 🔴 Must Have | @PitcherDev | ✅ Completed |
| **HU-1.2** | Open Existing Project | 5 | 🔴 Must Have | @PitcherDev | ✅ Completed |
| **HU-2.1** | Send Message to AI | 13 | 🔴 Must Have | @PitcherDev | ✅ Completed |
| **HU-2.2** | View Chat History | 5 | 🔴 Must Have | @PitcherDev | ✅ Completed |
| **Total** | **4 stories** | **31** | - | - | **4/4 Done** |

---

## 📦 Sprint Backlog

### HU-1.1: Create New Project (8 points)

**User Story:**
*"As a developer, I want to create a new project with a name and root directory so I can start documenting my software architecture."*

**Acceptance Criteria:**
1. ✅ Modal dialog with fields: Project Name, Root Directory (file picker), Description (optional)
2. ✅ System validates: name not empty, directory exists, no duplicate projects with same path
3. ✅ On success: Create SQLite database (`projects.db`), `context/` folder, initial chat message
4. ✅ Project card appears in workspace with "Phase 0 - 0% complete" status

**Tasks:**
```
[UI] Design new project modal (Flutter)         → 3h  ✅ Done
[UI] Implement file picker integration          → 2h  ✅ Done
[BE] Create project service with validation     → 4h  ✅ Done
[BE] Generate deterministic UUID (UUIDv5)       → 1h  ✅ Done
[BE] Store metadata in projects.db              → 2h  ✅ Done
[QA] Unit tests for validation logic            → 3h  ✅ Done
[QA] Widget tests for modal UI                  → 2h  ✅ Done
```
**Total Effort:** 17 hours (2.1 days)
**Actual Effort:** 16 hours (on schedule)

---

### HU-1.2: Open Existing Project (5 points)

**User Story:**
*"As a developer, I want to click on a project card to open it and see my chat history so I can continue working on my documentation."*

**Acceptance Criteria:**
1. ✅ Workspace screen displays all projects as cards (name, phase, completion %)
2. ✅ Click card → Navigate to chat screen
3. ✅ System loads project metadata from `projects.db`
4. ✅ System loads chat history from `project_data.db`
5. ✅ If database missing/corrupted, show error: "Cannot open project. Database may be corrupted."

**Tasks:**
```
[UI] Design project card widget                 → 2h  ✅ Done
[UI] Implement navigation to chat screen        → 1h  ✅ Done
[BE] Load project metadata from SQLite          → 2h  ✅ Done
[BE] Load chat history with pagination          → 3h  ✅ Done
[QA] Unit tests for database read               → 2h  ✅ Done
[QA] Widget tests for project card              → 2h  ✅ Done
```
**Total Effort:** 12 hours (1.5 days)
**Actual Effort:** 11 hours (ahead of schedule)

---

### HU-2.1: Send Message to AI (13 points) 🔥 **CRITICAL PATH**

**User Story:**
*"As a developer, I want to type questions and receive AI responses so I can get instant guidance on architecture decisions."*

**Acceptance Criteria:**
1. ✅ Chat panel has text input box at bottom, send button on right
2. ✅ Support multiline input (Shift+Enter for new line, Enter to send)
3. ✅ On send: User message appears immediately with avatar + timestamp
4. ✅ AI response streams token-by-token (not all-at-once)
5. ✅ Messages persist to SQLite (`chat_messages` table)
6. ✅ Handle errors: Ollama offline → "Cannot connect to Ollama. Please start the service."

**Tasks:**
```
[UI] Design chat UI (input box, message bubbles) → 5h  ✅ Done
[UI] Implement chat notifier with Riverpod       → 4h  ✅ Done
[BE] Create FastAPI endpoint /api/v1/chat/stream → 3h  ✅ Done
[BE] Integrate with Ollama (SSE streaming)       → 5h  ✅ Done
[BE] Implement message persistence (SQLite)      → 3h  ✅ Done
[BE] Error handling & retry logic                → 2h  ✅ Done
[QA] Unit tests for chat notifier                → 3h  ✅ Done
[QA] Integration test: Flutter → FastAPI → Ollama → 4h  ✅ Done
```
**Total Effort:** 29 hours (3.6 days)
**Actual Effort:** 32 hours (slightly over, but acceptable)

---

### HU-2.2: View Chat History (5 points)

**User Story:**
*"As a developer, I want to see all my previous messages when I reopen a project so I can review past conversations."*

**Acceptance Criteria:**
1. ✅ Chat screen shows all messages from oldest to newest
2. ✅ Messages display: role (user/assistant), content, timestamp
3. ✅ System loads messages from SQLite on project open
4. ✅ Scroll to bottom automatically on new message

**Tasks:**
```
[UI] Design message bubble widget (user vs AI)   → 2h  ✅ Done
[UI] Implement auto-scroll to bottom             → 1h  ✅ Done
[BE] Query chat history from SQLite              → 2h  ✅ Done
[BE] Format timestamps (relative: "2 hours ago") → 1h  ✅ Done
[QA] Widget tests for message display            → 2h  ✅ Done
```
**Total Effort:** 8 hours (1 day)
**Actual Effort:** 7 hours (ahead of schedule)

---

## 👥 Resource Allocation

### Developer 1: @PitcherDev (Full-Stack)
**Capacity:** 80 hours (10 days × 8 hours)

| Task Category | Planned Hours | Actual Hours | Variance |
|---------------|---------------|--------------|----------|
| UI Development | 20h | 22h | +2h |
| Backend Development | 24h | 26h | +2h |
| Testing (Unit + Widget) | 18h | 16h | -2h |
| Bug Fixes & Polish | 12h | 10h | -2h |
| Code Review & Docs | 6h | 6h | 0h |
| **Total** | **80h** | **80h** | **0h** |

**Utilization:** 100% (all sprint capacity consumed)

### Developer 2: (If Available - Backend-Focused)
**Note:** Sprint 1 was solo effort. Future sprints will allocate backend tasks to second developer.

---

## ⚠️ Risk Register

| Risk | Probability | Impact | Mitigation Strategy | Status |
|------|-------------|--------|---------------------|--------|
| **Ollama installation issues** (users can't run locally) | High | Critical | Add "Quick Start" docs with Docker Compose setup | ✅ Mitigated |
| **SSE streaming breaks on slow connections** | Medium | High | Add timeout + fallback to non-streaming mode | ⏳ Deferred to Sprint 2 |
| **SQLite corruption** (WAL mode issues) | Low | Critical | Add database integrity check on startup, auto-repair | ✅ Implemented |
| **Flutter desktop crashes** (GTK issues on Linux) | Medium | High | Test on Ubuntu 22.04, Fedora 38, Arch (3 distros) | ✅ Tested |
| **State management bugs** (Riverpod complexity) | Medium | Medium | Extensive widget tests, crash on dev errors (assert) | ✅ Mitigated |

---

## 📅 Daily Standup Schedule

**Time:** 9:00 AM (15 minutes daily)
**Format:** Async (Discord message) OR Sync (Video call)

### Standup Template

```
**Yesterday:**
- ✅ Completed: [Task name]
- 🔄 In Progress: [Task name] (80% done)

**Today:**
- 🎯 Plan: [Task name]

**Blockers:**
- ❌ None
- ⚠️ Waiting for [X] to finish [Y]
```

### Actual Standup Log (Sprint 1)

#### Day 1 (Feb 5)
```
✅ Completed: Project structure setup, database schema design
🎯 Today: Implement new project modal UI
❌ Blockers: None
```

#### Day 3 (Feb 7)
```
✅ Completed: New project modal UI + validation
🎯 Today: Integrate FastAPI backend for project creation
❌ Blockers: None
```

#### Day 5 (Feb 9) - **CRITICAL**
```
✅ Completed: Chat UI + Riverpod notifier
🎯 Today: Implement Ollama SSE streaming
⚠️ Blocker: Ollama API docs unclear on streaming format → RESOLVED (used `/api/generate` with `stream=true`)
```

#### Day 8 (Feb 14)
```
✅ Completed: Ollama integration working, chat history persistence
🎯 Today: Widget tests for chat UI, integration tests
❌ Blockers: None
```

#### Day 10 (Feb 16) - **SPRINT END**
```
✅ Completed: All 4 user stories done, 100% tests passing
🎯 Today: Sprint review prep, demo recording
❌ Blockers: None
```

---

## ✅ Definition of Done (DoD)

**A user story is "Done" when ALL criteria below are met:**

### Code Quality
- [ ] ✅ Code follows style guide (Dart: `flutter_lints`, Python: `black` + `ruff`)
- [ ] ✅ No `flutter analyze` warnings
- [ ] ✅ No Pyright type errors
- [ ] ✅ Code reviewed by at least 1 peer (or self-review + justification)

### Testing
- [ ] ✅ Unit tests written for business logic (>80% coverage)
- [ ] ✅ Widget tests for UI components (critical paths)
- [ ] ✅ All tests pass (`flutter test`, `pytest`)
- [ ] ✅ Integration tests for critical flows (at least 1 per epic)

### Documentation
- [ ] ✅ Public APIs documented (DartDoc, PyDoc)
- [ ] ✅ README updated (if new feature requires setup)
- [ ] ✅ Architecture Decision Record (ADR) if architectural change

### Acceptance Criteria
- [ ] ✅ All acceptance criteria from user story met
- [ ] ✅ Product Owner (or stakeholder) approved demo

### Deployment
- [ ] ✅ Code merged to `develop` branch
- [ ] ✅ No merge conflicts
- [ ] ✅ CI/CD pipeline passes (GitHub Actions)

---

## 🎪 Sprint Ceremonies

### Sprint Planning (Feb 5, 10:00 AM - 12:00 PM)

**Participants:** @PitcherDev, @ArchitectZero (AI Advisor)
**Duration:** 2 hours

**Agenda:**
1. Review Product Backlog (top 10 stories)
2. Select stories for Sprint 1 (based on velocity = 31 points)
3. Break down stories into tasks (estimation poker)
4. Identify dependencies and risks
5. Commit to Sprint Goal

**Outcome:**
- ✅ 4 stories selected (HU-1.1, HU-1.2, HU-2.1, HU-2.2)
- ✅ 66 tasks created (tracked in GitHub Projects)
- ✅ Risk register initialized

---

### Daily Standup (Feb 6-16, 9:00 AM)

**Participants:** @PitcherDev
**Duration:** 5 minutes (async updates)
**Format:** Discord message in `#standup` channel

---

### Sprint Review (Feb 18, 2:00 PM - 3:00 PM)

**Participants:** @PitcherDev, Stakeholders (optional)
**Duration:** 1 hour

**Agenda:**
1. Demo completed user stories (live demo + video recording)
2. Review Sprint Goal achievement
3. Discuss "not done" items (none in Sprint 1)
4. Gather feedback from stakeholders

**Demo Script:**
```
1. Show workspace screen (empty state)
2. Click "New Project" → Fill form → Create
3. Show project card with "Phase 0 - 0% complete"
4. Click project card → Navigate to chat
5. Send message: "What is Clean Architecture?"
6. Show streaming response (token-by-token)
7. Restart app → Show chat history persists
8. Send another message → Show new message appends
```

**Outcome:**
- ✅ All 4 stories demoed successfully
- ✅ Stakeholder feedback: "Chat feels very responsive, love the streaming"
- ✅ No critical bugs found during demo

---

### Sprint Retrospective (Feb 18, 3:15 PM - 4:15 PM)

**Participants:** @PitcherDev
**Duration:** 1 hour
**Format:** Start-Stop-Continue + Mad-Sad-Glad

#### What Went Well ✅
- **SSE Streaming:** Token-by-token response feels instant (users love this)
- **Ollama Integration:** Easier than expected (OpenAI-compatible API)
- **Database Design:** Two-database strategy (app + project) works great for isolation

#### What Went Wrong ❌
- **Ollama Docs:** Undocumented API quirks (lost 4 hours debugging streaming format)
- **Widget Tests:** Flaky tests when running in batch (timing issues with async state)
- **Estimation:** HU-2.1 underestimated (13 points → 16 actual hours needed)

#### Action Items for Sprint 2 🎯
1. **Improve Estimation:** Add 20% buffer for integration tasks (SSE, SQLite, etc.)
2. **Fix Flaky Tests:** Use `pumpAndSettle()` in widget tests to wait for async state
3. **Better Logging:** Add structured logging with context (project_id, user_id)
4. **Ollama Fallback:** Implement Groq cloud LLM as fallback when Ollama offline

---

## 📊 Sprint Metrics

### Velocity

| Metric | Value |
|--------|-------|
| **Planned Story Points** | 31 |
| **Completed Story Points** | 31 |
| **Velocity** | 31 points/sprint |
| **Completion Rate** | 100% (4/4 stories) |

**Analysis:** Strong first sprint. Conservative estimate worked well. Increase velocity to 40-45 points for Sprint 2.

---

### Time Tracking

| Category | Planned Hours | Actual Hours | Variance |
|----------|---------------|--------------|----------|
| Development | 44h | 48h | +4h |
| Testing | 18h | 16h | -2h |
| Meetings | 4h | 4h | 0h |
| Bug Fixes | 8h | 6h | -2h |
| Documentation | 6h | 6h | 0h |
| **Total** | **80h** | **80h** | **0h** |

---

### Burn-Down Chart

```
Story Points Remaining
31 |●
   |
25 |  ●
   |
20 |    ●
   |
15 |      ●
   |
10 |        ●
   |
 5 |          ●
   |
 0 |____________●
   Day1 3  5  7  9 10
```

**Analysis:** Steady burn-down. No last-minute crunch. Good pacing.

---

## 🔗 Related Documents

- **User Stories Master:** [USER_STORIES_MASTER_EXAMPLE.json](20-USER_STORIES_MASTER_EXAMPLE.json)
- **First Sprint Guide:** [FIRST_SPRINT_GUIDE_EXAMPLE.md](22-FIRST_SPRINT_GUIDE_EXAMPLE.md)
- **Definition of Ready/Done:** [DOR_DOD_EXAMPLE.md](15-DOR_DOD_EXAMPLE.md)
- **Functional Requirements:** [FUNCTIONAL_REQUIREMENTS_EXAMPLE.md](09-FUNCTIONAL_REQUIREMENTS_EXAMPLE.md)

---

## 📎 Appendix: Sprint 2 Preview

### Planned Stories (Sprint 2: Feb 19 - Mar 4)

| Story ID | Title | Points | Priority |
|----------|-------|--------|----------|
| **HU-3.1** | Generate Vision Document | 13 | 🔴 Must Have |
| **HU-3.2** | Generate Project Brief | 8 | 🔴 Must Have |
| **HU-3.3** | Generate Tech Stack Document | 13 | 🔴 Must Have |
| **HU-2.3** | Switch LLM Provider (Ollama/Groq) | 8 | 🟡 Should Have |
| **HU-4.1** | Track Workflow Phase | 8 | 🔴 Must Have |
| **Total** | **5 stories** | **50 points** | - |

**Sprint 2 Goal:** *"Enable document generation (Phase 1) and workflow phase tracking."*

---

> **Document Metadata:**
> **Sprint:** 1 (Foundation)
> **Status:** ✅ Completed
> **Final Velocity:** 31 story points
> **Team Satisfaction:** 9/10
> **Would Sprint Again?** Yes ✅
