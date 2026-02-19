# 🏛️ Compliance & Legal Matrix

Regulatory compliance table for **{{PROJECT_NAME}}**.
This matrix must be reviewed before each Major Release (v1.0, v2.0).

## 1. Licensing and Intellectual Property

| Component | Chosen License | Attribution Requirement | Status |
| :--- | :--- | :--- | :--- |
| **Source Code** | {{LICENSE_TYPE}} (E.g.: MIT / Proprietary) | N/A | 🟢 Defined |
| **3rd Party Libraries** | Automatic check | Do not use viral licenses (GPL) in proprietary code | 🟡 Pending |
| **Assets (Images/Fonts)** | Commercial / Royalty Free | List authors in `CREDITS.md` | 🟡 Pending |

## 2. Legal Regulations (Regulatory)

| Regulation | Applies | Implementation Measure | Status |
| :--- | :--- | :--- | :--- |
| **GDPR (Europe)** | {{GDPR_APPLIES}} | Cookie Banner + Deletion Endpoint | 🔴 Todo |
| **CCPA (California)** | {{CCPA_APPLIES}} | "Do Not Sell My Info" option | ⚪ N/A |
| **PCI-DSS (Payments)** | {{PCI_APPLIES}} | Fully delegated to gateway (Stripe/PayPal) | 🟢 OK |
| **HIPAA (Healthcare)** | {{HIPAA_APPLIES}} | E2E Encryption and Audit Logs | ⚪ N/A |

## 3. Internal Quality Standards

| Control | Acceptance Criteria | Validation Tool |
| :--- | :--- | :--- |
| **Code Quality** | 0 Critical Errors / 0 High Vulnerabilities | SonarQube / Ruff / Bandit |
| **Accessibility** | WCAG 2.1 AA Compliance | Lighthouse / Accessibility Scanner |
| **Performance** | API Response < {{MAX_LATENCY_MS}}ms (p95) | Load Testing (k6 / Locust) |

---
**Approval Signatures:**
* **Legal:** __________________
* **CTO:** __________________
