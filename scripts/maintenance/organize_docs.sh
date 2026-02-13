#!/bin/bash
# Script to organize documentation files from root to doc/
# Following AGENTS.md documentation standards

set -e

PROJECT_ROOT="/home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai"
DOC_REPORTS="$PROJECT_ROOT/doc/01-PROJECT_REPORT"

cd "$PROJECT_ROOT"

echo "📚 Organizing documentation files..."

# FILES TO MOVE TO doc/01-PROJECT_REPORT/
REPORT_FILES=(
  "APPCOLORS_MIGRATION_COMPLETE.md"
  "APPCOLORS_REFERENCE.md"
  "BEFORE_AFTER_COMPARISON.md"
  "CHANGELOG_SESSION_022226.md"
  "COMPREHENSIVE_SESSION_REPORT.md"
  "CORRECION_DEFINITIVA_HYBRID_SYSTEM.md"
  "FINAL_FIX_SUMMARY.md"
  "FINAL_VERIFICATION_6.3_REPORT.md"
  "FINAL_VERIFICATION_6.3_SUMMARY.md"
  "FIXES_SUMMARY.md"
  "HYBRID_SYSTEM_CHANGELOG.md"
  "HYBRID_SYSTEM_FIXES_VALIDATION.md"
  "HYBRID_SYSTEM_READY.md"
  "IMPLEMENTATION_COMPLETE.md"
  "IMPROVEMENTS_SUMMARY_20260207.md"
  "NAVIGATION_AND_INTEGRATION_COMPLETE.md"
  "PHASE_4_COMPLETION_SUMMARY.md"
  "PHASE_4_DEEP_ANALYSIS.md"
  "PHASE_4_STATUS.md"
  "PROJECTS_DASHBOARD_IMPLEMENTATION.md"
  "PROJECT_SHELL_REFACTORING_COMPLETE.md"
  "PROJECT_SHELL_REFACTORING_SUMMARY.md"
  "PROVIDER_BEFORE_AFTER_COMPARISON.md"
  "PROVIDER_CONSOLIDATION_ANALYSIS.md"
  "PROVIDER_CONSOLIDATION_COMPLETE.md"
  "PROVIDER_CONSOLIDATION_QUICK_REF.md"
  "REFACTORING_COMPLETION_REPORT.md"
  "SPRINT3_COMPLETION_SUMMARY.md"
  "TESTING_EXECUTION_LOG.md"
  "TEST_SUITE_COMPLETE_ANALYSIS.md"
  "VERIFICATION_6.3_COMPLETE.md"
  "WORKFLOW_COMPLETION_ANALYSIS.md"
  "FILESYSTEM_SERVICE_FIX.md"
  "RESUMEN_FINAL.md"
  "EXECUTIVE_SUMMARY.md"
  "COMPLETE_FLOW_VISUALIZATION.md"
  "ENTREGA_FINAL_VISUAL.md"
)

# FILES TO MOVE TO doc/02-SETUP_DEV/
SETUP_FILES=(
  "HYBRID_SYSTEM_README.md"
  "HYBRID_SYSTEM_VERIFICATION_GUIDE.md"
  "NAVIGATION_GUIDE.md"
  "MOCK_DATA_ESCALABILITY_GUIDE.md"
  "QUICK_START.md"
  "START_HERE.md"
  "TESTING_GUIDE_HYBRID_SYSTEM.md"
  "TESTING_MANUAL.md"
  "TESTING_QUICK_START.md"
  "VALIDATION_CHECKLIST.md"
  "RESIZABLE_COLUMNS_GUIDE.md"
  "RESIZABLE_COLUMNS_TECHNICAL.md"
  "DYNAMIC_RESIZABLE_COLUMNS.md"
)

# FILES TO KEEP IN ROOT (symlinks or important entry points)
ROOT_FILES=(
  "README.md"
  "AGENTS.md"
)

# FILES TO DELETE (duplicates or obsolete)
DELETE_FILES=(
  "ARCHITECTURE_DIAGRAM.md"  # Duplicado en context/
  "DOCUMENTATION_INDEX.md"  # Duplicado de doc/INDEX.md
  "PROYECTO_SEARCH_PATHS.md"  # Obsoleto
)

# Move report files
echo "📝 Moving report files to doc/01-PROJECT_REPORT/..."
for file in "${REPORT_FILES[@]}"; do
  if [ -f "$file" ]; then
    mv "$file" "$DOC_REPORTS/"
    echo "  ✅ Moved: $file"
  else
    echo "  ⚠️  Not found: $file"
  fi
done

# Move setup/guide files
echo "📚 Moving setup/guide files to doc/02-SETUP_DEV/..."
for file in "${SETUP_FILES[@]}"; do
  if [ -f "$file" ]; then
    mv "$file" "$PROJECT_ROOT/doc/02-SETUP_DEV/"
    echo "  ✅ Moved: $file"
  else
    echo "  ⚠️  Not found: $file"
  fi
done

# Delete obsolete files
echo "🗑️  Deleting obsolete files..."
for file in "${DELETE_FILES[@]}"; do
  if [ -f "$file" ]; then
    rm "$file"
    echo "  ✅ Deleted: $file"
  else
    echo "  ⚠️  Not found: $file"
  fi
done

# Verify cleanup
echo ""
echo "✅ Documentation organization complete!"
echo ""
echo "📊 Remaining .md files in root:"
find . -maxdepth 1 -name "*.md" -type f | wc -l
echo ""
find . -maxdepth 1 -name "*.md" -type f -exec basename {} \;
