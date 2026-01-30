# 🛡️ Security Threat Model (STRIDE)

Análisis de riesgos de seguridad para la arquitectura de **{{PROJECT_NAME}}**.
**Metodología:** STRIDE (Spoofing, Tampering, Repudiation, Info Disclosure, Denial of Service, Elevation of Privilege).

## 1. Superficie de Ataque
* **External Interfaces:** API Pública, Webhooks.
* **User Inputs:** Formularios, Subida de archivos.
* **Data Stores:** Base de datos, Logs.

## 2. Matriz de Amenazas y Mitigación

| Amenaza (Threat) | Tipo (STRIDE) | Probabilidad | Impacto | Mitigación Implementada |
| :--- | :--- | :--- | :--- | :--- |
| **SQL Injection** | Tampering | Media | Crítica | Uso estricto de ORM + Validación Pydantic. |
| **XSS (Cross-Site Scripting)** | Tampering | Alta | Alta | Auto-escaping en Frontend + CSP Headers. |
| **Robo de Token JWT** | Info Disclosure | Baja | Alta | Tokens HTTP-Only + Expiración corta (15min). |
| **DDoS API** | Denial of Service | Media | Media | Rate Limiting (Redis) en API Gateway. |
| **Acceso Admin no autorizado** | Elevation | Baja | Crítica | MFA obligatorio para roles Admin. |
| **{{THREAT_1}}** | {{STRIDE_TYPE}} | {{PROBABILITY}} | {{IMPACT}} | {{MITIGATION}} |

## 3. Plan de Respuesta a Incidentes
En caso de brecha detectada:
1. Rotar claves maestras.
2. Notificar usuarios afectados (según GDPR).
3. Restaurar backup limpio.
4. Análisis post-mortem y documento de lecciones aprendidas.

## 4. Requisitos de Seguridad por Capas

### Backend
* Validación estricta de entrada (Pydantic).
* Sanitización de outputs (para evitar XSS).
* Rate limiting en endpoints críticos.

### Frontend
* CORS restrictivo.
* CSP headers.
* Validación de lado del cliente.

### Base de Datos
* Encriptación en tránsito (TLS).
* Encriptación en reposo (si aplica).
* Backups encriptados y probados regularmente.
