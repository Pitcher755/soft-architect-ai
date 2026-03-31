#!/bin/bash
set -o pipefail

################################################################################
# 📊 FLUTTER COVERAGE CHECK WITH THRESHOLD ENFORCEMENT
################################################################################
# Purpose: Measure Flutter test coverage, filter generated files, and enforce
#          a minimum coverage threshold on business-critical directories.
#
# Usage:
#   ./scripts/testing/flutter_coverage_check.sh [--threshold=80] [--html]
#
# Requirements:
#   - Flutter SDK
#   - lcov (sudo apt install lcov)
#
# Exit codes:
#   0 = Coverage meets threshold
#   1 = Coverage below threshold or execution error
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ─── Defaults ────────────────────────────────────────────────────────────
THRESHOLD=80
GENERATE_HTML=false

# ─── Parse arguments ─────────────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --threshold=*) THRESHOLD="${arg#*=}" ;;
    --html)        GENERATE_HTML=true ;;
    --help|-h)
      echo "Usage: $0 [--threshold=80] [--html]"
      echo "  --threshold=N  Minimum coverage percentage (default: 80)"
      echo "  --html         Generate HTML report in coverage/html/"
      exit 0
      ;;
  esac
done

# ─── Colors ──────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  📊 Flutter Coverage Check (threshold: ${THRESHOLD}%)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

# ─── Verify tools ────────────────────────────────────────────────────────
if ! command -v flutter &>/dev/null; then
  echo -e "${RED}❌ Flutter not found. Install Flutter SDK first.${NC}"
  exit 1
fi

if ! command -v lcov &>/dev/null; then
  echo -e "${RED}❌ lcov not found. Install with: sudo apt install lcov${NC}"
  exit 1
fi

# ─── Clean previous coverage ─────────────────────────────────────────────
rm -rf "$PROJECT_ROOT/coverage"
rm -rf "$PROJECT_ROOT/src/client/coverage"

# ─── Run tests with coverage ─────────────────────────────────────────────
echo -e "${CYAN}▶ Running Flutter tests with coverage...${NC}"
cd "$PROJECT_ROOT/src/client" || exit 1

if ! flutter test ../../tests/client/ --coverage --no-pub 2>&1 | tail -5; then
  echo -e "${RED}❌ Flutter tests failed${NC}"
  exit 1
fi

# ─── Verify lcov.info was generated ──────────────────────────────────────
LCOV_RAW="$PROJECT_ROOT/src/client/coverage/lcov.info"
if [ ! -f "$LCOV_RAW" ]; then
  echo -e "${RED}❌ coverage/lcov.info not generated${NC}"
  exit 1
fi

# Move to canonical location
mkdir -p "$PROJECT_ROOT/coverage"
cp "$LCOV_RAW" "$PROJECT_ROOT/coverage/lcov.info"
rm -rf "$PROJECT_ROOT/src/client/coverage"
cd "$PROJECT_ROOT" || exit 1

LCOV_FILE="$PROJECT_ROOT/coverage/lcov.info"
echo -e "${GREEN}✅ lcov.info generated ($(wc -l < "$LCOV_FILE") lines)${NC}"
echo ""

# ─── Filter: exclude generated files ─────────────────────────────────────
echo -e "${CYAN}▶ Filtering generated files...${NC}"

LCOV_FILTERED="$PROJECT_ROOT/coverage/lcov_filtered.info"

lcov --remove "$LCOV_FILE" \
  '*.g.dart' \
  '*.freezed.dart' \
  '*/gen/*' \
  '*/l10n/*' \
  '*/generated/*' \
  '*.gen.dart' \
  --ignore-errors unused \
  -o "$LCOV_FILTERED" --quiet

echo -e "${GREEN}✅ Filtered: $(wc -l < "$LCOV_FILTERED") lines remaining${NC}"
echo ""

# ─── Extract coverage per directory ───────────────────────────────────────
extract_dir_coverage() {
  local dir_pattern="$1"
  local label="$2"
  local temp_file
  temp_file=$(mktemp)

  lcov --extract "$LCOV_FILTERED" "$dir_pattern" -o "$temp_file" --quiet 2>/dev/null

  if [ -s "$temp_file" ]; then
    local pct
    pct=$(lcov --summary "$temp_file" 2>&1 | grep -oP 'lines\.*:\s*\K[\d.]+(?=%)')
    rm -f "$temp_file"
    echo "$pct"
  else
    rm -f "$temp_file"
    echo ""
  fi
}

echo -e "${CYAN}▶ Coverage breakdown by directory:${NC}"
echo ""

# Overall coverage (filtered)
OVERALL_PCT=$(lcov --summary "$LCOV_FILTERED" 2>&1 | grep -oP 'lines\.*:\s*\K[\d.]+(?=%)')
echo -e "  📦 Overall (filtered):       ${OVERALL_PCT:-N/A}%"

# Business-critical directories (must meet threshold)
DOMAIN_PCT=$(extract_dir_coverage '*/domain/*' 'domain')
INFRA_PCT=$(extract_dir_coverage '*/infrastructure/*' 'infrastructure')

echo -e "  🏛️  domain/:                  ${DOMAIN_PCT:-N/A}%"
echo -e "  🔌 infrastructure/ (data):    ${INFRA_PCT:-N/A}%"

# Informational directories (not enforced)
CORE_PCT=$(extract_dir_coverage '*/core/*' 'core')
FEATURES_PCT=$(extract_dir_coverage '*/features/*' 'features')
SERVICES_PCT=$(extract_dir_coverage '*/services/*' 'services')
SHARED_PCT=$(extract_dir_coverage '*/shared/*' 'shared')

echo -e "  ⚙️  core/:                    ${CORE_PCT:-N/A}%"
echo -e "  🧩 features/:                ${FEATURES_PCT:-N/A}%"
echo -e "  🔧 services/:                ${SERVICES_PCT:-N/A}%"
echo -e "  📎 shared/:                  ${SHARED_PCT:-N/A}%"
echo ""

# ─── Generate HTML report (optional) ─────────────────────────────────────
if [ "$GENERATE_HTML" = true ]; then
  echo -e "${CYAN}▶ Generating HTML report...${NC}"
  mkdir -p "$PROJECT_ROOT/coverage/html"
  genhtml "$LCOV_FILTERED" -o "$PROJECT_ROOT/coverage/html" --ignore-errors source --quiet
  echo -e "${GREEN}✅ HTML report: coverage/html/index.html${NC}"
  echo ""
fi

# ─── Enforce threshold ───────────────────────────────────────────────────
FAILED=0

check_threshold() {
  local label="$1"
  local pct="$2"
  local min="$3"

  if [ -z "$pct" ]; then
    echo -e "  ${YELLOW}⚠️  $label: no coverage data (no source files matched)${NC}"
    return 0
  fi

  local pct_int
  pct_int=$(LC_NUMERIC=C printf "%.0f" "$pct")

  if [ "$pct_int" -ge "$min" ]; then
    echo -e "  ${GREEN}✅ $label: ${pct}% ≥ ${min}%${NC}"
  else
    echo -e "  ${RED}❌ $label: ${pct}% < ${min}% — BELOW THRESHOLD${NC}"
    FAILED=1
  fi
}

echo -e "${CYAN}▶ Threshold enforcement (minimum: ${THRESHOLD}%):${NC}"
echo -e "  ${CYAN}(enforced on business-critical layers: domain/, infrastructure/)${NC}"
echo ""

check_threshold "domain/"         "$DOMAIN_PCT"  "$THRESHOLD"
check_threshold "infrastructure/" "$INFRA_PCT"   "$THRESHOLD"

echo ""

# Overall is informational, not enforced
if [ -n "$OVERALL_PCT" ]; then
  local_int=$(LC_NUMERIC=C printf "%.0f" "$OVERALL_PCT")
  if [ "$local_int" -ge "$THRESHOLD" ]; then
    echo -e "  ${GREEN}ℹ️  Overall (informational): ${OVERALL_PCT}% ≥ ${THRESHOLD}%${NC}"
  else
    echo -e "  ${YELLOW}ℹ️  Overall (informational): ${OVERALL_PCT}% < ${THRESHOLD}% (UI/shared layers reduce total)${NC}"
  fi
fi

echo ""

# ─── Write summary for CI (GitHub Actions) ────────────────────────────────
if [ -n "$GITHUB_STEP_SUMMARY" ]; then
  {
    echo "## 📊 Flutter Coverage Report"
    echo ""
    echo "| Directory | Coverage | Threshold | Status |"
    echo "|-----------|----------|-----------|--------|"
    echo "| domain/ | ${DOMAIN_PCT:-N/A}% | ${THRESHOLD}% | $([ -n "$DOMAIN_PCT" ] && [ "$(LC_NUMERIC=C printf '%.0f' "$DOMAIN_PCT")" -ge "$THRESHOLD" ] && echo '✅' || echo '❌') |"
    echo "| infrastructure/ | ${INFRA_PCT:-N/A}% | ${THRESHOLD}% | $([ -n "$INFRA_PCT" ] && [ "$(LC_NUMERIC=C printf '%.0f' "$INFRA_PCT")" -ge "$THRESHOLD" ] && echo '✅' || echo '❌') |"
    echo "| **Overall** | **${OVERALL_PCT:-N/A}%** | — | ℹ️ |"
    echo ""
    echo "Excluded: \`*.g.dart\`, \`*.freezed.dart\`, \`gen/\`, \`l10n/\`"
  } >> "$GITHUB_STEP_SUMMARY"
fi

# ─── Final result ─────────────────────────────────────────────────────────
if [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}  ✅ Flutter coverage meets ${THRESHOLD}% threshold${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
  exit 0
else
  echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
  echo -e "${RED}  ❌ Flutter coverage BELOW ${THRESHOLD}% threshold${NC}"
  echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
  exit 1
fi
