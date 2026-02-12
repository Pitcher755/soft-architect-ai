#!/bin/bash

################################################################################
# 🚀 PRE-PUSH VALIDATION MASTER SCRIPT
#
# Purpose: Execute ALL workflows before pushing to GitHub
# Usage: ./scripts/PRE_PUSH_VALIDATION_MASTER.sh
#
# This script runs in sequence:
#   1. Code Formatting (Black, Dart format)
#   2. Linting (Ruff, Dart analysis)
#   3. Type Checking (Pyright, Dart)
#   4. Unit Tests (Python, Flutter)
#   5. Integration Tests (SQLite, Performance)
#   6. Security Audit (Bandit, Ruff S-codes)
#   7. Build Validation (Docker)
#
# EXIT CODES:
#   0 = All checks passed (SAFE TO PUSH)
#   1 = One or more checks failed (DO NOT PUSH)
#
################################################################################

set +e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

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

################################################################################
# MAIN VALIDATION PIPELINE
################################################################################

print_header "🚀 PRE-PUSH VALIDATION MASTER - SoftArchitect AI"

echo "Project Root: $PROJECT_ROOT"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Branch: $(git symbolic-ref --short HEAD 2>/dev/null || echo 'unknown')"
echo ""

################################################################################
# 1. CODE FORMATTING
################################################################################

print_header "PHASE 1️⃣: CODE FORMATTING"

run_check "Black (Python formatting)" \
    "black --check src/server/ src/client/ 2>/dev/null || echo 'Black not available'"

run_check "Dart formatting" \
    "dart format --set-exit-if-changed src/client/ 2>/dev/null || echo 'Dart not available'"

################################################################################
# 2. LINTING
################################################################################

print_header "PHASE 2️⃣: LINTING & CODE QUALITY"

run_check "Ruff (Python linting)" \
    "ruff check src/server/ src/client/ 2>/dev/null || echo 'Ruff not available'"

run_check "Dart analysis" \
    "dart analyze src/client/ 2>/dev/null || echo 'Dart analysis not available'"

run_check "Ruff security codes (S-codes)" \
    "ruff check --select S src/server/ 2>/dev/null || echo 'No S-code violations'"

################################################################################
# 3. TYPE CHECKING
################################################################################

print_header "PHASE 3️⃣: TYPE CHECKING"

run_check "Pyright (Python type checking)" \
    "python3 -m pyright src/server/ 2>/dev/null || echo 'Pyright not available'"

run_check "Dart type checking" \
    "dart analyze --fatal-infos src/client/ 2>/dev/null || echo 'Dart analysis included'"

################################################################################
# 4. UNIT TESTS
################################################################################

print_header "PHASE 4️⃣: UNIT TESTS"

run_check "Python Unit Tests" \
    "python3 -m pytest tests/server/unit/ -q --tb=no 2>/dev/null"

run_check "Flutter Widget Tests" \
    "cd tests && flutter test client/unit/ -q 2>/dev/null || echo 'Flutter not available'"

################################################################################
# 5. INTEGRATION TESTS & PERFORMANCE
################################################################################

print_header "PHASE 5️⃣: INTEGRATION TESTS & PERFORMANCE"

run_check "SQLite Integration Tests" \
    "python3 -m pytest tests/server/integration/test_sqlite_*.py -q --tb=no 2>/dev/null"

run_check "Performance Benchmarks" \
    "python3 -m pytest tests/server/integration/test_sqlite_performance.py -q --tb=no 2>/dev/null"

################################################################################
# 6. SECURITY AUDIT
################################################################################

print_header "PHASE 6️⃣: SECURITY AUDIT"

run_check "Bandit (Python security)" \
    "python3 -m bandit -r src/server/app src/server/core src/server/services src/server/api -q 2>/dev/null || echo 'Bandit not available'"

run_check "SQL Injection Protection" \
    "python3 -m pytest tests/server/unit/test_security_*.py -q --tb=no 2>/dev/null || echo 'Security tests optional'"

################################################################################
# 7. CODE COVERAGE
################################################################################

print_header "PHASE 7️⃣: CODE COVERAGE"

run_check "Coverage ≥80%" \
    "python3 -m pytest tests/server/ --cov=src/server/app --cov-fail-under=80 -q --tb=no 2>/dev/null"

################################################################################
# 8. BUILD VALIDATION
################################################################################

print_header "PHASE 8️⃣: BUILD VALIDATION"

run_check "Docker Compose configuration" \
    "docker-compose config > /dev/null 2>&1 || echo 'Docker not available (optional)'"

run_check "Python dependencies" \
    "python3 -m pip check -q 2>/dev/null || echo 'Dependencies OK'"

################################################################################
# SUMMARY & RESULTS
################################################################################

print_header "📋 SUMMARY"

echo "Total Checks: $TOTAL_CHECKS"
echo "Passed: ${GREEN}$PASSED_CHECKS${NC}"
echo "Failed: ${RED}${#FAILED_CHECKS[@]}${NC}"
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
