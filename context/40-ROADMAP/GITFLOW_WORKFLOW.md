
# 🌿 Estrategia de Ramas y Flujo de Trabajo (GitFlow)

> **Estándar:** GitFlow Simplificado + Conventional Commits.
> **Objetivo:** Mantener `main` siempre desplegable y `develop` como punto de integración estable.

---

## 1. Mapa de Ramas (Branch Topology)

### 🛡️ Ramas Permanentes (Protected)

| Rama | Propósito | Reglas de Escritura | Despliegue |
| :--- | :--- | :--- | :--- |
| **`main`** | **Producción / Stable**. Contiene la última versión oficial lanzada (Tags). | 🔒 **READ-ONLY**. Solo acepta Merges desde `release/*` o `hotfix/*`. | Producción (Release) |
| **`develop`** | **Integración / Next**. Contiene el código de la próxima versión en desarrollo. | 🔒 **READ-ONLY**. Solo acepta Pull Requests (PRs). | Entorno de Pruebas (Staging) |

### 🛠️ Ramas de Trabajo (Efímeras)

Todas nacen de `develop` y mueren al fusionarse (Squash & Merge).

* **`feature/nombre-feature`:** Desarrollo de nueva funcionalidad.
    * *Ejemplo:* `feature/rag-engine-setup`, `feature/flutter-ui-login`.
* **`fix/nombre-bug`:** Corrección de errores detectados en desarrollo.
    * *Ejemplo:* `fix/docker-compose-port-conflict`.
* **`docs/nombre-doc`:** Cambios exclusivos en documentación (`context/`, `doc/`).
    * *Ejemplo:* `docs/update-readme`, `docs/add-tech-pack-flutter`.
* **`refactor/nombre`:** Mejoras de código sin cambio funcional.
* **`chore/nombre`:** Tareas de mantenimiento (actualizar deps, configuración CI).

---

## 2. El Ciclo de Vida de una Tarea (Workflow)

### Paso 1: Crear la Rama
Siempre desde `develop` actualizado:
```bash
git checkout develop
git pull origin develop
git checkout -b feature/mi-nueva-feature

```

### Paso 2: Desarrollo y Commits

Usa **Conventional Commits** para que el historial sea semántico (Nota: El commit usa `feat`, la rama usa `feature`):

```bash
git commit -m "feat(api): add langchain base configuration"
git commit -m "test(api): add unit tests for prompt sanitizer"

```

### Paso 3: Pull Request (PR)

1. Sube la rama: `git push origin feature/mi-nueva-feature`.
2. Abre PR hacia **`develop`** (Nunca a `main`).
3. **Revisión:** El CI debe pasar (Linter + Tests). Otro humano (o el Agente) debe aprobar.

### Paso 4: Fusión

Al aprobar, se hace **Squash and Merge** para dejar un solo commit limpio en `develop`.

---

## 3. Releases y Hotfixes

### 🚀 Crear una Release (`release/vX.Y.Z`)

Cuando `develop` tiene suficientes features para una versión:

1. Crear rama `release/v0.1.0` desde `develop`.
2. Congelar código (Code Freeze). Solo se admiten bugfixes menores.
3. Actualizar `version` en `pubspec.yaml` y `pyproject.toml`.
4. Merge a **`main`** (con Tag `v0.1.0`) y a **`develop`**.

### 🔥 Hotfix (`hotfix/vX.Y.Z`)

Si hay un error crítico en `main`:

1. Crear rama desde `main`.
2. Corregir el bug.
3. Merge a **`main`** (con Tag incremental) y a **`develop`**.


