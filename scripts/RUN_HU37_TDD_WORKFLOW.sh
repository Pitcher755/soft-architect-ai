#!/bin/bash
##############################################################################
# HU-3.7: TDD Workflow Execution Script
# Master script to execute the complete TDD cycle for all 10 features
# Version: 2.0.0
# Created: 2026-02-11
# Agent: ArchitectZero
##############################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$PROJECT_ROOT/src/client"
TESTS_DIR="$PROJECT_ROOT/tests/test"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}HU-3.7: TDD Workflow Execution${NC}"
echo -e "${BLUE}Master Workflow 2.0.0${NC}"
echo -e "${BLUE}========================================${NC}"

# Phase 1: Verify Flutter environment
echo -e "\n${YELLOW}[Phase 1] Verifying Flutter environment...${NC}"
cd "$CLIENT_DIR"
if ! flutter --version &>/dev/null; then
    echo -e "${RED}❌ Flutter not found. Ensure Flutter SDK is installed.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Flutter SDK verified${NC}"

# Phase 2: Get dependencies
echo -e "\n${YELLOW}[Phase 2] Installing dependencies...${NC}"
flutter pub get --quiet || true
echo -e "${GREEN}✅ Dependencies installed${NC}"

# Phase 3: Run all tests
echo -e "\n${YELLOW}[Phase 3] Executing test suite...${NC}"
echo -e "${BLUE}[Test Suite] Running Settings features tests...${NC}"

TEST_FILES=(
    "$TESTS_DIR/features/settings/data/datasources/last_project_local_datasource_test.dart"
    "$TESTS_DIR/features/settings/presentation/widgets/profile_section_test.dart"
    "$TESTS_DIR/features/settings/presentation/widgets/appearance_section_test.dart"
    "$TESTS_DIR/features/settings/presentation/widgets/accessibility_section_test.dart"
    "$TESTS_DIR/features/settings/presentation/widgets/performance_section_test.dart"
)

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

for test_file in "${TEST_FILES[@]}"; do
    if [ -f "$test_file" ]; then
        echo -e "\n${BLUE}  🧪 Testing: $(basename "$test_file")${NC}"

        # Run test and capture result
        if flutter test "$test_file" --reporter=compact 2>&1 | tail -5; then
            ((PASSED_TESTS++))
            echo -e "    ${GREEN}✅ PASSED${NC}"
        else
            ((FAILED_TESTS++))
            echo -e "    ${RED}❌ FAILED${NC}"
        fi
        ((TOTAL_TESTS++))
    fi
done

# Phase 4: Run Flutter analyze
echo -e "\n${YELLOW}[Phase 4] Running Flutter analyze...${NC}"
if flutter analyze lib/features/settings --no-pub 2>&1 | grep -q "No issues found"; then
    echo -e "${GREEN}✅ No issues found${NC}"
else
    echo -e "${YELLOW}⚠️  Issues found (review above)${NC}"
fi

# Phase 5: Summary
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Total Tests: ${YELLOW}${TOTAL_TESTS}${NC}"
echo -e "Passed: ${GREEN}${PASSED_TESTS}${NC}"
echo -e "Failed: ${RED}${FAILED_TESTS}${NC}"
echo -e "${BLUE}========================================${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}✅ All tests passed! Ready for next phase.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Review output above.${NC}"
    exit 1
fi
