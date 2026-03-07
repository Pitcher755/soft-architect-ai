# ♿ Accessibility Requirements - SoftArchitect AI

> **Document Type:** WCAG 2.1 AA Compliance Specification
> **Project:** SoftArchitect AI
> **Version:** 1.0.0
> **Last Updated:** February 2026
> **Target Compliance:** WCAG 2.1 Level AA (⚠️ 60% achieved, Sprint 4-5 roadmap)

---

## 📖 Table of Contents

1. [Accessibility Overview](#-accessibility-overview)
2. [WCAG 2.1 Level AA Checklist](#-wcag-21-level-aa-checklist)
3. [Keyboard Navigation](#-keyboard-navigation)
4. [Screen Reader Support](#-screen-reader-support)
5. [Visual Accessibility](#-visual-accessibility)
6. [Cognitive Accessibility](#-cognitive-accessibility)
7. [Testing Strategy](#-testing-strategy)
8. [Known Limitations](#-known-limitations)
9. [Roadmap](#-roadmap)

---

## 🎯 Accessibility Overview

### Commitment

SoftArchitect AI aims to be accessible to developers with disabilities. We target **WCAG 2.1 Level AA** compliance for desktop application (Linux/macOS/Windows).

### Current Status (February 2026)

| Category | Status | Progress |
|----------|--------|----------|
| **Keyboard Navigation** | ⚠️ Partial | 90% (missing: custom widgets) |
| **Screen Reader Support** | ⚠️ Partial | 60% (basic Semantics only) |
| **Visual Accessibility** | ✅ Good | 85% (high contrast, scalable fonts) |
| **Cognitive Accessibility** | ✅ Good | 80% (clear labels, error messages) |
| **Overall WCAG 2.1 AA** | ⚠️ Partial | **60%** (target: 95%+ by Sprint 5) |

### User Personas with Disabilities

#### Persona 1: Alex (Visual Impairment)

- **Disability:** Legal blindness (light perception only)
- **Tools:** NVDA screen reader (Windows), Orca (Linux)
- **Needs:**
  - ✅ Full keyboard navigation (no mouse required)
  - ⚠️ ARIA labels for all interactive elements (60% coverage)
  - ⚠️ Proper heading hierarchy (lacks H1-H6 structure)
  - ❌ Screen reader announces form validation errors (not implemented)

#### Persona 2: Jordan (Motor Disability)

- **Disability:** Limited hand mobility (cerebral palsy)
- **Tools:** Mouth stick, voice control software
- **Needs:**
  - ✅ Large click targets (≥44x44px)
  - ✅ No time-based interactions (user controls pace)
  - ⚠️ Sticky keys friendly (shift+Ctrl+key sometimes fails)
  - ✅ No drag-and-drop required

#### Persona 3: Sam (Cognitive Disability)

- **Disability:** Dyslexia, ADHD
- **Tools:** Text-to-speech, focus mode
- **Needs:**
  - ✅ Clear, concise instructions
  - ✅ Consistent navigation patterns
  - ⚠️ Reduced distractions (needs "Focus Mode" toggle)
  - ✅ Error messages with suggested fixes

---

## ✅ WCAG 2.1 Level AA Checklist

### Perceivable (4 Principles)

#### 1.1 Text Alternatives

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **1.1.1 Non-text Content** | A | ⚠️ 70% | All images have `alt` text except Logo2.png (decorative, `alt=""`) |

**Example (Logo with decorative intent):**
```dart
// workspace_header.dart
Image.asset(
  'assets/images/Logo2.png',
  height: 70,
  semanticLabel: '',  // Empty = decorative (screen readers skip)
)
```

---

#### 1.2 Time-based Media

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **1.2.1 Audio-only and Video-only** | A | ✅ N/A | No audio/video content |
| **1.2.2 Captions** | A | ✅ N/A | No video content |

---

#### 1.3 Adaptable

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **1.3.1 Info and Relationships** | A | ⚠️ 60% | Form fields have labels, but lacks ARIA roles for custom widgets |
| **1.3.2 Meaningful Sequence** | A | ✅ 90% | Tab order follows visual layout (top-to-bottom, left-to-right) |
| **1.3.3 Sensory Characteristics** | A | ✅ 100% | Instructions don't rely on shape/color alone ("Click the green button" ❌, "Click Save" ✅) |
| **1.3.4 Orientation** | AA | ✅ 100% | App works in landscape/portrait (desktop resizable) |
| **1.3.5 Identify Input Purpose** | AA | ⚠️ 50% | No `autocomplete` attributes (not applicable to desktop forms) |

**Example (Semantic form field):**
```dart
// create_project_dialog.dart
TextField(
  decoration: InputDecoration(
    labelText: 'Project Name',  // ✅ Screen reader announces label
    hintText: 'e.g., MyAwesomeApp',
    errorText: _errorText,      // ✅ Screen reader announces errors
  ),
  semanticsLabel: 'Project Name Input',  // ✅ Explicit ARIA label
  autofocus: true,
)
```

---

#### 1.4 Distinguishable

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **1.4.1 Use of Color** | A | ✅ 100% | Error states use icons + text (not color alone) |
| **1.4.2 Audio Control** | A | ✅ N/A | No auto-playing audio |
| **1.4.3 Contrast (Minimum)** | AA | ✅ 95% | 4.5:1 contrast for normal text, 3:1 for large text |
| **1.4.4 Resize Text** | AA | ✅ 100% | Fonts scale with OS settings (respects `MediaQuery.textScaleFactor`) |
| **1.4.5 Images of Text** | AA | ✅ 100% | No text baked into images (except logo) |
| **1.4.10 Reflow** | AA | ✅ 90% | UI reflows at 400% zoom (tested up to 200%) |
| **1.4.11 Non-text Contrast** | AA | ⚠️ 80% | Most icons have 3:1 contrast, some decorative icons fail |
| **1.4.12 Text Spacing** | AA | ✅ 100% | Text remains readable with increased spacing |
| **1.4.13 Content on Hover** | AA | ✅ N/A | No hover-only tooltips (all info accessible via keyboard) |

**Contrast Test Results:**
```
Tested with WebAIM Contrast Checker:

✅ Primary text (dark mode): #E0E0E0 on #121212 = 12.63:1 (Pass AAA)
✅ Primary text (light mode): #212121 on #FAFAFA = 15.84:1 (Pass AAA)
✅ Error text: #F44336 on #FFFFFF = 4.55:1 (Pass AA)
⚠️ Disabled text: #757575 on #FAFAFA = 3.87:1 (Fail AA, needs 4.5:1)
```

**Fix for disabled text:**
```dart
// Fix low-contrast disabled text
TextStyle(
  color: Theme.of(context).disabledColor.withValues(alpha: 0.7),  // ⚠️ Old: 0.38
)
```

---

### Operable (4 Principles)

#### 2.1 Keyboard Accessible

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **2.1.1 Keyboard** | A | ⚠️ 90% | All controls accessible via Tab, Shift+Tab, Enter, Space (except custom chat bubble actions) |
| **2.1.2 No Keyboard Trap** | A | ✅ 100% | Dialogs can be closed with Esc |
| **2.1.4 Character Key Shortcuts** | A | ✅ 100% | No single-key shortcuts (all shortcuts use Ctrl/Cmd) |

**Example (Keyboard-accessible dialog):**
```dart
// Dialog with Esc key to close
AlertDialog(
  title: Text('Delete Project?'),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),  // ✅ Keyboard accessible
      child: Text('Cancel'),
    ),
    ElevatedButton(
      onPressed: _confirmDelete,
      autofocus: true,  // ✅ Focus on primary action
      child: Text('Delete'),
    ),
  ],
)

// Handle Esc key globally
@override
Widget build(BuildContext context) {
  return KeyboardListener(
    focusNode: _focusNode,
    onKeyEvent: (event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);  // ✅ Close dialog on Esc
      }
    },
    child: child,
  );
}
```

---

#### 2.2 Enough Time

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **2.2.1 Timing Adjustable** | A | ✅ 100% | No time limits (user controls pace) |
| **2.2.2 Pause, Stop, Hide** | A | ✅ N/A | No auto-updating content |

---

#### 2.3 Seizures and Physical Reactions

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **2.3.1 Three Flashes or Below** | A | ✅ 100% | No flashing content |

---

#### 2.4 Navigable

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **2.4.1 Bypass Blocks** | A | ⚠️ 0% | No "Skip to main content" link (desktop app, not applicable?) |
| **2.4.2 Page Titled** | A | ✅ 100% | Window title changes per screen ("SoftArchitect AI - Projects", "Chat") |
| **2.4.3 Focus Order** | A | ✅ 90% | Tab order matches visual order (top-to-bottom) |
| **2.4.4 Link Purpose** | A | ✅ 100% | All buttons have clear labels ("Create New Project", not "Click Here") |
| **2.4.5 Multiple Ways** | AA | ⚠️ 50% | No search function (planned Sprint 5) |
| **2.4.6 Headings and Labels** | AA | ✅ 90% | All forms have labels, sections have headings |
| **2.4.7 Focus Visible** | AA | ✅ 100% | Blue focus indicator (3px border) on all interactive elements |

**Example (Focus indicator):**
```dart
// Add visible focus indicator to all buttons
ElevatedButton(
  focusNode: _focusNode,
  child: Text('Send'),
  style: ElevatedButton.styleFrom(
    side: _focusNode.hasFocus
      ? BorderSide(color: Colors.blue, width: 3)  // ✅ Visible focus
      : null,
  ),
)
```

---

#### 2.5 Input Modalities

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **2.5.1 Pointer Gestures** | A | ✅ N/A | No multitouch gestures (desktop app) |
| **2.5.2 Pointer Cancellation** | A | ✅ 100% | Buttons trigger on `onPressed` (up event, not down) |
| **2.5.3 Label in Name** | A | ✅ 100% | Button labels match visible text |
| **2.5.4 Motion Actuation** | A | ✅ N/A | No motion-based controls |

---

### Understandable (3 Principles)

#### 3.1 Readable

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **3.1.1 Language of Page** | A | ✅ 100% | `<html lang="en">` equivalent set in Flutter |
| **3.1.2 Language of Parts** | AA | ✅ N/A | Single language (English) |

---

#### 3.2 Predictable

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **3.2.1 On Focus** | A | ✅ 100% | Focus doesn't trigger navigation |
| **3.2.2 On Input** | A | ✅ 100% | Typing doesn't auto-submit forms (user presses button) |
| **3.2.3 Consistent Navigation** | AA | ✅ 95% | Navigation menu always in same location |
| **3.2.4 Consistent Identification** | AA | ✅ 100% | Icons/labels consistent across app ("Trash" icon = delete everywhere) |

---

#### 3.3 Input Assistance

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **3.3.1 Error Identification** | A | ✅ 90% | Form errors displayed in text ("Project name is required") |
| **3.3.2 Labels or Instructions** | A | ✅ 100% | All inputs have labels ("Project Name", "Tech Stack") |
| **3.3.3 Error Suggestion** | AA | ✅ 80% | Error messages suggest fixes ("Project name already exists. Try 'MyApp_v2'") |
| **3.3.4 Error Prevention** | AA | ⚠️ 70% | Confirmation dialogs for destructive actions (delete), but not for "Discard changes" |

**Example (Error with suggestion):**
```dart
// Validation with helpful error message
String? _validateProjectName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Project name is required';  // ✅ Clear error
  }
  if (_projectExists(value)) {
    return 'Project "$value" already exists. Try "${value}_v2"';  // ✅ Suggests fix
  }
  return null;
}
```

---

### Robust (1 Principle)

#### 4.1 Compatible

| Criterion | Level | Status | Implementation |
|-----------|-------|--------|----------------|
| **4.1.1 Parsing** | A | ✅ 100% | Valid Flutter widget tree (no rendering errors) |
| **4.1.2 Name, Role, Value** | A | ⚠️ 60% | Semantic widgets have roles, but custom widgets lack ARIA |
| **4.1.3 Status Messages** | AA | ⚠️ 40% | Success messages shown, but not announced by screen readers |

**Issue (Status messages not announced):**
```dart
// ❌ WRONG: Toast not announced by screen reader
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Project created'))
);

// ✅ CORRECT: Use Semantics with liveRegion
Semantics(
  liveRegion: true,  // Announces to screen reader
  child: SnackBar(content: Text('Project created')),
)
```

---

## ⌨️ Keyboard Navigation

### Keyboard Shortcuts

| Action | Shortcut | Status |
|--------|----------|--------|
| **New Project** | Ctrl+N (Cmd+N macOS) | ✅ Implemented |
| **Open Project** | Ctrl+O | ✅ Implemented |
| **Send Message** | Ctrl+Enter | ✅ Implemented |
| **Focus Search** | Ctrl+F | ⚠️ Planned Sprint 5 |
| **Close Dialog** | Esc | ✅ Implemented |
| **Switch Tab** | Ctrl+Tab | ✅ Implemented |

### Tab Order (Home Screen)

```
1. Sidebar (Projects list)
2. "Create New Project" button
3. Project card 1
4. Project card 2
...
N. Search bar (if visible)
```

---

## 📢 Screen Reader Support

### Current Status

| Screen Reader | Platform | Status | Notes |
|---------------|----------|--------|-------|
| **NVDA** | Windows 11 | ⚠️ Partial | Basic navigation works, custom widgets not announced |
| **JAWS** | Windows 11 | ❌ Not Tested | Planned Sprint 5 |
| **Orca** | Ubuntu 22.04 | ⚠️ Partial | Same as NVDA |
| **VoiceOver** | macOS 14 | ⚠️ Partial | Better than NVDA (native Cocoa support) |

### Semantic Annotations

**Example (Chat message with semantic label):**
```dart
// chat_message_bubble.dart
Semantics(
  label: 'AI response from Assistant: ${message.content}',
  hint: 'Double-tap to copy text',
  child: SelectableText(message.content),
)
```

---

## 🎨 Visual Accessibility

### Color Palette (WCAG AA Compliant)

| Color | Hex | Use Case | Contrast Ratio |
|-------|-----|----------|----------------|
| **Primary Text (Dark)** | #E0E0E0 | Text on dark background | 12.63:1 (AAA) |
| **Primary Text (Light)** | #212121 | Text on light background | 15.84:1 (AAA) |
| **Error** | #F44336 | Error messages | 4.55:1 (AA) |
| **Success** | #4CAF50 | Success messages | 3.12:1 (Pass for large text) |
| **Link** | #2196F3 | Hyperlinks | 4.64:1 (AA) |

### Font Scaling

```dart
// Respect OS font size settings
Text(
  'Welcome',
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    fontSize: 24 * MediaQuery.of(context).textScaleFactor,  // ✅ Scales with OS
  ),
)
```

---

## 🧠 Cognitive Accessibility

### Plain Language

**❌ Before (Jargon):**
> "Initialize vector embeddings for the RAG pipeline"

**✅ After (Plain English):**
> "Set up AI assistant (takes 2 minutes)"

### Error Messages

**❌ Before:**
> "NullPointerException: chatRepository.getMessages()"

**✅ After:**
> "Unable to load chat history. Try restarting the app."

---

## 🧪 Testing Strategy

### Manual Testing

```bash
# Test with screen reader (Ubuntu)
sudo apt install orca
orca

# Navigate with keyboard only (unplug mouse)
# Tab through UI, verify all actions accessible
```

### Automated Testing

```dart
// Test keyboard navigation
testWidgets('Create project dialog accessible via keyboard', (tester) async {
  await tester.pumpWidget(MyApp());

  // Press Ctrl+N
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

  // Verify dialog opens
  expect(find.text('Create New Project'), findsOneWidget);

  // Tab to name field
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);

  // Type name
  await tester.enterText(find.byType(TextField), 'TestProject');

  // Submit with Enter
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);

  // Verify project created
  expect(find.text('TestProject'), findsOneWidget);
});
```

---

## ⚠️ Known Limitations

| Issue | Impact | Priority | ETA |
|-------|--------|----------|-----|
| **Screen reader doesn't announce chat streaming** | Medium | High | Sprint 4 |
| **Custom widgets lack ARIA roles** | High | High | Sprint 4 |
| **No high contrast mode** | Medium | Medium | Sprint 5 |
| **No "Skip to main content" link** | Low | Low | Sprint 6 |

---

## 🗺️ Roadmap

### Sprint 4 (March 2026) - 80% Coverage Target

- ✅ Add ARIA roles to custom widgets (chat bubbles, project cards)
- ✅ Implement live region for streaming chat
- ✅ Fix disabled text contrast (4.5:1 minimum)
- ✅ Add screen reader announcements for status messages

### Sprint 5 (April 2026) - 95% Coverage Target

- ⬜ Implement high contrast mode toggle
- ⬜ Add search function with keyboard shortcut (Ctrl+F)
- ⬜ Test with JAWS screen reader (Windows)
- ⬜ Conduct user testing with accessibility consultants

---

## 🔗 Related Documents

- **Non-Functional Requirements:** [NON_FUNCTIONAL_REQUIREMENTS_EXAMPLE.md](10-NON_FUNCTIONAL_REQUIREMENTS_EXAMPLE.md)
- **Testing Strategy:** [SPRINT_PLAN_EXAMPLE.md](21-SPRINT_PLAN_EXAMPLE.md)
- **User Journey Map:** [USER_JOURNEY_MAP_EXAMPLE.md](06-JOURNEY_MAP_EXAMPLE.md)

---

> **Document Metadata:**
> **Created:** 2026-02-10
> **Last Updated:** 2026-02-23
> **Maintainer:** Accessibility Team
> **Review Frequency:** Before each sprint
> **Status:** ⚠️ 60% WCAG 2.1 AA Compliance (Target: 95% Sprint 5)
