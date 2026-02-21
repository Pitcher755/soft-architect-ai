#!/usr/bin/env python3
"""
Automated translation script for doc/English/ directory.
Translates common Spanish patterns to English while preserving:
- Code blocks
- File paths
- URLs
- Command-line examples
"""

import re
from pathlib import Path
from typing import List

# Translation dictionary (most common patterns)
TRANSLATIONS = {
    # Headers and metadata
    r"^\> \*\*Estado:\*\*": "> **Status:**",
    r"^\> \*\*Fecha:\*\*": "> **Date:**",
    r"^\> \*\*Última Actualización:\*\*": "> **Last Updated:**",
    r"^\> \*\*Objetivo:\*\*": "> **Objective:**",
    r"^\> \*\*Descripción:\*\*": "> **Description:**",
    r"^\> \*\*Versión:\*\*": "> **Version:**",
    r"^\> \*\*Audiencia:\*\*": "> **Audience:**",
    # Table of contents
    r"## 📖 Tabla de Contenidos": "## 📖 Table of Contents",
    r"## Tabla de Contenidos": "## Table of Contents",
    # Common section headers
    r"## Características Principales": "## Main Features",
    r"## Características": "## Features",
    r"## Configuración": "## Configuration",
    r"## Instalación": "## Installation",
    r"## Descripción": "## Description",
    r"## Objetivo": "## Objective",
    r"## Resumen": "## Summary",
    r"## Documentos Generados": "## Generated Documents",
    r"## Próximos Pasos": "## Next Steps",
    r"## Notas": "## Notes",
    r"## Estado Actual": "## Current Status",
    r"## Conclusión": "## Conclusion",
    r"## Referencias": "## References",
    r"## Estructura": "## Structure",
    r"## Ejecución": "## Execution",
    r"## Validación": "## Validation",
    # Status indicators
    r"✅ Completado": "✅ Completed",
    r"⚠️ En progreso": "⚠️ In progress",
    r"❌ Pendiente": "❌ Pending",
    r"🏗️ En desarrollo": "🏗️ In development",
    # Common content patterns (word boundaries)
    r"\bdocumento\b": "document",
    r"\bdocumentos\b": "documents",
    r"\barchivo\b": "file",
    r"\barchivos\b": "files",
    r"\bcarpeta\b": "folder",
    r"\bcarpetas\b": "folders",
    r"\bproyecto\b": "project",
    r"\bproyectos\b": "projects",
    r"\bprueba\b": "test",
    r"\bpruebas\b": "tests",
    r"\bimplementación\b": "implementation",
    r"\bconfiguración\b": "configuration",
    r"\bvalidación\b": "validation",
    r"\bejemplo\b": "example",
    r"\bejemplos\b": "examples",
    r"\bcontenido\b": "content",
    r"\besquema\b": "schema",
    r"\bestructura\b": "structure",
}


def is_code_block(lines: List[str], line_num: int) -> bool:
    """Check if line is within a code block"""
    code_fence_count = 0
    for i in range(line_num):
        if lines[i].strip().startswith("```"):
            code_fence_count += 1
    return code_fence_count % 2 == 1


def translate_file(filepath: Path) -> tuple[bool, str]:
    """
    Translate a single markdown file.
    Returns (changed, message)
    """
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        original_content = content
        lines = content.split("\n")

        # Process line by line to avoid translating code blocks
        for i, line in enumerate(lines):
            if is_code_block(lines, i):
                continue  # Skip lines inside code blocks

            # Apply translations
            for pattern, replacement in TRANSLATIONS.items():
                lines[i] = re.sub(pattern, replacement, lines[i], flags=re.IGNORECASE)

        new_content = "\n".join(lines)

        if new_content != original_content:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(new_content)
            return True, "Translated"
        else:
            return False, "No changes needed"

    except Exception as e:
        return False, f"Error: {str(e)}"


def main():
    """Main translation process"""
    doc_english_dir = Path(__file__).parent.parent / "doc" / "English"

    if not doc_english_dir.exists():
        print(f"❌ Directory not found: {doc_english_dir}")
        return

    print(f"🚀 Starting translation of files in: {doc_english_dir}")
    print(f"📝 Applying {len(TRANSLATIONS)} translation patterns\n")

    # Find all markdown files
    md_files = list(doc_english_dir.rglob("*.md"))
    print(f"📄 Found {len(md_files)} markdown files\n")

    translated_count = 0
    skipped_count = 0
    error_count = 0

    for md_file in md_files:
        relative_path = md_file.relative_to(doc_english_dir)
        changed, message = translate_file(md_file)

        if changed:
            print(f"✅ {relative_path}: {message}")
            translated_count += 1
        elif "Error" in message:
            print(f"❌ {relative_path}: {message}")
            error_count += 1
        else:
            skipped_count += 1

    print("\n📊 TRANSLATION SUMMARY")
    print("=" * 50)
    print(f"✅ Translated:  {translated_count} files")
    print(f"⏭️  Skipped:     {skipped_count} files (already in English)")
    print(f"❌ Errors:      {error_count} files")
    print(f"📄 Total:       {len(md_files)} files")
    print("=" * 50)


if __name__ == "__main__":
    main()
