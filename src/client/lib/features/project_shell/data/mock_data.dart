import 'package:flutter/material.dart';

import '../../chat/presentation/widgets/message_bubble_widget.dart';
import '../../filesystem/domain/entities/file_node.dart';

/// Mock data for ProjectShellScreen demo
class MockProjectData {
  // ========================
  // File System Structure
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
  // Markdown Preview Mock Data
  // ========================
  static const String mockMarkdownContent = '''# 3. Architecture Overview

This document outlines the high-level architecture for **PROJECT-ALPHA**, focusing on the event-driven microservices interaction.

## System Context

The system follows a standard **Hexagonal Architecture** pattern to isolate core domain logic from external adapters.

```
┌─────────────────────┐
│   API Gateway       │
└──────────┬──────────┘
           │
    ┌──────┴──────┐
    │             │
┌───▼──┐      ┌──▼────┐
│ Auth │      │ Core  │
└──────┘      └───────┘
```

## Scalability Considerations

- **Horizontal Scaling:** Stateless services deployed via Kubernetes
- **Database Sharding:** User data sharded by `tenant_id`
- **Caching Strategy:** Redis cluster for session management

## Performance Targets

| Metric | Target | Status |
|--------|--------|--------|
| API Latency | < 200ms | ✓ |
| Throughput | 10k req/s | ✓ |
| Availability | 99.9% | ⏳ |

> **Note:** This section is being refined based on your constraints feedback.
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
