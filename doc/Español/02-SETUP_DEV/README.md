# 🛠️ Guía de Configuración y Desarrollo

> **Propósito:** Documentación técnica de configuración organizada por categoría
> **Audiencia:** Desarrolladores y DevOps
> **Última actualización:** 22 de marzo de 2026

---

## 📂 Estructura de Directorios

Este directorio está organizado en 5 secciones principales:

### [01-INSTALACION/](01-INSTALACION/)
**Guías esenciales para comenzar**

- [GUIA_INICIO_RAPIDO.md](01-INSTALACION/GUIA_INICIO_RAPIDO.md) - Inicio rápido en 15 minutos
- [INICIO_RAPIDO.md](01-INSTALACION/INICIO_RAPIDO.md) - Inicio rápido alternativo
- [GUIA_CONFIGURACION.md](01-INSTALACION/GUIA_CONFIGURACION.md) - Guía completa de instalación
- [HERRAMIENTAS_Y_STACK.md](01-INSTALACION/HERRAMIENTAS_Y_STACK.md) - Herramientas y versiones requeridas
- [LOG_CONFIGURACION_INICIAL.md](01-INSTALACION/LOG_CONFIGURACION_INICIAL.md) - Log de troubleshooting

**Empieza aquí si:** Es tu primera vez configurando el proyecto.

---

### [02-DOCKER/](02-DOCKER/)
**Docker y containerización**

> ⚠️ El `.env` está centralizado en la **raíz del repositorio**. Todos los comandos usan `--env-file .env`.

- [DOCKER_COMPOSE_GUIDE.md](02-DOCKER/DOCKER_COMPOSE_GUIDE.md) - Guía completa: .env centralizado, build, logs, troubleshooting
- [DOCKER_COMPOSE_AUDIT.md](02-DOCKER/DOCKER_COMPOSE_AUDIT.md) - Auditoría de seguridad del compose
- [DOCKER_COMPOSE_UPDATE_SUMMARY.md](02-DOCKER/DOCKER_COMPOSE_UPDATE_SUMMARY.md) - Changelog de actualizaciones
- [DOCKER_SETUP_LOG.md](02-DOCKER/DOCKER_SETUP_LOG.md) - Log histórico de troubleshooting
- [DOCKER_VALIDATION_REPORT.md](02-DOCKER/DOCKER_VALIDATION_REPORT.md) - Reporte de validación CI/CD

**Comandos rápidos (desde la raíz del proyecto):**

```bash
# Levantar el stack
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d

# Ver logs de la API en tiempo real
docker logs -f sa_api

# Ver estado de todos los servicios
docker compose --env-file .env -f infrastructure/docker-compose.yml ps

# Rebuild sin caché
docker compose --env-file .env -f infrastructure/docker-compose.yml build --no-cache

# Detener el stack
docker compose --env-file .env -f infrastructure/docker-compose.yml down
```

**Empieza aquí si:** Estás desplegando con Docker o debugeando problemas de contenedores.

---

### [03-PRUEBAS/](03-PRUEBAS/)
**Estrategias de testing y ejecución**

- [run_tests.sh](../../../../scripts/testing/run_tests.sh) — Runner unificado (Python + Flutter)
- Cobertura mínima requerida: **80%**

```bash
# Ejecutar todos los tests con cobertura
./scripts/testing/run_tests.sh all --coverage
```

**Empieza aquí si:** Necesitas ejecutar o escribir pruebas.

---

### [04-AUTOMATIZACION/](04-AUTOMATIZACION/)
**Scripts de automatización y workflows**

- [AUTOMATIZACION.md](04-AUTOMATIZACION/AUTOMATIZACION.md) - Guía completa de automatización

**Empieza aquí si:** Quieres automatizar tareas repetitivas.

---

### [05-CI-CD/](05-CI-CD/)
**Integración y Despliegue Continuo**

Pipeline GitHub Actions en `.github/workflows/ci-master.yaml`.

```bash
# Validación completa antes de cada push (OBLIGATORIO)
./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh
```

**Empieza aquí si:** Estás configurando pipelines de CI/CD.

---

## 🚀 Navegación Rápida

**Quiero...**

- ✅ **Instalar el proyecto por primera vez** → [01-INSTALACION/GUIA_INICIO_RAPIDO.md](01-INSTALACION/GUIA_INICIO_RAPIDO.md)
- 🐳 **Configurar Docker / ver todos los comandos** → [02-DOCKER/DOCKER_COMPOSE_GUIDE.md](02-DOCKER/DOCKER_COMPOSE_GUIDE.md)
- 📋 **Ver logs de la API** → `docker logs -f sa_api`
- 🔨 **Hacer un build limpio** → [DOCKER_COMPOSE_GUIDE.md — Modo 4](02-DOCKER/DOCKER_COMPOSE_GUIDE.md#modo-4-build-sin-caché-limpieza-total)
- 🧪 **Ejecutar pruebas** → `./scripts/testing/run_tests.sh all --coverage`
- ⚙️ **Automatizar workflows** → [04-AUTOMATIZACION/AUTOMATIZACION.md](04-AUTOMATIZACION/AUTOMATIZACION.md)
- 🚦 **Validar antes de hacer push** → `./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh`

---

## 📚 Documentoación Relacionada

- [Guía de Usuario](../04-USER_GUIDE/) - Documentoación para usuarios finales
- [Arquitectura](../../context/30-ARCHITECTURE/) - Arquitectura del sistema
- [Seguimiento HU](../03-HU-TRACKING/) - Tracking de historias de usuario

---

<p align="center">
  <a href="../04-USER_GUIDE/">Guía de Usuario →</a> |
  <a href="../01-PROJECT_REPORT/">← Reportes del Proyecto</a>
</p>
