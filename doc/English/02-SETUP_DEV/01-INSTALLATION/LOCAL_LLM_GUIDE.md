# 🧠✨ Guide: 100% Private AI on Your Machine
## Use SoftArchitect with Your Own Local LLM (Zero Cloud, Zero Spies)

<div align="center">

![Privacy](https://img.shields.io/badge/Privacy-100%25_Local-green?style=for-the-badge&logo=shield)
![Zero Cloud](https://img.shields.io/badge/Cloud-Zero_Dependency-blue?style=for-the-badge)
![Cost](https://img.shields.io/badge/Cost-$0_per_month-gold?style=for-the-badge&logo=cashapp)

**🎯 Setup Time:** 10-15 minutes | **💰 Recurring Cost:** $0 | **🔐 Privacy:** Absolute

</div>

---

## 📖 Table of Contents

```
🎬 Introduction ......................... Why local?
🔧 Step 1: Install Ollama ................. The AI engine
🧠 Step 2: Download your "brain" .......... Models by hardware
🔌 Step 3: Connect SoftArchitect .......... .env configuration
🚀 Step 4: Liftoff! ....................... Restart and fly
```

---

## 🎬 Introduction

```
┌─────────────────────────────────────────────────────────────┐
│  🔐 YOUR CODE NEVER LEAVES YOUR MACHINE                  │
│                                                             │
│  ✅ No paid APIs (OpenAI, Anthropic, etc.)                │
│  ✅ No monthly subscriptions                              │
│  ✅ No usage limits                                        │
│  ✅ Works without internet (once downloaded)              │
│  ✅ Ideal for proprietary or confidential code            │
└─────────────────────────────────────────────────────────────┘
```

**🎯 Who can use this?**

- 💻 **Gaming PC with NVIDIA GPU** (GTX 1660+, RTX series)
- 🍎 **Mac with M1/M2/M3/M4 chips** (unified memory is BRUTAL for AI)
- 🖥️ **Workstations with 16GB+ RAM** (works on CPU, slower but viable)

---

## 🔧 Step 1: Install the Engine (Ollama)

> 💡 **What is Ollama?** It's like Docker, but for AI models. It squeezes your GPU to the max and handles all the complexity for you.

### 📥 Installation

<table>
<tr>
<td width="33%" align="center">

**🪟 Windows**

1. Go to [ollama.com](https://ollama.com)
2. Download the `.exe`
3. Double-click and done!

</td>
<td width="33%" align="center">

**🍎 macOS**

1. Go to [ollama.com](https://ollama.com)
2. Download the `.dmg`
3. Drag to Applications

</td>
<td width="33%" align="center">

**🐧 Linux**

\`\`\`bash
curl -fsSL https://ollama.com/install.sh | sh
\`\`\`

</td>
</tr>
</table>

✅ **Verification:** Open your terminal and type:

\`\`\`bash
ollama --version
\`\`\`

If you see a version number (e.g., \`0.1.27\`), perfect! Ollama is running in the background.

---

## 🧠 Step 2: Download Your AI "Brain"

> ⚡ **Important:** The model you choose depends on your hardware. Bigger isn't always better if your GPU can't handle it!

### 🎯 Smart Model Selector

<details>
<summary>🟢 <b>I have 8GB VRAM (or less)</b> - RTX 3060, GTX 1660, Mac M1 with 8GB</summary>

\`\`\`bash
# The perfect balance: fast and very capable
ollama run llama3.1:8b
\`\`\`

**📊 Performance:**
- Speed: ⚡⚡⚡⚡⚡ (Very fast)
- Quality: ⭐⭐⭐⭐ (Comparable to GPT-3.5)
- Download size: ~4.7GB

</details>

<details>
<summary>🟡 <b>I have 12-16GB VRAM</b> - RTX 3080, RTX 4070, Mac M2 Pro</summary>

\`\`\`bash
# The king of programming
ollama run qwen2.5-coder:14b
\`\`\`

**📊 Performance:**
- Speed: ⚡⚡⚡⚡ (Fast)
- Quality: ⭐⭐⭐⭐⭐ (BRUTAL for code)
- Download size: ~9GB
- 🏆 **RECOMMENDED for development**

</details>

<details>
<summary>🔴 <b>I have 24GB+ VRAM</b> - RTX 4090, Mac M2 Max/Ultra with 64GB</summary>

\`\`\`bash
# Beast mode: GPT-4 on your machine
ollama run command-r

# Or the open-source giant
ollama run mixtral:8x7b
\`\`\`

**📊 Performance:**
- Speed: ⚡⚡⚡ (Moderate)
- Quality: ⭐⭐⭐⭐⭐ (GPT-4 level)
- Download size: ~20GB each
- 💎 Professional results

</details>

### 🚀 Download Example

\`\`\`bash
# Run this command and wait 5-10 minutes (depends on your internet)
ollama run llama3.1:8b

# You'll see something like:
# pulling manifest
# pulling 6a0746a1ec1a... 100% ▕████████████████▏ 4.7 GB
# verifying sha256 digest
# success! ✓
\`\`\`

> 💾 **Disk space:** Models are saved in \`~/.ollama/models/\`. Make sure you have enough space.

---

## 🔌 Step 3: Connect SoftArchitect to Your Local Brain

> 🎯 **Goal:** Tell the SoftArchitect backend to use your local model instead of OpenAI/Groq.

### 📝 Edit the \`.env\` file

**Location:** \`soft-architect-ai/.env\` (in the project root)

\`\`\`bash
# ══════════════════════════════════════════════════════════
# ║  🔐 LOCAL LLM CONFIGURATION (100% PRIVATE)           ║
# ══════════════════════════════════════════════════════════

# Provider: Change from "cloud" to "local"
LLM_PROVIDER=local

# Model: The SAME name you used in "ollama run"
LLM_MODEL=llama3.1:8b

# Ollama URL:
# - Docker (Windows/Mac): http://host.docker.internal:11434
# - Docker (Linux): http://172.17.0.1:11434 (or your local IP)
# - Native (no Docker): http://localhost:11434
OLLAMA_BASE_URL=http://host.docker.internal:11434
\`\`\`

### 🐧 Special Cases

<details>
<summary>❓ <b>Linux + Docker:</b> "host.docker.internal" doesn't work</summary>

**Solution 1:** Use Docker's gateway IP
\`\`\`bash
OLLAMA_BASE_URL=http://172.17.0.1:11434
\`\`\`

**Solution 2:** Use your local IP (find it with \`ip addr show\`)
\`\`\`bash
OLLAMA_BASE_URL=http://192.168.1.50:11434  # Change to your IP
\`\`\`

</details>

<details>
<summary>🍎 <b>Mac Apple Silicon:</b> Native Ollama (not Docker)</summary>

If you installed Ollama directly on macOS (without Docker):
\`\`\`bash
OLLAMA_BASE_URL=http://host.docker.internal:11434
\`\`\`

> 💡 See [Hardware Acceleration Guide](HARDWARE_ACCELERATION_GUIDE.md) for advanced Mac configuration.

</details>

---

## 🚀 Step 4: Liftoff!

### Restart to apply changes

\`\`\`bash
# 1️⃣ Stop current containers
docker compose down

# 2️⃣ Start with new configuration
docker compose up -d

# 3️⃣ Verify everything started correctly
docker compose ps
\`\`\`

**✅ You should see something like:**

\`\`\`
NAME                STATUS              PORTS
sa_ollama          Up 30 seconds       0.0.0.0:11434->11434/tcp
sa_server          Up 30 seconds       0.0.0.0:8000->8000/tcp
sa_chroma          Up 30 seconds       0.0.0.0:8001->8001/tcp
\`\`\`

---

## 🎉 DONE! Test Your Local AI

\`\`\`
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   🎯 Open the Flutter application                          │
│   💬 Create a new project                                  │
│   🤖 Ask the AI Architect a question                       │
│   ⚡ BOOM! Instant response from YOUR machine              │
│                                                             │
│   🔐 Your code NEVER left your local network               │
│   💰 Cost: $0.00                                           │
│   🚀 Speed: Limited only by your hardware                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
\`\`\`

### 🔍 Troubleshooting

<details>
<summary>❌ <b>Error: "Cannot connect to Ollama"</b></summary>

**Check this:**

\`\`\`bash
# 1. Is Ollama running?
curl http://localhost:11434/api/tags

# 2. Does the model exist?
ollama list

# 3. Is the model name in .env EXACT?
cat .env | grep LLM_MODEL
\`\`\`

If everything fails, restart Ollama:
- **Windows/Mac:** Close Ollama from systray and open it again
- **Linux:** \`sudo systemctl restart ollama\`

</details>

<details>
<summary>🐌 <b>Responses are very slow</b></summary>

**Possible causes:**

1. **GPU not detected:** See [Hardware Acceleration Guide](HARDWARE_ACCELERATION_GUIDE.md)
2. **Model too large for your VRAM:** Try \`llama3.1:8b\` or even \`llama3.2:3b\`
3. **CPU struggling:** Close other heavy programs (Chrome with 50 tabs, editors, etc.)

</details>

---

## 📚 Related Links

<table>
<tr>
<td width="50%">

### 🔗 Related Documentation

- 🚀 [Hardware Acceleration Guide](HARDWARE_ACCELERATION_GUIDE.md)
- ⚙️ [Complete Setup Guide](SETUP_GUIDE.md)
- 🛠️ [Tools and Stack](TOOLS_AND_STACK.md)

</td>
<td width="50%">

### 🆘 Need Help?

- 💬 [GitHub Discussions](https://github.com/Pitcher755/soft-architect-ai/discussions)
- 🐛 [Report a Bug](https://github.com/Pitcher755/soft-architect-ai/issues)
- 📖 [Complete Documentation](../../../INDEX.md)

</td>
</tr>
</table>

---

<div align="center">

**🎊 Congratulations! You now have an AI Architect running 100% on your machine 🎊**

*Your privacy is priceless. Your code stays with you.*

</div>
