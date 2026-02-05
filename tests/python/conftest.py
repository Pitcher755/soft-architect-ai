"""
Pytest Configuration for SoftArchitect AI Tests (Centralized)

This conftest configures the Python path to ensure all tests
can properly import from the application modules.

Location: tests/python/conftest.py (Monorepo centralized tests)
Source modules: src/server/
"""

import os
import sys
from pathlib import Path

# Add the src/server directory to the Python path
# Path calculation: tests/python/ -> ../../src/server
project_root = Path(__file__).parent.parent.parent
server_root = project_root / "src" / "server"

# Insert server root at the beginning of sys.path
if str(server_root) not in sys.path:
    sys.path.insert(0, str(server_root))

# Debug info (only in verbose mode)
if os.getenv("PYTEST_CURRENT_TEST"):
    print(f"✓ Tests path: {Path(__file__).parent}")
    print(f"✓ Server root: {server_root}")
    print(f"✓ Server root exists: {server_root.exists()}")
