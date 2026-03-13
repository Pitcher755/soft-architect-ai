#!/bin/bash
set -e

# ===============================================================================
# FLUTTER COVERAGE HTML REPORT GENERATOR
# ===============================================================================
# MANDATORY RULE: All Flutter coverage MUST be generated in PROJECT_ROOT/coverage/
# This script is the ONLY source of truth for Flutter coverage HTML reports.
# ===============================================================================

# Navigate to project root (script is in scripts/testing/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "📊 Generando coverage con Flutter..."
echo "📂 Directorio raíz: $PROJECT_ROOT"
echo "⏳ Esto puede tomar 2-3 minutos..."
echo

# Clean previous coverage data in canonical location
rm -rf "$PROJECT_ROOT/coverage"

# Run tests from tests/ directory
cd "$PROJECT_ROOT/tests"

# Ejecutar tests con coverage
flutter test --coverage 2>&1 | grep -E "(^Running|^✓|^✗|^All tests|^Generating|passed)" || true

echo
echo "✅ Tests completados"

# Verificar si lcov.info existe
if [ -f "coverage/lcov.info" ]; then
    echo "📄 lcov.info encontrado ($(wc -l < coverage/lcov.info) líneas)"
    
    # Move coverage to canonical location (PROJECT_ROOT/coverage/)
    echo "📦 Moviendo cobertura a ubicación canónica: $PROJECT_ROOT/coverage/"
    mv coverage "$PROJECT_ROOT/coverage"
    
    cd "$PROJECT_ROOT"
    
    echo
    echo "📊 Generando reporte HTML con genhtml..."

    # Crear directorio para HTML
    mkdir -p coverage/html

    # Generar HTML
    genhtml coverage/lcov.info -o coverage/html 2>&1 | grep -E "(Overall|Reading|Writing|lines|functions)" || true

    echo
    echo "✅ Reporte HTML generado en: coverage/html/index.html"
    echo "📍 Ubicación canónica: $PROJECT_ROOT/coverage/"
    echo
    echo "📊 Resumen:"
    ls -lh coverage/html/index.html
    
    echo
    echo "🌐 Abrir con:"
    echo "   xdg-open $PROJECT_ROOT/coverage/html/index.html"
else
    echo "❌ lcov.info no encontrado"
    ls -la coverage/ || echo "❌ Coverage directory no existe"
fi
