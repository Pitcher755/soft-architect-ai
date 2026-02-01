# 🚀 Guía: Ejecutar GitHub Actions Localmente con `act`

> **Propósito:** Probar workflows de CI/CD en local antes de hacer push a GitHub

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Instalación de `act`](#instalación-de-act)
3. [Uso Básico](#uso-básico)
4. [Comandos Específicos del Proyecto](#comandos-específicos-del-proyecto)
5. [Troubleshooting](#troubleshooting)

---

## ✅ Requisitos Previos

- **Docker** instalado y corriendo
- **Git Bash** o terminal compatible
- **Permisos sudo** para instalación

Verificar Docker:
```bash
docker --version
docker ps
```

---

## 📦 Instalación de `act`

### Opción 1: Script de instalación oficial (Linux/macOS)
```bash
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

### Opción 2: Usando Homebrew (macOS)
```bash
brew install act
```

### Opción 3: Manual
Descargar desde: https://github.com/nektos/act/releases

---

## 🎯 Uso Básico

### 1. Listar todos los workflows disponibles
```bash
act --list
```

### 2. Ejecutar workflow COMPLETO
```bash
# Backend CI completo
act -W .github/workflows/backend-ci.yaml

# Frontend CI completo
act -W .github/workflows/frontend-ci.yaml
```

### 3. Ejecutar un JOB específico
```bash
# Solo unit tests
act -j unit-tests -W .github/workflows/backend-ci.yaml

# Solo code quality
act -j code-quality -W .github/workflows/backend-ci.yaml
```

### 4. Dry-run (ver qué haría sin ejecutar)
```bash
act -n -W .github/workflows/backend-ci.yaml
```

### 5. Ver logs detallados (verbose)
```bash
act -v -j unit-tests -W .github/workflows/backend-ci.yaml
```

---

## 🐍 Comandos Específicos del Proyecto

### Backend CI Pipeline

```bash
# 1. Code Quality (Ruff + Black + MyPy)
act -j code-quality -W .github/workflows/backend-ci.yaml

# 2. Unit Tests (pytest + coverage)
act -j unit-tests -W .github/workflows/backend-ci.yaml

# 3. Security Scan (bandit + safety)
act -j security-check -W .github/workflows/backend-ci.yaml

# 4. Startup Verification
act -j startup-test -W .github/workflows/backend-ci.yaml
```

### Frontend CI Pipeline

```bash
# Flutter Analysis & Tests
act -j flutter-tests -W .github/workflows/frontend-ci.yaml
```

### Docker Build Pipeline

```bash
# Dockerfile & Compose Validation
act -j docker-validation -W .github/workflows/docker-build.yaml
```

### Lint Pipeline

```bash
# English Compliance Audit
act -j english-compliance -W .github/workflows/lint.yml

# Python Linting
act -j python-lint -W .github/workflows/lint.yml

# Dart Linting
act -j dart-lint -W .github/workflows/lint.yml
```

---

## 🛠️ Script Interactivo

Puedes usar el script helper incluido:

```bash
./scripts/test-workflows-locally.sh
```

Esto abre un menú interactivo con todas las opciones disponibles.

---

## 🔧 Troubleshooting

### Error: "docker: command not found"
**Solución:** Asegúrate de que Docker esté instalado y corriendo:
```bash
sudo systemctl start docker
docker ps
```

### Error: "permission denied while trying to connect to the Docker daemon"
**Solución:** Agrega tu usuario al grupo docker:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Error: Workflow no encuentra archivos
**Solución:** Ejecuta `act` desde la raíz del proyecto:
```bash
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai
act --list
```

### Los tests fallan localmente pero pasan en GitHub
**Razón:** `act` usa imágenes Docker diferentes. Puedes especificar la imagen exacta:
```bash
act -P ubuntu-latest=catthehacker/ubuntu:act-latest
```

### Quiero usar las MISMAS imágenes que GitHub Actions
```bash
# Usar imágenes más completas (más lentas pero más precisas)
act -P ubuntu-latest=catthehacker/ubuntu:full-latest
```

---

## 📚 Recursos Adicionales

- **Documentación oficial:** https://github.com/nektos/act
- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Docker Hub Images:** https://hub.docker.com/u/catthehacker

---

## 💡 Tips de Rendimiento

1. **Cachear dependencias:** `act` puede reutilizar imágenes Docker entre ejecuciones
2. **Ejecutar solo lo necesario:** Usa `-j <job-name>` en lugar de ejecutar todo el workflow
3. **Dry-run primero:** Usa `-n` para validar sintaxis sin ejecutar
4. **Verbose solo cuando falla:** `-v` genera muchos logs, úsalo solo para debugging

---

## ⚠️ Limitaciones Conocidas

- **Secretos:** `act` no tiene acceso a GitHub Secrets por defecto (usa `.secrets` local)
- **Eventos complejos:** Algunos triggers complejos pueden no funcionar igual
- **Cache Actions:** Las acciones de cache pueden comportarse diferente
- **Matrix builds:** Funciona, pero puede ser lento localmente

---

**Última actualización:** 01/02/2026
**Autor:** ArchitectZero
