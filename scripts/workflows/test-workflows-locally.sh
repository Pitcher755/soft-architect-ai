#!/bin/bash
# Script para ejecutar GitHub Actions workflows localmente con 'act'
# Requiere: Docker + act (https://github.com/nektos/act)

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 GitHub Actions Local Runner${NC}\n"

# Función helper
run_workflow() {
    local job_name=$1
    local workflow_file=$2
    echo -e "${GREEN}▶ Ejecutando: ${job_name}${NC}"
    echo -e "${YELLOW}Workflow: ${workflow_file}${NC}\n"
    act -W ".github/workflows/${workflow_file}" "$@"
}

# Menú interactivo
echo "Selecciona el workflow a ejecutar:"
echo ""
echo "1) 🐍 Backend CI - Code Quality (Ruff + Black + MyPy)"
echo "2) 🧪 Backend CI - Unit Tests (pytest + coverage)"
echo "3) 🔒 Backend CI - Security Scan (bandit + safety)"
echo "4) ✨ Backend CI - Startup Verification"
echo "5) 🎨 Frontend CI - Flutter Tests"
echo "6) 🐳 Docker - Dockerfile Validation"
echo "7) 📋 Lint - English Compliance"
echo "8) 🔍 Listar todos los workflows disponibles"
echo "9) ▶️  Ejecutar workflow COMPLETO de Backend CI"
echo "0) Salir"
echo ""
read -p "Opción: " option

case $option in
    1)
        echo -e "\n${BLUE}Ejecutando Code Quality checks...${NC}"
        act -j code-quality -W .github/workflows/backend-ci.yaml
        ;;
    2)
        echo -e "\n${BLUE}Ejecutando Unit Tests...${NC}"
        act -j unit-tests -W .github/workflows/backend-ci.yaml
        ;;
    3)
        echo -e "\n${BLUE}Ejecutando Security Scan...${NC}"
        act -j security-check -W .github/workflows/backend-ci.yaml
        ;;
    4)
        echo -e "\n${BLUE}Ejecutando Startup Verification...${NC}"
        act -j startup-test -W .github/workflows/backend-ci.yaml
        ;;
    5)
        echo -e "\n${BLUE}Ejecutando Flutter Tests...${NC}"
        act -j flutter-tests -W .github/workflows/frontend-ci.yaml
        ;;
    6)
        echo -e "\n${BLUE}Ejecutando Docker Validation...${NC}"
        act -j docker-validation -W .github/workflows/docker-build.yaml
        ;;
    7)
        echo -e "\n${BLUE}Ejecutando English Compliance...${NC}"
        act -j english-compliance -W .github/workflows/lint.yml
        ;;
    8)
        echo -e "\n${BLUE}Workflows disponibles:${NC}"
        act --list
        ;;
    9)
        echo -e "\n${BLUE}Ejecutando TODOS los jobs del Backend CI Pipeline...${NC}"
        act -W .github/workflows/backend-ci.yaml
        ;;
    0)
        echo "Saliendo..."
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Opción inválida${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}✅ Workflow ejecutado correctamente${NC}"
