"""
Unit-test-level sys.path fixup.

The root conftest.py (tests/server/conftest.py) adds src/server via the venv
activation, but since the path is already present in sys.path (from venv) the
`if path not in sys.path` guard skips the insertion at index 0.

That means src/server/app ends up BEFORE src/server in the search order,
so `import core` resolves to src/server/app/core/ (which contains exceptions.py
as a *file*) instead of src/server/core/ (which contains exceptions/ as a
*package*).

This conftest guarantees src/server is at position 0 prior to any test
collection in this directory tree.
"""

import sys
from pathlib import Path

# Absolute path to src/server (three levels up from this file)
# File: tests/server/unit/conftest.py
# Root: soft-architect-ai/
_SERVER_ROOT = str(Path(__file__).parent.parent.parent.parent / "src" / "server")

# Ensure it is the FIRST entry regardless of what venv activation put in place
if _SERVER_ROOT in sys.path:
    sys.path.remove(_SERVER_ROOT)
sys.path.insert(0, _SERVER_ROOT)
