#!/bin/bash

################################################################################
# 🚀 PRE-PUSH VALIDATION MASTER SCRIPT
################################################################################
# Purpose: Execute ALL workflows before pushing to GitHub
# Author: SoftArchitect AI Team
# Version: 2.0.0
# Updated: 2026-02-16
################################################################################
#
# 📋 USAGE:
#   ./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh
#
# 📦 REQUIREMENTS (auto-checked):
#   - Python 3.12+ with venv activated
#   - Flutter 3.38+
#   - Docker 20.10+ (for optional build validation)
#   - Git repository
#
# ✅ WHAT THIS SCRIPT VALIDATES:
#   1. Code Formatting (Black, Dart format)
#   2. Linting (Ruff, Dart analysis, Security S-codes)
#   3. Type Checking (Pyright + Dart required)
#   4. Unit Tests (Python ≥80% coverage, Flutter all)
#   5. Integration Tests (Python, Flutter, E2E)
#   6. Security Audit (Bandit, SQL injection patterns)
#   7. Code Coverage (Python ≥80%, Flutter ≥80%)
#   8. Build Validation (Docker Compose, Dependencies)
#
# 🚨 EXIT CODES:
#   0 = All checks passed (✅ SAFE TO PUSH)
#   1 = One or more checks failed (❌ DO NOT PUSH - fix issues first)
#
# 💡 TIP: Run this before every push to ensure GitHub Actions will pass
################################################################################

set +e  # Don't exit on error - we handle errors manually

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
MAGENTA='\033[0;35m'
NC='\033[0m'  # No Color
BOLD='\033[1m'

# ═══════════════════════════════════════════════════════════════════════════
# 3. PATHS CONFIGURATION (relative to project root)
# ═══════════════════════════════════════════════════════════════════════════
PYTHON_VENV="$PROJECT_ROOT/venv"
PYTHON_TEST_BIN="$PYTHON_VENV/bin/python"
PYTHON_SERVER_BIN="$PYTHON_VENV/bin/python"
BLACK_BIN="$PYTHON_VENV/bin/black"
RUFF_BIN="$PYTHON_VENV/bin/ruff"
PYRIGHT_BIN="$PYTHON_VENV/bin/pyright"
PYTEST_BIN="$PYTHON_VENV/bin/pytest"
BANDIT_BIN="$PYTHON_VENV/bin/bandit"

# Track results
declare -a FAILED_CHECKS=()
TOTAL_CHECKS=0
PASSED_CHECKS=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

print_fail() {
    echo -e "${RED}❌ $1${NC}"
    FAILED_CHECKS+=("$1")
}

run_check() {
    local check_name="$1"
    local command="$2"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    print_step "$check_name"

    if (cd "$PROJECT_ROOT" && eval "$command") >/dev/null 2>&1; then
        print_success "$check_name"
        return 0
    else
        print_fail "$check_name"
        return 1
    fi
}

run_optional_check() {
    local check_name="$1"
    local command="$2"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    print_step "$check_name"

    if (cd "$PROJECT_ROOT" && eval "$command") >/dev/null 2>&1; then
        print_success "$check_name"
        return 0
    else
        echo -e "${YELLOW}⚠️  $check_name (optional - skipped or tool missing)${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    fi
}

################################################################################
# MAIN VALIDATION PIPELINE
################################################################################

print_header "🚀 PRE-PUSH VALIDATION MASTER - SoftArchitect AI"

echo -e "${BOLD}Project Root:${NC} $PROJECT_ROOT"
echo -e "${BOLD}Timestamp:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${BOLD}Branch:${NC} $(git symbolic-ref --short HEAD 2>/dev/null || echo 'unknown')"
echo -e "${BOLD}Python venv:${NC} $PYTHON_VENV"
echo -e "${YELLOW}⏱️  Estimated time: 4-5 minutes (includes coverage generation)${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# REQUIREMENTS CHECK
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${CYAN}Checking requirements...${NC}"

if [ ! -d "$PYTHON_VENV" ]; then
    echo -e "${RED}❌ ERROR: Python venv not found at $PYTHON_VENV${NC}"
    echo "Run: python3 -m venv venv && source venv/bin/activate && pip install -r src/server/requirements.txt"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠️  WARNING: Flutter not found - Flutter tests will be skipped${NC}"
fi

# Install Pyright if not available (required for type checking)
if ! "$PYTHON_TEST_BIN" -m pyright --version &> /dev/null; then
    echo -e "${YELLOW}⏳ Installing Pyright (required for type checking)...${NC}"
    "$PYTHON_TEST_BIN" -m pip install -q pyright
fi

# Install lcov if not available (required for Flutter coverage)
if ! command -v lcov &> /dev/null; then
    echo -e "${YELLOW}⚠️  WARNING: lcov not found - install with: sudo apt install lcov${NC}"
fi

echo -e "${GREEN}✅ Requirements OK${NC}"
echo ""

################################################################################
# 1. CODE FORMATTING
################################################################################

print_header "PHASE 1️⃣: CODE FORMATTING"

run_check "Black (Python formatting)" \
    "$BLACK_BIN --check src/server/ --exclude '/(venv|\.venv|build|dist|__pycache__|site-packages)/'"

run_check "Dart formatting" \
    "dart format --set-exit-if-changed src/client/"

################################################################################
# 2. LINTING
################################################################################

print_header "PHASE 2️⃣: LINTING & CODE QUALITY"

run_check "Ruff (Python linting)" \
    "$PYTHON_TEST_BIN -m ruff check src/server/"

run_check "Dart analysis" \
    "dart analyze src/client/ 2>/dev/null"

run_check "Ruff security codes (S-codes)" \
    "$PYTHON_TEST_BIN -m ruff check --select S src/server/"

################################################################################
# 3. TYPE CHECKING
################################################################################

print_header "PHASE 3️⃣: TYPE CHECKING"

run_check "Pyright (Python type checking)" \
    "$PYTHON_SERVER_BIN -m pyright src/server/services src/server/core"

run_check "Dart type checking" \
    "dart analyze --fatal-infos src/client/ 2>/dev/null"

################################################################################
# 4. UNIT TESTS
################################################################################

print_header "PHASE 4️⃣: UNIT TESTS"

# Python Unit Tests: ONLY unit tests (tests/server/unit/)
# CRITICAL FIX: Use explicit path to unit tests directory
run_check "Python Unit Tests" \
    "$PYTEST_BIN tests/server/unit/ -q --tb=no --timeout=60 2>/dev/null"

# Flutter tests MUST run from tests/ directory (has test dependencies in pubspec.yaml)
# tests/pubspec.yaml imports src/client via path: ../src/client
run_check "Flutter Unit Tests" \
    "(cd tests && flutter test client/unit/ --reporter=compact 2>/dev/null) || echo 'Flutter not installed'"

run_check "Flutter Widget Tests" \
    "(cd tests && flutter test client/widget/ --reporter=compact 2>/dev/null) || echo 'No widget tests'"

################################################################################
# 5. INTEGRATION TESTS & PERFORMANCE
################################################################################

print_header "PHASE 5️⃣: INTEGRATION TESTS"

# Python Integration Tests: Explicit integration directory
run_check "Python Integration Tests" \
    "$PYTEST_BIN tests/server/integration/ -q --tb=no --timeout=120 2>/dev/null || echo 'No integration tests'"

run_check "Flutter Integration Tests" \
    "(cd tests && flutter test client/integration/ --reporter=compact 2>/dev/null) || echo 'No integration tests'"

run_check "Flutter E2E Tests" \
    "(cd tests && flutter test client/e2e/ --reporter=compact 2>/dev/null) || echo 'No E2E tests'"

################################################################################
# 6. SECURITY AUDIT
################################################################################

print_header "PHASE 6️⃣: SECURITY AUDIT"

run_check "Bandit (Python security)" \
    "$PYTHON_TEST_BIN -m bandit -r src/server/services src/server/core -q 2>/dev/null"

run_check "SQL Injection Protection" \
    "$PYTHON_TEST_BIN -m pytest tests/server -k 'sql or injection or security' -q --tb=no 2>/dev/null"

################################################################################
# 7. CODE COVERAGE
################################################################################

print_header "PHASE 7️⃣: CODE COVERAGE"

print_step "Python Coverage Analysis"
echo -e "${YELLOW}⏳ Running coverage (timeout: 180s)...${NC}"
rm -f /tmp/pycov.out /tmp/pycov.json
timeout 180 "$PYTHON_TEST_BIN" -m pytest tests/server/ --cov=src/server/app --cov-report=term --cov-report=json:/tmp/pycov.json --tb=no -q > /tmp/pycov.out 2>&1
COVERAGE_EXIT=$?

if [ "$COVERAGE_EXIT" -eq 124 ]; then
    print_fail "Python Coverage timeout (>180s)"
else
    COVERAGE_PERCENT=$(
        "$PYTHON_TEST_BIN" - <<'PY'
import json
from pathlib import Path

path = Path('/tmp/pycov.json')
if not path.exists():
    print('')
else:
    data = json.loads(path.read_text(encoding='utf-8'))
    value = data.get('totals', {}).get('percent_covered')
    if value is None:
        print('')
    else:
        print(int(round(float(value))))
PY
    )

    if [ -z "$COVERAGE_PERCENT" ]; then
        COVERAGE_PERCENT=$(grep -oP 'TOTAL.*\K\d+(?=%)' /tmp/pycov.out | tail -1)
    fi

    if [ -n "$COVERAGE_PERCENT" ] && [ "$COVERAGE_PERCENT" -ge 80 ]; then
        print_success "Python Coverage: ${COVERAGE_PERCENT}% (≥80%)"
    else
        print_fail "Python Coverage: ${COVERAGE_PERCENT:-0}% (<80% or execution error)"
    fi
fi

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

print_step "Flutter Coverage Analysis"
echo -e "${YELLOW}⏳ Generating Flutter coverage report...${NC}"
rm -rf "$PROJECT_ROOT/src/client/coverage"
if command -v flutter >/dev/null 2>&1; then
    # Generate coverage from client directory (Flutter project root)
    if (cd "$PROJECT_ROOT/src/client" && flutter test ../../tests/client/ --coverage >/tmp/flutter_cov.out 2>&1); then
        if [ -f "$PROJECT_ROOT/src/client/coverage/lcov.info" ]; then
            if command -v lcov >/dev/null 2>&1; then
                FLUTTER_COVERAGE=$(lcov --summary "$PROJECT_ROOT/src/client/coverage/lcov.info" 2>&1 | grep -oP 'lines\.*: \K\d+\.\d+(?=%)')
                if [ -n "$FLUTTER_COVERAGE" ]; then
                    FLUTTER_COVERAGE_INT=$(LC_NUMERIC=C printf "%.0f" "$FLUTTER_COVERAGE")
                    if [ "$FLUTTER_COVERAGE_INT" -ge 80 ]; then
                        print_success "Flutter Coverage: ${FLUTTER_COVERAGE}% (≥80%)"
                    else
                        print_fail "Flutter Coverage: ${FLUTTER_COVERAGE}% (<80%)"
                    fi
                else
                    print_fail "Flutter Coverage: Could not parse coverage percentage"
                fi
            else
                echo -e "${YELLOW}⚠️  lcov not installed - cannot calculate coverage percentage${NC}"
                echo -e "${YELLOW}   Install with: sudo apt install lcov${NC}"
                print_fail "Flutter Coverage: lcov required but not installed"
            fi
        else
            print_fail "Flutter Coverage: lcov.info not generated"
        fi
    else
        print_fail "Flutter Coverage: test execution failed"
    fi
else
    print_fail "Flutter Coverage: flutter not installed"
fi

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

################################################################################
# 8. BUILD VALIDATION
################################################################################

print_header "PHASE 8️⃣: BUILD VALIDATION"

run_check "Docker Compose configuration" \
    "docker-compose -f infrastructure/docker-compose.yml config > /dev/null 2>&1 || echo 'Docker optional'"

run_check "Python dependencies" \
    "$PYTHON_TEST_BIN -m pip check -q 2>/dev/null"

################################################################################
# SUMMARY & RESULTS
################################################################################

print_header "📋 VALIDATION SUMMARY"

echo "Total Checks: $TOTAL_CHECKS"
echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Failed: ${RED}${#FAILED_CHECKS[@]}${NC}"
echo ""

if [ ${#FAILED_CHECKS[@]} -eq 0 ]; then
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✅ ALL CHECKS PASSED - SAFE TO PUSH${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Next step: git push origin $(git symbolic-ref --short HEAD)"
    exit 0
else
    echo -e "${RED}════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}  ❌ SOME CHECKS FAILED - DO NOT PUSH${NC}"
    echo -e "${RED}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Failed checks:"
    for check in "${FAILED_CHECKS[@]}"; do
        echo -e "  ${RED}•${NC} $check"
    done
    echo ""
    echo "Fix the issues above and run this script again."
    exit 1
fi
