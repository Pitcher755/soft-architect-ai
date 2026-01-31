# 🏛️ Compliance & Legal Matrix

Tabla de cumplimiento normativo para **{{PROJECT_NAME}}**.
Esta matriz debe revisarse antes de cada Release Mayor (v1.0, v2.0).

## 1. Licenciamiento y Propiedad Intelectual

| Componente | Licencia Elegida | Requisito de Atribución | Estado |
| :--- | :--- | :--- | :--- |
| **Código Fuente** | {{LICENSE_TYPE}} (Ej: MIT / Proprietary) | N/A | 🟢 Definido |
| **Librerías 3rd Party** | Check automático | No usar licencias virales (GPL) en código propietario | 🟡 Pendiente |
| **Assets (Imágenes/Fuentes)** | Comercial / Royalty Free | Listar autores en `CREDITS.md` | 🟡 Pendiente |

## 2. Normativas Legales (Regulatory)

| Regulación | Aplica | Medida de Implementación | Estado |
| :--- | :--- | :--- | :--- |
| **GDPR (Europa)** | {{GDPR_APPLIES}} | Banner de Cookies + Endpoint de borrado | 🔴 Todo |
| **CCPA (California)** | {{CCPA_APPLIES}} | Opción "Do Not Sell My Info" | ⚪ N/A |
| **PCI-DSS (Pagos)** | {{PCI_APPLIES}} | Delegado totalmente en pasarela (Stripe/PayPal) | 🟢 OK |
| **HIPAA (Salud)** | {{HIPAA_APPLIES}} | Encriptación E2E y Logs de auditoría | ⚪ N/A |

## 3. Estándares Internos de Calidad

| Control | Criterio de Aceptación | Herramienta de Validación |
| :--- | :--- | :--- |
| **Calidad de Código** | 0 Errores Críticos / 0 High Vulnerabilities | SonarQube / Ruff / Bandit |
| **Accesibilidad** | Cumplimiento WCAG 2.1 AA | Lighthouse / Accessibility Scanner |
| **Performance** | API Response < {{MAX_LATENCY_MS}}ms (p95) | Load Testing (k6 / Locust) |

---
**Firmas de Aprobación:**
* **Legal:** __________________
* **CTO:** __________________
