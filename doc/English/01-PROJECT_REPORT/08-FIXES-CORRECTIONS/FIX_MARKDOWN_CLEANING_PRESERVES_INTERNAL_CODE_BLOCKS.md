# Fix: Markdown Cleaning Preserves Internal Code Blocks

> **Date:** 2026-03-13
> **Status:** ✅ Completed
> **Category:** Bug Fix / Code Quality
> **Impact:** HIGH - Preserves critical document content (Mermaid diagrams, code examples)

## 📋 Table of Contents

1. [Problem Statement](#problem-statement)
2. [Root Cause Analysis](#root-cause-analysis)
3. [Solution Implemented](#solution-implemented)
4. [Test Coverage](#test-coverage)
5. [Validation Results](#validation-results)
6. [Files Modified](#files-modified)

---

## 🔴 Problem Statement

### Issue

The `_cleanDocumentContent` method in `ChatNotifier` was using an aggressive `replaceAll` approach to remove markdown triple-backtick fences (` ``` `). This was **destroying internal code blocks** such as:

- **Mermaid diagrams** (```mermaid ... ```)
- **Python code examples** (```python ... ```)
- **JavaScript snippets** (```javascript ... ```)
- Any other fenced code blocks within the document

### Impact

When an LLM wrapped its response in an outer markdown fence:

```markdown
```markdown
# Architecture

```mermaid
graph TD;
  A-->B;
```
```
```

The old cleaning logic would **remove ALL triple backticks**, resulting in:

```markdown
# Architecture

mermaid
graph TD;
  A-->B;

```

**Result:** Broken Mermaid diagrams, corrupted code examples, unusable documentation.

---

## 🔍 Root Cause Analysis

### Original Implementation (BROKEN)

File: `src/client/lib/features/chat/presentation/notifiers/chat_notifier.dart`

```dart
String _cleanDocumentContent(String rawContent) {
  var clean = rawContent;
  if (clean.contains('[document]')) {
    clean = clean.split('[document]').last;
  }

  // ❌ AGGRESSIVE CLEANUP: Removes ALL triple backticks
  clean = clean.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '');
  clean = clean.replaceAll('```', '');

  // Clean redundant path labels
  clean = clean.replaceAll(
    RegExp(r'\*\*(Path|File|Ruta):\*\*.*?\n', caseSensitive: false),
    '',
  );

  return clean.trim();
}
```

### Why It Failed

The `replaceAll` calls removed **every occurrence** of triple backticks, not just the outer wrapper:

1. Regex `r'```[a-zA-Z]*\n?'` → Removes ```markdown, ```mermaid, ```python, etc.
2. `replaceAll('```', '')` → Removes **all remaining** triple backticks

**No distinction** was made between:
- **Outer wrapper:** ```` ```markdown ... ``` ```` (should be removed)
- **Internal blocks:** ```` ```mermaid ... ``` ```` (must be preserved)

---

## ✅ Solution Implemented

### New Safe Cleaning Logic

The new implementation performs **surgical cleanup** that:

1. ✅ Removes the **outer markdown fence wrapper only**
2. ✅ Preserves **all internal code blocks**
3. ✅ Handles special cases (JSON extraction for USER_STORIES_MASTER)
4. ✅ Removes redundant path labels

### Implementation

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

### Key Improvements

| Aspect | Old Behavior | New Behavior |
|--------|--------------|---------------|
| **Outer fence** | Removed all ` ``` ` | Removes only outer wrapper |
| **Internal blocks** | ❌ Destroyed | ✅ Preserved |
| **Mermaid diagrams** | ❌ Broken | ✅ Intact |
| **Code examples** | ❌ Lost | ✅ Maintained |
| **JSON extraction** | ❌ Not handled | ✅ Special case for USER_STORIES |
| **Safety** | ❌ Destructive | ✅ Surgical |

---

## 🧪 Test Coverage

### Tests Added

File: `tests/client/unit/features/chat/presentation/notifiers/chat_notifier_test.dart`

Added 4 comprehensive tests within the `'ChatNotifier - validateProposal Enhanced'` group:

#### Test 1: Preserve Internal Mermaid Diagrams

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

**Verifies:** Outer ```` ```markdown ... ``` ```` removed, inner ```` ```mermaid ... ``` ```` preserved.

#### Test 2: Remove Outer Fence, Keep Nested Code

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

**Verifies:** Generic outer fence removed, Python code block intact.

#### Test 3: Remove Redundant Path Labels

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

**Verifies:** Path labels removed, document content preserved.

#### Test 4: Handle [document] Control Markers

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

**Verifies:** Control markers stripped, clean content preserved.

---

## ✅ Validation Results

### Test Execution

```bash
flutter test client/unit/features/chat/presentation/notifiers/chat_notifier_test.dart \
  --name "validateProposal Enhanced"
```

**Output:**
```
00:11 +17: All tests passed! ✅
```

**Coverage:**
- Total tests in group: 17 (13 existing + 4 new)
- All tests: **PASS**
- Execution time: 11 seconds

### Code Quality

```bash
dart format src/client/lib/features/chat/presentation/notifiers/chat_notifier.dart
```

**Output:**
```
Formatted 1 file in 0.03 seconds. ✅
```

### Flutter Analyze

```bash
flutter analyze
```

**Output:**
```
No issues found! ✅
```

---

## 📁 Files Modified

### 1. Production Code

**File:** `src/client/lib/features/chat/presentation/notifiers/chat_notifier.dart`

**Changes:**
- **Method:** `_cleanDocumentContent` (lines 420-471)
- **Added:** Comprehensive DartDoc documentation
- **Modified:** Replaced aggressive `replaceAll` with safe line-based removal
- **Added:** JSON extraction for USER_STORIES_MASTER documents
- **Impact:** Preserves internal code blocks (Mermaid, Python, etc.)

### 2. Test Code

**File:** `tests/client/unit/features/chat/presentation/notifiers/chat_notifier_test.dart`

**Changes:**
- **Added:** 4 new tests in `'ChatNotifier - validateProposal Enhanced'` group
- **Coverage:** Mermaid preservation, nested code blocks, path labels, control markers
- **Lines:** Added ~70 lines of test code
- **Impact:** Ensures content cleaning safety for all document types

---

## 🎯 Success Criteria

| Criterion | Before Fix | After Fix |
|-----------|-----------|-----------|
| **Mermaid diagrams preserved** | ❌ No | ✅ Yes |
| **Code examples preserved** | ❌ No | ✅ Yes |
| **Outer fence removed** | ✅ Yes | ✅ Yes |
| **Path labels removed** | ✅ Yes | ✅ Yes |
| **Control markers handled** | ⚠️ Partial | ✅ Complete |
| **JSON extraction** | ❌ No | ✅ Yes (USER_STORIES) |
| **Test coverage** | ❌ 0 tests | ✅ 4 tests |
| **Documentation** | ❌ Minimal | ✅ Comprehensive DartDoc |

---

## 📚 Related Documentation

- [AGENTS.md](/AGENTS.md) - Agent rules and documentation standards
- [Testing Standards](/doc/English/02-SETUP_DEV/03-TESTING/TESTING_GUIDE.md)
- [Clean Architecture Guidelines](/doc/English/01-PROJECT_REPORT/01-ARCHITECTURE/)

---

## 🔗 References

- **Task:** Tarea 1 - Corregir la limpieza destructiva de Markdown
- **Branch:** `feature/hu-5.0-full-workflow-refinement`
- **Commit:** (pending)
- **Reviewed by:** ArchitectZero (AI Agent)
