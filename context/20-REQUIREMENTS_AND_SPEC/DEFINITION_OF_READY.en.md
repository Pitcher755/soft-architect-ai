# 🚦 Definition of Ready (DoR) - Entry Criteria

> **Objective:** Avoid "Garbage In, Garbage Out". Do not start coding until you know exactly what to do.
> **Use:** The Agent must consult this file before accepting a complex code generation prompt.

---

## 1. For User Stories

A User Story is considered **READY** to enter a Sprint only if it meets the INVEST acronym and also has:

1.  **Clear Title:** Format "As a [role], I want [action], so that [benefit]".
2.  **Acceptance Criteria (Gherkin/List):**
    * *Example:* "Given the user writes text, when they press Enter, the message appears in the list."
    * Minimum 3 positive verification criteria and 1 negative (error case).
3.  **Resolved Dependencies:** Does not depend on an API that does not yet exist or is not documented in `API_INTERFACE_CONTRACT.md`.
4.  **Estimation:** Has a t-shirt size (XS, S, M, L) or story points assigned.

---

## 2. For UI / Frontend Tasks

In addition to the above, requires:

* [ ] **Visual Reference:** A wireframe, a validated *Stitch* prompt, or a reference to an existing component in `DESIGN_SYSTEM.md`.
* [ ] **Assets:** Necessary icons or images are in `assets/` or in Figma.
* [ ] **Text (Copy):** Final texts (or i18n keys) are defined.

---

## 3. For Backend / API Tasks

Requires:

* [ ] **Data Contract:** The Request and Response JSON are defined in `API_INTERFACE_CONTRACT.md`.
* [ ] **Error Handling:** Knows what error codes (`ERROR_HANDLING_STANDARD.md`) it can throw.
* [ ] **Data Strategy:** Knows what DB tables or vector collections to read/write.

---

## 4. For Documentation Tasks

Requires:

* [ ] **Audience Defined:** Knows if it's for humans (`doc/`) or AI (`packages/knowledge_base/`).
* [ ] **Format Standards:** Follows `DOCUMENTATION_STANDARDS.md`.
* [ ] **Update Trigger:** Linked to a code change or architectural decision.

---

## 5. General Criteria

* [ ] **No Ambiguities:** All terms are defined or linked to existing documentation.
* [ ] **Testable:** Can be verified through automated tests or manual checks.
* [ ] **Prioritized:** Has a priority level (P1, P2, P3) and fits within Sprint capacity.
* [ ] **Architecturally Aligned:** Does not violate `ARCHITECTURE.md` principles.

---

> "🛑 **Block by DoR:** The task does not meet the *Definition of Ready*. Please specify the form fields and authentication endpoint before generating the code."