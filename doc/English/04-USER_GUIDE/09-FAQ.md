# ❓ Frequently Asked Questions (FAQ) - SoftArchitect AI

> **Date:** 02/19/2026
> **Status:** ✅ Frequently asked questions
> **Reading time:** 8 minutes

---

## 📖 Table of Contents

- [General](#general)
- [Installation and Setup](#installation-and-setup)
- [Usage and Features](#usage-and-features)
- [Security and Privacy](#security-and-privacy)
- [Performance](#performance)
- [Licenses and Costs](#licenses-and-costs)

---

## 🌐 General

### ❓ What is SoftArchitect AI?

**Answer:**
SoftArchitect AI is a **local-first** engineering assistant that guides developers through the complete software design cycle (0-100), from conceptualization to implementation, using private generative AI.

**Related document:** [Quick Start](01-QUICK_START.md)

---

### ❓ Do I need an internet connection?

**Answer:**
**NO**, if you use **Ollama Local** (recommended mode). All AI runs on your computer.

**YES**, only if you choose to use **Groq Cloud** (optional, for teams with limited hardware).

**Related document:** [Installation](02-INSTALLATION.md#option-a-docker-recommended)

---

### ❓ How is it different from ChatGPT or GitHub Copilot?

**Answer:**

| Feature | SoftArchitect AI | ChatGPT | GitHub Copilot |
|---------|------------------|---------|----------------|
| **Privacy** | 100% local | Cloud data ☁️ | Cloud data ☁️ |
| **Methodology** | Master Workflow 0-100 | No structure | Autocomplete |
| **Cost** | Free | $20/month | $10/month |
| **Offline** | ✅ Yes | ❌ No | ❌ No |

---

### ❓ Can I use it for commercial projects?

**Answer:**
**Yes**, absolutely. The project license allows commercial use as long as you respect the license terms (MIT).

**Related document:** [LICENSE](../../../LICENSE)

---

## 🛠️ Installation and Setup

### ❓ What hardware requirements do I need?

**Answer:**

**Minimum (Ollama Local):**
- RAM: 8GB
- CPU: 4 cores
- Disk: 10GB free
- GPU: Not required (recommended)

**Recommended:**
- RAM: 16GB+
- CPU: 8 cores
- Disk: 20GB+ free
- GPU: NVIDIA with 8GB VRAM

**Alternative (Groq Cloud):**
- RAM: 4GB
- CPU: 2 cores
- Disk: 5GB
- GPU: Not needed
- **Requires:** Groq API key (free)

**Related document:** [Installation](02-INSTALLATION.md)

---

### ❓ Does it work on Windows, Mac, and Linux?

**Answer:**
**Yes**, through Docker (full portability) or native installation on all three operating systems.

**Full support for:**
- ✅ Windows 10/11
- ✅ macOS 11+ (Intel and Apple Silicon)
- ✅ Linux (Ubuntu 20.04+, Debian, Arch, Fedora)

**Related document:** [Installation](02-INSTALLATION.md#installation-by-operating-system)

---

### ❓ Do I need to know how to code to use it?

**Answer:**
**NO to use it** (design architectures, generate documentation).

**YES to customize it** (add your own Tech Packs, modify prompts).

---

### ❓ How do I update to the latest version?

**Answer:**

**Method A: Docker (recommended)**
```bash
cd soft-architect-ai
git pull origin main
docker-compose pull
docker-compose up -d --build
```

**Method B: Local installation**
```bash
cd soft-architect-ai
git pull origin main
pip install -r requirements.txt --upgrade
cd src/client && flutter pub upgrade
```

---

## 💬 Usage and Features

### ❓ What is the "Master Workflow 0-100"?

**Answer:**
It's a structured 4-phase methodology for designing software:

1. **Phase 0 (Governance):** Define problem, requirements, stakeholders
2. **Phase 1 (Architecture):** Technical decisions (stack, patterns)
3. **Phase 2 (Implementation):** User stories, tasks
4. **Phase 3 (Tracking):** Sprints, validation, iteration

**Related document:** [Master Workflow](04-MASTER_WORKFLOW.md)

---

### ❓ Can I use my own templates or Tech Packs?

**Answer:**
**Yes**. Tech Packs are Markdown files in `packages/knowledge_base/02-TECH-PACKS/`.

**To add a new one:**
1. Create `packages/knowledge_base/02-TECH-PACKS/MY_STACK.md`
2. Follow format of existing Tech Packs
3. Restart backend to reindex

**Related document:** [Tech Packs Documentation](../../02-SETUP_DEV/KNOWLEDGE_BASE_STRUCTURE.md)

---

### ❓ How do I export results?

**Answer:**
All results are automatically saved in:
```
./data/projects/<project-name>/
├── 00-governance/          # Governance documents
├── 01-architecture/        # Architecture decisions
├── 02-implementation/      # User stories
└── 03-tracking/            # Sprints and metrics
```

**Additional export:**
- **PDF:** Click "Export to PDF" (coming soon)
- **Markdown:** Already available (copy-paste from folder)
- **JSON:** REST API `/api/export/{project_id}`

---

### ❓ Does the AI save conversation history?

**Answer:**
**YES**, but **only locally**. Never uploaded to the cloud.

**Location:**
`./data/chat_history/<date>.json`

**To delete history:**
```bash
rm -rf ./data/chat_history/*
```

---

## 🔒 Security and Privacy

### ❓ Is my data sent to the internet?

**Answer:**
**NO**, if you use **Ollama Local**.

**YES**, only if you choose to use **Groq Cloud** (optional) - in that case, only the question context is sent, not your sensitive data.

**Guarantee:** Zero telemetry, zero analytics, zero tracking.

**Related document:** [Privacy Policy](../private/PRIVACY_POLICY.md)

---

### ❓ Is it safe to use on confidential projects?

**Answer:**
**Yes**, if you use **Ollama Local**. The AI never leaves your computer.

**Applied certifications:**
- ✅ OWASP Top 10 compliance
- ✅ Data Sovereignty (EU legislation)
- ✅ GDPR-friendly (no cloud data)

**Related document:** [Security Audit](../../01-PROJECT_REPORT/SECURITY_AUDIT_REPORT.md)

---

### ❓ Can others see my projects?

**Answer:**
**NO**. Everything is on your local machine.
No "shared backend", no "login", no "sync".

---

## ⚡ Performance

### ❓ Why is it so slow at startup?

**Answer:**
**First time:** ChromaDB indexes the entire Knowledge Base (2-3 minutes).

**After:** Responses in <5 seconds.

**To speed up:**
```bash
# Use lighter model
ollama pull phi
# Edit .env
MODEL_NAME=phi
```

---

### ❓ Can I use it on a laptop without GPU?

**Answer:**
**Yes**, but it will be slower (10-30 seconds per response).

**Recommendations:**
- Use Groq Cloud (free API, <2s responses)
- Use light model (`phi` instead of `mistral`)

---

### ❓ How much RAM does it consume?

**Answer:**

| Mode | Minimum RAM | Recommended RAM |
|------|-------------|-----------------|
| **Ollama Local (mistral)** | 8GB | 16GB |
| **Ollama Local (phi)** | 4GB | 8GB |
| **Groq Cloud** | 2GB | 4GB |

---

## 💰 Licenses and Costs

### ❓ Is it free?

**Answer:**
**Yes**, 100% open source (MIT license).

**Optional costs:**
- **Groq Cloud:** Free up to 30 req/min (then $0.27/1M tokens)
- **Self-hosting:** $0 if you use your own computer

---

### ❓ Is there a "Pro" or "Enterprise" version?

**Answer:**
**Not yet**, but it's on the roadmap:

- **Pro** version (future): Custom models, priority support
- **Enterprise** (future): Multi-tenant, SSO, audit

---

### ❓ Can I contribute to the project?

**Answer:**
**Yes, please!** The project is open source.

**How to contribute:**
1. Fork the repository: https://github.com/Pitcher755/soft-architect-ai
2. Create feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -m "feat: new feature"`
4. Push: `git push origin feature/new-feature`
5. Open Pull Request

**Related document:** [CONTRIBUTING.md](../../../CONTRIBUTING.md)

---

## 🤝 Support

### ❓ Where do I report bugs or suggest improvements?

**Answer:**
**GitHub Issues:** https://github.com/Pitcher755/soft-architect-ai/issues

**Bug template:**
```markdown
**System:** Windows 11 / Docker
**Version:** v0.1.0
**Error:** [description]
**Steps to reproduce:**
1. Open app
2. Click "New Project"
3. Error appears

**Logs:** [paste server logs]
```

---

### ❓ Is there a community or Discord?

**Answer:**
**Coming soon** (Q2 2026). For now:
- GitHub Discussions
- GitHub Issues

---

## 📚 Related Documents

- [Quick Start](01-QUICK_START.md) - Get started in 15 minutes
- [Complete Installation](02-INSTALLATION.md) - Detailed setup
- [Troubleshooting](08-TROUBLESHOOTING.md) - Problem solving
- [Master Workflow](04-MASTER_WORKFLOW.md) - Understand the methodology

---

<p align="center">
  Didn't find your question?
  <br/>
  <a href="https://github.com/Pitcher755/soft-architect-ai/discussions"><strong>Ask on GitHub Discussions</strong></a>
  <br/><br/>
  <a href="08-TROUBLESHOOTING.md">Troubleshooting →</a> |
  <a href="01-QUICK_START.md">← Quick Start</a>
</p>
