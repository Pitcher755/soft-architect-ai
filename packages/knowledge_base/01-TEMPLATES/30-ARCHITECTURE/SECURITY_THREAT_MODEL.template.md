# 🛡️ Security Threat Model

<!-- TEMPLATE GUIDE: This document identifies security threats and mitigations.
     - Use STRIDE framework (Spoofing, Tampering, Repudiation, Info Disclosure, DoS, Elevation)
     - For each threat: Describe → Assess risk → Define mitigation
     Generation Order: 12/24 | Phase: 3-Architecture | Prerequisites: PROJECT_STRUCTURE_MAP.md
     Duration: ~40 mins
     Remove this guide before committing. -->

> **System:** {{SYSTEM_NAME}}
> **Classification:** {{CLASSIFICATION}}  <!-- Public, Internal, Confidential -->
> **Last Review:** {{DATE}}
> **Next Review:** {{NEXT_REVIEW}}

---

## 📖 Table of Contents

- [Threat Modeling Approach](#threat-modeling-approach)
- [System Assets](#system-assets)
- [Threat Catalog (STRIDE)](#threat-catalog-stride)
- [Risk Assessment](#risk-assessment)

---

## 🎯 Threat Modeling Approach

**Framework:** {{FRAMEWORK}}  <!-- e.g., STRIDE, PASTA, OCTAVE -->

**STRIDE Categories:**

| Category | Description | Example |
|----------|-------------|---------|
| **S**poofing | Attacker impersonates user/system | Stolen JWT tokens |
| **T**ampering | Attacker modifies data | SQL injection |
| **R**epudiation | Attacker denies action | No audit logs |
| **I**nfo Disclosure | Attacker accesses sensitive data | Database leak |
| **D**enial of Service | Attacker crashes system | Rate limit bypass |
| **E**levation of Privilege | Attacker gains admin access | IDOR vulnerability |

---

## 🏦 System Assets

**What we're protecting:**

| Asset | Value | Loss Impact | Threat Actors |
|-------|-------|-------------|---------------|
| {{ASSET_1}} | {{VALUE_1}} | {{IMPACT_1}} | {{ACTORS_1}} |
| {{ASSET_2}} | {{VALUE_2}} | {{IMPACT_2}} | {{ACTORS_2}} |

<!-- EXAMPLE:

| Asset | Value | Loss Impact | Threat Actors |
|-------|-------|-------------|---------------|
| User credentials | High | Account takeover → reputational damage | Script kiddies, competitors |
| Project source code | Medium | IP theft → competitive loss | Competitors, nation-states |
| RAG knowledge base | Medium | Data poisoning → bad outputs | Malicious users |
| API endpoints | Low | Abuse → infrastructure cost | Bots, scrapers |
-->

---

## 🚨 Threat Catalog (STRIDE)

### S1: Spoofing - Stolen Authentication Tokens

**Threat:** Attacker steals JWT token and impersonates user.

**Attack Vector:**

1. Attacker performs XSS attack on client
2. Steals `localStorage` JWT token
3. Uses token to access API as victim

**Risk:** {{RISK_S1}}  <!-- High, Medium, Low -->
**Likelihood:** {{LIKELIHOOD_S1}}  <!-- High, Medium, Low -->
**Impact:** {{IMPACT_S1}}  <!-- High, Medium, Low -->

**Mitigation:**

- ✅ Use `httpOnly` cookies instead of localStorage
- ✅ Implement CSRF tokens
- ✅ Short token expiry (30 minutes)
- ✅ Refresh token rotation
- ✅ Monitor for suspicious token usage

**Status:** {{STATUS_S1}}  <!-- ✅ Implemented, 🚧 In Progress, ❌ Not Implemented -->

---

### T1: Tampering - SQL Injection

**Threat:** Attacker injects SQL code to modify/delete data.

**Attack Vector:**

```python
# Vulnerable code
user_input = request.args.get("name")
db.execute(f"SELECT * FROM users WHERE name = '{user_input}'")
# Input: "'; DROP TABLE users;--"
```

**Risk:** High
**Likelihood:** Medium
**Impact:** High

**Mitigation:**

- ✅ Use parameterized queries (ORM)
- ✅ Input validation (whitelist)
- ✅ Least privilege database user
- ✅ Web Application Firewall (WAF)

**Status:** ✅ Implemented

---

### R1: Repudiation - No Audit Logs

**Threat:** User performs malicious action and claims "I didn't do it."

**Attack Vector:** Delete project → No proof of who deleted it

**Risk:** Medium
**Likelihood:** Low
**Impact:** Medium

**Mitigation:**

- ✅ Audit log every critical action (create, update, delete)
- ✅ Log: User ID, Timestamp, Action, Resource ID, IP Address
- ✅ Immutable logs (append-only, S3 + versioning)
- ✅ Tamper detection (log signing)

**Status:** {{STATUS_R1}}

---

### I1: Info Disclosure - Database Credentials Leaked

**Threat:** Attacker finds `.env` file in Git history or exposed server.

**Attack Vector:**

1. Developer commits `.env` to Git
2. Attacker scrapes GitHub for "DATABASE_PASSWORD="
3. Connects to production database

**Risk:** Critical
**Likelihood:** Medium
**Impact:** Critical

**Mitigation:**

- ✅ `.env` in `.gitignore`
- ✅ Pre-commit hook to detect secrets (TruffleHog)
- ✅ Secrets in vault (AWS Secrets Manager, HashiCorp Vault)
- ✅ Rotate credentials quarterly
- ✅ Git history rewrite if leaked

**Status:** ✅ Implemented

---

### D1: Denial of Service - Rate Limit Bypass

**Threat:** Attacker floods API with requests to crash server.

**Attack Vector:** 10,000 requests/second to `/api/rag/query` → RAM exhaustion

**Risk:** Medium
**Likelihood:** High
**Impact:** Medium

**Mitigation:**

- ✅ Rate limiting (100 req/min per IP)
- ✅ CAPTCHA for anonymous endpoints
- ✅ CDN with DDoS protection (Cloudflare)
- ✅ Autoscaling (horizontal scaling)
- ✅ Circuit breaker pattern

**Status:** {{STATUS_D1}}

---

### E1: Elevation of Privilege - IDOR Vulnerability

**Threat:** Attacker accesses other users' resources by guessing IDs.

**Attack Vector:**

```http
GET /api/projects/123  # User's own project
GET /api/projects/124  # Attacker guesses next ID → sees other user's project!
```

**Risk:** High
**Likelihood:** High
**Impact:** High

**Mitigation:**

- ✅ Authorization check on EVERY endpoint
  ```python
  if project.owner_id != current_user.id:
      raise ForbiddenError()
  ```
- ✅ Use UUIDs instead of sequential IDs
- ✅ Automated tests for authz failures
- ✅ Code review checklist: "Is authz checked?"

**Status:** {{STATUS_E1}}

---

## 📊 Risk Assessment Matrix

| Threat ID | Category | Risk | Likelihood | Impact | Mitigation Status |
|-----------|----------|------|------------|--------|-------------------|
| S1 | Spoofing | High | Medium | High | ✅ Implemented |
| T1 | Tampering | High | Medium | High | ✅ Implemented |
| R1 | Repudiation | Medium | Low | Medium | 🚧 In Progress |
| I1 | Info Disclosure | Critical | Medium | Critical | ✅ Implemented |
| D1 | Denial of Service | Medium | High | Medium | 🚧 In Progress |
| E1 | Elevation | High | High | High | ✅ Implemented |

**Risk Levels:**

- **Critical:** Drop everything, fix now
- **High:** Fix before release
- **Medium:** Fix in next sprint
- **Low:** Backlog

---

## 🔄 Review Schedule

**Frequency:** {{REVIEW_FREQUENCY}}  <!-- e.g., "Quarterly" OR "After major releases" -->

**Trigger Events:**

- New feature launch
- Security incident
- Third-party library vulnerability (Dependabot alert)
- Penetration test findings

---

## 🔗 Related Documents

- [SECURITY_PRIVACY_POLICY.md](../20-REQUIREMENTS/SECURITY_PRIVACY_POLICY.md) - Security rules
- [COMPLIANCE_MATRIX.md](../20-REQUIREMENTS/COMPLIANCE_MATRIX.md) - Legal requirements
- [API_INTERFACE_CONTRACT.md](API_INTERFACE_CONTRACT.md) - API security
