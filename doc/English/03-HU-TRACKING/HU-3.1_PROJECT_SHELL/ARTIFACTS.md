# 📦 Artefactos HU-3.1: Project Shell

> **Files a generar durante el desarrollo**
> **Última Actualización:** 03/02/2026

---

## 📋 Manifest de Artefactos

### Frontend - Screens

```
✓ src/client/presentation/screens/project_shell_screen.dart
  └─ Main screen widget
  └─ Status: PENDIENTE
  └─ Size Est: ~500 líneas
```

### Frontend - Widgets

```
✓ src/client/presentation/widgets/directory_tree_view.dart
  └─ Tree view component
  └─ Status: PENDIENTE
  └─ Size Est: ~300 líneas

✓ src/client/presentation/widgets/document_preview_panel.dart
  └─ Markdown preview
  └─ Status: PENDIENTE
  └─ Size Est: ~250 líneas

✓ src/client/presentation/widgets/project_creation_dialog.dart
  └─ Project creation form
  └─ Status: PENDIENTE
  └─ Size Est: ~200 líneas
```

### Domain - Models

```
✓ src/client/domain/models/project.dart
  └─ Project entity
  └─ Status: PENDIENTE
  └─ Size Est: ~100 líneas

✓ src/client/domain/models/document_item.dart
  └─ Document model
  └─ Status: PENDIENTE
  └─ Size Est: ~80 líneas
```

### Data - Repositories

```
✓ src/client/data/repositories/project_repository.dart
  └─ Project data access
  └─ Status: PENDIENTE
  └─ Size Est: ~200 líneas

✓ src/client/data/providers/project_provider.dart
  └─ Riverpod providers
  └─ Status: PENDIENTE
  └─ Size Est: ~150 líneas
```

### Tests

```
✓ test/presentation/screens/project_shell_screen_test.dart
  └─ Screen tests
  └─ Status: PENDIENTE
  └─ Test Cases: 5+

✓ test/domain/models/project_test.dart
  └─ Model tests
  └─ Status: PENDIENTE
  └─ Test Cases: 8+

✓ test/data/repositories/project_repository_test.dart
  └─ Repository tests
  └─ Status: PENDIENTE
  └─ Test Cases: 6+
```

### Documentation

```
✓ doc/HU-3.1/IMPLEMENTATION_NOTES.md
  └─ Notas técnicas
  └─ Status: PENDIENTE
  └─ Contains: Architecture decisions, gotchas

✓ doc/HU-3.1/API_CONTRACTS.md
  └─ Contrato con HU-3.2 y HU-3.3
  └─ Status: PENDIENTE
  └─ Contains: Interface definitions
```

---

## 🎨 Componentes UI a Create

### ProjectShellScreen (Main Container)
- **Estructura:** Column con 3 paneles
- **Paneles:**
  - Top: MenuBar (File, Edit, View, Help)
  - Left: Sidebar (DirectoryTreeView + ChatWidget)
  - Right: MainContent (DocumentPreviewPanel)

### DirectoryTreeView
- **Features:** Expandible, seleccionable, drag-drop ready
- **Estructura:** Árbol de 5 niveles (context/10-20-30-35-40/)
- **Acciones:** Expand, Collapse, Select, ContextMenu

### DocumentPreviewPanel
- **Features:** Markdown rendering, syntax highlighting, copy button
- **Librerías:** `flutter_markdown`, `flutter_highlighter`
- **Responsive:** Mantiene proporción con window resize

### ProjectCreationDialog
- **Validación:** Names únicos, caracteres válidos
- **Campos:** Name project, description, ubicación (si aplica)
- **Acciones:** Create, Cancel

---

## 📊 Dependencias Externas

### Flutter Packages

```yaml
flutter_markdown: ^0.6.0
flutter_highlighter: ^0.1.0
riverpod: ^2.4.0
riverpod_generator: ^2.3.0
freezed_annotation: ^2.4.0
```

### Architecture

```
clean_architecture/
├─ Domain: Modelos puros (no dependen de Flutter)
├─ Data: Repositorios, DTOs
└─ Presentation: Riverpod providers, Widgets
```

---

## 🧪 Estrategia de Testing

### Unit Tests (Domain + Data)
- [ ] Models serialization/deserialization
- [ ] Repository CRUD operations
- [ ] Provider state management

### Widget Tests (Presentation)
- [ ] DirectoryTreeView rendering
- [ ] DocumentPreviewPanel updates
- [ ] ProjectCreationDialog validation

### Integration Tests (E2E)
- [ ] Create project → navigate → preview doc
- [ ] Expand/collapse tree
- [ ] Update preview on selection

**Target Coverage:** >85%

---

## ✨ Características a Implementar

```
🎨 UI FEATURES
├─ Pantalla principal IDE-like
├─ Árbol de directorios interactivo
├─ Preview Markdown en tiempo real
├─ Menú contextual en archivos
├─ Indicadores visuales de estado
└─ Dark mode (DESIGN_SYSTEM.md)

🔧 TECHNICAL FEATURES
├─ State management (Riverpod)
├─ Hot reload compatible
├─ Memory efficient
├─ Responsive design
└─ Accesibilidad (WCAG AA)

🔗 INTEGRATION FEATURES
├─ Sincronización con FileSystemService (HU-3.2)
├─ API contracts con Chat (HU-3.3)
├─ Real-time updates
└─ Offline operation
```

---

## 📈 Checklist de Entrega

### Code
- [ ] Código sin linter warnings
- [ ] Documentación completada
- [ ] Tests verdes
- [ ] Code review aprobada

### Documentation
- [ ] README.md actualizado
- [ ] Javadoc/DartDoc completado
- [ ] API contracts documentados
- [ ] Guía de uso

### Testing
- [ ] Unit tests >85% cobertura
- [ ] Widget tests ejecutados
- [ ] Integration tests pasados
- [ ] Performance benchmarked

### Integración
- [ ] Integración con HU-3.2 verificada
- [ ] Integración con HU-3.3 verificada
- [ ] No hay regressions
- [ ] PR cerrada en develop

---

## 📞 Revisión de Artefactos

**Reviewer 1:** [Tech Lead - Flutter]
**Reviewer 2:** [Backend Lead - APIs]
**QA:** [QA Lead]

**Criterios de Aceptación:**
- ✅ 100% de funcionalidades implementadas
- ✅ Tests pasan
- ✅ Documentación completa
- ✅ Performance <100ms
- ✅ 2+ approvals en PR

---

**ARTIFACTS: HU-3.1**
**Total Líneas Esperadas:** ~2,080 líneas de código
**Total Files:** 11 files
**Actualizado:** 03/02/2026
