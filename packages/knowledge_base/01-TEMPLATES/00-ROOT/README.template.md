# {{PROJECT_NAME}}

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Coverage](https://img.shields.io/badge/coverage-80%25-green)
![Security](https://img.shields.io/badge/security-hardened-blue)

> **{{VISION_STATEMENT}}**

## 📖 Sobre el Proyecto
{{PROJECT_DESCRIPTION}}

Este proyecto sigue la arquitectura definida por **SoftArchitect AI**.
* **Stack Backend:** {{BACKEND_STACK}}
* **Stack Frontend:** {{FRONTEND_STACK}}
* **Base de Datos:** {{DATABASE_STACK}}

## 🚀 Quick Start

### Prerequisitos
* Docker & Docker Compose
* {{PRIMARY_LANGUAGE}} Environment

### Instalación
```bash
# 1. Clonar repositorio
git clone {{REPO_URL}}

# 2. Configurar entorno
cp infrastructure/.env.example infrastructure/.env

# 3. Levantar servicios
docker compose -f infrastructure/docker-compose.yml up -d
```

## 📂 Estructura del Proyecto
El proyecto sigue una estructura estricta de Clean Architecture:

* **src/server:** Backend API & Business Logic.
* **src/client:** Frontend Application.
* **infrastructure/:** Docker & Deployment configs.
* **context/:** Fuente de Verdad (Requisitos, Arquitectura, Reglas).

## 🤝 Contribución
Consulta CONTRIBUTING.md para conocer las reglas de Pull Requests y Estándares de Código.

## 📄 Licencia
Este proyecto está bajo la licencia {{LICENSE_TYPE}}.
