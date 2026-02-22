# 🤝 Contributing to {{PROJECT_NAME}}

<!--
════════════════════════════════════════════════════════════════════════════════
📘 TEMPLATE GUIDE: How to Fill Out This Document
════════════════════════════════════════════════════════════════════════════════

PURPOSE:
CONTRIBUTING.md answers: "How do I submit code/docs/bugs?"
This prevents:
- Rejected PRs (wrong format)
- Contributor frustration (unclear process)
- Unmergeable code (missing tests)

WHY THIS MATTERS:
- Reduces maintainer workload by 50%
- Increases PR acceptance rate
- Welcomes new contributors smoothly

WHEN TO CREATE:
- **Generation Order:** 4/24
- **Prerequisites:** AGENTS.md (roles), RULES.md (standards)
- **Duration:** ~30 minutes

INSTRUCTIONS:
1. Replace {{PLACEHOLDERS}} with your values
2. Add Code of Conduct (adapt from Contributor Covenant)
3. Link to RULES.md for detailed standards
4. Test setup instructions on clean machine
5. Remove TEMPLATE GUIDE before committing

BEST PRACTICES:
✅ Quick Start (<10 commands)
✅ Visual PR workflow (Mermaid)
✅ Label meanings table
✅ Response time expectations

ANTI-PATTERNS:
❌ "Read the code to understand"
❌ No issue templates
❌ Vague style guide ("be consistent")

RELATED DOCS:
- RULES.md (coding standards)
- AGENTS.md (who reviews)
- README.md (project overview)
════════════════════════════════════════════════════════════════════════════════
-->

> **Thank you for contributing to {{PROJECT_NAME}}!** 🎉
> **Every contribution matters** — from typo fixes to feature implementations.

---

## 📖 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Code Review Guidelines](#code-review-guidelines)
- [Issue Reporting](#issue-reporting)
- [Documentation Contributions](#documentation-contributions)
- [Testing Guidelines](#testing-guidelines)
- [Community](#community)

---

## 📜 Code of Conduct

**We enforce a positive environment:**

### Our Standards

**Expected Behavior:**
- ✅ Use welcoming language
- ✅ Respect differing viewpoints
- ✅ Accept constructive criticism
- ✅ Focus on what's best for the community

**Unacceptable Behavior:**
- ❌ Harassment, trolling, insults
- ❌ Publishing others' private info
- ❌ Spam or self-promotion
- ❌ Unethical/illegal activity

**Enforcement:**
1st violation: Warning
2nd violation: Temporary ban (30 days)
3rd violation: Permanent ban

**Report:** Email {{CONDUCT_EMAIL}} (confidential)

---

## 🚀 Getting Started

### Prerequisites

**Required:**
- {{BACKEND_LANG}} {{BACKEND_VER}}+ ([Install]({{BACKEND_INSTALL_URL}}))
- {{FRONTEND_FRAMEWORK}} {{FRONTEND_VER}}+ ([Install]({{FRONTEND_INSTALL_URL}}))
- Docker Desktop 24.0+ ([Install](https://docker.com/products/docker-desktop/))
- Git 2.40+

**Recommended:**
- {{IDE}} with extensions: {{EXTENSIONS}}
  <!-- e.g., VS Code with Python, Dart -->

### First-Time Setup (10 Minutes)

```bash
# 1. Fork the repo on GitHub
# Click "Fork" at https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}

# 2. Clone YOUR fork
git clone https://github.com/YOUR_USERNAME/{{REPO_NAME}}.git
cd {{REPO_NAME}}

# 3. Add upstream remote
git remote add upstream https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}.git

# 4. Install dependencies
cd src/server && pip install -r requirements.txt
cd ../client && flutter pub get

# 5. Start infrastructure
cd ../../infrastructure
docker compose up -d

# 6. Run tests (verify setup)
cd ../tests && flutter test client/
cd ../src/server && pytest ../../tests/server/

# 7. Create feature branch
git checkout -b feature/my-contribution develop
```

**Troubleshooting?** See [README.md](README.md#troubleshooting)

---

## 🛠️ Development Setup

### Environment Variables

Create `.env` in `src/server/`:

```bash
# Required
DATABASE_URL={{DATABASE_URL}}  # e.g., postgresql://user:pass@localhost:5432/db
CHROMA_HOST={{CHROMA_HOST}}    # e.g., http://localhost:8000

# Optional
LOG_LEVEL=DEBUG
OLLAMA_BASE_URL=http://localhost:11434
```

### Running Locally

**Backend:**
```bash
cd src/server
uvicorn main:app --reload --port 8080
# Visit http://localhost:8080/docs (OpenAPI)
```

**Frontend:**
```bash
cd src/client
flutter run -d {{TARGET_PLATFORM}}  # linux, macos, windows
```

### Pre-Commit Hooks (Recommended)

```bash
# Install hooks
cp scripts/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Now every commit auto-checks:
# ✓ Formatting
# ✓ Linting
# ✓ Tests
```

---

## 🎯 How to Contribute

### Types of Contributions

| Type | Description | Ideal For |
|------|-------------|-----------|
| 🐛 **Bug Fixes** | Fix reported issues | First-time contributors |
| ✨ **Features** | Implement from roadmap | Experienced developers |
| 📚 **Docs** | Improve guides, fix typos | All levels |
| 🧪 **Tests** | Add missing test coverage | QA engineers |
| 🎨 **UI/UX** | Design improvements | Designers |
| ♿ **Accessibility** | Screen reader, keyboard nav | Accessibility experts |

### Finding Work

**Good First Issues:**
- Label: `good-first-issue` ([View](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}/labels/good-first-issue))
- Estimated time: <4 hours
- Guided by maintainers

**Help Wanted:**
- Label: `help-wanted` ([View](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}/labels/help-wanted))
- Estimated time: 1-3 days
- Community-driven

---

## 🔀 Pull Request Process

### PR Workflow

```mermaid
graph LR
    A[Fork Repo] --> B[Create Branch]
    B --> C[Write Code]
    C --> D[Write Tests]
    D --> E[Run Locally]
    E --> F{Tests Pass?}
    F -->|No| C
    F -->|Yes| G[Commit]
    G --> H[Push to Fork]
    H --> I[Open PR]
    I --> J[CI Checks]
    J --> K{CI Pass?}
    K -->|No| L[Fix Issues]
    L --> G
    K -->|Yes| M[Code Review]
    M --> N{Approved?}
    N -->|Changes Requested| C
    N -->|Approved| O[Merge to Develop]

    style O fill:#90EE90
    style K fill:#FFB347
    style N fill:#FFB347
```

### PR Checklist

**Before Opening:**
```markdown
☐ Tests added/updated (coverage ≥{{COVERAGE_TARGET}}%)
☐ Code formatted ({{BACKEND_FORMATTER}}, {{FRONTEND_FORMATTER}})
☐ No linting errors
☐ Documentation updated (if API/behavior changed)
☐ Commit messages follow convention (feat/fix/docs)
☐ PR linked to issue (#123)
☐ Screenshots added (if UI changed)
☐ No merge conflicts with develop
```

### PR Title Format

```
<type>(<scope>): <description>

Examples:
✅ feat(auth): add OAuth login
✅ fix(api): handle null user response
✅ docs(readme): update install instructions

❌ updated stuff
❌ Fixed bug
```

### PR Description Template

```markdown
## 🎯 Purpose
<!-- Link to issue: Closes #123 -->

## 🔨 Changes
- Changed X to Y because Z
- Added validation for user input
- Refactored `calculate_total()` for readability

## 🧪 Testing
- [ ] Unit tests added (`test_login_success`, `test_login_invalid`)
- [ ] Manual testing: Logged in with OAuth, verified token storage
- [ ] Coverage: 92% → 94%

## 📸 Screenshots
<!-- Before/after (if UI) -->

## ⚠️ Breaking Changes
<!-- None / List migration steps -->

## 📝 Checklist
- [ ] Tests pass locally
- [ ] Code formatted
- [ ] Docs updated
- [ ] No merge conflicts
```

---

## 👀 Code Review Guidelines

### For Contributors

**Receiving Feedback:**
1. **Don't take it personally** — critique is about code, not you
2. **Ask questions** if feedback is unclear
3. **Iterate quickly** — respond within 24 hours
4. **Mark conversations resolved** once addressed

```
Reviewer: "Extract this to a separate function"

✅ GOOD RESPONSE:
"Done! Extracted to `validate_email()` in commit abc123"

❌ BAD RESPONSE:
"I don't think so" (no explanation)
```

### For Reviewers

**Review Time SLA:**
- **Hotfix:** <2 hours
- **Normal PR:** <4 hours
- **Large PR (>500 lines):** <8 hours

**Review Checklist:**
```markdown
☐ Logic correct (no off-by-one, null handling)
☐ Tests cover edge cases
☐ No security issues (SQL injection, XSS)
☐ Performance acceptable (no N+1 queries)
☐ Style matches RULES.md
☐ Docs updated (if public API changed)
```

**Feedback Tone:**
```
✅ CONSTRUCTIVE:
"Consider extracting `validate_user()` for readability.
This would also simplify testing. WDYT?"

❌ DESTRUCTIVE:
"This is terrible code."
```

---

## 🐛 Issue Reporting

### Bug Report Template

```markdown
**Describe the Bug**
A clear description of what the bug is.

**To Reproduce**
1. Go to '...'
2. Click on '...'
3. See error

**Expected Behavior**
What should have happened.

**Screenshots**
If applicable, add screenshots.

**Environment:**
- OS: [e.g., Ubuntu 22.04]
- Version: [e.g., v1.2.3]
- Browser (if web): [e.g., Chrome 120]

**Logs**
```
Paste error logs here
```
```

### Feature Request Template

```markdown
**Problem Statement**
Describe the problem: "I'm frustrated when..."

**Proposed Solution**
Describe your idea.

**Alternatives Considered**
What else did you think about?

**Additional Context**
Mockups, examples, links.
```

### Label Meanings

| Label | Meaning | Response Time |
|-------|---------|---------------|
| `bug` | Something broken | <2 days |
| `enhancement` | New feature | <1 week |
| `good-first-issue` | Easy for newcomers | <1 day |
| `help-wanted` | Community can tackle | <3 days |
| `security` | Security vulnerability | <4 hours |
| `documentation` | Docs improvements | <3 days |
| `wontfix` | Not planned | Closed with explanation |

---

## 📚 Documentation Contributions

### What to Document

**High Value:**
- Tutorials (step-by-step guides)
- Architecture decisions (why chose X over Y)
- Troubleshooting (common errors + fixes)
- API examples (code snippets)

**Low Value:**
- Repeating code comments
- Obvious information ("click Run to run")

### Documentation Standards

**File Naming:** `UPPERCASE_SNAKE_CASE.md`
**Location:** `doc/02-SETUP_DEV/` or `doc/04-USER_GUIDE/`
**Format:** Markdown with Mermaid diagrams
**Language:** English (primary), Spanish (secondary)

**Checklist:**
```markdown
☐ Table of contents at top
☐ Code examples tested (not pseudo-code)
☐ Screenshots current (not outdated)
☐ Links valid (no 404s)
☐ Spelling checked
```

---

## 🧪 Testing Guidelines

### Test Requirements

**All PRs Must:**
- ✅ Add tests for new code
- ✅ Update tests if changing behavior
- ✅ Maintain coverage ≥{{COVERAGE_TARGET}}%
- ❌ NO decreasing coverage

### Running Tests

```bash
# All tests
./scripts/testing/run_tests.sh all --coverage

# Backend only
pytest tests/server/ --cov=src/server --cov-report=term

# Frontend only
flutter test --coverage

# Specific file
pytest tests/server/test_auth.py -v
```

### Writing Good Tests

```{{BACKEND_LANG}}
# ✅ CORRECT: Descriptive name, covers edge case
def test_login_with_expired_token_returns_401(self):
    """User with expired JWT gets 401 Unauthorized."""
    token = generate_expired_token()
    response = client.post("/login", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 401
    assert "expired" in response.json()["error"]

# ❌ WRONG: Vague name, no assertion message
def test_login(self):
    response = client.post("/login")
    assert response.status_code == 200  # Why 200? What's tested?
```

---

## 💬 Community

### Communication Channels

| Channel | Purpose | Response Time |
|---------|---------|---------------|
| **GitHub Issues** | Bug reports, features | <48 hours |
| **GitHub Discussions** | Questions, ideas | <3 days |
| **{{SLACK_CHANNEL}}** | Real-time chat | <24 hours |
| **{{EMAIL}}** | Security vulnerabilities | <4 hours |

### Getting Help

**Stuck? Ask in this order:**
1. Check [README.md](README.md#troubleshooting)
2. Search [closed issues](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}/issues?q=is%3Aissue+is%3Aclosed)
3. Ask in Discussions
4. Tag `@{{MAINTAINER}}` if urgent

### Recognition

**Contributors Celebrated:**
- Listed in [README.md](README.md#team)
- Mentioned in release notes
- Invited to contributor calls

---

## 🏆 First PR Checklist

**Your First Contribution:**

```markdown
1. ☐ Read Code of Conduct
2. ☐ Read RULES.md (coding standards)
3. ☐ Setup local environment (tests pass)
4. ☐ Find "good-first-issue"
5. ☐ Comment "I'd like to work on this"
6. ☐ Wait for maintainer approval
7. ☐ Create branch (feature/issue-123-fix-bug)
8. ☐ Write code + tests
9. ☐ Run pre-commit checks
10. ☐ Open PR with template filled
11. ☐ Respond to feedback
12. ☐ Celebrate merge! 🎉
```

---

## 🎓 Resources

**Learn More:**
- [Architecture Overview](context/ARCH_DECISION_RECORDS.md)
- [Master Workflow](packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/GENERATION_ORDER.md)
- [Testing Strategy](context/TESTING_STRATEGY.md)
- [Security Policy](context/SECURITY_PRIVACY_POLICY.md)

---

## 📞 Contact

**Maintainers:**
- {{LEAD_NAME}} — [@{{LEAD_GITHUB}}](https://github.com/{{LEAD_GITHUB}}) — {{LEAD_EMAIL}}
- {{MAINTAINER_2}} — [@{{MAINTAINER_2_GITHUB}}](https://github.com/{{MAINTAINER_2_GITHUB}})

**Security Issues:** {{SECURITY_EMAIL}} (GPG key: {{GPG_KEY_ID}})

---

> **Thank you for making {{PROJECT_NAME}} better!** ❤️
> **Every contribution, no matter how small, is valued.**

---

## 🔄 Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| v1.0 | {{DATE}} | Initial version | {{AUTHOR}} |

---

**Questions?** Open a [Discussion](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}/discussions)
