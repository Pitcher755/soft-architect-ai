### 🏗️ The Development Architecture ("The Setup")

* **Your Laptop:** Only has VS Code installed. No code, no Docker, no Python, no Ollama.
* **Your HomeLab:** Has the repository cloned, Docker running, AI models downloaded, and the development environment.
* **The Tunnel:** VS Code connects via SSH and shows you the server's files as if they were on your hard drive.

---

### 🚀 Step by Step: How to Set It Up

#### 1. Prepare the HomeLab (The Server)

I assume your HomeLab runs Linux (Ubuntu/Debian/Zorin).

* Make sure you have SSH access from your laptop.
* Install **Docker** and **Git** on the HomeLab.
* Create the project folder: `mkdir ~/proyectos/softarchitect`.

#### 2. Prepare Your Laptop (The Client)

1. Open VS Code.
2. Go to Extensions and install: **"Remote - SSH"** (by Microsoft).
3. Press `F1` (or `Ctrl+Shift+P`) and type: `Remote-SSH: Connect to Host...`
4. Enter: `usuario@ip-de-tu-homelab` (e.g., `javier@192.168.1.50`).
5. It will ask for the password (or use SSH key if configured).

#### 3. The Magic ✨

Once connected, you'll see in the bottom left corner of VS Code it says green: `SSH: ip-de-tu-homelab`.

1. In VS Code, click "Open Folder".
2. Surprise! You're not browsing your laptop, you're browsing the HomeLab's files.
3. Open the integrated terminal in VS Code (`Ctrl + ñ`). **That terminal is your HomeLab's terminal**.

Now, run in that integrated terminal:

```bash
git clone https://github.com/tu-usuario/SoftArchitect-AI.git .
docker compose up -d

```

**Result:** Everything (Ollama, ChromaDB, Backend) is running on the server. Your laptop isn't consuming RAM or storing files.

---

### ⚠️ The "Trick" with Flutter (Pay Attention to This)

Here's where things get interesting. Flutter usually needs a screen to display the app (Android emulator or a Windows window). If the code is on the server (which has no screen), how do you see the app?

You have two options for this TFM:

#### Option A: Web Development (Recommended for this setup)

Flutter has excellent Web support.

1. In the remote terminal (in VS Code), run:
```bash
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

```


2. VS Code will detect that port 8080 has opened on the server and will offer **"Forward Port"** (Port Forwarding).
3. Open `localhost:8080` in your laptop's browser and **you'll see the app working**.
* *Advantage:* Everything remains 100% on the server.
* *Disadvantage:* You're testing the Web version, not the native desktop version, but for functional development it's identical.



#### Option B: Hybrid Development (Only Front on Local)

If *you need* to compile the Windows `.exe` or Android `.apk`:

* You'd have to have the Flutter code on your laptop and the Backend/AI on the HomeLab.
* Configure the API URL in Flutter to point to `http://ip-del-homelab:8000`.

**My advice:** For the TFM and to fulfill your desire for "everything on the HomeLab", use **Option A (Web)** during development. Only if at the end you want to generate the desktop executable, do a temporary `git clone` on your laptop just to compile the `release`.

### ✅ Daily Workflow Summary

1. Turn on laptop.
2. Open VS Code -> Click "Connect to Host".
3. Terminal: `docker compose up`.
4. Terminal: `flutter run -d web-server`.
5. Program calmly on the couch while the HomeLab sweats compiling and moving the AI.

---

### ⚙️ Critical Environment Configurations (HomeLab)

For the experience to be smooth as silk, run these adjustments once on your server (SSH terminal):

#### 1. Docker without `sudo` (Vital for VS Code)

VS Code tries to run Docker commands with your user. If it needs `sudo` every time, it will fail silently.

```bash
# Apply changes without restarting
newgrp docker
# Test that it works (should say "Hello from Docker!")
docker run hello-world

```

#### 2. VS Code Extensions on the Remote

When you connect via SSH, you'll see that your local extensions appear grayed out or with a button "Install in SSH: HomeLab".
**You must install on the remote:**

* **Flutter** (Dart-Code.flutter)
* **Dart** (Dart-Code.dart-code)
* **Docker** (ms-azuretools.vscode-docker)
* **Python** (ms-python.python)
* *(Optional but recommended)* **GitHub Copilot**

#### 3. Git Credential Manager (To not enter password every time)

Since you're on a server without a graphical environment, Git can't open a window to ask for login.

* **Pro Option:** Configure your GitHub SSH key on the HomeLab.
```bash
ssh-keygen -t ed25519 -C "tu_email@ejemplo.com"
cat ~/.ssh/id_ed25519.pub
# Copy the result and paste it in GitHub -> Settings -> SSH Keys

```


* **Quick Option:** Configure the credential storage helper:
```bash
git config --global credential.helper store
# The next time you do git push it will ask for pass once and save it forever.

```



#### 4. Increase File Watchers

Flutter and VS Code watch thousands of files. The default limit on Linux is low and can cause strange errors.

```bash
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

```

---

### 📝 Notes about Tailscale (Access from outside home)

* **Magic IPs:** Tailscale assigns a fixed IP (e.g., `100.x.y.z`) to your HomeLab. ALWAYS use this IP in VS Code Remote-SSH, even when you're at home. This way you don't have to change the configuration if you go to a coffee shop.
* **MagicDNS:** If you activate MagicDNS in the Tailscale panel, you can connect using the machine name: `ssh usuario@homelab` instead of the IP. Much easier to remember.

---

## 7. AI Engine Deployment (Ollama)

### 7.1. Docker Compose Configuration
Minimum configuration to validate hardware on the HomeLab. This service exposes the Ollama API on port 11434.

```yaml
version: '3.8'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: sa_ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_models:/root/.ollama
    restart: always
    # Uncomment if NVIDIA GPU is configured on the host
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: 1
    #           capabilities: [gpu]

volumes:
  ollama_models:

```

### 7.2. Hardware Validation ("The Fire Test")

Procedure to verify the server's inference capacity.

1. **Start the service:**
```bash
docker compose up -d

```


2. **Download the test model (Phi-3.5 Mini):**
Chosen for its low weight (~2.4GB) and speed, ideal for verifying the pipeline without long waits.
```bash
docker exec -it sa_ollama ollama pull phi3.5

```


3. **Inference Test (Smoke Test):**
Run a simple prompt to verify latency and operation.
```bash
docker exec -it sa_ollama ollama run phi3.5 "Hello, introduce yourself briefly."

```


4. **(Future) Production Model:**
Once the infrastructure is validated, the code-specialized model will be downloaded:
```bash
docker exec -it sa_ollama ollama pull qwen2.5-coder:7b

```
---

## 8. Intelligence Engine Configuration (Provider Selector)

SoftArchitect AI can work in two modes. Choose the one that fits your hardware by editing the `.env` file.

### Option A: Local Mode (Total Privacy) 🔒
*Recommended for:* Modern laptops (M1/M2/M3, Ryzen 5000+, Intel 11th+) or PCs with NVIDIA GPU.
*Requirement:* Have Ollama running (`docker compose up`).

```bash
# .env file
LLM_PROVIDER=local
OLLAMA_BASE_URL=[http://host.docker.internal:11434](http://host.docker.internal:11434)
MODEL_NAME=qwen2.5-coder:7b

```

## Option B: Cloud Mode (Extreme Speed) ⚡
*Recommended for:* Old HomeLabs, Raspberry Pi, or fast development without consuming local battery. Requirement: A free API Key from Groq Console.

```Bash
# .env file
LLM_PROVIDER=cloud
GROQ_API_KEY=gsk_tucodigosecreto...
MODEL_NAME=llama-3.1-8b-instant
Note: The change is instantaneous upon restarting the backend container (docker restart sa_api).

---

## 9. Environment Management with CasaOS and Automation (n8n)

Since the HomeLab uses **CasaOS** as the management interface, the configuration of critical containers like **n8n** must be done through its UI to ensure persistence and external connectivity.

### 9.1. n8n Installation and Configuration
To enable "Docs-as-Code" automation (Git -> Notion Synchronization), n8n requires a specific configuration that differs from the standard docker-compose.

**Configuration in CasaOS UI:**
Access `Settings` of the n8n container and configure:

1.  **Startup Command (Tunneling):**
    * For GitHub to send Webhooks to the local server without opening ports on the router, n8n's native tunnel is used.
    * **Field `Command`:** `start --tunnel`

2.  **Data Persistence (Volumes):**
    * It is critical to map the volume correctly to not lose Workflows upon restart.
    * **Host Path:** `/DATA/AppData/n8n` (CasaOS native path).
    * **Container Path:** `/home/node/.n8n` (Strict internal path).

### 9.2. Essential Workflows
The system has an active automation flow:
* **Name:** `Docs Sync (Git -> Notion)`
* **Function:** Listens to `push` events on GitHub, detects changes in Markdown files and updates the Knowledge Base in Notion.
* **Troubleshooting:** If Notion gives connection error, verify that the database ID is passed as "Expression" (fixed text) and not through the dynamic selector in the UI.

## 10. Advanced Configuration: Linux Environment with NVIDIA (GPU Mode)

If you deploy the project on a Linux machine with a dedicated graphics card (NVIDIA), follow these steps to enable hardware acceleration (CUDA).

### 10.1. Host Prerequisites
Having Docker is not enough. You need the bridge between Docker and your graphics card.

1.  **Install NVIDIA Container Toolkit:**
    ```bash
    curl -fsSL [https://nvidia.github.io/libnvidia-container/gpgkey](https://nvidia.github.io/libnvidia-container/gpgkey) | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L [https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list](https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list) | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
    ```

2.  **Verification:**
    Run `sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi`. You should see a table with your graphics card details.

### 10.2. Stack Deployment
In the `infrastructure` folder, make sure the `docker-compose.yml` has the `deploy` section of the `ollama` service uncommented.

```bash
cd infrastructure
docker compose up -d
```
````