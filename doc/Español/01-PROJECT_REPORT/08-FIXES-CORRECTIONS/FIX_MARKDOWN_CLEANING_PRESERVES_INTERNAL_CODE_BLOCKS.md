# Corrección: La Limpieza de Markdown Preserva los Bloques de Código Internos

> **Fecha:** 2026-03-13
> **Estado:** ✅ Completado
> **Categoría:** Corrección de Bug / Calidad de Código
> **Impacto:** ALTO - Preserva contenido crítico del documento (diagramas Mermaid, ejemplos de código)

## 📋 Tabla de Contenidos

1. [Descripción del Problema](#descripción-del-problema)
2. [Análisis de Causa Raíz](#análisis-de-causa-raíz)
3. [Solución Implementada](#solución-implementada)
4. [Cobertura de Tests](#cobertura-de-tests)
5. [Resultados de Validación](#resultados-de-validación)
6. [Archivos Modificados](#archivos-modificados)

---

## 🔴 Descripción del Problema

### Problema

El método `_cleanDocumentContent` en `ChatNotifier` estaba usando un enfoque agresivo de `replaceAll` para eliminar las vallas de triple comilla invertida de markdown (` ``` `). Esto estaba **destruyendo los bloques de código internos** tales como:

- **Diagramas Mermaid** (```mermaid ... ```)
- **Ejemplos de código Python** (```python ... ```)
- **Fragmentos de JavaScript** (```javascript ... ```)
- Cualquier otro bloque de código delimitado dentro del documento

### Impacto

Cuando un LLM envolvía su respuesta en una valla de markdown exterior:

```markdown
```markdown
# Arquitectura

```mermaid
graph TD;
  A-->B;
```
```
```

La antigua lógica de limpieza **eliminaba TODAS las triples comillas**, resultando en:

```markdown
# Arquitectura

mermaid
graph TD;
  A-->B;

```

**Resultado:** Diagramas Mermaid rotos, ejemplos de código corruptos, documentación inutilizable.

---

## 🔍 Análisis de Causa Raíz

### Implementación Original (ROTA)

Archivo: `src/client/lib/features/chat/presentation/notifiers/chat_notifier.dart`

```dart
String _cleanDocumentContent(String rawContent) {
  var clean = rawContent;
  if (clean.contains('[document]')) {
    clean = clean.split('[document]').last;
  }

  // ❌ LIMPIEZA AGRESIVA: Elimina TODAS las triples comillas
  clean = clean.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '');
  clean = clean.replaceAll('```', '');

  // Limpiar etiquetas de ruta redundantes
  clean = clean.replaceAll(
    RegExp(r'\*\*(Path|File|Ruta):\*\*.*?\n', caseSensitive: false),
    '',
  );

  return clean.trim();
}
```

### Por Qué Falló

Las llamadas `replaceAll` eliminaban **cada ocurrencia** de las triples comillas, no solo el envoltorio exterior:

1. Regex `r'```[a-zA-Z]*\n?'` → Elimina ```markdown, ```mermaid, ```python, etc.
2. `replaceAll('```', '')` → Elimina **todas las** triples comillas restantes

**No se hacía distinción** entre:
- **Envoltorio exterior:** ```` ```markdown ... ``` ```` (debe eliminarse)
- **Bloques internos:** ```` ```mermaid ... ``` ```` (deben preservarse)

---

## ✅ Solución Implementada

### Nueva Lógica de Limpieza Segura

La nueva implementación realiza **limpieza quirúrgica** que:

1. ✅ Elimina **solo el envoltorio de valla de markdown exterior**
2. ✅ Preserva **todos los bloques de código internos**
3. ✅ Maneja casos especiales (extracción de JSON para USER_STORIES_MASTER)
4. ✅ Elimina etiquetas de ruta redundantes

### Implementación

```dart
/// Cleans document content by removing outer markdown fences and metadata.
///
/// This method performs safe markdown cleanup that preserves internal code
/// blocks (e.g., Mermaid diagrams) while removing:
/// 1. Control markers like `[document]`
/// 2. JSON extraction for USER_STORIES_MASTER documents
/// 3. Outer markdown fence (``` wrapper) if present
/// 4. Redundant path labels (Path:, File:, etc.)
///
/// **Safety:** Unlike aggressive `replaceAll`, this only removes the
/// outermost code fence wrapper, preserving all internal code blocks.
String _cleanDocumentContent(String rawContent) {
  var clean = rawContent.trim();

  // 1. Remove control markers
  if (clean.contains('[document]')) {
    clean = clean.split('[document]').last.trim();
  }

  // 2. Extract pure JSON for USER_STORIES_MASTER
  final currentDocType = _getDocTypeForIndex(state.currentDocIndex);
  if (currentDocType == 'USER_STORIES_MASTER') {
    final jsonRegex = RegExp(r'(\{[\s\S]*\}|\[[\s\S]*\])');
    final match = jsonRegex.stringMatch(clean);
    if (match != null) return match.trim();
  }

  // 3. SAFE Markdown cleanup (only removes outer wrapper)
  if (clean.startsWith('```')) {
    final lines = clean.split('\n');
    if (lines.length > 1 &&
        lines.first.startsWith('```') &&
        lines.last.trim() == '```') {
      lines.removeAt(0); // Remove first line
      lines.removeLast(); // Remove last line
      clean = lines.join('\n');
    }
  }

  // 4. Clean redundant path labels
  clean = clean.replaceAll(
    RegExp(r'\*\*(Path|File|Archivo|Ruta):\*\*.*?\n', caseSensitive: false),
    '',
  );

  return clean.trim();
}
```

### Mejoras Clave

| Aspecto | Comportamiento Antiguo | Comportamiento Nuevo |
|---------|------------------------|----------------------|
| **Valla exterior** | Eliminaba todas las ` ``` ` | Elimina solo el envoltorio exterior |
| **Bloques internos** | ❌ Destruidos | ✅ Preservados |
| **Diagramas Mermaid** | ❌ Rotos | ✅ Intactos |
| **Ejemplos de código** | ❌ Perdidos | ✅ Mantenidos |
| **Extracción JSON** | ❌ No manejada | ✅ Caso especial para USER_STORIES |
| **Seguridad** | ❌ Destructiva | ✅ Quirúrgica |

---

## 🧪 Cobertura de Tests

### Tests Añadidos

Archivo: `tests/client/unit/features/chat/presentation/notifiers/chat_notifier_test.dart`

Se añadieron 4 tests completos dentro del grupo `'ChatNotifier - validateProposal Enhanced'`:

#### Test 1: Preservar Diagramas Mermaid Internos

```dart
test('should preserve internal Mermaid diagrams when validating', () async {
  fakeRepository.generatedTokens = [
    '```markdown\n',
    '# Architecture\n\n',
    '```mermaid\n',
    'graph TD;\n',
    '  A-->B;\n',
    '```\n',
    '```',
  ];

  await notifier.sendMessageStream('Generate architecture');
  await notifier.validateProposal();

  final savedContent = fakeFileSystemService.lastSavedContent;
  expect(savedContent, contains('```mermaid'));
  expect(savedContent, contains('graph TD;'));
  expect(savedContent, isNot(contains('```markdown')));
});
```

**Verifica:** ```` ```markdown ... ``` ```` exterior eliminado, ```` ```mermaid ... ``` ```` interno preservado.

#### Test 2: Eliminar Valla Externa, Mantener Código Anidado

```dart
test('should remove outer fence but keep nested code blocks', () async {
  fakeRepository.generatedTokens = [
    '```\n',
    '# Guide\n\n',
    '```python\n',
    'def test():\n',
    '    pass\n',
    '```\n',
    '```',
  ];

  await notifier.validateProposal();

  final savedContent = fakeFileSystemService.lastSavedContent;
  expect(savedContent, contains('```python'));
  expect(savedContent, contains('def test():'));
});
```

**Verifica:** Valla externa genérica eliminada, bloque de código Python intacto.

#### Test 3: Eliminar Etiquetas de Ruta Redundantes

```dart
test('should remove redundant path labels from content', () async {
  fakeRepository.generatedTokens = [
    '# Project Manifesto\n\n',
    '**Path:** context/PROJECT_MANIFESTO.md\n\n',
    '## Introduction\n',
    'Content here.',
  ];

  await notifier.validateProposal();

  final savedContent = fakeFileSystemService.lastSavedContent;
  expect(savedContent, isNot(contains('**Path:**')));
  expect(savedContent, contains('# Project Manifesto'));
});
```

**Verifica:** Etiquetas de ruta eliminadas, contenido del documento preservado.

#### Test 4: Manejar Marcadores de Control [document]

```dart
test('should handle [document] control markers', () async {
  fakeRepository.generatedTokens = [
    '[thinking] Processing...\n',
    '[document]\n',
    '# Clean Doc\n',
    'Content',
  ];

  await notifier.validateProposal();

  final savedContent = fakeFileSystemService.lastSavedContent;
  expect(savedContent, isNot(contains('[thinking]')));
  expect(savedContent, isNot(contains('[document]')));
  expect(savedContent, contains('# Clean Doc'));
});
```

**Verifica:** Marcadores de control eliminados, contenido limpio preservado.

---

## ✅ Resultados de Validación

### Ejecución de Tests

```bash
flutter test client/unit/features/chat/presentation/notifiers/chat_notifier_test.dart \
  --name "validateProposal Enhanced"
```

**Salida:**
```
00:11 +17: All tests passed! ✅
```

**Cobertura:**
- Total de tests en el grupo: 17 (13 existentes + 4 nuevos)
- Todos los tests: **PASS**
- Tiempo de ejecución: 11 segundos

### Calidad de Código

```bash
dart format src/client/lib/features/chat/presentation/notifiers/chat_notifier.dart
```

**Salida:**
```
Formatted 1 file in 0.03 seconds. ✅
```

### Flutter Analyze

```bash
flutter analyze
```

**Salida:**
```
No issues found! ✅
```

---

## 📁 Archivos Modificados

### 1. Código de Producción

**Archivo:** `src/client/lib/features/chat/presentation/notifiers/chat_notifier.dart`

**Cambios:**
- **Método:** `_cleanDocumentContent` (líneas 420-471)
- **Añadido:** Documentación DartDoc completa
- **Modificado:** Reemplazado `replaceAll` agresivo con eliminación segura basada en líneas
- **Añadido:** Extracción JSON para documentos USER_STORIES_MASTER
- **Impacto:** Preserva bloques de código internos (Mermaid, Python, etc.)

### 2. Código de Tests

**Archivo:** `tests/client/unit/features/chat/presentation/notifiers/chat_notifier_test.dart`

**Cambios:**
- **Añadido:** 4 nuevos tests en el grupo `'ChatNotifier - validateProposal Enhanced'`
- **Cobertura:** Preservación de Mermaid, bloques de código anidados, etiquetas de ruta, marcadores de control
- **Líneas:** Añadidas ~70 líneas de código de test
- **Impacto:** Asegura la seguridad de la limpieza de contenido para todos los tipos de documentos

---

## 🎯 Criterios de Éxito

| Criterio | Antes de la Corrección | Después de la Corrección |
|----------|------------------------|--------------------------|
| **Diagramas Mermaid preservados** | ❌ No | ✅ Sí |
| **Ejemplos de código preservados** | ❌ No | ✅ Sí |
| **Valla exterior eliminada** | ✅ Sí | ✅ Sí |
| **Etiquetas de ruta eliminadas** | ✅ Sí | ✅ Sí |
| **Marcadores de control manejados** | ⚠️ Parcial | ✅ Completo |
| **Extracción JSON** | ❌ No | ✅ Sí (USER_STORIES) |
| **Cobertura de tests** | ❌ 0 tests | ✅ 4 tests |
| **Documentación** | ❌ Mínima | ✅ DartDoc completa |

---

## 📚 Documentación Relacionada

- [AGENTS.md](/AGENTS.md) - Reglas del agente y estándares de documentación
- [Estándares de Testing](/doc/Español/02-SETUP_DEV/03-TESTING/TESTING_GUIDE.md)
- [Guías de Clean Architecture](/doc/Español/01-PROJECT_REPORT/01-ARCHITECTURE/)

---

## 🔗 Referencias

- **Tarea:** Tarea 1 - Corregir la limpieza destructiva de Markdown
- **Rama:** `feature/hu-5.0-full-workflow-refinement`
- **Commit:** (pendiente)
- **Revisado por:** ArchitectZero (Agente IA)
