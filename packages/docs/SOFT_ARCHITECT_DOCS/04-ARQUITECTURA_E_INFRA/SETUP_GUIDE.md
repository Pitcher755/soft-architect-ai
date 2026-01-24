### 🏗️ La Arquitectura de Desarrollo ("The Setup")

* **Tu Portátil:** Solo tiene VS Code instalado. No tiene código, ni Docker, ni Python, ni Ollama.
* **Tu HomeLab:** Tiene el repositorio clonado, Docker corriendo, los modelos de IA descargados y el entorno de desarrollo.
* **El Túnel:** VS Code se conecta por SSH y te muestra los archivos del servidor como si estuvieran en tu disco duro.

---

### 🚀 Paso a Paso: Cómo configurarlo

#### 1. Prepara el HomeLab (El Servidor)

Asumo que tu HomeLab corre Linux (Ubuntu/Debian/Zorin).

* Asegúrate de tener acceso SSH desde tu portátil.
* Instala **Docker** y **Git** en el HomeLab.
* Crea la carpeta del proyecto: `mkdir ~/proyectos/softarchitect`.

#### 2. Prepara tu Portátil (El Cliente)

1. Abre VS Code.
2. Ve a Extensiones e instala: **"Remote - SSH"** (de Microsoft).
3. Pulsa `F1` (o `Ctrl+Shift+P`) y escribe: `Remote-SSH: Connect to Host...`
4. Introduce: `usuario@ip-de-tu-homelab` (ej: `javier@192.168.1.50`).
5. Te pedirá la contraseña (o usa clave SSH si la tienes configurada).

#### 3. La Magia ✨

Una vez conectado, verás que en la esquina inferior izquierda de VS Code pone verde: `SSH: ip-de-tu-homelab`.

1. En VS Code, dale a "Abrir Carpeta".
2. ¡Sorpresa! No estás navegando por tu portátil, estás navegando por los archivos del HomeLab.
3. Abre la terminal integrada en VS Code (`Ctrl + ñ`). **Esa terminal es la terminal de tu HomeLab**.

Ahora, ejecuta en esa terminal integrada:

```bash
git clone https://github.com/tu-usuario/SoftArchitect-AI.git .
docker compose up -d

```

**Resultado:** Todo (Ollama, ChromaDB, Backend) se está ejecutando en el servidor. Tu portátil no está consumiendo RAM ni guardando archivos.

---

### ⚠️ El "Truco" con Flutter (Ojo a esto)

Aquí es donde la cosa se pone interesante. Flutter suele necesitar una pantalla para mostrar la app (el emulador de Android o una ventana de Windows). Si el código está en el servidor (que no tiene pantalla), ¿cómo ves la app?

Tienes dos opciones para este TFM:

#### Opción A: Desarrollo Web (Recomendada para este setup)

Flutter tiene soporte Web excelente.

1. En la terminal remota (en VS Code), ejecuta:
```bash
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

```


2. VS Code detectará que el puerto 8080 se ha abierto en el servidor y te ofrecerá **"Forward Port"** (Reenvío de puertos).
3. Abres `localhost:8080` en el navegador de tu portátil y **verás la app funcionando**.
* *Ventaja:* Todo sigue 100% en el servidor.
* *Desventaja:* Estás probando la versión Web, no la nativa de escritorio, pero para desarrollo funcional es idéntico.



#### Opción B: Desarrollo Híbrido (Solo el Front en local)

Si *necesitas* compilar el `.exe` de Windows o la `.apk` de Android:

* Tendrías que tener el código de Flutter en tu portátil y el Backend/IA en el HomeLab.
* Configuras la URL de la API en Flutter para que apunte a `http://ip-del-homelab:8000`.

**Mi consejo:** Para el TFM y para cumplir tu deseo de "todo en el HomeLab", usa la **Opción A (Web)** durante el desarrollo. Solo si al final quieres generar el ejecutable de escritorio, haces un `git clone` temporal en tu portátil solo para compilar el `release`.

### ✅ Resumen del Workflow Diario

1. Enciendes portátil.
2. Abres VS Code -> Clic en "Connect to Host".
3. Terminal: `docker compose up`.
4. Terminal: `flutter run -d web-server`.
5. Programas tranquilamente en el sofá mientras el HomeLab suda compilando y moviendo la IA.

---

### ⚙️ Configuraciones Críticas del Entorno (HomeLab)

Para que la experiencia sea fluida como la seda, ejecuta estos ajustes una sola vez en tu servidor (terminal SSH):

#### 1. Docker sin `sudo` (Vital para VS Code)

VS Code intenta ejecutar comandos de Docker con tu usuario. Si necesita `sudo` cada vez, fallará silenciosamente.

```bash
# Añade tu usuario al grupo docker
sudo usermod -aG docker $USER
# Aplica los cambios sin reiniciar
newgrp docker
# Prueba que funciona (debe decir "Hello from Docker!")
docker run hello-world

```

#### 2. Extensiones de VS Code en el Remoto

Cuando te conectas por SSH, verás que tus extensiones locales aparecen en gris o con un botón "Install in SSH: HomeLab".
**Debes instalar en el remoto:**

* **Flutter** (Dart-Code.flutter)
* **Dart** (Dart-Code.dart-code)
* **Docker** (ms-azuretools.vscode-docker)
* **Python** (ms-python.python)
* *(Opcional pero recomendada)* **GitHub Copilot**

#### 3. Git Credential Manager (Para no meter password cada vez)

Como estás en un servidor sin entorno gráfico, Git no puede abrir una ventanita para pedirte login.

* **Opción Pro:** Configura tu clave SSH de GitHub en el HomeLab.
```bash
ssh-keygen -t ed25519 -C "tu_email@ejemplo.com"
cat ~/.ssh/id_ed25519.pub
# Copia el resultado y pégalo en GitHub -> Settings -> SSH Keys

```


* **Opción Rápida:** Configura el helper de almacenamiento de credenciales:
```bash
git config --global credential.helper store
# La próxima vez que hagas git push te pedirá pass una vez y la guardará para siempre.

```



#### 4. Aumentar los "Vigilantes" de Archivos (File Watchers)

Flutter y VS Code observan miles de archivos. El límite por defecto de Linux es bajo y puede causar errores extraños.

```bash
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

```

---

### 📝 Notas sobre Tailscale (Acceso desde fuera de casa)

* **IPs Mágicas:** Tailscale asigna una IP fija (ej: `100.x.y.z`) a tu HomeLab. Usa SIEMPRE esta IP en VS Code Remote-SSH, incluso cuando estés en casa. Así no tienes que cambiar la configuración si te vas a una cafetería.
* **MagicDNS:** Si activas MagicDNS en el panel de Tailscale, puedes conectar usando el nombre de la máquina: `ssh usuario@homelab` en lugar de la IP. Mucho más fácil de recordar.

---

## 7. Despliegue del Motor de IA (Ollama)

### 7.1. Configuración de Docker Compose
Configuración mínima para validar el hardware en el HomeLab. Este servicio expone la API de Ollama en el puerto 11434.

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
    # Descomentar si se dispone de GPU NVIDIA configurada en el host
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

### 7.2. Validación de Hardware ("The Fire Test")

Procedimiento para verificar la capacidad de inferencia del servidor.

1. **Levantar el servicio:**
```bash
docker compose up -d

```


2. **Descargar el modelo de prueba (Phi-3.5 Mini):**
Elegido por su bajo peso (~2.4GB) y velocidad, ideal para verificar la tubería sin esperas largas.
```bash
docker exec -it sa_ollama ollama pull phi3.5

```


3. **Prueba de Inferencia (Smoke Test):**
Ejecutar un prompt simple para verificar latencia y funcionamiento.
```bash
docker exec -it sa_ollama ollama run phi3.5 "Hola, preséntate brevemente."

```


4. **(Futuro) Modelo de Producción:**
Una vez validada la infraestructura, se descargará el modelo especializado en código:
```bash
docker exec -it sa_ollama ollama pull qwen2.5-coder:7b

```
---

## 8. Configuración del Motor de Inteligencia (Selector de Proveedor)

SoftArchitect AI puede funcionar en dos modos. Elige el que se adapte a tu hardware editando el archivo `.env`.

### Opción A: Modo Local (Privacidad Total) 🔒
*Recomendado para:* Portátiles modernos (M1/M2/M3, Ryzen 5000+, Intel 11th+) o PCs con GPU NVIDIA.
*Requisito:* Tener Ollama corriendo (`docker compose up`).

```bash
# Archivo .env
LLM_PROVIDER=local
OLLAMA_BASE_URL=[http://host.docker.internal:11434](http://host.docker.internal:11434)
MODEL_NAME=qwen2.5-coder:7b

```

## Opción B: Modo Cloud (Velocidad Extrema) ⚡
*Recomendado para:*  HomeLabs antiguos, Raspberry Pi, o desarrollo rápido sin consumir batería local. Requisito: Una API Key gratuita de Groq Console.

```Bash
# Archivo .env
LLM_PROVIDER=cloud
GROQ_API_KEY=gsk_tucodigosecreto...
MODEL_NAME=llama-3.1-8b-instant
Nota: El cambio es instantáneo al reiniciar el contenedor del backend (docker restart sa_api).