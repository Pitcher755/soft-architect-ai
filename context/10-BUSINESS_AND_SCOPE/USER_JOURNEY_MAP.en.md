# 🗺️ User Journey Map (User Journey)

> **Persona:** Javier (Senior Dev & Architect).
> **Goal:** Create a robust MVP in Flutter/Python without wasting time on boilerplate or trivial decisions.

---

## 1. Installation and Onboarding Phase (Day 0)

| Step | User Action | System Response (SoftArchitect) | Touchpoints |
| :--- | :--- | :--- | :--- |
| **1.1** | Downloads and runs the installer `.AppImage` (Linux). | Shows **Splash** screen and checks prerequisites (Docker, GPU). | UI: Splash Screen |
| **1.2** | Selects "Local Mode" (Maximum Privacy). | Starts Docker containers (`ollama`, `chroma`) in the background. Shows "Green Light". | UI: Setup Wizard |
| **1.3** | Configures API Keys (optional for Groq). | Saves secrets in local Secure Storage. | UI: Settings Modal |

---

## 2. Project Creation Phase (The Setup)

| Step | User Action | System Response | Touchpoints |
| :--- | :--- | :--- | :--- |
| **2.1** | Clicks "New Project" -> Chooses "Flutter + Python". | Loads the corresponding **Tech Packs** into memory. Starts the interview. | UI: Chat |
| **2.2** | Answers the interview: "Riverpod, Clean Arch, Material 3". | Generates the internal `RULES.md` file and the virtual directory tree. | RAG: Context |
| **2.3** | Asks: "Generate the initial Scaffolding". | Returns a `setup.sh` script or terminal commands to create folders. | Chat: Code Block |

---

## 3. Development Phase (The Loop)

*Repetitive cycle: Requirement -> Code -> Test.*

| Step | User Action | System Response | Touchpoints |
| :--- | :--- | :--- | :--- |
| **3.1** | Describes a feature: "I need a login screen with email/password". | Validates against DoR (Definition of Ready). If incomplete, asks for more details. | Chat: Validation |
| **3.2** | Provides complete requirements. | Generates the UI code (Flutter Widget) and API endpoint (Python). | Chat: Code Generation |
| **3.3** | Asks: "How do I test this?". | Provides unit tests for the UseCase and integration tests for the API. | Chat: Test Generation |
| **3.4** | Runs tests and they fail. | Analyzes the error and suggests fixes (e.g., "Add @riverpod annotation"). | Chat: Debugging |

---

## 4. Quality Assurance Phase (The Gate)

| Step | User Action | System Response | Touchpoints |
| :--- | :--- | :--- | :--- |
| **4.1** | Clicks "Run QA Checks". | Executes linting, accessibility checks, and OWASP scans. | UI: QA Dashboard |
| **4.2** | Fixes issues based on feedback. | Updates the code suggestions in real-time. | Chat: Iterative Refinement |

---

## 5. Deployment Phase (The Release)

| Step | User Action | System Response | Touchpoints |
| :--- | :--- | :--- | :--- |
| **5.1** | Clicks "Build for Production". | Generates the executable binary and Docker image. | UI: Build Progress |
| **5.2** | Deploys to local environment. | Monitors logs and provides troubleshooting. | UI: Deployment Logs |

---

## Key Principles in the Journey

* **Context Awareness:** The system remembers past decisions and enforces consistency (e.g., "You chose Riverpod, so I'll use it here too").
* **Privacy Indicator:** Always shows if data is leaving the machine (e.g., cloud icon for Groq).
* **Hallucination Prevention:** If the user asks for something outside the stack (e.g., "Use GetX"), the system must respond: "According to `RULES.md`, we use Riverpod. Do you want to proceed the same way?".