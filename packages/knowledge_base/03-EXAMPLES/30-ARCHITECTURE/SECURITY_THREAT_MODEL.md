# 🔐 Security Threat Model: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Analizado
> **Metodología:** STRIDE (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege)
> **Classification:** INTERNAL SECURITY DOCUMENT

---

## 📖 Tabla de Contenidos

1. [Threat Overview](#threat-overview)
2. [STRIDE Analysis](#stride-analysis)
3. [Attack Vectors](#attack-vectors)
4. [Mitigation Controls](#mitigation-controls)
5. [Risk Matrix](#risk-matrix)

---

## Threat Overview

### Threat Landscape

```
┌────────────────────────────────────────────────┐
│  SoftArchitect AI Threat Surface               │
├────────────────────────────────────────────────┤
│                                                │
│  External Threats:                             │
│  - Network-based attacks (TLS intercept)       │
│  - Supply chain (malicious dependencies)       │
│  - Physical (stolen machine)                   │
│                                                │
│  Internal Threats:                             │
│  - Malicious user (own data theft)             │
│  - Logic errors (data corruption)              │
│  - Privilege escalation (future multi-user)    │
│                                                │
│  Indirect Threats:                             │
│  - OS vulnerability (gets root)                │
│  - Third-party LLM poisoning (Groq API)        │
│  - Ollama container escape                     │
│                                                │
└────────────────────────────────────────────────┘
```

---

## STRIDE Analysis

### S - Spoofing

**Definition:** Pretending to be someone else

#### Threats

```
Threat 1: Spoofing API requests
├─ Attack: Send malicious HTTP requests as if from UI
├─ Impact: Query injection, data manipulation
└─ Likelihood: LOW (localhost only)

Threat 2: Spoofing Ollama endpoint
├─ Attack: Redirect to attacker-controlled LLM
├─ Impact: Prompt injection, data exfiltration
└─ Likelihood: MEDIUM (if network compromised)

Threat 3: Spoofing ChromaDB
├─ Attack: Return poisoned embeddings
├─ Impact: RAG returns incorrect context
└─ Likelihood: LOW (local process)
```

#### Mitigations

```
✅ Control 1: mTLS between Flutter and FastAPI
   └─ Verify certificate pinning
   └─ Validate hostname

✅ Control 2: Environment validation
   └─ Check localhost:8000 only
   └─ Verify Ollama via process verification

✅ Control 3: Response validation
   └─ Type checking on all inputs
   └─ Schema validation (Pydantic)
```

---

### T - Tampering

**Definition:** Modifying data in transit or at rest

#### Threats

```
Threat 1: Tampering with queries/responses
├─ Attack: MITM intercepts HTTP, modifies data
├─ Impact: User sees corrupted responses
└─ Likelihood: MEDIUM (without TLS)

Threat 2: Tampering with SQLite database
├─ Attack: Direct file access (if permissions weak)
├─ Impact: Decisions corrupted, decisions deleted
└─ Likelihood: LOW (file permissions)

Threat 3: Tampering with ChromaDB vectors
├─ Attack: Modify embedding files
├─ Impact: Similarity search returns wrong results
└─ Likelihood: LOW (same as SQLite)

Threat 4: Tampering with code examples
├─ Attack: Modify stored code snippets
├─ Impact: User executes malicious code
└─ Likelihood: LOW
```

#### Mitigations

```
✅ Control 1: TLS 1.3+ for all network traffic
   └─ Enforced encryption
   └─ HMAC for integrity

✅ Control 2: File permissions (chmod 0600)
   └─ SQLite: readable/writable by user only
   └─ ChromaDB: same restrictions

✅ Control 3: Database encryption at rest
   └─ AES-256 encryption for sensitive columns
   └─ Transparent to application

✅ Control 4: Integrity checks
   └─ SHA256 file hashes for documents
   └─ Checksums for embeddings
```

---

### R - Repudiation

**Definition:** User denying actions they performed

#### Threats

```
Threat 1: User denies making a query
├─ Attack: Claim they didn't generate specific decision
├─ Impact: Legal/compliance issues
└─ Likelihood: LOW (not applicable to local-first)

Threat 2: User modifies audit logs
├─ Attack: Delete or modify audit records
├─ Impact: Loss of accountability
└─ Likelihood: MEDIUM (has file access)
```

#### Mitigations

```
✅ Control 1: Immutable audit logs
   └─ Append-only database table
   └─ Cannot be modified post-insertion

✅ Control 2: Audit log backup
   └─ Automatic backup to external storage (user-controlled)
   └─ Separation of audit store from operational data

✅ Control 3: Cryptographic signing
   └─ Hash-chain for critical events
   └─ User's public key sign each entry (future)
```

---

### I - Information Disclosure

**Definition:** Unauthorized access to sensitive information

#### Threats

```
Threat 1: Information disclosure via logs
├─ Attack: Read local log files containing queries
├─ Impact: User privacy violated
└─ Likelihood: MEDIUM (local attacker)

Threat 2: Information disclosure via memory
├─ Attack: Dump process memory, extract data
├─ Impact: Current session data leaked
└─ Likelihood: LOW (requires root)

Threat 3: Information disclosure via backups
├─ Attack: Access unencrypted user backups
├─ Impact: Historical decisions leaked
└─ Likelihood: LOW (user controls backups)

Threat 4: Information disclosure via error messages
├─ Attack: Stack traces contain sensitive paths/data
├─ Impact: Information leakage
└─ Likelihood: MEDIUM

Threat 5: Information disclosure via API responses
├─ Attack: Error responses contain PII
├─ Impact: User identification
└─ Likelihood: LOW (strict response sanitization)
```

#### Mitigations

```
✅ Control 1: Log file encryption
   └─ All logs stored encrypted
   └─ Keys not in logs

✅ Control 2: Log rotation & deletion
   └─ Rotate logs daily
   └─ Delete after 30 days (configurable)

✅ Control 3: Memory encryption
   └─ Sensitive data cleared after use
   └─ Use secure delete (overwrite with zeros)

✅ Control 4: Error message sanitization
   └─ Generic error messages to user
   └─ Detailed errors to local logs only

✅ Control 5: Backup encryption
   └─ User can enable encryption for backups
   └─ User controls backup location
```

---

### D - Denial of Service (DoS)

**Definition:** Making service unavailable

#### Threats

```
Threat 1: Disk space exhaustion
├─ Attack: Upload massive files repeatedly
├─ Impact: Storage full, app crashes
└─ Likelihood: MEDIUM (single-user but possible)

Threat 2: CPU exhaustion
├─ Attack: Submit complex queries repeatedly
├─ Impact: System becomes unresponsive
└─ Likelihood: MEDIUM (local, intentional)

Threat 3: Memory exhaustion
├─ Attack: Generate embeddings for huge documents
├─ Impact: OOM kill processes
└─ Likelihood: LOW

Threat 4: Ollama unavailability
├─ Attack: Kill Ollama process
├─ Impact: LLM queries fail
└─ Likelihood: MEDIUM (local attacker)
```

#### Mitigations

```
✅ Control 1: Rate limiting
   └─ Max 10 queries/minute per user
   └─ Max 5 uploads/minute
   └─ Enforced at FastAPI layer

✅ Control 2: Resource limits
   └─ Max file size: 100MB
   └─ Max document chunks: 1000
   └─ Max tokens/response: 4096

✅ Control 3: Timeout enforcement
   └─ Query timeout: 60 seconds
   └─ Upload timeout: 300 seconds
   └─ Connection timeout: 30 seconds

✅ Control 4: Disk quota
   └─ Max storage: 10GB (configurable)
   └─ Cleanup old documents when exceeded

✅ Control 5: Health monitoring
   └─ Check Ollama health every 10 seconds
   └─ Auto-restart if detected down
   └─ Alert user if unavailable
```

---

### E - Elevation of Privilege

**Definition:** Gaining unauthorized access levels

#### Threats

```
Threat 1: Privilege escalation via Python RCE
├─ Attack: Inject Python code into eval()
├─ Impact: Attacker gets code execution
└─ Likelihood: HIGH (if not mitigated)

Threat 2: Privilege escalation via SQL injection
├─ Attack: Inject SQL to bypass auth
├─ Impact: Attacker accesses other users' data
└─ Likelihood: HIGH (if not using ORM)

Threat 3: Privilege escalation via SSRF
├─ Attack: Make server access internal resources
├─ Impact: Access to Ollama, ChromaDB, etc.
└─ Likelihood: MEDIUM

Threat 4: Privilege escalation via path traversal
├─ Attack: Use ../ to access files outside upload dir
├─ Impact: Read arbitrary files
└─ Likelihood: MEDIUM

Threat 5: Privilege escalation via container escape
├─ Attack: Break out of Ollama Docker container
├─ Impact: Access to host system
└─ Likelihood: LOW
```

#### Mitigations

```
✅ Control 1: No eval() or exec()
   └─ NEVER use eval() for user input
   └─ Use safe expression evaluation (simpleeval)

✅ Control 2: Parameterized queries
   └─ ONLY use ORM (SQLAlchemy) or prepared statements
   └─ No string concatenation

✅ Control 3: Input validation
   └─ Whitelist allowed characters
   └─ Reject suspicious patterns
   └─ Max length enforcement

✅ Control 4: Path sanitization
   └─ Use os.path.normpath() + check parent directory
   └─ Reject absolute paths
   └─ Reject paths containing ../

✅ Control 5: Container hardening
   └─ Run Ollama as non-root user
   └─ Read-only filesystem where possible
   └─ No privileged capabilities
```

---

## Attack Vectors

### External Attack Scenarios

#### Scenario 1: Network Interception

```
Attacker Goal: Steal user queries
Attack Path:
  1. MITM attack on localhost:8000
  2. Intercept unencrypted HTTP
  3. Extract query/response

Likelihood: LOW (localhost, same machine)
Severity: HIGH (PII exposed)

Mitigation:
  ✅ TLS 1.3+ enforced
  ✅ Certificate pinning
  ✅ No unencrypted fallback
```

#### Scenario 2: Supply Chain Attack

```
Attacker Goal: Inject malware via dependency
Attack Path:
  1. Compromise PyPI package (e.g., pydantic)
  2. Package includes backdoor
  3. Backdoor exfiltrates data

Likelihood: LOW (but increasing)
Severity: CRITICAL (complete compromise)

Mitigation:
  ✅ pip-audit in CI/CD
  ✅ Dependency pinning (lockfile)
  ✅ Security scanning (Snyk)
  ✅ Private package mirror (future)
```

#### Scenario 3: Stolen Machine

```
Attacker Goal: Access all user data
Attack Path:
  1. Steal or access unattended machine
  2. Read SQLite file (if not encrypted)
  3. Read ChromaDB embeddings

Likelihood: MEDIUM
Severity: CRITICAL (full data loss)

Mitigation:
  ✅ Disk encryption (BitLocker, FileVault, LUKS)
  ✅ Database encryption at rest (optional)
  ✅ OS-level access controls
  ✅ User responsibility (recommended)
```

---

## Mitigation Controls

### Control Categories

```
Category            Controls
────────────────────────────────────────────
Preventive          Input validation, encryption, auth
Detective           Logging, monitoring, alerts
Corrective          Incident response, backups
Compensating        Manual review, audit trails
```

### Control Implementation Matrix

```
Risk                Priority   Control Type    Owner         Status
─────────────────────────────────────────────────────────────────────
Injection           CRITICAL   Preventive      Backend       ✅ Implemented
Data tampering      CRITICAL   Preventive      Backend       ✅ Implemented
Information disc.   HIGH       Detective       Logging       ✅ Implemented
DoS attacks         HIGH       Preventive      API           ✅ Implemented
Privilege escal.    HIGH       Preventive      Backend       ✅ Implemented
Supply chain        MEDIUM     Detective       DevOps        ✅ Implemented
Threat monitoring   MEDIUM     Detective       Ops           ⏳ Planned
```

---

## Risk Matrix

### Risk Assessment

```
Risk Level = Likelihood × Severity × (1 - Mitigation Coverage)

Risk Levels:
  🔴 CRITICAL: >80 (immediate action)
  🟠 HIGH:     50-80 (planned action)
  🟡 MEDIUM:   20-50 (monitor)
  🟢 LOW:      <20 (accept)
```

### Risk Register

```
ID    Threat                    Likelihood  Severity  Mitigations  Risk Level
──────────────────────────────────────────────────────────────────────────────
T-001 SQL Injection             HIGH        CRITICAL  2/2          🟢 LOW
T-002 API Interception          MEDIUM      HIGH      2/3          🟡 MEDIUM
T-003 Malicious Dependencies    LOW         CRITICAL  1/3          🟠 HIGH
T-004 Resource Exhaustion       MEDIUM      HIGH      4/5          🟢 LOW
T-005 Path Traversal            MEDIUM      HIGH      1/2          🟡 MEDIUM
T-006 Container Escape          LOW         CRITICAL  1/3          🟢 LOW
T-007 Information Disclosure    MEDIUM      HIGH      5/5          🟢 LOW
T-008 Privilege Escalation      LOW         CRITICAL  4/5          🟢 LOW

Summary:
  🔴 CRITICAL: 0
  🟠 HIGH: 1 (Dependency management)
  🟡 MEDIUM: 2 (API security, path handling)
  🟢 LOW: 5 (Well-mitigated)
```

---

## Incident Response Plan

### Escalation Path

```
Severity      Response Time    Notification
──────────────────────────────────────────────
CRITICAL      Immediate (1h)   User, All team
HIGH          4 hours          All team
MEDIUM        1 day            Dev lead
LOW           1 week           Issue tracker
```

### Incident Template

```
INCIDENT REPORT:

Title: [STRIDE Category] [Brief Description]
ID: SEC-XXXX
Date: YYYY-MM-DD
Discoverer: [Name]

Description:
  [What happened]

Impact:
  - Data affected: [Yes/No, type]
  - Users affected: [Count]
  - Severity: [CRITICAL/HIGH/MEDIUM/LOW]

Mitigation:
  [Steps taken immediately]

Long-term Fix:
  [Permanent resolution]

Post-mortem:
  [What we learned]
```

---

**Security Threat Model** asegura que la seguridad no es un feature, sino un requisito arquitectónico. 🔐
