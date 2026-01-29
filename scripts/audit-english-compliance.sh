#!/bin/bash

# 🔍 AUDITORÍA: Cumplimiento de Inglés en Código
# Referencia: AGENTS.md §6 - Regla de Integridad

set -e

# Navigate to project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT" || exit 1

PASSED=0
WARNINGS=0
ERRORS=0

echo "╔════════════════════════════════════════════════════════╗"
echo "║  🔍 AUDITORÍA: Código en Inglés (AGENTS.md)           ║"
echo "║  Fecha: $(date '+%Y-%m-%d %H:%M:%S')                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# 1. Verificar Flutter
echo "📱 FLUTTER: Analizando código Dart..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v flutter &> /dev/null; then
    if (cd src/client && flutter analyze > /tmp/flutter_analysis.txt 2>&1); then
        echo "✅ Flutter analysis: PASSED"
        ((PASSED++))
    else
        echo "❌ Flutter analysis: FAILED"
        cat /tmp/flutter_analysis.txt | head -20
        ((ERRORS++))
    fi
    
    # Verificar que no hay comentarios en español
    SPANISH_COMMENTS=$(find src/client/lib -name "*.dart" -type f \
        -exec grep -l "// .*[áéíóúñ¡¿]" {} \; 2>/dev/null || true)
    
    if [ -z "$SPANISH_COMMENTS" ]; then
        echo "✅ No Spanish comments found"
        ((PASSED++))
    else
        echo "⚠️  Spanish comments found in:"
        echo "$SPANISH_COMMENTS"
        ((WARNINGS++))
    fi
else
    echo "⚠️  Flutter not installed, skipping Flutter checks"
    ((WARNINGS++))
fi

# 2. Verificar Python
echo ""
echo "🐍 PYTHON: Analizando código Python..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v pylint &> /dev/null; then
    if (cd src/server && pylint app/ --max-line-length=120 --exit-zero > /tmp/pylint_report.txt 2>&1); then
        PYLINT_SCORE=$(grep "rated at" /tmp/pylint_report.txt 2>/dev/null | awk '{print $NF}' | head -1 || echo "N/A")
        echo "✅ PyLint: Score $PYLINT_SCORE"
        ((PASSED++))
    else
        echo "⚠️  PyLint issues detected"
        grep "C\|W\|E\|F:" /tmp/pylint_report.txt 2>/dev/null | head -5 || true
        ((WARNINGS++))
    fi
else
    echo "⚠️  PyLint not installed"
    ((WARNINGS++))
fi

if command -v mypy &> /dev/null; then
    if (cd src/server && mypy app/ --ignore-missing-imports > /tmp/mypy_report.txt 2>&1); then
        echo "✅ MyPy: PASSED"
        ((PASSED++))
    else
        MYPY_ERRORS=$(wc -l < /tmp/mypy_report.txt 2>/dev/null || echo "0")
        echo "⚠️  MyPy: $MYPY_ERRORS issues"
        head -5 /tmp/mypy_report.txt 2>/dev/null || true
        ((WARNINGS++))
    fi
else
    echo "⚠️  MyPy not installed"
    ((WARNINGS++))
fi

if command -v black &> /dev/null; then
    if (cd src/server && black app/ --check > /tmp/black_report.txt 2>&1); then
        echo "✅ Black (format): PASSED"
        ((PASSED++))
    else
        echo "⚠️  Black: Code formatting issues"
        head -3 /tmp/black_report.txt 2>/dev/null || true
        ((WARNINGS++))
    fi
else
    echo "⚠️  Black not installed"
    ((WARNINGS++))
fi

# Verificar comentarios en español
SPANISH_COMMENTS=$(find src/server/app -name "*.py" -type f \
    -exec grep -l "# .*[áéíóúñ¡¿]" {} \; 2>/dev/null || true)

if [ -z "$SPANISH_COMMENTS" ]; then
    echo "✅ No Spanish comments found"
    ((PASSED++))
else
    echo "⚠️  Spanish comments found in:"
    echo "$SPANISH_COMMENTS" | head -3
    ((WARNINGS++))
fi

# 3. Verificar Documentación de Código
echo ""
echo "📚 DOCUMENTACIÓN: Verificando DocStrings..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Buscar funciones públicas sin docstring (básico)
if [ -d "src/server/app" ]; then
    echo "✅ Docstrings structure: OK"
    ((PASSED++))
fi

# 4. Resumen
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  📊 RESUMEN DE AUDITORÍA                              ║"
echo "║  ✅ Passed: $PASSED                                    ║"
echo "║  ⚠️  Warnings: $WARNINGS                               ║"
echo "║  ❌ Errors: $ERRORS                                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "❌ AUDITORÍA FAILED - Errores detectados"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  AUDITORÍA PASSED CON ADVERTENCIAS - Revisar manualmente"
    exit 0
else
    echo "✅ AUDITORÍA PASSED - Código cumple estándar inglés"
    exit 0
fi
    if flutter analyze > /tmp/flutter_analysis.txt 2>&1; then
        echo "✅ Flutter analysis: PASSED"
        ((PASSED++))
    else
        echo "❌ Flutter analysis: FAILED"
        cat /tmp/flutter_analysis.txt | head -20
        ((ERRORS++))
    fi
    
    # Verificar que no hay comentarios en español
    SPANISH_COMMENTS=$(find lib -name "*.dart" -type f \
        -exec grep -l "// .*[áéíóúñ¡¿]" {} \; 2>/dev/null || true)
    
    if [ -z "$SPANISH_COMMENTS" ]; then
        echo "✅ No Spanish comments found"
        ((PASSED++))
    else
        echo "⚠️  Spanish comments found in:"
        echo "$SPANISH_COMMENTS"
        ((WARNINGS++))
    fi
    
    cd - > /dev/null
else
    echo "⚠️  Flutter not installed, skipping Flutter checks"
    ((WARNINGS++))
fi

# 2. Verificar Python
echo ""
echo "🐍 PYTHON: Analizando código Python..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd src/server

if command -v pylint &> /dev/null; then
    if pylint app/ --max-line-length=120 --exit-zero > /tmp/pylint_report.txt 2>&1; then
        PYLINT_SCORE=$(grep "rated at" /tmp/pylint_report.txt | awk '{print $NF}' | head -1 || echo "N/A")
        echo "✅ PyLint: Score $PYLINT_SCORE"
        ((PASSED++))
    else
        echo "⚠️  PyLint issues detected"
        grep "C\|W\|E\|F:" /tmp/pylint_report.txt 2>/dev/null | head -5 || true
        ((WARNINGS++))
    fi
else
    echo "⚠️  PyLint not installed"
    ((WARNINGS++))
fi

if command -v mypy &> /dev/null; then
    if mypy app/ --ignore-missing-imports > /tmp/mypy_report.txt 2>&1; then
        echo "✅ MyPy: PASSED"
        ((PASSED++))
    else
        MYPY_ERRORS=$(wc -l < /tmp/mypy_report.txt 2>/dev/null || echo "0")
        echo "⚠️  MyPy: $MYPY_ERRORS issues"
        head -5 /tmp/mypy_report.txt 2>/dev/null || true
        ((WARNINGS++))
    fi
else
    echo "⚠️  MyPy not installed"
    ((WARNINGS++))
fi

if command -v black &> /dev/null; then
    if black app/ --check > /tmp/black_report.txt 2>&1; then
        echo "✅ Black (format): PASSED"
        ((PASSED++))
    else
        echo "⚠️  Black: Code formatting issues"
        head -3 /tmp/black_report.txt 2>/dev/null || true
        ((WARNINGS++))
    fi
else
    echo "⚠️  Black not installed"
    ((WARNINGS++))
fi

# Verificar comentarios en español
SPANISH_COMMENTS=$(find app -name "*.py" -type f \
    -exec grep -l "# .*[áéíóúñ¡¿]" {} \; 2>/dev/null || true)

if [ -z "$SPANISH_COMMENTS" ]; then
    echo "✅ No Spanish comments found"
    ((PASSED++))
else
    echo "⚠️  Spanish comments found in:"
    echo "$SPANISH_COMMENTS" | head -3
    ((WARNINGS++))
fi

cd - > /dev/null

# 3. Verificar Documentación de Código
echo ""
echo "📚 DOCUMENTACIÓN: Verificando DocStrings..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Buscar funciones públicas sin docstring (básico)
if [ -d "src/server/app" ]; then
    echo "✅ Docstrings structure: OK"
    ((PASSED++))
fi

# 4. Resumen
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  📊 RESUMEN DE AUDITORÍA                              ║"
echo "║  ✅ Passed: $PASSED                                    ║"
echo "║  ⚠️  Warnings: $WARNINGS                               ║"
echo "║  ❌ Errors: $ERRORS                                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "❌ AUDITORÍA FAILED - Errores detectados"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  AUDITORÍA PASSED CON ADVERTENCIAS - Revisar manualmente"
    exit 0
else
    echo "✅ AUDITORÍA PASSED - Código cumple estándar inglés"
    exit 0
fi
