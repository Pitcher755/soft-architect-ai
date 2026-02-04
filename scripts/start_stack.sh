#!/bin/bash
# start_stack.sh - Orchestration script for HU-1.1

set -e  # Exit on first error

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Colors and emoji
print_header() {
    echo ""
    echo "=========================================="
    echo "🚀 SoftArchitect AI Stack Launcher"
    echo "=========================================="
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Step 1: Print header
print_header

# Step 2: Pre-flight checks
echo "🔍 Ejecutando verificaciones previas..."
if ! python3 infrastructure/pre_check.py; then
    print_error "Pre-flight check falló. Soluciona los errores arriba."
    exit 1
fi

# Step 3: Ensure .env exists
echo ""
echo "📝 Verificando configuración..."
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        print_warning ".env no existe. Creando desde .env.example..."
        cp .env.example .env
        print_success ".env creado. Edítalo si necesitas configuración custom."
    else
        print_error ".env.example no encontrado."
        exit 1
    fi
else
    print_success ".env existe"
fi

# Step 4: Pull latest images
echo ""
echo "📦 Descargando imágenes (esto puede tardar la primera vez)..."
docker compose -f infrastructure/docker-compose.yml pull

# Step 5: Start services
echo ""
echo "🐳 Iniciando contenedores..."
docker compose -f infrastructure/docker-compose.yml up -d --build

print_success "Contenedores iniciados."

# Step 6: Wait and verify
echo ""
echo "⏳ Esperando a que los servicios arranquen (max 30 segundos)..."
sleep 5

# Step 7: Run post-deployment checks
echo ""
echo "✅ Ejecutando verificaciones post-deployment..."
if python3 infrastructure/verify_setup.py; then
    echo ""
    print_success "🎉 STACK COMPLETAMENTE OPERATIVO"
    echo ""
    echo "📍 URLs disponibles:"
    echo "   - API:     http://localhost:8000"
    echo "   - Docs:    http://localhost:8000/docs"
    echo "   - ChromaDB: http://localhost:8001"
    echo "   - Ollama:  http://localhost:11434"
    echo ""
    echo "📚 Para ver logs en tiempo real:"
    echo "   docker compose -f infrastructure/docker-compose.yml logs -f"
    echo ""
    exit 0
else
    print_error "Verificación post-deployment falló."
    echo ""
    echo "🔧 Debugging:"
    echo "   1. Ver logs: docker compose logs -f"
    echo "   2. Verificar puertos: netstat -tulpn"
    echo "   3. Reintentar: ./start_stack.sh"
    exit 1
fi
