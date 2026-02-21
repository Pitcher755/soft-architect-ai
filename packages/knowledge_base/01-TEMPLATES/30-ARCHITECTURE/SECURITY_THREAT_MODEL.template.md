# 🛡️ Security Threat Model (STRIDE)

Security risk analysis for the architecture of **{{PROJECT_NAME}}**.
**Methodology:** STRIDE (Spoofing, Tampering, Repudiation, Info Disclosure, Denial of Service, Elevation of Privilege).

## 1. Attack Surface
* **External Interfaces:** Public API, Webhooks.
* **User Inputs:** Forms, File uploads.
* **Data Stores:** Database, Logs.

## 2. Threat and Mitigation Matrix

| Threat | Type (STRIDE) | Probability | Impact | Implemented Mitigation |
| :--- | :--- | :--- | :--- | :--- |
| **SQL Injection** | Tampering | Medium | Critical | Strict use of ORM + Pydantic validation. |
| **XSS (Cross-Site Scripting)** | Tampering | High | High | Auto-escaping in Frontend + CSP Headers. |
| **JWT Token Theft** | Info Disclosure | Low | High | HTTP-Only tokens + Short expiration (15min). |
| **API DDoS** | Denial of Service | Medium | Medium | Rate Limiting (Redis) at API Gateway. |
| **Unauthorized Admin Access** | Elevation | Low | Critical | MFA mandatory for Admin roles. |
| **{{THREAT_1}}** | {{STRIDE_TYPE}} | {{PROBABILITY}} | {{IMPACT}} | {{MITIGATION}} |

## 3. Incident Response Plan
In case of detected breach:
1. Rotate master keys.
2. Notify affected users (per GDPR).
3. Restore clean backup.
4. Post-mortem analysis and lessons learned document.

## 4. Security Requirements by Layer

### Backend
* Strict input validation (Pydantic).
* Output sanitization (to prevent XSS).
* Rate limiting on critical endpoints.

### Frontend
* Restrictive CORS.
* CSP headers.
* Client-side validation.

### Database
* Encryption in transit (TLS).
* Encryption at rest (if applicable).
* Encrypted and regularly tested backups.
