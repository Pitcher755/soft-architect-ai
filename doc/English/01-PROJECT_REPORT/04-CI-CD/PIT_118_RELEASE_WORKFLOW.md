# 🚀 PIT-118 — Automated Release Workflow (Release Please)

> **Date:** 31/03/2026
> **Status:** ✅ **COMPLETED**
> **Branch:** `feature/hu-6.1-release-workflow`
> **Linear:** [PIT-118](https://linear.app/pitcherdev/issue/PIT-118)

## 📋 Table of Contents

1. [Summary](#summary)
2. [Architecture](#architecture)
3. [Release Please Configuration](#release-please-configuration)
4. [Workflow Jobs](#workflow-jobs)
5. [Artifact Packaging](#artifact-packaging)
6. [Files Created](#files-created)
7. [How It Works](#how-it-works)

---

## Summary

| Aspect | Detail |
|--------|--------|
| **Ticket** | PIT-118 — [HU-6.1] Automated Release Workflow |
| **Paradigm** | Google Release Please (replaces manual tag push) |
| **Trigger** | Push to `main` branch |
| **Artifacts** | `.deb` + `.AppImage` (Linux x86_64) |
| **Checksums** | SHA-256 for every artifact |
| **CHANGELOG** | Auto-generated from conventional commits |

---

## Architecture

```
Push to main
    │
    ▼
┌─────────────────────────────┐
│  Job 1: Release Please      │
│  googleapis/release-please   │
│  - Creates/updates PR        │
│  - On merge: Tag + Release   │
│  - Auto CHANGELOG            │
└──────────┬──────────────────┘
           │ releases_created == true
           ▼
┌─────────────────────────────┐
│  Job 2: Build & Upload       │
│  - Flutter build linux       │
│  - Backend bundle            │
│  - .deb package              │
│  - .AppImage package         │
│  - SHA-256 checksums         │
│  - Upload to GitHub Release  │
└─────────────────────────────┘
```

---

## Release Please Configuration

### Monorepo Components

| Component | Path | Type | Package Name |
|-----------|------|------|-------------|
| Backend | `src/server` | python | softarchitect-ai-server |
| Frontend | `src/client` | dart | softarchitect_ai |

### CHANGELOG Sections

Conventional commit types map to CHANGELOG sections:

| Commit Type | CHANGELOG Section | Visible |
|-------------|-------------------|---------|
| `feat:` | Features | Yes |
| `fix:` | Bug Fixes | Yes |
| `perf:` | Performance Improvements | Yes |
| `security:` | Security | Yes |
| `refactor:` | Code Refactoring | Yes |
| `docs:` | Documentation | Yes |
| `test:` | Tests | Yes |
| `ci:` | CI/CD | Yes |
| `chore:` | Miscellaneous | Hidden |

### Initial Versions

Both components start at `0.1.0` in `.release-please-manifest.json`.

---

## Workflow Jobs

### Job 1: Release Please

- **Action:** `googleapis/release-please-action@v4`
- **Config:** `release-please-config.json` + `.release-please-manifest.json`
- **Outputs:** `releases_created`, per-component `tag_name`, `version`
- **Behavior:**
  - On every push to `main`: creates or updates a release PR
  - On merge of release PR: creates GitHub Release + tag + CHANGELOG

### Job 2: Build & Upload Artifacts

- **Condition:** Only runs when `releases_created == 'true'`
- **Dependencies:** `needs: release-please`
- **Steps:**
  1. Checkout code
  2. Setup Flutter 3.38.0
  3. Setup Python 3.12
  4. Install Linux packaging tools (dpkg-dev, fakeroot, cmake, etc.)
  5. Build Flutter Linux desktop (release mode)
  6. Prepare backend bundle (pip install to dist/)
  7. Package `.deb` (full desktop + server)
  8. Package `.AppImage` (portable format)
  9. Generate SHA-256 checksums
  10. Upload all artifacts to GitHub Release via `gh release upload`

---

## Artifact Packaging

### .deb Package Structure

```
/opt/softarchitect-ai/
├── client/          # Flutter desktop bundle
└── server/          # Python backend
/usr/bin/softarchitect-ai    # Launcher script
/usr/share/applications/     # .desktop entry
```

### .AppImage Structure

```
AppDir/
├── AppRun           # Entry point
├── softarchitect-ai.desktop
├── softarchitect-ai.png
└── usr/
    ├── bin/         # Flutter bundle
    └── share/       # Backend
```

### Checksums

Every artifact gets a `.sha256` companion file with the SHA-256 hash, uploaded alongside the artifact to the GitHub Release.

---

## Files Created

| File | Description |
|------|-------------|
| `release-please-config.json` | Monorepo configuration (backend python + frontend dart) |
| `.release-please-manifest.json` | Initial versions (0.1.0) |
| `.github/workflows/release.yaml` | Full release workflow (2 jobs) |

---

## How It Works

### Developer Flow

```bash
# 1. Work on feature branch with conventional commits
git commit -m "feat(backend): add new RAG query endpoint"
git commit -m "fix(frontend): resolve chat scroll issue"

# 2. Merge to develop, then to main
# 3. Release Please automatically:
#    - Opens a PR titled "chore: release X.Y.Z"
#    - PR includes auto-generated CHANGELOG
# 4. Review and merge the release PR
# 5. Release Please creates:
#    - Git tag (e.g., src/client-v0.2.0)
#    - GitHub Release with CHANGELOG
# 6. Job 2 automatically builds and uploads:
#    - softarchitect-ai_0.2.0.deb
#    - softarchitect-ai-0.2.0-x86_64.AppImage
#    - SHA-256 checksums for both
```
