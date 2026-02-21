# ♿ Accessibility Guidelines (a11y)

Accessibility standard for **{{PROJECT_NAME}}**.
**Target Level:** WCAG 2.1 Level {{WCAG_LEVEL}} (AA / AAA).

## 1. Contrast and Color
* **Normal Text:** Minimum ratio 4.5:1.
* **Large Text:** Minimum ratio 3:1.
* **Semantics:** Do not use color as the only error indicator (use icons + text).

## 2. Screen Readers
* **Images:** All must have `alt text` or be marked as decorative.
* **Labels:** All Inputs must have `label` or `aria-label`.
* **Focus:** Tab order should be logical (Left -> Right, Top -> Bottom).

## 3. Interaction (Keyboard/Gestures)
* **Focus Visible:** The active element should always have a clear visual border.
* **Touch Target:** Minimum {{TOUCH_TARGET_SIZE}}px (e.g., 44px) for fingers on mobile.
* **Keyboard Navigation:** All buttons and links must be accessible without mouse.

## 4. Accessibility Testing
* **Tools:** Lighthouse / Axe / WAVE.
* **Frequency:** At least once per sprint.
* **Acceptance Criteria:** 0 critical errors before release.

## 5. Special Documentation
* **Keyboard Shortcuts:** List all available shortcuts.
* **High Contrast Mode:** Available for users with low vision.
