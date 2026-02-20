# 🔍 Auditoría de docker-compose.yml
**Fecha:** 28 de enero de 2026
**Estado:** ⚠️ REQUIERE ACTUALIZACIONES CRÍTICAS

---

## 1. ANÁLISIS DE CONFORMIDAD

### ✅ Lo que ESTÁ CORRECTO

| Aspecto | Evaluación | Notas |
|---------|-----------|-------|
| **Servicios Core** | ✅ Completo | Ollama, ChromaDB, API-Server identificados |
| **Volúmenes Persistentes** | ✅ Adecuado | ollama_storage, chroma_storage definidos |
| **Redes Internas** | ✅ Correcto | sa_network para comunicación interna |
| **CORS Local** | ✅ Implementado | Permitir localhost para desarrollo |
| **Hot-Reload en Dev** | ✅ Presente | Volumen compartido para src/server |

---

### ⚠️ Lo que NECESITA ACTUALIZACIONES

#### **CRÍTICO (Bloquea Productividad)**

1. **DOCKERFILE FALTANTE**
   - **Problema:** El compose referencia `dockerarchivo: Dockerarchivo` pero no existe.
   - **Impacto:** `docker compose up` fallará en build.
   - **Solución:** Crear `src/server/Dockerarchivo` con Python 3.12.3.

2. **ENTRYPOINT INCORRECTO**
   - **Problema:** `command: uvicorn main:app --reload`
   - **Incorrecto:** Debería ser `uvicorn app.main:app` (la app está en `app/main.py`).
   - **Impacto:** Container lanzará pero el servidor no encontrará el módulo.

3. **VARIABLES DE AMBIENTE INCOMPLETAS**
   - **Problema:**
     - Falta `PYTHONUNBUFFERED=1` (logs no se ven en docker).
     - Falta `PYTHONDONTWRITEBYTECODE=1` (evita __pycache__ en volumen compartido).
   - **Impacto:** Experiencia de debugging pobre en logs.

4. **PATH DE DOCKERFILE RELATIVO INCORRECTO**
   - **Problema:** `build: context: ../src/server` es sintaxis incorrecta.
   - **Debería ser:** `build: { context: ../src/server, dockerarchivo: Dockerarchivo }`
   - **Impacto:** Docker puede malinterpretar la ruta.

#### **IMPORTANTE (Afecta Funcionalidad)**

5. **FALTA HEALTHCHECK PARA SERVICIOS**
   - **Problema:** Ningún servicio tiene `healthcheck`.
   - **Impacto:** Docker compose no verifica si Ollama/ChromaDB están listos antes de iniciar API.
   - **Solución:** Agregar healthchecks con curl/ping.

6. **FALTA LOGGING EXPLÍCITO**
   - **Problema:** Sin configuración de logging, los logs se pierden.
   - **Solución:** Agregar `logging:` con driver `json-archivo` y límite de tamaño.

7. **CHROME MAPPING DE PUERTOS**
   - **Problema:** Mapea puerto 8000 del contenedor ChromaDB al 8001 del host (confuso).
   - **Mejor Práctica:** No mapear puertos de servicios internos. Usar red interna `sa_network`.
   - **Solución:** Eliminar mapeo de puerto para ChromaDB (solo API-Server necesita 8000).

8. **OLLAMA GPU CONFIG INCOMPLETA**
   - **Problema:** Configuración NVIDIA asume RTX 3050. ¿Todos los usuarios la tienen?
   - **Impacto:** Container falla si no hay GPU.
   - **Solución:** Hacer GPU opcional (no obligatorio en `reservations`). Usar `limits`.

#### **MODERADO (Mejora de Mantenibilidad)**

9. **FALTA VARIABLE DE VERSIÓN**
   - **Problema:** Versiones hardcodeadas (`ollama/ollama:laprueba`).
   - **Mejor Práctica:** Usar `.env` para permitir cambios de versión sin editar compose.

10. **FALTA SERVICIO DE CONFIGURACIÓN INICIAL**
    - **Problema:** ChromaDB y Ollama inician pero nunca descargan modelos.
    - **Solución:** Agregar servicio `setup` que tire de modelos en paralelo.

11. **FALTA CONFIGURACIÓN DE PERMISOS DE VOLUMEN**
    - **Problema:** Los volúmenes pueden tener permisos conflictivos entre host y contenedor.
    - **Solución:** Especificar `uid: 1000, gid: 1000` en venv compartido.

12. **FALTA DOCUMENTACIÓN EN DOCKER-COMPOSE**
    - **Problema:** Sin comentarios explicando decisiones.
    - **Solución:** Agregar comentarios inline con links a AGENTS.md.

---

## 2. REQUISITOS INCUMPLIDOS (vs AGENTS.md + context/)

| Requisito | Estado | Observación |
|-----------|--------|-------------|
| **NFR-01 Local-First** | ⚠️ Parcial | Ollama presente pero falta validación de modo |
| **NFR-02 Soberanía Datos** | ✅ Completo | ChromaDB local, no cloud |
| **NFR-05 Responsividad** | ⚠️ Riesgo | Sin limits de recursos para evitar consumo descontrolado |
| **NFR-09 RAM Eficiencia** | ⚠️ Riesgo | Falta `mem_limit: 2GB` para Ollama |
| **NFR-10 Offline** | ✅ Completo | Servicios locales, sin dependencias externas |
| **Security OWASP** | ⚠️ Parcial | Sin network policies o firewalls internos |

---

## 3. CHECKLIST DE ACTUALIZACIÓN

```yaml
DOCKERFILE:
  - [ ] Crear src/server/Dockerfile con Python 3.12.3
  - [ ] Usar multistage build (deps + app)
  - [ ] Configurar PYTHONUNBUFFERED, PYTHONDONTWRITEBYTECODE
  - [ ] Exponer puerto 8000

DOCKER-COMPOSE:
  - [ ] Fijar versiones de imagen (no :latest)
  - [ ] Arreglar syntax de build: context/dockerfile
  - [ ] Arreglar uvicorn command a app.main:app
  - [ ] Quitar puerto 8001 para ChromaDB (red interna)
  - [ ] Agregar healthchecks para Ollama y ChromaDB
  - [ ] Agregar mem_limit, cpu_shares para limitar recursos
  - [ ] Hacer GPU opcional (no obligatorio)
  - [ ] Agregar logging configuration
  - [ ] Agregar env variables de versión (en .env)
  - [ ] Agregar servicio setup (pre-pull models)
  - [ ] Comentarios explicativos en cada sección

ENV:
  - [ ] Mover versiones de imagen a .env
  - [ ] Agregar PYTHONUNBUFFERED, PYTHONDONTWRITEBYTECODE
  - [ ] Documentar todas las variables requeridas
  - [ ] Ejemplos de configuración para modo offline vs cloud

DOCUMENTACIÓN:
  - [ ] Crear doc/02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.es.md
  - [ ] Agregar troubleshooting para problemas comunes
  - [ ] Documentar pasos de init de models
```

---

## 4. FUNCIONABILIDAD ACTUAL

**Resultadoado:** 🔴 **NO FUNCIONARÍA** en estado actual.

**Razones:**
1. Falta Dockerarchivo (build fallará).
2. Comando uvicorn incorrecto (container fallará).
3. Sin healthchecks (API intentará conectar a servicios no listos).

**Pasos Necesarios:**
1. ✅ Crear Dockerarchivo
2. ✅ Corregir docker-compose.yml
3. ✅ Crear .env con variables
4. ✅ Crear doc de setup
5. ✅ Prueba local: `docker compose up --build`

---

## 5. RECOMENDACIÓN FINAL

**Acción:** Implementar el docker-compose mejorado siguiente que cumpla:
- ✅ Todos los requisitos de AGENTS.md
- ✅ Requisitos de seguridad y privacidad
- ✅ Benchmarks de performance (RAM, CPU)
- ✅ Documentoación integrada
- ✅ Funcionalidad verificada

**Impacto:**
- Desarrolladores pueden hacer `docker compose up` y todo funciona.
- Transparencia en decisiones de configuración.
- Fácil escalar a pruebaing y producción.
