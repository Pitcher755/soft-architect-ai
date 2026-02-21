# 🗺️ The Master Workflow - 4 Phases of SoftArchitect AI

> **Date:** 02/19/2026
> **Status:** ✅ Complete guide
> **Reading time:** 15 minutes
> **Applicable to:** All projects

---

## 📖 Table of Contents

- [Overview](#overview)
- [PHASE 1: Governance & Identity](#phase-1-governance--identity)
- [PHASE 2: Analysis & Architectural Design](#phase-2-analysis--architectural-design)
- [PHASE 3: Implementation Planning](#phase-3-implementation-planning)
- [PHASE 4: Tracking & Optimization](#phase-4-tracking--optimization)
- [Complete Diagram](#complete-diagram)
- [References](#references)

---

## 🎯 Overview

SoftArchitect AI follows a **4-Phase Master Workflow** that guides you from idea to continuous optimization.

### Simple Metaphor:
Imagine building a project is like planning a trip:
- **PHASE 1** = Decide where to go (destination, why, who's going)
- **PHASE 2** = Plan the route (map, obstacles, resources)
- **PHASE 3** = Prepare the trip (luggage, calendar, budget)
- **PHASE 4** = During and after the trip (adjustments, learn, improve)

### Total Duration:
| Phase | Duration | Users | Outputs |
|-------|----------|-------|---------|
| **PHASE 1** | 45 min | Everyone | Project Manifesto + Analysis |
| **PHASE 2** | 1.5 h | Tech leads | C4 Diagram + Patterns |
| **PHASE 3** | 2 h | Tech leads | Roadmap + Sprints |
| **PHASE 4** | Continuous | Everyone | KPIs + Retrospectives |

---

## 🏛️ PHASE 1: Governance & Identity

> **Main question:** WHO are we and WHY do we exist?

### Objective
Define the **clear and shared identity** of the project. It's the foundation upon which everything else is built.

### What You Answer (6 Questions)

```
1️⃣  What is your purpose?
    └─ The reason for being of your project

2️⃣  Who are your users?
    └─ Whom are you serving

3️⃣  What problem do you solve?
    └─ The status quo you change

4️⃣  What is your differentiator?
    └─ What makes you unique

5️⃣  What is your horizon?
    └─ Where you want to be in 12 months

6️⃣  How will you measure success?
    └─ Your initial KPIs
```

### What SoftArchitect AI Generates

| Document | Purpose | Use |
|----------|---------|-----|
| **My Promise (Project Manifesto)** | Identity declaration | Communicate vision to team |
| **Feasibility Analysis** | Critical evaluation | Identify risks early |
| **Risk Matrix** | Threat map | Create mitigation plan |
| **Market Analysis** | Competitive context | Understand opportunities |
| **12-Month Roadmap** | Key milestones | Plan timeline |

### Example Output

```
═════════════════════════════════════════════════════
         EXAMPLE: ACADEMIC BLOG PLATFORM
═════════════════════════════════════════════════════

📋 PROJECT MANIFESTO
───────────────────────
Vision:   A platform that celebrates academic collaboration
Mission:  Validate and share quality research
Values:   Excellence, Collaboration, Transparency

📊 FEASIBILITY
───────────────────────
Technical:   ⚠️ Moderate (6 months, recommended stack: Go+React)
Market:      ✅ High (TAM $2.3B, low direct competition)
Financial:   ✅ Viable (ROI in 18 months, $200K investment)

⚠️ TOP 3 RISKS
───────────────────────
1. User retention (strategy: gamification)
2. Slow initial growth (strategy: partnerships)
3. Technical scalability (strategy: cloud-native architecture)

📈 12-MONTH OBJECTIVES
───────────────────────
├─ 1000 active users (MAU)
├─ 5000 published articles
├─ 10 university partners
└─ NPS > 50
```

### Estimated Time
- Answer questions: 15 minutes
- AI analysis: 20 minutes
- Review results: 10 minutes
- **Total: 45 minutes**

### When to Use This Phase
✅ **Start of a new project**
✅ **Strategic direction pivot**
✅ **Leadership team changes**
✅ **Annually (strategic review)**

---

## 🏗️ PHASE 2: Analysis & Architectural Design

> **Main question:** HOW are we going to build it?

### Objective
Define the **clear and scalable technical architecture** of the system. Transform the vision into a technical plan.

### What You Answer (4 Dimensions)

```
1️⃣  DOMAINS: What are the main areas?
    └─ Visual decomposition of the system

2️⃣  PATTERNS: What architectural patterns will you use?
    └─ Modular monolith, microservices, event-driven, etc.

3️⃣  DEPENDENCIES: What are the external integrations?
    └─ APIs, databases, cloud services

4️⃣  CONSTRAINTS: What technical limitations exist?
    └─ Performance, security, scalability
```

### What SoftArchitect AI Generates

| Document | Purpose | Use |
|----------|---------|-----|
| **C4 Diagram** | Architecture visualization | Communicate structure to team |
| **Pattern Matrix** | Architectural decisions | Justify chosen technologies |
| **Scalability Analysis** | Growth projections | Size infrastructure |
| **Technical Risk Evaluation** | OWASP threats, performance | Mitigation plan |
| **Technical Decisions (ADR)** | Record of why | Basis for future decisions |

### Example Output (Simplified C4 Diagram)

```
LEVEL 1: SYSTEM CONTEXT
────────────────────────────
[Users] ──→ [Academic Blog System] ──→ [Email Service]
[Admin] ──→                      ──→ [Search Index]
                                 ──→ [Auth Provider]

LEVEL 2: CONTAINER
────────────────────────────
┌────────────────────────────────┐
│ Academic Blog System           │
├────────────────────────────────┤
│                                │
│  ┌──────────────────────────┐ │
│  │  Frontend Web (React)    │ │
│  │  - User interface        │ │
│  │  - Article management    │ │
│  └──────────────────────────┘ │
│             ↓                  │
│  ┌──────────────────────────┐ │
│  │ Backend API (Go/FastAPI) │ │
│  │ - Authentication         │ │
│  │ - Business logic         │ │
│  │ - Data integration       │ │
│  └──────────────────────────┘ │
│             ↓                  │
│  ┌──────────────────────────┐ │
│  │ Database (PostgreSQL)    │ │
│  │ - Articles               │ │
│  │ - Users                  │ │
│  │ - Comments               │ │
│  └──────────────────────────┘ │
│             ↓                  │
│  ┌──────────────────────────┐ │
│  │ Search Engine (Elastic)  │ │
│  │ - Search indexes         │ │
│  │ - Full-text search       │ │
│  └──────────────────────────┘ │
│                                │
└────────────────────────────────┘

LEVEL 3: COMPONENTS (Backend)
────────────────────────────────
[Auth Controller] ──→ [Auth Service]  ──→ [User Repository] ──→ [DB]
[Article Controller]──→[Article Service]─→ [Article Repository]──→ [DB]
[Comment Controller]──→[Comment Service]─→ [Comment Repository]──→ [DB]
```

### Common Architectural Patterns

| Pattern | When to Use | Advantages | Disadvantages |
|---------|-------------|-----------|----------------|
| **Modular Monolith** | Teams <5, medium complexity | Simple, maintainable | Limited scalability |
| **Microservices** | Teams >8, high scalability | Scalable, independent | Complex, overhead |
| **Event-Driven** | Real-time data | Reactive, flexible | Hard debugging |
| **Serverless** | Unpredictable load | Low cost, no ops | Variable latency |

### Estimated Time
- Define domains: 30 minutes
- Architectural analysis: 40 minutes
- Review and refine: 20 minutes
- **Total: 1.5 hours**

### When to Use This Phase
✅ **After completing PHASE 1**
✅ **Before writing code**
✅ **Significant requirement changes**
✅ **Expected scale multiplication**

---

## 📅 PHASE 3: Implementation Planning

> **Main question:** WHEN do we build it and WITH WHAT resources?

### Objective
Convert the architectural design into a **concrete work plan** with sprints, estimations, and resource allocation.

### What You Answer (3 Dimensions)

```
1️⃣  ROADMAP: What is the implementation order?
    └─ Development phases, dependencies

2️⃣  SPRINTS: What are the increments?
    └─ User stories, sprint sizes

3️⃣  RESOURCES: Who does what and with what budget?
    └─ Team, skills, costs, timeline
```

### What SoftArchitect AI Generates

| Document | Purpose | Use |
|----------|---------|-----|
| **Technical Roadmap** | Development plan | Communicate timeline to stakeholders |
| **Sprint Definition** | Broken-down user stories | Assign work to team |
| **Capacity Matrix** | Team velocity | Estimate duration |
| **Detailed Budget** | Costs per phase | Investment approval |
| **Risk Plan** | Delay mitigation | Planned contingencies |

### Example Output (Simplified Roadmap)

```
TECHNICAL ROADMAP: ACADEMIC BLOG PLATFORM
────────────────────────────────────────────────

🏃 SPRINT 0: INITIAL SETUP (2 weeks)
├─ Base infrastructure (Docker, CI/CD)
├─ Database setup
└─ ✅ DELIVERABLE: Operational development pipeline

🏃 SPRINT 1-3: MVP CORE (6 weeks)
├─ Authentication and user management
├─ Article CRUD
├─ Basic commenting system
└─ ✅ DELIVERABLE: Functional blog minimum

🏃 SPRINT 4-5: QUALITY & UX (4 weeks)
├─ Search system (Elasticsearch)
├─ Improved responsive design
├─ Automated testing
└─ ✅ DELIVERABLE: Public beta ready

🏃 SPRINT 6-8: GAMIFICATION (6 weeks)
├─ Badge and point system
├─ Personalized recommendations
├─ Statistics and analytics
└─ ✅ DELIVERABLE: Platform 1.0

📊 TOTAL TIMELINE: 18 weeks ≈ 4.5 months

ESTIMATED RESOURCES:
├─ 2 Backend Engineers (full-time)
├─ 1 Frontend Engineer (full-time)
├─ 1 DevOps/Infrastructure (0.5 time)
├─ 1 QA (0.5 time)
└─ Total: $180K in personnel costs
```

### Tracking Metrics (Burndown)

```
TEAM VELOCITY: 35 points per sprint

Sprint 1:  ████████░░ 35 pts (100%)
Sprint 2:  ██████████ 35 pts (100%)
Sprint 3:  ████████░░ 32 pts (91%)
Sprint 4:  ██████████ 38 pts (109%)  ← Velocity improvement
Sprint 5:  ██████████ 36 pts (103%)
```

### Recommended Tools

- **Planning:** Jira, Linear, GitHub Projects
- **Timeline:** Gantt charts, roadmap tools
- **Tracking:** Burndown, velocity charts
- **Communication:** Sprint reviews, retrospectives

### Estimated Time
- Story analysis: 45 minutes
- Estimation and planning: 50 minutes
- Team validation: 25 minutes
- **Total: 2 hours**

### When to Use This Phase
✅ **After completing PHASE 2**
✅ **Before starting development**
✅ **Every quarter (replanning)**
✅ **Significant scope changes**

---

## 📊 PHASE 4: Tracking & Optimization

> **Main question:** HOW are we doing and WHAT are we learning?

### Objective
Create a **measurement and continuous improvement system** that ensures the project meets objectives and continuously optimizes.

### What You'll Measure (4 Areas)

```
1️⃣  BUSINESS INDICATORS (Business KPIs)
    └─ MAU, ARR, churn, engagement

2️⃣  TECHNICAL INDICATORS (Technical KPIs)
    └─ Uptime, latency, error rate, test coverage

3️⃣  TEAM INDICATORS (Team KPIs)
    └─ Velocity, code quality, morale

4️⃣  MARKET INDICATORS (Market KPIs)
    └─ NPS, retention, acquisition
```

### What You Do in PHASE 4

| Activity | Frequency | Purpose | Output |
|----------|-----------|---------|--------|
| **Sprint Review** | Every 2 weeks | Show progress | Feedback |
| **Retrospective** | Every 2 weeks | Learn and improve | Action items |
| **Status Report** | Weekly/monthly | Communicate status | Dashboard |
| **Data Analysis** | Monthly | Understand behavior | Insights |
| **Milestone Revisit** | Quarterly | Adjust roadmap | Updated priorities |

### Example Dashboard PHASE 4

```
═════════════════════════════════════════════════════
    DASHBOARD: ACADEMIC BLOG PLATFORM (MONTH 3)
═════════════════════════════════════════════════════

📈 BUSINESS KPIs
─────────────────────────────
Active users (MAU):          450/500    ✅ 90% of target
Published articles:          285/300    ✅ 95% of target
Retention rate:              78%        ✅ Above 70%
Net Promoter Score:          48         ⚠️ Almost 50 (target)

⚙️ TECHNICAL KPIs
─────────────────────────────
Uptime:                      99.8%      ✅ Excellent
P95 Latency:                 320ms      ⚠️ Target 200ms
Error rate:                  0.12%      ✅ Low
Test coverage:               82%        ✅ 80% required

👥 TEAM KPIs
─────────────────────────────
Velocity (points/sprint):    35         ✅ Consistent
Code review time:            4h         ✅ Within time
Deploy frequency:            3x/week    ✅ Frequent

🎯 ACTIONS TO IMPROVE
─────────────────────────────
1. ⚠️ P95 Latency: Optimize search query
2. ⚠️ NPS: Survey low-scoring users
3. ✅ Maintain current velocity
4. ✅ Expand test coverage to 90%
```

### PHASE 4 Meeting Cadence

```
WEEKLY (30 min)
└─ Status standup
   └─ Blockers, progress

EVERY 2 WEEKS (1 h)
├─ Sprint Review (30 min)
│  └─ Feature demo
└─ Retrospective (30 min)
   └─ What went well, what to improve

MONTHLY (1 h)
└─ Business review
   └─ KPIs vs. targets

QUARTERLY (2 h)
└─ Roadmap review & Planning
   └─ Strategic adjustments
```

### Measurement Tools

- **Analytics:** Mixpanel, Amplitude, Google Analytics
- **APM:** New Relic, Datadog, Prometheus
- **Surveys:** Typeform, SurveySparrow
- **Dashboards:** Mixpanel, Grafana, Tableau

### Estimated Time
- Ongoing (not a one-time phase)
- Continuous dedication: 5-10% of team's time

### When to Use This Phase
✅ **Throughout development**
✅ **After every sprint**
✅ **Continuously (never ends)**
✅ **Infinite feedback loop**

---

## 📊 Complete Diagram: All 4 Phases

```
╔════════════════════════════════════════════════════════════════════╗
║          MASTER WORKFLOW: 4 PHASES OF SOFTARCHITECT AI             ║
╚════════════════════════════════════════════════════════════════════╝

┌──────────────────┐
│ PHASE 1          │  ⏱️  45 minutes
│ GOVERNANCE       │  👥 Everyone
│ & IDENTITY       │  ❓ Who are we?
└──────────────────┘
   6 Questions
   └─→ [Project Manifesto]
   └─→ [Feasibility Analysis]
   └─→ [Risk Matrix]
   └─→ [Market Analysis]
   └─→ [12m Roadmap]
        ↓
┌──────────────────┐
│ PHASE 2          │  ⏱️  1.5 hours
│ ANALYSIS &       │  👥 Tech leads
│ ARCHITECTURAL    │  ❓ How do we build it?
│ DESIGN           │
└──────────────────┘
   4 Dimensions
   └─→ [C4 Diagram]
   └─→ [Pattern Matrix]
   └─→ [Scalability Analysis]
   └─→ [Technical Risk Evaluation]
   └─→ [Architecture Decision Records]
        ↓
┌──────────────────┐
│ PHASE 3          │  ⏱️  2 hours
│ IMPLEMENTATION   │  👥 Tech leads
│ PLANNING         │  ❓ When & with what?
└──────────────────┘
   3 Dimensions
   └─→ [Technical Roadmap]
   └─→ [Sprint Planning]
   └─→ [User Stories]
   └─→ [Capacity Matrix]
   └─→ [Detailed Budget]
        ↓
┌──────────────────┐
│ PHASE 4          │  ⏱️  Continuous
│ TRACKING &       │  👥 Everyone
│ OPTIMIZATION     │  ❓ How are we doing?
└──────────────────┘
   4 Areas
   └─→ [Business KPIs]
   └─→ [Technical KPIs]
   └─→ [Team KPIs]
   └─→ [Market KPIs]
   └─→ [Live Dashboard]
   └─→ [Retrospectives]
   └─→ [Data Analysis]
        │
        └─→ FEEDBACK LOOP (return to PHASE 1, 2, or 3)
            ↓
            Continuous Improvement ♻️
```

---

## 🔄 Feedback Loops: How Phases Connect

```
TYPICAL ISSUE: Users leave after 2 weeks

DETECTION (PHASE 4):
  └─ KPI: Churn = 45% (target: <20%)

ANALYSIS (PHASE 4):
  └─ Surveys: "UI confusing", "Missing feature X"

ACTION (← PHASE 2):
  └─ Redesign UI architecture
  └─ Prioritize Feature X in next sprint

IMPLEMENTATION (← PHASE 3):
  └─ Update roadmap
  └─ Allocate resources

EXECUTION (PHASE 3):
  └─ Develop in Sprint N

MEASUREMENT (← PHASE 4):
  └─ Measure new churn in 4 weeks
  └─ ✅ Churn drops to 28% (60% improvement)

COMPLETE CYCLE: 6-8 weeks
```

---

## 📚 References

To dive deeper into each phase, see:

- **PHASE 1:** [Quick Start Guide](01-QUICK_START.md)
- **PHASE 2:** [Architectural Patterns Guide](../02-SETUP_DEV/)
- **PHASE 3:** [Implementation Planning](../01-PROJECT_REPORT/)
- **PHASE 4:** [KPIs & Metrics](../01-PROJECT_REPORT/)

---

## 🚀 How to Get Started

### Your First Project (Today!)

1. ✅ **PHASE 1:** Answer 6 questions (45 min)
2. ⏳ **PHASE 2:** Define architecture (tomorrow, 1.5h)
3. ⏳ **PHASE 3:** Implementation plan (next, 2h)
4. ⏳ **PHASE 4:** Measure and optimize (continuously)

### Estimated Total:
**≈ 5 hours for the first 3 phases**
**+ Continuous optimization in PHASE 4**

---

<p align="center">
  ✅ You now understand the 4 Phases
  <br/>
  🎯 Ready for: <a href="01-QUICK_START.md"><strong>Create Your Project</strong></a>
  <br/><br/>
  <a href="03-FIRST_PROJECT.md">← My First Project</a> |
  <a href="05-CHAT_INTERFACE.md">AI Chat →</a>
</p>
