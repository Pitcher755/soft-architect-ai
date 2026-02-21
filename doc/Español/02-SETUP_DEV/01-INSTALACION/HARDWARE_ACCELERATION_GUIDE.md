# 🚀🔥 Guía: Acelera tu IA con GPU
## Hardware Acceleration para LLMs Locales - Saca todo el jugo a tu máquina

<div align="center">

![GPU Power](https://img.shields.io/badge/GPU-10x_Faster-red?style=for-the-badge&logo=nvidia)
![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20Linux%20%7C%20macOS-blue?style=for-the-badge)
![Zero Config](https://img.shields.io/badge/Difficulty-Medium-yellow?style=for-the-badge)

**⚡ GPU vs CPU:** 10-50x más rápido | **🎯 Plataformas:** Windows, Linux, macOS | **⏱️ Setup:** 15-30 min

</div>

---

## 📖 Tabla de Contenidos

```
🔍 Introducción .................... ¿Por qué necesitas GPU?
🟢 Opción 1: Windows/Linux NVIDIA ... La configuración gold standard
🔵 Opción 2: Mac Apple Silicon ....... M1/M2/M3/M4 (modo bestia)
🟡 Opción 3: Sin GPU ................. Plan B (CPU fallback)
📊 Tabla Comparativa ............... Elige tu camino
```

---

## 🔍 ¿Por qué necesitas aceleración por GPU?

```
┌─────────────────────────────────────────────────────────────┐
│  COMPARACIÓN: CPU vs GPU en Generación de Código            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  🐢 CPU (Intel i7/AMD Ryzen):                              │
│     Velocidad: 2-5 tokens/segundo                           │
│     Experiencia: Palabras salen letra por letra 🐌          │
│     Uso práctico: Frustrante para trabajo real               │
│                                                             │
│  🚀 GPU (RTX 3060, RX 6700 XT):                            │
│     Velocidad: 30-60 tokens/segundo                         │
│     Experiencia: Respuestas casi instantáneas ⚡            │
│     Uso práctico: Fluido y profesional                       │
│                                                             │
│  🔥 GPU High-End (RTX 4090, M2 Ultra):                      │
│     Velocidad: 80-150+ tokens/segundo                       │
│     Experiencia: Más rápido que escribir 🤯               │
│     Uso práctico: Indistinguible de ChatGPT Plus             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

<div align="center">

## 🎯 Elige tu Opción

**Haz clic en tu configuración para ver instrucciones detalladas ⬇️**

</div>

---

## 🟢 Opción 1: Windows o Linux con GPU NVIDIA

<div align="center">

```
╔════════════════════════════════════════════════════════╗
║  🏆 OPCIÓN GOLD STANDARD (MÁXIMO RENDIMIENTO)         ║
╚════════════════════════════════════════════════════════╝
```

**✨ Ventajas:**
- ⚡ Máximo rendimiento
- 🎮 Docker maneja todo
- 🔧 Fácil de mantener

</div>

### 📊 Requisitos Previos

<table>
<tr>
<td width="50%">

#### 🪟 **Windows**

```
✅ Docker Desktop instalado
✅ WSL2 activado
✅ Drivers NVIDIA recientes
✅ GPU: GTX 1060 6GB o superior
```

> 💡 **Nota:** Docker Desktop en Windows 11 ya incluye soporte GPU automático

</td>
<td width="50%">

#### 🐧 **Linux**

```
✅ Docker instalado
✅ Drivers NVIDIA instalados
✅ NVIDIA Container Toolkit
✅ GPU: GTX 1060 6GB o superior
```

**Instalar Container Toolkit:**

```bash
# Ubuntu/Debian
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Verificar
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

</td>
</tr>
</table>

### ⚙️ Configuración de docker-compose.yml

**Archivo:** `infrastructure/docker-compose.yml`

**Busca el servicio `ollama` y asegúrate de que esté así:**

```yaml
  ollama:
    image: ollama/ollama:latest
    container_name: sa_ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama

    # 👇 ESTA ES LA PARTE CRÍTICA 👇
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia      # Driver de NVIDIA
              count: 1            # 1 GPU (o "all" para todas)
              capabilities: [gpu] # Capacidades de GPU
```

> 👁️ **Importante:** El bloque `deploy` debe estar indentado correctamente dentro del servicio `ollama`

### 📝 Configuración de .env

```bash
# Proveedor local
LLM_PROVIDER=local

# URL del Ollama en Docker (usa el nombre del servicio)
OLLAMA_BASE_URL=http://ollama:11434

# Modelo (descarga el que quieras)
LLM_MODEL=llama3.1:8b
```

### 🚀 Reiniciar Docker

```bash
# Bajar servicios
docker compose down

# Levantar con GPU
docker compose up -d

# Verificar que Ollama ve la GPU
docker exec sa_ollama nvidia-smi
```

**✅ Si ves información de tu GPU (nombre, temperatura, VRAM), ¡PERFECTO!** Estás usando aceleración por hardware.

---

## 🔵 Opción 2: Mac con Apple Silicon (M1/M2/M3/M4)

<div align="center">

```
╔════════════════════════════════════════════════════════╗
║  🍎 MODO BESTIA - MEMORIA UNIFICADA                  ║
╚════════════════════════════════════════════════════════╝
```

**💪 Por qué los chips M son BRUTALES para IA:**

```
Memoria Unificada = RAM + VRAM son la misma cosa

Mac M2 con 32GB RAM = Es como tener 32GB de VRAM
➜ Puedes correr modelos GIGANTES (70B+)
➜ Velocidad de acceso a memoria increíble
➜ Eficiencia energética superior
```

</div>

### ⚠️ **¡ALTO AHÍ! Configuración Especial Requerida**

<table>
<tr>
<td width="50%" bgcolor="#ff6b6b" style="color: #1a1a1a;">

### ❌ **NO Hagas Esto**

```
✗ NO uses Ollama en Docker
✗ Docker Desktop NO puede usar
  la GPU de Apple eficientemente
✗ Perderás el 90% del rendimiento
```

</td>
<td width="50%" bgcolor="#51cf66" style="color: #1a1a1a;">

### ✅ **SÍ Haz Esto**

```
✓ Instala Ollama NATIVO en macOS
✓ Corre fuera de Docker
✓ Conecta Docker a Ollama nativo
✓ 100% del rendimiento disponible
```

</td>
</tr>
</table>

### 🛠️ Guía Paso a Paso (Mac)

#### 1️⃣ Instalar Ollama Nativo

```bash
# Opción A: Descarga desde la web
open https://ollama.com
# Descarga el .dmg, arrastra a Aplicaciones, ábrelo

# Opción B: Homebrew
brew install ollama
ollama serve  # Iniciar servidor
```

✅ **Verificación:**

```bash
# Deberías ver el icono de Ollama (alpaca) en la barra superior
curl http://localhost:11434/api/tags
# Debería responder con JSON
```

#### 2️⃣ Desactivar Ollama en Docker

**Edita:** `infrastructure/docker-compose.yml`

**Opción A - Comentar todo el bloque:**

```yaml
# ========================================
# OLLAMA DESACTIVADO - Usando nativo macOS
# ========================================
#  ollama:
#    image: ollama/ollama:latest
#    container_name: sa_ollama
#    ...
```

**Opción B - Remover el servicio completamente**
(Borra todo el bloque `ollama:`)

#### 3️⃣ Conectar Docker al Ollama Nativo

**Edita:** `.env`

```bash
# Proveedor local
LLM_PROVIDER=local

# 🍎 URL ESPECIAL para Mac - Esto dice "sal del contenedor y busca en macOS"
OLLAMA_BASE_URL=http://host.docker.internal:11434

# Modelo (descarga el que quieras con "ollama run")
LLM_MODEL=llama3.1:8b
```

> 💡 **Cómo funciona:** `host.docker.internal` es una dirección mágica que Docker usa para comunicarse con el host (tu Mac)

#### 4️⃣ Descargar un Modelo

```bash
# En una terminal de macOS (NO Docker)
ollama run llama3.1:8b

# Para Macs con 32GB+ RAM, prueba modelos grandes:
ollama run qwen2.5-coder:32b
ollama run llama3.1:70b
```

#### 5️⃣ Reiniciar Backend

```bash
docker compose down
docker compose up -d

# Verificar conexión desde Docker
docker exec sa_server curl http://host.docker.internal:11434/api/tags
```

### 📊 Rendimiento Esperado (Mac M2 Pro 32GB)

```
Modelo: llama3.1:8b
Velocidad: ~80-120 tokens/segundo
Experiencia: Respuestas instantáneas ⚡

Modelo: qwen2.5-coder:32b
Velocidad: ~30-50 tokens/segundo
Experiencia: Fluido y profesional 🚀
```

---

## 🟡 Opción 3: Ordenadores sin GPU dedicada

<div align="center">

```
╔════════════════════════════════════════════════════════╗
║  🐢 MODO CPU - Plan de Supervivencia                 ║
╚════════════════════════════════════════════════════════╝
```

</div>

**🤔 ¿En qué casos aplica esto?**

- 💼 PC de oficina sin tarjeta gráfica dedicada
- 💻 Laptop con gráficos integrados (Intel UHD, AMD Radeon integrada)
- 🍎 Mac Intel antiguo (pre-M1)
- 🖥️ Workstation sin GPU NVIDIA/AMD dedicada

### 🚦 Expectativas Realistas

```
┌────────────────────────────────────────────────────────────┐
│  📊 VELOCIDAD CON CPU                                      │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  Modelo llama3.1:8b (4.7GB):                               │
│  Velocidad: 2-5 tokens/segundo                            │
│  Experiencia: Ver palabras salir una por una 🐌            │
│                                                            │
│  Modelo qwen:0.5b (minimalista):                          │
│  Velocidad: 10-20 tokens/segundo                          │
│  Experiencia: Aceptable pero capacidad limitada           │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### 🔧 Estrategia 1: Modelos Minimalistas (Local)

**Usa modelos ULTRA pequeños diseñados para CPU:**

```bash
# El más pequeño viable (500MB)
ollama run qwen:0.5b

# Muy pequeño pero más capaz (1.3GB)
ollama run llama3.2:1b

# Equilibrio CPU-friendly (2GB)
ollama run phi3:3.8b
```

**Configuración `.env`:**

```bash
LLM_PROVIDER=local
OLLAMA_BASE_URL=http://ollama:11434
LLM_MODEL=qwen:0.5b  # Modelo más pequeño
```

**docker-compose.yml:** Asegúrate de que el servicio `ollama` **NO tenga** el bloque `deploy` (para evitar errores buscando GPU)

```yaml
  ollama:
    image: ollama/ollama:latest
    container_name: sa_ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    # NO incluyas el bloque "deploy" con "nvidia"
```

### 🌐 Estrategia 2: Usar la Nube (RECOMENDADO)

> 💡 **Realidad:** Si no tienes GPU, la experiencia con CPU será frustrante. Usar APIs en la nube es más práctico.

**🏆 Mejor opción: Groq (GRATIS y ULTRA RÁPIDO)**

<div align="center">

```
┌────────────────────────────────────────────────────────┐
│  GROQ: Como tener una RTX 4090... en la nube 🚀         │
├────────────────────────────────────────────────────────┤
│  ✅ Plan gratuito generoso (6000 tokens/min)            │
│  ⚡ Velocidad: 500-800 tokens/segundo                    │
│  🏆 Modelos: llama3.1-70b, mixtral-8x7b, etc.         │
│  💰 Coste: $0 hasta miles de requests diarios          │
└────────────────────────────────────────────────────────┘
```

</div>

**Guía Rápida Groq:**

```bash
# 1. Obtén tu API Key GRATIS
open https://console.groq.com/keys

# 2. Edita tu .env
LLM_PROVIDER=groq
GROQ_API_KEY=gsk_tu_api_key_aquí
GROQ_MODEL=llama-3.1-70b-versatile

# 3. Reinicia
docker compose down && docker compose up -d

# 4. ¡Disfruta velocidad RTX 4090 desde tu laptop de oficina! 🚀
```

---

## 📊 Tabla Comparativa: Elige tu Camino

<div align="center">

### 🎯 Guía Rápida de Decisión

</div>

| 🔧 Hardware | 💻 Sistema | ⚡ Rendimiento | 🎯 Método Recomendado | 📁 URL Ollama | 📝 Notas |
|----------|----------|--------------|----------------------|---------------|-------|
| **GPU NVIDIA** | Windows 11 | 🔥🔥🔥🔥🔥 | Docker con GPU | `http://ollama:11434` | 🏆 Gold Standard |
| **GPU NVIDIA** | Linux | 🔥🔥🔥🔥🔥 | Docker con GPU | `http://ollama:11434` | Requiere Container Toolkit |
| **Apple M1-M4** | macOS | 🔥🔥🔥🔥🔥 | Ollama Nativo | `http://host.docker.internal:11434` | ⚠️ NO Docker Ollama |
| **CPU Intel/AMD** | Cualquiera | 🐢 | Modelos Tiny | `http://ollama:11434` | O usa Groq (mejor) |
| **Sin GPU** | Cualquiera | 🐌 | **Groq Cloud** | N/A | 🏆 RECOMENDADO |

---

## 🧠 Descarga de Modelos: Cuál Elegir

### 📊 Matriz de Decisión

```
╔════════════════════════════════════════════════════════════════════════════════╗
║  SELECCIÓN DE MODELO POR HARDWARE                                        ║
╚════════════════════════════════════════════════════════════════════════════════╝

VRAM/RAM     Modelo Recomendado           Velocidad    Calidad    Uso
────────────────────────────────────────────────────────────────────────────────
4GB          qwen:0.5b                    ⚡⚡⚡⚡⚡        ⭐⭐         CPU only
6-8GB        llama3.1:8b                  ⚡⚡⚡⚡⚡        ⭐⭐⭐⭐       General
12-16GB      qwen2.5-coder:14b            ⚡⚡⚡⚡         ⭐⭐⭐⭐⭐      Coding
24GB+        llama3.1:70b                 ⚡⚡⚡          ⭐⭐⭐⭐⭐      Pro
32GB+ (Mac)  qwen2.5-coder:32b            ⚡⚡⚡⚡         ⭐⭐⭐⭐⭐      Mac Bestia
64GB+ (Mac)  command-r-plus               ⚡⚡           ⭐⭐⭐⭐⭐      Ultimate
```

### 📥 Cómo Descargar

```bash
# Ejemplo: Descarga e inicia un modelo
ollama run llama3.1:8b

# Ver tus modelos descargados
ollama list

# Eliminar un modelo que no usas
ollama rm model_name
```

> 💡 **Consejo Pro:** No olvides actualizar `LLM_MODEL=` en tu `.env` después de descargar un nuevo modelo

---

## 📚 Enlaces Relacionados

<div align="center">

| 🔗 Guía | 📝 Descripción |
|---------|---------------|
| [LOCAL_LLM_GUIDE.md](LOCAL_LLM_GUIDE.md) | 🧠 Guía base para instalar Ollama |
| [GUIA_CONFIGURACION.md](GUIA_CONFIGURACION.md) | ⚙️ Configuración completa del proyecto |
| [DOCKER_COMPOSE_GUIDE.md](../02-DOCKER/DOCKER_COMPOSE_GUIDE.md) | 🐳 Troubleshooting Docker |
| [HERRAMIENTAS_Y_STACK.md](HERRAMIENTAS_Y_STACK.md) | 🛠️ Stack técnico completo |

</div>

---

<div align="center">

### 🎉 ¡Configuración de Hardware Completada!

**Tu GPU está lista para arrasar con cualquier tarea de IA 🔥**

*¿Problemas? Abre un [Issue en GitHub](https://github.com/Pitcher755/soft-architect-ai/issues)*

</div>
