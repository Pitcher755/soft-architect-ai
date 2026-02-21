#!/usr/bin/env python3
"""
Migración Inteligente de Documentación
Clasifica y copia documentos a estructura bilingüe (Español/English)
"""

import shutil
from pathlib import Path
from dataclasses import dataclass
from typing import Optional


@dataclass
class DocConfig:
    """Configuración para clasificación de documentos"""

    doc_root: Path = Path(
        "/home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai/doc"
    )
    spanish_root: Optional[Path] = None
    english_root: Optional[Path] = None

    def __post_init__(self):
        self.spanish_root = self.doc_root / "Español"
        self.english_root = self.doc_root / "English"


def classify_document(file_path: Path) -> tuple[str, str, str]:
    """
    Clasifica un documento por idioma y categoría
    Retorna: (idioma, categoria_destino, nombre_base)
    # idioma: 'es', 'en', o 'neutral'
    # categoria: '00-VISION', '01-PROJECT_REPORT', etc.
    # nombre_base: nombre del archivo sin sufijo de idioma
    """
    filename = file_path.name

    # Detectar idioma por sufijo
    if filename.endswith(".es.md"):
        idioma = "es"
        nombre_base = filename[:-6]  # Quita .es.md
    elif filename.endswith(".en.md"):
        idioma = "en"
        nombre_base = filename[:-6]  # Quita .en.md
    else:
        idioma = "neutral"
        nombre_base = filename[:-3] if filename.endswith(".md") else filename

    # Detectar si es parte de HU (User Story)
    parent_name = file_path.parent.name
    if parent_name.startswith("HU-"):
        # Es parte de un HU tracking, mantener la estructura
        categoria = f"03-HU-TRACKING/{parent_name}"
    # Clasificar por contenido del nombre de archivo
    elif any(
        x in filename.lower()
        for x in ["vision", "concept", "what_we", "manifesto", "promise"]
    ):
        categoria = "00-VISION"
    elif any(
        x in filename.lower()
        for x in [
            "setup",
            "quick_start",
            "installation",
            "tools",
            "docker",
            "automation",
            "stack",
        ]
    ):
        categoria = "02-SETUP_DEV"
    elif any(x in filename.lower() for x in ["private", "internal", "blueprint"]):
        categoria = "private"
    elif any(
        x in filename.lower()
        for x in ["user_guide", "user-guide", "tutorial", "getting_started"]
    ):
        categoria = "04-USER_GUIDE"
    else:
        # Default: PROJECT_REPORT
        categoria = "01-PROJECT_REPORT"

    return (idioma, categoria, nombre_base)


def get_destination_path(
    config: DocConfig, idioma: str, categoria: str, nombre_base: str
) -> Path:
    """Obtiene la ruta de destino para un documento"""
    if idioma == "es":
        root = config.spanish_root
        extension = ".md"
    elif idioma == "en":
        root = config.english_root
        extension = ".md"
    else:  # neutral
        root = config.english_root  # Default a English
        extension = ".md"

    assert root is not None, "Destination root path must not be None"
    return root / categoria / f"{nombre_base}{extension}"


def migrate_documents(config: DocConfig, dry_run=True):
    """Migra documentos a estructura bilingüe"""

    # Directorios a procesar (incluye raíz para archivos README, etc.)
    dirs_to_process = [
        config.doc_root,  # Raíz primero (para README, INDEX, etc.)
        config.doc_root / "00-VISION",
        config.doc_root / "01-PROJECT_REPORT",
        config.doc_root / "02-SETUP_DEV",
        config.doc_root / "03-HU-TRACKING",
        config.doc_root / "private",
    ]

    migrated = {"es": 0, "en": 0, "neutral": 0}
    skipped = 0

    for src_dir in dirs_to_process:
        if not src_dir.exists():
            continue

        # Para la raíz, solo archivos directos (no recursivo)
        if src_dir == config.doc_root:
            file_iterator = src_dir.glob("*.md")
        else:
            # Para subdirectorios, recursivo
            file_iterator = src_dir.rglob("*.md")

        # Procesar archivos .md
        for file_path in file_iterator:
            # Skip si ya está en Español o English
            if "Español" in str(file_path) or "English" in str(file_path):
                skipped += 1
                continue

            # Skip archivos especiales que deben quedarse en raíz
            if file_path.name in [
                "README.md",
                "INDEX.md",
                "COMPLETION_STATUS.md",
                "REORGANIZATION_STRATEGY.md",
                "migration_script.py",
            ]:
                skipped += 1
                continue

            idioma, categoria, nombre_base = classify_document(file_path)
            dest_path = get_destination_path(config, idioma, categoria, nombre_base)

            # Asegurar que el directorio existe
            dest_path.parent.mkdir(parents=True, exist_ok=True)

            if not dry_run:
                try:
                    shutil.copy2(file_path, dest_path)
                    migrated[idioma] += 1
                    print(f"✓ {idioma:8} → {categoria:30} : {file_path.name}")
                except Exception as e:
                    print(f"✗ Error al copiar {file_path.name}: {e}")
            else:
                print(
                    f"📋 [{idioma}] {categoria:30} : {file_path.name} → {dest_path.name}"
                )
                migrated[idioma] += 1

    print("\n📊 Resumen:")
    print(f"   Español:     {migrated['es']} documentos")
    print(f"   English:     {migrated['en']} documentos")
    print(f"   Neutral:     {migrated['neutral']} documentos")
    print(f"   Omitidos:    {skipped} documentos (ya migrados o especiales)")
    print(f"   Total:       {sum(migrated.values())} documentos migrados")


if __name__ == "__main__":
    config = DocConfig()
    print("🔍 Análisis de Migración (DRY RUN)")
    print("=" * 80)
    migrate_documents(config, dry_run=True)

    print("\n" + "=" * 80)
    print("✅ Para ejecutar la migración real, ejecutar con dry_run=False")
