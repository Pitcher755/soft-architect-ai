import 'package:flutter/material.dart';

/// Markdown preview widget displaying rendered markdown content.
///
/// This widget renders the preview panel in the project shell IDE layout.
/// Note: Uses simple text rendering for markdown preview.
class MarkdownPreviewWidget extends StatelessWidget {
  const MarkdownPreviewWidget({this.content, this.filename, super.key});

  /// The markdown content to display
  final String? content;

  /// The filename being previewed
  final String? filename;

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF0D1117),
    child: Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.visibility,
                    size: 18,
                    color: Color(0xFF8B949E),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    filename ?? 'Preview',
                    style: const TextStyle(
                      color: Color(0xFFC9D1D9),
                      fontSize: 12,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    color: const Color(0xFF8B949E),
                    iconSize: 18,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    color: const Color(0xFF8B949E),
                    iconSize: 18,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),

        // Content - Rendered markdown
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _MarkdownRenderer(
              content: content ?? _getDefaultMarkdown(),
            ),
          ),
        ),
      ],
    ),
  );

  static String _getDefaultMarkdown() => '''# SoftArchitect AI - Propuesta de Documento

## 📋 Resumen Ejecutivo

Este documento presenta la propuesta para generar una nueva sección en la documentación del proyecto.

### Características Principales

- **Completitud**: Cobertura completa de temas
- **Claridad**: Explicaciones precisas y ejemplos
- **Mantenibilidad**: Estructura modular y fácil de actualizar

## 🎯 Objetivos

El presente documento busca:

1. Documentar los procesos clave
2. Facilitar la onboarding de nuevos miembros
3. Mantener un registro actualizado

## 📊 Estructura Propuesta

La estructura base es:

```
doc/
├── 00-VISION/
├── 01-PROJECT_REPORT/
└── 02-SETUP_DEV/
```

### Secciones Incluidas

**Sección 1: Contenido Principal**

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

**Sección 2: Detalles Técnicos**

- Punto 1: Implementación principal
- Punto 2: Validaciones requeridas
- Punto 3: Testing y cobertura

## ✅ Validación

| Criterio | Estado | Notas |
|----------|--------|-------|
| Contenido | ✓ | Completo |
| Formato | ✓ | Validado |
| Ejemplos | ✓ | Incluidos |

## 📝 Notas Adicionales

> Esta es una propuesta inicial. Se aceptan sugerencias y mejoras.

---

**Fecha**: 8 de febrero 2026
**Autor**: SoftArchitect AI
''';
}

/// Simple markdown renderer without external dependencies
class _MarkdownRenderer extends StatelessWidget {
  const _MarkdownRenderer({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final lines = content.split(r'\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('# ')) {
        widgets.add(_buildHeading1(line.substring(2).trim()));
      } else if (line.startsWith('## ')) {
        widgets.add(_buildHeading2(line.substring(3).trim()));
      } else if (line.startsWith('### ')) {
        widgets.add(_buildHeading3(line.substring(4).trim()));
      } else if (line.startsWith('- ')) {
        widgets.add(_buildBullet(line.substring(2).trim()));
      } else if (line.startsWith('> ')) {
        widgets.add(_buildBlockquote(line.substring(2).trim()));
      } else if (line.startsWith('| ')) {
        // Skip table lines for now
        continue;
      } else if (line.startsWith('```')) {
        // Code block marker
        continue;
      } else if (line.startsWith('---')) {
        widgets.add(const Divider(color: Color(0xFF30363D)));
      } else {
        widgets.add(_buildParagraph(line));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildHeading1(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFFC9D1D9),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildHeading2(String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFFC9D1D9),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildHeading3(String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 4),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFFC9D1D9),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _buildParagraph(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFFC9D1D9),
        fontSize: 13,
        height: 1.6,
      ),
    ),
  );

  Widget _buildBullet(String text) => Padding(
    padding: const EdgeInsets.only(left: 16, bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            color: Color(0xFF79C0FF),
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFC9D1D9),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildBlockquote(String text) => Padding(
    padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
    child: Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Color(0xFF79C0FF), width: 3),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8B949E),
          fontSize: 13,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
      ),
    ),
  );
}
