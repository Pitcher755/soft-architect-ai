# 🚀 Instalación Completa - SoftArchitect AI

> **Date:** 19/02/2026
> **Status:** ✅ Guía actualizada
> **Tiempo aproximado:** 20-30 minutos

---

## 📖 Table of Contents

- [Requisitos del Sistema](#requisitos-del-sistema)
- [Instalación Rápida (Recomendado)](#instalación-rápida-recomendado)
- [Instalación Manual Completa](#instalación-manual-completa)
- [Instalación por Sistema Operativo](#instalación-por-sistema-operativo)
- [Verificar la Instalación](#verificar-la-instalación)
- [Solucionar Problemas](#solucionar-problemas)

---

## ⚙️ Requisitos del Sistema

### Hardware Mínimo
- **CPU:** Procesador moderno (Intel/AMD, 2+ núcleos)
- **RAM:** 8 GB mínimo, 16 GB recomendado
- **Almacenamiento:** 10 GB libres
- **Conexión:** Internet para la instalación inicial

### Software Requerido

#### Opción 1: Con Docker (⭐ Recomendado)
- **Docker Desktop** 4.20+
- **Docker Compose** incluido en Docker Desktop
- Tu navegador web

#### Opción 2: Local (Sin Docker)
- **Python** 3.12+
- **Flutter** 3.38.9+ (Dart 3.10.8+, opcional si usas desktop)
- **Node.js** 18+ (para algunas herramientas)

---

## 🚀 Instalación Rápida (Recomendado)

### Si tienes Docker instalado:

```bash
# 1️⃣ Clonar el repositorio
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2️⃣ Iniciar los servicios (Docker)
docker-compose up -d

# 3️⃣ Esperar 30 segundos y abrir el navegador
# La aplicación estará disponible en:
# 🌐 http://localhost:3000

# 4️⃣ ¡Listo! Empieza tu primer proyecto
```

### ⏱️ Tiempo total: ~2 minutos

**¿Necesitas detener después?**
```bash
docker-compose down
```

---

## 🔧 Instalación Manual Completa

### Paso 1: Clonar el Repositorio

```bash
# Abrir terminal/PowerShell
cd ~  # O una carpeta de tu preferencia
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai
```

**¿No tienes Git instalado?**
→ Descarga directamente: https://github.com/Pitcher755/soft-architect-ai/archive/develop.zip

---

### Paso 2: Instalar Dependencias Python

```bash
# Crear entorno virtual
python3.12 -m venv venv

# Activar el entorno virtual
# En Linux/Mac:
source venv/bin/activate

# En Windows:
venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt
```

**¿Qué son dependencias?**
→ Librerías de Python que la aplicación necesita para funcionar

---

### Paso 3: Configurar Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar con tu editor favorito
# En Linux/Mac:
nano .env

# En Windows:
notepad .env
```

**Variables esenciales:**
```env
# Modelo local (Ollama)
OLLAMA_BASE_URL=http://localhost:11434
MODEL_NAME=mistral

# Puerto de la app (dejar por defecto)
APP_PORT=3000

# Datos locales
DATA_DIR=./data
```

---

### Paso 4: Iniciar Ollama (si usas modelo local)

#### Si planeas usar Ollama:

```bash
# 1. Descargar Ollama desde: https://ollama.ai
# 2. Instalar y ejecutar: ollama serve

# 3. En otra terminal, descargar modelo:
ollama pull mistral

# 4. Verificar que funciona:
ollama list  # Debería mostrar "mistral"
```

**¿Prefiere usar la nube?**
→ Salta este paso y configura GROQ_API_KEY en .env

---

### Paso 5: Iniciar la Aplicación

```bash
# En la terminal con entorno virtual activado:
cd src/server
python main.py

# Verás algo como:
# ✅ Servidor iniciado en http://localhost:8000
# ✅ DocumentStore conectado
# ✅ LLM Engine listo

# En otra terminal, abrir en navegador:
# http://localhost:3000
```

---

## 💻 Instalación por Sistema Operativo

### 🖥️ Windows

#### Prerequisitos
```powershell
# Verificar versión de Python
python --version  # Debe ser 3.12+

# Si no lo tienes, descargar de: https://www.python.org/downloads/
```

#### Instalación completa

```powershell
# 1. Clonar
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2. Entorno virtual
python -m venv venv
venv\Scripts\activate

# 3. Dependencias
pip install -r requirements.txt

# 4. Configurar
copy .env.example .env
notepad .env  # Editar variables

# 5. Iniciar (en una PowerShell)
cd src/server
python main.py

# 6. En otra PowerShell, abrir navegador
start http://localhost:3000
```

**Problema: "Python no se reconoce"**
→ Añade Python a PATH: https://realpython.com/add-python-to-path/

---

### 🍎 macOS

#### Prerequisitos
```bash
# Verificar Python
python3 --version  # Debe ser 3.12+

# Si no lo tienes, usar Homebrew:
brew install python@3.12
```

#### Instalación completa

```bash
# 1. Clonar
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2. Entorno virtual
python3.12 -m venv venv
source venv/bin/activate

# 3. Dependencias
pip install -r requirements.txt

# 4. Configurar
cp .env.example .env
nano .env  # Editar variables (Ctrl+X para salir)

# 5. Iniciar
cd src/server
python main.py

# 6. En otra terminal, abrir navegador
open http://localhost:3000
```

**En M1/M2 Macs:**
```bash
# Asegurar soporte para arquitectura ARM
arch -arm64 python3.12 -m venv venv
```

---

### 🐧 Linux (Ubuntu/Debian)

#### Prerequisitos
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Python 3.12
sudo apt install python3.12 python3.12-venv python3-pip -y

# Verificar instalación
python3.12 --version
```

#### Instalación completa

```bash
# 1. Clonar
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2. Entorno virtual
python3.12 -m venv venv
source venv/bin/activate

# 3. Dependencias
pip install -r requirements.txt

# 4. Configurar
cp .env.example .env
nano .env  # Editar variables

# 5. Iniciar
cd src/server
python main.py

# 6. En otra terminal
firefox http://localhost:3000 &
```

**Con Docker (más simple):**
```bash
sudo apt install docker.io docker-compose -y
docker-compose up -d
# Luego abrir http://localhost:3000
```

---

## ✅ Verificar la Instalación

### Lista de Verification

Después de instalar, comtest que todo funciona:

```bash
# 1️⃣ ¿Python está correctamente instalado?
python --version  # Debe ser 3.12+

# 2️⃣ ¿Las dependencias se instalaron?
pip list | grep -E 'fastapi|chromadb|langchain'
# Debería mostrar esos paquetes

# 3️⃣ ¿El servidor inicia sin errores?
cd src/server
python main.py
# Debe terminar sin errores

# 4️⃣ ¿La app es accesible en el navegador?
# Abre: http://localhost:3000
# Debería ver la interfaz principal

# 5️⃣ ¿Puedes crear un nuevo proyecto?
# Debería permitir crear y nombrar un proyecto
```

### Result Esperado

✅ **Pasos 1-3 completos**: Backend funcionando
✅ **Pasos 4-5 completos**: Frontend funcional
✅ **Todo funciona**: Listo para el primer project

---

## 🚨 Solucionar Problemas

### Problema 1: "ModuleNotFoundError: No module named 'fastapi'"

**Causa:** Dependencias no instaladas
**Solución:**

```bash
# Aseguráte de estar en el entorno virtual
source venv/bin/activate  # o activate.bat en Windows

# Reinstalar dependencias
pip install -r requirements.txt -v
```

---

### Problema 2: "Puerto 3000 ya está en uso"

**Causa:** Otra aplicación usa el mismo puerto
**Solución:**

```bash
# Opción A: Matar el proceso
# En Linux/Mac:
lsof -i :3000
kill -9 <PID>

# En Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Opción B: Usar otro puerto
# Editar .env y cambiar APP_PORT=3001
```

---

### Problema 3: "Error: ENOENT: no such file or directory '.env'"

**Causa:** File .env no existe
**Solución:**

```bash
# Crear desde ejemplo
cp .env.example .env
# Editar con tus valores
```

---

### Problema 4: "ConnectionError: No se puede conectar a Ollama"

**Causa:** Ollama no está corriendo
**Solución:**

```bash
# Opción A: Iniciar Ollama
ollama serve

# Opción B: Usar Groq (nube)
# En .env, cambiar a:
USE_GROQ=true
GROQ_API_KEY=tu_clave_aqui
```

---

### Problema 5: Docker no inicia

**Causa:** Docker Desktop no está ejecutándose
**Solución:**

```bash
# Reiniciar Docker
# En Windows/Mac: Cerrar y abrir Docker Desktop

# En Linux:
sudo systemctl restart docker

# Verificar que funciona:
docker --version
docker ps
```

---

## 📱 Acceso por Dispositivos

### Desde el mismo equipo:
```
Navegador: http://localhost:3000
```

### Desde otro equipo en la red local:
```
Reemplaza localhost por tu IP
Ejemplo: http://192.168.1.100:3000
```

**Encontrar tu IP:**
```bash
# Linux/Mac:
ifconfig | grep inet

# Windows:
ipconfig
```

---

## 🔐 Consideraciones de Seguridad

### En Producción (NO usar como se instaló)

⚠️ **Cambios necesarios antes de producción:**

1. **Cambiar contraseñas por defecto**
   ```env
   DB_PASSWORD=tu_contraseña_segura
   API_KEY=tu_clave_segura
   ```

2. **Habilitar HTTPS**
   ```env
   USE_HTTPS=true
   SSL_CERT=/ruta/a/certificado.pem
   ```

3. **Restricción de CORS**
   ```env
   ALLOWED_ORIGINS=tu_dominio.com
   ```

4. **Rate limiting**
   ```env
   ENABLE_RATE_LIMIT=true
   MAX_REQUESTS_PER_MINUTE=60
   ```

---

## 🆘 ¿Aún no funciona?

Si después de todos estos pasos aún tienes problemas:

### 1️⃣ Revisa el log de errores:
```bash
# El servidor muestra el error en la terminal
# Copia el mensaje de error exacto
```

### 2️⃣ Abre un GitHub Issue:
https://github.com/Pitcher755/soft-architect-ai/issues/new

**Incluye:**
- Sistema operativo y versión
- Versión de Python
- Mensaje de error exacto (copia-pega)
- Pasos que ejecutaste

### 3️⃣ O contacta al equipo:
- Email: arquitecto@softarchitectai.com
- Comunidad: Discord (próximamente)

---

## ✅ Next Paso

Una vez instalado y funcionando:

🎯 **[Create tu Primer Project →](03-FIRST_PROJECT.md)**

Aprenderás a:
- Create un nuevo project
- Definir la visión
- Execute FASE 1 del Master Workflow

---

## 📚 Referencia Rápida

| Comando | Propósito |
|---------|-----------|
| `docker-compose up -d` | Iniciar servicios |
| `docker-compose down` | Detener servicios |
| `source venv/bin/activate` | Activar entorno (Linux/Mac) |
| `venv\Scripts\activate` | Activar entorno (Windows) |
| `pip install -r requirements.txt` | Instalar dependencias |
| `python main.py` | Iniciar servidor |
| `ollama pull mistral` | Descargar modelo local |

---

<p align="center">
  ✅ Instalación completada correctamente
  <br/>
  🎯 Listo para: <a href="03-FIRST_PROJECT.md"><strong>Create tu Primer Project</strong></a>
</p>
