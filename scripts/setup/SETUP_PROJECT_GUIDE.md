# 🚀 Setup Project Script - User Guide

> **Script:** `setup_project.sh`
> **Purpose:** Automated one-command development environment setup
> **Version:** 1.0.0
> **Date:** 2026-02-15

---

## 📋 Table of Contents

1. [Overview](#-overview)
2. [Prerequisites](#-prerequisites)
3. [Quick Start](#-quick-start)
4. [Detailed Testing Steps](#-detailed-testing-steps)
5. [What the Script Does](#-what-the-script-does)
6. [Troubleshooting](#-troubleshooting)
7. [Advanced Usage](#-advanced-usage)

---

## 🎯 Overview

The `setup_project.sh` script automates the complete development environment setup for **SoftArchitect AI** project. It handles:

- ✅ System requirements verification (Python, Poetry, Flutter, Docker)
- ✅ Environment files configuration (.env management)
- ✅ Backend dependencies installation (Poetry)
- ✅ Frontend dependencies installation (Flutter)
- ✅ Docker infrastructure (ChromaDB, Ollama, API Server)
- ✅ AI models download (Ollama models)
- ✅ Health checks (smoke tests)
- ✅ Git hooks setup (optional pre-push validation)

**Estimated time:** 5-15 minutes (depending on internet speed for model downloads)

---

## 📦 Prerequisites

Before running the script, ensure you have:

### Required Software

| Tool | Minimum Version | Check Command |
|------|----------------|---------------|
| **Python** | 3.12+ | `python3 --version` |
| **Poetry** | 1.6+ | `poetry --version` |
| **Flutter** | 3.38+ | `flutter --version` |
| **Docker** | 20.10+ | `docker --version` |
| **Docker Compose** | 2.0+ | `docker compose version` |

### Optional Software

| Tool | Purpose | Check Command |
|------|---------|---------------|
| **Ollama** (CLI) | Local AI model management | `ollama --version` |

**Note:** If Ollama CLI is not installed, the script will use Ollama in Docker (automatic).

### System Resources

- **Disk Space:** ~15 GB free (for AI models)
- **RAM:** 8 GB minimum (16 GB recommended)
- **Network:** Stable internet connection (for model downloads)

---

## ⚡ Quick Start

### Step 1: Make Script Executable

```bash
chmod +x setup_project.sh
```

### Step 2: Run the Script

```bash
./setup_project.sh
```

### Step 3: Follow Interactive Prompts

The script will:
1. Verify all requirements (exit if something is missing)
2. Configure environment files (.env)
3. Install dependencies (Backend + Frontend)
4. Start Docker services
5. Download AI models (~7 GB, may take time)
6. Run smoke tests
7. **Ask if you want to install git hooks** (recommended: press Enter for Yes)

### Step 4: Wait for Completion

Look for this final message:

```
╔═══════════════════════════════════════════════════════════════╗
║  ✨ SoftArchitect AI Development Environment is Ready! ✨     ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 🧪 Detailed Testing Steps

### Test 1: System Requirements Verification

**Purpose:** Ensure all tools are installed and running.

```bash
# Run script
./setup_project.sh
```

**Expected Output (Phase 1):**

```
╔═══════════════════════════════════════════════════════════════╗
║ PHASE 1: VERIFYING SYSTEM REQUIREMENTS
╚═══════════════════════════════════════════════════════════════╝

▶ Checking Python Installation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Python version: 3.12.3
✅ Python 3.12+ detected

▶ Checking Poetry Installation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Poetry version: 1.8.2
✅ Poetry detected

[... more checks ...]

✅ All requirements verified successfully!
```

**If something fails:**
- Script will stop and show installation instructions
- Fix the missing requirement
- Re-run the script (it's idempotent)

---

### Test 2: Environment Files Configuration

**Purpose:** Verify .env files are created from .env.example templates.

**Before running:**
```bash
# Optional: Remove existing .env files to see the creation process
rm -f .env src/server/.env src/client/.env
```

**Run script:**
```bash
./setup_project.sh
```

**Expected Output (Phase 2):**

```
╔═══════════════════════════════════════════════════════════════╗
║ PHASE 2: CONFIGURING ENVIRONMENT FILES
╚═══════════════════════════════════════════════════════════════╝

ℹ️  Environment files (.env) store configuration values for the application
ℹ️  These files are gitignored and must be created from .env.example templates

▶ Root .env Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Creating .env from .env.example
✅ Root .env created with default values
⚠️  🔧 Review and customize: /path/to/.env

▶ Backend .env Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Creating backend .env from .env.example
✅ Backend .env created with default values
⚠️  🔧 Review and customize: /path/to/src/server/.env
ℹ️  Key settings: OLLAMA_MODEL, CHROMADB_HOST, API_KEY

✅ Environment configuration complete
ℹ️  All .env files are ready with default values
```

**Manual Verification:**
```bash
ls -la .env src/server/.env src/client/.env
cat src/server/.env  # Review configuration
```

---

### Test 3: Backend Setup

**Purpose:** Install Python dependencies with Poetry.

**Expected Output (Phase 3):**

```
╔═══════════════════════════════════════════════════════════════╗
║ PHASE 3: SETTING UP BACKEND (Python/Poetry)
╚═══════════════════════════════════════════════════════════════╝

▶ Installing Python Dependencies
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Creating virtual environment with Poetry
[Installing dependencies...]
✅ Dependencies installed

▶ Verifying Backend Setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Backend environment is ready
ℹ️  Virtual env Python: Python 3.12.3

✅ Backend setup complete
```

**Manual Verification:**
```bash
# Check virtual environment exists
ls -la src/server/.venv/

# Test backend Python
cd src/server
poetry run python --version
poetry run python -c "import fastapi; print('FastAPI OK')"
cd ../..
```

---

### Test 4: Frontend Setup

**Purpose:** Install Flutter dependencies.

**Expected Output (Phase 4):**

```
╔═══════════════════════════════════════════════════════════════╗
║ PHASE 4: SETTING UP FRONTEND (Flutter)
╚═══════════════════════════════════════════════════════════════╝

▶ Installing Client Dependencies
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Running flutter pub get in src/client/
[Downloading packages...]
✅ Client dependencies installed

▶ Installing Test Dependencies
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Running flutter pub get in tests/
✅ Test dependencies installed

▶ Running Flutter Doctor
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.38.0, Linux)
[✓] Linux toolchain - develop for Linux desktop

✅ Frontend setup complete
```

**Manual Verification:**
```bash
# Check dependencies
ls -la src/client/.dart_tool/
ls -la tests/.dart_tool/

# Run a quick test
cd tests
flutter test client/unit/ --reporter=compact
cd ..
```

---

### Test 5: Docker Infrastructure

**Purpose:** Start ChromaDB, Ollama, and API Server containers.

**Expected Output (Phase 5):**

```
╔═══════════════════════════════════════════════════════════════╗
║ PHASE 5: SETTING UP INFRASTRUCTURE (Docker)
╚═══════════════════════════════════════════════════════════════╝

▶ Verifying Docker Service
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Docker daemon is running and ready

▶ Starting Docker Services
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Starting services: ChromaDB, Ollama, API Server
[+] Running 4/4
 ✔ Network sa_network          Created
 ✔ Container sa_chromadb        Started
 ✔ Container sa_ollama          Started
 ✔ Container sa_api             Started

▶ Waiting for Services to be Healthy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Waiting for services... (5/60s)
→ Waiting for services... (10/60s)
✅ Services are healthy

▶ Running Services
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NAME          STATUS          PORTS
sa_chromadb   Up (healthy)    0.0.0.0:8001->8000/tcp
sa_ollama     Up (healthy)    0.0.0.0:11434->11434/tcp
sa_api        Up (healthy)    0.0.0.0:8000->8000/tcp

✅ Infrastructure setup complete
```

**Manual Verification:**
```bash
# Check containers status
cd infrastructure
docker compose ps

# Check logs
docker compose logs chromadb --tail=20
docker compose logs ollama --tail=20
docker compose logs api-server --tail=20

cd ..
```

**If Docker stops here:**
- Docker daemon might not be running: `sudo systemctl start docker`
- Permission issues: `sudo usermod -aG docker $USER` (then logout/login)

---

### Test 6: AI Models Download

**Purpose:** Download Ollama models (qwen2.5-coder:7b, llama2).

**Expected Output (Phase 6):**

```
╔═══════════════════════════════════════════════════════════════╗
║ PHASE 6: CONFIGURING OLLAMA AI MODELS
╚═══════════════════════════════════════════════════════════════╝

ℹ️  Using Ollama in Docker

▶ Pulling Required Models
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Checking model: qwen2.5-coder:7b
→ Downloading model: qwen2.5-coder:7b (this may take several minutes)...
[████████████████] 100%
✅ Model qwen2.5-coder:7b downloaded

→ Checking model: llama2
ℹ️  Model llama2 already exists (skipping)

▶ Available Models
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NAME                  SIZE      MODIFIED
qwen2.5-coder:7b      4.7 GB    2 minutes ago
llama2:latest         3.8 GB    1 day ago

✅ Ollama models setup complete
```

**Manual Verification:**
```bash
# List models
docker exec sa_ollama ollama list

# Test a model
docker exec sa_ollama ollama run llama2 "Hello, how are you?"
```

**Notes:**
- **Large downloads:** Models are ~4-8 GB each
- **Slow connection?** Cancel (Ctrl+C) and download later manually
- **Skip if exists:** Script detects already downloaded models (idempotent)

---

### Test 7: Smoke Tests

**Purpose:** Verify all services are responding correctly.

**Expected Output (Phase 7):**

```
╔═══════════════════════════════════════════════════════════════╗
║ PHASE 7: RUNNING SMOKE TESTS
╚═══════════════════════════════════════════════════════════════╝

▶ Backend API Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Backend API is responding at http://localhost:8000/health

▶ ChromaDB Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ ChromaDB is responding at http://localhost:8001

▶ Ollama Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Ollama is responding (version: 0.1.27)

✅ Smoke tests complete
```

**Manual Verification:**
```bash
# Backend API (Swagger UI)
curl http://localhost:8000/docs
# or open in browser: http://localhost:8000/docs

# ChromaDB
curl http://localhost:8001/api/v1/heartbeat
# Expected: {"nanosecond heartbeat": 1234567890}

# Ollama
curl http://localhost:11434/api/version
# Expected: {"version": "0.x.x"}
```

---

### Test 8: Git Hooks Setup (Interactive)

**Purpose:** Optionally install pre-push validation hook.

**Expected Output (Phase 8):**

```
╔═══════════════════════════════════════════════════════════════╗
║ PHASE 8: CONFIGURING GIT HOOKS (Optional)
╚═══════════════════════════════════════════════════════════════╝

ℹ️  Git hooks can automatically validate code quality before pushing
ℹ️  This prevents CI/CD failures by catching issues locally

▶ Installing Pre-Push Validation Hook
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Install pre-push validation hook? (Y/n): ▊
```

**Option A: Press Enter (or 'Y') to Install**

```
→ Creating pre-push hook
✅ Pre-push hook installed successfully!
ℹ️  Location: /path/to/.git/hooks/pre-push

ℹ️  📌 How it works:
   → Every 'git push' will trigger automatic validation
   → If validation fails, push is aborted
   → Bypass (not recommended): git push --no-verify

✅ 🛡️  Quality gate activated! All pushes will be validated.
```

**Option B: Press 'n' to Skip**

```
ℹ️  Pre-push hook installation skipped (manual validation required)
⚠️  Remember to run: ./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh
```

**Manual Verification (if installed):**
```bash
# Check hook exists
ls -la .git/hooks/pre-push
cat .git/hooks/pre-push

# Test the hook (make a dummy change)
echo "# test" >> README.md
git add README.md
git commit -m "test: validate hook"

# Try to push (hook will run PRE_PUSH_VALIDATION_MASTER.sh)
git push
# Should see validation output before push
```

**Test Hook Failure:**
```bash
# Intentionally break something
echo "syntax error" > src/server/app/main.py

# Try to commit and push
git add src/server/app/main.py
git commit -m "test: break validation"
git push

# Expected: Push aborted with validation errors
# Fix the file and try again
git restore src/server/app/main.py
```

---

### Test 9: Final Report

**Expected Output (Phase 9):**

```
╔═══════════════════════════════════════════════════════════════╗
║ 🎉 SETUP COMPLETE - ENVIRONMENT READY
╚═══════════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════════╗
║  ✨ SoftArchitect AI Development Environment is Ready! ✨     ║
╚═══════════════════════════════════════════════════════════════╝

📊 Setup Summary
  ✅ Requirements verified
  ✅ Environment files configured
  ✅ Backend dependencies installed (Poetry)
  ✅ Frontend dependencies installed (Flutter)
  ✅ Docker services running
  ✅ Ollama models configured
  ✅ Smoke tests passed

🚀 Next Steps

  1. Start coding:
     → Backend: cd src/server && poetry run uvicorn app.main:app --reload
     → Frontend: cd src/client && flutter run -d linux

  2. Run tests:
     → All tests: ./scripts/testing/run_tests.sh all
     → Backend: cd src/server && poetry run pytest
     → Frontend: cd tests && flutter test client/

  3. Access services:
     → Backend API: http://localhost:8000/docs
     → ChromaDB: http://localhost:8001
     → Ollama: http://localhost:11434

  4. Before pushing code:
     → Validate: ./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh

Happy coding! 🚀
```

---

## 🔍 What the Script Does

### Phase-by-Phase Breakdown

| Phase | Name | Duration | Actions | Idempotent? |
|-------|------|----------|---------|-------------|
| 1 | Requirements Verification | 10s | Check Python, Poetry, Flutter, Docker versions | ✅ Yes |
| 2 | Environment Configuration | 5s | Create .env files from .env.example | ✅ Yes (skips if exists) |
| 3 | Backend Setup | 2-5min | `poetry install`, create venv | ✅ Yes (skips if .venv exists) |
| 4 | Frontend Setup | 1-3min | `flutter pub get` (client + tests) | ✅ Yes |
| 5 | Infrastructure Setup | 30s | `docker compose up -d`, health checks | ✅ Yes (restarts if running) |
| 6 | Ollama Models | 5-10min | `ollama pull` for each model | ✅ Yes (skips if downloaded) |
| 7 | Smoke Tests | 30s | curl health checks for all services | ✅ Yes |
| 8 | Git Hooks (Optional) | 5s | Install pre-push hook | ✅ Yes (asks to overwrite) |

**Total Time:** 10-20 minutes (first run), 1-2 minutes (subsequent runs)

### Files Created/Modified

```
.env                              # Root environment config
src/server/.env                   # Backend environment config
src/client/.env                   # Frontend environment config (if applicable)
src/server/.venv/                 # Python virtual environment
src/client/.dart_tool/            # Flutter build cache
tests/.dart_tool/                 # Test dependencies cache
.git/hooks/pre-push               # Git pre-push hook (optional)
infrastructure/chroma_data/       # ChromaDB persistent data
infrastructure/ollama_data/       # Ollama models storage
```

---

## 🐛 Troubleshooting

### Issue 1: Script Stops at Phase 1 (Requirements)

**Symptom:**
```
❌ Python 3.12+ required (found: 3.10.8)
❌ Some requirements are missing. Please install them and re-run this script.
```

**Solution:**
1. Install the missing requirement (follow on-screen instructions)
2. Re-run the script: `./setup_project.sh`

**Common fixes:**
```bash
# Python 3.12
sudo apt update
sudo apt install python3.12 python3.12-venv

# Poetry
curl -sSL https://install.python-poetry.org | python3 -
export PATH="$HOME/.local/bin:$PATH"

# Flutter
# Follow: https://docs.flutter.dev/get-started/install/linux

# Docker
sudo apt install docker.io docker-compose-plugin
sudo systemctl start docker
sudo usermod -aG docker $USER  # Logout/login after this
```

---

### Issue 2: Docker Daemon Not Running (Phase 5)

**Symptom:**
```
❌ Docker daemon is not running!
ℹ️  Start Docker: sudo systemctl start docker
⚠️  Cannot proceed with infrastructure setup without Docker
```

**Solution:**
```bash
# Start Docker
sudo systemctl start docker

# Enable Docker on boot (optional)
sudo systemctl enable docker

# Fix permission issues (if needed)
sudo usermod -aG docker $USER
# Then logout and login again

# Re-run script
./setup_project.sh
```

---

### Issue 3: Ollama Model Download Fails (Phase 6)

**Symptom:**
```
⚠️  Failed to download model qwen2.5-coder:7b
ℹ️  You can download it later: docker exec sa_ollama ollama pull qwen2.5-coder:7b
```

**Causes:**
- Slow internet connection
- Disk space full
- Model repository temporarily unavailable

**Solution:**
```bash
# Check disk space
df -h

# Download manually later
docker exec sa_ollama ollama pull qwen2.5-coder:7b

# Or use a different model
docker exec sa_ollama ollama pull llama2
```

---

### Issue 4: Backend API Not Responding (Phase 7)

**Symptom:**
```
⚠️  Backend API did not respond within timeout
ℹ️  Check logs: cd infrastructure && docker compose logs api-server
```

**Solution:**
```bash
# Check container logs
cd infrastructure
docker compose logs api-server --tail=50

# Common issues:
# 1. .env file misconfigured
cat ../src/server/.env
# Fix: Ensure CHROMADB_HOST=chromadb, OLLAMA_BASE_URL=http://ollama:11434

# 2. Port already in use
sudo netstat -tulpn | grep 8000
# Fix: Stop conflicting service or change port in docker-compose.yml

# 3. Container crashed
docker compose restart api-server

# Re-run smoke tests
cd ..
curl http://localhost:8000/health
```

---

### Issue 5: Git Hook Not Working

**Symptom:**
```
$ git push
# Hook doesn't run, push proceeds without validation
```

**Solution:**
```bash
# Check hook exists and is executable
ls -la .git/hooks/pre-push
# Should show: -rwxr-xr-x

# If not executable
chmod +x .git/hooks/pre-push

# Test hook manually
.git/hooks/pre-push

# If script missing
./setup_project.sh  # Re-run setup and choose to install hook
```

---

## 🎓 Advanced Usage

### Run Script in Dry-Run Mode (Simulation)

```bash
# Not yet implemented, but possible future enhancement
./setup_project.sh --dry-run
```

### Run Specific Phases Only

```bash
# Not yet implemented, but you can manually call functions:
# Example: Only setup backend
cd src/server
poetry install
poetry run python --version
```

### Skip Phases

```bash
# Not yet implemented, but you can manually skip by commenting out lines in main():
# Edit setup_project.sh, comment unwanted phases
```

### Clean Reinstall

```bash
# Remove all generated files
rm -rf .env src/server/.env src/client/.env
rm -rf src/server/.venv
rm -rf src/client/.dart_tool tests/.dart_tool
cd infrastructure
docker compose down -v
cd ..

# Re-run setup (fresh install)
./setup_project.sh
```

### Automated CI/CD Integration

```bash
# Run non-interactively (auto-accept defaults)
# Not yet implemented, but possible enhancement:
./setup_project.sh --yes  # Auto-answer Yes to all prompts
```

---

## 📚 Related Documentation

- **Quick Start Guide:** [doc/02-SETUP_DEV/QUICK_START_GUIDE.md](doc/02-SETUP_DEV/QUICK_START_GUIDE.md)
- **Setup Guide (detailed):** [doc/02-SETUP_DEV/SETUP_GUIDE.en.md](doc/02-SETUP_DEV/SETUP_GUIDE.en.md)
- **Docker Compose Guide:** [doc/02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.en.md](doc/02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.en.md)
- **Pre-Push Validation:** [scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh](scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh)
- **Project Architecture:** [doc/30-ARCHITECTURE/](doc/30-ARCHITECTURE/)

---

## ✅ Post-Setup Checklist

After running `./setup_project.sh`:

- [ ] All 8 phases completed successfully
- [ ] No errors in final report (0 errors found)
- [ ] `.env` files exist in root, backend, and client
- [ ] `src/server/.venv/` directory exists
- [ ] `docker compose ps` shows 3 containers "Up (healthy)"
- [ ] `docker exec sa_ollama ollama list` shows 2 models
- [ ] `curl http://localhost:8000/docs` returns HTML
- [ ] `curl http://localhost:8001/api/v1/heartbeat` returns JSON
- [ ] `curl http://localhost:11434/api/version` returns version JSON
- [ ] Git hook installed (optional): `.git/hooks/pre-push` exists
- [ ] Backend tests pass: `cd src/server && poetry run pytest`
- [ ] Frontend tests pass: `cd tests && flutter test client/`

**If all checkboxes are checked → Environment is 100% ready! 🎉**

---

## 🆘 Get Help

If the script fails and you can't resolve it:

1. **Check logs above** for specific error messages
2. **Read troubleshooting section** above
3. **Manual setup:** Follow [doc/02-SETUP_DEV/SETUP_GUIDE.en.md](doc/02-SETUP_DEV/SETUP_GUIDE.en.md)
4. **Open an issue:** Describe the error, include output of `./setup_project.sh`

---

## 📝 Notes

- **Idempotent:** Safe to run multiple times (skips what's already done)
- **Network-dependent:** Model downloads require stable internet
- **Disk-intensive:** AI models are large (~15 GB total)
- **Time-consuming:** First run takes 10-20 minutes
- **Interactive:** Phase 8 asks for user input (git hooks)

---

**Happy coding! 🚀**
