# 🎨 Design System

<!-- TEMPLATE GUIDE: This document is your visual language (colors, typography, spacing, components).
     - Ensures consistency across all screens
     - Speeds up development (reusable components)
     Generation Order: 14/24 | Phase: 4-UX/UI | Prerequisites: ARCH_DECISION_RECORDS.md
     Duration: ~35 mins
     Remove this guide before committing. -->

> **Design System:** {{SYSTEM_NAME}}
> **Version:** {{VERSION}}
> **Figma:** {{FIGMA_URL}}
> **Last Updated:** {{DATE}}

---

## 📖 Table of Contents

- [Color Palette](#color-palette)
- [Typography](#typography)
- [Spacing & Layout](#spacing--layout)
- [Components](#components)

---

## 🎨 Color Palette

### Primary Colors

| Name | Hex | RGB | Usage | Contrast Ratio |
|------|-----|-----|-------|----------------|
| {{COLOR_1}} | {{HEX_1}} | {{RGB_1}} | {{USAGE_1}} | {{CONTRAST_1}} |
| {{COLOR_2}} | {{HEX_2}} | {{RGB_2}} | {{USAGE_2}} | {{CONTRAST_2}} |

<!-- EXAMPLE:

| Name | Hex | RGB | Usage | Contrast Ratio |
|------|-----|-----|-------|----------------|
| Primary | #1976D2 | 25,118,210 | Buttons, links | 4.8:1 (AA ✅) |
| Primary Dark | #1565C0 | 21,101,192 | Hover states | 6.2:1 (AAA ✅) |
| Primary Light | #42A5F5 | 66,165,245 | Backgrounds | 3.1:1 (AA Large ✅) |
-->

---

### Secondary Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| {{COLOR_3}} | {{HEX_3}} | {{RGB_3}} | {{USAGE_3}} |

<!-- EXAMPLE:

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Success | #4CAF50 | 76,175,80 | Success messages, checkmarks |
| Warning | #FF9800 | 255,152,0 | Warnings, caution states |
| Error | #F44336 | 244,67,54 | Errors, delete actions |
| Info | #2196F3 | 33,150,243 | Info messages, tooltips |
-->

---

### Neutral Colors

| Name | Hex | Usage |
|------|-----|-------|
| {{NEUTRAL_1}} | {{NEUTRAL_HEX_1}} | {{NEUTRAL_USAGE_1}} |

<!-- EXAMPLE:

| Name | Hex | Usage |
|------|-----|-------|
| Background | #FFFFFF | Page background |
| Surface | #F5F5F5 | Card backgrounds |
| Text Primary | #212121 | Main text (7.2:1 contrast) |
| Text Secondary | #757575 | Subtitles, captions (4.6:1 contrast) |
| Divider | #E0E0E0 | Borders, separators |
-->

---

## 🔤 Typography

### Font Families

| Type | Font | Fallback | Usage |
|------|------|----------|-------|
| {{TYPE_1}} | {{FONT_1}} | {{FALLBACK_1}} | {{FONT_USAGE_1}} |

<!-- EXAMPLE:

| Type | Font | Fallback | Usage |
|------|------|----------|-------|
| Headings | Inter | system-ui, sans-serif | H1, H2, H3 |
| Body | Roboto | system-ui, sans-serif | Paragraphs, labels |
| Monospace | Fira Code | Courier, monospace | Code blocks, terminal |
-->

---

### Font Scales

| Level | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| H1 | {{H1_SIZE}} | {{H1_WEIGHT}} | {{H1_LINE}} | {{H1_USAGE}} |
| H2 | {{H2_SIZE}} | {{H2_WEIGHT}} | {{H2_LINE}} | {{H2_USAGE}} |
| Body | {{BODY_SIZE}} | {{BODY_WEIGHT}} | {{BODY_LINE}} | {{BODY_USAGE}} |

<!-- EXAMPLE:

| Level | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| H1 | 32px | 700 (Bold) | 40px | Page titles |
| H2 | 24px | 600 (Semi-Bold) | 32px | Section headers |
| H3 | 20px | 600 (Semi-Bold) | 28px | Subsection headers |
| Body | 16px | 400 (Regular) | 24px | Paragraphs, descriptions |
| Caption | 14px | 400 (Regular) | 20px | Small text, metadata |
| Button | 14px | 500 (Medium) | 20px | Button labels (uppercase) |
-->

---

## 📏 Spacing & Layout

### Spacing Scale (8px base)

| Name | Value | Usage |
|------|-------|-------|
| {{SPACE_1}} | {{SPACE_VAL_1}} | {{SPACE_USAGE_1}} |

<!-- EXAMPLE:

| Name | Value | Usage |
|------|-------|-------|
| xs | 4px | Icon padding, tight spacing |
| sm | 8px | Between related elements (label + input) |
| md | 16px | Default spacing (cards, sections) |
| lg | 24px | Between sections |
| xl | 32px | Between major page sections |
| 2xl | 48px | Page top/bottom padding |
-->

---

### Grid System

**Layout:** {{LAYOUT_TYPE}}  <!-- e.g., "12-column grid" OR "Flexbox" -->
**Container Max Width:** {{MAX_WIDTH}}  <!-- e.g., "1200px" -->
**Gutter:** {{GUTTER}}  <!-- e.g., "16px" -->

---

## 🧩 Components

### Button

**Primary Button:**

| State | Background | Text Color | Border | Example |
|-------|------------|------------|--------|---------|
| Default | {{BTN_BG}} | {{BTN_TEXT}} | None | [Create Project] |
| Hover | {{BTN_HOVER_BG}} | {{BTN_TEXT}} | None | [Create Project] |
| Disabled | {{BTN_DISABLED_BG}} | {{BTN_DISABLED_TEXT}} | None | [Create Project] |

<!-- EXAMPLE:

| State | Background | Text Color | Border | Preview |
|-------|------------|------------|--------|---------|
| Default | #1976D2 | #FFFFFF | None | 🔵 Create Project |
| Hover | #1565C0 | #FFFFFF | None | 🔵 Create Project (darker) |
| Disabled | #E0E0E0 | #9E9E9E | None | ⚪ Create Project |
-->

**Sizes:**

| Size | Height | Padding | Font Size |
|------|--------|---------|-----------|
| Small | 32px | 8px 16px | 14px |
| Medium | 40px | 12px 24px | 16px |
| Large | 48px | 16px 32px | 18px |

---

### Input Field

| State | Border | Background | Placeholder | Example |
|-------|--------|------------|-------------|---------|
| Default | {{INPUT_BORDER}} | {{INPUT_BG}} | {{INPUT_PLACEHOLDER}} | ___email@example.com___ |
| Focus | {{INPUT_FOCUS_BORDER}} | {{INPUT_BG}} | {{INPUT_PLACEHOLDER}} | ___john@example.com___ |
| Error | {{INPUT_ERROR_BORDER}} | {{INPUT_ERROR_BG}} | - | ___invalid-email___ |

<!-- EXAMPLE:

| State | Border | Background | Placeholder Color | Example |
|-------|--------|------------|-------------------|---------|
| Default | 1px #E0E0E0 | #FFFFFF | #9E9E9E | [           ] |
| Focus | 2px #1976D2 | #FFFFFF | #9E9E9E | [john@...    ] (blue border) |
| Error | 2px #F44336 | #FFEBEE | - | [invalid    ] (red border) |
-->

---

### Card

**Structure:**

```
┌────────────────────────┐
│ [Icon]  Card Title     │ ← Header (H3, 16px padding)
├────────────────────────┤
│ Body text goes here.   │ ← Body (16px padding)
│ Can span multiple      │
│ lines.                 │
├────────────────────────┤
│ [Button 1] [Button 2]  │ ← Actions (right-aligned)
└────────────────────────┘
```

**Styles:**

| Property | Value |
|----------|-------|
| Background | {{CARD_BG}} |
| Border | {{CARD_BORDER}} |
| Border Radius | {{CARD_RADIUS}} |
| Shadow | {{CARD_SHADOW}} |
| Padding | {{CARD_PADDING}} |

<!-- EXAMPLE:

| Property | Value |
|----------|-------|
| Background | #FFFFFF |
| Border | 1px solid #E0E0E0 |
| Border Radius | 8px |
| Shadow | 0 2px 4px rgba(0,0,0,0.1) |
| Padding | 16px |
-->

---

### Modal

**Structure:**

- **Backdrop:** Semi-transparent overlay (#000000, 50% opacity)
- **Dialog:** White card, centered, max-width {{MODAL_MAX_WIDTH}}
- **Close Button:** Top-right, icon button, aria-label="Close"

**Example:**

```dart
AlertDialog(
  title: Text('Confirm Action'),
  content: Text('Are you sure you want to delete this project?'),
  actions: [
    TextButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context)),
    ElevatedButton(child: Text('Delete'), onPressed: () => _confirmDelete()),
  ],
)
```

---

## 🔗 Related Documents

- [ACCESSIBILITY_GUIDE.md](ACCESSIBILITY_GUIDE.md) - Color contrast ratios
- [UI_WIREFRAMES_FLOW.md](UI_WIREFRAMES_FLOW.md) - Component usage in screens
