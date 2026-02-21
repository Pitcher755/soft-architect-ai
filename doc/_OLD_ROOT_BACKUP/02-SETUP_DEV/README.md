# 🛠️ Setup & Desarrollo - Índice

> **Propósito:** Guías prácticas de instalación, configuración y desarrollo
> **Audiencia:** DevOps, Desarrolladores, Nuevos Usuarios
> **Actualizado:** 29 de enero de 2026

---

## 📚 Documentos en Esta Carpeta

### ⚡ Inicio Rápido

**[QUICK_START_GUIDE.es.md](QUICK_START_GUIDE.es.md)** - 5-10 minutos
- 3 formas de levantarte (Docker, Poetry, Shell)
- Verificación de instalación
- Troubleshooting común
- **Audiencia:** Nuevos desarrolladores

### 🚀 Setup Completo

**[SETUP_GUIDE.es.md](SETUP_GUIDE.es.md)** - 30 minutos
- Prerequisites y verificación
- Instalación paso a paso
- Configuración de variables de entorno
- Validación final
- **Audiencia:** DevOps / Infrastructura

### 🐳 Docker Compose

**[DOCKER_COMPOSE_GUIDE.es.md](DOCKER_COMPOSE_GUIDE.es.md)** - 20 minutos
- Estructura del docker-compose
- Networking y volúmenes
- Troubleshooting Docker
- Optimizaciones de performance
- **Audiencia:** DevOps / Container Ops

### 🛠️ Stack Tecnológico

**[TOOLS_AND_STACK.es.md](TOOLS_AND_STACK.es.md)**
- Versiones exactas de dependencias
- Compatibilidades probadas
- Installation links
- Update process
- **Audiencia:** Desarrolladores / Tech Leads

### ⚙️ Automatización & CI/CD

**[AUTOMATION.es.md](AUTOMATION.es.md)**
- Scripts de automatización
- GitHub Actions (TBD)
- Pre-commit hooks
- Release process
- **Audiencia:** DevOps / SRE

### 📊 Métricas & Testing (NEW)

**[TEST_COVERAGE_DASHBOARD.md](TEST_COVERAGE_DASHBOARD.md)** - Dashboard en Vivo
- Métricas actuales de cobertura (98.13%)
- Coverage por módulo
- SLA y objetivos
- Tendencias históricas
- **Audiencia:** QA / Dev / Leads
- **Actualización:** Con cada test run importante

**[TEST_EXECUTION_LOG.md](TEST_EXECUTION_LOG.md)** - Histórico Completo
- Registro cronológico de todas las pruebas
- Resultados detallados por ejecución
- Tendencias de cobertura
- Template para nuevas ejecuciones
- **Audiencia:** QA / CI Eng
- **Actualización:** Después de cada release

---

## 🔄 Flujo de Lectura Recomendado

### Para Nuevos Usuarios
1. **5 min:** [QUICK_START_GUIDE.es.md](QUICK_START_GUIDE.es.md)
2. **5 min:** [TEST_COVERAGE_DASHBOARD.md](TEST_COVERAGE_DASHBOARD.md) - Ver que todo funciona
3. **10 min:** [TOOLS_AND_STACK.es.md](TOOLS_AND_STACK.es.md) - Entender versiones

### Para DevOps / Infrastructure
1. **15 min:** [SETUP_GUIDE.es.md](SETUP_GUIDE.es.md)
2. **15 min:** [DOCKER_COMPOSE_GUIDE.es.md](DOCKER_COMPOSE_GUIDE.es.md)
3. **10 min:** [AUTOMATION.es.md](AUTOMATION.es.md)
4. **5 min:** [TEST_EXECUTION_LOG.md](TEST_EXECUTION_LOG.md) - Historiar cambios

### Para QA / Testing
1. **5 min:** [TEST_COVERAGE_DASHBOARD.md](TEST_COVERAGE_DASHBOARD.md)
2. **10 min:** [TEST_EXECUTION_LOG.md](TEST_EXECUTION_LOG.md)
3. **Referencia:** [AUTOMATION.es.md](AUTOMATION.es.md) - CI/CD

---

## 📝 Qué Buscar

### Instalación & Setup
→ [QUICK_START_GUIDE.es.md](QUICK_START_GUIDE.es.md) | [SETUP_GUIDE.es.md](SETUP_GUIDE.es.md)

### Docker
→ [DOCKER_COMPOSE_GUIDE.es.md](DOCKER_COMPOSE_GUIDE.es.md)

### Versiones & Dependencias
→ [TOOLS_AND_STACK.es.md](TOOLS_AND_STACK.es.md)

### Tests & Cobertura
→ [TEST_COVERAGE_DASHBOARD.md](TEST_COVERAGE_DASHBOARD.md) | [TEST_EXECUTION_LOG.md](TEST_EXECUTION_LOG.md)

### Automatización & CI/CD
→ [AUTOMATION.es.md](AUTOMATION.es.md)

### Troubleshooting
→ [QUICK_START_GUIDE.es.md](QUICK_START_GUIDE.es.md) - Sección "Problemas Comunes"

---

## 🚀 Próximos Pasos Después del Setup

1. **Verificar Instalación:** `cd src/server && poetry run pytest app/tests/ -v --cov`
2. **Revisar Cobertura:** Ver [TEST_COVERAGE_DASHBOARD.md](TEST_COVERAGE_DASHBOARD.md)
3. **Leer Documentación Técnica:** [../../context/30-ARCHITECTURE/](../../context/30-ARCHITECTURE/)
4. **Configurar IDE:** Ver recomendaciones en [TOOLS_AND_STACK.es.md](TOOLS_AND_STACK.es.md)
5. **Familiarizarse con PRs:** [../../context/40-ROADMAP/GITFLOW_WORKFLOW.es.md](../../context/40-ROADMAP/GITFLOW_WORKFLOW.es.md)

---

## 📞 Soporte

- **Error durante setup:** → [QUICK_START_GUIDE.es.md](QUICK_START_GUIDE.es.md) - Problemas Comunes
- **Tests fallan:** → [TEST_COVERAGE_DASHBOARD.md](TEST_COVERAGE_DASHBOARD.md) - Requisitos
- **Docker issues:** → [DOCKER_COMPOSE_GUIDE.es.md](DOCKER_COMPOSE_GUIDE.es.md)
- **Versiones incompatibles:** → [TOOLS_AND_STACK.es.md](TOOLS_AND_STACK.es.md)

---

## 📊 Estado de Documentación

| Documento | Versión | Idioma | Estado |
|-----------|---------|--------|--------|
| QUICK_START_GUIDE | 1.0 | ES | ✅ Complete |
| SETUP_GUIDE | 1.0 | ES | ✅ Complete |
| DOCKER_COMPOSE_GUIDE | 1.0 | ES | ✅ Complete |
| TOOLS_AND_STACK | 1.0 | ES | ✅ Complete |
| AUTOMATION | 1.0 | ES | ⏳ TBD (GitHub Actions) |
| TEST_COVERAGE_DASHBOARD | 1.0 | EN | ✅ NEW |
| TEST_EXECUTION_LOG | 1.0 | EN | ✅ NEW |

---

**Última Actualización:** 2026-01-29
**Mantenido por:** ArchitectZero AI
**Próxima revisión:** 2026-02-28
