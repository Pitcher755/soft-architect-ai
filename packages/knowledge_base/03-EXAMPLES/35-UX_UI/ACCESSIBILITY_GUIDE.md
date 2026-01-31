# ♿ Accessibility Guide: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Conformidad WCAG AA
> **Estándar:** WCAG 2.1 Level AA (mínimo)
> **Target:** Level AAA donde sea práctico

---

## 📖 Tabla de Contenidos

1. [Accessibility Overview](#accessibility-overview)
2. [Keyboard Navigation](#keyboard-navigation)
3. [Screen Reader Support](#screen-reader-support)
4. [Visual Design](#visual-design)
5. [Testing & Validation](#testing--validation)

---

## Accessibility Overview

### Commitment to Inclusion

```
"SoftArchitect AI should be usable by:
  - Visual impairments (blind, low vision)
  - Hearing impairments (deaf, hard of hearing)
  - Motor impairments (cannot use mouse)
  - Cognitive impairments (dyslexia, ADHD)
  - Temporary impairments (broken arm, migraine)
  - Environmental (noisy office, bright sun)"
```

### Scope

```
Component              Status           Notes
──────────────────────────────────────────────────────
Desktop UI (Flutter)   ✅ WCAG AA       Primary focus
API (FastAPI)          ✅ WCAG AA       Via OpenAPI docs
Documentation          ✅ WCAG AA       Markdown accessible
Ollama Interface       ⚠️ Out of scope  Third-party
```

---

## Keyboard Navigation

### Keyboard Accessibility Standard

**Every function must be accessible without mouse.**

### Navigation Flow

```
┌────────────────────────────────────┐
│  SoftArchitect UI Navigation       │
├────────────────────────────────────┤
│                                    │
│  Tab         → Focus next element  │
│  Shift+Tab   → Focus previous      │
│  Enter       → Activate button     │
│  Space       → Toggle checkbox     │
│  Arrow Keys  → Navigate list       │
│  Esc         → Close dialog        │
│  Alt+H       → Help menu           │
│  Alt+S       → Settings            │
│  Alt+Q       → Search              │
│                                    │
└────────────────────────────────────┘
```

### Tab Order Rules

```
✅ DO:
  - Tab order matches visual left-to-right flow
  - Skip non-interactive elements
  - Focus moves logically (top → bottom)

❌ DON'T:
  - Tab order jumps randomly
  - Trap focus in modal
  - Focus indicator invisible
```

### Implementation (Flutter)

```dart
// GOOD: Semantic focus navigation
FocusableActionDetector(
  actions: {
    ActivateIntent: CallbackAction(
      onInvoke: (intent) => _handleQuery(),
    ),
  },
  child: TextField(
    key: ValueKey('query-input'),
    focusNode: _queryFocusNode,
    accessibleLabel: 'Question input field',
    // ...
  ),
)

// BAD: No semantics
TextField(
  // Missing accessibility attributes
)
```

---

## Screen Reader Support

### Required Screen Reader Support

```
Platform    Screen Reader       Status
────────────────────────────────────────────
Windows     NVDA (free)         ✅ Tested
            JAWS (paid)         ✅ Tested
macOS       VoiceOver (free)    ✅ Tested
Linux       Orca (free)         ✅ Tested
```

### Semantic Labeling

**Every element must have descriptive label.**

```dart
// GOOD: Clear semantics
Semantics(
  label: 'Submit query button',
  enabled: true,
  button: true,
  child: ElevatedButton(
    onPressed: _submit,
    child: Text('Send Query'),
  ),
)

// BAD: No context
Icon(Icons.send)  // What does this do?
```

### Semantic Tree Examples

```
Query Input Area
├─ "Question input field"
│   └─ Value: [user can type here]
├─ "Send button"
│   └─ Action: [submit query]
├─ "Settings button"
│   └─ Action: [open settings]
└─ "Help button"
    └─ Action: [open help]

Response Area
├─ "Response text content"
│   └─ Value: [AI generated response]
├─ "Copy button"
│   └─ Action: [copy to clipboard]
├─ "Save button"
│   └─ Action: [save to knowledge base]
└─ "Feedback section"
    ├─ "Was this helpful?"
    ├─ "Yes button" (action: vote yes)
    └─ "No button" (action: vote no)
```

### Live Regions (Dynamic Content)

```dart
// Announce new content to screen readers
Semantics(
  liveRegion: true,
  label: 'Response area',
  enabled: true,
  child: Container(
    child: Text(aiResponse),
  ),
)
```

---

## Visual Design

### Color Contrast

**WCAG AA Minimum:**
```
Element                 Ratio    Example
────────────────────────────────────────────────
Text (normal)           4.5:1   Black (#000000) on white (#FFFFFF)
Text (large 18pt+)      3:1     Dark gray (#424242) on light gray (#F5F5F5)
UI Components           3:1     Button border visibility
Focus Indicator         3:1     Visible focus ring

CHECK: Use contrast checker → https://webaim.org/resources/contrastchecker/
```

### Text Sizing & Spacing

```
Property         Requirement      SoftArchitect Implementation
─────────────────────────────────────────────────────────────────
Min font size    12pt             ✅ Base 14pt (readable)
Line spacing     1.5x             ✅ 1.5 for body text
Letter spacing   0.12em           ✅ Increased for readability
Text alignment   Left-aligned     ✅ Left-aligned main content
```

### Focus Indicators

```
✅ GOOD:
  - Visible focus ring (2px, high contrast)
  - Color distinct from content
  - Visible in light AND dark modes
  - No flickering

❌ BAD:
  - Outline color: rgba(0,0,0,0.1)  [too faint]
  - No focus indicator at all
  - Focus ring removed with outline: none
  - Flashing indicator (seizure risk)
```

### Color Independence

**Don't rely on color alone to convey information.**

```
✅ GOOD:
  Status indicator:
    ✅ Green circle + "✓ Indexed"
    ❌ Red circle + "✗ Error"

❌ BAD:
  Status indicator:
    🟢 [green circle only - what does it mean?]
    🔴 [red circle only]
```

---

## Testing & Validation

### Automated Testing

```bash
# 1. Flutter Semantics Analyzer
flutter analyze

# 2. Accessibility Scanner
flutter pub global activate accessibility_testing

# 3. Manual keyboard test
[Use Tab/Shift+Tab to navigate entire app]

# 4. Screen reader test
# Windows: Enable Narrator
#   Settings → Ease of Access → Narrator
# macOS: Command + F5 (VoiceOver)
# Linux: Alt + Super + S (Orca)
```

### Manual Testing Checklist

```
Keyboard Navigation:
  [ ] All interactive elements focusable
  [ ] Tab order logical
  [ ] Keyboard shortcuts work
  [ ] No focus traps
  [ ] Focus visible at all times

Screen Reader (NVDA/JAWS/VoiceOver):
  [ ] All text readable
  [ ] Images have alt text
  [ ] Buttons labeled correctly
  [ ] Forms properly associated (label ↔ input)
  [ ] Dynamic content announced (ARIA live regions)
  [ ] Status messages announced

Visual Design:
  [ ] Contrast ratio 4.5:1 (minimum)
  [ ] Text resizable (up to 200%)
  [ ] No information by color alone
  [ ] Focus indicator visible
  [ ] Animations don't cause seizures

Content:
  [ ] Language specified (HTML lang attribute)
  [ ] Reading order logical
  [ ] Headings hierarchical (h1 → h2 → h3)
  [ ] Lists properly marked
  [ ] Code properly formatted
```

### Test Results Template

```markdown
## Accessibility Test Report

Date: 2026-01-30
Tester: [Name]
Tools: NVDA 2025.1, Flutter 3.10, WebAIM Contrast

### Results

| Component | Test | Result | Notes |
|:---|:---|:---:|:---|
| Query Input | Keyboard focus | ✅ PASS | Clear focus ring |
| Send Button | Semantic label | ✅ PASS | "Submit Query" |
| Response Area | Live region | ✅ PASS | Announced to screen reader |
| Settings | Contrast | ✅ PASS | 5.2:1 ratio |
| Error Message | Color only | ❌ FAIL | Fix: add text label |

### Issues Found

1. **Error message color-only (Priority: HIGH)**
   - Location: Error toast notification
   - Impact: Colorblind users cannot identify error
   - Fix: Add text icon or label

### Sign-off

[ ] Passed WCAG AA audit
[ ] Ready for production
```

---

## Inclusive Language

### Guidelines

```
Avoid                          Use Instead
────────────────────────────────────────────────────────
"Blind" (negative tone)        "Visually impaired"
"Deaf and dumb"                "Deaf"
"Handicapped"                  "Person with disability"
"Normal" (implies others not)   "Typical" or "without disability"
"Suffer from" disorder          "Person with" disorder
"Man-hours"                     "Person-hours"
```

### Documentation Examples

```
✅ GOOD:
"SoftArchitect AI supports users with visual, hearing, and motor impairments."

❌ BAD:
"Crippled users may have trouble using this feature."
```

---

## Accessibility Roadmap

### Phase 1 (MVP - Now)
```
✅ Keyboard navigation fully working
✅ Screen reader compatible
✅ WCAG AA contrast compliance
✅ Focus indicators visible
```

### Phase 2 (Future)
```
⏳ Voice input/output
⏳ Gesture customization
⏳ High contrast mode toggle
⏳ Reduced motion option
```

### Phase 3 (Long-term)
```
📅 WCAG AAA compliance
📅 Multi-language speech support
📅 Cognitive load reduction features
📅 Eye tracking support
```

---

## Resources & Standards

### Standards

```
WCAG 2.1: https://www.w3.org/WAI/WCAG21/quickref/
Section 508: https://www.section508.gov/
ARIA 1.2: https://www.w3.org/TR/wai-aria-1.2/
```

### Testing Tools

```
Automated:
  - axe DevTools: https://www.deque.com/axe/devtools/
  - WebAIM Contrast: https://webaim.org/resources/contrastchecker/
  - Flutter Semantics: pub.dev/packages/semantics_testing

Manual:
  - NVDA (Windows): https://www.nvaccess.org/
  - JAWS (Windows): https://www.freedomscientific.com/
  - VoiceOver (macOS): Built-in
  - Orca (Linux): Built-in
```

---

**Accessibility Guide** ensures SoftArchitect AI is usable by everyone, regardless of ability. ♿ = Everyone wins.
