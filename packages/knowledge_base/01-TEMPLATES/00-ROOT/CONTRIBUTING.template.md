# 🤝 Contribution Guide for {{PROJECT_NAME}}

Thank you for wanting to contribute! To maintain the quality and architecture of this project, we follow strict rules.

## 1. Workflow (GitFlow)
* **Main Branch:** `develop` (No direct push).
* **Stable Branch:** `main` (Only for releases).
* **Feature Branches:** `feature/descriptive-name`.
* **Fix Branches:** `fix/bug-name`.

### Create a new feature
```bash
git checkout develop
git checkout -b feature/{{FEATURE_NAME_EXAMPLE}}
```

## 2. Commit Standards
We use Conventional Commits. Messages in {{PRIMARY_LANGUAGE}} (or English if defined in RULES).

```
feat: add login endpoint

fix: correct email validation error

docs: update architecture diagram

style: code formatting (ruff/prettier)

refactor: optimize SQL query
```

## 3. Pull Request (PR) Rules
* **Title:** Must follow Conventional Commits.
* **Description:** Link the User Story (e.g., Closes #HU-1.2).
* **Tests:** PR is not approved if coverage drops below 80%.
* **Docs:** If you change logic, update `context/`.

## 4. Bug Report
Use the provided Issues template. Include:

* Steps to reproduce.
* Expected vs actual behavior.
* Logs or screenshots.
