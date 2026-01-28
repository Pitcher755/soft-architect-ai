# 🌿 Branch Strategy and Workflow (GitFlow)

> **Standard:** Simplified GitFlow + Conventional Commits.
> **Objective:** Keep `main` always deployable and `develop` as a stable integration point.

---

## 1. Branch Map (Branch Topology)

### 🛡️ Permanent Branches (Protected)

| Branch | Purpose | Write Rules | Deployment |
| :--- | :--- | :--- | :--- |
| **`main`** | **Production / Stable**. Contains the latest official released version (Tags). | 🔒 **READ-ONLY**. Only accepts Merges from `release/*` or `hotfix/*`. | Production (Release) |
| **`develop`** | **Integration / Next**. Contains code for the next version in development. | 🔒 **READ-ONLY**. Only accepts Pull Requests (PRs). | Testing Environment (Staging) |

### 🛠️ Work Branches (Ephemeral)

All born from `develop` and die when merged (Squash & Merge).

* **`feature/name-feature`:** New functionality development.
    * *Example:* `feature/rag-engine-setup`, `feature/flutter-ui-login`.
* **`fix/name-bug`:** Bug fixes detected in development.
    * *Example:* `fix/docker-compose-port-conflict`.
* **`docs/name-doc`:** Exclusive documentation changes (`context/`, `doc/`).
    * *Example:* `docs/update-readme`, `docs/add-tech-pack-flutter`.
* **`refactor/name`:** Code improvements without functional change.
* **`chore/name`:** Maintenance tasks (update deps, config CI).

---

## 2. Task Lifecycle (Workflow)

### Step 1: Create the Branch
Always from updated `develop`:
```bash
git checkout develop
git pull origin develop
git checkout -b feature/my-new-feature

```

### Step 2: Development and Commits

Use **Conventional Commits** for semantic history (Note: Commit uses `feat`, branch uses `feature`):

```bash
git commit -m "feat(api): add langchain base configuration"
git commit -m "test(api): add unit tests for prompt sanitizer"

```

### Step 3: Pull Request (PR)

1. Push the branch: `git push origin feature/my-new-feature`.
2. Open PR towards **`develop`** (Never to `main`).
3. **Review:** CI must pass (Linter + Tests). Another human (or Agent) must approve.

### Step 4: Merge

Upon approval, do **Squash and Merge** to leave a clean single commit in `develop`.

---

## 3. Releases and Hotfixes

### 🚀 Create a Release (`release/vX.Y.Z`)

When `develop` has enough features for a version:

1. Create branch `release/v0.1.0` from `develop`.
2. Freeze code (Code Freeze). Only minor bugfixes allowed.
3. Update `version` in `pubspec.yaml` and `pyproject.toml`.
4. Merge to **`main`** (with Tag `v0.1.0`) and to **`develop`**.

### 🔥 Hotfix (`hotfix/vX.Y.Z`)

If there's a critical error in `main`:

1. Create branch from `main`.
2. Fix the bug.
3. Merge to **`main`** (with incremental Tag) and to **`develop`**.