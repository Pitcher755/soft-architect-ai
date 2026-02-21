#!/usr/bin/env python3
"""
Sincronización de Espejo Bilingüe
Copia todos los archivos de English/ a Español/ para crear espejo perfecto
"""

import shutil
from pathlib import Path


def sync_bilingual_mirror():
    """Sincroniza English/ -> Español/ para crear espejo perfecto"""

    doc_root = Path("/home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai/doc")
    english_root = doc_root / "English"
    spanish_root = doc_root / "Español"

    copied = 0
    skipped = 0
    errors = 0

    # Iterar todos los archivos .md en English/
    for english_file in english_root.rglob("*.md"):
        # Calcular ruta relativa desde English/
        relative_path = english_file.relative_to(english_root)

        # Ruta correspondiente en Español/
        spanish_file = spanish_root / relative_path

        # Si el archivo NO existe en Español/, copiarlo
        if not spanish_file.exists():
            try:
                # Crear directorio padre si no existe
                spanish_file.parent.mkdir(parents=True, exist_ok=True)

                # Copiar archivo
                shutil.copy2(english_file, spanish_file)

                print(f"✓ Copiado: {relative_path}")
                copied += 1
            except Exception as e:
                print(f"✗ Error copiando {relative_path}: {e}")
                errors += 1
        else:
            skipped += 1

    print("\n📊 Resumen:")
    print(f"   Copiados: {copied} archivos")
    print(f"   Omitidos: {skipped} archivos (ya existían)")
    print(f"   Errores:  {errors}")

    # Verificar espejo
    english_total = len(list(english_root.rglob("*.md")))
    spanish_total = len(list(spanish_root.rglob("*.md")))

    print("\n✅ Verificación Final:")
    print(f"   English/:  {english_total} archivos")
    print(f"   Español/:  {spanish_total} archivos")

    if english_total == spanish_total:
        print("   ✅ ESPEJO PERFECTO - Misma cantidad de archivos")
    else:
        print(f"   ⚠️  Diferencia: {abs(english_total - spanish_total)} archivos")


if __name__ == "__main__":
    print("🔄 Sincronizando Espejo Bilingüe English/ -> Español/")
    print("=" * 60)
    sync_bilingual_mirror()
