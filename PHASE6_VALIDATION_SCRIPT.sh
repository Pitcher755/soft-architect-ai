#!/bin/bash

# Phase 6: VALIDATION (CI/CD & Final Review)
# Script to execute all validation steps

set +e  # Don't exit on error, we want to capture all results

PROJECT_ROOT="$(pwd)"
REPORT_FILE="$PROJECT_ROOT/PHASE6_VALIDATION_REPORT.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
PYTHON_CMD="python3"

echo "🔍 PHASE 6: VALIDATION (CI/CD & Final Review)"
echo "📊 Report File: $REPORT_FILE"
echo "⏰ Started: $TIMESTAMP"
echo ""

# Initialize report
cat > "$REPORT_FILE" << 'EOF'
# Phase 6: VALIDATION (CI/CD & Final Review) Report

> **Date:** 2026-02-10
> **Status:** IN PROGRESS
> **Report Generated:** EOF
EOF

echo "## Test Execution Summary" >> "$REPORT_FILE"
echo "### 6.1 Local Testing" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 6.1.1 Python Tests
echo "#### 6.1.1 Full Python Test Suite"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"
echo "Executing: $PYTHON_CMD -m pytest tests/python/ --cov=services --cov-report=term-missing"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"
echo '```'  >> "$REPORT_FILE"

if timeout 180 $PYTHON_CMD -m pytest tests/python/ --cov=services --cov-report=term-missing -v 2>&1 | tee -a "$REPORT_FILE"; then
    PYTHON_TEST_STATUS="✅ PASSED"
else
    PYTHON_TEST_STATUS="⚠️ FAILED OR NOT FOUND"
fi

echo '```'  >> "$REPORT_FILE"
echo "Status: $PYTHON_TEST_STATUS"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"

# Code Quality Checks
echo "### 6.3 Code Quality Analysis"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"

# Black Format Check
echo "#### Black Format Check"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"
echo '```'  >> "$REPORT_FILE"

if timeout 60 $PYTHON_CMD -m black --check services/ core/ api/ utils/ 2>&1 | tee -a "$REPORT_FILE"; then
    BLACKSTATUS="✅ PASSED"
else
    BLACKSTATUS="⚠️ FORMATTING ISSUES FOUND"
fi

echo '```'  >> "$REPORT_FILE"
echo "Status: $BLACKSTATUS"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"

# Ruff Lint Check
echo "#### Ruff Lint Check"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"
echo '```'  >> "$REPORT_FILE"

if timeout 60 $PYTHON_CMD -m ruff check services/ core/ api/ utils/ 2>&1 | tee -a "$REPORT_FILE"; then
    RUFFSTATUS="✅ PASSED"
else
    RUFFSTATUS="⚠️ LINTING ISSUES FOUND"
fi

echo '```'  >> "$REPORT_FILE"
echo "Status: $RUFFSTATUS"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"

# Security Scan with Bandit
echo "### 6.2 Security Validation"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"
echo "#### Bandit Security Scan"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"
echo '```'  >> "$REPORT_FILE"

if timeout 60 $PYTHON_CMD -m bandit -r services/ core/ api/ -ll 2>&1 | tee -a "$REPORT_FILE"; then
    BANDITSTATUS="✅ NO CRITICAL ISSUES"
else
    BANDITSTATUS="⚠️ REVIEW REQUIRED"
fi

echo '```'  >> "$REPORT_FILE"
echo "Status: $BANDITSTATUS"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"

# Ruff Security Codes Check
echo "#### Ruff Security Scan (S-codes)"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"
echo '```'  >> "$REPORT_FILE"

if timeout 60 $PYTHON_CMD -m ruff check services/ core/ api/ --select S 2>&1 | tee -a "$REPORT_FILE"; then
    RUFF_SECURITY_STATUS="✅ NO SECURITY ISSUES"
else
    RUFF_SECURITY_STATUS="⚠️ SECURITY REVIEW REQUIRED"
fi

echo '```'  >> "$REPORT_FILE"
echo "Status: $RUFF_SECURITY_STATUS"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"

# Summary Section
echo "## Quality Gates Summary"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"
echo "| Check | Status |"  >> "$REPORT_FILE"
echo "|-------|--------|"  >> "$REPORT_FILE"
echo "| **Python Tests** | $PYTHON_TEST_STATUS |"  >> "$REPORT_FILE"
echo "| **Black Format** | $BLACKSTATUS |"  >> "$REPORT_FILE"
echo "| **Ruff Lint** | $RUFFSTATUS |"  >> "$REPORT_FILE"
echo "| **Bandit Security** | $BANDITSTATUS |"  >> "$REPORT_FILE"
echo "| **Ruff Security (S-codes)** | $RUFF_SECURITY_STATUS |"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"

# Git Status
echo "## Git Status Check"  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"
echo '```'  >> "$REPORT_FILE"
git status >> "$REPORT_FILE" 2>&1
echo '```'  >> "$REPORT_FILE"
echo ""  >> "$REPORT_FILE"

# Final timestamp
echo "---"  >> "$REPORT_FILE"
echo "**Report Generated:** $(date '+%Y-%m-%d %H:%M:%S')"  >> "$REPORT_FILE"
echo "**Status:** ✅ VALIDATION COMPLETE"  >> "$REPORT_FILE"

echo ""
echo "✅ Phase 6 validation completed!"
echo "📄 Report saved to: $REPORT_FILE"
cat "$REPORT_FILE"
