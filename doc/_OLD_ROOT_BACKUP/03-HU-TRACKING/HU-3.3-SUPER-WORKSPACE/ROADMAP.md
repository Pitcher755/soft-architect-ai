# 🚀 HU-3.3 SUPER WORKSPACE - ROADMAP MAESTRO

> **Fecha de Creación:** 06/02/2026 15:45 CET
> **Estado:** ✅ PLANIFICACIÓN COMPLETA
> **Estimación:** XXL (21 Story Points)
> **Branch:** `feature/chat-sequential-docs`

---

## 📋 Executive Summary

La **HU-3.3 Super-Vitaminada** expande el alcance original para incluir el **Workspace IDE completo** (3 columnas estilo VS Code), integrando:

- **Explorador de Archivos** (Columna Izquierda)
- **Chat Secuencial** (Columna Central)
- **Preview Markdown** (Columna Derecha)

**Objetivo:** Crear una experiencia IDE completa donde el usuario puede generar documentos secuencialmente, verlos en tiempo real, y navegar por la estructura del proyecto.

---

## 🎯 Alcance de la HU-3.3 Expandida

### ✅ **Pantallas y Componentes del Mapa de Widgets**

| Pantalla | Archivo HTML Ref | Estado | Inclusión en HU-3.3 |
|----------|------------------|--------|---------------------|
| Dashboard | `dashboard.html` | ✅ Ya implementado | HU-3.1 (previo) |
| Modal Crear Proyecto | `create_project_modal.html` | ✅ Ya implementado | HU-3.1 (previo) |
| **Workspace IDE** | `workspace.html` | ⚠️ **NUEVO** | **HU-3.3 SUPER** |
| └─ Explorador Archivos | (Columna Izquierda) | ⚠️ **NUEVO** | **HU-3.3 SUPER** |
| └─ Chat Secuencial | (Columna Central) | ✅ Widgets implementados | **HU-3.3 SUPER** |
| └─ Preview Markdown | (Columna Derecha) | ⚠️ **NUEVO** | **HU-3.3 SUPER** |
| Chat Components | `chat_components.html` | ✅ Widgets implementados | HU-3.3 (original) |

---

## 🏗️ Arquitectura: 3 Columnas Resizables

```
┌────────────────────────────────────────────────────────────────────┐
│                    PROJECT WORKSPACE SCREEN                         │
├────────────────────────────────────────────────────────────────────┤
│  AppBar: Proyecto X | Doc 3/25 | [Progress: ████░░░░░░ 12%]       │
├─────────────┬──────────────────────────┬─────────────────────────────┤
│             │                          │                             │
│  EXPLORADOR │      CHAT SECUENCIAL     │    PREVIEW MARKDOWN         │
│  ARCHIVOS   │                          │                             │
│             │                          │                             │
│ 📁 context/ │  💬 User: "Necesito     │ # Documento de Requisitos   │
│   📁 10-... │      requisitos"         │                             │
│   📁 20-... │  🤖 AI: "Generando..."  │ ## 1. Introducción          │
│   📄 REQ.md │  📋 Propuesta:          │ Este documento describe...  │
│   📄 VIS.md │     [Validar] [Refinar] │                             │
│             │                          │ ## 2. Requisitos Funcionales│
│ 200px       │  [Input aquí...]  [Send]│ - RF-001: El usuario...     │
│             │                          │                             │
│ Resizable → │    ← Flex: 1 →          │  ← Resizable →              │
│             │                          │                             │
└─────────────┴──────────────────────────┴─────────────────────────────┘
```

---

## 📦 Estructura de Carpetas (Clean Architecture)

```
src/client/lib/
├── features/
│   ├── project_shell/              # HU-3.3 SUPER: Workspace Shell
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── workspace_state.dart
│   │   │   └── repositories/
│   │   │       └── workspace_repository.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── workspace_state_dto.dart
│   │   │   └── repositories/
│   │   │       └── workspace_repository_impl.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── project_workspace_screen.dart  # ✨ NUEVO
│   │       ├── widgets/
│   │       │   ├── file_system_tree_widget.dart   # ✨ NUEVO
│   │       │   ├── markdown_preview_widget.dart   # ✨ NUEVO
│   │       │   └── resizable_pane.dart            # ✨ NUEVO
│   │       └── notifiers/
│   │           └── workspace_notifier.dart        # ✨ NUEVO
│   │
│   ├── chat/                       # HU-3.3 ORIGINAL: Chat Secuencial
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── chat_message.dart
│   │   │   │   └── document_proposal.dart
│   │   │   └── use_cases/
│   │   │       ├── send_message_use_case.dart
│   │   │       └── validate_proposal_use_case.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── chat_message_dto.dart
│   │   │   └── repositories/
│   │   │       └── chat_repository_impl.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── sequential_chat_screen.dart    # ✨ NUEVO (integrado)
│   │       ├── widgets/
│   │       │   ├── message_bubble_widget.dart     # ✅ HECHO
│   │       │   ├── proposal_card_widget.dart      # ✅ HECHO
│   │       │   └── streaming_indicator_widget.dart# ✅ HECHO
│   │       └── notifiers/
│   │           └── chat_notifier.dart             # ✅ HECHO
│   │
│   └── file_system/                # HU-3.2: Sistema de Archivos
│       └── data/
│           └── services/
│               └── file_system_service.dart       # ✅ HECHO
│
└── core/
    ├── router/
    │   └── app_router.dart                        # ✏️ Actualizar rutas
    └── theme/
        └── app_colors.dart                        # Tema GitHub Dark
```

---

## 🎯 Workflow Maestro: Implementación TDD (6 Fases)

### **FASE 1: Workspace Shell (El Contenedor Principal)**

**Objetivo:** Crear `ProjectWorkspaceScreen` con 3 columnas vacías.

#### 1.1 Tests (RED)
```bash
# Archivo: tests/features/project_shell/presentation/screens/project_workspace_screen_test.dart
- test_renders_three_columns_layout()
- test_appbar_shows_project_name()
- test_appbar_shows_progress_indicator()
```

#### 1.2 Implementación (GREEN)
```dart
// Archivo: lib/features/project_shell/presentation/screens/project_workspace_screen.dart
class ProjectWorkspaceScreen extends ConsumerWidget {
  final String projectPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proyecto X | Doc 3/25'),
        bottom: PreferredSize(
          child: LinearProgressIndicator(value: 0.12),
        ),
      ),
      body: Row(
        children: [
          Container(width: 200, color: Colors.blue),  // Explorador
          Expanded(child: Container(color: Colors.green)), // Chat
          Container(width: 400, color: Colors.orange),  // Preview
        ],
      ),
    );
  }
}
```

#### 1.3 Refactor (BLUE)
- Extraer AppBar a `WorkspaceAppBar` widget
- Aplicar tema GitHub Dark
- Agregar tests para responsive layout

**Entregable:** `ProjectWorkspaceScreen` renderiza 3 columnas de colores temporales.

---

### **FASE 2: Explorador de Archivos (Columna Izquierda)**

**Objetivo:** Implementar `FileSystemTreeWidget` conectado a `FileSystemService`.

#### 2.1 Tests (RED)
```bash
# Archivo: tests/features/project_shell/presentation/widgets/file_system_tree_widget_test.dart
- test_renders_root_folders()
- test_expands_folder_on_click()
- test_highlights_selected_file()
- test_shows_file_icons_by_type()
```

#### 2.2 Implementación (GREEN)
```dart
// Archivo: lib/features/project_shell/presentation/widgets/file_system_tree_widget.dart
class FileSystemTreeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileTree = ref.watch(fileSystemTreeProvider);

    return ListView.builder(
      itemCount: fileTree.nodes.length,
      itemBuilder: (context, index) {
        final node = fileTree.nodes[index];
        return TreeTile(
          node: node,
          onTap: () => ref.read(fileSystemTreeProvider.notifier).selectFile(node.path),
        );
      },
    );
  }
}
```

#### 2.3 Integración
- Conectar con `FileSystemService` (HU-3.2)
- Leer estructura de `context/` del proyecto activo
- Iconos por tipo de archivo (.md, .json, carpetas)

**Entregable:** Árbol navegable que muestra estructura real del proyecto.

---

### **FASE 3: Preview Markdown (Columna Derecha)**

**Objetivo:** Implementar `MarkdownPreviewWidget` con estilos GitHub Dark.

#### 3.1 Tests (RED)
```bash
# Archivo: tests/features/project_shell/presentation/widgets/markdown_preview_widget_test.dart
- test_renders_markdown_content()
- test_shows_placeholder_when_no_file()
- test_applies_github_dark_theme()
- test_scrolls_to_section_on_click()
```

#### 3.2 Implementación (GREEN)
```dart
// Archivo: lib/features/project_shell/presentation/widgets/markdown_preview_widget.dart
class MarkdownPreviewWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFile = ref.watch(selectedFileProvider);

    if (selectedFile == null) {
      return Center(child: Text('Select a file to preview...'));
    }

    return Markdown(
      data: selectedFile.content,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        h1: TextStyle(color: AppColors.textPrimary, fontSize: 28),
        code: TextStyle(backgroundColor: AppColors.codeBg),
      ),
    );
  }
}
```

#### 3.3 Features
- Syntax highlighting para bloques de código
- Links internos navegables
- Auto-scroll al encabezado clickeado en el explorador

**Entregable:** Preview funcional con estilos GitHub Dark.

---

### **FASE 4: Chat Secuencial (Columna Central - Integración)**

**Objetivo:** Integrar `SequentialChatScreen` con widgets ya creados.

#### 4.1 Tests (RED)
```bash
# Archivo: tests/features/chat/presentation/screens/sequential_chat_screen_test.dart
- test_renders_chat_history()
- test_shows_proposal_card_on_ai_response()
- test_validates_and_saves_proposal()
- test_prevents_skip_without_validation()
- test_streaming_indicator_appears_during_generation()
```

#### 4.2 Implementación (GREEN)
```dart
// Archivo: lib/features/chat/presentation/screens/sequential_chat_screen.dart
class SequentialChatScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatNotifierProvider);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: chatState.messages.length,
            itemBuilder: (context, index) {
              final message = chatState.messages[index];
              return MessageBubbleWidget(message: message);
            },
          ),
        ),
        if (chatState.currentProposal != null)
          ProposalCardWidget(
            proposal: chatState.currentProposal!,
            onValidate: () => _handleValidate(ref),
            onRefine: () => _handleRefine(ref),
          ),
        if (chatState.isStreaming)
          StreamingIndicatorWidget(
            progress: chatState.streamProgress,
            documentIndex: chatState.currentDocIndex,
            totalDocuments: 25,
          ),
        ChatInputField(onSend: (text) => _handleSend(ref, text)),
      ],
    );
  }
}
```

#### 4.3 Flujo de Validación
```dart
void _handleValidate(WidgetRef ref) async {
  final chatNotifier = ref.read(chatNotifierProvider.notifier);
  final fileService = ref.read(fileSystemServiceProvider);

  // 1. Guardar propuesta en disco
  await fileService.saveDocument(
    path: chatNotifier.getCurrentDocumentPath(),
    content: chatNotifier.currentProposal!.content,
  );

  // 2. Actualizar árbol de archivos (columna izquierda)
  ref.read(fileSystemTreeProvider.notifier).refresh();

  // 3. Mostrar en preview (columna derecha)
  ref.read(selectedFileProvider.notifier).selectFile(path);

  // 4. Avanzar al siguiente documento
  chatNotifier.advanceToNextDocument();
}
```

**Entregable:** Chat funcional con validación que actualiza las 3 columnas.

---

### **FASE 5: Resizable Panes (UX Enhancement)**

**Objetivo:** Hacer que las columnas sean redimensionables.

#### 5.1 Implementación
```dart
// Archivo: lib/features/project_shell/presentation/widgets/resizable_pane.dart
class ResizablePanes extends StatefulWidget {
  final Widget left;
  final Widget center;
  final Widget right;

  @override
  _ResizablePanesState createState() => _ResizablePanesState();
}

class _ResizablePanesState extends State<ResizablePanes> {
  double leftWidth = 200;
  double rightWidth = 400;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: leftWidth, child: widget.left),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() => leftWidth += details.delta.dx);
          },
          child: Container(width: 4, color: AppColors.borderDark),
        ),
        Expanded(child: widget.center),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() => rightWidth -= details.delta.dx);
          },
          child: Container(width: 4, color: AppColors.borderDark),
        ),
        SizedBox(width: rightWidth, child: widget.right),
      ],
    );
  }
}
```

**Entregable:** Columnas redimensionables con arrastre de bordes.

---

### **FASE 6: Integración E2E y Validación**

**Objetivo:** Validar el flujo completo de generación de documentos.

#### 6.1 Test E2E
```bash
# Archivo: integration_test/workspace_e2e_test.dart
- test_complete_document_generation_flow()
  1. Abrir proyecto
  2. Workspace se carga con 3 columnas
  3. Enviar mensaje al chat
  4. IA responde con propuesta
  5. Validar propuesta
  6. Archivo aparece en explorador
  7. Preview muestra contenido
  8. Chat avanza a siguiente documento
```

#### 6.2 Casos de Validación
- ✅ No se puede saltar documentos sin validar
- ✅ Propuestas rechazadas no se guardan
- ✅ Progress bar se actualiza al validar
- ✅ Árbol de archivos refleja cambios en tiempo real
- ✅ Preview sincroniza con selección del árbol

**Entregable:** Test E2E completo con cobertura >80%.

---

## 📊 Mapeo: Widgets HTML → Widgets Dart

| HTML Component (mapa_widgets.md) | Dart Widget | Ubicación | Estado |
|-----------------------------------|-------------|-----------|--------|
| Sidebar (Explorador) | `FileSystemTreeWidget` | `project_shell/widgets/` | ⚠️ Nuevo |
| Tree Node (Carpeta) | `TreeTile` | `project_shell/widgets/` | ⚠️ Nuevo |
| Preview Panel | `MarkdownPreviewWidget` | `project_shell/widgets/` | ⚠️ Nuevo |
| Chat Message (User) | `MessageBubbleWidget` | `chat/widgets/` | ✅ Hecho |
| Chat Message (AI) | `MessageBubbleWidget` | `chat/widgets/` | ✅ Hecho |
| Proposal Card | `ProposalCardWidget` | `chat/widgets/` | ✅ Hecho |
| Streaming Indicator | `StreamingIndicatorWidget` | `chat/widgets/` | ✅ Hecho |
| Progress Bar (AppBar) | `LinearProgressIndicator` | Built-in | ⚠️ Integrar |
| Resizable Divider | `ResizablePanes` | `project_shell/widgets/` | ⚠️ Nuevo |

---

## 🧪 Cobertura de Tests Requerida

| Categoría | Objetivo | Archivos |
|-----------|----------|----------|
| **Unit Tests** | >80% | `*_test.dart` |
| **Widget Tests** | 100% componentes críticos | `*_widget_test.dart` |
| **Integration Tests** | 100% flujo E2E | `integration_test/*.dart` |
| **Total Coverage** | >80% global | Validado por CI/CD |

### Tests Críticos (Obligatorios)
```
✅ project_workspace_screen_test.dart (10 tests)
✅ file_system_tree_widget_test.dart (8 tests)
✅ markdown_preview_widget_test.dart (6 tests)
✅ sequential_chat_screen_test.dart (12 tests)
✅ workspace_notifier_test.dart (15 tests)
✅ chat_notifier_test.dart (20 tests) [Ya existe]
✅ workspace_e2e_test.dart (5 scenarios)
```

---

## 📅 Cronograma de Implementación

### Sprint Breakdown (Estimación 21 SP)

| Fase | Tarea | SP | Duración Estimada | Dependencias |
|------|-------|----|--------------------|--------------|
| **FASE 1** | Workspace Shell | 2 | 1 día | Ninguna |
| **FASE 2** | Explorador Archivos | 3 | 2 días | HU-3.2 |
| **FASE 3** | Preview Markdown | 3 | 2 días | FASE 1 |
| **FASE 4** | Chat Secuencial | 8 | 4 días | FASE 1, 2, 3 |
| **FASE 5** | Resizable Panes | 2 | 1 día | FASE 1 |
| **FASE 6** | E2E Tests | 3 | 2 días | FASE 1-5 |
| **TOTAL** | | **21** | **12 días** | |

---

## 🚨 Riesgos y Mitigación

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| **Complejidad del árbol de archivos** | Alta | Alto | Usar librería `flutter_treeview` |
| **Performance con 25 documentos** | Media | Medio | Virtualización de listas |
| **Sincronización 3 columnas** | Media | Alto | StateNotifier global con Riverpod |
| **Streaming SSE bloqueante** | Baja | Alto | Async/await correcto, tests extensivos |
| **Redimensionamiento buggy** | Media | Bajo | Constraints mínimos/máximos |

---

## 🎯 Definition of Done (HU-3.3 SUPER)

### Funcionalidad
- [ ] Workspace carga al abrir proyecto
- [ ] 3 columnas visibles y funcionales
- [ ] Explorador muestra estructura real
- [ ] Preview renderiza Markdown correctamente
- [ ] Chat genera propuestas secuencialmente
- [ ] Validación guarda y actualiza 3 columnas
- [ ] Progress bar refleja avance (X/25)
- [ ] Columnas son redimensionables

### Calidad
- [ ] >80% cobertura de tests
- [ ] 0 errores en `flutter analyze`
- [ ] 0 warnings críticos
- [ ] Pre-commit hooks pasan
- [ ] Test E2E completo ejecuta correctamente

### Documentación
- [ ] README.md en `doc/03-HU-TRACKING/HU-3.3-SUPER-WORKSPACE/`
- [ ] PROGRESS.md actualizado (6 fases)
- [ ] ARTIFACTS.md con todos los archivos creados
- [ ] Comentarios en código (DartDoc)
- [ ] Diagramas de flujo en documentación

### Git
- [ ] Commits atómicos y descriptivos
- [ ] Branch `feature/chat-sequential-docs`
- [ ] Sin conflictos con `develop`
- [ ] PR abierto con descripción completa

---

## 📚 Documentos de Referencia

### Internos
- [`doc/03-HU-TRACKING/HU-3.3-SUPER-WORKSPACE/README.md`](doc/03-HU-TRACKING/HU-3.3-SUPER-WORKSPACE/README.md)
- [`doc/03-HU-TRACKING/HU-3.3-SUPER-WORKSPACE/PROGRESS.md`](doc/03-HU-TRACKING/HU-3.3-SUPER-WORKSPACE/PROGRESS.md)
- [`context/40-ROADMAP/mapa_widgets.md`](context/40-ROADMAP/mapa_widgets.md)
- [`context/40-ROADMAP/USER_STORIES_MASTER.es.json`](context/40-ROADMAP/USER_STORIES_MASTER.es.json)

### Externos
- [Flutter Clean Architecture](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)
- [Riverpod 2.0 Docs](https://riverpod.dev/docs/getting_started)
- [flutter_markdown Package](https://pub.dev/packages/flutter_markdown)

---

## ✅ Checklist de Inicio

Antes de empezar a codificar:

- [x] Leer este roadmap completo
- [x] Revisar `mapa_widgets.md` (HTML de referencia)
- [x] Confirmar HU-3.1 y HU-3.2 completadas
- [ ] Crear branch `feature/chat-sequential-docs` (si no existe)
- [ ] Verificar que `flutter analyze` pasa actualmente
- [ ] Confirmar que todos los tests previos pasan (289/289)
- [ ] Instalar dependencias adicionales:
  ```bash
  flutter pub add flutter_markdown
  flutter pub add flutter_treeview
  flutter pub add multi_split_view  # Para resize panes
  ```

---

## 🎉 Resultado Final Esperado

Al completar la HU-3.3 SUPER, el usuario podrá:

1. ✅ **Abrir un proyecto** desde el Dashboard
2. ✅ **Ver el Workspace IDE** con 3 columnas estilo VS Code
3. ✅ **Navegar por archivos** en el explorador lateral
4. ✅ **Chatear con la IA** para generar documentos secuencialmente
5. ✅ **Validar propuestas** que se guardan automáticamente
6. ✅ **Ver el preview** del documento validado en tiempo real
7. ✅ **Seguir el progreso** con la barra de avance (Doc X/25)
8. ✅ **Redimensionar columnas** según preferencias

**Status Final:** 🚀 **WORKSPACE IDE FULLY FUNCTIONAL**

---

**Última Actualización:** 06/02/2026 15:45 CET
**Autor:** ArchitectZero
**Revisión:** v1.0 - Roadmap Completo
