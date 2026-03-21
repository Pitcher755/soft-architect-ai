# ADR-003: Centralized Environment Configuration — Single Source of Truth

> **Status:** ✅ Accepted
> **Date:** 2026-06-01
> **Deciders:** Development Team + ArchitectZero
> **Related HU:** Infrastructure / DevOps

---

## 📋 Table of Contents

1. [Context](#context)
2. [Decision](#decision)
3. [Alternatives Considered](#alternatives-considered)
4. [Consequences](#consequences)
5. [Migration Guide](#migration-guide)
6. [References](#references)

---

## 📖 Context

### The Problem: Environment Configuration Hell

Before this ADR, environment configuration was fragmented across multiple locations:

| Path | Consumer | Problem |
|------|----------|---------|
| `infrastructure/.env` | Docker Compose (auto-loaded from CWD) | Only works if CWD is `infrastructure/` |
| `src/server/.env` | FastAPI / Pydantic Settings | Had to be kept in sync manually |
| *(missing)* | Flutter client configuration | Not formalized |

This fragmentation created several recurring issues:

#### Issue 1 — Duplicate Configuration

Developers edited `infrastructure/.env` for Docker but forgot to update `src/server/.env` for
the FastAPI dev server (running outside Docker). The services saw different values.

#### Issue 2 — CWD-Dependent Behaviour

`docker compose` auto-loads `.env` from the directory of the compose file (Docker Compose v2
default). Running from the repo root with `-f infrastructure/docker-compose.yml` reads
`infrastructure/.env`. Running from `infrastructure/` also reads `infrastructure/.env`. However,
if a developer placed a `.env` at the repo root (natural instinct), it was silently ignored.

#### Issue 3 — Onboarding Confusion

New contributors asked: "Which `.env` do I edit? There seem to be several!" The answer required
reading multiple files — a barrier that slowed first-time setup.

#### Issue 4 — Security Audit Surface

Multiple `.env` files multiplied the attack surface for accidental secret exposure and made
security audits more complex.

---

## ✅ Decision

### Single Source of Truth: Root `.env`

All environment configuration lives in **one file**: `.env` at the **repository root**.

```
soft-architect-ai/
├── .env              ← Single Source of Truth (gitignored)
├── .env.example      ← Template committed to version control
└── infrastructure/
    └── docker-compose.yml   ← Reads root .env via --env-file or env_file: - ../.env
```

#### How Each Consumer Reads It

| Consumer | How |
|----------|-----|
| **Docker Compose variable substitution** (`${VAR}` in compose file) | `--env-file ../.env` flag |
| **Docker container env vars** (FastAPI runtime inside container) | `env_file: - ../.env` in `docker-compose.yml` |
| **FastAPI dev server** (local, no Docker) | Run `uvicorn` from repo root OR set `ENV_FILE=../../.env` |

#### Canonical Docker Commands

When running from the **`infrastructure/` directory** (canonical form):

```bash
docker compose --env-file ../.env up -d
```

When running from the **repository root** (scripts, CI/CD):

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env up -d
```

Both forms are equivalent. The `--env-file` flag is **mandatory** and **explicit** — it removes
any ambiguity about which file Docker Compose reads for variable substitution.

---

## 🔄 Alternatives Considered

### Option A: Keep fragmented files (status quo)
**Rejected.** Root cause of the configuration hell described above.

### Option B: Symlinks (`infrastructure/.env` → `../.env`)
**Rejected.** Symlinks are fragile across operating systems (Windows, WSL2) and fail silently
inside Docker build contexts. They also confuse `git status`.

### Option C: A script that copies/syncs env files
**Rejected.** Adds a maintenance burden and introduces race conditions between the "canonical"
file and its copies. Any drift is a latent bug.

### Option D: Docker secrets / external vault
**Considered, deferred.** Appropriate for production multi-tenant deployments. Overkill for a
local-first developer tool at MVP stage. Can be revisited in a future
`ADR-004-Secrets-Management`.

---

## ⚡ Consequences

### Positive

- ✅ **One file to rule them all:** No more "which `.env` do I edit?"
- ✅ **Deterministic Docker Compose:** `--env-file` makes the source explicit regardless of CWD.
- ✅ **Onboarding simplified:** Step 1 in all docs is always `cp .env.example .env` at repo root.
- ✅ **CI/CD clean:** GitHub Actions injects all secrets via a single env-file artifact.
- ✅ **Reduced security audit surface:** One file to audit, back up, and rotate.

### Negative / Breaking Changes

- ⚠️ **Breaking change for bare `docker compose up`:** Running `docker compose up` from
  `infrastructure/` without `--env-file` no longer loads the root `.env`. Old commands
  documented in wikis, run-books, or shell history are now incorrect.
- ⚠️ **FastAPI local dev:** Developers running FastAPI outside Docker must ensure Pydantic
  Settings finds the root `.env`. Standard workaround: run `uvicorn` from the repo root.

---

## 🔧 Migration Guide

If you have an existing `infrastructure/.env` from before this ADR:

```bash
# 1. Move to repo root
mv infrastructure/.env .env

# 2. Verify docker-compose.yml reads it correctly
docker compose -f infrastructure/docker-compose.yml --env-file .env config

# 3. Update any local documentation / run-books
# Old: docker compose -f infrastructure/docker-compose.yml up -d
# New: docker compose -f infrastructure/docker-compose.yml --env-file .env up -d
```

---

## 🔗 References

- [infrastructure/README.md](../../../infrastructure/README.md) — Infrastructure directory guide
- [infrastructure/.env.example](../../../infrastructure/.env.example) — Environment template
- [infrastructure/docker-compose.yml](../../../infrastructure/docker-compose.yml) — Service definitions
- [ADR-002: Configurable RAG Limits](ADR-002-Configurable-RAG-Limits.en.md) — Related ADR
