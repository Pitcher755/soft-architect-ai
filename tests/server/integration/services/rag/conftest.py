"""Conftest for RAG service integration tests.

Patches the transitive Google SDK / gRPC import chain so the
SequentialOrchestrator module can be imported without hitting
the venv-level cryptography conflict present in the server
environment.

This mirrors the approach used in tests/server/services/rag/conftest.py
and is required here because the integration/ tree does not inherit
from that directory's conftest; pytest only propagates conftest.py
files along the ancestor path of each test file.
"""

import sys
from types import ModuleType
from unittest.mock import MagicMock


def _make_package(name: str) -> ModuleType:
    """Create a stub ModuleType that also acts as a package (has __path__)."""
    mod = ModuleType(name)
    mod.__spec__ = None  # type: ignore[assignment]
    mod.__path__ = []  # marks it as a package so sub-imports work
    mod.__package__ = name
    return mod


def _patch_google_sdk() -> None:
    """Insert minimal stubs for google SDK packages into sys.modules.

    Registration order matters: parent packages must come before children.
    """
    # ── Cryptography ─────────────────────────────────────────────────────────
    for name in [
        "cryptography",
        "cryptography.hazmat",
        "cryptography.hazmat.bindings",
        "cryptography.hazmat.bindings._rust",
        "cryptography.hazmat.primitives",
        "cryptography.x509",
    ]:
        if name not in sys.modules:
            sys.modules[name] = _make_package(name)

    # ── gRPC ──────────────────────────────────────────────────────────────────
    for name in ["grpc", "grpc.experimental"]:
        if name not in sys.modules:
            sys.modules[name] = _make_package(name)

    # ── google namespace ──────────────────────────────────────────────────────
    for name in [
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

    # ── Attribute stubs accessed at import-time ───────────────────────────────
    genai_mod = sys.modules["google.generativeai"]
    genai_mod.GenerativeModel = MagicMock()  # type: ignore[attr-defined]
    genai_mod.configure = MagicMock()  # type: ignore[attr-defined]
    genai_mod.GenerationConfig = MagicMock()  # type: ignore[attr-defined]

    genai_types = sys.modules["google.generativeai.types"]
    genai_types.HarmBlockThreshold = MagicMock()  # type: ignore[attr-defined]
    genai_types.HarmCategory = MagicMock()  # type: ignore[attr-defined]

    api_exc = sys.modules["google.api_core.exceptions"]
    api_exc.GoogleAPIError = Exception  # type: ignore[attr-defined]


# Apply patches before pytest collects any file in this directory.
_patch_google_sdk()
