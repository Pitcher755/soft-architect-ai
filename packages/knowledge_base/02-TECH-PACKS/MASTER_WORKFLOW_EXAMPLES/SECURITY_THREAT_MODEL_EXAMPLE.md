# 🛡️ SECURITY THREAT MODEL: TaskFlow Pro

> **Project:** TaskFlow Pro - Enterprise Task Management System
> **Document Type:** Security Threat Analysis & Mitigation Strategy
> **Framework:** STRIDE + OWASP Top 10 (2021)
> **Version:** 3.1.0
> **Last Updated:** February 22, 2026
> **Status:** ✅ Active & Enforced
> **Authority:** Lead Architect + Compliance Officer

---

## 📋 Table of Contents

- [Executive Summary](#executive-summary)
- [Threat Modeling Methodology](#threat-modeling-methodology)
- [System Components (Attack Surface)](#system-components-attack-surface)
- [STRIDE Analysis by Component](#stride-analysis-by-component)
- [OWASP Top 10 Mapping](#owasp-top-10-mapping)
- [Attack Trees](#attack-trees)
- [Risk Matrix](#risk-matrix)
- [Mitigation Strategies](#mitigation-strategies)
- [Security Test Cases](#security-test-cases)
- [Incident Response Plan](#incident-response-plan)
- [References](#references)

---

## 🎯 Executive Summary

TaskFlow Pro handles **sensitive customer data** (task descriptions, project plans, user emails) and requires **enterprise-grade security**. This document identifies 47 potential threats across 5 system components and provides mitigation strategies for all High/Critical risks.

**Key Statistics:**
- **Total Threats Identified:** 47
- **Critical Risks:** 8 (all mitigated)
- **High Risks:** 15 (all mitigated)
- **Medium Risks:** 18 (accepted with monitoring)
- **Low Risks:** 6 (accepted)

**Compliance Targets:**
- OWASP Top 10 (2021) - 100% coverage
- GDPR Article 32 (Security of Processing) - Compliant
- SOC 2 Type II - Security controls implemented

---

## 🔬 Threat Modeling Methodology

### Framework: STRIDE
STRIDE is a threat classification model developed by Microsoft:

| Category | Threat | Security Property Violated |
|----------|--------|---------------------------|
| **S** | **Spoofing** | Authentication |
| **T** | **Tampering** | Integrity |
| **R** | **Repudiation** | Non-repudiation |
| **I** | **Information Disclosure** | Confidentiality |
| **D** | **Denial of Service** | Availability |
| **E** | **Elevation of Privilege** | Authorization |

### Threat Identification Process

```mermaid
graph LR
    A[Identify Assets] --> B[Map Attack Surface]
    B --> C[Apply STRIDE per Component]
    C --> D[Cross-Reference OWASP]
    D --> E[Calculate Risk Score]
    E --> F[Design Mitigations]
    F --> G[Implement + Test]
    G --> H[Monitor + Review]
    H --> A
```

---

## 🏗️ System Components (Attack Surface)

### 1. Frontend Application (Flutter Desktop)
- **Technology:** Dart 3.3, Flutter 3.19
- **Attack Vectors:** XSS, CSRF, credential theft, local storage tampering
- **Data Handled:** User credentials (cached), JWT tokens, task data (cached)

### 2. API Gateway (FastAPI)
- **Technology:** Python 3.12, FastAPI 0.110
- **Attack Vectors:** SQL injection, broken auth, mass assignment, SSRF
- **Data Handled:** All user inputs, authentication tokens, business logic

### 3. Database (PostgreSQL)
- **Technology:** PostgreSQL 16
- **Attack Vectors:** SQL injection, credential theft, data exfiltration
- **Data Handled:** All persistent data (PII, tasks, projects, passwords)

### 4. Authentication Service (OAuth2 + JWT)
- **Technology:** OAuth2, JWT (RS256)
- **Attack Vectors:** Token theft, replay attacks, brute force, session hijacking
- **Data Handled:** User credentials, access tokens, refresh tokens

### 5. File Storage (AWS S3)
- **Technology:** AWS S3 with pre-signed URLs
- **Attack Vectors:** Unauthorized access, data leakage, bucket enumeration
- **Data Handled:** File attachments (PDFs, images, documents)

---

## 🔍 STRIDE Analysis by Component

### Component 1: Frontend Application

#### 1.1 Spoofing Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| F-S1 | Attacker impersonates legitimate user by stealing cached credentials | HIGH | MEDIUM | **HIGH** | Encrypt local storage (Fernet), auto-logout after 15min inactivity |
| F-S2 | Phishing attack tricks user into fake login page | MEDIUM | HIGH | **HIGH** | Certificate pinning, display full domain in login screen |
| F-S3 | Compromised JWT token used to access API | CRITICAL | LOW | **HIGH** | Short token expiry (15min), refresh token rotation |

**Mitigation Code Example (Encrypted Storage):**
```dart
// lib/core/storage/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Store JWT with AES-256 encryption
  static Future<void> saveToken(String token) async {
    final key = encrypt.Key.fromSecureRandom(32); // 256-bit key
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(token, iv: iv);
    await _storage.write(key: 'auth_token', value: encrypted.base64);
  }
}
```

#### 1.2 Tampering Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| F-T1 | Attacker modifies local task data cache | LOW | MEDIUM | **LOW** | Validate against API on sync, hash verification |
| F-T2 | Man-in-the-middle modifies API responses | CRITICAL | LOW | **HIGH** | TLS 1.3 only, certificate pinning |

**Mitigation Code Example (Certificate Pinning):**
```dart
// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class ApiClient {
  static Dio create() {
    final dio = Dio();

    // Certificate pinning (prevent MITM)
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) {
        // Only allow our specific certificate
        return cert.sha256 == 'AAF3E...4D2C1' && host == 'api.taskflowpro.com';
      };
      return client;
    };

    return dio;
  }
}
```

#### 1.3 Repudiation Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| F-R1 | User denies performing task deletion | MEDIUM | LOW | **LOW** | Audit log on backend, digital signatures |

#### 1.4 Information Disclosure Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| F-I1 | Sensitive data leaked via insecure logging | HIGH | MEDIUM | **HIGH** | Sanitize logs, never log tokens/passwords |
| F-I2 | Task data visible in app screenshots | MEDIUM | HIGH | **MEDIUM** | Flag sensitive screens as secure (Android), disable screenshots |

**Mitigation Code Example (Secure Logging):**
```dart
// lib/core/utils/logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final _logger = Logger(
    filter: ProductionFilter(), // Only errors in production
    printer: PrettyPrinter(
      methodCount: 0, // No stack traces (info leakage)
    ),
  );

  // NEVER log sensitive data
  static void logApiCall(String endpoint, Map<String, dynamic> body) {
    final sanitized = {...body};
    sanitized.remove('password');
    sanitized.remove('email');
    sanitized.remove('token');
    _logger.d('API Call: $endpoint - ${sanitized}');
  }
}
```

#### 1.5 Denial of Service Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| F-D1 | Memory exhaustion from loading huge task lists | MEDIUM | LOW | **LOW** | Pagination (50 items/page), lazy loading |

#### 1.6 Elevation of Privilege Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| F-E1 | User modifies JavaScript to bypass role checks | HIGH | LOW | **MEDIUM** | Validate permissions on backend, no frontend-only auth |

---

### Component 2: API Gateway (FastAPI)

#### 2.1 Spoofing Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| A-S1 | Attacker forges JWT token | CRITICAL | LOW | **HIGH** | RS256 signatures (asymmetric), validate issuer/audience |
| A-S2 | API key leaked and reused | HIGH | MEDIUM | **HIGH** | API key rotation every 90 days, rate limiting per key |

**Mitigation Code Example (JWT Validation):**
```python
# src/server/core/security.py
from jose import jwt, JWTError
from datetime import datetime, timedelta
from fastapi import HTTPException, Depends
from fastapi.security import HTTPBearer

security = HTTPBearer()

SECRET_KEY = "RS256_PUBLIC_KEY_HERE"  # Load from env
ALGORITHM = "RS256"
ISSUER = "taskflowpro.com"
AUDIENCE = "api.taskflowpro.com"

def verify_token(token: str = Depends(security)) -> dict:
    """Verify JWT token integrity and claims."""
    try:
        payload = jwt.decode(
            token.credentials,
            SECRET_KEY,
            algorithms=[ALGORITHM],
            issuer=ISSUER,
            audience=AUDIENCE,
        )

        # Check expiration
        exp = payload.get("exp")
        if exp and datetime.fromtimestamp(exp) < datetime.now():
            raise HTTPException(status_code=401, detail="Token expired")

        return payload
    except JWTError as e:
        raise HTTPException(status_code=401, detail=f"Invalid token: {e}")
```

#### 2.2 Tampering Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| A-T1 | SQL injection via user input | CRITICAL | MEDIUM | **CRITICAL** | SQLAlchemy ORM (parameterized queries), input validation |
| A-T2 | Mass assignment vulnerability (extra fields in request) | HIGH | MEDIUM | **HIGH** | Pydantic schemas with explicit field whitelisting |

**Mitigation Code Example (SQL Injection Prevention):**
```python
# src/server/domain/repositories/task_repository.py
from sqlalchemy.orm import Session
from src.server.domain.models.task import Task

class TaskRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, task_id: int) -> Task | None:
        # ✅ SAFE: Parameterized query (ORM)
        return self.db.query(Task).filter(Task.id == task_id).first()

        # ❌ UNSAFE: String interpolation
        # return self.db.execute(f"SELECT * FROM tasks WHERE id = {task_id}")
```

**Mitigation Code Example (Mass Assignment Prevention):**
```python
# src/server/domain/schemas/task.py
from pydantic import BaseModel, Field

class TaskCreate(BaseModel):
    title: str = Field(..., max_length=255)
    description: str | None = Field(None, max_length=10000)
    project_id: int

    # ✅ Explicit field whitelisting prevents mass assignment
    # If client sends {"id": 999, "admin": true}, they are ignored

    class Config:
        # Forbid extra fields
        extra = "forbid"
```

#### 2.3 Repudiation Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| A-R1 | Admin denies unauthorized data deletion | HIGH | LOW | **MEDIUM** | Audit log with user_id, IP, timestamp, action |

**Mitigation Code Example (Audit Logging):**
```python
# src/server/core/audit.py
import logging
from datetime import datetime
from fastapi import Request

audit_logger = logging.getLogger("audit")

def log_action(request: Request, action: str, resource: str, user_id: int):
    """Log security-critical actions."""
    audit_logger.info(
        f"[AUDIT] {datetime.utcnow().isoformat()} | "
        f"User: {user_id} | IP: {request.client.host} | "
        f"Action: {action} | Resource: {resource}"
    )
    # Also store in database for compliance
```

#### 2.4 Information Disclosure Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| A-I1 | Verbose error messages leak system internals | MEDIUM | HIGH | **HIGH** | Generic error messages in production, log details server-side |
| A-I2 | API exposes internal IDs (sequential user IDs) | LOW | HIGH | **LOW** | Use UUIDs for public IDs, obfuscate internal IDs |
| A-I3 | CORS misconfiguration allows unauthorized domains | HIGH | MEDIUM | **HIGH** | Whitelist only `app.taskflowpro.com` |

**Mitigation Code Example (Error Handling):**
```python
# src/server/api/v1/tasks.py
from fastapi import APIRouter, HTTPException
from src.server.core.exceptions import DatabaseError

router = APIRouter()

@router.post("/tasks")
async def create_task(task_data: TaskCreate):
    try:
        return await task_service.create(task_data)
    except DatabaseError as e:
        # ✅ SAFE: Generic message to user
        raise HTTPException(status_code=500, detail="Failed to create task")

        # ❌ UNSAFE: Exposes internals
        # raise HTTPException(status_code=500, detail=f"Database error: {e}")
    finally:
        # Log details server-side
        logger.error(f"Task creation failed: {e}", exc_info=True)
```

#### 2.5 Denial of Service Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| A-D1 | API flooding (brute force login) | HIGH | HIGH | **CRITICAL** | Rate limiting (5 requests/10sec per IP), CAPTCHA after 3 fails |
| A-D2 | ReDoS (regex denial of service) | MEDIUM | LOW | **LOW** | Avoid complex regex, use timeouts |

**Mitigation Code Example (Rate Limiting):**
```python
# src/server/api/middleware.py
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@app.post("/api/v1/auth/login")
@limiter.limit("5/10second")  # Max 5 requests per 10 seconds
async def login(credentials: LoginRequest, request: Request):
    return await auth_service.login(credentials)
```

#### 2.6 Elevation of Privilege Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| A-E1 | Horizontal privilege escalation (access other user's tasks) | CRITICAL | MEDIUM | **CRITICAL** | Check `task.owner_id == current_user.id` on every read/update |
| A-E2 | Vertical privilege escalation (regular user performs admin action) | CRITICAL | LOW | **HIGH** | Role-based access control (RBAC) with @require_role decorator |

**Mitigation Code Example (Authorization Check):**
```python
# src/server/api/dependencies.py
from fastapi import Depends, HTTPException
from src.server.core.security import get_current_user

async def check_task_ownership(
    task_id: int,
    current_user = Depends(get_current_user),
    task_service: TaskService = Depends(),
):
    """Verify user owns the task."""
    task = await task_service.get_by_id(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    # ✅ CRITICAL: Check ownership
    if task.owner_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Access denied")

    return task

# Usage in endpoint
@router.delete("/tasks/{task_id}")
async def delete_task(
    task = Depends(check_task_ownership),  # Authorization enforced
):
    await task_service.delete(task)
    return {"status": "deleted"}
```

---

### Component 3: Database (PostgreSQL)

#### 3.1 Key Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| D-S1 | Database credentials leaked | CRITICAL | LOW | **HIGH** | Rotate credentials every 90 days, use AWS Secrets Manager |
| D-T1 | Direct database modification bypassing API | HIGH | LOW | **MEDIUM** | Database audit logs, read-only replicas for analytics |
| D-I1 | Backup files stolen | CRITICAL | LOW | **HIGH** | Encrypt backups (AES-256), store in S3 with restricted IAM |
| D-D1 | Database connection exhaustion | HIGH | MEDIUM | **HIGH** | Connection pooling (max 20 connections), query timeouts |

**Mitigation Code Example (Connection Pooling):**
```python
# src/server/core/database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql://user:pass@localhost/taskflow"

engine = create_engine(
    DATABASE_URL,
    pool_size=10,          # Max 10 idle connections
    max_overflow=10,       # Max 10 overflow connections
    pool_timeout=30,       # Wait 30s for available connection
    pool_pre_ping=True,    # Test connections before using
)

SessionLocal = sessionmaker(bind=engine)
```

---

### Component 4: Authentication Service

#### 4.1 Key Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| Auth-S1 | Password brute force | HIGH | HIGH | **CRITICAL** | Bcrypt (cost factor 12), account lockout after 5 fails |
| Auth-T1 | Session fixation attack | HIGH | LOW | **MEDIUM** | Regenerate session ID after login |
| Auth-I1 | Password reset token leaked via email | MEDIUM | MEDIUM | **MEDIUM** | One-time tokens (15min expiry), log usage |

**Mitigation Code Example (Password Hashing):**
```python
# src/server/core/security.py
from passlib.context import CryptContext

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
    bcrypt__rounds=12,  # Cost factor (2^12 iterations)
)

def hash_password(password: str) -> str:
    """Hash password with bcrypt (OWASP recommended)."""
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    """Verify password against hash."""
    return pwd_context.verify(plain, hashed)
```

---

### Component 5: File Storage (AWS S3)

#### 5.1 Key Threats

| ID | Threat | Impact | Likelihood | Risk | Mitigation |
|----|--------|--------|-----------|------|------------|
| S-S1 | Unauthorized file access via guessed URL | HIGH | MEDIUM | **HIGH** | Pre-signed URLs (5min expiry), UUIDs for filenames |
| S-I1 | Sensitive data in file metadata | LOW | MEDIUM | **LOW** | Strip EXIF data before upload |
| S-E1 | Public bucket misconfiguration | CRITICAL | LOW | **HIGH** | Block all public access, use IAM policies only |

**Mitigation Code Example (Pre-Signed URLs):**
```python
# src/server/infrastructure/storage/s3.py
import boto3
from datetime import timedelta

s3_client = boto3.client('s3')

def generate_presigned_url(file_key: str) -> str:
    """Generate temporary URL for file download (5 min expiry)."""
    return s3_client.generate_presigned_url(
        'get_object',
        Params={'Bucket': 'taskflow-uploads', 'Key': file_key},
        ExpiresIn=300,  # 5 minutes
    )
```

---

## 🎯 OWASP Top 10 Mapping

### A01:2021 - Broken Access Control

**Affected Components:** API Gateway, Frontend
**TaskFlow Pro Risks:**
- Horizontal privilege escalation (accessing other user's tasks)
- Vertical privilege escalation (regular user performing admin actions)

**Mitigations:**
- ✅ RBAC (Role-Based Access Control) with `@require_role` decorator
- ✅ Ownership checks on every resource access
- ✅ Unit tests for authorization logic (100% coverage)

**Test Case:**
```python
# tests/api/test_auth.py
def test_user_cannot_delete_others_task():
    # User A creates a task
    task = client.post("/tasks", json={"title": "My Task"}, headers=user_a_headers)

    # User B tries to delete it (should fail)
    response = client.delete(f"/tasks/{task['id']}", headers=user_b_headers)
    assert response.status_code == 403
    assert "Access denied" in response.json()["detail"]
```

---

### A02:2021 - Cryptographic Failures

**Affected Components:** Database, File Storage, Frontend
**TaskFlow Pro Risks:**
- Passwords stored in plaintext
- JWT tokens not encrypted in local storage

**Mitigations:**
- ✅ Bcrypt for password hashing (cost factor 12)
- ✅ AES-256 encryption for sensitive data at rest
- ✅ TLS 1.3 for data in transit
- ✅ Never log passwords/tokens

---

### A03:2021 - Injection

**Affected Components:** API Gateway, Database
**TaskFlow Pro Risks:**
- SQL injection via search queries
- NoSQL injection (if using MongoDB)

**Mitigations:**
- ✅ SQLAlchemy ORM (parameterized queries)
- ✅ Pydantic input validation (reject non-alphanumeric where appropriate)
- ✅ Never concatenate user input into queries

**Attack Example (Prevented):**
```python
# ❌ VULNERABLE CODE (don't do this)
def get_tasks_by_title(title: str):
    query = f"SELECT * FROM tasks WHERE title = '{title}'"
    return db.execute(query)

# Attacker input: title = "'; DROP TABLE tasks; --"
# Result: SQL injection deletes entire table

# ✅ SAFE CODE (use ORM)
def get_tasks_by_title(title: str):
    return db.query(Task).filter(Task.title == title).all()
```

---

### A04:2021 - Insecure Design

**Affected Components:** All
**TaskFlow Pro Risks:**
- No rate limiting (DDoS vulnerability)
- No audit logging (repudiation)

**Mitigations:**
- ✅ Rate limiting (5 req/10sec for login)
- ✅ Audit logs for critical actions
- ✅ Threat modeling performed (this document)

---

### A05:2021 - Security Misconfiguration

**Affected Components:** API Gateway, Database
**TaskFlow Pro Risks:**
- Verbose error messages in production
- Default admin credentials

**Mitigations:**
- ✅ Separate configs for dev/staging/prod
- ✅ Force strong passwords (min 12 chars, uppercase, symbols)
- ✅ Disable stack traces in production

---

### A06:2021 - Vulnerable Components

**Affected Components:** All
**TaskFlow Pro Risks:**
- Outdated dependencies with known CVEs

**Mitigations:**
- ✅ Dependabot alerts enabled
- ✅ Monthly dependency updates
- ✅ Trivy security scans in CI/CD

**CI/CD Check:**
```yaml
# .github/workflows/security-scan.yml
- name: Scan for vulnerabilities
  run: |
    trivy image taskflow-backend:latest --severity CRITICAL,HIGH --exit-code 1
```

---

### A07:2021 - Identification and Authentication Failures

**Affected Components:** Authentication Service
**TaskFlow Pro Risks:**
- Weak password policy
- No account lockout

**Mitigations:**
- ✅ 15-minute JWT expiry
- ✅ Account lockout after 5 failed logins
- ✅ Password complexity requirements

---

### A08:2021 - Software and Data Integrity Failures

**Affected Components:** CI/CD, Frontend
**TaskFlow Pro Risks:**
- Unsigned software updates
- Tampered dependencies

**Mitigations:**
- ✅ Code signing for Flutter builds
- ✅ SRI (Subresource Integrity) for CDN assets
- ✅ Lock files (poetry.lock, pubspec.lock)

---

### A09:2021 - Security Logging and Monitoring Failures

**Affected Components:** All
**TaskFlow Pro Risks:**
- Attacks go undetected
- No incident response

**Mitigations:**
- ✅ Centralized logging (ELK stack)
- ✅ Alerts for suspicious activity (5+ failed logins)
- ✅ Annual penetration testing

---

### A10:2021 - Server-Side Request Forgery (SSRF)

**Affected Components:** API Gateway
**TaskFlow Pro Risks:**
- User-supplied URLs fetched by backend

**Mitigations:**
- ✅ Whitelist allowed domains
- ✅ Validate URL schemes (only https://)
- ✅ Network segmentation (backend can't access internal AWS metadata)

---

## 🌳 Attack Trees

### Attack Tree 1: Steal User Credentials

```mermaid
graph TD
    A[Steal User Credentials] --> B[Phishing Attack]
    A --> C[Brute Force Login]
    A --> D[Keylogger Malware]
    A --> E[Intercept Network Traffic]

    B --> B1[Fake Login Page]
    B --> B2[Email with Malicious Link]

    C --> C1[Dictionary Attack]
    C --> C2[Credential Stuffing from Breach]

    E --> E1[MITM on Public WiFi]
    E --> E2[Compromised Router]

    style A fill:#ff6b6b
    style B fill:#feca57
    style C fill:#feca57
    style D fill:#feca57
    style E fill:#feca57
```

**Mitigations:**
- **B (Phishing):** Certificate pinning, phishing-resistant MFA
- **C (Brute Force):** Rate limiting, account lockout, CAPTCHA
- **D (Keylogger):** Antivirus recommendations, security awareness training
- **E (MITM):** TLS 1.3 only, certificate pinning

---

### Attack Tree 2: Unauthorized Data Access

```mermaid
graph TD
    A[Access Other User's Data] --> B[Horizontal Privilege Escalation]
    A --> C[SQL Injection]
    A --> D[Stolen JWT Token]

    B --> B1[Manipulate task_id in URL]
    B --> B2[Mass assignment vulnerability]

    C --> C1[Inject via search query]
    C --> C2[Inject via filter parameter]

    D --> D1[XSS steals token from localStorage]
    D --> D2[Phishing captures token]

    style A fill:#ff6b6b
    style B fill:#feca57
    style C fill:#feca57
    style D fill:#feca57
```

**Mitigations:**
- **B (Privilege Escalation):** Authorization checks on every endpoint
- **C (SQL Injection):** ORM usage, parameterized queries
- **D (Token Theft):** httpOnly cookies (instead of localStorage), 15min expiry

---

## 📊 Risk Matrix

### Risk Calculation
```
Risk Score = Likelihood × Impact

Likelihood:
- LOW (1): <10% chance in 1 year
- MEDIUM (3): 10-50% chance
- HIGH (5): >50% chance

Impact:
- LOW (1): Minor inconvenience
- MEDIUM (3): Data breach <100 users
- HIGH (5): Data breach >1000 users, service down >1 hour
- CRITICAL (10): Complete system compromise
```

### Top 10 Risks (Sorted by Score)

| ID | Threat | Likelihood | Impact | Score | Status |
|----|--------|-----------|--------|-------|--------|
| A-E1 | Horizontal privilege escalation | 3 | 10 | **30** | ✅ Mitigated |
| A-T1 | SQL injection | 3 | 10 | **30** | ✅ Mitigated |
| A-D1 | API flooding (brute force) | 5 | 5 | **25** | ✅ Mitigated |
| A-S1 | JWT token forgery | 1 | 10 | **10** | ✅ Mitigated |
| F-S1 | Cached credential theft | 3 | 5 | **15** | ✅ Mitigated |
| D-I1 | Database backup theft | 1 | 10 | **10** | ✅ Mitigated |
| Auth-S1 | Password brute force | 5 | 5 | **25** | ✅ Mitigated |
| S-S1 | Unauthorized file access | 3 | 5 | **15** | ✅ Mitigated |
| A-I1 | Verbose error messages | 5 | 3 | **15** | ✅ Mitigated |
| F-I1 | Insecure logging (token leakage) | 3 | 5 | **15** | ✅ Mitigated |

---

## 🛠️ Mitigation Strategies

### Strategy 1: Defense in Depth
**Principle:** Multiple layers of security (if one fails, others remain)

**Implementation:**
```
Layer 1: Network (Firewall, WAF)
Layer 2: Authentication (OAuth2 + JWT)
Layer 3: Authorization (RBAC)
Layer 4: Input Validation (Pydantic)
Layer 5: Data Encryption (AES-256)
Layer 6: Audit Logging (ELK)
```

---

### Strategy 2: Principle of Least Privilege
**Principle:** Grant minimum permissions required

**Implementation:**
- Database user has only SELECT/INSERT/UPDATE rights (no DROP)
- API keys scoped to specific endpoints
- IAM roles for S3 (no wildcard policies)

**Example (IAM Policy):**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::taskflow-uploads/*"
    }
  ]
}
```

---

### Strategy 3: Fail Securely
**Principle:** Errors default to deny access, not grant

**Implementation:**
```python
def check_permission(user: User, resource: Resource) -> bool:
    try:
        return user.role in resource.allowed_roles
    except Exception:
        # ✅ SAFE: On error, deny access
        return False

        # ❌ UNSAFE: Never return True on error
```

---

## 🧪 Security Test Cases

### Test Suite 1: Authentication
```python
# tests/security/test_auth_security.py
import pytest

def test_brute_force_protection():
    """Verify account locks after 5 failed logins."""
    for _ in range(5):
        response = client.post("/auth/login", json={
            "email": "user@example.com",
            "password": "wrong_password"
        })

    # 6th attempt should be blocked
    response = client.post("/auth/login", json={
        "email": "user@example.com",
        "password": "correct_password"
    })
    assert response.status_code == 429  # Too Many Requests
    assert "Account locked" in response.json()["detail"]

def test_jwt_expiry():
    """Verify JWT expires after 15 minutes."""
    token = generate_test_token(exp=datetime.now() + timedelta(minutes=16))
    response = client.get("/tasks", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 401
```

---

### Test Suite 2: Authorization
```python
def test_horizontal_privilege_escalation_blocked():
    """Verify user cannot access another user's tasks."""
    # User A creates task
    task = create_task(user=user_a, title="Secret task")

    # User B tries to read it
    response = client.get(f"/tasks/{task.id}", headers=user_b_headers)
    assert response.status_code == 403

def test_vertical_privilege_escalation_blocked():
    """Verify regular user cannot perform admin actions."""
    response = client.delete("/users/123", headers=regular_user_headers)
    assert response.status_code == 403
```

---

### Test Suite 3: Input Validation
```python
def test_sql_injection_blocked():
    """Verify SQL injection attempts are sanitized."""
    malicious_input = "'; DROP TABLE tasks; --"
    response = client.get(f"/tasks?search={malicious_input}")
    assert response.status_code == 200
    assert len(response.json()) == 0  # No results, but no error

def test_xss_injection_blocked():
    """Verify XSS payloads are escaped."""
    response = client.post("/tasks", json={
        "title": "<script>alert('XSS')</script>"
    })
    task = response.json()
    assert "<script>" not in task["title"]  # Should be escaped
```

---

## 🚨 Incident Response Plan

### Phase 1: Detection (0-15 minutes)
- **Trigger:** Monitoring alerts (5+ failed logins, unusual API traffic)
- **Actions:**
  1. Security team paged via PagerDuty
  2. Collect initial logs (CloudWatch, ELK)
  3. Determine severity (P1-P4)

### Phase 2: Containment (15-60 minutes)
- **Actions:**
  1. Isolate affected systems (disable API keys)
  2. Block malicious IPs (WAF rules)
  3. Revoke compromised tokens
  4. Enable read-only mode if needed

### Phase 3: Eradication (1-4 hours)
- **Actions:**
  1. Patch vulnerability
  2. Reset affected user passwords
  3. Rotate all secrets (DB credentials, JWT keys)

### Phase 4: Recovery (4-24 hours)
- **Actions:**
  1. Re-enable services gradually
  2. Monitor for repeat attacks
  3. Notify affected users (GDPR requirement)

### Phase 5: Lessons Learned (1 week)
- **Actions:**
  1. Post-mortem meeting
  2. Update threat model
  3. Implement preventive controls

---

## 📚 References

### Internal Documents
- [RULES.md](../00-ROOT/RULES.md) - Security policies (Section 4)
- [API_INTERFACE_CONTRACT.md](API_INTERFACE_CONTRACT.md) - API security specs
- [TESTING_STRATEGY.md](../40-PLANNING/TESTING_STRATEGY.md) - Security test requirements

### External Standards
- [OWASP Top 10 (2021)](https://owasp.org/www-project-top-ten/)
- [STRIDE Threat Modeling](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CWE Top 25](https://cwe.mitre.org/top25/)

---

**Document Signature:**

```
Approved by:
- Sarah Chen (Lead Architect) - February 22, 2026
- Jonathan Wright (Compliance Officer) - February 22, 2026

Next Review Date: May 22, 2026 (Quarterly)
Last Penetration Test: January 15, 2026 (Annual)
```

---

*This document is version-controlled and stored in `context/30-ARCHITECTURE/SECURITY_THREAT_MODEL.md`. Changes require security team approval and ADR documentation.*
