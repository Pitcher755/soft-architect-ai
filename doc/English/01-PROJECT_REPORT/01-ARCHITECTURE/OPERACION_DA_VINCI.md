# 🎨 Operation Da Vinci — Mermaid Diagram Rendering

> **Date:** 26/02/2026
> **Status:** ✅ Phase 1 Complete (mermaid.ink API)
> **Category:** Architecture Decision Record (ADR)
> **Initiative:** Operation Da Vinci — Mermaid Diagrams in Flutter Desktop
> **Author:** ArchitectZero (SoftArchitect AI)

---

## 📖 Table of Contents

1. [Context and Original Goal](#1-context-and-original-goal)
2. [Technical Blocker — Linux Desktop WebView Limitations](#2-technical-blocker--linux-desktop-webview-limitations)
3. [Architectural Decision — The Pivot to mermaid.ink](#3-architectural-decision--the-pivot-to-mermaidink)
4. [Killer Feature — AI Hallucination Sanitizer](#4-killer-feature--ai-hallucination-sanitizer)
5. [Key Components](#5-key-components)
6. [Setup Notes for Contributors](#6-setup-notes-for-contributors)
7. [Next Steps (Backlog)](#7-next-steps-backlog)

---

## 1. Context and Original Goal

SoftArchitect AI's Master Workflow relies heavily on architectural diagrams. The LLM generates ```` ```mermaid ```` fenced blocks inside its Markdown responses and inside the generated context documents. The goal was to render these diagrams **visually and inline**, directly inside the chat panel and the document preview pane.

### The 100% Offline Vision

The original design requirement was unambiguous:

> **All diagram rendering must happen locally, with zero network calls, preserving the project's "Data Sovereignty" principle.**

The initial plan was to embed `mermaid.min.js` inside a local HTML page served by a `WebView` widget, then pass the diagram source code via a JavaScript bridge (`evaluateJavascript`). Two candidate packages were evaluated:

| Package | Version | Notes |
|---|---|---|
| `webview_flutter` | ^4.x | Official Flutter WebView |
| `flutter_inappwebview` | ^6.x | More control over JS bridge |

Both packages were capable of achieving the goal on Android / iOS / macOS. The blocker appeared specifically on **Linux Desktop**.

---

## 2. Technical Blocker — Linux Desktop WebView Limitations

### What We Found

After adding the packages and attempting to initialize the WebView widget, Flutter threw a hard assertion error at runtime:

```
WebViewPlatform.instance != null
Failed assertion: line 42 pos 14
```

#### Root Cause

Flutter's `webview_flutter` and `flutter_inappwebview` delegate rendering to the OS's native WebView implementation. On Linux, this means:

- **`webview_flutter_linux`** delegates to `WebKitGTK` via `libwebkit2gtk-4.1-dev`
- **`flutter_inappwebview_linux`** can also delegate to `WPE WebKit` via `libwpewebkit-1.0-dev`

These system packages are **not** pre-installed on a standard Ubuntu / Debian desktop. Even when manually installed:

```bash
sudo apt install libwebkit2gtk-4.1-dev
# or
sudo apt install libwpewebkit-1.0-dev
```

The packages still failed to render the WebView **inline** inside the widget tree. The implementation opened separate OS-level windows, completely disconnecting the diagram from the chat flow and breaking the UX.

### Impact

| Criterion | Status |
|---|---|
| Inline rendering in chat panel | ❌ Not possible |
| Same-window rendering | ❌ Opens separate window |
| Dependency-free installation | ❌ Requires heavy OS packages |
| CI/CD compatibility | ❌ Build agents lack GTK libraries |

**Decision: Temporarily blocked. Pivot required to unblock feature development.**

---

## 3. Architectural Decision — The Pivot to mermaid.ink

### Tactical Fallback

Introduced the **mermaid.ink** rendering API as a temporary but production-grade solution. The API is a free, public, stateless service that accepts a Base64-encoded JSON payload and returns a PNG/SVG image.

```
GET https://mermaid.ink/img/<base64url-payload>
```

### Encoding Algorithm

```dart
// In MermaidView — lib/shared/presentation/widgets/mermaid_view.dart
String get _imageUrl {
  final jsonPayload = jsonEncode({
    'code': _sanitizedCode,
    'mermaid': {'theme': 'dark', 'backgroundColor': 'transparent'},
  });

  final bytes = utf8.encode(jsonPayload);
  final base64Str = base64UrlEncode(bytes).replaceAll('=', '');

  return 'https://mermaid.ink/img/$base64Str';
}
```

1. Wrap the Mermaid source in a JSON envelope with theme metadata.
2. Encode with `utf8.encode` → `base64UrlEncode`.
3. Strip padding (`=`) — required by the API.
4. Pass the URL to `Image.network()`.

### Why This Works Well

- **Zero Flutter dependencies**: uses only core Dart `dart:convert`.
- **Stays inline**: renders as a native `Image` widget inside the chat / document tree.
- **Loading state**: native `loadingBuilder` shows a spinner during fetch.
- **Error state**: `errorBuilder` shows a warning badge if the API rejects the payload.
- **Dark theme aware**: theme is embedded in the payload.

### Trade-offs Accepted

| Attribute | Offline Engine (goal) | mermaid.ink (current) |
|---|---|---|
| Network required | ❌ No | ✅ Yes |
| Privacy | ✅ 100% local | ⚠️ Diagram sent to 3rd party |
| Linux support | ❌ Blocked | ✅ Works everywhere |
| Latency | < 10 ms | ~ 300–800 ms (network) |
| Dependencies | Heavy OS packages | None |

> **Privacy note:** The diagram code is sent to `mermaid.ink` servers only. No user messages, project metadata, or API keys are exposed. For teams with strict data governance requirements, a self-hosted instance of mermaid.ink can be substituted by changing a single constant.

---

## 4. Killer Feature — AI Hallucination Sanitizer

### The Problem

During integration tests, the LLM occasionally generated syntactically invalid Mermaid code. The most frequent error pattern was a malformed arrow notation:

```
%% LLM-generated (WRONG)
A -->|Label|> B
         ^^^
         Extra |> causes HTTP 400 from mermaid.ink
```

The API returned HTTP 400 for these payloads, triggering the error state widget. The sanitizer was introduced to prevent this silently, before the network call.

### The Solution — Regex Sanitization Layer

```dart
// In MermaidView — sanitizedCode getter
String get _sanitizedCode => code
    // Fix -->|Label|> → -->|Label|
    .replaceAll(RegExp(r'\|>\s*'), '| ')
    // Fix ->(single) → -->(double)
    .replaceAll(RegExp(r'(?<!-)−>\|'), '-->|')
    .replaceAll('->|', '-->|');
```

| Pattern | Input | Output | Reason |
|---|---|---|---|
| `\|>\s*` | `-->|Deploys|>` | `-->|Deploys| ` | Removes stray `>` after label |
| `(?<!-)−>\|` | `−>|Auth|` | `-->|Auth|` | Fixes Unicode-minus arrow |
| `->|` | `->|Deploy|` | `-->|Deploy|` | Normalises single-dash arrow |

This sanitization runs **100% client-side**, zero network overhead, on every `MermaidView` render.

---

## 5. Key Components

### 5.1 `MermaidView` — Core Rendering Widget

**Path:** `lib/shared/presentation/widgets/mermaid_view.dart`

A pure `StatelessWidget` that acts as the rendering pipeline:

```
String code (raw LLM output)
    │
    ▼
_sanitizedCode    ← Regex sanitizer removes invalid patterns
    │
    ▼
_imageUrl         ← JSON encode → UTF-8 → Base64 URL-safe → mermaid.ink URL
    │
    ▼
Image.network()   ← Renders inline with loading + error states
```

### 5.2 `MermaidBuilder` — The Sniper for `SmartMessageRenderer`

**Path:** `lib/shared/presentation/widgets/markdown_builders/mermaid_builder.dart`

A `MarkdownElementBuilder` injected into `MarkdownBody.builders`. It intercepts Markdown `<code>` elements whose CSS class is `language-mermaid` and redirects them to `MermaidView`. All other code blocks are left untouched for the default renderer.

```dart
class MermaidBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final classList = element.attributes['class'] ?? '';
    if (classList.contains('language-mermaid')) {
      return MermaidView(code: element.textContent);
    }
    return null; // Fall through to default rendering
  }
}
```

`SmartMessageRenderer` registers it via:

```dart
MarkdownBody(
  data: content,
  builders: {'code': MermaidBuilder()},
  ...
)
```

### 5.3 `_CodeElementBuilder` — The Hybrid Sniper for `MarkdownPreviewWidget`

**Path:** `lib/features/project_shell/presentation/widgets/markdown_preview_widget.dart`

The document preview widget uses a local, private `_CodeElementBuilder` that implements the same intercept pattern but also handles syntax-highlighted code blocks via `flutter_highlighter`:

```dart
class _CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final language = /* extract from class="language-X" */ ...;

    // Route: mermaid → MermaidView
    if (language == 'mermaid') {
      return MermaidView(code: codeContent);
    }

    // Route: everything else → HighlightView (syntax colors)
    return HighlightView(
      codeContent,
      language: language,
      theme: atomOneDarkTheme,
      ...
    );
  }
}
```

This "hybrid sniper" pattern ensures that a single `builders` map handles **all** code block types without conditional rendering at the widget tree level.

### 5.4 `MarkdownPreviewWidget` — `PathNotFoundException` Fix

During document preview, `_loadFileContent()` is called when a `filename` is provided. Before the fix, attempting to read a file that had never been saved (i.e., it only existed as in-memory streamed content) would throw a `PathNotFoundException`, crashing the preview pane.

The fix wraps the `file.readAsString()` call in a typed exception handler and gracefully falls back to the `widget.content` prop:

```dart
Future<void> _loadFileContent() async {
  try {
    final file = File(widget.filename!);
    final content = await file.readAsString();
    if (mounted && !_isEditing) {
      setState(() => _textController.text = content);
    }
  } on Exception catch (e) {
    debugPrint('⚠️ Error reading file: $e');
    // Graceful fallback to in-memory content
    if (mounted && !_isEditing) {
      setState(() => _textController.text = widget.content ?? '');
    }
  }
}
```

---

## 6. Setup Notes for Contributors

> **⚠️ Note for future contributors — Linux Desktop WebView support**

If the team decides to revisit the 100% offline WebView rendering path (Phase 2.0), the following OS-level libraries **must** be installed on any Linux build host or development machine before running `flutter build linux` with WebView packages:

```bash
# Option A: WebKit GTK (webview_flutter_linux)
sudo apt install libwebkit2gtk-4.1-dev

# Option B: WPE WebKit (flutter_inappwebview_linux)
sudo apt install libwpewebkit-1.0-dev

# Also required in most minimal environments
sudo apt install build-essential cmake ninja-build
```

These packages must also be declared in the GitHub Actions runner environment or any Docker build image used for CI/CD.

---

## 7. Next Steps (Backlog)

| Priority | Task | Notes |
|---|---|---|
| P1 | **Evaluate Flutter WebView maturity on Linux** | Re-assess when `webview_flutter_linux` >= 1.0 is stable. Track: [flutter/plugins#7246](https://github.com/flutter/flutter/issues) |
| P1 | **Optional: Self-hosted mermaid.ink** | Deploy `mermaid.ink` as a Docker sidecar in `infrastructure/` for teams requiring full data sovereignty (zero external calls) |
| P2 | **SVG rendering mode** | Use `mermaid.ink/svg/` endpoint + `flutter_svg` for resolution-independent diagrams |
| P2 | **Diagram caching** | Add LRU cache keyed on diagram hash to avoid redundant API calls for identical diagrams during streaming |
| P3 | **Extend sanitizer rules** | Monitor LLM output in staging; add new regex patterns for new hallucination variants |
| P3 | **Offline fallback UI** | If `mermaid.ink` is unreachable (no internet), show the raw code in a styled code block instead of the error widget |

---

> **Architecture principle fulfilled:** The pivot to `mermaid.ink` was made transparently without changing the public API of any consumer widget. All callsites (`SmartMessageRenderer`, `MarkdownPreviewWidget`) continue to pass raw Mermaid source strings without knowing how rendering is implemented — the Dependency Inversion principle is preserved.
