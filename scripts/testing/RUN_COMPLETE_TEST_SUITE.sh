#!/bin/bash
# Compatibility wrapper (kept for existing docs/commands)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/run_tests.sh" all --coverage
