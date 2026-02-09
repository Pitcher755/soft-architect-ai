// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'package:flutter/material.dart';

import '../../chat/presentation/widgets/message_bubble_widget.dart';
import '../../filesystem/domain/entities/file_node.dart';

/// Mock data for ProjectShellScreen demo
class MockProjectData {
  // ========================
  // Guía del Usuario (Mock Guide)
  // ========================
  static const FileNode guideRootNode = FileNode(
    id: 'root-guide',
    name: 'SOFTARCHITECT-GUIDE',
    path: 'mock://softarchitect-guide',
    isDirectory: true,
    children: [
      FileNode(
        id: 'welcome',
        name: '00-Bienvenido.md',
        path: 'mock://softarchitect-guide/00-Bienvenido.md',
        isDirectory: false,
      ),
      FileNode(
        id: 'features',
        name: '01-Funcionalidades',
        path: 'mock://softarchitect-guide/features',
        isDirectory: true,
        children: [
          FileNode(
            id: 'f1',
            name: 'Chat-IA.md',
            path: 'mock://softarchitect-guide/features/Chat-IA.md',
            isDirectory: false,
          ),
        ],
      ),
    ],
  );

  // ========================
  // Contenido de la Guía
  // ========================
  static const Map<String, String> guideFileContents = {
    'mock://softarchitect-guide/00-Bienvenido.md':
        '''# 👋 Bienvenido a SoftArchitect AI

Esta es tu guía interactiva. Aquí aprenderás a usar la herramienta.

## Pasos:
1. Crea un proyecto con el botón "+".
2. Selecciona una carpeta vacía.
3. Empieza a crear.

## Características principales:
- **Análisis de Arquitectura**: Diseña sistemas escalables
- **Documentación Viva**: Genera documentos automáticamente
- **Chat IA**: Interactúa con tus documentos
- **Híbrido**: Funciona online y offline''',
    'mock://softarchitect-guide/features/Chat-IA.md': '''# 🤖 Chat IA

El panel central te permite hablar con tus documentos.

## Funcionalidades:
- Realiza preguntas sobre tu arquitectura
- Genera archivos automáticamente
- Obtén sugerencias de mejora
- Crea documentación

## Ejemplo:
Prueba a pedir:
- "Genera un README"
- "Sugiere mejoras al diseño"
- "Crea un diagrama de componentes"
- "Explica la arquitectura actual"

## Tips:
- Sé específico en tus preguntas
- Proporciona contexto si es necesario
- Revisa siempre las sugerencias antes de aplicarlas''',
  };

  // ========================
  // Legacy Mock Data (Proyecto de Ejemplo)
  // ========================
  static const FileNode mockProjectRoot = FileNode(
    id: 'root',
    name: 'PROJECT-ALPHA',
    path: '/projects/PROJECT-ALPHA',
    isDirectory: true,
    children: [
      FileNode(
        id: 'context',
        name: 'context/',
        path: '/projects/PROJECT-ALPHA/context',
        isDirectory: true,
        children: [
          FileNode(
            id: 'system_prompt',
            name: 'system-prompt.md',
            path: '/projects/PROJECT-ALPHA/context/system-prompt.md',
            isDirectory: false,
          ),
        ],
      ),
      FileNode(
        id: '10-context',
        name: '10-CONTEXT/',
        path: '/projects/PROJECT-ALPHA/10-CONTEXT',
        isDirectory: true,
        children: [
          FileNode(
            id: 'vision',
            name: '01-vision.md',
            path: '/projects/PROJECT-ALPHA/10-CONTEXT/01-vision.md',
            isDirectory: false,
          ),
          FileNode(
            id: 'constraints',
            name: '02-constraints.md',
            path: '/projects/PROJECT-ALPHA/10-CONTEXT/02-constraints.md',
            isDirectory: false,
          ),
          FileNode(
            id: 'arch_overview',
            name: '03-arch-overview.md',
            path: '/projects/PROJECT-ALPHA/10-CONTEXT/03-arch-overview.md',
            isDirectory: false,
          ),
        ],
      ),
      FileNode(
        id: '20-requirements',
        name: '20-REQUIREMENTS/',
        path: '/projects/PROJECT-ALPHA/20-REQUIREMENTS',
        isDirectory: true,
      ),
      FileNode(
        id: '30-architecture',
        name: '30-ARCHITECTURE/',
        path: '/projects/PROJECT-ALPHA/30-ARCHITECTURE',
        isDirectory: true,
      ),
    ],
  );

  // ========================
  // Chat Messages Mock Data
  // ========================
  static final List<ChatMessageUI> mockChatMessages = [
    ChatMessageUI(
      id: 'msg1',
      role: 'system',
      content:
          'SoftArchitect AI Project initialized. Context loaded from context/.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessageUI(
      id: 'msg2',
      role: 'user',
      content:
          'Generate the high-level architecture overview based on the vision and constraints defined. Focus on scalability for the microservices layer.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessageUI(
      id: 'msg3',
      role: 'assistant',
      content:
          'I have analyzed the constraints. Moving to module definition. Identifying key scalability bottlenecks in current constraint definitions. Mapping event-driven patterns...',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  // ========================
  // Markdown Preview Mock Data (RICH CONTENT)
  // ========================
  // Usamos r''' (raw string) para evitar conflictos con el símbolo $ en el código Dart
  static const String mockMarkdownContent = r'''

# 🚀 Project Vision: SoftArchitect AI

## 📋 Executive Summary
This document outlines the architecture for the **SoftArchitect AI** MVP. We are aiming for a modular, scalable solution that prioritizes local execution and user privacy.

### Tech Stack Overview
| Component | Technology | Version | Status |
|-----------|------------|---------|--------|
| Frontend  | Flutter    | 3.27    | ✅ Stable |
| Backend   | FastAPI    | 0.109   | ✅ Stable |
| Database  | ChromaDB   | 0.4     | 🚧 Beta   |
| AI Model  | Ollama     | Latest  | 🚀 Active |

## 💻 Implementation Example (Dart)
The following code snippet demonstrates how we handle local file persistence safely within the file system shell:

```dart
import 'dart:io';

Future<void> saveDocument(String path, String content) async {
  final file = File(path);
  try {
    await file.writeAsString(content);
    print('✅ File saved successfully at: $path');
  } catch (e) {
    print('❌ Error saving file: $e');
  }
}

```

## 📊 Architecture Diagram (Mermaid)

The system follows a standard **RAG (Retrieval-Augmented Generation)** pipeline designed for offline capability:

```mermaid
graph TD;
    User[User] -->|1. Prompt| App(Flutter App);
    App -->|2. API Request| API{FastAPI Gateway};
    API -->|3. Query Vector DB| DB[(ChromaDB)];
    DB -->|4. Return Context| API;
    API -->|5. Send Context + Prompt| LLM[Ollama LLM];
    LLM -->|6. Stream Response| App;

    style User fill:#f9f,stroke:#333,stroke-width:2px
    style DB fill:#bbf,stroke:#333,stroke-width:2px
    style LLM fill:#dfd,stroke:#333,stroke-width:2px

```

## 📝 Key Constraints

> "Simplicity is the soul of efficiency." - Austin Freeman

1. **Offline First:** The system must work without internet for local models.
2. **Low Latency:** UI updates must occur within 16ms frame budget.
3. **Security:** API keys must never be logged or transmitted externally.

---

*Last Updated: February 2026*



```

''';

  // ========================
  // Progress Indicator Data
  // ========================
  static const int mockDocumentsCreated = 8;
  static const String mockCurrentPhase = '20-REQUIREMENTS';
  static const int totalDocuments = 25;

  // ========================
  // Helper Methods
  // ========================

  /// Get color for directory phase (00-ROOT, 10-CONTEXT, etc.)
  static Color getPhaseColor(String phaseName) {
    if (phaseName.contains('ROOT')) {
      return const Color(0xFF1B4965); // Dark blue
    } else if (phaseName.contains('10-CONTEXT')) {
      return const Color(0xFF7B2D5E); // Purple
    } else if (phaseName.contains('20-REQUIREMENTS')) {
      return const Color(0xFFC05746); // Orange
    } else if (phaseName.contains('30-ARCHITECTURE')) {
      return const Color(0xFF566573); // Gray blue
    } else if (phaseName.contains('35-UI_UX')) {
      return const Color(0xFF1B9E77); // Teal
    } else if (phaseName.contains('40-PLANNING')) {
      return const Color(0xFFD95319); // Dark orange
    } else {
      return const Color(0xFF7F39FB); // Default purple
    }
  }

  /// Get phase end count for progress calculation
  static int getPhaseEndCount(String phase) {
    switch (phase) {
      case 'ROOT':
        return 4;
      case 'CONTEXT':
        return 4 + 3;
      case 'REQUIREMENTS':
        return 4 + 3 + 4;
      case 'ARCHITECTURE':
        return 4 + 3 + 4 + 6;
      case 'UI_UX':
        return 4 + 3 + 4 + 6 + 3;
      case 'PLANNING':
        return 4 + 3 + 4 + 6 + 3 + 4;
      case 'META':
        return 25;
      default:
        return 0;
    }
  }
}
