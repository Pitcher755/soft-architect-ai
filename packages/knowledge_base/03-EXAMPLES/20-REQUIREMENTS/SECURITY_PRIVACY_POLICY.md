# 🛡️ Security & Privacy Policy: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Definido
> **Compliance:** GDPR, OWASP, Data Privacy by Design

---

## 📖 Tabla de Contenidos

1. [Principios de Seguridad](#principios-de-seguridad)
2. [Data Classification](#data-classification)
3. [Privacy by Design](#privacy-by-design)
4. [Compliance](#compliance)
5. [Incident Response](#incident-response)

---

## Principios de Seguridad

### "Privacy First, Security Always"

```
Principio 1: LOCAL-FIRST
  └─ Cero datos a la nube (por default)
  └─ Todo procesamiento local
  └─ Usuario controla su data

Principio 2: ENCRYPTION
  └─ Data in transit: TLS 1.3+
  └─ Data at rest: AES-256 (optional)
  └─ Keys: Locales, sin backup a la nube

Principio 3: TRANSPARENCY
  └─ Logs locales accesibles
  └─ No hidden telemetry
  └─ User consent explícito

Principio 4: MINIMIZATION
  └─ Solo colectar datos necesarios
  └─ Borrar después de uso
  └─ No profiling
```

---

## Data Classification

### PII (Personally Identifiable Information)

```
COLLECTED:
  ✓ Email (si registración opcional)
  ✓ Decisions históricas (local only)
  ✓ Query logs (local only)

NEVER COLLECTED:
  ✗ Payment information
  ✗ Phone number
  ✗ Address
  ✗ Browsing history
  ✗ IP address (unless error reporting opt-in)
```

### Tech Data (Queries & Decisions)

```
STORED LOCALLY:
  ✓ User questions
  ✓ Decision matrices generadas
  ✓ Code examples copiados
  ✓ Chat history

RETAINED:
  ✓ Permanently (user control)
  ✓ Encrypted in SQLite
  ✓ Backupable by user

DELETION:
  ✓ User puede borrar todo anytime
  ✓ Bulk export before deletion
  ✓ Permanent removal (no recovery)
```

### Metadata

```
COLLECTED:
  - Timestamp (local)
  - Feature used
  - Response time
  - Error messages (sanitized)

SHARED:
  - Nothing (unless user opt-in)
```

---

## Privacy by Design

### "Zero Trust Architecture"

```
Asumo que:
  ❌ Internet no es seguro
  ❌ Terceros van a tomar datos si pueden
  ❌ Usuarios necesitan control total

Implementación:
  ✅ Offline-first (no internet needed)
  ✅ Encryption por defecto
  ✅ No external API calls (default)
  ✅ User audit logs
  ✅ Opt-in para cualquier cloud feature
```

### Data Flow Mapping

```
┌─────────────────────────────────────────┐
│ USER                                    │
└────────────┬────────────────────────────┘
             │ (Local, on user's machine)
             ▼
┌─────────────────────────────────────────┐
│ FLUTTER APP                             │
│ ├─ Input validation                     │
│ ├─ Encryption buffer                    │
│ └─ Local cache                          │
└────────────┬────────────────────────────┘
             │ (HTTP to localhost:8000)
             ▼
┌─────────────────────────────────────────┐
│ FASTAPI BACKEND (Local)                 │
│ ├─ Ollama (LLM, local)                  │
│ ├─ ChromaDB (vectors, local)            │
│ └─ SQLite (config, local)               │
└────────────┬────────────────────────────┘
             │ (No external calls)
             ▼
┌─────────────────────────────────────────┐
│ RESPONSE (to user, encrypted in transit)│
└─────────────────────────────────────────┘

100% DATA STAYS LOCAL
```

### Opt-in Cloud Features

```
IF USER CHOOSES cloud:

1. Groq API (LLM acceleration)
   └─ User must explicitly enable
   └─ Can disable anytime
   └─ Data sent: only query + decision context
   └─ Data NOT sent: PII, query history

2. Custom LLMs
   └─ User configures own endpoint
   └─ Full control over where data goes

3. Export to Cloud Storage
   └─ User triggered
   └─ User controls encryption
   └─ User manages credentials
```

---

## Compliance

### GDPR (EU Data Protection)

```
GDPR Requirement         SoftArchitect Approach
─────────────────────────────────────────────────────
Right to Access          User can export all data
Right to Erasure         One-click delete all
Consent                  Explicit opt-in (not opt-out)
Transparency             Open source, audit logs visible
Minimization             Only necessary data collected
Retention                User controls (default: local)
Portability              Export feature built-in
```

### OWASP Top 10

```
OWASP Risk              Mitigation
────────────────────────────────────────────
Injection               Pydantic validation, parameterized queries
Broken Auth             No auth needed (local app)
Sensitive Data          Encryption, local-first
XML External            No XML parsing
Broken Access Control   Single user (no RBAC needed)
Security Config         Hardened defaults
Injection (SQL)         ORM usage, no string concat
XSS                     Framework escaping (Flutter)
Insecure Deser          Type hints, validation
Logging                 Local logs only
```

### Data Protection Standards

```
Standard                Status      Details
────────────────────────────────────────────────────
PCI-DSS                 N/A         No payment data
HIPAA                   N/A         No health data
SOC 2                   ✅ Ready    Audit logs available
ISO 27001               ✅ Ready    Security controls
NIST Cybersecurity      ✅ Ready    Framework aligned
```

---

## Incident Response

### Security Incident Plan

```
Level 1: Low Risk (user data, no exploit)
  └─ Example: User forgot password
  └─ Response: N/A (no password system)
  └─ Time: N/A

Level 2: Medium Risk (vulnerability, no proof of exploit)
  └─ Example: XSS vector found
  └─ Response: Patch release, security advisory
  └─ Time: 48 hours

Level 3: High Risk (active exploit, data accessed)
  └─ Example: RCE vulnerability confirmed
  └─ Response: Emergency patch, full disclosure, audit
  └─ Time: 24 hours

Level 4: Critical (widespread compromise)
  └─ Example: Key compromise
  └─ Response: Full investigation, rekey, audit
  └─ Time: Immediate
```

### Vulnerability Disclosure

```
Security researchers can report to:
  - Email: security@softarchitect.ai (private)
  - GPG key: [public key for encryption]
  - Response time: 48 hours max
  - Reward: Recognition in SECURITY.md

Policy:
  ✅ 90-day disclosure window
  ✅ Patches before public announcement
  ✅ Credit to reporter (if desired)
  ✅ No legal action against researchers
```

---

## Security Checklist

### Development

```
Before COMMIT:
  [ ] No secrets in code
  [ ] Input validated
  [ ] Type hints present
  [ ] Tests passing
  [ ] Linting clean

Before RELEASE:
  [ ] Security audit done
  [ ] Dependencies checked (pip-audit, npm audit)
  [ ] Encryption working
  [ ] Logs sanitized
  [ ] Changelog updated
```

### Deployment

```
Before DEPLOYMENT:
  [ ] SSL/TLS configured
  [ ] Secrets injected (not committed)
  [ ] Backups working
  [ ] Monitoring enabled
  [ ] Rollback plan ready
  [ ] Incident response team notified
```

### User Maintenance

```
User should:
  [ ] Keep OS updated
  [ ] Keep app updated
  [ ] Use strong passwords (if needed)
  [ ] Backup data regularly
  [ ] Review privacy settings
  [ ] Enable encryption (if applicable)
```

---

## Privacy Policy Summary

```
EN RESUMEN:

✅ PROTEGEMOS:
  - Privacidad (local-first)
  - Datos (encrypted)
  - Consentimiento (explicit)
  - Transparencia (open source)

❌ NO HACEMOS:
  - Vender datos
  - Rastrear usuarios
  - Compartir con terceros
  - Guardar sin consentimiento
  - Usar para ML entrenamiento (sin permiso)

🛡️ SI OCURRE BREACH:
  - Notificación inmediata
  - Transparencia total
  - Acción correctiva
  - Compensación (si aplica)
```

---

**Security & Privacy** no es un feature, es la base de SoftArchitect AI. 🔒
