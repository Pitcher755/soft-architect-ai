# 🏛️ Compliance & Legal Matrix

<!--
════════════════════════════════════════════════════════════════════════════════
📘 TEMPLATE GUIDE: How to Fill Out This Document
════════════════════════════════════════════════════════════════════════════════

PURPOSE:
The Compliance Matrix is YOUR LEGAL SHIELD. It answers:
- What laws/regulations apply to us? (GDPR, CCPA, HIPAA)- Do we comply? (80% ✅ / 20% ⚠️ / 0% ❌)
- What's our plan to reach 100%?

WHEN TO CREATE:
- **Generation Order:** 7/24 (LAST of Requirements Phase)
- **Phase:** 2 - Requirements
- **Prerequisites:** SECURITY_PRIVACY_POLICY.md (security requirements finalized)
- **Duration:** ~35 minutes- Are we compliant? (Status tracking)
- How do we prove it? (Audit trail)

WHY THIS MATTERS:
- Prevents lawsuits (GDPR fines up to €20M or 4% revenue!)
- Protects brand reputation (data breaches = trust lost)
- Enables sales (B2B customers ask "Are you SOC 2 compliant?")
- Unblocks deployments (EU market requires GDPR compliance)

WHEN TO CREATE:
- **Generation Order:** 13/24
- **Phase:** 2 - Requirements
- **Prerequisites:** SECURITY_PRIVACY_POLICY.md, REQUIREMENTS_MASTER.md
- **Duration:** ~40 minutes (initial), review before each major release

INSTRUCTIONS:
1. Check which regulations ACTUALLY apply (don't gold-plate!)
2. For each reg, define HOW you comply (implementation measure)
3. Track compliance status (🔴 Not Started, 🟡 In Progress, 🟢 Compliant)
4. Get legal sign-off BEFORE v1.0 launch
5. Review quarterly (laws change!)
6. Remove TEMPLATE GUIDE before committing

CRITICAL RULES:
❌ NEVER claim compliance without proof (audit logs, tests)
❌ NEVER copy-paste generic compliance (customize to YOUR app)
❌ NEVER ignore applicable regulations ("We'll fix it later")
✅ ALWAYS consult lawyer for high-risk domains (healthcare, finance)
✅ ALWAYS document WHY a regulation doesn't apply
✅ ALWAYS test compliance features (deletion endpoints, data exports)

BEST PRACTICES:
- Start with "Does this reg apply?" checklist
- Link to implementation (e.g., GDPR → data_export_handler.py)
- Add audit evidence (screenshots, test results)
- Update after each major feature (new data collection = review!)

RELATED DOCS:
- SECURITY_PRIVACY_POLICY.md (implements compliance controls)
- DATA_MODEL_SCHEMA.md (shows what PII is stored)
- API_INTERFACE_CONTRACT.md (deletion/export endpoints)
════════════════════════════════════════════════════════════════════════════════
-->

> **Last Updated:** {{DATE}}
> **Owner:** {{COMPLIANCE_OWNER}}  <!-- e.g., Legal Counsel, CTO, Security Officer -->
> **Next Review:** {{NEXT_REVIEW_DATE}}  <!-- e.g., Every 6 months or before major release -->
> **Legal Approval:** {{LEGAL_APPROVAL_STATUS}}  <!-- e.g., "Pending", "Approved 2024-03-15" -->

---

## 📖 Table of Contents

- [Applicability Checklist](#applicability-checklist)
- [License Compliance](#license-compliance)
- [Data Protection Regulations](#data-protection-regulations)
- [Industry-Specific Regulations](#industry-specific-regulations)
- [Quality & Accessibility Standards](#quality--accessibility-standards)
- [Open Source Compliance](#open-source-compliance)
- [Audit Trail](#audit-trail)
- [Compliance Roadmap](#compliance-roadmap)

---

## ✅ Applicability Checklist

**Quick Filter: Which Regulations Apply to Us?**

| Regulation | Applies? | Why / Why Not | Priority |
|------------|----------|---------------|----------|
| **GDPR** (Europe) | {{GDPR_APPLIES}} | {{GDPR_REASON}} | {{GDPR_PRIORITY}} |
| **CCPA** (California) | {{CCPA_APPLIES}} | {{CCPA_REASON}} | {{CCPA_PRIORITY}} |
| **HIPAA** (Healthcare) | {{HIPAA_APPLIES}} | {{HIPAA_REASON}} | {{HIPAA_PRIORITY}} |
| **PCI-DSS** (Payments) | {{PCI_DSS_APPLIES}} | {{PCI_DSS_REASON}} | {{PCI_DSS_PRIORITY}} |
| **SOC 2** (B2B SaaS) | {{SOC2_APPLIES}} | {{SOC2_REASON}} | {{SOC2_PRIORITY}} |
| **COPPA** (Children <13) | {{COPPA_APPLIES}} | {{COPPA_REASON}} | {{COPPA_PRIORITY}} |
| **WCAG 2.1 AA** (Accessibility) | {{WCAG_APPLIES}} | {{WCAG_REASON}} | {{WCAG_PRIORITY}} |

<!-- EXAMPLE:
| GDPR | ✅ Yes | We process EU citizen data (analytics, user accounts) | P0 (Blocker) |
| CCPA | ✅ Yes | California users can register | P1 (High) |
| HIPAA | ❌ No | Not handling protected health information | N/A |
| PCI-DSS | ❌ No | Payments delegated to Stripe (SAQ-A) | N/A |
| SOC 2 | ⏳ Future | Needed for enterprise sales (Roadmap 2025) | P2 (Medium) |
-->

---

## 📜 License Compliance

### Source Code Licensing

| Component | License | Commercial Use | Attribution Required | Viral? |
|-----------|---------|----------------|---------------------|--------|
| **{{PROJECT_NAME}}** | {{PROJECT_LICENSE}} | {{COMMERCIAL_OK}} | {{ATTRIBUTION_REQUIRED}} | {{IS_VIRAL}} |

<!-- EXAMPLE:
| SoftArchitect AI | MIT | ✅ Yes | ✅ Copyright notice | ❌ No (permissive) |
-->

**License Text Location:** `LICENSE` file in repository root

**Copyright Statement:**
```
Copyright {{YEAR}} {{COPYRIGHT_HOLDER}}

Permission is hereby granted...
```

---

### Third-Party Dependencies

**Critical Rules:**
- ✅ Permissive licenses OK: MIT, Apache 2.0, BSD
- ⚠️ Weak copyleft OK (if not linked): LGPL
- ❌ **PROHIBITED:** GPL, AGPL in closed-source products

**Dependency Audit:**

| Dependency | Version | License | Status | Action Required |
|------------|---------|---------|--------|-----------------|
| {{DEP_1}} | {{DEP_1_VER}} | {{DEP_1_LICENSE}} | {{DEP_1_STATUS}} | {{DEP_1_ACTION}} |
| {{DEP_2}} | {{DEP_2_VER}} | {{DEP_2_LICENSE}} | {{DEP_2_STATUS}} | {{DEP_2_ACTION}} |

<!-- EXAMPLE:
| FastAPI | 0.109.0 | MIT | 🟢 OK | None |
| langchain | 0.1.0 | MIT | 🟢 OK | None |
| Qt | 6.5 | LGPL v3 | 🟡 Review | Dynamic linking only (OK) |
| mysql-connector | 8.0 | GPL v2 | 🔴 ISSUE | Replace with pymysql (MIT) |
-->

**Automated Check:**
```bash
# Python
pip-licenses --format=markdown --order=license

# JavaScript
npx license-checker --summary

# Dart/Flutter
flutter pub deps --json | grep "license"
```

---

### Asset Licensing (Images, Fonts, Icons)

| Asset | Source | License | Attribution |
|-------|--------|---------|-------------|
| {{ASSET_1}} | {{ASSET_1_SOURCE}} | {{ASSET_1_LICENSE}} | {{ASSET_1_ATTR}} |

<!-- EXAMPLE:
| Logo | Custom design | Copyright (proprietary) | N/A |
| Inter Font | Google Fonts | SIL OFL 1.1 | Credit in CREDITS.md |
| Heroicons | heroicons.com | MIT | No attribution required |
-->

**Attribution File:** `doc/CREDITS.md`

---

## 🔒 Data Protection Regulations

### GDPR (General Data Protection Regulation) - Europe

**Applicability:** {{GDPR_APPLICABILITY}}
<!-- e.g., "Applies to EU citizens, regardless of server location" -->

**Legal Basis for Processing:**

| Data Type | Legal Basis | Purpose | Retention |
|-----------|-------------|---------|-----------|
| {{DATA_TYPE_1}} | {{LEGAL_BASIS_1}} | {{PURPOSE_1}} | {{RETENTION_1}} |
| {{DATA_TYPE_2}} | {{LEGAL_BASIS_2}} | {{PURPOSE_2}} | {{RETENTION_2}} |

<!-- EXAMPLE:
| Email Address | Consent (Art. 6(1)(a)) | User authentication | Until account deletion |
| IP Address | Legitimate Interest (Art. 6(1)(f)) | Security logs | 90 days |
| Usage Analytics | Consent (cookie banner) | Product improvement | 12 months |
-->

**GDPR Rights Implementation:**

| Right | Article | Implementation | Status |
|-------|---------|----------------|--------|
| **Right to Access** | Art. 15 | `GET /api/user/data-export` | {{ACCESS_STATUS}} |
| **Right to Rectification** | Art. 16 | `PUT /api/user/profile` | {{RECTIFY_STATUS}} |
| **Right to Erasure** | Art. 17 | `DELETE /api/user/account` | {{ERASURE_STATUS}} |
| **Right to Portability** | Art. 20 | Download JSON/CSV | {{PORTABILITY_STATUS}} |
| **Right to Object** | Art. 21 | Opt-out toggles | {{OBJECT_STATUS}} |

<!-- EXAMPLE:
| Right to Access | Art. 15 | GET /api/user/data-export (returns JSON) | 🟢 Implemented |
| Right to Erasure | Art. 17 | DELETE /api/user/account (cascade deletes) | 🟢 Tested |
| Right to Portability | Art. 20 | Download my_data.json (machine-readable) | 🟢 Compliant |
-->

**Data Processing Agreement (DPA):**

| Third Party | Service | Data Shared | DPA Signed? |
|-------------|---------|-------------|-------------|
| {{VENDOR_1}} | {{SERVICE_1}} | {{DATA_SHARED_1}} | {{DPA_STATUS_1}} |

<!-- EXAMPLE:
| AWS | Cloud hosting (S3, RDS) | All user data | ✅ AWS GDPR DPA signed |
| Groq | AI inference (optional) | Prompts (no PII) | ✅ DPA signed 2024-01-15 |
| Stripe | Payment processing | Email, billing address | ✅ Stripe inherits DPA |
-->

**Breach Notification:**

**Response Time:** <72 hours to supervisory authority (Art. 33)
**Responsible:** {{DPO_NAME}}  <!-- Data Protection Officer -->
**Notification Template:** `doc/private/GDPR_BREACH_TEMPLATE.md`

---

### CCPA (California Consumer Privacy Act)

**Applicability:** {{CCPA_APPLICABILITY}}
<!-- e.g., "Applies if ≥50k CA residents OR gross revenue >$25M" -->

**Consumer Rights Implementation:**

| Right | Implementation | Status |
|-------|----------------|--------|
| **Right to Know** | Data export API | {{KNOW_STATUS}} |
| **Right to Delete** | Account deletion | {{DELETE_STATUS}} |
| **Right to Opt-Out (Sale)** | "Do Not Sell My Info" link | {{OPT_OUT_STATUS}} |

<!-- EXAMPLE:
| Right to Know | Same as GDPR data export | 🟢 Compliant |
| Right to Delete | Same as GDPR right to erasure | 🟢 Compliant |
| Right to Opt-Out | Footer link → opt-out toggle | 🟡 In Progress |
-->

**"Do Not Sell My Info" Link:**

Location: `{{WEBSITE_FOOTER}}` + Privacy Policy
Mechanism: {{OPT_OUT_MECHANISM}}  <!-- e.g., "Cookie toggle, synced to backend flag" -->

---

### HIPAA (Health Insurance Portability and Accountability Act)

**Applicability:** {{HIPAA_APPLICABILITY}}
<!-- e.g., "N/A - not handling PHI" OR "Applies - storing patient records" -->

**If Applicable:**

| Requirement | Implementation | Status |
|-------------|----------------|--------|
| **Encryption at Rest** | {{ENCRYPTION_AT_REST}} | {{STATUS_1}} |
| **Encryption in Transit** | TLS 1.3 | {{STATUS_2}} |
| **Audit Logs** | All PHI access logged | {{STATUS_3}} |
| **BAA (Business Associate Agreement)** | Signed with {{VENDOR}} | {{STATUS_4}} |

<!-- EXAMPLE:
| Encryption at Rest | AES-256 on database | 🟢 Enabled |
| Audit Logs | Logs to SIEM (Splunk) | 🟢 Compliant |
| BAA | AWS BAA signed 2024-02-01 | 🟢 Active |
-->

---

## 💳 Industry-Specific Regulations

### PCI-DSS (Payment Card Industry Data Security Standard)

**Applicability:** {{PCI_APPLICABILITY}}
<!-- e.g., "N/A - payments delegated to Stripe (SAQ-A)" -->

**SAQ Type:** {{SAQ_TYPE}}  <!-- A, A-EP, B, C, D -->

**If Handling Cards Directly:**

| Requirement | Implementation | Status |
|-------------|----------------|--------|
| **Never Store CVV** | Validation only, not persisted | {{CVV_STATUS}} |
| **Tokenization** | Use Stripe/PayPal tokens | {{TOKEN_STATUS}} |
| **PCI Scan** | Quarterly vulnerability scan | {{SCAN_STATUS}} |

<!-- EXAMPLE:
| Never Store CVV | CVV field not in database schema | 🟢 Compliant |
| Tokenization | Stripe tokens only (no plaintext cards) | 🟢 Verified |
-->

**Attestation of Compliance (AoC):** {{AOC_DATE}}

---

### SOC 2 (Service Organization Control 2)

**Applicability:** {{SOC2_APPLICABILITY}}
<!-- e.g., "Required for enterprise B2B sales" -->

**Trust Principles:**

| Principle | Controls | Status |
|-----------|----------|--------|
| **Security** | Encryption, access control, monitoring | {{SEC_STATUS}} |
| **Availability** | 99.9% uptime SLA | {{AVAIL_STATUS}} |
| **Confidentiality** | NDA enforcement, data segregation | {{CONF_STATUS}} |

**Audit Status:** {{SOC2_AUDIT_STATUS}}
<!-- e.g., "Type I completed 2024-03-01, Type II in progress" -->

---

## ♿ Quality & Accessibility Standards

### WCAG 2.1 AA (Web Content Accessibility Guidelines)

**Applicability:** {{WCAG_APPLICABILITY}}
<!-- e.g., "Applies to all public-facing web/desktop UI" -->

**Compliance Checklist:**

| Criterion | Level | Implementation | Status |
|-----------|-------|----------------|--------|
| **Keyboard Navigation** | A | All interactive elements tab-accessible | {{KB_STATUS}} |
| **Color Contrast** | AA | 4.5:1 text, 3:1 UI components | {{COLOR_STATUS}} |
| **Screen Reader** | A | ARIA labels on custom widgets | {{SR_STATUS}} |
| **Focus Indicators** | AA | Visible 2px outline on focus | {{FOCUS_STATUS}} |

<!-- EXAMPLE:
| Keyboard Nav | A | All buttons/forms tab-accessible | 🟢 Passed |
| Color Contrast | AA | 4.7:1 on text (Lighthouse tested) | 🟢 Passed |
| Screen Reader | A | Flutter Semantics widget used | 🟡 Manual testing pending |
-->

**Testing Tools:**
- **Automated:** axe DevTools, Lighthouse, WAVE
- **Manual:** Screen reader testing (NVDA, JAWS)

**Audit Report:** `doc/02-SETUP_DEV/ACCESSIBILITY_AUDIT_REPORT.md`

---

## 🔓 Open Source Compliance

### Contribution License Agreement (CLA)

**Approach:** {{CLA_APPROACH}}
<!-- e.g., "Developer Certificate of Origin (DCO)" OR "CLA required" -->

**CLA Text:** {{CLA_LINK}}
<!-- e.g., "https://cla-assistant.io/{{ORG}}/{{REPO}}" -->

### License Compatibility

**Safe Combinations:**

```
MIT + Apache 2.0 → OK
MIT + BSD → OK
Apache 2.0 + LGPL (dynamically linked) → OK

UNSAFE:
MIT + GPL → Cannot redistribute as MIT
Proprietary + GPL → Cannot distribute
```

---

## 📊 Audit Trail

### Compliance Reviews

| Date | Reviewer | Changes | Approval |
|------|----------|---------|----------|
| {{REVIEW_1_DATE}} | {{REVIEWER_1}} | {{CHANGES_1}} | {{APPROVAL_1}} |

<!-- EXAMPLE:
| 2024-01-15 | Legal Counsel (Maria) | Added GDPR data export API | ✅ Approved |
| 2024-02-20 | Security Audit | Fixed WCAG color contrast | ✅ Passed |
-->

### Evidence Repository

| Compliance Item | Evidence Location | Last Verified |
|----------------|-------------------|---------------|
| GDPR data export | `tests/test_data_export.py` | {{LAST_TESTED}} |
| WCAG AA | `doc/ACCESSIBILITY_AUDIT_REPORT.md` | {{LAST_AUDIT}} |
| Dependency licenses | `licenses_report.txt` (CI artifact) | {{LAST_SCAN}} |

---

## 🛣️ Compliance Roadmap

**Upcoming Compliance Work:**

| Milestone | Target Date | Blocking? |
|-----------|-------------|-----------|
| {{MILESTONE_1}} | {{DATE_1}} | {{BLOCKING_1}} |
| {{MILESTONE_2}} | {{DATE_2}} | {{BLOCKING_2}} |

<!-- EXAMPLE:
| Complete SOC 2 Type I | 2024-06-30 | ⚠️ Blocks enterprise sales |
| WCAG AAA (Level 3) | 2024-12-31 | ❌ Nice-to-have |
-->

---

## ✍️ Sign-Off

**Legal Approval:**

- [ ] Legal Counsel reviewed ({{LEGAL_NAME}})
- [ ] Security Officer reviewed ({{SECURITY_NAME}})
- [ ] Privacy Officer reviewed ({{PRIVACY_NAME}})

**Signatures:**

**Legal Counsel:** ___________________ Date: __________
**CTO/Security Officer:** ___________________ Date: __________

---

## 🔗 Related Documents

- [SECURITY_PRIVACY_POLICY.md](SECURITY_PRIVACY_POLICY.md) - Security controls implementation
- [DATA_MODEL_SCHEMA.md](../30-ARCHITECTURE/DATA_MODEL_SCHEMA.md) - What PII is stored
- [API_INTERFACE_CONTRACT.md](../30-ARCHITECTURE/API_INTERFACE_CONTRACT.md) - Deletion/export endpoints
- [TESTING_STRATEGY.md](../40-PLANNING/TESTING_STRATEGY.md) - Compliance testing

---

> **Remember:** Compliance is NOT a checkbox. It's an ongoing process. Review quarterly.
