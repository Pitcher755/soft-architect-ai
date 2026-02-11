#!/usr/bin/env bash
#
# PHASE 3 REFACTOR - BULK APPLY SCRIPT
# Applies Black, Ruff, and Pyright to all Python files
#

set -e

LOG_FILE="phase3_refactor_log.txt"
> "$LOG_FILE"  # Clear previous log

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "🚀 PHASE 3: REFACTOR BULK APPLICATION"
log "======================================"
log "Start time: $(date)"
log ""

# 1. BLACK FORMATTER
log "📋 Step 1: Black Formatter (Python code formatting)"
log "Target: All Python files with 100-char line length"
log ""

find . -name "*.py" -type f \
    -not -path "./venv/*" \
    -not -path "./.git/*" \
    -not -path "./__pycache__/*" \
    -not -path "./build/*" \
    -not -path "./.pytest_cache/*" \
    -not -path "./tests/test_cache/*" \
    -not -path "./tests/venv/*" \
    | while read -r file; do

    if echo "$file" | grep -q "site-packages\|dist-packages"; then
        continue
    fi

    if black "$file" --line-length=100 --quiet 2>/dev/null; then
        log "  ✓ $file"
    else
        log "  ✗ $file (ERROR)"
    fi
done

log ""
log "✅ Black formatter complete"
log ""

# 2. RUFF LINTER
log "📋 Step 2: Ruff Linter (Python code quality)"
log "Target: All Python files - AUTO-FIX enabled"
log ""

if ruff check . --fix --quiet 2>/dev/null; then
    log "✅ Ruff linter complete (auto-fixes applied)"
else
    log "⚠️  Ruff linter completed with warnings"
fi
log ""

# 3. Type Checking Info
log "📋 Step 3: Type Safety (Pyright)"
log "Target: Core application files only"
log ""

if command -v pyright &> /dev/null; then
    pyright api/ core/ domain/ services/ utils/ 2>&1 | tee -a "$LOG_FILE" || true
    log "✅ Pyright check complete"
else
    log "⚠️  Pyright not found (install: npm install -g pyright)"
fi
log ""

# 4. Summary
log "======================================"
log "Phase 3 Refactor Complete!"
log "End time: $(date)"
log ""
log "Changed files will show in: git status"
log "To review changes: git diff"
log "To commit: git add . && git commit -m 'refactor: apply phase 3 to all Python'"
log ""
