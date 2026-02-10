#!/bin/bash

# HU-3.3 Widget Integration - Quick Launch Script
# Ejecuta la app Flutter con los widgets integrados

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$SCRIPT_DIR/src/client"

echo "🚀 HU-3.3 Widget Integration - Launching Flutter App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado o no está en el PATH"
    exit 1
fi

echo "📋 Verificando compilación..."
cd "$CLIENT_DIR"

# Run analysis
echo "🔍 Ejecutando flutter analyze..."
if ! flutter analyze --no-fatal-infos 2>&1 | tail -3; then
    echo "❌ Errores encontrados"
    exit 1
fi

echo ""
echo "✅ Compilación OK"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Iniciando app... (asegúrate de tener Linux disponible)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚡ Una vez la app inicie:"
echo "   1. Busca el botón de CHAT en la AppBar (ícono de chat_outlined)"
echo "   2. Clickea para abrir ChatScreen"
echo "   3. Deberías ver:"
echo "      • Empty state message (bienvenida)"
echo "      • Input area para mensajes"
echo "      • Streaming indicator cuando se procesa"
echo ""
echo "🎯 Widgets que deberías ver:"
echo "   ✓ MessageBubbleWidget - Renderiza mensajes"
echo "   ✓ StreamingIndicatorWidget - Muestra progreso"
echo "   ✓ ProposalCardWidget - Listo para propuestas"
echo ""

flutter run -d linux
