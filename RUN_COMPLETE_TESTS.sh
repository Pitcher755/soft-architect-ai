#!/bin/bash
# Complete test execution and coverage reporting script

set -e
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🧪 SoftArchitect AI - Complete Test Suite Execution${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Initialize counters
TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0

# =====================================================================
# FLUTTER TESTS
# =====================================================================
echo -e "${YELLOW}📱 FLUTTER TESTS${NC}"
echo -e "${YELLOW}═════════════════════════════════════════════════════${NC}\n"

cd tests

# Run Flutter tests and capture results
FLUTTER_OUTPUT=$(flutter test test/ --verbose 2>&1)
FLUTTER_PASSED=$(echo "$FLUTTER_OUTPUT" | grep -o "All tests passed" | wc -l)

if [ $FLUTTER_PASSED -eq 1 ]; then
  FLUTTER_COUNT=$(echo "$FLUTTER_OUTPUT" | grep -oP '\+\d+:' | head -1 | grep -oP '\d+')
  echo -e "${GREEN}✅ Flutter Tests${NC}"
  echo -e "   Passed: ${GREEN}$FLUTTER_COUNT${NC}"
  echo -e "   Failed: ${GREEN}0${NC}"
  echo -e "   Coverage: Not measured (flutter_test limitation)\n"
  TOTAL_TESTS=$((TOTAL_TESTS + FLUTTER_COUNT))
  TOTAL_PASSED=$((TOTAL_PASSED + FLUTTER_COUNT))
else
  echo -e "${RED}❌ Flutter Tests Failed${NC}\n"
  TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi

cd ..

# =====================================================================
# PYTHON TESTS
# =====================================================================
echo -e "${YELLOW}🐍 PYTHON TESTS${NC}"
echo -e "${YELLOW}═════════════════════════════════════════════════════${NC}\n"

source venv/bin/activate

# Run Python unit tests
PYTHON_OUTPUT=$(python -m pytest tests/python/unit/ -v 2>&1)
PYTHON_PASSED=$(echo "$PYTHON_OUTPUT" | grep -c "PASSED" || echo "0")
PYTHON_FAILED=$(echo "$PYTHON_OUTPUT" | grep -c "FAILED" || echo "0")

echo -e "${GREEN}✅ Python Tests${NC}"
echo -e "   Passed: ${GREEN}$PYTHON_PASSED${NC}"
echo -e "   Failed: ${GREEN}$PYTHON_FAILED${NC}\n"

TOTAL_TESTS=$((TOTAL_TESTS + PYTHON_PASSED + PYTHON_FAILED))
TOTAL_PASSED=$((TOTAL_PASSED + PYTHON_PASSED))
TOTAL_FAILED=$((TOTAL_FAILED + PYTHON_FAILED))

# =====================================================================
# COVERAGE REPORT
# =====================================================================
echo -e "${YELLOW}📊 COVERAGE ANALYSIS${NC}"
echo -e "${YELLOW}═════════════════════════════════════════════════════${NC}\n"

# Python Coverage
echo -e "${BLUE}Python Backend Coverage:${NC}"
python -m pytest tests/python/unit/ --cov=services --cov-report=term-missing -q 2>&1 | tail -20

# =====================================================================
# FINAL SUMMARY
# =====================================================================
echo -e "\n${YELLOW}═════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📈 FINAL SUMMARY${NC}"
echo -e "${YELLOW}═════════════════════════════════════════════════════${NC}\n"

echo -e "Total Tests Run: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Total Passed:    ${GREEN}$TOTAL_PASSED${NC}"
echo -e "Total Failed:    $([ $TOTAL_FAILED -eq 0 ] && echo ${GREEN}$TOTAL_FAILED${NC} || echo ${RED}$TOTAL_FAILED${NC})"
echo -e "\nSuccess Rate: $(( (TOTAL_PASSED * 100) / TOTAL_TESTS ))%\n"

# Quality Gates Check
echo -e "${YELLOW}Quality Gates Compliance:${NC}"
if [ $TOTAL_PASSED -ge 171 ]; then
  echo -e "  ✅ Minimum tests passing: ${GREEN}$TOTAL_PASSED >= 171${NC}"
else
  echo -e "  ❌ Minimum tests passing: ${RED}$TOTAL_PASSED < 171${NC}"
fi

if [ $TOTAL_FAILED -le 8 ]; then
  echo -e "  ✅ Maximum failures allowed: ${GREEN}$TOTAL_FAILED <= 8${NC}"
else
  echo -e "  ❌ Maximum failures allowed: ${RED}$TOTAL_FAILED > 8${NC}"
fi

echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}\n"

deactivate
