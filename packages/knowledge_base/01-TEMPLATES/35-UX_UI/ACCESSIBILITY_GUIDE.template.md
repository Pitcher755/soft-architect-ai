# ♿ Accessibility Guide (WCAG 2.1 AA)

<!-- TEMPLATE GUIDE: This document ensures the app is usable by EVERYONE.
     - WCAG 2.1 Level AA compliance (legal requirement in many countries)
     - Covers: Keyboard nav, screen readers, color contrast, focus management
     Generation Order: 20/24 | Phase: 4-UX/UI | Duration: ~30 mins
     Remove this guide before committing. -->

> **Standard:** {{STANDARD}}  <!-- e.g., WCAG 2.1 AA -->
> **Target Compliance:** {{COMPLIANCE_DATE}}
> **Last Audit:** {{AUDIT_DATE}}
> **Score:** {{SCORE}}  <!-- e.g., "87/100 (Lighthouse)" -->

---

## 📖 Table of Contents

- [WCAG Principles](#wcag-principles)
- [Checklist](#checklist)
- [Implementation](#implementation)
- [Testing](#testing)

---

## 🎯 WCAG Principles (POUR)

| Principle | Meaning | Example |
|-----------|---------|---------|
| **P**erceivable | Information must be presentable in ways users can perceive | Alt text for images, captions for videos |
| **O**perable | UI must be operable with keyboard only | All buttons tab-accessible |
| **U**nderstandable | Information must be understandable | Clear error messages, consistent navigation |
| **R**obust | Content must work with assistive tech | Semantic HTML, ARIA labels |

---

## ✅ Checklist

### 1. Keyboard Navigation

| Requirement | Status | Notes |
|-------------|--------|-------|
| All interactive elements tab-accessible | {{KB_STATUS}} | {{KB_NOTES}} |
| Tab order follows visual flow | {{TAB_STATUS}} | {{TAB_NOTES}} |
| Focus indicator visible (3px outline) | {{FOCUS_STATUS}} | {{FOCUS_NOTES}} |
| No keyboard traps | {{TRAP_STATUS}} | {{TRAP_NOTES}} |
| Skip navigation link | {{SKIP_STATUS}} | {{SKIP_NOTES}} |

<!-- EXAMPLE:
| All interactive elements tab-accessible | ✅ Compliant | All buttons, links, inputs focusable |
| Tab order follows visual flow | ✅ Compliant | Left-to-right, top-to-bottom |
| Focus indicator visible | ✅ Compliant | Blue 3px outline |
| No keyboard traps | ✅ Compliant | Modal ESC key closes |
| Skip navigation | 🚧 In Progress | "Skip to main content" link |
-->

---

### 2. Screen Reader Support

| Requirement | Status | Notes |
|-------------|--------|-------|
| Semantic HTML (`<nav>`, `<main>`, `<button>`) | {{SEMANTIC_STATUS}} | {{SEMANTIC_NOTES}} |
| ARIA labels on icon buttons | {{ARIA_STATUS}} | {{ARIA_NOTES}} |
| Form labels properly associated | {{LABEL_STATUS}} | {{LABEL_NOTES}} |
| Dynamic content announces | {{DYNAMIC_STATUS}} | {{DYNAMIC_NOTES}} |
| Heading hierarchy (H1 → H2 → H3) | {{HEADING_STATUS}} | {{HEADING_NOTES}} |

<!-- EXAMPLE:
| Semantic HTML | ✅ Compliant | <button>, <nav>, <main>, <aside> |
| ARIA labels | ✅ Compliant | aria-label="Close dialog" on X button |
| Form labels | ✅ Compliant | <label for="email">Email</label> |
| Dynamic content | 🚧 In Progress | aria-live="polite" on notifications |
| Heading hierarchy | ✅ Compliant | H1 page title, H2 sections, H3 subsections |
-->

---

### 3. Color Contrast (WCAG AA)

| Element | Required Ratio | Current | Status |
|---------|----------------|---------|--------|
| Normal text (<18pt) | 4.5:1 | {{TEXT_CONTRAST}} | {{TEXT_STATUS}} |
| Large text (≥18pt) | 3:1 | {{LARGE_CONTRAST}} | {{LARGE_STATUS}} |
| UI components (buttons, inputs) | 3:1 | {{UI_CONTRAST}} | {{UI_STATUS}} |

**Tool:** [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

<!-- EXAMPLE:
| Normal text | 4.5:1 | 7.2:1 ✅ | Pass (black on white) |
| Large text | 3:1 | 4.8:1 ✅ | Pass (dark gray on light bg) |
| UI components | 3:1 | 3.5:1 ✅ | Pass (button borders) |
-->

---

### 4. Forms

| Requirement | Status | Notes |
|-------------|--------|-------|
| Labels visible and descriptive | {{FORM_LABEL_STATUS}} | {{FORM_LABEL_NOTES}} |
| Error messages clear | {{ERROR_STATUS}} | {{ERROR_NOTES}} |
| Required fields marked (`*`) | {{REQUIRED_STATUS}} | {{REQUIRED_NOTES}} |
| Inline validation | {{INLINE_STATUS}} | {{INLINE_NOTES}} |

<!-- EXAMPLE:
| Labels visible | ✅ Compliant | "Email address" label above input |
| Error messages | ✅ Compliant | "Email must contain @" |
| Required fields | ✅ Compliant | "Email *" with aria-required="true" |
| Inline validation | ✅ Compliant | Red border + error text below input |
-->

---

### 5. Images & Media

| Requirement | Status | Notes |
|-------------|--------|-------|
| Alt text on images | {{ALT_STATUS}} | {{ALT_NOTES}} |
| Decorative images marked | {{DECORATIVE_STATUS}} | {{DECORATIVE_NOTES}} |
| Video captions | {{CAPTIONS_STATUS}} | {{CAPTIONS_NOTES}} |

<!-- EXAMPLE:
| Alt text | ✅ Compliant | <img alt="Logo of SoftArchitect AI"> |
| Decorative images | ✅ Compliant | alt="" (empty alt for decorative) |
| Video captions | N/A | No video content in MVP |
-->

---

## 🛠️ Implementation

### Keyboard Navigation Example

```dart
// ✅ CORRECT: All interactive elements focusable
ElevatedButton(
  onPressed: () => _handleClick(),
  child: Text('Submit'),
  // Auto-focusable, ESC/Enter handled by Flutter
)

// ❌ WRONG: GestureDetector not keyboard-accessible
GestureDetector(
  onTap: () => _handleClick(),  // No keyboard support!
  child: Text('Submit'),
)
```

---

### Screen Reader Support

```dart
// ✅ CORRECT: Semantic label for icon button
Semantics(
  label: 'Close dialog',
  button: true,
  child: IconButton(
    icon: Icon(Icons.close),
    onPressed: () => Navigator.pop(context),
  ),
)

// ❌ WRONG: Icon button with no label
IconButton(
  icon: Icon(Icons.close),  // Screen reader reads "button"
  onPressed: () => Navigator.pop(context),
)
```

---

### Focus Management (Modal)

```dart
// ✅ CORRECT: Trap focus inside modal
class AccessibleDialog extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      child: AlertDialog(
        title: Text('Confirm Action'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _confirmAction(),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🧪 Testing

### Automated Tools

| Tool | Purpose | Command |
|------|---------|---------|
| **Lighthouse** | Overall accessibility score | Chrome DevTools → Lighthouse → Accessibility |
| **axe DevTools** | Detailed WCAG violations | Chrome Extension |
| **WAVE** | Visual feedback | https://wave.webaim.org |

---

### Manual Testing

**Keyboard-Only Test:**

1. Disconnect mouse
2. Navigate entire app with `Tab`, `Shift+Tab`, `Enter`, `ESC`
3. Verify all features accessible

**Screen Reader Test:**

| OS | Screen Reader | Command |
|----|---------------|---------|
| macOS | VoiceOver | `Cmd+F5` |
| Linux | Orca | `Super+Alt+S` |
| Windows | NVDA | Download from nvaccess.org |

---

## 📊 Compliance Report

**Last Audit:** {{AUDIT_DATE}}
**Auditor:** {{AUDITOR}}
**Score:** {{SCORE}}/100

**Violations Found:** {{VIOLATIONS_COUNT}}

| Issue | Severity | Status |
|-------|----------|--------|
| {{ISSUE_1}} | {{SEVERITY_1}} | {{STATUS_1}} |

<!-- EXAMPLE:
| Missing alt text on 3 images | Medium | ✅ Fixed |
| Low contrast on "Learn More" link | High | ✅ Fixed |
| Modal focus trap not implemented | Critical | 🚧 In Progress |
-->

---

## 🔗 Related Documents

- [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) - Color palette with contrast ratios
- [UI_WIREFRAMES_FLOW.md](UI_WIREFRAMES_FLOW.md) - Keyboard navigation flows
