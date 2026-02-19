#!/usr/bin/env python3
"""
Organizador de doc/03-HU-TRACKING/

Mueve archivos .md sueltos a sus respectivos subdirectorios HU-*.
Ejemplo: HU-3.3_COMPLETION_REPORT.md → HU-3.3_CHAT_SEQUENTIAL_DOCS/
"""

from pathlib import Path
import shutil
import re


def organize_hu_tracking():
    """Organizar archivos en 03-HU-TRACKING/ moviéndolos a sus subdirectorios HU."""
    doc_root = Path(__file__).parent.parent.resolve()

    for lang_dir in ["English", "Español"]:
        hu_tracking = doc_root / lang_dir / "03-HU-TRACKING"

        if not hu_tracking.exists():
            print(f"⚠️  {lang_dir}/03-HU-TRACKING/ no encontrado")
            continue

        print(f"\n📁 Processing: {lang_dir}/03-HU-TRACKING/")
        print("=" * 70)

        # Obtener todos los subdirectorios HU-*
        hu_dirs = {
            d.name: d
            for d in hu_tracking.iterdir()
            if d.is_dir() and d.name.startswith("HU-")
        }

        print(f"🔍 Subdirectorios HU encontrados: {len(hu_dirs)}")

        # Obtener todos los archivos .md sueltos en el root
        loose_files = [f for f in hu_tracking.glob("*.md") if f.is_file()]

        print(f"📄 Archivos .md sueltos encontrados: {len(loose_files)}")
        print()

        moved = 0
        skipped = 0
        errors = 0

        for file in loose_files:
            # Extraer el prefijo HU del nombre del archivo
            # Ejemplo: HU-3.3_COMPLETION_REPORT.md → HU-3.3
            match = re.match(r"(HU-\d+\.\d+)", file.name)

            if not match:
                print(f"⚠️  No se pudo determinar HU para: {file.name}")
                skipped += 1
                continue

            hu_prefix = match.group(1)

            # Buscar el subdirectorio correspondiente
            target_dir = None
            for dir_name, dir_path in hu_dirs.items():
                if dir_name.startswith(hu_prefix):
                    target_dir = dir_path
                    break

            if not target_dir:
                print(
                    f"⚠️  No se encontró directorio para {file.name} (prefijo: {hu_prefix})"
                )
                skipped += 1
                continue

            # Mover archivo
            try:
                target_file = target_dir / file.name
                if target_file.exists():
                    print(f"⏭️  Ya existe: {file.name} en {target_dir.name}/")
                    skipped += 1
                else:
                    shutil.move(str(file), str(target_file))
                    print(f"✅ Movido: {file.name} → {target_dir.name}/")
                    moved += 1
            except Exception as e:
                print(f"❌ Error moviendo {file.name}: {e}")
                errors += 1

        print()
        print("📊 Resumen:")
        print(f"   Movidos:  {moved} archivos")
        print(f"   Omitidos: {skipped} archivos")
        print(f"   Errores:  {errors}")
        print()

    print("=" * 70)
    print("✅ ORGANIZACIÓN COMPLETADA")
    print("=" * 70)


if __name__ == "__main__":
    organize_hu_tracking()
