# 🎮 Proyecto Shell Screen - User Guide

> **Estado:** ✅ Completado y Validado
> **Compilación:** 0 errors
> **Última Actualización:** 8 de febrero de 2026

---

## 📖 Tabla de Contenidos

- [Características Principales](#características-principales)
- [Cómo Usar](#cómo-usar)
- [Estructura de Datos](#estructura-de-datos)
- [Integración con Backend](#integración-con-backend)

---

## ✨ Características Principales

### 1️⃣ Árbol de Directorios (Archivos Column)

**Funcionalidades:**
- ✅ Expandir/Contraer carpetas
- ✅ Seleccionar archivos
- ✅ Visual feedback de selección
- ✅ Icono diferenciador (carpeta vs archivo)
- ✅ Profundidad de indentación automática

**Cómo usar:**
```
1. Haz clic en ► para expandir una carpeta
2. Haz clic en ▼ para contraerla
3. Haz clic en cualquier archivo/carpeta para seleccionar
4. El archivo seleccionado se resalta en azul
```

**Datos precargados:**
```
PROJECT-ALPHA/
├── context/
│   └── system-prompt.md
├── 10-CONTEXT/
│   ├── 01-vision.md
│   ├── 02-constraints.md
│   └── 03-arch-overview.md
├── 20-REQUIREMENTS/
└── 30-ARCHITECTURE/
```

---

### 2️⃣ Chat Panel (Columna Central)

**Componentes:**

#### Header con Progreso
```
┌──────────────────────────────────────┐
│ Generando Documento 8 de 25   [⏸ Pause]
├──────────────────────────────────────┤
│ ████████░░░░░░░░░░░░░░░░░░░░ 32%    │
└──────────────────────────────────────┘
```

**Características:**
- Progress bar animado
- Label dinámico con contador
- Botón Pause (placeholder)
- Colores por fase (ROOT, CONTEXT, REQUIREMENTS, etc.)

#### Mensajes de Chat
```
[SYSTEM] SoftArchitect AI Project initialized...  14:32
[USER] Generate the high-level architecture...    14:31
[ASSISTANT] I have analyzed the constraints...    14:30
```

**Características:**
- Mensajes del usuario alineados a la derecha (azul)
- Mensajes del asistente alineados a la izquierda (gris)
- Timestamps en cada mensaje
- Input field para escribir nuevos mensajes
- Botón Send

---

### 3️⃣ Markdown Preview (Columna Derecha)

**Contenido:**
```
# 3. Architecture Overview

This document outlines the high-level architecture...

## System Context
┌─────────────────────┐
│   API Gateway       │
└──────────┬──────────┘

## Scalability Considerations
- Horizontal Scaling: Stateless services...
- Database Sharding: User data sharded by tenant_id

## Performance Targets
| Metric | Target | Status |
|--------|--------|--------|
| API Latency | < 200ms | ✓ |
```

**Características:**
- Toolbar con Copy & Download botóns
- Header con nombre del archivo
- Contenido scrolleable
- Monospace font para código
- Links seleccionables

---

### 4️⃣ Columnas Redimensionables

**Cómo Usar:**

1. **Pasar mouse sobre el borde entre columnas**
   - El cursor cambia a ↔ (resize)
   - El borde se ilumina en azul

2. **Draggear el borde**
   - Mueve el borde a la izquierda/derecha
   - Los constraints se aplican automáticamente
   - El cambio es inmediato y suave

**Limites:**
- Archivos Column: 200px (mín) - 500px (máx)
- Preview Column: 300px (mín) - 600px (máx)

---

### 5️⃣ Columnas Ocultables (FABs)

**Ubicación:** Esquina inferior derecha

**Botones:**
```
┌─────┐
│ 📁 │  ← Toggle Files Column (Explorer)
├─────┤
│ 👁 │  ← Toggle Preview Column (Markdown)
└─────┘
```

**Cómo Usar:**

1. Haz clic en **📁 carpeta icon** para mostrar/ocultar el explorador
2. Haz clic en **👁 visibility icon** para mostrar/ocultar el preview
3. El estado persiste al toggle

---

## 🎯 Cómo Usar - Flujo Completo

### Escenario: Revisar Documentoos del Proyecto

```
1. Abre el app → Project Shell Screen
   │
   ├─ [IZQUIERDA] Files Explorer visible
   ├─ [CENTRO] Chat Panel con Progress
   └─ [DERECHA] Markdown Preview visible

2. Haz clic en un archivo .md en el explorador
   │
   ├─ El archivo se resalta en azul
   ├─ El preview muestra el contenido markdown
   └─ El árbol permanece visible

3. Expande más carpetas según necesites
   │
   ├─ Haz clic en ► para expandir 10-CONTEXT
   ├─ Haz clic en ► para expandir 20-REQUIREMENTS
   └─ Haz clic en cualquier .md para previewear

4. Cambia el ancho del explorador
   │
   ├─ Posiciona el mouse en el borde derecho del explorador
   ├─ Draggea a la izquierda para hacerlo más pequeño
   └─ Draggea a la derecha para hacerlo más grande

5. Oculta/Muestra columnas según necesites
   │
   ├─ Haz clic en 📁 para ocultar el explorador (ganas espacio para chat)
   ├─ Haz clic en 👁 para ocultar el preview (ganas espacio para chat)
   └─ Los botones hacen toggle on/off
```

---

## 📊 Estructura de Datos

### ArchivoNode (Árbol de Directorios)

```dart
class FileNode {
  final String id;              // Unique identifier (e.g., 'root', '10-context')
  final String name;            // Display name (e.g., 'PROJECT-ALPHA', '01-vision.md')
  final String path;            // File path (e.g., '/projects/PROJECT-ALPHA/...')
  final bool isDirectory;       // true = folder, false = file
  final List<FileNode> children; // Subfolders/files (empty if file)
}
```

**Ejemplo:**
```dart
FileNode(
  id: 'root',
  name: 'PROJECT-ALPHA',
  path: '/projects/PROJECT-ALPHA',
  isDirectory: true,
  children: [
    FileNode(
      id: 'vision',
      name: '01-vision.md',
      path: '/projects/PROJECT-ALPHA/10-CONTEXT/01-vision.md',
      isDirectory: false,
      children: [],
    ),
    // ... more files
  ],
)
```

### ChatMessageUI (Mensajes)

```dart
class ChatMessageUI {
  final String id;              // Unique message ID
  final String role;            // 'system', 'user', 'assistant'
  final String content;         // Message text
  final DateTime timestamp;     // When was sent
}
```

**Ejemplo:**
```dart
ChatMessageUI(
  id: 'msg1',
  role: 'user',
  content: 'Generate the architecture overview',
  timestamp: DateTime.now().subtract(Duration(minutes: 4)),
)
```

### MockProyectoData (Fuente Única de Verdad)

```dart
class MockProjectData {
  // Árbol de directorios
  static const FileNode mockProjectRoot = FileNode(...)

  // Mensajes de chat
  static final List<ChatMessageUI> mockChatMessages = [...]

  // Contenido markdown
  static const String mockMarkdownContent = '''# Architecture Overview...'''

  // Progreso
  static const int mockDocumentsCreated = 8
  static const String mockCurrentPhase = '20-REQUIREMENTS'
  static const int totalDocuments = 25
}
```

---

## 🔄 Integración con Backend

### Paso 1: Crear Notifiers

Reemplaza MockProyectoData con notifiers reales:

```dart
// ANTES: Mock
String _fileContent = MockProjectData.mockMarkdownContent;

// DESPUÉS: Real backend
final contentAsync = ref.watch(fileContentNotifier(_selectedNode.path));
```

### Paso 2: Notifier de Árbol de Archivos

```dart
final fileTreeNotifier = StateNotifierProvider<FileTreeNotifier, FileNode>((ref) {
  return FileTreeNotifier(ref.watch(apiProvider));
});

class FileTreeNotifier extends StateNotifier<FileNode> {
  FileTreeNotifier(this.api) : super(FileNode.root());

  Future<void> loadTree(String projectPath) async {
    final tree = await api.getProjectTree(projectPath);
    state = tree;
  }
}
```

### Paso 3: Notifier de Mensajes de Chat

```dart
final chatMessagesNotifier = StateNotifierProvider<ChatNotifier, List<ChatMessageUI>>((ref) {
  return ChatNotifier(ref.watch(apiProvider));
});

class ChatNotifier extends StateNotifier<List<ChatMessageUI>> {
  ChatNotifier(this.api) : super([]);

  Future<void> sendMessage(String content) async {
    final response = await api.sendChatMessage(content);
    state = [...state, response];
  }
}
```

### Paso 4: Reemplazar en proyecto_shell_screen.dart

```dart
// OLD: Mock data
child: FileTreeWidget(onFileSelected: _onFileSelected)

// NEW: Async data from backend
final fileTree = ref.watch(fileTreeNotifier);
fileTree.when(
  data: (tree) => FileTreeWidget(onFileSelected: _onFileSelected),
  loading: () => LoadingWidget(),
  error: (err, st) => ErrorWidget(error: err),
)
```

---

## 🐛 Troubleshooting

### "El árbol no se expande"
**Solución:** Haz clic en el ► (flecha derecha), no en el nombre del archivo

### "El preview no se actualiza"
**Solución:** Asegúrate de que seleccionaste un archivo (.md), no una carpeta

### "Las columnas no se redimensionan"
**Solución:** El cursor debe cambiar a ↔. Posiciona el mouse en el borde exacto

### "Los FABs no se ven"
**Solución:** Están en la esquina inferior derecha. Desplázate si es necesario

### "El chat no guarda los mensajes"
**Solución:** Los mensajes son solo demo (mock data). El backend los guardará

---

## 📝 Notas Técnicas

- **Compilación:** 0 errors, 25 info warnings (linting only)
- **Performance:** Optimizado para Desktop (Flutter desktop target)
- **Memoria:** Mock data es const (sin overhead en ejecutartime)
- **Responsive:** Funciona en cualquier tamaño de ventana

---

**Última revisión:** 8 de febrero de 2026
**Versión:** 2.0 (Architecture Complete)
**Próxima:** 3.0 (Backend Integración)
