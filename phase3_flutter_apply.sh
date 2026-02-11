#!/usr/bin/env bash
#
# PHASE 3 REFACTOR - FLUTTER BULK APPLY SCRIPT
# Applies Dart format and Flutter analyzer to all Dart files
#

set -e

LOG_FILE="phase3_flutter_refactor_log.txt"
> "$LOG_FILE"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "🚀 PHASE 3: FLUTTER REFACTOR"
log "============================="
log "Start time: $(date)"
log ""

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    log "❌ ERROR: Flutter is not installed or not in PATH"
    log "Please install Flutter first: https://flutter.dev/docs/get-started/install"
    exit 1
fi

log "Using Flutter: $(flutter --version | head -1)"
log ""

# 1. DART FORMAT
log "📋 Step 1: Dart Format (code formatting)"
log "Target: All Dart files in src/client/lib and tests/test"
log ""

dart_files=$(find ./src/client/lib ./tests/test -name "*.dart" 2>/dev/null | wc -l)
log "Found $dart_files Dart files"
log ""

find ./src/client/lib ./tests/test -name "*.dart" 2>/dev/null | while read -r file; do
    if dart format "$file" > /dev/null 2>&1; then
        log "  ✓ $file"
    else
        log "  ✗ $file (ERROR)"
    fi
done

log ""
log "✅ Dart formatter complete"
log ""

# 2. FLUTTER ANALYZE
log "📋 Step 2: Flutter Analyzer (static analysis)"
log "Target: src/client/lib"
log ""

if flutter analyze --no-pub 2>&1 | tee -a "$LOG_FILE"; then
    log "✅ Flutter analyzer complete"
else
    log "⚠️  Flutter analyzer completed with warnings/info"
fi
log ""

# 3. Summary
log "============================="
log "Phase 3 Flutter Refactor Complete!"
log "End time: $(date)"
log ""
log "Changed files: git status"
log "To commit: git add . && git commit -m 'refactor: apply phase 3 flutter'"
log ""
