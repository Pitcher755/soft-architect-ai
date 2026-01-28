#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# 🔍 SoftArchitect AI - Docker Setup Validator
#
# Verifica que la configuración Docker es correcta y funcional
# antes de iniciar servicios.
#
# Uso: bash validate-docker-setup.sh
# ═══════════════════════════════════════════════════════════════

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0

# ─────────────────────────────────────────────────────────────
# Funciones de utilidad
# ─────────────────────────────────────────────────────────────

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

check_pass() {
    echo -e "${GREEN}✓ $1${NC}"
    ((CHECKS_PASSED++))
}

check_fail() {
    echo -e "${RED}✗ $1${NC}"
    ((CHECKS_FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((CHECKS_WARNED++))
}

# ─────────────────────────────────────────────────────────────
# VERIFICACIÓN 1: Docker Instalado
# ─────────────────────────────────────────────────────────────

print_header "1. Verificando Docker Instalado"

if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    check_pass "Docker encontrado: $DOCKER_VERSION"
else
    check_fail "Docker NO está instalado"
    echo "  → Instalar: https://docs.docker.com/get-docker/"
fi

# ─────────────────────────────────────────────────────────────
# VERIFICACIÓN 2: Docker Daemon Corriendo
# ─────────────────────────────────────────────────────────────

print_header "2. Verificando Docker Daemon"

if docker ps &> /dev/null; then
    check_pass "Docker daemon está corriendo"
else
    check_fail "Docker daemon NO está corriendo"
    echo "  → En Linux: sudo systemctl start docker"
    echo "  → En macOS/Windows: Abrir Docker Desktop"
fi

# ─────────────────────────────────────────────────────────────
# VERIFICACIÓN 3: Docker Compose
# ─────────────────────────────────────────────────────────────

print_header "3. Verificando Docker Compose"

if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version | awk '{print $4}')
    check_pass "Docker Compose encontrado: $COMPOSE_VERSION"
else
    check_fail "Docker Compose NO encontrado (requiere v2.0+)"
    echo "  → Instalar: https://docs.docker.com/compose/install/"
fi

# ─────────────────────────────────────────────────────────────
# VERIFICACIÓN 4: Recursos Disponibles
# ─────────────────────────────────────────────────────────────

print_header "4. Verificando Recursos del Sistema"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    AVAILABLE_RAM=$(free -h | awk 'NR==2 {print $7}')
    AVAILABLE_DISK=$(df -h / | awk 'NR==2 {print $4}')
    echo "  RAM disponible: $AVAILABLE_RAM"
    echo "  Disco disponible: $AVAILABLE_DISK"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    AVAILABLE_RAM=$(vm_stat | grep "Pages free" | awk '{print int($3/256)}')MB
    echo "  RAM disponible: ~$AVAILABLE_RAM"
fi

RAM_GB=$(echo "$AVAILABLE_RAM" | sed 's/G.*//' | tr -d ' ')
if [[ -z "$RAM_GB" ]] || [[ "$RAM_GB" -lt 8 ]]; then
    check_warn "RAM disponible parece < 8GB (recomendado 8GB+)"
    echo "  → Si Ollama crashea: reducir OLLAMA_MEMORY_LIMIT en .env"
else
    check_pass "RAM suficiente ($AVAILABLE_RAM)"
fi

DISK_GB=$(echo "$AVAILABLE_DISK" | sed 's/G.*//' | tr -d ' ')
if [[ -z "$DISK_GB" ]] || [[ "$DISK_GB" -lt 20 ]]; then
    check_warn "Disco disponible < 20GB (recomendado 20GB+)"
else
    check_pass "Disco suficiente ($AVAILABLE_DISK)"
fi

# ─────────────────────────────────────────────────────────────
# VERIFICACIÓN 5: Estructura de Carpetas
# ─────────────────────────────────────────────────────────────

print_header "5. Verificando Estructura del Proyecto"

# Desde cualquier lugar, encontrar la raíz del proyecto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

REQUIRED_DIRS=(
    "src/server"
    "src/client"
    "packages/knowledge_base"
    "infrastructure"
    "context"
    "doc"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$PROJECT_ROOT/$dir" ]]; then
        check_pass "Directorio encontrado: $dir"
    else
        check_fail "Directorio FALTANTE: $dir"
    fi
done

# ─────────────────────────────────────────────────────────────
# VERIFICACIÓN 6: Archivos de Configuración
# ─────────────────────────────────────────────────────────────

print_header "6. Verificando Archivos de Configuración"

if [[ -f "$PROJECT_ROOT/src/server/Dockerfile" ]]; then
    check_pass "Dockerfile existe"
else
    check_fail "Dockerfile FALTANTE en src/server/"
fi

if [[ -f "$PROJECT_ROOT/infrastructure/docker-compose.yml" ]]; then
    check_pass "docker-compose.yml existe"
else
    check_fail "docker-compose.yml FALTANTE en infrastructure/"
fi

if [[ -f "$PROJECT_ROOT/infrastructure/.env" ]] || [[ -f "$PROJECT_ROOT/infrastructure/.env.example" ]]; then
    check_pass "Archivo .env para infrastructure existe"
else
    check_fail ".env FALTANTE en infrastructure/ (copiar desde .env.example)"
fi

if [[ -f "$PROJECT_ROOT/src/server/.env" ]] || [[ -f "$PROJECT_ROOT/src/server/.env.example" ]]; then
    check_pass "Archivo .env para src/server existe"
else
    check_fail ".env FALTANTE en src/server/ (copiar desde .env.example)"
fi

# ─────────────────────────────────────────────────────────────
# VERIFICACIÓN 7: Puertos Disponibles
# ─────────────────────────────────────────────────────────────

print_header "7. Verificando Puertos"

check_port() {
    local port=$1
    local service=$2
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
            check_warn "Puerto $port ya está en uso (servicio: $service)"
            echo "  → Cambiar en docker-compose.yml o detener proceso en puerto $port"
        else
            check_pass "Puerto $port disponible (para $service)"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if lsof -i :$port >/dev/null 2>&1; then
            check_warn "Puerto $port ya está en uso (servicio: $service)"
        else
            check_pass "Puerto $port disponible (para $service)"
        fi
    else
        check_pass "Puerto $port verificación saltada (sistema desconocido)"
    fi
}

check_port 8000 "API"
check_port 11434 "Ollama" 
check_port 8001 "ChromaDB (alternativo)"

# ─────────────────────────────────────────────────────────────
# VERIFICACIÓN 8: Sintaxis YAML
# ─────────────────────────────────────────────────────────────

print_header "8. Verificando Sintaxis de docker-compose.yml"

if docker compose -f "$PROJECT_ROOT/infrastructure/docker-compose.yml" config > /dev/null 2>&1; then
    check_pass "docker-compose.yml tiene sintaxis YAML válida"
else
    check_fail "docker-compose.yml tiene ERRORES DE SINTAXIS"
    docker compose -f "$PROJECT_ROOT/infrastructure/docker-compose.yml" config 2>&1 | head -20
fi

# ─────────────────────────────────────────────────────────────
# VERIFICACIÓN 9: GPU NVIDIA (Opcional)
# ─────────────────────────────────────────────────────────────

print_header "9. Verificando GPU NVIDIA (Opcional)"

if command -v nvidia-smi &> /dev/null; then
    GPU_COUNT=$(nvidia-smi --list-gpus | wc -l)
    check_pass "GPU NVIDIA detectada: $GPU_COUNT GPU(s)"
    
    if docker run --rm --gpus all nvidia/cuda:12.0.0-runtime-base nvidia-smi &> /dev/null; then
        check_pass "NVIDIA Container Toolkit funcionando"
    else
        check_warn "NVIDIA Container Toolkit NO funciona (comentar sección GPU en docker-compose.yml)"
    fi
else
    echo "  ℹ GPU NVIDIA no detectada (OK para CPU-only, pero lento)"
fi

# ─────────────────────────────────────────────────────────────
# RESUMEN FINAL
# ─────────────────────────────────────────────────────────────

print_header "📊 RESUMEN DE VERIFICACIÓN"

TOTAL=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNED))

echo "Verificaciones ejecutadas: $TOTAL"
echo -e "  ${GREEN}✓ Pasadas: $CHECKS_PASSED${NC}"
echo -e "  ${YELLOW}⚠ Advertencias: $CHECKS_WARNED${NC}"
echo -e "  ${RED}✗ Fallos: $CHECKS_FAILED${NC}"

echo ""

if [[ $CHECKS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ CONFIGURACIÓN LISTA PARA USAR${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "  1. cd infrastructure"
    echo "  2. docker compose up --build"
    echo "  3. Visitar http://localhost:8000/docs"
    echo ""
    exit 0
else
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}✗ CORRIGE LOS ERRORES ARRIBA ANTES DE CONTINUAR${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    exit 1
fi
