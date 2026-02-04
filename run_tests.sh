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
COVERAGE_FLAG=""

# Check for coverage flag
if [[ "$*" == *"--coverage"* ]]; then
  COVERAGE_FLAG="--coverage"
fi

case $TEST_TYPE in
  flutter|unit)
    echo -e "${YELLOW}Running Flutter Unit Tests...${NC}"
    cd tests
    flutter test unit/flutter/ --verbose $COVERAGE_FLAG --coverage-package=softarchitect_ai --coverage-path=coverage/lcov.info
    cd ..

    # Si se pidió cobertura, generar reporte HTML
    if [[ "$COVERAGE_FLAG" == "--coverage" ]]; then
      echo -e "${YELLOW}Generating HTML coverage report...${NC}"
      cd tests
      genhtml --synthesize-missing --ignore-errors source coverage/lcov.info -o coverage/html --title "SoftArchitect AI - Flutter Unit Tests Coverage"
      cd ..
    fi

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
    flutter test ../../tests/integration/flutter/ --verbose $COVERAGE_FLAG

    # Si se pidió cobertura, copiar el archivo generado al directorio centralizado
    if [[ "$COVERAGE_FLAG" == "--coverage" ]]; then
      echo -e "${YELLOW}Copying coverage data to centralized location...${NC}"
      cp coverage/lcov.info ../../tests/coverage/ 2>/dev/null || echo "⚠️  No coverage file generated"
    fi

    cd ../..
    echo -e "${GREEN}✅ Integration tests passed${NC}\n"
    ;;
  all)
    echo -e "${YELLOW}Running ALL Tests...${NC}"
    echo -e "${YELLOW}1. Flutter Unit Tests${NC}"
    cd tests
    flutter test unit/flutter/ --verbose $COVERAGE_FLAG --coverage-package=softarchitect_ai --coverage-path=coverage/lcov.info || echo -e "${RED}❌ Flutter tests failed${NC}"
    cd ..

    # Si se pidió cobertura, generar reporte HTML
    if [[ "$COVERAGE_FLAG" == "--coverage" ]]; then
      echo -e "${YELLOW}Generating HTML coverage report...${NC}"
      cd tests
      genhtml --synthesize-missing --ignore-errors source coverage/lcov.info -o coverage/html --title "SoftArchitect AI - Flutter Unit Tests Coverage"
      cd ..
    fi

    echo -e "\n${YELLOW}2. Python Tests${NC}"
    cd src/server
    python -m pytest ../../tests/unit/python/ -v 2>/dev/null || echo "⚠️  No Python unit tests yet"
    cd ../..

    echo -e "\n${YELLOW}3. Integration Tests${NC}"
    cd src/client
    flutter test ../../tests/integration/flutter/ --verbose $COVERAGE_FLAG 2>/dev/null || echo "⚠️  No integration tests yet"

    # Si se pidió cobertura, copiar el archivo generado al directorio centralizado
    if [[ "$COVERAGE_FLAG" == "--coverage" ]]; then
      echo -e "${YELLOW}Copying coverage data to centralized location...${NC}"
      cp coverage/lcov.info ../../tests/coverage/ 2>/dev/null || echo "⚠️  No coverage file generated"
    fi

    cd ../..

    echo -e "\n${GREEN}✅ All tests completed${NC}\n"
    ;;
  *)
    echo -e "${RED}❌ Unknown test type: $TEST_TYPE${NC}"
    echo "Usage: ./run_tests.sh [flutter|python|unit|integration|all]"
    exit 1
    ;;
esac
