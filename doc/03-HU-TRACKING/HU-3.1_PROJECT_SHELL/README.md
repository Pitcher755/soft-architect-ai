# 📋 HU-3.1: Project Shell (IDE-like UI for Project Management)

> **Historia de Usuario:** Interfaz IDE-like para crear y gestionar proyectos
> **Tipo:** Frontend (Flutter)
> **Prioridad:** 🔴 CRITICAL
> **Estimación:** XL (13 pts)
> **Rama:** `feature/ui-project-shell`
> **Estado:** 📋 PENDIENTE

---

## 📖 Tabla de Contenidos

- [Descripción](#descripción)
- [Criterios de Aceptación](#criterios-de-aceptación)
- [Tareas Técnicas](#tareas-técnicas)
- [Dependencias](#dependencias)
- [Progreso](#progreso)
- [Artefactos](#artefactos)

---

## 📝 Descripción

### User Story

```
Como Usuario,
Quiero una interfaz IDE-like para crear y gestionar proyectos,
Con navegación lateral y preview de documentos,
Para poder organizar mis trabajos y acceder fácilmente a los documentos generados.
```

### Alcance

Implementar la **pantalla principal del proyecto** con:

- 🎨 Vista IDE-like (sidebar + editor panel + preview panel)
- 📂 Árbol de directorios expandible/colapable
- 📄 Preview de Markdown en tiempo real
- ⚙️ Menú de opciones (Nuevo Proyecto, Abrir, Guardar, Exportar)
- 📊 Indicadores visuales de estado
- 🔄 Gestor de estado con Riverpod

---

## ✅ Criterios de Aceptación

| # | Criterio | Prioridad | Status |
|---|----------|-----------|--------|
| 1 | ✅ Pantalla de inicio con opción "Crear Proyecto" y listado de recientes | Alta | ⏳ |
| 2 | ✅ Vista de árbol de directorios con estructura auto-creada (context/10-20-30-35-40/) | Alta | ⏳ |
| 3 | ✅ Panel lateral con navegación entre documentos y chatbot | Alta | ⏳ |
| 4 | ✅ Preview de Markdown en tiempo real con sintaxis destacada | Media | ⏳ |
| 5 | ✅ Barra de menú con opciones: Nuevo, Abrir, Guardar, Exportar | Media | ⏳ |
| 6 | ✅ Interfaz responsive para redimensionamiento de ventana | Media | ⏳ |
| 7 | ✅ Indicador visual de estado de generación (spinner, progreso) | Media | ⏳ |
| 8 | ❌ No permitir crear proyectos con nombres duplicados o caracteres inválidos | Alta | ⏳ |

---

## 🛠️ Tareas Técnicas

| # | Tarea | Complejidad | Story Points | Status |
|---|-------|-------------|--------------|--------|
| 1 | Crear `ProjectShell` widget (contenedor principal) | M | 2 | ⏳ |
| 2 | Implementar `DirectoryTreeView` con expansión/colapso | M | 2 | ⏳ |
| 3 | Crear `DocumentPreviewPanel` con soporte Markdown | M | 2 | ⏳ |
| 4 | Implementar `ProjectCreationDialog` con validación | S | 1 | ⏳ |
| 5 | Gestionar estado de proyectos con Riverpod | M | 2 | ⏳ |
| 6 | Integrar tema del DESIGN_SYSTEM.md (Dark Mode) | S | 1 | ⏳ |
| 7 | Escribir tests de UI: 5+ casos de navegación | M | 2 | ⏳ |
| 8 | Integrar paquetes: `flutter_markdown`, `flutter_highlighter` | S | 1 | ⏳ |

---

## 🔗 Dependencias

### Bloqueantes
- ✅ `context/30-ARCHITECTURE/DESIGN_SYSTEM.md` (Tema visual)
- ✅ `context/30-ARCHITECTURE/UI_WIREFRAMES_AND_PROMPTS.md` (Diseño)

### Contribuye a
- 🔜 HU-3.3: Chat Sequential Docs (necesita la shell)

### Coordinadas con
- ↔️ HU-3.2: FileSystemService (backend de I/O)

---

## 📊 Progreso

Ver: [PROGRESS.md](PROGRESS.md)

```
Fase 0: Planificación ......................... [████████░░░░░░░░░░] 40%
Fase 1: Diseño UI ............................ [░░░░░░░░░░░░░░░░░░] 0%
Fase 2: Implementación ........................ [░░░░░░░░░░░░░░░░░░] 0%
Fase 3: Testing .............................. [░░░░░░░░░░░░░░░░░░] 0%
Fase 4: Integración .......................... [░░░░░░░░░░░░░░░░░░] 0%

Progreso Total: 8% (1.04 pts de 13)
```

---

## 📦 Artefactos

Ver: [ARTIFACTS.md](ARTIFACTS.md)

**Entregables esperados:**
- 📄 `src/client/presentation/screens/project_shell_screen.dart` (Main widget)
- 📄 `src/client/presentation/widgets/directory_tree_view.dart` (Tree widget)
- 📄 `src/client/presentation/widgets/document_preview_panel.dart` (Preview widget)
- 📄 `src/client/domain/models/project.dart` (Domain model)
- 📄 `src/client/data/repositories/project_repository.dart` (Repository)
- 📄 `test/presentation/screens/project_shell_test.dart` (Tests)
- 📄 `doc/HU-3.1/IMPLEMENTATION_NOTES.md` (Notas técnicas)

---

## 🎯 Definición de Listo (DoD)

- [ ] Código revisado por Tech Lead
- [ ] Tests pasan al 100% (>85% cobertura)
- [ ] Documentación completada
- [ ] PR mergeada a `develop`
- [ ] Integración con HU-3.2 verificada
- [ ] Funciona offline (sin conexión a servidor)

---

## 📞 Contacto y Preguntas

**Tech Lead:** @techLead
**Asignado a:** [Equipo Frontend]
**Última actualización:** 03/02/2026

---

**HU-3.1: PROJECT SHELL**
**Sprint 3: Project-First Sequential Document Generation**
**Rama:** `feature/ui-project-shell`
