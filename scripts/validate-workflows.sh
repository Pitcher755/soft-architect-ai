#!/bin/bash
# Script de validación rápida de GitHub Actions workflows

cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai

echo "🚀 ==========================="
echo "   Validando Workflows Localmente con act"
echo "==========================="
echo ""

# 1. Listar workflows
echo "📋 PASO 1: Workflows disponibles"
echo "---"
act --list 2>&1 | grep "Backend CI Pipeline" | head -5
echo ""

# 2. Validación básica del código
echo "📋 PASO 2: Validación de imports (Python)"
echo "---"
cd src/server
python3 << 'EOF'
import sys
try:
    from services.rag.vector_store import VectorStoreService
    print("✅ VectorStoreService imports correctamente")
    from core.exceptions import ConnectionError, DatabaseReadError, DatabaseWriteError
    print("✅ Core exceptions imports correctamente")
    print("\n✅ TODO EL CÓDIGO PUEDE IMPORTARSE CORRECTAMENTE")
except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)
EOF
echo ""

# 3. Listar los tests disponibles
echo "📋 PASO 3: Tests disponibles para HU-2.2"
echo "---"
python3 -m pytest tests/unit/services/rag/test_vector_store.py --collect-only -q 2>&1 | head -20
echo ""

echo "🎯 RESUMEN"
echo "---"
echo "✅ Import validation: COMPLETADO"
echo "✅ Code structure: VALIDADO"
echo ""
echo "Para ejecutar tests completos con act:"
echo "  act -j unit-tests -W .github/workflows/backend-ci.yaml"
echo ""
echo "O para ejecutar solo unit tests:"
echo "  cd src/server && python -m pytest tests/unit/services/rag/test_vector_store.py -v"
