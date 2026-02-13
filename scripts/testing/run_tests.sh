#!/bin/bash
# Unified comprehensive test runner
# Usage: ./scripts/testing/run_tests.sh [all|flutter|python] [--coverage]

set +e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

MODE="${1:-all}"
WITH_COVERAGE="false"
if [[ "$*" == *"--coverage"* ]]; then
  WITH_COVERAGE="true"
fi

print_header() {
  echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}$1${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"
}

print_step() { echo -e "${BLUE}▶ $1${NC}"; }
print_ok() { echo -e "${GREEN}✅ $1${NC}"; }
print_fail() { echo -e "${RED}❌ $1${NC}"; }
print_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

extract_flutter_count() {
  local file="$1"
  grep -oP '\+\K\d+(?=\s*~?\d*:\s*$)|\+\K\d+(?=:)' "$file" | tail -1
}

extract_pytest_counts() {
  local file="$1"
  local passed failed skipped
  passed=$(grep -oP '\b\d+(?= passed\b)' "$file" | tail -1)
  failed=$(grep -oP '\b\d+(?= failed\b)' "$file" | tail -1)
  skipped=$(grep -oP '\b\d+(?= skipped\b)' "$file" | tail -1)
  echo "${passed:-0} ${failed:-0} ${skipped:-0}"
}

run_flutter_suite() {
  local label="$1"
  local path="$2"
  local outfile="$3"

  if [ ! -d "tests/$path" ]; then
    print_warn "$label: carpeta no encontrada ($path)" >&2
    echo "0 0"; return
  fi

  print_step "$label" >&2
  (cd tests && flutter test "$path" --reporter=compact) >"$outfile" 2>&1
  local exit_code=$?
  local count
  count=$(extract_flutter_count "$outfile")
  count=${count:-0}

  if [ $exit_code -eq 0 ]; then
    print_ok "$label ($count tests)" >&2
    echo "$count 0"
  else
    print_fail "$label" >&2
    echo "$count 1"
  fi
}

run_python_suite() {
  local label="$1"
  local path="$2"
  local outfile="$3"

  if [ ! -d "$path" ]; then
    print_warn "$label: carpeta no encontrada ($path)" >&2
    echo "0 0 0 1"; return
  fi

  print_step "$label" >&2
  tests/venv/bin/python -m pytest "$path" -q --tb=no >"$outfile" 2>&1
  local exit_code=$?
  read -r passed failed skipped < <(extract_pytest_counts "$outfile")

  if [ $exit_code -eq 0 ]; then
    print_ok "$label ($passed passed, $skipped skipped)" >&2
  else
    print_fail "$label ($passed passed, $failed failed, $skipped skipped)" >&2
  fi

  echo "$passed $failed $skipped $exit_code"
}

print_header "🧪 SoftArchitect AI - Unified Test Suite"

echo "Project Root: $PROJECT_ROOT"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Mode: $MODE"
echo "Coverage: $WITH_COVERAGE"

FLUTTER_TOTAL=0
FLUTTER_FAILED=0
PYTHON_PASSED=0
PYTHON_FAILED=0
PYTHON_SKIPPED=0
PYTHON_EXIT_FAILS=0

if [[ "$MODE" == "all" || "$MODE" == "flutter" ]]; then
  print_header "📱 Flutter Test Suites"

  read -r c f < <(run_flutter_suite "Flutter Unit" "client/unit" "/tmp/flutter_unit.log")
  FLUTTER_TOTAL=$((FLUTTER_TOTAL + c)); FLUTTER_FAILED=$((FLUTTER_FAILED + f))

  read -r c f < <(run_flutter_suite "Flutter Widget" "client/widget" "/tmp/flutter_widget.log")
  FLUTTER_TOTAL=$((FLUTTER_TOTAL + c)); FLUTTER_FAILED=$((FLUTTER_FAILED + f))

  read -r c f < <(run_flutter_suite "Flutter Integration" "client/integration" "/tmp/flutter_integration.log")
  FLUTTER_TOTAL=$((FLUTTER_TOTAL + c)); FLUTTER_FAILED=$((FLUTTER_FAILED + f))

  read -r c f < <(run_flutter_suite "Flutter E2E" "client/e2e" "/tmp/flutter_e2e.log")
  FLUTTER_TOTAL=$((FLUTTER_TOTAL + c)); FLUTTER_FAILED=$((FLUTTER_FAILED + f))
fi

if [[ "$MODE" == "all" || "$MODE" == "python" ]]; then
  print_header "🐍 Python Test Suites"

  read -r p f s e < <(run_python_suite "Python Unit" "tests/server/unit" "/tmp/python_unit.log")
  PYTHON_PASSED=$((PYTHON_PASSED + p)); PYTHON_FAILED=$((PYTHON_FAILED + f)); PYTHON_SKIPPED=$((PYTHON_SKIPPED + s)); if [ $e -ne 0 ]; then PYTHON_EXIT_FAILS=$((PYTHON_EXIT_FAILS + 1)); fi

  read -r p f s e < <(run_python_suite "Python Integration" "tests/server/integration" "/tmp/python_integration.log")
  PYTHON_PASSED=$((PYTHON_PASSED + p)); PYTHON_FAILED=$((PYTHON_FAILED + f)); PYTHON_SKIPPED=$((PYTHON_SKIPPED + s)); if [ $e -ne 0 ]; then PYTHON_EXIT_FAILS=$((PYTHON_EXIT_FAILS + 1)); fi
fi

PYTHON_COV="N/A"
FLUTTER_COV="N/A"
if [ "$WITH_COVERAGE" = "true" ] || [ "$MODE" = "all" ]; then
  print_header "📊 Coverage Summary"

  print_step "Python coverage (src/server/app)"
  tests/venv/bin/python -m pytest tests/server/ --cov=src/server/app --cov-report=term --cov-report=json:/tmp/python_cov.json --tb=no -q >/tmp/python_cov.log 2>&1
  py_cov_exit=$?
  if [ $py_cov_exit -eq 0 ] || [ $py_cov_exit -eq 1 ]; then
    PYTHON_COV=$(tests/venv/bin/python - <<'PY'
import json
from pathlib import Path
p=Path('/tmp/python_cov.json')
if p.exists():
    d=json.loads(p.read_text(encoding='utf-8'))
    v=d.get('totals',{}).get('percent_covered')
    print(f"{float(v):.1f}" if v is not None else "N/A")
else:
    print("N/A")
PY
)
    print_ok "Python coverage: ${PYTHON_COV}%"
  else
    print_fail "Python coverage execution failed"
  fi

  print_step "Flutter coverage (tests/client)"
  rm -f src/client/coverage/lcov.info
  (cd src/client && flutter test ../../tests/client/ --coverage >/tmp/flutter_cov.log 2>&1)
  fl_cov_exit=$?
  if [ $fl_cov_exit -eq 0 ] && [ -f "src/client/coverage/lcov.info" ]; then
    FLUTTER_COV=$(awk -F: '/^LF:/{lf+=$2} /^LH:/{lh+=$2} END{if(lf>0) printf "%.1f", (lh/lf)*100; else print "N/A"}' src/client/coverage/lcov.info)
    FLUTTER_COV=${FLUTTER_COV:-N/A}
    print_ok "Flutter coverage: ${FLUTTER_COV}%"
  else
    print_fail "Flutter coverage execution failed"
  fi
fi

print_header "📋 Final Summary"
TOTAL_TESTS=$((FLUTTER_TOTAL + PYTHON_PASSED + PYTHON_FAILED + PYTHON_SKIPPED))
TOTAL_FAILED=$((FLUTTER_FAILED + PYTHON_FAILED + PYTHON_EXIT_FAILS))

echo "Flutter tests: $FLUTTER_TOTAL (suite failures: $FLUTTER_FAILED)"
echo "Python tests:  passed=$PYTHON_PASSED failed=$PYTHON_FAILED skipped=$PYTHON_SKIPPED"
echo "Total tests counted: $TOTAL_TESTS"
echo "Python coverage: $PYTHON_COV%"
echo "Flutter coverage: $FLUTTER_COV%"

if [ "$TOTAL_FAILED" -eq 0 ]; then
  print_ok "All suites passed"
  exit 0
else
  print_fail "Some suites failed (total failure signals: $TOTAL_FAILED)"
  exit 1
fi
