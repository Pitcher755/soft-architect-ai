"""Conftest for RAG service unit tests.

Patches broken transitive import chain at collection time via sys.modules so
the module under test (sequential_orchestrator) can be imported without
triggering the cloud-SDK dependency chain that has a venv conflict:

  app.services.rag.__init__
    → orchestrator.py
      → app.infrastructure.llm.factory
        → GeminiClient
          → google.generativeai        ← cryptography version conflict
          → google.api_core.exceptions ← same conflict
          → google.generativeai.types  ← downstream

All stub modules are registered BEFORE pytest collects any test file,
because conftest.py in the same directory is loaded first.
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

    Order matters: parent packages must be registered before children.
    """
    # ── Cryptography ────────────────────────────────────────────────────────
    crypto_stubs = [
        "cryptography",
        "cryptography.hazmat",
        "cryptography.hazmat.bindings",
        "cryptography.hazmat.bindings._rust",
        "cryptography.hazmat.primitives",
        "cryptography.x509",
    ]
    for name in crypto_stubs:
        if name not in sys.modules:
            sys.modules[name] = _make_package(name)

    # ── gRPC ────────────────────────────────────────────────────────────────
    grpc_stubs = ["grpc", "grpc.experimental"]
    for name in grpc_stubs:
        if name not in sys.modules:
            sys.modules[name] = _make_package(name)

    # ── google namespace ─────────────────────────────────────────────────────
    google_stubs = [
        "google",
        # google.auth
        "google.auth",
        "google.auth.transport",
        "google.auth.transport.grpc",
        "google.auth.crypt",
        # google.api_core  ← needs sub-packages
        "google.api_core",
        "google.api_core.exceptions",
        "google.api_core.gapic_v1",
        "google.api_core.gapic_v1.method",
        "google.api_core.retry",
        # google.generativeai
        "google.generativeai",
        "google.generativeai.types",
        # google.ai
        "google.ai",
        "google.ai.generativelanguage_v1beta",
    ]
    for name in google_stubs:
        if name not in sys.modules:
            sys.modules[name] = _make_package(name)

    # ── Attribute stubs accessed at import-time ──────────────────────────────
    genai_mod = sys.modules["google.generativeai"]
    genai_mod.GenerativeModel = MagicMock()  # type: ignore[attr-defined]
    genai_mod.configure = MagicMock()  # type: ignore[attr-defined]
    genai_mod.GenerationConfig = MagicMock()  # type: ignore[attr-defined]

    genai_types = sys.modules["google.generativeai.types"]
    genai_types.HarmBlockThreshold = MagicMock()  # type: ignore[attr-defined]
    genai_types.HarmCategory = MagicMock()  # type: ignore[attr-defined]

    api_exc = sys.modules["google.api_core.exceptions"]
    api_exc.GoogleAPIError = Exception  # type: ignore[attr-defined]


# ── Apply patches before pytest collects any test file ──────────────────────
_patch_google_sdk()
