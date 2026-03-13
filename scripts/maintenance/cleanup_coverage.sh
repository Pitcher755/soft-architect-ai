#!/bin/bash
set -e

# ===============================================================================
# COVERAGE DIRECTORIES CLEANUP SCRIPT
# ===============================================================================
# Purpose: Remove all scattered coverage directories, keeping only canonical ones
# Canonical locations:
#   - Flutter: PROJECT_ROOT/coverage/
#   - Python:  PROJECT_ROOT/coverage_html/
# ===============================================================================

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧹 ========================================"
echo "📊 LIMPIEZA DE DIRECTORIOS DE COBERTURA"
echo "=========================================="
echo ""
echo "📂 Directorio raíz: $PROJECT_ROOT"
echo ""

# Find all scattered coverage directories (excluding canonical ones)
echo "🔍 Buscando directorios de cobertura dispersos..."
SCATTERED_DIRS=$(find . -maxdepth 3 -type d \( -name "htmlcov*" -o -name "coverage" \) \
  ! -path "./coverage" ! -path "./coverage_html" 2>/dev/null || true)

if [ -z "$SCATTERED_DIRS" ]; then
    echo "✅ No se encontraron directorios dispersos. ¡Estructura limpia!"
    echo ""
    echo "📍 Directorios canónicos actuales:"
    [ -d "coverage" ] && echo "   ✓ coverage/ (Flutter)" || echo "   ✗ coverage/ (no existe)"
    [ -d "coverage_html" ] && echo "   ✓ coverage_html/ (Python)" || echo "   ✗ coverage_html/ (no existe)"
    exit 0
fi

echo "⚠️  Directorios dispersos encontrados:"
echo "$SCATTERED_DIRS" | sed 's/^/   - /'
echo ""

# Ask for confirmation
read -p "¿Deseas eliminar estos directorios? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Operación cancelada por el usuario"
    exit 0
fi

echo ""
echo "🗑️  Eliminando directorios dispersos..."

# Remove scattered directories
REMOVED_COUNT=0
while IFS= read -r dir; do
    if [ -d "$dir" ]; then
        echo "   Eliminando: $dir"
        rm -rf "$dir"
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    fi
done <<< "$SCATTERED_DIRS"

echo ""
echo "✅ Limpieza completada: $REMOVED_COUNT directorios eliminados"
echo ""
echo "📍 Estructura final (directorios canónicos):"
[ -d "coverage" ] && echo "   ✓ coverage/ (Flutter)" || echo "   ✗ coverage/ (no existe)"
[ -d "coverage_html" ] && echo "   ✓ coverage_html/ (Python)" || echo "   ✗ coverage_html/ (no existe)"
echo ""
echo "🎯 Recuerda:"
echo "   - Flutter coverage DEBE generarse SOLO en: ./coverage/"
echo "   - Python coverage DEBE generarse SOLO en: ./coverage_html/"
echo ""
echo "📚 Ver AGENTS.md sección 8.M para reglas completas"
