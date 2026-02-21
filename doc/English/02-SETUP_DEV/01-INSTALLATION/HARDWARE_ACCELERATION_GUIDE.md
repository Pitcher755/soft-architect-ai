# 🚀🔥 Guide: Supercharge Your AI with GPU
## Hardware Acceleration for Local LLMs - Squeeze Every Drop from Your Machine

<div align="center">

![GPU Power](https://img.shields.io/badge/GPU-10x_Faster-red?style=for-the-badge&logo=nvidia)
![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20Linux%20%7C%20macOS-blue?style=for-the-badge)
![Difficulty](https://img.shields.io/badge/Difficulty-Medium-yellow?style=for-the-badge)

**⚡ GPU vs CPU:** 10-50x faster | **🎯 Platforms:** Windows, Linux, macOS | **⏱️ Setup:** 15-30 min

</div>

---

## 📋 Table of Contents
- [Introduction](#-introduction)
- [Option 1: Windows/Linux + NVIDIA GPU](#-option-1-windowslinux--nvidia-gpu)
- [Option 2: Mac with Apple Silicon](#-option-2-mac-with-apple-silicon)
- [Option 3: Computers without dedicated GPU](#-option-3-no-gpu---survival-plan)
- [Comparison Table](#-comparison-table-choose-your-path)
- [Model Selection](#-model-download-which-to-choose)

---

## 🎯 Introduction

### Why do you need GPU?

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    ⚡ GPU vs CPU PERFORMANCE                            │
├─────────────────────────────────────────────────────────────────────────┤
│  💻 CPU (Basic):        2-5 tokens/second    😴 Slow, visible delay    │
│  🚀 GPU (Accelerated):  50-100 tokens/sec    ⚡ Instant, professional  │
│                                                                         │
│  📊 DIFFERENCE:  10-50x FASTER                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Who can use this guide?**
- 🪟 PC with NVIDIA GPU (RTX 2060 or higher)
- 🐧 Linux workstation with dedicated GPU
- 🍎 Mac with Apple Silicon (M1, M2, M3, M4)

**⚠️ Important:** Each platform has a **different configuration**. Choose your option below.

---

## 🏆 Choose Your Option
Click on your system for detailed instructions:

| Option | System | Performance | Setup Time |
|--------|--------|-------------|------------|
| **[Option 1](#-option-1-windowslinux--nvidia-gpu)** | Windows/Linux + NVIDIA | ⚡⚡⚡⚡⚡ Maximum | 20 min |
| **[Option 2](#-option-2-mac-with-apple-silicon)** | Mac Apple Silicon | ⚡⚡⚡⚡ Excellent | 15 min |
| **[Option 3](#-option-3-no-gpu---survival-plan)** | Any (CPU only) | ⚡ Basic | 5 min |

---

## 💎 Option 1: Windows/Linux + NVIDIA GPU

### 🏅 GOLD STANDARD OPTION (MAXIMUM PERFORMANCE)

**Advantages:**
- ✅ Maximum performance (RTX 4090 = 100+ tokens/second)
- ✅ Docker handles everything automatically
- ✅ Easy to maintain and configure

---

### Prerequisites

<table>
<tr>
<td width="50%">

**🪟 Windows**
- Docker Desktop installed
- WSL2 enabled
- Recent NVIDIA drivers
- **GPU:** RTX 2060 or higher

> 💡 **Note:** Docker Desktop on Windows
> already includes automatic GPU support

</td>
<td width="50%">

**🐧 Linux**
- Docker installed
- NVIDIA drivers installed
- **GPU:** GTX 1660 or higher

> ⚠️ **Linux Requirement:**
> You need to install Container Toolkit:

</td>
</tr>
</table>

---

### 1️⃣ Install Container Toolkit (Linux only)

```bash
# Add NVIDIA repository
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Restart Docker
sudo systemctl restart docker
```

**Verify:**
```bash
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```
✅ If you see your GPU info, **PERFECT!**

---

### 2️⃣ Configuration of `docker-compose.yml`

**File:** `infrastructure/docker-compose.yml`

Find the service `ollama-service` and make sure it looks like this:

```yaml
ollama-service:
  image: ollama/ollama:latest
  container_name: ollama-local
  ports:
    - "11434:11434"
  volumes:
    - ./data/ollama_models:/root/.ollama
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: all
            capabilities: [gpu]

# ⚠️ THIS IS THE CRITICAL PART ⚠️
# The "deploy" block must be correctly indented
```

**Important:** The block `deploy.resources.reservations.devices` must be indented correctly _(2 spaces per level)_.

---

### 3️⃣ Configuration of `.env`

**File:** `src/server/.env`

```ini
# Local provider
LLM_PROVIDER=local

# Ollama URL in Docker (use the service name)
OLLAMA_BASE_URL=http://ollama-service:11434

# Model (download whichever you want)
OLLAMA_MODEL=llama3.1:8b
```

---

### 4️⃣ Restart Docker

```bash
# Stop services
docker compose -f infrastructure/docker-compose.yml down

# Start with GPU
docker compose -f infrastructure/docker-compose.yml up -d
```

---

### 5️⃣ Verify Ollama sees the GPU

```bash
docker exec -it ollama-local nvidia-smi
```

**If you see your GPU info (name, temperature, VRAM):**
```
✅ PERFECT! You are using hardware acceleration
```

---

## 🍎 Option 2: Mac with Apple Silicon

### 🦁 BEAST MODE - UNIFIED MEMORY

**Why M chips are BRUTAL for AI:**

**Unified Memory** = CPU RAM + GPU VRAM are the same thing.

- ✅ It's like having 32GB/64GB/128GB of VRAM (impossible on PC GPUs)
- ✅ You can run GIANT models (70B parameters on Mac Studio)
- ✅ Incredible memory access speed (400+ GB/s bandwidth)
- ✅ Superior energy efficiency (M4 Max = RTX 4090 performance at 40W)

---

### ⚠️ STOP RIGHT THERE! Special Configuration Required

<table>
<tr>
<td width="50%" bgcolor="#ffe6e6" style="color: #2d3436;">

**❌ DO NOT Do This**
- ❌ DO NOT use Ollama in Docker
- ❌ Docker Desktop CANNOT use Apple GPU efficiently
- ❌ You will lose 90% of performance

</td>
<td width="50%" bgcolor="#e6ffe6" style="color: #2d3436;">

**✅ YES Do This**
- ✅ Install NATIVE Ollama on macOS
- ✅ Run outside Docker
- ✅ Connect Docker to native Ollama
- ✅ 100% performance available

</td>
</tr>
</table>

---

### 📖 Step-by-Step Guide (Mac)

#### 1️⃣ Install Native Ollama

**Option A: Download from website**
1. Download the `.app` from [ollama.com/download](https://ollama.com/download)
2. Drag to Applications
3. Open it

**Option B: Homebrew**
```bash
brew install ollama
```

#### 2️⃣ Start server

In a terminal (NOT Docker):
```bash
ollama serve
```

**Verification:**
- You should see Ollama icon (alpaca) in the top bar
- Test: `curl http://localhost:11434/api/tags` → Should respond with JSON

---

#### 3️⃣ Disable Ollama in Docker

**Edit:** `infrastructure/docker-compose.yml`

**Option A: Comment out the entire block:**
```yaml
# ─────────────────────────────────────────────────
# 🍎 OLLAMA DISABLED - Using native macOS
# ─────────────────────────────────────────────────
#  ollama-service:
#    image: ollama/ollama:latest
#    ...entire block commented...
```

**Option B: Remove the service completely**
Delete the entire `ollama-service` block.

---

#### 4️⃣ Connect Docker to Native Ollama

**Location:** `src/server/.env`

```ini
# Local provider
LLM_PROVIDER=local

# 🍎 SPECIAL URL for Mac
OLLAMA_BASE_URL=http://host.docker.internal:11434

# Model (download whichever you want with `ollama pull`)
OLLAMA_MODEL=llama3.1:8b
```

**How it works:** `host.docker.internal` is a magic address that Docker uses to communicate with the host (your Mac).

---

#### 5️⃣ Download a Model

In a macOS terminal (NOT Docker):
```bash
ollama pull llama3.1:8b
```

**For Macs with 32GB or more RAM, try large models:**
```bash
ollama pull qwen2.5-coder:14b      # Coding
ollama pull command-r:35b          # General
ollama pull deepseek-coder-v2:16b  # Pro coding
```

---

#### 6️⃣ Restart Backend

```bash
docker compose -f infrastructure/docker-compose.yml restart backend-server
```

---

#### 7️⃣ Verify connection from Docker

```bash
docker exec -it backend-server curl http://host.docker.internal:11434/api/tags
```
✅ If you see your models listed: **PERFECT!**

---

### 🎯 Expected Performance

| Mac Model | Speed | Experience |
|-----------|-------|------------|
| M1 (8GB) | 20-30 tokens/second | Instant responses, fluid |
| M2 Pro (16GB) | 40-60 tokens/second | Instant responses, professional |
| M3 Max (36GB) | 60-100 tokens/second | RTX 4070 equivalent |
| M4 Max (128GB) | 100-150 tokens/second | RTX 4090 equivalent |

---

## 🐌 Option 3: No GPU - Survival Plan

### When does this apply?

- 💼 Office PC without dedicated graphics
- 💻 Laptop with integrated graphics (Intel HD, AMD Vega)
- 🍎 Old Intel Mac (pre-M1)
- 🖥️ Workstation without dedicated GPU

---

### Realistic Expectations

```
┌─────────────────────────────────────────────────────────────┐
│               ⚠️ SPEED WITH CPU                            │
├─────────────────────────────────────────────────────────────┤
│  Tiny models (1-3B):  2-5 tokens/second                    │
│                       😐 Watch words come out one by one    │
│                                                             │
│  Medium models (7B):  0.5-2 tokens/second                  │
│                       😴 Minimalist experience              │
│                                                             │
│  Large models (13B+): 0.1-0.5 tokens/second                │
│                       💀 Acceptable but limited capability  │
└─────────────────────────────────────────────────────────────┘
```

---

### Strategy 1️⃣: Minimalist Models (Local)

Use ULTRA small models designed for CPU:

```bash
ollama pull tinyllama:1b      # The smallest viable (1GB RAM)
ollama pull phi3:mini         # Very small but more capable (2GB)
ollama pull gemma2:2b         # Balance CPU-friendly (2GB)
```

**Configuration `src/server/.env`:**
```ini
LLM_PROVIDER=local
OLLAMA_BASE_URL=http://ollama-service:11434
OLLAMA_MODEL=phi3:mini        # Smallest model
```

**In `infrastructure/docker-compose.yml`:**
Make sure the service `ollama-service` does NOT have the `deploy.resources` block (to avoid errors looking for GPU).

> ⚠️ DO NOT include the block with `devices: driver: nvidia`

---

### Strategy 2️⃣: Use the Cloud (RECOMMENDED)

**Reality:** If you do not have GPU, CPU experience will be frustrating. Using cloud APIs is more practical.

**Best option: [Groq](https://groq.com) - FREE and ULTRA FAST**
- ⚡⚡⚡⚡⚡ Like having an RTX 4090... in the cloud
- 🆓 Generous free plan (6,000+ requests daily)
- 💰 **Cost:** $0 (free) up to thousands of queries

---

#### Quick Guide

1️⃣ **Get your API Key FREE:**
- Visit [console.groq.com](https://console.groq.com)
- Create account
- Copy your API key

2️⃣ **Edit your `.env`:**
```ini
LLM_PROVIDER=groq
GROQ_API_KEY=your_key_here
GROQ_MODEL=llama-3.1-70b-versatile
```

3️⃣ **Restart:**
```bash
docker compose -f infrastructure/docker-compose.yml restart backend-server
```

✅ **Enjoy RTX 4090 speed from your office laptop!**

---

## 📊 Comparison Table: Choose Your Path

### Quick Decision Guide

| Hardware | System | Performance | Recommended Method | Ollama URL | Notes |
|----------|--------|-------------|-------------------|-----------|-------|
| **NVIDIA GPU** | Windows | ⚡⚡⚡⚡⚡ Maximum | Docker with GPU | `http://ollama-service:11434` | Requires Container Toolkit |
| **NVIDIA GPU** | Linux | ⚡⚡⚡⚡⚡ Maximum | Docker with GPU | `http://ollama-service:11434` | Install nvidia-container-toolkit |
| **Apple Silicon** | Mac M1/M2/M3/M4 | ⚡⚡⚡⚡ Excellent | Native Ollama | `http://host.docker.internal:11434` | DO NOT use Docker for Ollama |
| **Intel/AMD (No GPU)** | Any | ⚡ Basic | Tiny Models or Groq | `http://ollama-service:11434` | Tiny Models or better: Groq Cloud |

---

## 🎯 Model Download: Which to Choose

### Decision Matrix

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                  MODEL SELECTION BY HARDWARE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ VRAM/RAM    │ Model               │ Speed    │ Quality │ Usage             │
├─────────────┼─────────────────────┼──────────┼─────────┼───────────────────┤
│ 8GB         │ llama3.1:8b         │ ⚡⚡⚡    │ ⭐⭐⭐⭐ │ General           │
│ 8GB         │ phi3:mini           │ ⚡⚡⚡⚡  │ ⭐⭐⭐   │ General           │
│ 12-16GB     │ qwen2.5-coder:14b   │ ⚡⚡⚡    │ ⭐⭐⭐⭐⭐│ Coding            │
│ 12-16GB     │ llama3.1:13b        │ ⚡⚡⚡    │ ⭐⭐⭐⭐ │ General Pro       │
│ 24GB+       │ command-r:35b       │ ⚡⚡      │ ⭐⭐⭐⭐⭐│ Intelligence Pro  │
│ 24GB+       │ mixtral:8x7b        │ ⚡⚡      │ ⭐⭐⭐⭐⭐│ Multilingual      │
│ Mac Beast   │ llama3.1:70b        │ ⚡⚡      │ ⭐⭐⭐⭐⭐│ M3/M4 Max 64GB+   │
│ Ultimate    │ qwen2.5:72b         │ ⚡        │ ⭐⭐⭐⭐⭐│ M4 Max 128GB only │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### How to Download

**Example:**
```bash
# Download and start a model
ollama pull llama3.1:8b

# See your downloaded models
ollama list

# Remove a model you do not use
ollama rm old-model-name
```

**Pro Tip:** Do not forget to update `OLLAMA_MODEL` in your `.env` after downloading a new model.

---

## 🔗 Related Links

| Guide | Description |
|-------|-------------|
| [LOCAL_LLM_GUIDE.md](LOCAL_LLM_GUIDE.md) | Base guide to install Ollama |
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | Complete project configuration |
| [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) | Troubleshooting |
| [TOOLS_AND_STACK.md](TOOLS_AND_STACK.md) | Complete technical stack |

---

<div align="center">

## 🎊 Hardware Configuration Completed!

Your GPU is ready to crush any AI task.

**Problems?** Open an [issue on GitHub](https://github.com/your-repo/issues).

</div>
