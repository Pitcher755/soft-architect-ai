#!/bin/bash
# ============================================================
# Quick Test Suite Verification Script
# ============================================================
# Propósito: Validar rápidamente el estado de tests
# Usage: bash scripts/verify-tests.sh [unit|integration|all]
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SERVER_DIR="$PROJECT_ROOT/src/server"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Main
cd "$SERVER_DIR"

MODE="${1:-all}"

case $MODE in
    unit)
        print_header "Running UNIT TESTS"
        python -m pytest tests/unit/ -v --tb=short
        ;;

    integration)
        print_header "Running INTEGRATION/E2E TESTS"

        # Check if CHROMA_HOST is set
        if [ -z "$CHROMA_HOST" ]; then
            print_warning "CHROMA_HOST not set. E2E tests will be SKIPPED"
            print_warning "To run E2E tests:"
            echo ""
            echo "  1. Start Docker: docker-compose -f infrastructure/docker-compose.yml up -d chromadb"
            echo "  2. Set env: export CHROMA_HOST=localhost"
            echo "  3. Run tests: bash scripts/verify-tests.sh integration"
            echo ""
        fi

        python -m pytest tests/integration/ -v --tb=short
        ;;

    all)
        print_header "Running ALL TESTS (Unit + Integration)"

        # Unit tests
        echo ""
        print_header "UNIT TESTS"
        python -m pytest tests/unit/ -v --tb=short

        # Integration tests
        echo ""
        print_header "INTEGRATION/E2E TESTS"
        if [ -z "$CHROMA_HOST" ]; then
            print_warning "CHROMA_HOST not set. E2E tests will be SKIPPED"
        fi
        python -m pytest tests/integration/ -v --tb=short

        # Summary
        echo ""
        print_header "TEST SUMMARY"
        python -m pytest tests/ --collect-only -q | tail -5
        ;;

    *)
        echo "Usage: bash scripts/verify-tests.sh [unit|integration|all]"
        echo ""
        echo "Examples:"
        echo "  bash scripts/verify-tests.sh unit        # Run unit tests only"
        echo "  bash scripts/verify-tests.sh integration # Run E2E tests (requires Docker)"
        echo "  bash scripts/verify-tests.sh all         # Run all tests"
        exit 1
        ;;
esac

print_success "Test verification completed!"
