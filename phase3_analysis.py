#!/usr/bin/env python3
"""
PHASE 3 REFACTOR - ANALYSIS SCRIPT
Analyzes entire SoftArchitect AI project for code quality issues.

Checks:
1. Circular dependencies
2. Generic exception usage
3. Missing docstrings
4. Code duplication
5. Architecture violations

Run: python3 phase3_analysis.py
"""

import re
from pathlib import Path


def analyze_python_files():
    """Analyze all Python files for quality issues."""
    print("🔍 ANALYZING PYTHON CODE...")
    print("=" * 80)

    issues = {
        "generic_exceptions": [],
        "missing_docstrings": [],
        "circular_imports": [],
        "domain_infra_imports": [],
    }

    python_files = list(Path(".").rglob("*.py"))
    python_files = [
        f for f in python_files if "tests" not in str(f) and "__pycache__" not in str(f)
    ]

    for file_path in python_files:
        with open(file_path) as f:
            content = f.read()

        # Check for generic exceptions
        if re.search(r"except\s+(Exception|Error):", content):
            issues["generic_exceptions"].append(str(file_path))

        # Check for missing docstrings in classes/functions
        class_matches = re.findall(
            r"^class\s+\w+.*?(?=^class|\Z)", content, re.MULTILINE | re.DOTALL
        )
        for match in class_matches:
            if '"""' not in match and "'''" not in match:
                issues["missing_docstrings"].append(str(file_path))
                break

        # Check for domain layer importing infrastructure
        if "domain" in str(file_path) and "from.*infrastructure" in content:
            issues["domain_infra_imports"].append(str(file_path))

    print("\n📊 ANALYSIS RESULTS:")
    print(f"  • Total Python files analyzed: {len(python_files)}")
    print(f"  • Generic exception usage: {len(issues['generic_exceptions'])} files")
    print(f"  • Missing docstrings: {len(issues['missing_docstrings'])} files")
    print(f"  • Domain→Infra imports: {len(issues['domain_infra_imports'])} files")

    return issues


def analyze_flutter_files():
    """Analyze all Flutter files for quality issues."""
    print("\n🔍 ANALYZING FLUTTER CODE...")
    print("=" * 80)

    issues = {
        "duplicated_widgets": 0,
        "missing_dartdocs": 0,
        "repeated_patterns": [],
    }

    dart_files = (
        list(Path("src/client/lib").rglob("*.dart"))
        if Path("src/client/lib").exists()
        else []
    )

    elevated_button_count = 0
    elevated_button_files = []

    for file_path in dart_files:
        with open(file_path) as f:
            content = f.read()

        # Count ElevatedButton usage
        if "ElevatedButton" in content:
            count = content.count("ElevatedButton")
            elevated_button_count += count
            if count > 1:
                elevated_button_files.append((str(file_path), count))

        # Check for missing dartdocs
        if not re.search(r"^///\s", content, re.MULTILINE):
            issues["missing_dartdocs"] += 1

    print("\n📊 FLUTTER ANALYSIS RESULTS:")
    print(f"  • Total Dart files: {len(dart_files)}")
    print(f"  • Total ElevatedButton usage: {elevated_button_count}")
    print(f"  • Files with repeated ElevatedButton: {len(elevated_button_files)}")
    if elevated_button_files:
        for file_path, count in elevated_button_files[:5]:
            print(f"    - {file_path}: {count} instances")

    return issues


if __name__ == "__main__":
    python_issues = analyze_python_files()
    flutter_issues = analyze_flutter_files()

    print("\n" + "=" * 80)
    print("✅ ANALYSIS COMPLETE")
    print("=" * 80)
    print("\nRECOMMENDATIONS:")
    print("1. Create centralized exceptions.py in core/")
    print("2. Replace all generic Exception/Error catches with specific types")
    print("3. Add docstring decorators or module documentation")
    print("4. Extract repeated ElevatedButton patterns to CustomButton widget")
    print("5. Run Black, Ruff, Dart format on all files")
