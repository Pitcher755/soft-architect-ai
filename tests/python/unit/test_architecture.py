"""
Architecture validation tests.
Ensures the project structure follows PROJECT_STRUCTURE_MAP.md exactly.

Reference: context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md
"""

from pathlib import Path


def test_folder_structure_exists():
    """
    Validates that Clean Architecture folder structure exists physically.

    This test MUST FAIL initially (RED phase), then pass after scaffolding.

    Based on: context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.md
    """
    base_path = Path(__file__).resolve().parent.parent

    required_dirs = [
        "core",  # Config, Security, Events
        "api/v1/endpoints",  # API Routers
        "domain/models",  # Business Entities
        "domain/schemas",  # Pydantic DTOs
        "services/rag",  # RAG/LangChain Logic
        "services/vectors",  # ChromaDB Logic
        "utils",  # Generic Helpers
        "tests",  # Test Suite
    ]

    missing = []
    for directory in required_dirs:
        full_path = base_path / directory
        if not full_path.exists():
            missing.append(directory)

    assert not missing, (
        f"❌ Missing required architecture directories: {missing}\n"
        f"Please create them according to PROJECT_STRUCTURE_MAP.md"
    )


def test_init_files_exist():
    """
    Validates that all packages have __init__.py files.

    This makes directories proper Python packages.
    """
    base_path = Path(__file__).resolve().parent.parent

    package_dirs = [
        "core",
        "api",
        "api/v1",
        "api/v1/endpoints",
        "domain",
        "domain/models",
        "domain/schemas",
        "services",
        "services/rag",
        "services/vectors",
        "utils",
    ]

    missing_inits = []
    for directory in package_dirs:
        init_file = base_path / directory / "__init__.py"
        if not init_file.exists():
            missing_inits.append(f"{directory}/__init__.py")

    assert not missing_inits, (
        f"❌ Missing __init__.py files: {missing_inits}\n"
        f"Run: find . -type d -exec touch {{}}/__init__.py \\;"
    )
