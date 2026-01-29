#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# 🔍 SoftArchitect AI - Docker Setup Validator
#
# Validates that Docker configuration is correct and functional
# before starting services.
#
# Usage: bash validate-docker-setup.sh
# ═══════════════════════════════════════════════════════════════

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0

# ─────────────────────────────────────────────────────────────
# Utility Functions
# ─────────────────────────────────────────────────────────────

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

check_pass() {
    echo -e "${GREEN}✓ $1${NC}"
    ((CHECKS_PASSED++))
}

check_fail() {
    echo -e "${RED}✗ $1${NC}"
    ((CHECKS_FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((CHECKS_WARNED++))
}

# ─────────────────────────────────────────────────────────────
# CHECK 1: Docker Installed
# ─────────────────────────────────────────────────────────────

print_header "1. Checking if Docker is Installed"

if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    check_pass "Docker found: $DOCKER_VERSION"
else
    check_fail "Docker is NOT installed"
    echo "  → Install: https://docs.docker.com/get-docker/"
fi

# ─────────────────────────────────────────────────────────────
# CHECK 2: Docker Daemon Running
# ─────────────────────────────────────────────────────────────

print_header "2. Checking if Docker Daemon is Running"

if docker ps &> /dev/null; then
    check_pass "Docker daemon is running"
else
    check_fail "Docker daemon is NOT running"
    echo "  → On Linux: sudo systemctl start docker"
    echo "  → On macOS/Windows: Open Docker Desktop"
fi

# ─────────────────────────────────────────────────────────────
# CHECK 3: Docker Compose
# ─────────────────────────────────────────────────────────────

print_header "3. Checking if Docker Compose is Available"

if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version | awk '{print $4}')
    check_pass "Docker Compose found: $COMPOSE_VERSION"
else
    check_fail "Docker Compose NOT found (requires v2.0+)"
    echo "  → Install: https://docs.docker.com/compose/install/"
fi

# ─────────────────────────────────────────────────────────────
# CHECK 4: System Resources Available
# ─────────────────────────────────────────────────────────────

print_header "4. Checking System Resources"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    AVAILABLE_RAM=$(free -h | awk 'NR==2 {print $7}')
    AVAILABLE_DISK=$(df -h / | awk 'NR==2 {print $4}')
    echo "  Available RAM: $AVAILABLE_RAM"
    echo "  Available Disk: $AVAILABLE_DISK"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    AVAILABLE_RAM=$(vm_stat | grep "Pages free" | awk '{print int($3/256)}')MB
    echo "  Available RAM: ~$AVAILABLE_RAM"
fi

RAM_GB=$(echo "$AVAILABLE_RAM" | sed 's/G.*//' | tr -d ' ')
if [[ -z "$RAM_GB" ]] || [[ "$RAM_GB" -lt 8 ]]; then
    check_warn "Available RAM appears < 8GB (recommended 8GB+)"
    echo "  → If Ollama crashes: reduce OLLAMA_MEMORY_LIMIT in .env"
else
    check_pass "Sufficient RAM ($AVAILABLE_RAM)"
fi

DISK_GB=$(echo "$AVAILABLE_DISK" | sed 's/G.*//' | tr -d ' ')
if [[ -z "$DISK_GB" ]] || [[ "$DISK_GB" -lt 20 ]]; then
    check_warn "Available disk < 20GB (recommended 20GB+)"
else
    check_pass "Sufficient disk space ($AVAILABLE_DISK)"
fi

# ─────────────────────────────────────────────────────────────
# CHECK 5: Project Directory Structure
# ─────────────────────────────────────────────────────────────

print_header "5. Checking Project Directory Structure"

# From anywhere, find project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

REQUIRED_DIRS=(
    "src/server"
    "src/client"
    "packages/knowledge_base"
    "infrastructure"
    "context"
    "doc"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$PROJECT_ROOT/$dir" ]]; then
        check_pass "Directory found: $dir"
    else
        check_fail "Directory MISSING: $dir"
    fi
done

# ─────────────────────────────────────────────────────────────
# CHECK 6: Configuration Files
# ─────────────────────────────────────────────────────────────

print_header "6. Checking Configuration Files"

if [[ -f "$PROJECT_ROOT/src/server/Dockerfile" ]]; then
    check_pass "Dockerfile exists"
else
    check_fail "Dockerfile MISSING in src/server/"
fi

if [[ -f "$PROJECT_ROOT/infrastructure/docker-compose.yml" ]]; then
    check_pass "docker-compose.yml exists"
else
    check_fail "docker-compose.yml MISSING in infrastructure/"
fi

if [[ -f "$PROJECT_ROOT/infrastructure/.env" ]] || [[ -f "$PROJECT_ROOT/infrastructure/.env.example" ]]; then
    check_pass "Environment file for infrastructure exists"
else
    check_fail ".env MISSING in infrastructure/ (copy from .env.example)"
fi

if [[ -f "$PROJECT_ROOT/src/server/.env" ]] || [[ -f "$PROJECT_ROOT/src/server/.env.example" ]]; then
    check_pass "Environment file for src/server exists"
else
    check_fail ".env MISSING in src/server/ (copy from .env.example)"
fi

# ─────────────────────────────────────────────────────────────
# CHECK 7: Available Ports
# ─────────────────────────────────────────────────────────────

print_header "7. Checking Available Ports"

check_port() {
    local port=$1
    local service=$2
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
            check_warn "Port $port already in use (service: $service)"
            echo "  → Change in docker-compose.yml or stop process on port $port"
        else
            check_pass "Port $port available (for $service)"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if lsof -i :$port >/dev/null 2>&1; then
            check_warn "Port $port already in use (service: $service)"
        else
            check_pass "Port $port available (for $service)"
        fi
    else
        check_pass "Port $port check skipped (unknown system)"
    fi
}

check_port 8000 "API"
check_port 11434 "Ollama" 
check_port 8001 "ChromaDB (alternate)"

# ─────────────────────────────────────────────────────────────
# CHECK 8: YAML Syntax
# ─────────────────────────────────────────────────────────────

print_header "8. Checking docker-compose.yml YAML Syntax"

if docker compose -f "$PROJECT_ROOT/infrastructure/docker-compose.yml" config > /dev/null 2>&1; then
    check_pass "docker-compose.yml has valid YAML syntax"
else
    check_fail "docker-compose.yml has SYNTAX ERRORS"
    docker compose -f "$PROJECT_ROOT/infrastructure/docker-compose.yml" config 2>&1 | head -20
fi

# ─────────────────────────────────────────────────────────────
# CHECK 9: NVIDIA GPU (Optional)
# ─────────────────────────────────────────────────────────────

print_header "9. Checking for NVIDIA GPU (Optional)"

if command -v nvidia-smi &> /dev/null; then
    GPU_COUNT=$(nvidia-smi --list-gpus | wc -l)
    check_pass "NVIDIA GPU detected: $GPU_COUNT GPU(s)"
    
    if docker run --rm --gpus all nvidia/cuda:12.0.0-runtime-base nvidia-smi &> /dev/null; then
        check_pass "NVIDIA Container Toolkit is working"
    else
        check_warn "NVIDIA Container Toolkit NOT working (comment GPU section in docker-compose.yml)"
    fi
else
    echo "  ℹ NVIDIA GPU not detected (OK for CPU-only, but slower)"
fi

# ─────────────────────────────────────────────────────────────
# FINAL SUMMARY
# ─────────────────────────────────────────────────────────────

print_header "📊 VALIDATION SUMMARY"

TOTAL=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNED))

echo "Checks executed: $TOTAL"
echo -e "  ${GREEN}✓ Passed: $CHECKS_PASSED${NC}"
echo -e "  ${YELLOW}⚠ Warnings: $CHECKS_WARNED${NC}"
echo -e "  ${RED}✗ Failures: $CHECKS_FAILED${NC}"

echo ""

if [[ $CHECKS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ CONFIGURATION READY TO USE${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. cd infrastructure"
    echo "  2. docker compose up --build"
    echo "  3. Visit http://localhost:8000/docs"
    echo ""
    exit 0
else
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}✗ FIX THE ERRORS ABOVE BEFORE PROCEEDING${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    exit 1
fi
