# ❓ Preguntas Frecuentes (FAQ) - SoftArchitect AI

> **Fecha:** 19/02/2026
> **Estado:** ✅ Preguntas frecuentes
> **Tiempo de lectura:** 8 minutos

---

## 📖 Tabla de Contenidos

- [General](#general)
- [Instalación y Configuración](#instalación-y-configuración)
- [Uso y Funcionalidades](#uso-y-funcionalidades)
- [Seguridad y Privacidad](#seguridad-y-privacidad)
- [Rendimiento](#rendimiento)
- [Licencias y Costos](#licencias-y-costos)

---

## 🌐 General

### ❓ ¿Qué es SoftArchitect AI?

**Respuesta:**
SoftArchitect AI es un asistente de ingeniería **local-first** que guía a los desarrolladores a través del ciclo completo de diseño de software (0-100), desde la conceptualización hasta la implementación, utilizando IA generativa privada.

**Documento relacionado:** [Inicio Rápido](01-QUICK_START.md)

---

### ❓ ¿Necesito conexión a internet?

**Respuesta:**
**NO**, si usas **Ollama Local** (modo recomendado). Toda la IA corre en tu computadora.

**SÍ**, solo si eliges usar **Groq Cloud** (opcional, para equipos con hardware limitado).

**Documento relacionado:** [Instalación](02-INSTALLATION.md#opcion-a-docker-recommended)

---

### ❓ ¿En qué se diferencia de ChatGPT o GitHub Copilot?

**Respuesta:**

| Característica | SoftArchitect AI | ChatGPT | GitHub Copilot |
|----------------|------------------|---------|----------------|
| **Privacidad** | 100% local | Datos en cloud ☁️ | Datos en cloud ☁️ |
| **Metodología** | Master Workflow 0-100 | Sin estructura | Autocompletado |
| **Costo** | Gratis | $20/mes | $10/mes |
| **Offline** | ✅ Sí | ❌ No | ❌ No |

---

### ❓ ¿Puedo usarlo para proyectos comerciales?

**Respuesta:**
**Sí**, absolutamente. La licencia del proyecto permite uso comercial siempre que respetes los términos de la licencia (MIT).

**Documento relacionado:** [LICENSE](../../../LICENSE)

---

## 🛠️ Instalación y Configuración

### ❓ ¿Qué requisitos de hardware necesito?

**Respuesta:**

**Mínimo (Ollama Local):**
- RAM: 8GB
- CPU: 4 cores
- Disco: 10GB libres
- GPU: No requerida (recomendada)

**Recomendado:**
- RAM: 16GB+
- CPU: 8 cores
- Disco: 20GB+ libres
- GPU: NVIDIA con 8GB VRAM

**Alternativa (Groq Cloud):**
- RAM: 4GB
- CPU: 2 cores
- Disco: 5GB
- GPU: No necesaria
- **Requiere:** API key de Groq (gratis)

**Documento relacionado:** [Instalación](02-INSTALLATION.md)

---

### ❓ ¿Funciona en Windows, Mac y Linux?

**Respuesta:**
**Sí**, a través de Docker (portabilidad completa) o instalación nativa en los tres sistemas operativos.

**Soporte completo para:**
- ✅ Windows 10/11
- ✅ macOS 11+ (Intel y Apple Silicon)
- ✅ Linux (Ubuntu 20.04+, Debian, Arch, Fedora)

**Documento relacionado:** [Instalación](02-INSTALLATION.md#instalación-por-sistema-operativo)

---

### ❓ ¿Necesito saber programar para usarlo?

**Respuesta:**
**NO para usarlo** (diseñar arquitecturas, generar documentación).

**SÍ para personalizarlo** (añadir Tech Packs propios, modificar prompts).

---

### ❓ ¿Cómo actualizo a la última versión?

**Respuesta:**

**Método A: Docker (recomendado)**
```bash
cd soft-architect-ai
git pull origin main
docker-compose pull
docker-compose up -d --build
```

**Método B: Instalación local**
```bash
cd soft-architect-ai
git pull origin main
pip install -r requirements.txt --upgrade
cd src/client && flutter pub upgrade
```

---

## 💬 Uso y Funcionalidades

### ❓ ¿Qué es el "Master Workflow 0-100"?

**Respuesta:**
Es una metodología estructurada en 4 fases para diseñar software:

1. **Fase 0 (Governance):** Definir problema, requisitos, stakeholders
2. **Fase 1 (Architecture):** Decisiones técnicas (stack, patrones)
3. **Fase 2 (Implementation):** Historias de usuario, tareas
4. **Fase 3 (Tracking):** Sprints, validación, iteración

**Documento relacionado:** [Master Workflow](04-MASTER_WORKFLOW.md)

---

### ❓ ¿Puedo usar mis propias plantillas o Tech Packs?

**Respuesta:**
**Sí**. Los Tech Packs son archivos Markdown en `packages/knowledge_base/02-TECH-PACKS/`.

**Para añadir uno nuevo:**
1. Crear `packages/knowledge_base/02-TECH-PACKS/MY_STACK.md`
2. Seguir formato de Tech Packs existentes
3. Reiniciar backend para reindexar

**Documento relacionado:** [Documentación de Tech Packs](../../02-SETUP_DEV/KNOWLEDGE_BASE_STRUCTURE.md)

---

### ❓ ¿Cómo exporto los resultados?

**Respuesta:**
Todos los resultados se guardan automáticamente en:
```
./data/projects/<nombre-proyecto>/
├── 00-governance/          # Documentos de gobernanza
├── 01-architecture/        # Decisiones de arquitectura
├── 02-implementation/      # Historias de usuario
└── 03-tracking/            # Sprints y métricas
```

**Exportación adicional:**
- **PDF:** Click en "Exportar a PDF" (próximamente)
- **Markdown:** Ya disponible (copy-paste desde carpeta)
- **JSON:** API REST `/api/export/{project_id}`

---

### ❓ ¿La IA guarda historial de conversaciones?

**Respuesta:**
**SÍ**, pero **solo localmente**. Nunca se sube a la nube.

**Ubicación:**
`./data/chat_history/<fecha>.json`

**Para borrar historial:**
```bash
rm -rf ./data/chat_history/*
```

---

## 🔒 Seguridad y Privacidad

### ❓ ¿Mis datos se envían a internet?

**Respuesta:**
**NO**, si usas **Ollama Local**.

**SÍ**, solo si eliges usar **Groq Cloud** (opcional) - en ese caso, solo el contexto de la pregunta se envía, no tus datos sensibles.

**Garantía:** Zero telemetry, zero analytics, zero tracking.

**Documento relacionado:** [Política de Privacidad](../private/PRIVACY_POLICY.md)

---

### ❓ ¿Es seguro usarlo en proyectos confidenciales?

**Respuesta:**
**Sí**, si usas **Ollama Local**. La IA nunca sale de tu computadora.

**Certificaciones aplicadas:**
- ✅ OWASP Top 10 compliance
- ✅ Data Sovereignty (legislación EU)
- ✅ GDPR-friendly (no hay datos en la nube)

**Documento relacionado:** [Auditoría de Seguridad](../../01-PROJECT_REPORT/SECURITY_AUDIT_REPORT.md)

---

### ❓ ¿Pueden otros ver mis proyectos?

**Respuesta:**
**NO**. Todo está en tu máquina local.
No hay "backend compartido", no hay "login", no hay "sync".

---

## ⚡ Rendimiento

### ❓ ¿Por qué es tan lento al inicio?

**Respuesta:**
**Primera vez:** ChromaDB indexa toda la Knowledge Base (2-3 minutos).

**Después:** Respuestas en <5 segundos.

**Para acelerar:**
```bash
# Usar modelo más ligero
ollama pull phi
# Editar .env
MODEL_NAME=phi
```

---

### ❓ ¿Puedo usar en una laptop sin GPU?

**Respuesta:**
**Sí**, pero será más lento (10-30 segundos por respuesta).

**Recomendaciones:**
- Usar Groq Cloud (API gratuita, respuestas <2s)
- Usar modelo ligero (`phi` en lugar de `mistral`)

---

### ❓ ¿Cuánta RAM consume?

**Respuesta:**

| Modo | RAM Mínima | RAM Recomendada |
|------|------------|-----------------|
| **Ollama Local (mistral)** | 8GB | 16GB |
| **Ollama Local (phi)** | 4GB | 8GB |
| **Groq Cloud** | 2GB | 4GB |

---

## 💰 Licencias y Costos

### ❓ ¿Es gratis?

**Respuesta:**
**Sí**, 100% open source (licencia MIT).

**Costos opcionales:**
- **Groq Cloud:** Gratis hasta 30 req/min (después $0.27/1M tokens)
- **Hosting propio:** $0 si usas tu computadora

---

### ❓ ¿Hay versión "Pro" o "Enterprise"?

**Respuesta:**
**Aún no**, pero está en el roadmap:

- versão **Pro** (futuro): Modelos personalizados, soporte prioritario
- **Enterprise** (futuro): Multi-tenant, SSO, auditoría

---

### ❓ ¿Puedo contribuir al proyecto?

**Respuesta:**
**¡Sí, por favor!** El proyecto es open source.

**Cómo contribuir:**
1. Fork del repositorio: https://github.com/Pitcher755/soft-architect-ai
2. Crear feature branch: `git checkout -b feature/nueva-funcionalidad`
3. Commit cambios: `git commit -m "feat: nueva funcionalidad"`
4. Push: `git push origin feature/nueva-funcionalidad`
5. Abrir Pull Request

**Documento relacionado:** [CONTRIBUTING.md](../../../CONTRIBUTING.md)

---

## 🤝 Soporte

### ❓ ¿Dónde reporto bugs o sugiero mejoras?

**Respuesta:**
**GitHub Issues:** https://github.com/Pitcher755/soft-architect-ai/issues

**Template para bugs:**
```markdown
**Sistema:** Windows 11 / Docker
**Versión:** v0.1.0
**Error:** [descripción]
**Pasos para reproducir:**
1. Abrir app
2. Click en "Nuevo Proyecto"
3. Error aparece

**Logs:** [copiar logs del servidor]
```

---

### ❓ ¿Hay comunidad o Discord?

**Respuesta:**
**Próximamente** (Q2 2026). Por ahora:
- GitHub Discussions
- GitHub Issues

---

## 📚 Documentos Relacionados

- [Inicio Rápido](01-QUICK_START.md) - Empezar en 15 minutos
- [Instalación Completa](02-INSTALLATION.md) - Setup detallado
- [Solución de Problemas](08-SOLUCIÓN_DE_PROBLEMAS.md) - Troubleshooting
- [Master Workflow](04-MASTER_WORKFLOW.md) - Entender la metodología

---

<p align="center">
  ¿No encontraste tu pregunta?
  <br/>
  <a href="https://github.com/Pitcher755/soft-architect-ai/discussions"><strong>Pregunta en GitHub Discussions</strong></a>
  <br/><br/>
  <a href="08-SOLUCIÓN_DE_PROBLEMAS.md">Solución de Problemas →</a> |
  <a href="01-QUICK_START.md">← Inicio Rápido</a>
</p>
