"""
Pytest Configuration for SoftArchitect AI Tests

This conftest configures the Python path to ensure all tests
can properly import from the application modules.
"""

import sys
from pathlib import Path

# Add the src/server directory to the Python path
# so that imports like `from services...` work correctly
server_root = Path(__file__).parent.parent
print(f"DEBUG: Adding to sys.path: {server_root}")
sys.path.insert(0, str(server_root))
print(f"DEBUG: sys.path now: {sys.path[:3]}")
