#!/bin/bash

################################################################################
# 🚀 GITHUB ACTIONS LOCAL TESTING SCRIPT
################################################################################
# Purpose: Execute GitHub Actions workflows locally before pushing
# Author: SoftArchitect AI Team
# Version: 2.0.0
# Updated: 2026-02-16
################################################################################
#
# 📋 USAGE:
#   ./scripts/workflows/test-workflows-locally.sh
#
# 📦 REQUIREMENTS:
#   - Docker (for act runner)
#   - act (GitHub Actions local runner): https://github.com/nektos/act
#     Install: curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
#
# ✅ WHAT THIS SCRIPT DOES:
#   - Lists all available workflows
#   - Allows interactive selection of specific workflow/job
#   - Runs workflow in Docker container (emulates GitHub Actions)
#   - Shows logs and results
#
# 💡 TIP: Use this to test GitHub Actions configurations without pushing
################################################################################

set -e  # Exit on error

# ═══════════════════════════════════════════════════════════════════════════
# 1. PROJECT ROOT DETECTION (works from any directory)
# ═══════════════════════════════════════════════════════════════════════════
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT" || { echo "❌ ERROR: Cannot navigate to project root"; exit 1; }

# ═══════════════════════════════════════════════════════════════════════════
# 2. COLOR CODES & FORMATTING
# ═══════════════════════════════════════════════════════════════════════════
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color
BOLD='\033[1m'

# ═══════════════════════════════════════════════════════════════════════════
# 3. REQUIREMENTS CHECK
# ═══════════════════════════════════════════════════════════════════════════
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ ERROR: Docker not found${NC}"
    echo "Install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v act &> /dev/null; then
    echo -e "${RED}❌ ERROR: 'act' not found${NC}"
    echo "Install act: curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash"
    exit 1
fi

echo -e "${GREEN}✅ Requirements OK (Docker + act)${NC}"
echo ""

echo -e "${BLUE}🚀 GitHub Actions Local Runner${NC}\n"
echo -e "${BOLD}Project:${NC} $PROJECT_ROOT"
echo -e "${BOLD}Workflows dir:${NC} .github/workflows/"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# 4. WORKFLOW DEFINITIONS (matching .github/workflows/*.yaml)
# ═══════════════════════════════════════════════════════════════════════════
# Verified workflows (2026-02-16):
# - backend-ci.yaml: Backend CI Pipeline
# - ci-master.yaml: Master CI Pipeline
# - docker-build.yaml: Docker Build Validation
# - frontend-ci.yaml: Frontend CI Pipeline
# - lint.yml: Linting Pipeline
# - performance-tests.yml: Performance Tests

# Menú interactivo
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo "Selecciona el workflow a ejecutar:"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo ""
echo "${BOLD}BACKEND CI (backend-ci.yaml):${NC}"
echo "1) 🐍 Code Quality (Ruff + Black + Type Check)"
echo "2) 🧪 Unit Tests (pytest + coverage)"
echo "3) 🔒 Security Scan (bandit + safety)"
echo "4) ✨ Startup Verification"
echo "5) 🚀 Run COMPLETE Backend CI Pipeline"
echo ""
echo "${BOLD}FRONTEND CI (frontend-ci.yaml):${NC}"
echo "6) 🎨 Flutter Tests (unit + widget + integration)"
echo ""
echo "${BOLD}DOCKER (docker-build.yaml):${NC}"
echo "7) 🐳 Dockerfile Validation"
echo ""
echo "${BOLD}LINTING (lint.yml):${NC}"
echo "8) 📋 English Compliance"
echo ""
echo "${BOLD}PERFORMANCE (performance-tests.yml):${NC}"
echo "9) ⚡ Performance Tests"
echo ""
echo "${BOLD}MASTER CI (ci-master.yaml):${NC}"
echo "10) 🔍 Run MASTER CI Pipeline (all jobs)"
echo ""
echo "${BOLD}UTILITIES:${NC}"
echo "11) 📄 List all workflows and jobs"
echo "0) ❌ Exit"
echo ""
read -p "Option: " option

case $option in
    1)
        echo -e "\n${BLUE}Running Backend CI: Code Quality...${NC}"
        act -j code-quality -W .github/workflows/backend-ci.yaml
        ;;
    2)
        echo -e "\n${BLUE}Running Backend CI: Unit Tests...${NC}"
        act -j unit-tests -W .github/workflows/backend-ci.yaml
        ;;
    3)
        echo -e "\n${BLUE}Running Backend CI: Security Scan...${NC}"
        act -j security-check -W .github/workflows/backend-ci.yaml
        ;;
    4)
        echo -e "\n${BLUE}Running Backend CI: Startup Verification...${NC}"
        act -j startup-test -W .github/workflows/backend-ci.yaml
        ;;
    5)
        echo -e "\n${BLUE}Running COMPLETE Backend CI Pipeline...${NC}"
        act -W .github/workflows/backend-ci.yaml
        ;;
    6)
        echo -e "\n${BLUE}Running Frontend CI: Flutter Tests...${NC}"
        act -j flutter-tests -W .github/workflows/frontend-ci.yaml
        ;;
    7)
        echo -e "\n${BLUE}Running Docker: Validation...${NC}"
        act -j docker-validation -W .github/workflows/docker-build.yaml
        ;;
    8)
        echo -e "\n${BLUE}Running Lint: English Compliance...${NC}"
        act -j english-compliance -W .github/workflows/lint.yml
        ;;
    9)
        echo -e "\n${BLUE}Running Performance Tests...${NC}"
        act -W .github/workflows/performance-tests.yml
        ;;
    10)
        echo -e "\n${BLUE}Running MASTER CI Pipeline (all workflows)...${NC}"
        act -W .github/workflows/ci-master.yaml
        ;;
    11)
        echo -e "\n${BLUE}Available workflows and jobs:${NC}"
        echo ""
        act --list
        ;;
    0)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}✅ Workflow executed successfully${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  - Review the output above for any errors"
echo "  - Fix issues locally before pushing"
echo "  - Run ./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh before git push"
echo ""
