#!/usr/bin/env python3
"""
Script de Organización de doc/[English|Español]/01-PROJECT_REPORT/
=====================================================================

Clasifica y organiza 246 archivos .md en categorías lógicas.
Mantiene sincronización perfecta entre directorios English/ y Español/.

Autor: ArchitectZero
Fecha: 2026-02-19
"""

import shutil
import re
from pathlib import Path
from typing import Dict, List
from collections import defaultdict


# ============================================================================
# CONFIGURACIÓN DE CATEGORÍAS
# ============================================================================

CATEGORIES = {
    "01-ARCHITECTURE": {
        "description": "Architecture Decision Records (ADRs), Diagrams, Design",
        "patterns": [
            r"^ADR[-_]",
            r"ARCHITECTURE",
            r"DESIGN",
            r"MONOREPO",
            r"CLEAN_ARCHITECTURE",
            r"HEXAGONAL",
            r"I18N_ARCHITECTURE",
        ],
    },
    "02-PHASES": {
        "description": "Project Phase Reports (Phase 0-6, Fase 1-9)",
        "patterns": [
            r"^PHASE[-_]?\d",
            r"^FASE[-_]?\d",
            r"SPRINT\d+",
            r"INITIATION",
        ],
    },
    "03-TESTING": {
        "description": "Test Reports, Coverage, Execution, E2E, Unit Tests",
        "patterns": [
            r"TEST(?!ING_GUIDE)",  # TEST pero no TESTING_GUIDE
            r"COVERAGE",
            r"E2E",
            r"TDD",
            r"PYTEST",
            r"FLUTTER_TEST",
            r"TESTING_PYRAMID",
            r"TESTING_EXECUTION",
            r"TESTING_MANUAL",
            r"TESTING_BEST",
        ],
    },
    "04-CI-CD": {
        "description": "CI/CD Pipelines, GitHub Actions, Automation",
        "patterns": [
            r"CI_CD",
            r"GITHUB_ACTIONS",
            r"PIPELINE",
            r"PRE_PUSH",
            r"AUTOMATION",
            r"SCRIPTS_VALIDATION",
        ],
    },
    "05-COMPLETION-STATUS": {
        "description": "Completion Reports, Status, Progress, Dashboards",
        "patterns": [
            r"COMPLETION(?!_REPORT\.md$)",  # COMPLETION pero no el genérico
            r"STATUS",
            r"PROGRESS",
            r"DASHBOARD",
            r"EXECUTIVE_SUMMARY",
            r"FINAL_SUMMARY",
            r"SESSION_SUMMARY",
        ],
    },
    "06-VALIDATION": {
        "description": "Validation, Verification, Quality Gates, Audits",
        "patterns": [
            r"VALIDATION",
            r"VERIFICATION",
            r"QUALITY_GATES",
            r"AUDIT",
            r"CHECKLIST",
            r"ACCEPTANCE_CRITERIA",
        ],
    },
    "07-WORKFLOWS": {
        "description": "Workflow Definitions, Master Workflow, Flow Guides",
        "patterns": [
            r"WORKFLOW",
            r"MASTER_WORKFLOW",
            r"FLOW",
        ],
    },
    "08-FIXES-CORRECTIONS": {
        "description": "Bug Fixes, Corrections, Hotfixes, Error Handling",
        "patterns": [
            r"FIX(?:ES)?",
            r"CORRECTION",
            r"HOTFIX",
            r"ERROR_HANDLING",
            r"EXCEPTION",
            r"BUGS",
            r"CORRECION",  # Español typo común
        ],
    },
    "09-GUIDES-MANUALS": {
        "description": "User Guides, Manuals, Quick References, How-Tos",
        "patterns": [
            r"GUIDE(?!LINES)",
            r"MANUAL",
            r"QUICK_REFERENCE",
            r"QUICKSTART",
            r"HOW_TO",
            r"TUTORIAL",
            r"START_HERE",
        ],
    },
    "10-DOCUMENTATION": {
        "description": "General Documentation, Indices, Metadata, Organization",
        "patterns": [
            r"^README\.md$",
            r"^INDEX\.md$",
            r"DOCUMENTATION",
            r"MEMORIA",
            r"REORGANIZATION",
            r"INVENTORY",
            r"MANIFEST",
            r"^ARTIFACTS\.md$",
        ],
    },
}

# Archivos especiales que van a la raíz (no se mueven)
ROOT_FILES = ["README.md", "INDEX.md"]


# ============================================================================
# FUNCIONES DE CLASIFICACIÓN
# ============================================================================


def classify_file(filename: str) -> str:
    """
    Clasifica un archivo en una categoría basándose en patrones regex.

    Args:
        filename: Nombre del archivo a clasificar

    Returns:
        ID de la categoría (ej: "01-ARCHITECTURE")
    """
    # Archivos especiales
    if filename in ROOT_FILES:
        return "ROOT"

    # Buscar coincidencia en patrones
    for category_id, config in CATEGORIES.items():
        for pattern in config["patterns"]:
            if re.search(pattern, filename, re.IGNORECASE):
                return category_id

    # Si no coincide con nada, va a "10-DOCUMENTATION" por defecto
    return "10-DOCUMENTATION"


def analyze_directory(base_path: Path) -> Dict[str, List[str]]:
    """
    Analiza el directorio y clasifica todos los archivos .md

    Args:
        base_path: Ruta al directorio 01-PROJECT_REPORT/

    Returns:
        Diccionario {category_id: [lista de archivos]}
    """
    classification = defaultdict(list)

    if not base_path.exists():
        return classification

    for file in sorted(base_path.glob("*.md")):
        category = classify_file(file.name)
        classification[category].append(file.name)

    return dict(classification)


# ============================================================================
# FUNCIONES DE ORGANIZACIÓN
# ============================================================================


def create_category_directories(base_path: Path) -> None:
    """Crea los subdirectorios de categorías"""
    for category_id in CATEGORIES.keys():
        category_path = base_path / category_id
        category_path.mkdir(exist_ok=True)
        print(f"  ✅ Created: {category_path.relative_to(base_path.parent)}")


def move_files(
    base_path: Path, classification: Dict[str, List[str]], dry_run: bool = False
) -> int:
    """
    Mueve archivos a sus categorías correspondientes

    Args:
        base_path: Ruta al directorio 01-PROJECT_REPORT/
        classification: Diccionario con la clasificación
        dry_run: Si True, solo simula (no mueve archivos)

    Returns:
        Número de archivos movidos
    """
    moved_count = 0

    for category_id, files in classification.items():
        if category_id == "ROOT":
            continue  # No mover archivos raíz

        target_dir = base_path / category_id

        for filename in files:
            source = base_path / filename
            destination = target_dir / filename

            if not source.exists():
                continue

            if dry_run:
                print(f"  [DRY-RUN] {filename} → {category_id}/")
            else:
                shutil.move(str(source), str(destination))
                moved_count += 1
                print(f"  ✅ Moved: {filename} → {category_id}/")

    return moved_count


def generate_readme(
    base_path: Path, classification: Dict[str, List[str]], language: str = "en"
) -> None:
    """
    Genera un README.md navegable con índice de todas las categorías

    Args:
        base_path: Ruta al directorio 01-PROJECT_REPORT/
        classification: Diccionario con la clasificación
        language: 'en' o 'es' para bilingüismo
    """
    readme_path = base_path / "README.md"

    # Textos bilingües
    texts = {
        "en": {
            "title": "📊 01-PROJECT_REPORT",
            "subtitle": "Comprehensive Project Reports & Documentation",
            "toc_title": "📋 Table of Contents",
            "summary_title": "📈 Summary",
            "categories_title": "📂 Categories",
            "total_files": "Total Files",
            "organized_in": "Organized in",
            "categories": "categories",
            "files": "files",
            "description": "Description",
        },
        "es": {
            "title": "📊 01-PROJECT_REPORT",
            "subtitle": "Reportes Completos de Proyecto y Documentación",
            "toc_title": "📋 Tabla de Contenidos",
            "summary_title": "📈 Resumen",
            "categories_title": "📂 Categorías",
            "total_files": "Total de Archivos",
            "organized_in": "Organizados en",
            "categories": "categorías",
            "files": "archivos",
            "description": "Descripción",
        },
    }

    t = texts[language]

    # Contar archivos totales (excluir ROOT)
    total_files = sum(
        len(files) for cat, files in classification.items() if cat != "ROOT"
    )
    total_categories = len([cat for cat in classification.keys() if cat != "ROOT"])

    content = f"""# {t['title']}

> **{t['subtitle']}**
> **Generated:** {Path(__file__).name} (2026-02-19)

---

## {t['toc_title']}

- [📈 {t['summary_title']}](#{t['summary_title'].lower().replace(' ', '-')})
- [📂 {t['categories_title']}](#{t['categories_title'].lower().replace(' ', '-')})
"""

    # Agregar links a cada categoría en TOC
    for category_id in sorted(CATEGORIES.keys()):
        category_name = category_id.replace("-", " ").title()
        anchor = category_id.lower()
        content += f"  - [{category_name}](#{anchor})\n"

    # Summary
    content += f"""
---

## {t['summary_title']}

**{t['total_files']}:** {total_files} {t['files']}
**{t['organized_in']}:** {total_categories} {t['categories']}

---

## {t['categories_title']}

"""

    # Listar cada categoría con sus archivos
    for category_id in sorted(CATEGORIES.keys()):
        if category_id not in classification or not classification[category_id]:
            continue

        config = CATEGORIES[category_id]
        files = sorted(classification[category_id])

        content += f"### {category_id.replace('-', ' ')}\n\n"
        content += f"**{t['description']}:** {config['description']}  \n"
        content += f"**{t['files'].capitalize()}:** {len(files)}\n\n"

        # Listar archivos con links relativos
        for filename in files:
            file_path = f"{category_id}/{filename}"
            # Nombre sin extensión para display
            display_name = filename.replace(".md", "").replace("_", " ")
            content += f"- [{display_name}]({file_path})\n"

        content += "\n"

    # Footer
    content += """---

> **Note:** This structure mirrors `doc/English/01-PROJECT_REPORT/` and `doc/Español/01-PROJECT_REPORT/` for bilingual support.
"""

    # Escribir archivo
    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"  ✅ Generated: {readme_path.relative_to(base_path.parent)}")


# ============================================================================
# FUNCIÓN PRINCIPAL
# ============================================================================


def main():
    """Función principal del script"""
    # Detectar raíz del proyecto
    script_dir = Path(__file__).parent
    project_root = script_dir.parent.parent

    # Directorios a procesar
    directories = [
        project_root / "doc" / "English" / "01-PROJECT_REPORT",
        project_root / "doc" / "Español" / "01-PROJECT_REPORT",
    ]

    print("\n" + "=" * 80)
    print("🗂️  ORGANIZADOR DE doc/01-PROJECT_REPORT/")
    print("=" * 80 + "\n")

    # Procesar cada directorio
    for base_path in directories:
        language = "en" if "English" in str(base_path) else "es"
        lang_display = "English" if language == "en" else "Español"

        print(f"\n📁 Processing: {base_path.relative_to(project_root)}")
        print("-" * 80)

        if not base_path.exists():
            print("  ⚠️  Directory not found, skipping...")
            continue

        # 1. Analizar y clasificar
        print("\n🔍 Step 1: Analyzing files...")
        classification = analyze_directory(base_path)

        # Mostrar estadísticas
        total_files = sum(
            len(files) for cat, files in classification.items() if cat != "ROOT"
        )
        print(f"  📊 Found {total_files} files to organize")

        # 2. Crear directorios
        print("\n🛠️  Step 2: Creating category directories...")
        create_category_directories(base_path)

        # 3. Mover archivos
        print("\n📦 Step 3: Moving files...")
        moved = move_files(base_path, classification, dry_run=False)
        print(f"  ✅ Moved {moved} files")

        # 4. Generar README
        print("\n📝 Step 4: Generating README.md...")
        generate_readme(base_path, classification, language=language)

        print(f"\n✅ {lang_display} directory organized successfully!\n")

    print("=" * 80)
    print("✅ ORGANIZATION COMPLETE!")
    print("=" * 80 + "\n")

    # Mostrar resumen final
    print("\n📊 CLASSIFICATION SUMMARY:")
    print("-" * 80)

    # Usar la clasificación del directorio English como referencia
    ref_path = project_root / "doc" / "English" / "01-PROJECT_REPORT"
    classification = analyze_directory(ref_path)

    for category_id in sorted(CATEGORIES.keys()):
        if category_id in classification:
            count = len(classification[category_id])
            desc = CATEGORIES[category_id]["description"]
            print(f"{category_id:<25} {count:>3} files - {desc}")

    if "ROOT" in classification:
        print(
            f"{'ROOT (not moved)':<25} {len(classification['ROOT']):>3} files - Special files"
        )

    total = sum(len(files) for cat, files in classification.items())
    print("-" * 80)
    print(f"{'TOTAL':<25} {total:>3} files\n")


# ============================================================================
# EJECUCIÓN
# ============================================================================

if __name__ == "__main__":
    main()
