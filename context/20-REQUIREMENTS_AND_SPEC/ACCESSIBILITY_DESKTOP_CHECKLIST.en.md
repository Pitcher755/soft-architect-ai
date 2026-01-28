# ♿ Desktop Accessibility Checklist (A11y)

> **Standard:** WCAG 2.1 Level AA.
> **Context:** Flutter Desktop (Linux/Windows).
> **Philosophy:** "Keyboard First". A development tool must be usable without a mouse.

---

## 1. Keyboard Navigation (Focus Traversal)

The developer (and Agent) must ensure all interactive elements are reachable via `Tab`.

* [ ] **Logical Order:** Focus must move left to right and top to bottom.
    * *Flutter Tip:* Use `FocusTraversalGroup` for complex sections.
* [ ] **Visual Indicator:** Every element with focus must have a visible border or color change.
    * *Rule:* Do not remove the default `FocusNode` without providing an alternative visual.
* [ ] **Keyboard Shortcuts:**
    * `Ctrl + Enter`: Send message in chat.
    * `Esc`: Close modals or dialogs.

---

## 2. Screen Readers (Semantics)

The UI must be "readable" by tools like NVDA (Windows) or Orca (Linux).

* [ ] **Semantic Labeling:** All buttons that are only icons (e.g., "Send") must have `Tooltip` and be wrapped in `Semantics(label: "Send message")`.
* [ ] **Decorative Images:** Illustrations or icons without function must have `Semantics(excludeSemantics: true)`.
* [ ] **Dynamic States:** If the chat is "Thinking...", the reader must announce the state change.

---

## 3. Contrast and Readability (Visual)

* [ ] **Contrast Ratio:** Normal text must have a minimum ratio of 4.5:1 against the background.
    * *Verification:* Use colors from `DESIGN_SYSTEM.md` (already validated).
* [ ] **Text Scaling:** The UI must not break if the user increases the system font size.
    * *Flutter Tip:* Do not use fixed pixel heights for text containers. Use `Flexible` or `Expanded`.

---

## 4. Color Independence

* [ ] **No Color Reliance:** Information is not conveyed only through color (e.g., error states have icons + text).
* [ ] **Color Blind Simulation:** Test with tools like Color Oracle to ensure usability for color blind users.

---

## 5. Motion and Animation

* [ ] **Reduced Motion:** Respect the system setting for reduced motion (disable animations if requested).
* [ ] **Animation Duration:** No animation longer than 5 seconds without pause control.

---

## 6. Automatic Auditing (Dev Workflow)

* [ ] **Linting Rules:** Enable `flutter_lints` with accessibility rules.
* [ ] **Testing:** Include accessibility tests in the test suite.
    * *Example:* Verify that all interactive elements have semantic labels.

---

## 7. Manual Testing Checklist

* [ ] Navigate the entire app using only Tab and Enter.
* [ ] Use screen reader to read all UI elements.
* [ ] Test with high contrast mode enabled.
* [ ] Verify touch targets are at least 44x44px.
* [ ] Test with system font size increased to 200%.