# 🚀 Complete Installation - SoftArchitect AI

> **Fecha:** 02/19/2026
> **Estado:** ✅ Updated guide
> **Estimated time:** 20-30 minutes

---

## 📖 Tabla de Contenidos

- [System Requirements](#system-requirements)
- [Quick Installation (Recommended)](#quick-installation-recommended)
- [Complete Manual Installation](#complete-manual-installation)
- [Installation by Operating System](#installation-by-operating-system)
- [Verify the Installation](#verify-the-installation)
- [Troubleshooting](#troubleshooting)

---

## ⚙️ System Requirements

### Minimum Hardware
- **CPU:** Modern processor (Intel/AMD, 2+ cores)
- **RAM:** 8 GB minimum, 16 GB recommended
- **Storage:** 10 GB free space
- **Connection:** Internet for initial setup

### Required Software

#### Option 1: With Docker (⭐ Recommended)
- **Docker Desktop** 4.20+
- **Docker Compose** included in Docker Desktop
- Your web browser

#### Option 2: Local (Without Docker)
- **Python** 3.12+
- **Flutter** 3.38.9+ (Dart 3.10.8+, optional if using desktop)
- **Node.js** 18+ (for some tools)

---

## 🚀 Quick Installation (Recommended)

### If you have Docker installed:

```bash
# 1️⃣ Clone the repository
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2️⃣ Start the services (Docker)
docker-compose up -d

# 3️⃣ Wait 30 seconds and open your browser
# The application will be available at:
# 🌐 http://localhost:3000

# 4️⃣ Done! Start your first project
```

### ⏱️ Total time: ~2 minutes

**Need to stop later?**
```bash
docker-compose down
```

---

## 🔧 Complete Manual Installation

### Step 1: Clone the Repository

```bash
# Open terminal/PowerShell
cd ~  # Or your preferred folder
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai
```

**Don't have Git installed?**
→ Download directly: https://github.com/Pitcher755/soft-architect-ai/archive/develop.zip

---

### Step 2: Install Python Dependencies

```bash
# Create virtual environment
python3.12 -m venv venv

# Activate the virtual environment
# On Linux/Mac:
source venv/bin/activate

# On Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

**What are dependencies?**
→ Python libraries that the application needs to function

---

### Step 3: Configure Environment Variables

```bash
# Copy example file
cp .env.example .env

# Edit with your favorite editor
# On Linux/Mac:
nano .env

# On Windows:
notepad .env
```

**Essential variables:**
```env
# Local model (Ollama)
OLLAMA_BASE_URL=http://localhost:11434
MODEL_NAME=mistral

# App port (leave default)
APP_PORT=3000

# Local data
DATA_DIR=./data
```

---

### Step 4: Start Ollama (if using local model)

#### If you plan to use Ollama:

```bash
# 1. Download Ollama from: https://ollama.ai
# 2. Install and run: ollama serve

# 3. In another terminal, download model:
ollama pull mistral

# 4. Verify it works:
ollama list  # Should show "mistral"
```

**Prefer using cloud?**
→ Skip this step and configure GROQ_API_KEY in .env

---

### Step 5: Start the Application

```bash
# In the terminal with virtual environment activated:
cd src/server
python main.py

# You should see something like:
# ✅ Server started on http://localhost:8000
# ✅ DocumentStore connected
# ✅ LLM Engine ready

# In another terminal, open in browser:
# http://localhost:3000
```

---

## 💻 Installation by Operating System

### 🖥️ Windows

#### Prerequisites
```powershell
# Check Python version
python --version  # Must be 3.12+

# If you don't have it, download from: https://www.python.org/downloads/
```

#### Complete installation

```powershell
# 1. Clone
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2. Virtual environment
python -m venv venv
venv\Scripts\activate

# 3. Dependencies
pip install -r requirements.txt

# 4. Configure
copy .env.example .env
notepad .env  # Edit variables

# 5. Start (in one PowerShell)
cd src/server
python main.py

# 6. In another PowerShell, open browser
start http://localhost:3000
```

**Problem: "Python is not recognized"**
→ Add Python to PATH: https://realpython.com/add-python-to-path/

---

### 🍎 macOS

#### Prerequisites
```bash
# Check Python
python3 --version  # Must be 3.12+

# If you don't have it, use Homebrew:
brew install python@3.12
```

#### Complete installation

```bash
# 1. Clone
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2. Virtual environment
python3.12 -m venv venv
source venv/bin/activate

# 3. Dependencies
pip install -r requirements.txt

# 4. Configure
cp .env.example .env
nano .env  # Edit variables (Ctrl+X to exit)

# 5. Start
cd src/server
python main.py

# 6. In another terminal, open browser
open http://localhost:3000
```

**On M1/M2 Macs:**
```bash
# Ensure ARM architecture support
arch -arm64 python3.12 -m venv venv
```

---

### 🐧 Linux (Ubuntu/Debian)

#### Prerequisites
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python 3.12
sudo apt install python3.12 python3.12-venv python3-pip -y

# Verify installation
python3.12 --version
```

#### Complete installation

```bash
# 1. Clone
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2. Virtual environment
python3.12 -m venv venv
source venv/bin/activate

# 3. Dependencies
pip install -r requirements.txt

# 4. Configure
cp .env.example .env
nano .env  # Edit variables

# 5. Start
cd src/server
python main.py

# 6. In another terminal
firefox http://localhost:3000 &
```

**With Docker (simpler):**
```bash
sudo apt install docker.io docker-compose -y
docker-compose up -d
# Then open http://localhost:3000
```

---

## ✅ Verify the Installation

### Verificación Checklist

After installation, verify everything works:

```bash
# 1️⃣ Is Python correctly installed?
python --version  # Must be 3.12+

# 2️⃣ Were dependencies installed?
pip list | grep -E 'fastapi|chromadb|langchain'
# Should show those packages

# 3️⃣ Does the server start without errors?
cd src/server
python main.py
# Must complete without errors

# 4️⃣ Is the app accessible in the browser?
# Open: http://localhost:3000
# Should see the main interface

# 5️⃣ Can you create a new project?
# Should allow creating and naming a project
```

### Expected Resultado

✅ **Steps 1-3 complete**: Backend working
✅ **Steps 4-5 complete**: Frontend functional
✅ **Everything works**: Preparado para first proyecto

---

## 🚨 Troubleshooting

### Problem 1: "ModuleNotFoundError: No module named 'fastapi'"

**Cause:** Dependencies not installed
**Solution:**

```bash
# Make sure you're in the virtual environment
source venv/bin/activate  # or activate.bat on Windows

# Reinstall dependencies
pip install -r requirements.txt -v
```

---

### Problem 2: "Port 3000 is Already in Use"

**Cause:** Another application uses the same port
**Solution:**

```bash
# Option A: Kill the process
# On Linux/Mac:
lsof -i :3000
kill -9 <PID>

# On Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Option B: Use a different port
# Edit .env and change APP_PORT=3001
```

---

### Problem 3: "Error: ENOENT: no such archivo or directory '.env'"

**Cause:** .env archivo doesn't exist
**Solution:**

```bash
# Create from example
cp .env.example .env
# Edit with your values
```

---

### Problem 4: "ConnectionError: Cannot connect to Ollama"

**Cause:** Ollama is not ejecutarning
**Solution:**

```bash
# Option A: Start Ollama
ollama serve

# Option B: Use Groq (cloud)
# In .env, change to:
USE_GROQ=true
GROQ_API_KEY=your_key_here
```

---

### Problem 5: Docker Won't Start

**Cause:** Docker Desktop is not ejecutarning
**Solution:**

```bash
# Restart Docker
# On Windows/Mac: Close and reopen Docker Desktop

# On Linux:
sudo systemctl restart docker

# Verify it works:
docker --version
docker ps
```

---

## 📱 Access from Devices

### From the same computer:
```
Browser: http://localhost:3000
```

### From another computer on the local network:
```
Replace localhost with your IP
Example: http://192.168.1.100:3000
```

**Find your IP:**
```bash
# Linux/Mac:
ifconfig | grep inet

# Windows:
ipconfig
```

---

## 🔐 Security Considerations

### In Production (DO NOT use as installed)

⚠️ **Changes needed before production:**

1. **Change default passwords**
   ```env
   DB_PASSWORD=your_secure_password
   API_KEY=your_secure_key
   ```

2. **Enable HTTPS**
   ```env
   USE_HTTPS=true
   SSL_CERT=/path/to/certificate.pem
   ```

3. **Restrict CORS**
   ```env
   ALLOWED_ORIGINS=your_domain.com
   ```

4. **Rate limiting**
   ```env
   ENABLE_RATE_LIMIT=true
   MAX_REQUESTS_PER_MINUTE=60
   ```

---

## 🆘 Still Having Issues?

If after all these steps you still have problems:

### 1️⃣ Review the error log:
```bash
# The server displays the error in the terminal
# Copy the exact error message
```

### 2️⃣ Open a GitHub Issue:
https://github.com/Pitcher755/soft-architect-ai/issues/new

**Include:**
- Operating system and version
- Python version
- Exact error message (copy-paste)
- Steps you ejecutard

### 3️⃣ Or contact the team:
- Email: architect@softarchitectai.com
- Community: Discord (coming soon)

---

## ✅ Siguiente Step

Once installed and ejecutarning:

🎯 **[Crear Your First Proyecto →](03-FIRST_PROJECT.md)**

You'll learn to:
- Crear a nuevo proyecto
- Define the vision
- Ejecutar PHASE 1 of the Master Workflow

---

## 📚 Quick Reference

| Command | Purpose |
|---------|---------|
| `docker-compose up -d` | Start services |
| `docker-compose down` | Stop services |
| `source venv/bin/activate` | Activate environment (Linux/Mac) |
| `venv\Scripts\activate` | Activate environment (Windows) |
| `pip install -r requirements.txt` | Install dependencies |
| `python main.py` | Start server |
| `ollama pull mistral` | Download local model |

---

<p align="center">
  ✅ Installation completed successfully
  <br/>
  🎯 Preparado para: <a href="03-FIRST_PROJECT.md"><strong>Crear Your First Proyecto</strong></a>
</p>
