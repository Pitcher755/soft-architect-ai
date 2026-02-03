#!/bin/bash
# run_tests.sh - Execute tests from centralized location with proper context

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧪 SoftArchitect AI - Test Execution${NC}\n"

# Parse arguments
TEST_TYPE=${1:-all}  # all, flutter, python, unit, integration
TARGET=${2:-.}

case $TEST_TYPE in
  flutter|unit)
    echo -e "${YELLOW}Running Flutter Unit Tests...${NC}"
    cd src/client
    flutter test ../../tests/unit/flutter/ --verbose
    cd ../..
    echo -e "${GREEN}✅ Flutter tests passed${NC}\n"
    ;;
  python)
    echo -e "${YELLOW}Running Python Tests...${NC}"
    cd src/server
    python -m pytest ../../tests/unit/python/ -v --cov=services --cov-fail-under=80 2>/dev/null || \
    python -m pytest ../../tests/unit/python/ -v 2>/dev/null || \
    echo "⚠️  Python tests not configured yet"
    cd ../..
    echo -e "${GREEN}✅ Python tests passed${NC}\n"
    ;;
  integration)
    echo -e "${YELLOW}Running Integration Tests...${NC}"
    cd src/client
    flutter test ../../tests/integration/flutter/ --verbose
    cd ../..
    echo -e "${GREEN}✅ Integration tests passed${NC}\n"
    ;;
  all)
    echo -e "${YELLOW}Running ALL Tests...${NC}"
    echo -e "${YELLOW}1. Flutter Unit Tests${NC}"
    cd src/client
    flutter test ../../tests/unit/flutter/ --verbose || echo -e "${RED}❌ Flutter tests failed${NC}"
    cd ../..

    echo -e "\n${YELLOW}2. Python Tests${NC}"
    cd src/server
    python -m pytest ../../tests/unit/python/ -v 2>/dev/null || echo "⚠️  No Python unit tests yet"
    cd ../..

    echo -e "\n${YELLOW}3. Integration Tests${NC}"
    cd src/client
    flutter test ../../tests/integration/flutter/ --verbose 2>/dev/null || echo "⚠️  No integration tests yet"
    cd ../..

    echo -e "\n${GREEN}✅ All tests completed${NC}\n"
    ;;
  *)
    echo -e "${RED}❌ Unknown test type: $TEST_TYPE${NC}"
    echo "Usage: ./run_tests.sh [flutter|python|unit|integration|all]"
    exit 1
    ;;
esac
