#!/bin/bash
# 🔍 VERIFICATION SCRIPT: Sistema Híbrido de Proyectos
#
# Este script verifica que la implementación híbrida está correcta.
# Uso: bash VERIFY_HYBRID_SYSTEM.sh

set -e

echo "🔍 Iniciando verificación del sistema híbrido..."
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de checks
PASSED=0
FAILED=0

# Función para verificar
check() {
  local description="$1"
  local command="$2"

  echo -n "⏳ Verificando: $description... "

  if eval "$command" > /dev/null 2>&1; then
    echo -e "${GREEN}✅${NC}"
    PASSED=$((PASSED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
}

# Función para verificar existencia de archivo
check_file() {
  local filepath="$1"
  local description="${2:-$filepath}"
  check "$description" "test -f '$filepath'"
}

# Función para verificar patrón en archivo
check_pattern() {
  local filepath="$1"
  local pattern="$2"
  local description="${3:-Pattern in $filepath}"
  check "$description" "grep -q '$pattern' '$filepath'"
}

# ============================
# SECCIÓN 1: ARCHIVOS
# ============================
echo "📁 VERIFICACIÓN DE ARCHIVOS"
echo "================================"

check_file "src/client/lib/features/project_shell/presentation/providers/projects_provider.dart" \
  "projects_provider.dart existe"

check_file "src/client/lib/features/project_shell/data/mock_projects_data.dart" \
  "mock_projects_data.dart existe"

check_file "src/client/lib/features/project_shell/data/mock_data.dart" \
  "mock_data.dart existe"

check_file "src/client/lib/features/project_shell/domain/entities/project.dart" \
  "project.dart existe"

check_file "doc/HYBRID_SYSTEM_IMPLEMENTATION.md" \
  "Documentación del sistema híbrido"

echo ""

# ============================
# SECCIÓN 2: CÓDIGO CLAVE
# ============================
echo "💻 VERIFICACIÓN DE CÓDIGO CLAVE"
echo "================================"

check_pattern \
  "src/client/lib/features/project_shell/presentation/providers/projects_provider.dart" \
  "buildHybridProjectsList" \
  "buildHybridProjectsList() definida"

check_pattern \
  "src/client/lib/features/project_shell/domain/entities/project.dart" \
  "String get phase" \
  "Getter phase en Project"

check_pattern \
  "src/client/lib/features/project_shell/data/mock_data.dart" \
  "guideRootNode" \
  "guideRootNode definida"

check_pattern \
  "src/client/lib/features/project_shell/data/mock_data.dart" \
  "guideFileContents" \
  "guideFileContents definida"

check_pattern \
  "src/client/lib/features/project_shell/presentation/screens/project_workspace_screen.dart" \
  "buildHybridProjectsList" \
  "buildHybridProjectsList() usada en workspace"

echo ""

# ============================
# SECCIÓN 3: PROTOCOLO VIRTUAL
# ============================
echo "🔗 VERIFICACIÓN DE PROTOCOLO VIRTUAL"
echo "====================================="

check_pattern \
  "src/client/lib/features/filesystem/presentation/widgets/file_tree_widget.dart" \
  "mock://" \
  "Detección mock:// en file_tree_widget"

check_pattern \
  "src/client/lib/features/project_shell/presentation/screens/project_shell_screen.dart" \
  "mock://" \
  "Detección mock:// en project_shell_screen"

check_pattern \
  "src/client/lib/features/project_shell/data/mock_projects_data.dart" \
  "mock://" \
  "Protocolo mock:// en mock_projects_data"

echo ""

# ============================
# SECCIÓN 4: IMPORTS
# ============================
echo "📦 VERIFICACIÓN DE IMPORTS"
echo "=========================="

check_pattern \
  "src/client/lib/features/project_shell/presentation/screens/project_workspace_screen.dart" \
  "import.*projects_provider" \
  "projects_provider importada en workspace"

check_pattern \
  "src/client/lib/features/filesystem/presentation/widgets/file_tree_widget.dart" \
  "import.*mock_data" \
  "mock_data importada en file_tree_widget"

check_pattern \
  "src/client/lib/features/project_shell/presentation/widgets/project_list_view.dart" \
  "import.*project.dart" \
  "project.dart importada en project_list_view"

echo ""

# ============================
# SECCIÓN 5: ESTRUCTURA DE DATOS
# ============================
echo "📊 VERIFICACIÓN DE ESTRUCTURA DE DATOS"
echo "======================================"

check_pattern \
  "src/client/lib/features/project_shell/data/mock_data.dart" \
  "FileNode.*guideRootNode" \
  "guideRootNode es FileNode"

check_pattern \
  "src/client/lib/features/project_shell/data/mock_data.dart" \
  "Map.*guideFileContents" \
  "guideFileContents es Map<String, String>"

check_pattern \
  "src/client/lib/features/project_shell/data/mock_projects_data.dart" \
  "getMockProjectsData" \
  "Función getMockProjectsData() existe"

echo ""

# ============================
# SECCIÓN 6: CONSISTENCIA
# ============================
echo "🔄 VERIFICACIÓN DE CONSISTENCIA"
echo "================================"

# Verificar que Project no usa lastModified
check_pattern \
  "src/client/lib/features/project_shell/domain/entities/project.dart" \
  "createdAt" \
  "Project usa createdAt"

check_pattern \
  "src/client/lib/features/project_shell/domain/entities/project.dart" \
  "lastOpened" \
  "Project usa lastOpened"

# Verificar que no usa propiedades inválidas en algunos archivos
if grep -q "project\['name'\]" src/client/lib/features/project_shell/presentation/screens/project_workspace_screen.dart 2>/dev/null; then
  echo -e "❌ Aún hay acceso Map en project_workspace_screen"
  FAILED=$((FAILED + 1))
else
  echo -e "✅ No hay acceso Map en project_workspace_screen"
  PASSED=$((PASSED + 1))
fi

echo ""

# ============================
# RESUMEN
# ============================
echo "📋 RESUMEN"
echo "=========="
TOTAL=$((PASSED + FAILED))
echo "Total verificaciones: $TOTAL"
echo -e "Pasadas: ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✨ ¡Todas las verificaciones pasaron! ✨${NC}"
  echo "El sistema híbrido está correctamente implementado."
  exit 0
else
  echo -e "${RED}⚠️  Algunas verificaciones fallaron.${NC}"
  echo "Por favor revisa los problemas anteriores."
  exit 1
fi
