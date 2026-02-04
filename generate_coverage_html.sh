#!/bin/bash

cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai/tests/flutter

echo "📊 Generando coverage con Flutter..."
echo "⏳ Esto puede tomar 2-3 minutos..."
echo

# Ejecutar tests con coverage
flutter test --coverage 2>&1 | grep -E "(^Running|^✓|^✗|^All tests|^Generating|passed)" || true

echo
echo "✅ Tests completados"

# Verificar si lcov.info existe
if [ -f "coverage/lcov.info" ]; then
    echo "📄 lcov.info encontrado ($(wc -l < coverage/lcov.info) líneas)"
    echo
    echo "📊 Generando reporte HTML con genhtml..."

    # Crear directorio para HTML
    mkdir -p coverage/html

    # Generar HTML
    genhtml coverage/lcov.info -o coverage/html 2>&1 | grep -E "(Overall|Reading|Writing|lines|functions)" || true

    echo
    echo "✅ Reporte HTML generado en: coverage/html/index.html"
    echo
    echo "📊 Resumen:"
    ls -lh coverage/html/index.html
else
    echo "❌ lcov.info no encontrado"
    ls -la coverage/ || echo "❌ Coverage directory no existe"
fi
