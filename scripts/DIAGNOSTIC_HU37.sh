#!/bin/bash
##############################################################################
# HU-3.7: Diagnostic Report
# Analysis of current feature implementation status
# Created: 2026-02-11
##############################################################################

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$PROJECT_ROOT/src/client"

echo "=========================================="
echo "HU-3.7: DIAGNOSTIC REPORT"
echo "=========================================="

# Function to check if file exists
check_file() {
    local file="$1"
    local label="$2"
    if [ -f "$file" ]; then
        local lines=$(wc -l < "$file")
        echo "  ✅ $label ($lines lines)"
        return 0
    else
        echo "  ❌ $label (NOT FOUND)"
        return 1
    fi
}

# Feature 1: LastProjectLocalDataSource
echo ""
echo "[FEATURE 1] LastProjectLocalDataSource"
check_file "$CLIENT_DIR/lib/features/settings/data/datasources/last_project_local_datasource.dart" "Implementation"
check_file "$PROJECT_ROOT/tests/test/features/settings/data/datasources/last_project_local_datasource_test.dart" "Tests"

# Feature 2: ProfileSection
echo ""
echo "[FEATURE 2] ProfileSection"
check_file "$CLIENT_DIR/lib/features/settings/presentation/widgets/profile_section.dart" "Widget"
check_file "$PROJECT_ROOT/tests/test/features/settings/presentation/widgets/profile_section_test.dart" "Tests"

# Feature 3: AppearanceSection
echo ""
echo "[FEATURE 3] AppearanceSection + LanguageSelector"
check_file "$CLIENT_DIR/lib/features/settings/presentation/widgets/appearance_section.dart" "AppearanceSection"
check_file "$CLIENT_DIR/lib/features/settings/presentation/widgets/language_selector_widget.dart" "LanguageSelector"
check_file "$PROJECT_ROOT/tests/test/features/settings/presentation/widgets/appearance_section_test.dart" "Tests"

# Feature 4: AccessibilitySection
echo ""
echo "[FEATURE 4] AccessibilitySection"
check_file "$CLIENT_DIR/lib/features/settings/presentation/widgets/accessibility_section.dart" "Widget"
check_file "$PROJECT_ROOT/tests/test/features/settings/presentation/widgets/accessibility_section_test.dart" "Tests"

# Feature 5: PerformanceSection
echo ""
echo "[FEATURE 5] PerformanceSection"
check_file "$CLIENT_DIR/lib/features/settings/presentation/widgets/performance_section.dart" "Widget"
check_file "$PROJECT_ROOT/tests/test/features/settings/presentation/widgets/performance_section_test.dart" "Tests"

# Domain Layer
echo ""
echo "[DOMAIN LAYER] Entities & UseCases"
check_file "$CLIENT_DIR/lib/features/settings/domain/entities/settings_entity.dart" "SettingsEntity"
check_file "$CLIENT_DIR/lib/features/settings/domain/entities/language_preference.dart" "LanguagePreference"
check_file "$CLIENT_DIR/lib/features/settings/domain/entities/accessibility_settings.dart" "AccessibilitySettings"
check_file "$CLIENT_DIR/lib/features/settings/domain/exceptions/settings_exceptions.dart" "Exceptions"

# Data Layer
echo ""
echo "[DATA LAYER] Repositories"
check_file "$CLIENT_DIR/lib/features/settings/data/repositories/settings_repository_impl.dart" "SettingsRepo"
check_file "$CLIENT_DIR/lib/features/settings/data/repositories/last_project_repository_impl.dart" "LastProjectRepo"

# Presentation Layer
echo ""
echo "[PRESENTATION LAYER] Providers & Notifiers"
check_file "$CLIENT_DIR/lib/features/settings/presentation/providers/settings_providers.dart" "Providers"
check_file "$CLIENT_DIR/lib/features/settings/presentation/notifiers/settings_notifier.dart" "Notifier"

echo ""
echo "=========================================="
echo "Analysis complete!"
echo "=========================================="
