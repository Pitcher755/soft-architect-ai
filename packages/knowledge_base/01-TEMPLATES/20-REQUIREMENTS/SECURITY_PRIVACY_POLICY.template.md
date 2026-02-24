# 🔒 Security & Privacy Policy

<!-- TEMPLATE GUIDE: This document defines HOW the system protects data and users.
     - Security = Prevent attacks (authentication, encryption, input validation)
     - Privacy = Respect user data (GDPR, minimal collection, right to delete)
     Generation Order: 6/24 | Phase: 2-Requirements | Duration: ~45 mins
     Prerequisites: REQUIREMENTS_MASTER.md (requirements defined)
     Remove this guide before committing. -->

> **Classification:** {{DATA_CLASSIFICATION}}  <!-- Public, Internal, Confidential, Restricted -->
> **Owner:** {{SECURITY_OFFICER}}
> **Last Review:** {{DATE}}
> **Next Review:** {{NEXT_REVIEW_DATE}}

---

## 📖 Table of Contents

- [Security Principles](#security-principles)
- [Authentication & Authorization](#authentication--authorization)
- [Data Protection](#data-protection)
- [Input Validation](#input-validation)
- [Secrets Management](#secrets-management)
- [Privacy Policy](#privacy-policy)
- [Incident Response](#incident-response)

---

## 🛡️ Security Principles

**Core Philosophy:**

1. **Defense in Depth** - Multiple security layers (no single point of failure)
2. **Least Privilege** - Minimum access required (users, services, databases)
3. **Zero Trust** - Verify everything (never assume trusted network)
4. **Privacy by Design** - Security + privacy from day 1 (not bolted on later)

---

## 🔑 Authentication & Authorization

### Authentication Standard

**Method:** {{AUTH_METHOD}}
<!-- e.g., "OAuth 2.0 + JWT" OR "Session-based with Redis" -->

**Password Requirements:**

| Rule | Requirement | Enforcement |
|------|-------------|-------------|
| **Length** | ≥{{MIN_PASSWORD_LENGTH}} characters | Backend validation |
| **Complexity** | 1 uppercase, 1 number, 1 symbol | Regex check |
| **Hashing** | {{PASSWORD_HASH_ALGO}} | Argon2id / bcrypt |
| **Salt** | Unique per user | Auto-generated |

<!-- EXAMPLE:
| Length | ≥12 characters | Backend ValidationError |
| Complexity | 1 upper, 1 number, 1 special | Regex: ^(?=.*[A-Z])... |
| Hashing | Argon2id | argon2-cffi library |
-->

**Multi-Factor Authentication (MFA):**

Status: {{MFA_STATUS}}  <!-- e.g., "Optional (opt-in)" OR "Mandatory for admins" -->
Method: {{MFA_METHOD}}  <!-- e.g., "TOTP (Google Authenticator, Authy)" -->

---

### Authorization Model

**Approach:** {{AUTHZ_MODEL}}
<!-- e.g., "RBAC (Role-Based)" OR "ABAC (Attribute-Based)" -->

**Roles:**

| Role | Permissions | Example |
|------|-------------|---------|
| {{ROLE_1}} | {{ROLE_1_PERMS}} | {{ROLE_1_EXAMPLE}} |
| {{ROLE_2}} | {{ROLE_2_PERMS}} | {{ROLE_2_EXAMPLE}} |

<!-- EXAMPLE:
| Admin | Full access (create, read, update, delete all) | CTO, Security Officer |
| Developer | Read own projects, create docs | Team members |
| Viewer | Read-only (no modifications) | Stakeholders, auditors |
-->

---

## 🔐 Data Protection

### Encryption

**In Transit:**

- **Protocol:** TLS 1.3 (minimum TLS 1.2)
- **Cipher Suites:** AES-256-GCM, ChaCha20-Poly1305
- **Certificate:** Let's Encrypt (auto-renewal)

**At Rest:**

| Data Type | Encryption | Key Management |
|-----------|------------|----------------|
| {{DATA_1}} | {{DATA_1_ENC}} | {{DATA_1_KEY_MGMT}} |
| {{DATA_2}} | {{DATA_2_ENC}} | {{DATA_2_KEY_MGMT}} |

<!-- EXAMPLE:
| User passwords | Argon2id hash | N/A (one-way hash) |
| Database (PII) | AES-256 | AWS KMS / env var |
| File uploads | AES-256-GCM | Per-user key derived from master |
-->

---

### Data Minimization (GDPR Principle)

**What We Collect:**

| Data Type | Purpose | Legal Basis | Retention |
|-----------|---------|-------------|-----------|
| {{PII_1}} | {{PII_1_PURPOSE}} | {{PII_1_BASIS}} | {{PII_1_RETENTION}} |
| {{PII_2}} | {{PII_2_PURPOSE}} | {{PII_2_BASIS}} | {{PII_2_RETENTION}} |

<!-- EXAMPLE:
| Email address | User authentication | Consent (GDPR Art. 6(1)(a)) | Until account deletion |
| IP address (logs) | Security monitoring | Legitimate interest (Art. 6(1)(f)) | 90 days |
| Project data | Core functionality | Contract (Art. 6(1)(b)) | User-controlled |
-->

**What We DON'T Collect:**

- ❌ {{EXCLUDED_1}}  <!-- e.g., "Credit card numbers (Stripe handles)" -->
- ❌ {{EXCLUDED_2}}  <!-- e.g., "Health data" -->
- ❌ {{EXCLUDED_3}}  <!-- e.g., "Location tracking" -->

---

## 🧪 Input Validation

**OWASP Top 10 Mitigation:**

| Threat | Mitigation | Implementation |
|--------|------------|----------------|
| **SQL Injection** | Parameterized queries | ORM (SQLAlchemy) + no raw SQL |
| **XSS** | Output encoding | Framework auto-escape (Jinja2) |
| **CSRF** | CSRF tokens | FastAPI CSRF middleware |
| **Path Traversal** | Whitelist validation | Reject `../` in file paths |

**Validation Rules:**

```python
# ✅ CORRECT: Strict validation
from pydantic import BaseModel, EmailStr, constr

class UserInput(BaseModel):
    email: EmailStr  # Auto-validates RFC 5322
    username: constr(min_length=3, max_length=20, regex="^[a-zA-Z0-9_]+$")

# ❌ WRONG: Trusting user input
@app.post("/user")
def create_user(data: dict):  # No validation!
    db.execute(f"INSERT INTO users VALUES ('{data['name']}')")  # SQL injection!
```

---

## 🔑 Secrets Management

**Rules:**

1. ❌ **NEVER** commit secrets to Git (`.env` in `.gitignore`)
2. ✅ **ALWAYS** use environment variables
3. ✅ **ALWAYS** rotate secrets quarterly
4. ✅ **ALWAYS** use different secrets per environment (dev, staging, prod)

**Secret Types:**

| Secret | Location | Rotation |
|--------|----------|----------|
| {{SECRET_1}} | {{SECRET_1_LOC}} | {{SECRET_1_ROTATION}} |

<!-- EXAMPLE:
| DATABASE_PASSWORD | .env (dev), AWS Secrets Manager (prod) | Every 90 days |
| JWT_SECRET | .env (dev), Kubernetes Secret (prod) | Every 180 days |
| API_KEY_GROQ | .env (optional, user-provided) | N/A (user manages) |
-->

**Detection:**

```bash
# Pre-commit hook (TruffleHog)
docker run --rm -v "$PWD:/repo" trufflesecurity/trufflehog:latest git file:///repo
```

---

## 🕵️ Privacy Policy

### User Rights (GDPR/CCPA)

| Right | Implementation | API Endpoint |
|-------|----------------|--------------|
| **Access** | Export all user data | `GET /api/user/export` |
| **Rectification** | Update profile | `PUT /api/user/profile` |
| **Erasure** | Delete account + cascade | `DELETE /api/user/account` |
| **Portability** | Download JSON/CSV | `GET /api/user/export?format=json` |
| **Opt-Out** | Disable analytics | `POST /api/user/opt-out` |

**Data Processing:**

- **Controller:** {{COMPANY_NAME}}
- **Processor:** {{PROCESSOR_NAME}}  <!-- e.g., "AWS (cloud hosting)" -->
- **DPA (Data Processing Agreement):** {{DPA_STATUS}}  <!-- e.g., "Signed 2024-01-15" -->

---

### Cookie Policy

| Cookie | Purpose | Expiry | Required? |
|--------|---------|--------|-----------|
| {{COOKIE_1}} | {{COOKIE_1_PURPOSE}} | {{COOKIE_1_EXPIRY}} | {{COOKIE_1_REQUIRED}} |

<!-- EXAMPLE:
| session_id | User authentication | 30 days | ✅ Essential |
| analytics_id | Usage analytics | 12 months | ❌ Optional (consent) |
-->

**Banner Text:**
> "We use cookies to keep you logged in. Analytics cookies are optional. [Manage Preferences](#)"

---

## 🚨 Incident Response

### Security Incident Procedure

**Response Time:**

- **P0 (Critical):** Data breach, system compromise → <30 minutes
- **P1 (High):** Unauthorized access attempt → <2 hours
- **P2 (Medium):** Vulnerability discovered → <24 hours

**Incident Team:**

| Role | Responsible | Contact |
|------|-------------|---------|
| **Incident Commander** | {{IC_NAME}} | {{IC_CONTACT}} |
| **Security Engineer** | {{ENG_NAME}} | {{ENG_CONTACT}} |
| **Legal Counsel** | {{LEGAL_NAME}} | {{LEGAL_CONTACT}} |

**Notification Requirements:**

- **GDPR:** Notify supervisory authority within 72 hours (Art. 33)
- **CCPA:** Notify users "without unreasonable delay"
- **Internal:** Email {{INCIDENT_EMAIL}} immediately

---

### Vulnerability Disclosure

**Responsible Disclosure Policy:**

1. Email: {{SECURITY_EMAIL}}
2. PGP Key: {{PGP_KEY_ID}}
3. Response SLA: <48 hours
4. **Bug Bounty:** {{BOUNTY_STATUS}}  <!-- e.g., "No bounty (MVP)" OR "$100-$5,000" -->

---

## 🔄 Version History

| Version | Date | Changes | Approver |
|---------|------|---------|----------|
| v1.0 | {{DATE}} | Initial policy | {{APPROVER}} |

---

## 🔗 Related Documents

- [COMPLIANCE_MATRIX.md](COMPLIANCE_MATRIX.md) - Regulatory requirements
- [SECURITY_THREAT_MODEL.md](../30-ARCHITECTURE/SECURITY_THREAT_MODEL.md) - Threat analysis
- [ARCH_DECISION_RECORDS.md](../30-ARCHITECTURE/ARCH_DECISION_RECORDS.md) - Security architecture decisions
