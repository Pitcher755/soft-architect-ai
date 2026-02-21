# 🧠✨ Guía: IA 100% Privada en Tu Máquina
## Usa SoftArchitect con tu propio LLM Local (Zero Cloud, Zero Espías)

<div align="center">

![Privacy](https://img.shields.io/badge/Privacy-100%25_Local-green?style=for-the-badge&logo=shield)
![Zero Cloud](https://img.shields.io/badge/Cloud-Zero_Dependency-blue?style=for-the-badge)
![Cost](https://img.shields.io/badge/Cost-$0_per_month-gold?style=for-the-badge&logo=cashapp)

**🎯 Tiempo de Setup:** 10-15 minutos | **💰 Coste Recurrente:** $0 | **🔐 Privacidad:** Absoluta

</div>

---

## 📖 Tabla de Contenidos

```
🎬 Introducción ........................... ¿Por qué local?
🔧 Paso 1: Instalar Ollama ................ El motor de IA
🧠 Paso 2: Descargar tu "cerebro" ......... Modelos según tu hardware
🔌 Paso 3: Conectar SoftArchitect ......... Configuración .env
🚀 Paso 4: ¡Despegue! ..................... Reiniciar y volar
```

---

## 🎬 Introducción

```
┌─────────────────────────────────────────────────────────────┐
│  🔐 TU CÓDIGO NUNCA SALE DE TU MÁQUINA                     │
│                                                             │
│  ✅ Sin APIs de pago (OpenAI, Anthropic, etc.)            │
│  ✅ Sin suscripciones mensuales                           │
│  ✅ Sin límites de uso                                     │
│  ✅ Funciona sin internet (una vez descargado)            │
│  ✅ Ideal para código propietario o confidencial          │
└─────────────────────────────────────────────────────────────┘
```

**🎯 ¿Quién puede usar esto?**

- 💻 **PC Gaming con GPU NVIDIA** (GTX 1660+, RTX series)
- 🍎 **Mac con chips M1/M2/M3/M4** (la memoria unificada es BRUTAL para IA)
- 🖥️ **Workstations con 16GB+ RAM** (funciona por CPU, más lento pero viable)

---

## 🔧 Paso 1: Instalar el Motor (Ollama)

> 💡 **¿Qué es Ollama?** Es como Docker, pero para modelos de IA. Exprime tu GPU al máximo y gestiona toda la complejidad por ti.

### 📥 Instalación

<table>
<tr>
<td width="33%" align="center">

**🪟 Windows**

1. Ve a [ollama.com](https://ollama.com)
2. Descarga el `.exe`
3. ¡Doble clic y listo!

</td>
<td width="33%" align="center">

**🍎 macOS**

1. Ve a [ollama.com](https://ollama.com)
2. Descarga el `.dmg`
3. Arrastra a Aplicaciones

</td>
<td width="33%" align="center">

**🐧 Linux**

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

</td>
</tr>
</table>

✅ **Verificación:** Abre tu terminal y escribe:

```bash
ollama --version
```

Si ves un número de versión (ej: `0.1.27`), ¡perfecto! Ollama está corriendo en segundo plano.

---

## 🧠 Paso 2: Descargar tu "Cerebro" IA

> ⚡ **Importante:** El modelo que elijas depende de tu hardware. ¡Más grande no siempre es mejor si tu GPU no puede manejarlo!

### 🎯 Selector de Modelo Inteligente

<details>
<summary>🟢 <b>Tengo 8GB VRAM (o menos)</b> - RTX 3060, GTX 1660, Mac M1 con 8GB</summary>

```bash
# El equilibrio perfecto: rápido y muy capaz
ollama run llama3.1:8b
```

**📊 Rendimiento:**
- Velocidad: ⚡⚡⚡⚡⚡ (Muy rápida)
- Calidad: ⭐⭐⭐⭐ (Comparable a GPT-3.5)
- Tamaño descarga: ~4.7GB

</details>

<details>
<summary>🟡 <b>Tengo 12-16GB VRAM</b> - RTX 3080, RTX 4070, Mac M2 Pro</summary>

```bash
# El rey de la programación
ollama run qwen2.5-coder:14b
```

**📊 Rendimiento:**
- Velocidad: ⚡⚡⚡⚡ (Rápida)
- Calidad: ⭐⭐⭐⭐⭐ (BRUTAL para código)
- Tamaño descarga: ~9GB
- 🏆 **RECOMENDADO para desarrollo**

</details>

<details>
<summary>🔴 <b>Tengo 24GB+ VRAM</b> - RTX 4090, Mac M2 Max/Ultra con 64GB</summary>

```bash
# Modo bestia: GPT-4 en tu máquina
ollama run command-r

# O el gigante de código abierto
ollama run mixtral:8x7b
```

**📊 Rendimiento:**
- Velocidad: ⚡⚡⚡ (Moderada)
- Calidad: ⭐⭐⭐⭐⭐ (Nivel GPT-4)
- Tamaño descarga: ~20GB cada uno
- 💎 Resultados profesionales

</details>

### 🚀 Ejemplo de Descarga

```bash
# Ejecuta este comando y espera 5-10 minutos (depende de tu internet)
ollama run llama3.1:8b

# Verás algo como:
# pulling manifest
# pulling 6a0746a1ec1a... 100% ▕████████████████▏ 4.7 GB
# verifying sha256 digest
# success! ✓
```

> 💾 **Espacio en disco:** Los modelos se guardan en `~/.ollama/models/`. Asegúrate de tener espacio suficiente.

---

## 🔌 Paso 3: Conectar SoftArchitect a tu Cerebro Local

> 🎯 **Objetivo:** Decirle al backend de SoftArchitect que use tu modelo local en lugar de OpenAI/Groq.

### 📝 Editar el archivo `.env`

**Ubicación:** `soft-architect-ai/.env` (en la raíz del proyecto)

```bash
# ╔══════════════════════════════════════════════════════════╗
# ║  🔐 CONFIGURACIÓN LOCAL LLM (100% PRIVADO)              ║
# ╚══════════════════════════════════════════════════════════╝

# Proveedor: Cambia de "cloud" a "local"
LLM_PROVIDER=local

# Modelo: El MISMO nombre que usaste en "ollama run"
LLM_MODEL=llama3.1:8b

# URL de Ollama:
# - Docker (Windows/Mac): http://host.docker.internal:11434
# - Docker (Linux): http://172.17.0.1:11434 (o tu IP local)
# - Nativo (sin Docker): http://localhost:11434
OLLAMA_BASE_URL=http://host.docker.internal:11434
```

### 🐧 Casos Especiales

<details>
<summary>❓ <b>Linux + Docker:</b> "host.docker.internal" no funciona</summary>

**Solución 1:** Usa la IP del gateway de Docker
```bash
OLLAMA_BASE_URL=http://172.17.0.1:11434
```

**Solución 2:** Usa tu IP local (encuéntrala con `ip addr show`)
```bash
OLLAMA_BASE_URL=http://192.168.1.50:11434  # Cambia por tu IP
```

</details>

<details>
<summary>🍎 <b>Mac Apple Silicon:</b> Ollama nativo (no Docker)</summary>

Si instalaste Ollama directamente en macOS (sin Docker):
```bash
OLLAMA_BASE_URL=http://host.docker.internal:11434
```

> 💡 Ver [Guía de Aceleración Hardware](HARDWARE_ACCELERATION_GUIDE.md) para configuración avanzada de Mac.

</details>

---

## 🚀 Paso 4: ¡Despegue!

### Reiniciar para aplicar cambios

```bash
# 1️⃣ Bajar los contenedores actuales
docker compose down

# 2️⃣ Levantar con la nueva configuración
docker compose up -d

# 3️⃣ Verificar que todo arrancó correctamente
docker compose ps
```

**✅ Deberías ver algo como:**

```
NAME                STATUS              PORTS
sa_ollama          Up 30 seconds       0.0.0.0:11434->11434/tcp
sa_server          Up 30 seconds       0.0.0.0:8000->8000/tcp
sa_chroma          Up 30 seconds       0.0.0.0:8001->8001/tcp
```

---

## 🎉 ¡LISTO! Prueba tu IA Local

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   🎯 Abre la aplicación de Flutter                         │
│   💬 Crea un nuevo proyecto                                 │
│   🤖 Haz una pregunta al Arquitecto IA                      │
│   ⚡ BOOM! Respuesta instantánea desde TU máquina          │
│                                                             │
│   🔐 Tu código NUNCA salió de tu red local                 │
│   💰 Coste: $0.00                                           │
│   🚀 Velocidad: Limitada solo por tu hardware              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 🔍 Troubleshooting

<details>
<summary>❌ <b>Error: "Cannot connect to Ollama"</b></summary>

**Verifica esto:**

```bash
# 1. ¿Ollama está corriendo?
curl http://localhost:11434/api/tags

# 2. ¿El modelo existe?
ollama list

# 3. ¿El nombre del modelo en .env es EXACTO?
cat .env | grep LLM_MODEL
```

Si todo falla, reinicia Ollama:
- **Windows/Mac:** Cierra Ollama del systray y ábrelo de nuevo
- **Linux:** `sudo systemctl restart ollama`

</details>

<details>
<summary>🐌 <b>Las respuestas son muy lentas</b></summary>

**Posibles causas:**

1. **GPU no detectada:** Ver [Guía de Aceleración Hardware](HARDWARE_ACCELERATION_GUIDE.md)
2. **Modelo muy grande para tu VRAM:** Prueba con `llama3.1:8b` o incluso `llama3.2:3b`
3. **CPU peleando:** Cierra otros programas pesados (Chrome con 50 tabs, editores, etc.)

</details>

---

## 📚 Enlaces Relacionados

<table>
<tr>
<td width="50%">

### 🔗 Documentación Relacionada

- 🚀 [Guía de Aceleración por Hardware](HARDWARE_ACCELERATION_GUIDE.md)
- ⚙️ [Guía de Configuración Completa](GUIA_CONFIGURACION.md)
- 🛠️ [Herramientas y Stack](HERRAMIENTAS_Y_STACK.md)

</td>
<td width="50%">

### 🆘 ¿Necesitas Ayuda?

- 💬 [GitHub Discussions](https://github.com/Pitcher755/soft-architect-ai/discussions)
- 🐛 [Reportar un Bug](https://github.com/Pitcher755/soft-architect-ai/issues)
- 📖 [Documentación Completa](../../../INDEX.md)

</td>
</tr>
</table>

---

<div align="center">

**🎊 ¡Felicidades! Ahora tienes un Arquitecto IA funcionando 100% en tu máquina 🎊**

*Tu privacidad no tiene precio. Tu código se queda contigo.*

</div>
