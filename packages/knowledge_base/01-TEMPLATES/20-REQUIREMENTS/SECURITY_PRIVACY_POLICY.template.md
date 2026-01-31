# 🔒 Security & Privacy Policy: {{PROJECT_NAME}}

> **Nivel de Clasificación:** {{DATA_CLASSIFICATION_LEVEL}} (e.g., Internal / Confidential / Public)
> **Responsable:** {{SECURITY_OFFICER_ROLE}}

Este documento define las reglas de seguridad mandatorias que la arquitectura y el código deben cumplir.

## 1. Reglas de Privacidad de Datos (GDPR/CCPA)

### 1.1 Minimización de Datos
Solo recolectamos lo estrictamente necesario.
* **Datos Sensibles (PII) Recolectados:**
    * {{PII_DATA_1}} (Ej: Email)
    * {{PII_DATA_2}} (Ej: Dirección IP)
* **Datos Excluidos Explícitamente:**
    * {{EXCLUDED_DATA}} (Ej: Tarjetas de crédito - procesadas por Stripe).

### 1.2 Retención y Borrado
* **Tiempo de Retención:** {{DATA_RETENTION_DAYS}} días.
* **Derecho al Olvido:** El sistema DEBE tener un mecanismo para borrar todos los datos de un usuario (`cascade delete`).

## 2. Manejo de Secretos y Configuración
* **Regla #1:** JAMÁS subir credenciales al repositorio.
* **Gestión:** Se usan variables de entorno (`.env`) cargadas vía `Pydantic Settings` (o equivalente).
* **Secretos Requeridos:**
    * `DB_PASSWORD`
    * `{{API_KEY_NAME}}`
    * `JWT_SECRET`

## 3. Autenticación y Autorización
* **Estándar:** {{AUTH_STANDARD}} (Ej: OAuth2 + JWT).
* **Hashing de Contraseñas:** {{PASSWORD_HASHING_ALGO}} (Ej: Argon2 / bcrypt).
* **Sesiones:** Stateless (Tokens) / Stateful (Redis).

## 4. Seguridad en Transmisión y Reposo
* **Transporte:** HTTPS obligatorio (TLS 1.2+).
* **Base de Datos:** Encriptación en reposo (At Rest) habilitada en {{DATABASE_STACK}}.
