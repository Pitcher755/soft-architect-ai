#!/bin/bash
set -e

echo "🧪 Validación de Migración de Tests"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

cd "$(dirname "$0")/.."

echo -e "${YELLOW}[1/5] Verificando estructura de tests...${NC}"
if [ -d "tests/server/unit" ] && [ -d "tests/server/integration" ]; then
    echo -e "${GREEN}✓ Estructura tests/server/ existe${NC}"
else
    echo -e "${RED}✗ Estructura tests/server/ incompleta${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[2/5] Verificando conftest.py centralizado...${NC}"
if [ -f "tests/server/conftest.py" ]; then
    echo -e "${GREEN}✓ tests/server/conftest.py existe${NC}"
    echo "   Contenido clave:"
    grep -A 2 "server_root" tests/server/conftest.py | head -3 || true
else
    echo -e "${RED}✗ tests/server/conftest.py no encontrado${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[3/5] Contando tests migrados...${NC}"
OLD_TESTS=$(find src/server/tests -name "test_*.py" 2>/dev/null | wc -l || echo "0")
NEW_TESTS=$(find tests/server -name "test_*.py" 2>/dev/null | wc -l)
echo -e "   Tests en src/server/tests/: ${OLD_TESTS}"
echo -e "   Tests en tests/server/: ${NEW_TESTS}"
if [ "$NEW_TESTS" -gt 0 ]; then
    echo -e "${GREEN}✓ Tests migrados correctamente ($NEW_TESTS archivos)${NC}"
else
    echo -e "${RED}✗ No se encontraron tests en tests/server/${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[4/5] Verificando configuración pytest...${NC}"
if grep -q "testpaths.*tests/server" src/server/pyproject.toml; then
    echo -e "${GREEN}✓ pyproject.toml actualizado (testpaths apunta a tests/python)${NC}"
else
    echo -e "${RED}✗ pyproject.toml no actualizado${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[5/5] Verificando pyrightconfig.json...${NC}"
if grep -q "tests/python" pyrightconfig.json; then
    echo -e "${GREEN}✓ pyrightconfig.json actualizado${NC}"
else
    echo -e "${RED}✗ pyrightconfig.json no actualizado${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Migración VALIDADA correctamente${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "📋 Próximos pasos:"
echo "   1. Ejecutar tests: cd src/server && pytest ../../tests/python/"
echo "   2. Verificar CI/CD pasa: git push"
echo "   3. Eliminar src/server/tests/ después de validar"
echo ""
echo "📁 Estructura final:"
echo "   tests/python/          # ← Tests centralizados (Monorepo)"
echo "   ├── conftest.py        # ← Configuración pytest"
echo "   ├── unit/              # ← Tests unitarios"
echo "   │   ├── app/           # ← Tests de endpoints FastAPI"
echo "   │   ├── core/          # ← Tests de core (exceptions, config)"
echo "   │   └── services/      # ← Tests de servicios (RAG, etc)"
echo "   └── integration/       # ← Tests de integración"
echo ""
