# 🚀 Quick Start - SoftArchitect AI

> **Reading Time:** 15 minutes
> **Level:** Beginner
> **Requirements:** Nothing, we'll start from scratch

---

## 📌 What is SoftArchitect AI?

SoftArchitect AI is your **personal software architect**. It's an application that guides you step-by-step to **transform ideas into professional technical architecture** without all the overwhelming decisions.

### Instead of:
❌ "What stack should I use? Flutter or React? FastAPI or Django? PostgreSQL or MongoDB?"

### It helps you:
✅ Define first **WHAT** you'll build (vision)
✅ Then **WHY** in each decision (security, scalability)
✅ Then **HOW** (technical architecture)
✅ Finally **WHEN** and **WITH WHAT QUALITY**

---

## ⚡ Installation (2 minutes)

### Option 1: Docker (Recommended)

```bash
# 1. Clone the project
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2. Start services
docker compose -f infrastructure/docker-compose.yml --env-file .env up -d

# 3. Open the application
# URL: http://localhost:5000
# Wait 30 seconds for everything to start
```

### Option 2: Local Installation

```bash
# Prerequisites: Flutter 3.38.9+ (Dart 3.10.8+), Python 3.12+

# 1. Backend
cd src/server
pip install -r requirements.txt
python -m uvicorn app.main:app --reload

# 2. Frontend (in another terminal)
cd src/client
flutter run -d windows/macos/linux
```

---

## 🎯 Your First Project (5 minutes)

### Step 1: Open the App

Go to **http://localhost:5000** (or run Flutter)

You'll see the home screen:

```
┌────────────────────────────┐
│ 🏗️ SoftArchitect AI        │
├────────────────────────────┤
│  + CREATE NEW PROJECT      │
│    My Projects             │
│    Settings                │
└────────────────────────────┘
```

### Step 2: Create a Project

Click on **"+CREATE NEW PROJECT"**

Fill in:
- **Name:** "My Notes App" (or whatever idea you have)
- **Description:** "App for teams to share notes during meetings" (2-3 lines)

Click **CREATE**

### Step 3: Start the Conversation

The app will show you the chat view with a message:

> **SoftArchitect AI:**
> "Hi, I see you want to create 'My Notes App'. Tell me more about your vision: Who will use it? What problem does it solve?"

### Step 4: Respond

Type in the chat box:

> "It's an app for my work team to share notes during meetings. Everyone can edit at the same time. It should be fast and secure."

Click **SEND** (or press Ctrl+Enter)

### Step 5: Watch the Magic 🪄

The AI will analyze your answer and generate:

✅ **PROJECT_MANIFESTO.md**
- Your vision in a professional document
- Project principles
- User promise

✅ **AGENTS.md**
- Project roles
- Responsibilities

✅ **USER_JOURNEY_MAP.md**
- How your end user uses the app
- Context and needs

---

## 📚 The Master Workflow (4 Phases)

SoftArchitect guides you through 4 sequential phases. Each one answers a question:

### PHASE 1: Governance & Identity
**Question:** "What's the 'Why'?"
**Duration:** 10-15 minutes
**Documents:** 4 (Manifesto, Agents, Rules, User Journey)
**Result:** Everyone understands the vision

### PHASE 2: Specification & Security
**Question:** "What's the 'What'?"
**Duration:** 30 minutes
**Documents:** 3 (Requirements, User Stories, Security Policy)
**Result:** Clear acceptance criteria

### PHASE 3: Technical Architecture
**Question:** "What's the 'How'?"
**Duration:** 45 minutes
**Documents:** 4 (Tech Stack, Structure Map, API Contract, Threat Model)
**Result:** Professional technical architecture

### PHASE 4: Planning & Quality
**Question:** "When? With what quality?"
**Duration:** 20 minutes
**Documents:** 2 (Roadmap Phases, Testing Strategy)
**Result:** Execution plan and success metrics

---

## 💡 Important Tips

### ✅ DO's (Do it this way)

1. **Be specific in your answers**
   - ❌ "Chat app"
   - ✅ "Real-time chat for remote teams of max 50 people"

2. **Follow the phases in order**
   - Don't skip from PHASE 1 to PHASE 3
   - Each phase prepares you for the next

3. **Use the chat for clarifications**
   - "Why do you recommend PostgreSQL and not MongoDB?"
   - The AI will explain its decisions

4. **Download the generated documents**
   - Use them as a reference in your team
   - They're copyrighted to you, do what you want

### ❌ DON'Ts (Don't do this)

1. **Don't ask for code yet**
   - The first 3 phases are pure design
   - If you ask for code before PHASE 4, the AI will tell you (kindly)

2. **Don't change decisions without documenting**
   - If you change from Flutter to React mid-way, update PHASE 3
   - Consistency matters

3. **Don't ignore clarification questions**
   - If the AI asks "Cloud or On-premises?", answer it
   - That affects your entire architecture

---

## 🎨 Interface: What You'll See

### Left Panel (Sidebar)

```
📁 My Notes App
├─ 📄 PHASE 1: Governance ✅ (3 of 4 docs)
├─ 📄 PHASE 2: Specification ⏳ (0 of 3 docs)
├─ 📄 PHASE 3: Architecture 🔒 (Locked)
├─ 📄 PHASE 4: Planning 🔒 (Locked)
├─ 💬 Chat History
└─ ⚙️ Settings
```

### Center Panel (Chat)

- **Top message:** The AI's latest question
- **History:** Your complete conversation (scrollable)
- **Input box:** Where you type
- **SEND button:** Or Ctrl+Enter

### Right Panel (Documents)

- **Preview** of the document the AI just generated
- **DOWNLOAD** button
- **EDIT** button (if you want to tweak it manually)

---

## 🔑 Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Enter` | Send message |
| `Ctrl+D` | Download current document |
| `Ctrl+.` | Open settings |
| `Escape` | Close dialogs |

---

## 🚨 When Something Doesn't Work

### "The AI doesn't understand my question"
→ Be more specific. Instead of "I want scalability", say "I expect 10,000 concurrent users"

### "The chat is slow"
→ It could be ChromaDB (the memory) indexing (first 30 seconds)

### "It disconnected"
→ Reload the page (Ctrl+R). Your chat is auto-saved.

### "I want to start over"
→ Create a new project. The previous one is archived.

---

## 📖 Complete Documentation

To go beyond Quick Start:

- **[Complete Installation Guide](02-INSTALLATION.md)** - All steps for each OS
- **[Master Workflow Detailed](04-MASTER_WORKFLOW.md)** - Deep explanation of each phase
- **[Chat Interface](05-CHAT_INTERFACE.md)** - How to use all options
- **[Real-time Streaming](06-STREAMING.md)** - How AI streaming works
- **[Persistence & Saving](07-PERSISTENCE.md)** - Where your projects are saved
- **[Troubleshooting](08-TROUBLESHOOTING.md)** - FAQ and solutions
- **[Video Tutorials](10-VIDEO_TUTORIALS.md)** - Links to step-by-step videos

---

## 🌟 What's Next?

Now that you know:
1. ✅ How to install the app
2. ✅ How to create a project
3. ✅ How to complete PHASE 1

Your next step:

**→ Continue to PHASE 2 ("Specification & Security")**

The AI will ask you to define functional and non-functional requirements.

---

## 💬 Support

Have questions?

- **GitHub Issues:** [github.com/Pitcher755/soft-architect-ai/issues](https://github.com/Pitcher755/soft-architect-ai/issues)
- **Technical Docs:** See `doc/English/01-PROJECT_REPORT` folder
- **FAQ:** [08-TROUBLESHOOTING.md](08-TROUBLESHOOTING.md)

---

**Welcome to SoftArchitect AI! 🚀 Let's build something extraordinary together.**

*Last updated: 19/02/2026*
