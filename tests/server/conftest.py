"""
Pytest Configuration for SoftArchitect AI Tests (Centralized)

This conftest configures the Python path to ensure all tests
can properly import from the application modules.

CRITICAL: This file is loaded FIRST by pytest before any test collection.
"""

import sys
from pathlib import Path

# Get the project root (three levels up from this file)
# File: /path/to/soft-architect-ai/tests/python/conftest.py
# Root: /path/to/soft-architect-ai/
project_root = Path(__file__).parent.parent.parent

# Define the key paths
server_root = project_root / "src" / "server"
app_root = server_root / "app"

# Add paths to sys.path in order of priority
# Insert at position 0 so they're checked FIRST before any standard library paths
paths_to_configure = [
    str(server_root),  # /path/to/soft-architect-ai/src/server
    str(project_root),  # /path/to/soft-architect-ai/
    str(app_root),  # /path/to/soft-architect-ai/src/server/app
]

for idx, path in enumerate(paths_to_configure):
    if path not in sys.path:
        sys.path.insert(idx, path)

# DEBUG: Comment out for production
# print(f"\n🔍 PYTEST CONFTEST EXECUTED")
# for p in paths_to_configure:
#     print(f"   ✓ {p}")
