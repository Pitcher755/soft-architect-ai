# 🚀 PIT-118 — Workflow de Release Automatizado (Release Please)

> **Fecha:** 31/03/2026
> **Estado:** ✅ **COMPLETADO**
> **Rama:** `feature/hu-6.1-release-workflow`
> **Linear:** [PIT-118](https://linear.app/pitcherdev/issue/PIT-118)

## 📋 Tabla de Contenidos

1. [Resumen](#resumen)
2. [Arquitectura](#arquitectura)
3. [Configuración de Release Please](#configuración-de-release-please)
4. [Jobs del Workflow](#jobs-del-workflow)
5. [Empaquetado de Artefactos](#empaquetado-de-artefactos)
6. [Archivos Creados](#archivos-creados)
7. [Cómo Funciona](#cómo-funciona)

---

## Resumen

| Aspecto | Detalle |
|---------|---------|
| **Ticket** | PIT-118 — [HU-6.1] Workflow de Release Automatizado |
| **Paradigma** | Google Release Please (reemplaza push manual de tags) |
| **Trigger** | Push a la rama `main` |
| **Artefactos** | `.deb` + `.AppImage` (Linux x86_64) |
| **Checksums** | SHA-256 para cada artefacto |
| **CHANGELOG** | Generado automáticamente desde commits convencionales |

---

## Arquitectura

```
Push a main
    │
    ▼
┌─────────────────────────────┐
│  Job 1: Release Please      │
│  googleapis/release-please   │
│  - Crea/actualiza PR         │
│  - Al mergear: Tag + Release │
│  - CHANGELOG automático      │
└──────────┬──────────────────┘
           │ releases_created == true
           ▼
┌─────────────────────────────┐
│  Job 2: Build & Upload       │
│  - Flutter build linux       │
│  - Bundle del backend        │
│  - Paquete .deb              │
│  - Paquete .AppImage         │
│  - Checksums SHA-256         │
│  - Subida a GitHub Release   │
└─────────────────────────────┘
```

---

## Configuración de Release Please

### Componentes del Monorepo

| Componente | Ruta | Tipo | Nombre del Paquete |
|------------|------|------|--------------------|
| Backend | `src/server` | python | softarchitect-ai-server |
| Frontend | `src/client` | dart | softarchitect_ai |

### Secciones del CHANGELOG

Los tipos de commits convencionales se mapean a secciones del CHANGELOG:

| Tipo de Commit | Sección CHANGELOG | Visible |
|----------------|-------------------|---------|
| `feat:` | Features | Sí |
| `fix:` | Bug Fixes | Sí |
| `perf:` | Performance Improvements | Sí |
| `security:` | Security | Sí |
| `refactor:` | Code Refactoring | Sí |
| `docs:` | Documentation | Sí |
| `test:` | Tests | Sí |
| `ci:` | CI/CD | Sí |
| `chore:` | Miscellaneous | Oculto |

### Versiones Iniciales

Ambos componentes comienzan en `0.1.0` en `.release-please-manifest.json`.

---

## Jobs del Workflow

### Job 1: Release Please

- **Action:** `googleapis/release-please-action@v4`
- **Config:** `release-please-config.json` + `.release-please-manifest.json`
- **Outputs:** `releases_created`, `tag_name` y `version` por componente
- **Comportamiento:**
  - En cada push a `main`: crea o actualiza un PR de release
  - Al mergear el PR de release: crea GitHub Release + tag + CHANGELOG

### Job 2: Build & Upload Artifacts

- **Condición:** Solo se ejecuta cuando `releases_created == 'true'`
- **Dependencias:** `needs: release-please`
- **Steps:**
  1. Checkout del código
  2. Setup Flutter 3.38.0
  3. Setup Python 3.12
  4. Instalación de herramientas de empaquetado Linux (dpkg-dev, fakeroot, cmake, etc.)
  5. Build de Flutter Linux desktop (modo release)
  6. Preparación del bundle del backend (pip install a dist/)
  7. Empaquetado `.deb` (desktop + servidor completo)
  8. Empaquetado `.AppImage` (formato portable)
  9. Generación de checksums SHA-256
  10. Subida de todos los artefactos a GitHub Release vía `gh release upload`

---

## Empaquetado de Artefactos

### Estructura del paquete .deb

```
/opt/softarchitect-ai/
├── client/          # Bundle de Flutter desktop
└── server/          # Backend Python
/usr/bin/softarchitect-ai    # Script de arranque
/usr/share/applications/     # Entrada .desktop
```

### Estructura del .AppImage

```
AppDir/
├── AppRun           # Punto de entrada
├── softarchitect-ai.desktop
├── softarchitect-ai.png
└── usr/
    ├── bin/         # Bundle de Flutter
    └── share/       # Backend
```

### Checksums

Cada artefacto obtiene un archivo `.sha256` acompañante con el hash SHA-256, subido junto al artefacto en la GitHub Release.

---

## Archivos Creados

| Archivo | Descripción |
|---------|-------------|
| `release-please-config.json` | Configuración del monorepo (backend python + frontend dart) |
| `.release-please-manifest.json` | Versiones iniciales (0.1.0) |
| `.github/workflows/release.yaml` | Workflow completo de release (2 jobs) |

---

## Cómo Funciona

### Flujo del Desarrollador

```bash
# 1. Trabajar en rama feature con commits convencionales
git commit -m "feat(backend): add new RAG query endpoint"
git commit -m "fix(frontend): resolve chat scroll issue"

# 2. Mergear a develop, luego a main
# 3. Release Please automáticamente:
#    - Abre un PR titulado "chore: release X.Y.Z"
#    - El PR incluye CHANGELOG auto-generado
# 4. Revisar y mergear el PR de release
# 5. Release Please crea:
#    - Tag de Git (ej. src/client-v0.2.0)
#    - GitHub Release con CHANGELOG
# 6. Job 2 automáticamente build y sube:
#    - softarchitect-ai_0.2.0.deb
#    - softarchitect-ai-0.2.0-x86_64.AppImage
#    - Checksums SHA-256 para ambos
```
