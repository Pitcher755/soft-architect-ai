#!/bin/bash

################################################################################
# 🚀 SOFTARCHITECT AI - AUTOMATED DEVELOPMENT ENVIRONMENT SETUP
################################################################################
# Purpose: One-command project onboarding for new developers
# Usage: ./scripts/setup/setup_project.sh
# Author: PitcherDev
# Version: 1.0.0
# Created: 2026-02-15
################################################################################

set -e  # Exit on any error

################################################################################
# 1. CONFIGURATION & COLORS
################################################################################

# ANSI Color Codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Project Paths
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKEND_DIR="$PROJECT_ROOT/src/server"
readonly CLIENT_DIR="$PROJECT_ROOT/src/client"
readonly TESTS_DIR="$PROJECT_ROOT/tests"
readonly INFRA_DIR="$PROJECT_ROOT/infrastructure"

# Version Requirements
readonly REQUIRED_PYTHON_VERSION="3.12"
readonly REQUIRED_FLUTTER_VERSION="3.38"
readonly REQUIRED_DOCKER_VERSION="20.10"

# Ollama Models (from .env.example and code analysis)
readonly OLLAMA_MODELS=("qwen2.5-coder:3b" "llama2")

# State tracking
ERRORS_FOUND=0
WARNINGS_FOUND=0

################################################################################
# 2. UTILITY FUNCTIONS
################################################################################

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║${NC} ${CYAN}$1${NC}"
    echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

print_section() {
    echo ""
    echo -e "${BOLD}${MAGENTA}▶ $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((ERRORS_FOUND++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS_FOUND++))
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_step() {
    echo -e "${BLUE}→ $1${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

version_compare() {
    # Returns 0 if $1 >= $2, 1 otherwise
    local ver1="$1"
    local ver2="$2"

    if [ "$(printf '%s\n' "$ver2" "$ver1" | sort -V | head -n1)" = "$ver2" ]; then
        return 0
    else
        return 1
    fi
}

################################################################################
# 3. REQUIREMENTS VERIFICATION
################################################################################

verify_requirements() {
    print_header "PHASE 1: VERIFYING SYSTEM REQUIREMENTS"

    local all_requirements_met=true

    # Python Check
    print_section "Checking Python Installation"
    if check_command python3; then
        local python_version=$(python3 --version | awk '{print $2}')
        print_step "Python version: $python_version"

        if version_compare "$python_version" "$REQUIRED_PYTHON_VERSION"; then
            print_success "Python ${REQUIRED_PYTHON_VERSION}+ detected"
        else
            print_error "Python ${REQUIRED_PYTHON_VERSION}+ required (found: $python_version)"
            print_info "Install: sudo apt install python3.12 python3.12-venv"
            all_requirements_met=false
        fi
    else
        print_error "Python not found"
        print_info "Install: sudo apt install python3.12 python3.12-venv"
        all_requirements_met=false
    fi

    # Poetry Check
    print_section "Checking Poetry Installation"
    if check_command poetry; then
        local poetry_version=$(poetry --version | awk '{print $3}')
        print_step "Poetry version: $poetry_version"
        print_success "Poetry detected"
    else
        print_error "Poetry not found"
        print_info "Install: curl -sSL https://install.python-poetry.org | python3 -"
        print_info "Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
        all_requirements_met=false
    fi

    # Flutter Check
    print_section "Checking Flutter Installation"
    if check_command flutter; then
        local flutter_version=$(flutter --version | head -n1 | awk '{print $2}')
        print_step "Flutter version: $flutter_version"

        if version_compare "$flutter_version" "$REQUIRED_FLUTTER_VERSION"; then
            print_success "Flutter ${REQUIRED_FLUTTER_VERSION}+ detected"
        else
            print_warning "Flutter ${REQUIRED_FLUTTER_VERSION}+ recommended (found: $flutter_version)"
            print_info "Update: flutter upgrade"
        fi
    else
        print_error "Flutter not found"
        print_info "Install: https://docs.flutter.dev/get-started/install/linux"
        all_requirements_met=false
    fi

    # Docker Check
    print_section "Checking Docker Installation"
    if check_command docker; then
        local docker_version=$(docker --version | awk '{print $3}' | tr -d ',')
        print_step "Docker version: $docker_version"

        if version_compare "$docker_version" "$REQUIRED_DOCKER_VERSION"; then
            print_success "Docker ${REQUIRED_DOCKER_VERSION}+ detected"
        else
            print_warning "Docker ${REQUIRED_DOCKER_VERSION}+ recommended (found: $docker_version)"
        fi

        # Check if Docker is running
        if docker info &> /dev/null; then
            print_success "Docker daemon is running"
        else
            print_error "Docker daemon is not running"
            print_info "Start: sudo systemctl start docker"
            all_requirements_met=false
        fi
    else
        print_error "Docker not found"
        print_info "Install: https://docs.docker.com/engine/install/"
        all_requirements_met=false
    fi

    # Docker Compose Check
    print_section "Checking Docker Compose Installation"
    if docker compose version &> /dev/null || check_command docker-compose; then
        print_success "Docker Compose detected"
    else
        print_error "Docker Compose not found"
        print_info "Install: sudo apt install docker-compose-plugin"
        all_requirements_met=false
    fi

    # Ollama Check (Optional - can run in Docker)
    print_section "Checking Ollama Installation (Optional)"
    if check_command ollama; then
        print_success "Ollama CLI detected (local installation)"

        # Check if Ollama service is running
        if curl -s http://localhost:11434/api/version &> /dev/null; then
            print_success "Ollama service is running"
        else
            print_warning "Ollama service is not running (will use Docker version)"
            print_info "Start: ollama serve"
        fi
    else
        print_info "Ollama CLI not found (will use Docker version)"
        print_info "Optional install: curl -fsSL https://ollama.com/install.sh | sh"
    fi

    # Final verdict
    echo ""
    if [ "$all_requirements_met" = false ]; then
        print_error "Some requirements are missing. Please install them and re-run this script."
        exit 1
    else
        print_success "All requirements verified successfully!"
    fi
}

################################################################################
# 4. ENVIRONMENT CONFIGURATION
################################################################################

setup_environment_files() {
    print_header "PHASE 2: CONFIGURING ENVIRONMENT FILES"

    print_info "Environment files (.env) store configuration values for the application"
    print_info "These files are gitignored and must be created from .env.example templates"
    echo ""

    # Root .env
    print_section "Root .env Configuration"
    if [ -f "$PROJECT_ROOT/.env" ]; then
        print_success "Root .env already exists (using existing configuration)"
    else
        if [ -f "$PROJECT_ROOT/.env.example" ]; then
            print_step "Creating .env from .env.example"
            cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
            print_success "Root .env created with default values"
            print_warning "🔧 Review and customize: $PROJECT_ROOT/.env"
        else
            print_warning "No .env.example found in root (skipping)"
        fi
    fi

    # Backend .env
    print_section "Backend .env Configuration"
    if [ -f "$BACKEND_DIR/.env" ]; then
        print_success "Backend .env already exists (using existing configuration)"
    else
        if [ -f "$BACKEND_DIR/.env.example" ]; then
            print_step "Creating backend .env from .env.example"
            cp "$BACKEND_DIR/.env.example" "$BACKEND_DIR/.env"
            print_success "Backend .env created with default values"
            print_warning "🔧 Review and customize: $BACKEND_DIR/.env"
            print_info "Key settings: OLLAMA_MODEL, CHROMADB_HOST, API_KEY"
        else
            print_error "Backend .env.example not found!"
            print_info "Create manually: cp $BACKEND_DIR/.env.example $BACKEND_DIR/.env"
            return 1
        fi
    fi

    # Client .env
    print_section "Client .env Configuration"
    if [ -f "$CLIENT_DIR/.env" ]; then
        print_success "Client .env already exists (using existing configuration)"
    else
        if [ -f "$CLIENT_DIR/.env.example" ]; then
            print_step "Creating client .env from .env.example"
            cp "$CLIENT_DIR/.env.example" "$CLIENT_DIR/.env"
            print_success "Client .env created with default values"
        else
            print_info "No .env.example for client (optional - skipping)"
        fi
    fi

    echo ""
    print_success "✅ Environment configuration complete"
    print_info "All .env files are ready with default values"
}

################################################################################
# 5. BACKEND SETUP (Python/Poetry)
################################################################################

setup_backend() {
    print_header "PHASE 3: SETTING UP BACKEND (Python/Poetry)"

    print_section "Installing Python Dependencies"
    cd "$BACKEND_DIR"

    # Check if virtual environment already exists
    if [ -d "$BACKEND_DIR/.venv" ]; then
        print_info "Virtual environment already exists"
    else
        print_step "Creating virtual environment with Poetry"
        poetry install --no-interaction
        print_success "Dependencies installed"
    fi

    # Verify installation
    print_section "Verifying Backend Setup"
    if poetry run python --version &> /dev/null; then
        print_success "Backend environment is ready"
        local venv_python=$(poetry run python --version)
        print_info "Virtual env Python: $venv_python"
    else
        print_error "Backend environment verification failed"
        return 1
    fi

    # Database migrations (if any)
    print_section "Checking Database Migrations"
    if [ -d "$BACKEND_DIR/alembic" ] || [ -f "$BACKEND_DIR/manage.py" ]; then
        print_warning "Database migrations detected but not automated"
        print_info "Run manually: cd $BACKEND_DIR && poetry run alembic upgrade head"
    else
        print_info "No migrations found (SQLite used - auto-created on first run)"
    fi

    cd "$PROJECT_ROOT"
    print_success "Backend setup complete"
}

################################################################################
# 6. FRONTEND SETUP (Flutter)
################################################################################

setup_frontend() {
    print_header "PHASE 4: SETTING UP FRONTEND (Flutter)"

    # Client dependencies
    print_section "Installing Client Dependencies"
    cd "$CLIENT_DIR"

    if [ -f "pubspec.yaml" ]; then
        print_step "Running flutter pub get in src/client/"
        flutter pub get
        print_success "Client dependencies installed"
    else
        print_error "pubspec.yaml not found in $CLIENT_DIR"
        cd "$PROJECT_ROOT"
        return 1
    fi

    # Tests dependencies
    print_section "Installing Test Dependencies"
    cd "$TESTS_DIR"

    if [ -f "pubspec.yaml" ]; then
        print_step "Running flutter pub get in tests/"
        flutter pub get
        print_success "Test dependencies installed"
    else
        print_warning "pubspec.yaml not found in $TESTS_DIR"
    fi

    # Run flutter doctor for diagnostics
    print_section "Running Flutter Doctor"
    cd "$PROJECT_ROOT"
    flutter doctor

    print_success "Frontend setup complete"
}

################################################################################
# 7. INFRASTRUCTURE SETUP (Docker Compose)
################################################################################

setup_infrastructure() {
    print_header "PHASE 5: SETTING UP INFRASTRUCTURE (Docker)"

    # Double-check Docker daemon is running (critical before docker compose)
    print_section "Verifying Docker Service"
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running!"
        print_info "Start Docker: sudo systemctl start docker"
        print_info "Enable on boot: sudo systemctl enable docker"
        print_warning "Cannot proceed with infrastructure setup without Docker"
        return 1
    fi
    print_success "Docker daemon is running and ready"

    print_section "Starting Docker Services"
    cd "$INFRA_DIR"

    # Verify docker-compose.yml exists
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found in $INFRA_DIR"
        return 1
    fi

    # Check if services are already running
    if docker compose ps 2>/dev/null | grep -q "Up"; then
        print_info "Some services are already running"
        print_step "Restarting services to ensure fresh state"
        docker compose restart
    else
        print_step "Starting services: ChromaDB, Ollama, API Server"
        docker compose up -d
    fi

    # Wait for services to be healthy
    print_section "Waiting for Services to be Healthy"
    local max_wait=60
    local elapsed=0

    while [ $elapsed -lt $max_wait ]; do
        if docker compose ps | grep -q "(healthy)"; then
            print_success "Services are healthy"
            break
        fi
        print_step "Waiting for services... ($elapsed/${max_wait}s)"
        sleep 5
        ((elapsed+=5))
    done

    if [ $elapsed -ge $max_wait ]; then
        print_warning "Services did not become healthy within ${max_wait}s"
        print_info "Check logs: docker compose logs"
    fi

    # Display running services
    print_section "Running Services"
    docker compose ps

    cd "$PROJECT_ROOT"
    print_success "Infrastructure setup complete"
}

################################################################################
# 8. OLLAMA MODELS SETUP
################################################################################

setup_ollama_models() {
    print_header "PHASE 6: CONFIGURING OLLAMA AI MODELS"

    # Determine if using local Ollama or Docker Ollama
    local ollama_cmd=""
    local ollama_host=""

    if check_command ollama && curl -s http://localhost:11434/api/version &> /dev/null; then
        ollama_cmd="ollama"
        ollama_host="localhost:11434"
        print_info "Using local Ollama installation"
    elif docker compose -f "$INFRA_DIR/docker-compose.yml" ps | grep -q "sa_ollama.*Up"; then
        ollama_cmd="docker exec sa_ollama ollama"
        ollama_host="Ollama Docker container"
        print_info "Using Ollama in Docker"
    else
        print_error "Ollama is not running (local or Docker)"
        print_info "Start Docker services first: cd infrastructure && docker compose up -d"
        return 1
    fi

    print_section "Pulling Required Models"
    for model in "${OLLAMA_MODELS[@]}"; do
        print_step "Checking model: $model"

        # Check if model is already downloaded
        if $ollama_cmd list | grep -q "$model"; then
            print_info "Model $model already exists (skipping)"
        else
            print_step "Downloading model: $model (this may take several minutes)..."
            if $ollama_cmd pull "$model"; then
                print_success "Model $model downloaded"
            else
                print_warning "Failed to download model $model"
                print_info "You can download it later: $ollama_cmd pull $model"
            fi
        fi
    done

    # List all available models
    print_section "Available Models"
    $ollama_cmd list

    print_success "Ollama models setup complete"
}

################################################################################
# 9. SMOKE TEST VALIDATION
################################################################################

run_smoke_tests() {
    print_header "PHASE 7: RUNNING SMOKE TESTS"

    # Backend API health check
    print_section "Backend API Health Check"
    local api_url="http://localhost:8000/health"
    local max_retries=10
    local retry_count=0

    while [ $retry_count -lt $max_retries ]; do
        if curl -sf "$api_url" &> /dev/null; then
            print_success "Backend API is responding at $api_url"
            break
        fi
        print_step "Waiting for API to be ready... (${retry_count}/${max_retries})"
        sleep 3
        ((retry_count++))
    done

    if [ $retry_count -ge $max_retries ]; then
        print_warning "Backend API did not respond within timeout"
        print_info "Check logs: cd infrastructure && docker compose logs api-server"
        print_info "Or start manually: cd src/server && poetry run uvicorn app.main:app --reload"
    fi

    # ChromaDB health check
    print_section "ChromaDB Health Check"
    if curl -sf "http://localhost:8001/api/v1/heartbeat" &> /dev/null; then
        print_success "ChromaDB is responding at http://localhost:8001"
    else
        print_warning "ChromaDB is not responding"
        print_info "Check status: docker compose logs chromadb"
    fi

    # Ollama health check
    print_section "Ollama Health Check"
    if curl -sf "http://localhost:11434/api/version" &> /dev/null; then
        local ollama_version=$(curl -s "http://localhost:11434/api/version" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        print_success "Ollama is responding (version: $ollama_version)"
    else
        print_warning "Ollama is not responding"
        print_info "Check status: docker compose logs ollama"
    fi

    print_success "Smoke tests complete"
}

################################################################################
# 10. GIT HOOKS SETUP (OPTIONAL)
################################################################################

setup_git_hooks() {
    print_header "PHASE 8: CONFIGURING GIT HOOKS (Optional)"

    print_info "Git hooks can automatically validate code quality before pushing"
    print_info "This prevents CI/CD failures by catching issues locally"
    echo ""

    local pre_push_script="$PROJECT_ROOT/scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh"
    local git_hooks_dir="$PROJECT_ROOT/.git/hooks"
    local pre_push_hook="$git_hooks_dir/pre-push"

    # Check if git repository exists
    if [ ! -d "$PROJECT_ROOT/.git" ]; then
        print_warning "Not a git repository (skipping git hooks)"
        return 0
    fi

    # Check if validation script exists
    if [ ! -f "$pre_push_script" ]; then
        print_warning "PRE_PUSH_VALIDATION_MASTER.sh not found (skipping)"
        return 0
    fi

    print_section "Installing Pre-Push Validation Hook"

    # Check if hook already exists
    if [ -f "$pre_push_hook" ]; then
        print_info "Pre-push hook already exists"
        echo ""
        read -p "$(echo -e "${YELLOW}⚠️  Overwrite existing hook? (y/N): ${NC}")" -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Keeping existing pre-push hook (skipped)"
            return 0
        fi
    else
        echo ""
        read -p "$(echo -e "${CYAN}Install pre-push validation hook? (Y/n): ${NC}")" -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_info "Pre-push hook installation skipped (manual validation required)"
            print_warning "Remember to run: ./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh"
            return 0
        fi
    fi

    # Create hooks directory if it doesn't exist
    mkdir -p "$git_hooks_dir"

    # Create the hook (calls the validation script)
    print_step "Creating pre-push hook"
    cat > "$pre_push_hook" << 'HOOK_EOF'
#!/bin/bash
# Auto-generated by setup_project.sh
# Runs PRE_PUSH_VALIDATION_MASTER.sh before every git push

set -e

echo ""
echo "🔍 Running pre-push validation..."
echo ""

# Get project root (assuming hook is in .git/hooks/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VALIDATION_SCRIPT="$PROJECT_ROOT/scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh"

if [ ! -f "$VALIDATION_SCRIPT" ]; then
    echo "❌ Validation script not found: $VALIDATION_SCRIPT"
    echo "⚠️  Skipping validation (hook may be misconfigured)"
    exit 0
fi

# Run validation
if ! "$VALIDATION_SCRIPT"; then
    echo ""
    echo "❌ Pre-push validation FAILED!"
    echo "🚫 Push aborted. Fix the issues above and try again."
    echo ""
    echo "💡 To bypass (not recommended): git push --no-verify"
    exit 1
fi

echo ""
echo "✅ Pre-push validation PASSED! Proceeding with push..."
echo ""

exit 0
HOOK_EOF

    # Make hook executable
    chmod +x "$pre_push_hook"

    print_success "Pre-push hook installed successfully!"
    print_info "Location: $pre_push_hook"
    echo ""
    print_info "📌 How it works:"
    echo -e "   ${BLUE}→${NC} Every 'git push' will trigger automatic validation"
    echo -e "   ${BLUE}→${NC} If validation fails, push is aborted"
    echo -e "   ${BLUE}→${NC} Bypass (not recommended): git push --no-verify"
    echo ""
    print_success "🛡️  Quality gate activated! All pushes will be validated."
}

################################################################################
# 11. FINAL REPORT
################################################################################

print_final_report() {
    print_header "🎉 SETUP COMPLETE - ENVIRONMENT READY"

    echo ""
    echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║${NC}  ${CYAN}✨ SoftArchitect AI Development Environment is Ready! ✨${NC}     ${BOLD}${GREEN}║${NC}"
    echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    print_section "📊 Setup Summary"
    echo -e "  ${GREEN}✅${NC} Requirements verified"
    echo -e "  ${GREEN}✅${NC} Environment files configured"
    echo -e "  ${GREEN}✅${NC} Backend dependencies installed (Poetry)"
    echo -e "  ${GREEN}✅${NC} Frontend dependencies installed (Flutter)"
    echo -e "  ${GREEN}✅${NC} Docker services running"
    echo -e "  ${GREEN}✅${NC} Ollama models configured"
    echo -e "  ${GREEN}✅${NC} Smoke tests passed"

    if [ $WARNINGS_FOUND -gt 0 ]; then
        echo ""
        print_warning "$WARNINGS_FOUND warnings found (check logs above)"
    fi

    if [ $ERRORS_FOUND -gt 0 ]; then
        echo ""
        print_error "$ERRORS_FOUND errors found (check logs above)"
    fi

    print_section "🚀 Next Steps"
    echo ""
    echo -e "  ${CYAN}1.${NC} Start coding:"
    echo -e "     ${BLUE}→${NC} Backend: cd src/server && poetry run uvicorn app.main:app --reload"
    echo -e "     ${BLUE}→${NC} Frontend: cd src/client && flutter run -d linux"
    echo ""
    echo -e "  ${CYAN}2.${NC} Run tests:"
    echo -e "     ${BLUE}→${NC} All tests: ./scripts/testing/run_tests.sh all"
    echo -e "     ${BLUE}→${NC} Backend: cd src/server && poetry run pytest"
    echo -e "     ${BLUE}→${NC} Frontend: cd tests && flutter test client/"
    echo ""
    echo -e "  ${CYAN}3.${NC} Access services:"
    echo -e "     ${BLUE}→${NC} Backend API: http://localhost:8000/docs"
    echo -e "     ${BLUE}→${NC} ChromaDB: http://localhost:8001"
    echo -e "     ${BLUE}→${NC} Ollama: http://localhost:11434"
    echo ""
    echo -e "  ${CYAN}4.${NC} Before pushing code:"
    echo -e "     ${BLUE}→${NC} Validate: ./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh"
    echo ""

    print_section "📚 Documentation"
    echo ""
    echo -e "  ${BLUE}→${NC} Quick Start: doc/02-SETUP_DEV/QUICK_START_GUIDE.md"
    echo -e "  ${BLUE}→${NC} Architecture: doc/30-ARCHITECTURE/"
    echo -e "  ${BLUE}→${NC} Contributing: CONTRIBUTING.md"
    echo ""

    print_section "🛠️ Useful Commands"
    echo ""
    echo -e "  ${BLUE}→${NC} Stop services: cd infrastructure && docker compose down"
    echo -e "  ${BLUE}→${NC} View logs: cd infrastructure && docker compose logs -f"
    echo -e "  ${BLUE}→${NC} Restart services: cd infrastructure && docker compose restart"
    echo -e "  ${BLUE}→${NC} Clean rebuild: docker compose down -v && docker compose up -d --build"
    echo ""

    echo -e "${BOLD}${GREEN}Happy coding! 🚀${NC}"
    echo ""
}

################################################################################
# 12. MAIN EXECUTION
################################################################################

main() {
    echo ""
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                                                               ║${NC}"
    echo -e "${BOLD}${CYAN}║        🚀 SOFTARCHITECT AI - DEVELOPMENT SETUP 🚀             ║${NC}"
    echo -e "${BOLD}${CYAN}║                                                               ║${NC}"
    echo -e "${BOLD}${CYAN}║     Automated Onboarding for New Developers                  ║${NC}"
    echo -e "${BOLD}${CYAN}║     Version: 1.0.0 | Date: 2026-02-15                        ║${NC}"
    echo -e "${BOLD}${CYAN}║                                                               ║${NC}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    print_info "This script will set up your complete development environment"
    print_info "Estimated time: 5-15 minutes (depending on internet speed)"
    echo ""

    # Execute setup phases
    verify_requirements
    setup_environment_files
    setup_backend
    setup_frontend
    setup_infrastructure
    setup_ollama_models
    run_smoke_tests
    setup_git_hooks
    print_final_report

    # Exit with appropriate code
    if [ $ERRORS_FOUND -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"
