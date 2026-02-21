# 🚨 Troubleshooting - SoftArchitect AI

> **Fecha:** 02/19/2026
> **Estado:** ✅ Troubleshooting guide
> **Tiempo de lectura:** 10 minutes

---

## 📖 Tabla de Contenidos

- [Installation Problems](#installation-problems)
- [AI Issues](#ai-issues)
- [Performance Problems](#performance-problems)
- [Network Issues](#network-issues)
- [Data Problems](#data-problems)
- [Getting Additional Help](#getting-additional-help)

---

## 🛠️ Installation Problems

### ❌ "ModuleNotFoundError: No module named 'fastapi'"

**Symptoms:**
```
ModuleNotFoundError: No module named 'fastapi'
```

**Cause:** Python dependencies not installed correctly

**Solution:**
```bash
# 1. Ensure virtual environment is active
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# 2. Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# 3. Verify installation
pip list | grep fastapi
```

---

### ❌ "Port 3000 already in use"

**Symptoms:**
```
Error: listen EADDRINUSE: address already in use ::1:3000
```

**Cause:** Another process is using port 3000

**Solution A: Change port**
```bash
# Edit .env
APP_PORT=3001

# Restart app
```

**Solution B: Kill existing process**
```bash
# Linux/Mac
lsof -i :3000
kill -9 <PID>

# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

---

### ❌ "Docker won't start or fails"

**Symptoms:**
```
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Cause:** Docker Desktop not ejecutarning

**Solution:**
```bash
# 1. Open Docker Desktop manually

# 2. Verify it's running
docker ps

# 3. If still failing, restart Docker
# On Linux:
sudo systemctl restart docker

# On Windows/Mac: Restart Docker Desktop
```

---

### ❌ "Python not recognized as command"

**Symptoms:**
```
'python' is not recognized as an internal or external command
```

**Cause:** Python not in PATH

**Solution:**
1. **Windows:** Reinstall Python and check "Add Python to PATH"
2. **Linux/Mac:** Use `python3` instead of `python`
3. Verify with: `python --version` or `python3 --version`

---

## 🤖 AI Issues

### ❌ "AI doesn't respond or takes too long"

**Symptoms:**
- Chat shows "Thinking..." for more than 2 minutes
- Responses never arrive

**Possible Cause 1: ChromaDB indexing**
**Solution:**
```bash
# Wait 30-60 seconds more
# First time always takes longer

# Check server logs
docker logs soft-architect-ai-backend
```

**Possible Cause 2: Ollama not ejecutarning**
**Solution:**
```bash
# Verify Ollama
ollama list

# If no response, start:
ollama serve

# Download model if missing:
ollama pull mistral
```

**Possible Cause 3: API connection problem**
**Solution:**
```bash
# If using Groq, verify .env:
GROQ_API_KEY=your_key_here
USE_GROQ=true

# Check request limit:
# Groq free tier: 30 req/min
# Wait 1 minute and retry
```

---

### ❌ "AI gives nonsense responses or hallucinations"

**Symptoms:**
- Contradictory responses
- Mentions technologies you didn't ask for
- Excessive "creative mode"

**Cause:** Incorrect model configuración

**Solution:**
```bash
# 1. Edit src/server/config/llm_settings.py
# Reduce temperature:
TEMPERATURE=0.3  # Default value: 0.7

# 2. Increase penalty:
FREQUENCY_PENALTY=0.5

# 3. Restart server
```

---

### ❌ "AI doesn't understand my question"

**Symptoms:**
- Generic responses
- "I'm sorry, I don't understand"
- Asks the same thing repeatedly

**Cause:** Insufficient or ambiguous context

**Solution:**
✅ **DO:**
- "I need a task management app for remote teams of 20 people, with real-time synchronization"

❌ **DON'T:**
- "Task app"

✅ **DO:**
- "We'll use PostgreSQL because we already have experience and need ACID"

❌ **DON'T:**
- "Database that works"

---

## ⚡ Performance Problems

### ❌ "App is slow or freezes"

**Symptoms:**
- UI slow to respond
- Chat lag
- Documentos take forever to load

**Possible Cause 1: Insufficient RAM**
**Solution:**
```bash
# Check memory usage
docker stats  # If using Docker

# If usage > 90%, close other programs
# Or increase RAM allocated to Docker:
# Docker Desktop → Settings → Resources → Memory: 8GB
```

**Possible Cause 2: Large ChromaDB**
**Solution:**
```bash
# Clean old data
cd infrastructure/chroma_data
rm -rf *  # ⚠️ You'll lose history

# Restart app
docker-compose restart
```

**Possible Cause 3: Disk full**
**Solution:**
```bash
# Check available space
df -h  # Linux/Mac
dir   # Windows

# Free space if < 5GB
# Delete old logs, cache, etc.
```

---

### ❌ "Streaming responses choppy"

**Symptoms:**
- Text appears in jerky chunks
- Words get cut off
- Delays between sentences

**Cause:** Slow connection or overloaded backend

**Solution:**
```bash
# 1. Check model latency
# If using Ollama locally:
ollama run mistral "test"  # Takes >5s?

# 2. Switch to lighter model
ollama pull phi  # Faster model

# 3. In .env:
MODEL_NAME=phi

# 4. Restart
```

---

## 🌐 Network Issues

### ❌ "Cannot connect to localhost:3000"

**Symptoms:**
```
ERR_CONNECTION_REFUSED
```

**Cause:** Backend not ejecutarning

**Solution:**
```bash
# 1. Verify server is running
docker ps  # Look for "backend" container

# or
ps aux | grep uvicorn  # If local install

# 2. If not running, start:
docker-compose up -d  # Docker
# or
cd src/server && python main.py  # Local

# 3. Wait 30 seconds and open browser
```

---

### ❌ "CORS policy error"

**Symptoms:**
```
Access to fetch at 'http://localhost:8000' from origin 'http://localhost:3000'
has been blocked by CORS policy
```

**Cause:** Misconfigured CORS settings

**Solution:**
```python
# src/server/app/main.py
# Verify ALLOWED_ORIGINS includes your domain

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 💾 Data Problems

### ❌ "My proyectos disappeared"

**Symptoms:**
- Empty proyecto list
- "No proyectos found"

**Cause:** Data not persisted or carpeta moved

**Solution:**
```bash
# 1. Check data folder
ls -la ./data/projects  # Linux/Mac
dir .\data\projects     # Windows

# 2. If empty, check backup
ls -la ./data/backup

# 3. Restore from backup if exists
cp -r ./data/backup/* ./data/projects/

# 4. If no backup, data is lost 😢
# In future, use Docker volumes for persistence
```

---

### ❌ "Error saving documentos"

**Symptoms:**
```
PermissionError: [Errno 13] Permission denied: './data/projects/...'
```

**Cause:** Incorrect write permissions

**Solution:**
```bash
# Linux/Mac
sudo chown -R $USER:$USER ./data
chmod -R 755 ./data

# Windows
# Right-click data folder → Properties → Security
# Give "Full control" to your user
```

---

## 🔐 Security Problems

### ❌ "SSL certificate error"

**Symptoms:**
```
SSL: CERTIFICATE_VERIFY_FAILED
```

**Cause:** Outdated SSL certificates

**Solution:**
```bash
# Option A: Update system certificates
# Linux:
sudo apt update && sudo apt install ca-certificates

# Mac:
# Open Keychain Access → Certificates → Update

# Option B: Disable verification (NOT recommended in production)
# In development, edit .env:
SSL_VERIFY=false
```

---

## 🆘 Getting Additional Help

### 📋 Information to gather before reporting:

1. **Operating system** and version
   ```bash
   uname -a  # Linux/Mac
   systeminfo  # Windows
   ```

2. **Installed versions**
   ```bash
   python --version
   docker --version
   flutter --version
   ```

3. **Server logs**
   ```bash
   docker logs soft-architect-ai-backend --tail 50
   # or
   cat src/server/logs/app.log
   ```

4. **Complete error message** (exact copy-paste)

5. **Steps to reproduce the problem**

---

### 🌐 Support Channels

| Channel | Use | Response |
|---------|-----|----------|
| **GitHub Issues** | Bugs, features | 24-48h |
| **Discord** (coming soon) | Quick help | Community |
| **Email** | Technical support | 2-3 days |
| **Documentoation** | Troubleshooting | Instant |

**GitHub Issues:** https://github.com/Pitcher755/soft-architect-ai/issues
**Email:** support@softarchitectai.com

---

### 📚 Related Documentos

- [Complete Installation](02-INSTALLATION.md) - For setup problems
- [Quick Start](01-QUICK_START.md) - Start from scratch
- [FAQ](09-FAQ.md) - Common questions
- [Master Workflow](04-MASTER_WORKFLOW.md) - Understand how it works

---

## ✅ Quick Diagnostic Checklist

Before reporting a problem, verify:

- [ ] Did you restart the application?
- [ ] Did you check server logs?
- [ ] Did you verify Docker is ejecutarning? (if applicable)
- [ ] Did you check the port isn't occupied?
- [ ] Did you update to the laprueba version?
- [ ] Did you consult the documentoation?
- [ ] Did you search for the error in GitHub Issues?

---

<p align="center">
  ✅ Problem solved? Great!
  <br/>
  ❌ Still not? <a href="https://github.com/Pitcher755/soft-architect-ai/issues"><strong>Report on GitHub Issues</strong></a>
  <br/><br/>
  <a href="09-FAQ.md">Frequently Asked Questions →</a> |
  <a href="02-INSTALLATION.md">← Installation</a>
</p>
