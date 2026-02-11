#!/usr/bin/env python3
"""Verification script for Phase 2 GREEN completion."""

import subprocess
import os
import sys

os.chdir("/home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai")

print("=" * 80)
print("PHASE 2: GREEN - VERIFICATION")
print("=" * 80)

# Run Python tests
print("\n1️⃣ Running Python Tests with Coverage...")
result = subprocess.run(
    [
        "pytest",
        "tests/python/",
        "--cov=src/server/app",
        "--cov-fail-under=80",
        "-q",
        "--tb=line",
    ],
    capture_output=True,
    text=True,
    timeout=120,
)

print(result.stdout)
if result.stderr:
    print("STDERR:", result.stderr)

python_success = result.returncode == 0
print(
    "✅ PYTHON TESTS: PASSED"
    if python_success
    else f"❌ PYTHON TESTS: FAILED (exit code: {result.returncode})"
)

print("\n" + "=" * 80)
print("VERIFICATION COMPLETE")
print("=" * 80)
print(f"Python Tests: {'✅ PASS' if python_success else '❌ FAIL'}")

sys.exit(0 if python_success else 1)
