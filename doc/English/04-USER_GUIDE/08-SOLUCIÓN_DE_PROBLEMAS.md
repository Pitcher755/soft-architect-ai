# 🚨 Solución de Problemas - SoftArchitect AI

> **Date:** 19/02/2026
> **Status:** ✅ Guía de troubleshooting
> **Reading Time:** 10 minutos

---

## 📖 Table of Contents

- [Problemas de Instalación](#problemas-de-instalación)
- [Problemas con la IA](#problemas-con-la-ia)
- [Problemas de Rendimiento](#problemas-de-rendimiento)
- [Problemas de Red](#problemas-de-red)
- [Problemas de Datos](#problemas-de-datos)
- [Obtener Ayuda Adicional](#obtener-ayuda-adicional)

---

## 🛠️ Problemas de Instalación

### ❌ "ModuleNotFoundError: No module named 'fastapi'"

**Síntomas:**
```
ModuleNotFoundError: No module named 'fastapi'
```

**Causa:** Dependencias de Python no instaladas correctamente

**Solución:**
```bash
# 1. Asegúrate de estar en el entorno virtual
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# 2. Reinstalar dependencias
pip install -r requirements.txt --force-reinstall

# 3. Verificar instalación
pip list | grep fastapi
```

---

### ❌ "Puerto 3000 ya está en uso"

**Síntomas:**
```
Error: listen EADDRINUSE: address already in use ::1:3000
```

**Causa:** Otro proceso está usando el puerto 3000

**Solución A: Cambiar puerto**
```bash
# Editar .env
APP_PORT=3001

# Reiniciar app
```

**Solución B: Matar proceso existente**
```bash
# Linux/Mac
lsof -i :3000
kill -9 <PID>

# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

---

### ❌ "Docker no inicia o falla"

**Síntomas:**
```
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Causa:** Docker Desktop no está ejecutándose

**Solución:**
```bash
# 1. Abrir Docker Desktop manualmente

# 2. Verificar que está corriendo
docker ps

# 3. Si aún falla, reiniciar Docker
# En Linux:
sudo systemctl restart docker

# En Windows/Mac: Reiniciar Docker Desktop
```

---

### ❌ "Python no se reconoce como comando"

**Síntomas:**
```
'python' is not recognized as an internal or external command
```

**Causa:** Python no está en PATH

**Solución:**
1. **Windows:** Reinstala Python y marca "Add Python to PATH"
2. **Linux/Mac:** Usa `python3` en lugar de `python`
3. Verifica con: `python --version` o `python3 --version`

---

## 🤖 Problemas con la IA

### ❌ "La IA no responde o tarda mucho"

**Síntomas:**
- Chat muestra "Pensando..." por más de 2 minutos
- Respuestas nunca llegan

**Causa Posible 1: ChromaDB indexando**
**Solución:**
```bash
# Esperar 30-60 segundos más
# Primera vez siempre tarda más

# Verificar logs del servidor
docker logs soft-architect-ai-backend
```

**Causa Posible 2: Ollama no está corriendo**
**Solución:**
```bash
# Verificar Ollama
ollama list

# Si no hay respuesta, iniciar:
ollama serve

# Descargar modelo si falta:
ollama pull mistral
```

**Causa Posible 3: problema de conexión con API**
**Solución:**
```bash
# Si usas Groq, verificar .env:
GROQ_API_KEY=tu_clave_aquí
USE_GROQ=true

# Verificar límite de requests:
# Groq free tier: 30 req/min
# Esperar 1 minuto y reintentar
```

---

### ❌ "La IA da respuestas sin sentido o alucinaciones"

**Síntomas:**
- Respuestas contradictorias
- Menciona tecnologías que no pediste
- "Modo creativo" excesivo

**Causa:** Configuration del modelo inadecuada

**Solución:**
```bash
# 1. Editar src/server/config/llm_settings.py
# Reducir temperature:
TEMPERATURE=0.3  # Valor por defecto: 0.7

# 2. Aumentar penalty:
FREQUENCY_PENALTY=0.5

# 3. Reiniciar servidor
```

---

### ❌ "La IA no entiende mi pregunta"

**Síntomas:**
- Respuestas genéricas
- "Lo siento, no entiendo"
- Pregunta lo mismo repetidamente

**Causa:** Contexto insuficiente o ambiguo

**Solución:**
✅ **HACER:**
- "Necesito una app de gestión de tareas para equipos remotos de 20 personas, con sincronización en tiempo real"

❌ **NO HACER:**
- "App de tareas"

✅ **HACER:**
- "Usaremos PostgreSQL porque ya tenemos experiencia y necesitamos ACID"

❌ **NO HACER:**
- "Base de datos que funcione"

---

## ⚡ Problemas de Rendimiento

### ❌ "La app va lenta o se congela"

**Síntomas:**
- UI tarda en responder
- Chat lag
- Documents tardan en cargar

**Causa Posible 1: RAM insuficiente**
**Solución:**
```bash
# Verificar uso de memoria
docker stats  # Si usas Docker

# Si uso > 90%, cerrar otros programas
# O aumentar RAM asignada a Docker:
# Docker Desktop → Settings → Resources → Memory: 8GB
```

**Causa Posible 2: ChromaDB grande**
**Solución:**
```bash
# Limpiar datos antiguos
cd infrastructure/chroma_data
rm -rf *  # ⚠️ Perderás historial

# Reiniciar app
docker-compose restart
```

**Causa Posible 3: Disco lleno**
**Solución:**
```bash
# Verificar espacio disponible
df -h  # Linux/Mac
dir   # Windows

# Liberar espacio si < 5GB
# Eliminar logs viejos, cache, etc.
```

---

### ❌ "Streaming de respuestas entrecortado"

**Síntomas:**
- Texto aparece a saltos
- Palabras se cortan
- Delays entre oraciones

**Causa:** Conexión lenta o backend sobrecargado

**Solución:**
```bash
# 1. Verificar latencia del modelo
# Si usas Ollama local:
ollama run mistral "test"  # ¿Tarda >5s?

# 2. Cambiar a modelo más ligero
ollama pull phi  # Modelo más rápido

# 3. En .env:
MODEL_NAME=phi

# 4. Reiniciar
```

---

## 🌐 Problemas de Red

### ❌ "Cannot connect to localhost:3000"

**Síntomas:**
```
ERR_CONNECTION_REFUSED
```

**Causa:** Backend no está levantado

**Solución:**
```bash
# 1. Verificar que el servidor está corriendo
docker ps  # Busca container "backend"

# o
ps aux | grep uvicorn  # Si instalación local

# 2. Si no está corriendo, iniciar:
docker-compose up -d  # Docker
# o
cd src/server && python main.py  # Local

# 3. Esperar 30 segundos y abrir navegador
```

---

### ❌ "CORS policy error"

**Síntomas:**
```
Access to fetch at 'http://localhost:8000' from origin 'http://localhost:3000'
has been blocked by CORS policy
```

**Causa:** Configuration CORS mal configurada

**Solución:**
```python
# src/server/app/main.py
# Verificar que ALLOWED_ORIGINS incluye tu dominio

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 💾 Problemas de Datos

### ❌ "Mis projects desaparecieron"

**Síntomas:**
- Lista de projects vacía
- "No projects found"

**Causa:** Datos no persistidos o folder movida

**Solución:**
```bash
# 1. Verificar carpeta de datos
ls -la ./data/projects  # Linux/Mac
dir .\data\projects     # Windows

# 2. Si está vacía, verificar backup
ls -la ./data/backup

# 3. Restaurar desde backup si existe
cp -r ./data/backup/* ./data/projects/

# 4. Si no hay backup, los datos se perdieron 😢
# En futuro, usar Docker volumes para persistencia
```

---

### ❌ "Error al guardar documents"

**Síntomas:**
```
PermissionError: [Errno 13] Permission denied: './data/projects/...'
```

**Causa:** Permisos de escritura incorrectos

**Solución:**
```bash
# Linux/Mac
sudo chown -R $USER:$USER ./data
chmod -R 755 ./data

# Windows
# Click derecho en carpeta data → Properties → Security
# Dar "Full control" a tu usuario
```

---

## 🔐 Problemas de Seguridad

### ❌ "SSL certificate error"

**Síntomas:**
```
SSL: CERTIFICATE_VERIFY_FAILED
```

**Causa:** Certificados SSL desactualizados

**Solución:**
```bash
# Opción A: Actualizar certificados del sistema
# Linux:
sudo apt update && sudo apt install ca-certificates

# Mac:
# Abrir Keychain Access → Certificados → Actualizar

# Opción B: Deshabilitar verificación (NO recomendado en producción)
# En development, editar .env:
SSL_VERIFY=false
```

---

## 🆘 Obtener Ayuda Adicional

### 📋 Información a recopilar antes de reportar:

1. **Sistema operativo** y versión
   ```bash
   uname -a  # Linux/Mac
   systeminfo  # Windows
   ```

2. **Versiones instaladas**
   ```bash
   python --version
   docker --version
   flutter --version
   ```

3. **Logs del servidor**
   ```bash
   docker logs soft-architect-ai-backend --tail 50
   # o
   cat src/server/logs/app.log
   ```

4. **Mensaje de error completo** (copy-paste exacto)

5. **Pasos para reproducir el problema**

---

### 🌐 Canales de Soporte

| Canal | Uso | Respuesta |
|-------|-----|-----------|
| **GitHub Issues** | Bugs, features | 24-48h |
| **Discord** (próximamente) | Ayuda rápida | Comunidad |
| **Email** | Soporte técnico | 2-3 días |
| **Documentación** | Troubleshooting | Instantáneo |

**GitHub Issues:** https://github.com/Pitcher755/soft-architect-ai/issues
**Email:** soporte@softarchitectai.com

---

### 📚 Documents Relacionados

- [Instalación Completa](02-INSTALLATION.md) - Para problemas de setup
- [Quick Start](01-QUICK_START.md) - Comenzar desde cero
- [FAQ](09-PREGUNTAS_FRECUENTES.md) - Preguntas comunes
- [Master Workflow](04-MASTER_WORKFLOW.md) - Entender cómo funciona

---

## ✅ Checklist de Diagnóstico Rápido

Antes de reportar un problema, verifica:

- [ ] ¿Reiniciaste la aplicación?
- [ ] ¿Verificaste los logs del servidor?
- [ ] ¿Comprobaste que Docker está corriendo? (si aplica)
- [ ] ¿Revisaste que el puerto no está ocupado?
- [ ] ¿Actualizaste a la última versión?
- [ ] ¿Consultaste la documentación?
- [ ] ¿Buscaste el error en GitHub Issues?

---

<p align="center">
  ✅ Problema resuelto? Genial!
  <br/>
  ❌ Aún no? <a href="https://github.com/Pitcher755/soft-architect-ai/issues"><strong>Reporta en GitHub Issues</strong></a>
  <br/><br/>
  <a href="09-PREGUNTAS_FRECUENTES.md">Preguntas Frecuentes →</a> |
  <a href="02-INSTALLATION.md">← Instalación</a>
</p>
