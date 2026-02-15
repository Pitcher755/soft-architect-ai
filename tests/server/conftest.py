"""
Pytest Configuration for SoftArchitect AI Tests (Centralized)

This conftest configures the Python path to ensure all tests
can properly import from the application modules.

CRITICAL: This file is loaded FIRST by pytest before any test collection.
"""

import json
import sys
from pathlib import Path
from typing import AsyncGenerator

import pytest

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


# ========================================================================
# HU-4.3: SSE STREAMING FIXTURES
# ========================================================================


@pytest.fixture
def mock_ollama_stream():
    """
    Mock Ollama NDJSON stream response for testing.

    Returns a factory function that creates async generator simulating
    Ollama's streaming API response format.

    Example:
        >>> async for line in mock_ollama_stream()():
        ...     data = json.loads(line)
        ...     print(data["response"])
    """

    async def _stream() -> AsyncGenerator[str, None]:
        """Generate mock NDJSON lines mimicking Ollama stream format."""
        tokens = ["Hello", " world", "!"]
        for token in tokens:
            yield json.dumps({"response": token, "done": False})
        # Final event with metadata
        yield json.dumps(
            {
                "response": "",
                "done": True,
                "total_duration": 1000000,
                "load_duration": 500000,
                "prompt_eval_count": 10,
                "eval_count": 3,
            }
        )

    return _stream


@pytest.fixture
def sse_test_client(test_client):
    """
    HTTP client configured for SSE streaming tests.

    FastAPI's TestClient automatically handles streaming responses,
    so we can use it directly for SSE endpoint tests.

    Args:
        test_client: Base FastAPI TestClient fixture (must be defined elsewhere).

    Returns:
        TestClient instance ready for SSE requests.

    Note:
        This fixture requires a `test_client` fixture to be defined
        (typically in a conftest.py closer to the FastAPI app instance).
    """
    return test_client
