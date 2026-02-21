# 🔒 Security & Privacy Policy: {{PROJECT_NAME}}

> **Classification Level:** {{DATA_CLASSIFICATION_LEVEL}} (e.g., Internal / Confidential / Public)
> **Responsible:** {{SECURITY_OFFICER_ROLE}}

This document defines the mandatory security rules that architecture and code must comply with.

## 1. Data Privacy Rules (GDPR/CCPA)

### 1.1 Data Minimization
We only collect what is strictly necessary.
* **Sensitive Data (PII) Collected:**
    * {{PII_DATA_1}} (E.g.: Email)
    * {{PII_DATA_2}} (E.g.: IP Address)
* **Explicitly Excluded Data:**
    * {{EXCLUDED_DATA}} (E.g.: Credit cards - processed by Stripe).

### 1.2 Retention and Deletion
* **Retention Time:** {{DATA_RETENTION_DAYS}} days.
* **Right to be Forgotten:** The system MUST have a mechanism to delete all user data (`cascade delete`).

## 2. Secrets and Configuration Management
* **Rule #1:** NEVER upload credentials to the repository.
* **Management:** Environment variables (`.env`) loaded via `Pydantic Settings` (or equivalent) are used.
* **Required Secrets:**
    * `DB_PASSWORD`
    * `{{API_KEY_NAME}}`
    * `JWT_SECRET`

## 3. Authentication and Authorization
* **Standard:** {{AUTH_STANDARD}} (E.g.: OAuth2 + JWT).
* **Password Hashing:** {{PASSWORD_HASHING_ALGO}} (E.g.: Argon2 / bcrypt).
* **Sessions:** Stateless (Tokens) / Stateful (Redis).

## 4. Security in Transit and at Rest
* **Transport:** HTTPS mandatory (TLS 1.2+).
* **Database:** Encryption at rest enabled in {{DATABASE_STACK}}.
