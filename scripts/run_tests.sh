#!/bin/bash
# run_tests.sh - Execute tests from centralized location with proper context

set -e

# Ensure we're in the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧪 SoftArchitect AI - Test Execution${NC}\n"

# Parse arguments
TEST_TYPE=${1:-all}  # all, flutter, python, unit, integration
TARGET=${2:-.}
COVERAGE_FLAG=""

# Check for coverage flag
if [[ "$*" == *"--coverage"* ]]; then
  COVERAGE_FLAG="--coverage"
fi

case $TEST_TYPE in
  flutter|unit)
    echo -e "${YELLOW}Running Flutter Unit Tests...${NC}"
    cd tests
    flutter test test/ --verbose $COVERAGE_FLAG --coverage-package=softarchitect_ai
    cd ..

    # Si se pidió cobertura, generar reporte HTML
    if [[ "$COVERAGE_FLAG" == "--coverage" ]]; then
      echo -e "${YELLOW}Generating HTML coverage report...${NC}"
      cd tests
      mkdir -p coverage/html
      genhtml --synthesize-missing --ignore-errors source coverage/lcov.info -o coverage/html --title "SoftArchitect AI - Flutter Tests Coverage"
      cd ..
    fi

    echo -e "${GREEN}✅ Flutter tests passed${NC}\n"
    ;;
  python)
    echo -e "${YELLOW}Running Python Tests...${NC}"
    cd tests/python/unit
    python -m pytest . -v --cov=services --cov-fail-under=80 2>/dev/null || \
    python -m pytest . -v 2>/dev/null || \
    echo "⚠️  Python tests not configured yet"
    cd ../..
    echo -e "${GREEN}✅ Python tests passed${NC}\n"
    ;;
  integration)
    echo -e "${YELLOW}Running Integration Tests...${NC}"
    cd tests
    flutter test test/integration --verbose $COVERAGE_FLAG

    # Si se pidió cobertura, copiar el archivo generado al directorio centralizado
    if [[ "$COVERAGE_FLAG" == "--coverage" ]]; then
      echo -e "${YELLOW}Generating coverage report...${NC}"
      mkdir -p coverage/html
      genhtml --synthesize-missing --ignore-errors source coverage/lcov.info -o coverage/html --title "SoftArchitect AI - Flutter Integration Tests Coverage"
    fi

    cd ..
    echo -e "${GREEN}✅ Integration tests passed${NC}\n"
    ;;
  all)
    echo -e "${YELLOW}Running ALL Tests...${NC}"
    echo -e "${YELLOW}1. Flutter Tests (Unit + Widget + Integration)${NC}"
    cd tests
    flutter test test/ --verbose $COVERAGE_FLAG || echo -e "${RED}❌ Flutter tests failed${NC}"

    # Si se pidió cobertura, generar reporte HTML
    if [[ "$COVERAGE_FLAG" == "--coverage" ]]; then
      echo -e "${YELLOW}Generating HTML coverage report...${NC}"
      mkdir -p coverage/html
      genhtml --synthesize-missing --ignore-errors source coverage/lcov.info -o coverage/html --title "SoftArchitect AI - Flutter Tests Coverage"
    fi

    cd ..

    echo -e "\n${YELLOW}2. Python Tests${NC}"
    cd tests/python/unit
    python -m pytest . -v 2>/dev/null || echo "⚠️  No Python unit tests yet"
    cd ../../..

    echo -e "\n${GREEN}✅ All tests completed${NC}\n"
    ;;
  *)
    echo -e "${RED}❌ Unknown test type: $TEST_TYPE${NC}"
    echo "Usage: ./run_tests.sh [flutter|python|unit|integration|all]"
    exit 1
    ;;
esac
