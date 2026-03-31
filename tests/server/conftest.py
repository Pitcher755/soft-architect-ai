"""
Pytest Configuration for SoftArchitect AI Tests (Centralized)

This conftest configures the Python path to ensure all tests
can properly import from the application modules.

CRITICAL: This file is loaded FIRST by pytest before any test collection.
It also patches the broken cryptography/Google SDK import chain to prevent
ImportError during collection of test modules that import app-level code.
"""

import sys
from pathlib import Path
from types import ModuleType
from unittest.mock import MagicMock


# ========================================================================
# GOOGLE SDK / CRYPTOGRAPHY PATCH (must run before ANY app import)
# ========================================================================


def _make_package(name: str) -> ModuleType:
    """Create a stub ModuleType that also acts as a package (has __path__)."""
    mod = ModuleType(name)
    mod.__spec__ = None  # type: ignore[assignment]
    mod.__path__ = []  # marks it as a package so sub-imports work
    mod.__package__ = name
    return mod


def _patch_google_sdk() -> None:
    """Insert minimal stubs for google SDK packages into sys.modules.

    Prevents the venv-level cryptography version conflict from crashing
    test collection.  Registration order matters: parents before children.
    """
    for name in [
        # Cryptography
        "cryptography",
        "cryptography.hazmat",
        "cryptography.hazmat.bindings",
        "cryptography.hazmat.bindings._rust",
        "cryptography.hazmat.primitives",
        "cryptography.x509",
        # gRPC (needed by chromadb → opentelemetry)
        "grpc",
        "grpc.experimental",
        # OpenTelemetry (cuts the chromadb telemetry import chain)
        "opentelemetry",
        "opentelemetry.exporter",
        "opentelemetry.exporter.otlp",
        "opentelemetry.exporter.otlp.proto",
        "opentelemetry.exporter.otlp.proto.grpc",
        "opentelemetry.exporter.otlp.proto.grpc.trace_exporter",
        "opentelemetry.exporter.otlp.proto.grpc.exporter",
        "opentelemetry.sdk",
        "opentelemetry.sdk.trace",
        "opentelemetry.sdk.trace.export",
        "opentelemetry.sdk.resources",
        "opentelemetry.trace",
        "opentelemetry.trace.status",
        "opentelemetry.context",
        # Google namespace
        "google",
        "google.auth",
        "google.auth.transport",
        "google.auth.transport.grpc",
        "google.auth.crypt",
        "google.api_core",
        "google.api_core.exceptions",
        "google.api_core.gapic_v1",
        "google.api_core.gapic_v1.method",
        "google.api_core.retry",
        "google.generativeai",
        "google.generativeai.types",
        "google.ai",
        "google.ai.generativelanguage_v1beta",
    ]:
        if name not in sys.modules:
            sys.modules[name] = _make_package(name)

    # gRPC attributes required by opentelemetry (via chromadb)
    grpc_mod = sys.modules["grpc"]
    for attr in [
        "ChannelCredentials",
        "Compression",
        "Channel",
        "insecure_channel",
        "secure_channel",
        "ssl_channel_credentials",
        "RpcError",
        "StatusCode",
    ]:
        if not hasattr(grpc_mod, attr):
            setattr(grpc_mod, attr, MagicMock())
    if not hasattr(grpc_mod, "__version__"):
        grpc_mod.__version__ = "1.0.0"  # type: ignore[attr-defined]

    # opentelemetry.trace attribute stubs
    trace_mod = sys.modules["opentelemetry.trace"]
    for attr in ["get_tracer", "Tracer", "Span", "SpanKind", "StatusCode"]:
        if not hasattr(trace_mod, attr):
            setattr(trace_mod, attr, MagicMock())

    # opentelemetry.sdk.resources stubs (chromadb telemetry)
    sdk_resources = sys.modules["opentelemetry.sdk.resources"]
    for attr in ["SERVICE_NAME", "Resource"]:
        if not hasattr(sdk_resources, attr):
            setattr(sdk_resources, attr, MagicMock())

    # opentelemetry.sdk.trace stubs (chromadb telemetry)
    sdk_trace = sys.modules["opentelemetry.sdk.trace"]
    if not hasattr(sdk_trace, "TracerProvider"):
        sdk_trace.TracerProvider = MagicMock()  # type: ignore[attr-defined]

    # opentelemetry.sdk.trace.export stubs (chromadb telemetry)
    sdk_trace_export = sys.modules["opentelemetry.sdk.trace.export"]
    if not hasattr(sdk_trace_export, "BatchSpanProcessor"):
        sdk_trace_export.BatchSpanProcessor = MagicMock()  # type: ignore[attr-defined]

    # opentelemetry.exporter.otlp.proto.grpc.trace_exporter stubs
    otlp_trace = sys.modules["opentelemetry.exporter.otlp.proto.grpc.trace_exporter"]
    if not hasattr(otlp_trace, "OTLPSpanExporter"):
        otlp_trace.OTLPSpanExporter = MagicMock()  # type: ignore[attr-defined]

    # Attribute stubs accessed at import-time
    genai_mod = sys.modules["google.generativeai"]
    genai_mod.GenerativeModel = MagicMock()  # type: ignore[attr-defined]
    genai_mod.configure = MagicMock()  # type: ignore[attr-defined]
    genai_mod.GenerationConfig = MagicMock()  # type: ignore[attr-defined]

    genai_types = sys.modules["google.generativeai.types"]
    genai_types.HarmBlockThreshold = MagicMock()  # type: ignore[attr-defined]
    genai_types.HarmCategory = MagicMock()  # type: ignore[attr-defined]

    api_exc = sys.modules["google.api_core.exceptions"]
    api_exc.GoogleAPIError = Exception  # type: ignore[attr-defined]


_patch_google_sdk()


# ========================================================================
# Standard imports (safe after SDK patch)
# ========================================================================
import json  # noqa: E402
from typing import AsyncGenerator  # noqa: E402

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402

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
# FASTAPI TEST CLIENT FIXTURE (for smoke tests)
# ========================================================================


@pytest.fixture
def client():
    """
    FastAPI TestClient fixture for smoke tests.

    Provides a test client for making HTTP requests to the API.
    Used primarily by smoke tests that verify API endpoints.

    Returns:
        TestClient: Configured FastAPI test client instance.
    """
    from app.main import app

    with TestClient(app) as test_client:
        yield test_client


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
