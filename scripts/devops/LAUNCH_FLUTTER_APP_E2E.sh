#!/bin/bash

# HU-4.4 E2E Testing - Launch Flutter with Real Backend
# Ejecuta la app Flutter conectada al backend Docker (localhost:8000)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../.."
CLIENT_DIR="$PROJECT_ROOT/src/client"

echo "🚀 HU-4.4 E2E Testing - Launching Flutter App with Real Backend"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado o no está en el PATH"
    exit 1
fi

# Check if Docker backend is running
echo "🔍 Verificando backend Docker..."
if ! docker ps | grep -q "sa_api"; then
    echo "⚠️  Backend no detectado en Docker"
    echo ""
    echo "Por favor, inicia el backend primero:"
    echo "  cd $PROJECT_ROOT"
    echo "  ./scripts/devops/start_stack.sh"
    echo ""
    read -p "¿Quieres iniciar el backend ahora? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 Iniciando stack Docker..."
        cd "$PROJECT_ROOT"
        ./scripts/devops/start_stack.sh
    else
        echo "❌ No se puede continuar sin el backend"
        exit 1
    fi
fi

echo "✅ Backend Docker detectado (sa_api)"
echo ""

# Validate backend health
echo "🏥 Verificando salud del backend..."
BACKEND_URL="http://localhost:8000"
if curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/health" | grep -q "200"; then
    echo "✅ Backend funcional en $BACKEND_URL"
else
    echo "⚠️  Backend no responde en $BACKEND_URL/health"
    echo "   Continuando de todos modos (puede estar iniciándose)..."
fi
echo ""

# Run analysis
echo "📋 Verificando compilación..."
cd "$CLIENT_DIR"

echo "🔍 Ejecutando flutter analyze..."
if ! flutter analyze --no-fatal-infos 2>&1 | tail -3; then
    echo "❌ Errores encontrados"
    exit 1
fi

echo ""
echo "✅ Compilación OK"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Iniciando app con BACKEND REAL..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔧 Configuración:"
echo "   USE_REAL_BACKEND=true"
echo "   BACKEND_BASE_URL=$BACKEND_URL"
echo "   BACKEND_API_KEY=dev-key"
echo ""
echo "⚡ Para validar E2E:"
echo "   1. Navega al panel de Chat (lado derecho)"
echo "   2. Escribe: '¿Qué es una API REST?'"
echo "   3. Presiona el botón de enviar (📤)"
echo ""
echo "✅ Deberías ver:"
echo "   • Mensaje del usuario (burbuja azul, derecha)"
echo "   • Mensaje de IA (burbuja gris, izquierda)"
echo "   • Efecto máquina de escribir (streaming tokens)"
echo "   • Respuesta completa en ~5-10 segundos"
echo ""
echo "🧪 Test de Graceful Degradation:"
echo "   1. Detener ChromaDB: docker stop sa_chromadb"
echo "   2. Enviar mensaje en el chat"
echo "   3. Debería funcionar con template Fallback (sin error 500)"
echo "   4. Restaurar: docker start sa_chromadb"
echo ""

flutter run -d linux \
  --dart-define=USE_REAL_BACKEND=true \
  --dart-define=BACKEND_BASE_URL="$BACKEND_URL" \
  --dart-define=BACKEND_API_KEY=dev-key
