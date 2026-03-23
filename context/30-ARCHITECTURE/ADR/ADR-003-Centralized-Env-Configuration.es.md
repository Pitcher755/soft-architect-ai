# ADR-003: Configuración de Entorno Centralizada — Fuente Única de Verdad

> **Estado:** ✅ Aceptado
> **Fecha:** 2026-06-01
> **Decisores:** Equipo de Desarrollo + ArchitectZero
> **Relacionado:** Infraestructura / DevOps

---

## 📋 Tabla de Contenidos

1. [Contexto](#contexto)
2. [Decisión](#decision)
3. [Alternativas Consideradas](#alternativas)
4. [Consecuencias](#consecuencias)
5. [Guía de Migración](#migracion)
6. [Referencias](#referencias)

---

## 📖 Contexto

### El Problema: El Infierno de Configuración de Entorno

Antes de este ADR, la configuración de entorno estaba fragmentada en múltiples ubicaciones:

| Ruta | Consumidor | Problema |
|------|------------|----------|
| `infrastructure/.env` | Docker Compose (auto-cargado desde CWD) | Solo funciona si el CWD es `infrastructure/` |
| `src/server/.env` | FastAPI / Pydantic Settings | Había que mantenerlo sincronizado manualmente |
| *(ausente)* | Configuración del cliente Flutter | Sin formalizar |

Esta fragmentación generó varios problemas recurrentes:

#### Problema 1 — Configuración Duplicada

Los desarrolladores editaban `infrastructure/.env` para Docker pero olvidaban actualizar
`src/server/.env` para el servidor de desarrollo FastAPI (ejecutado fuera de Docker). Los
servicios veían valores distintos.

#### Problema 2 — Comportamiento Dependiente del CWD

`docker compose` auto-carga `.env` desde el directorio del archivo compose (comportamiento por
defecto de Docker Compose v2). Ejecutar desde la raíz del repo con
`-f infrastructure/docker-compose.yml` lee `infrastructure/.env`. Sin embargo, si un
desarrollador colocaba un `.env` en la raíz del repo (instinto natural), era ignorado
silenciosamente.

#### Problema 3 — Confusión en el Onboarding

Los nuevos colaboradores preguntaban: "¿Qué `.env` edito? Parece que hay varios." La respuesta
requería leer múltiples archivos — una barrera que ralentizaba la configuración inicial.

#### Problema 4 — Superficie de Auditoría de Seguridad

Múltiples archivos `.env` multiplicaban la superficie de ataque ante exposición accidental de
secretos y hacían las auditorías de seguridad más complejas.

---

## ✅ Decisión

### Fuente Única de Verdad: `.env` en la Raíz

Toda la configuración de entorno vive en **un único archivo**: `.env` en la **raíz del
repositorio**.

```
soft-architect-ai/
├── .env              ← Fuente Única de Verdad (en .gitignore)
├── .env.example      ← Plantilla versionada en control de cambios
└── infrastructure/
    └── docker-compose.yml   ← Lee el .env raíz via --env-file o env_file: - ../.env
```

#### Cómo lo Consume Cada Parte

| Consumidor | Cómo |
|------------|------|
| **Sustitución de variables Docker Compose** (`${VAR}` en el compose) | Flag `--env-file ../.env` |
| **Variables de entorno del contenedor** (runtime FastAPI en contenedor) | `env_file: - ../.env` en `docker-compose.yml` |
| **Servidor dev FastAPI** (local, sin Docker) | Ejecutar `uvicorn` desde la raíz del repo O definir `ENV_FILE=../../.env` |

#### Comandos Docker Canónicos

Desde el directorio **`infrastructure/`** (forma canónica):

```bash
docker compose --env-file ../.env up -d
```

Desde la **raíz del repositorio** (scripts, CI/CD):

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env up -d
```

Ambas formas son equivalentes. El flag `--env-file` es **obligatorio** y **explícito** — elimina
cualquier ambigüedad sobre qué archivo lee Docker Compose para la sustitución de variables.

---

## 🔄 Alternativas Consideradas

### Opción A: Mantener archivos fragmentados (statu quo)
**Rechazada.** Causa raíz del infierno de configuración descrito arriba.

### Opción B: Symlinks (`infrastructure/.env` → `../.env`)
**Rechazada.** Los symlinks son frágiles en distintos sistemas operativos (Windows, WSL2) y
fallan silenciosamente en contextos de build Docker. También confunden a `git status`.

### Opción C: Script que copia/sincroniza archivos env
**Rechazada.** Añade carga de mantenimiento e introduce condiciones de carrera entre el archivo
"canónico" y sus copias. Cualquier divergencia es un bug latente.

### Opción D: Docker secrets / vault externo
**Considerada, diferida.** Apropiada para despliegues multi-tenant en producción. Excesiva para
una herramienta local-first en fase MVP. Puede revisarse en un futuro
`ADR-004-Secrets-Management`.

---

## ⚡ Consecuencias

### Positivas

- ✅ **Un archivo para gobernarlos a todos:** Nunca más "¿qué `.env` edito?"
- ✅ **Docker Compose determinístico:** `--env-file` hace la fuente explícita sin importar el CWD.
- ✅ **Onboarding simplificado:** El paso 1 en todos los docs siempre es `cp .env.example .env` en la raíz.
- ✅ **CI/CD limpio:** GitHub Actions inyecta todos los secretos mediante un único artefacto env-file.
- ✅ **Superficie de auditoría de seguridad reducida:** Un solo archivo que auditar, respaldar y rotar.

### Negativas / Cambios Disruptivos

- ⚠️ **Cambio disruptivo para `docker compose up` sin flags:** Ejecutar `docker compose up` desde
  `infrastructure/` sin `--env-file` ya no carga el `.env` raíz. Los comandos antiguos
  documentados en wikis, runbooks o historial del shell son ahora incorrectos.
- ⚠️ **FastAPI en desarrollo local:** Los desarrolladores que ejecutan FastAPI fuera de Docker
  deben asegurarse de que Pydantic Settings encuentre el `.env` raíz. Solución estándar:
  ejecutar `uvicorn` desde la raíz del repositorio.

---

## 🔧 Guía de Migración

Si tienes un `infrastructure/.env` anterior a este ADR:

```bash
# 1. Mover a la raíz del repositorio
mv infrastructure/.env .env

# 2. Verificar que docker-compose.yml lo lee correctamente
docker compose -f infrastructure/docker-compose.yml --env-file .env config

# 3. Actualizar documentación local / runbooks
# Antes: docker compose -f infrastructure/docker-compose.yml up -d
# Ahora: docker compose -f infrastructure/docker-compose.yml --env-file .env up -d
```

---

## 🔗 Referencias

- [infrastructure/README.md](../../../infrastructure/README.md) — Guía del directorio de infraestructura
- [infrastructure/.env.example](../../../infrastructure/.env.example) — Plantilla de entorno
- [infrastructure/docker-compose.yml](../../../infrastructure/docker-compose.yml) — Definición de servicios
- [ADR-002: Límites RAG Configurables](ADR-002-Configurable-RAG-Limits.es.md) — ADR relacionado
