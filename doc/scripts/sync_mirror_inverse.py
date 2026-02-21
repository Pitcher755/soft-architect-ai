#!/usr/bin/env python3
"""
Sincronización inversa: Copiar archivos de Español/ a English/ que NO existen.

Este script complementa sync_mirror_bilingual.py copiando archivos que
existen en Español/ pero NO en English/.
"""

from pathlib import Path
import shutil


def sync_inverse_mirror():
    """Copiar archivos de Español/ a English/ si no existen."""
    doc_root = Path(__file__).parent.resolve()
    spanish_root = doc_root / "Español"
    english_root = doc_root / "English"

    print("🔄 Sincronización Inversa Español/ -> English/")
    print("=" * 60)

    copied = 0
    skipped = 0
    errors = 0

    # Iterar todos los archivos .md en Español/
    for spanish_file in spanish_root.rglob("*.md"):
        # Calcular ruta relativa
        relative_path = spanish_file.relative_to(spanish_root)
        english_file = english_root / relative_path

        # Si el archivo NO existe en English/, copiarlo
        if not english_file.exists():
            try:
                # Crear directorio padre si no existe
                english_file.parent.mkdir(parents=True, exist_ok=True)

                # Copiar archivo
                shutil.copy2(spanish_file, english_file)
                print(f"✓ Copiado: {relative_path}")
                copied += 1
            except Exception as e:
                print(f"❌ Error copiando {relative_path}: {e}")
                errors += 1
        else:
            skipped += 1

    print()
    print("📊 Resumen:")
    print(f"   Copiados: {copied} archivos")
    print(f"   Omitidos: {skipped} archivos (ya existían)")
    print(f"   Errores:  {errors}")
    print()

    # Verificación final
    english_total = len(list(english_root.rglob("*.md")))
    spanish_total = len(list(spanish_root.rglob("*.md")))

    print("✅ Verificación Final:")
    print(f"   English/:  {english_total} archivos")
    print(f"   Español/:  {spanish_total} archivos")

    if english_total == spanish_total:
        print("   ✅ ESPEJO PERFECTO - Misma cantidad de archivos")
    else:
        diff = abs(english_total - spanish_total)
        print(f"   ⚠️  Diferencia: {diff} archivos")


if __name__ == "__main__":
    sync_inverse_mirror()
