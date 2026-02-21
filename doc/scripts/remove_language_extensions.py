#!/usr/bin/env python3
"""
Limpieza de extensiones de idioma duplicadas (.en.md, .es.md)

Con la estructura English/ y Español/, las extensiones de idioma son redundantes.
Este script:
1. En English/: elimina archivos .es.md (idioma incorrecto)
2. En Español/: elimina archivos .en.md (idioma incorrecto)
3. Consolida duplicados: si existen .en.md/.es.md y .md, mantiene solo .md
"""

from pathlib import Path


def clean_language_extensions():
    """Limpiar extensiones de idioma redundantes."""
    doc_root = Path(__file__).parent.parent.resolve()

    stats = {
        "English": {"removed_es": 0, "removed_en": 0, "consolidated": 0},
        "Español": {"removed_es": 0, "removed_en": 0, "consolidated": 0},
    }

    for lang_dir_name in ["English", "Español"]:
        lang_dir = doc_root / lang_dir_name

        if not lang_dir.exists():
            continue

        print(f"\n📁 Procesando: {lang_dir_name}/")
        print("=" * 70)

        # Encontrar todos los archivos .en.md y .es.md
        en_files = list(lang_dir.rglob("*.en.md"))
        es_files = list(lang_dir.rglob("*.es.md"))

        print("🔍 Encontrados:")
        print(f"   - {len(en_files)} archivos .en.md")
        print(f"   - {len(es_files)} archivos .es.md")
        print()

        # Procesar archivos .en.md
        if lang_dir_name == "English":
            # En English/, .en.md puede quedarse o consolidarse con .md
            for en_file in en_files:
                base_name = en_file.stem  # Ej: "CONCEPT_WHITE_PAPER"
                md_file = en_file.parent / f"{base_name}.md"

                if md_file.exists():
                    # Ya existe .md, eliminar .en.md (duplicado)
                    print(f"🗑️  Eliminando duplicado: {en_file.relative_to(lang_dir)}")
                    en_file.unlink()
                    stats["English"]["consolidated"] += 1
                else:
                    # No existe .md, renombrar .en.md → .md
                    print(f"♻️  Consolidando: {en_file.name} → {md_file.name}")
                    en_file.rename(md_file)
                    stats["English"]["consolidated"] += 1

        elif lang_dir_name == "Español":
            # En Español/, .en.md NO debería estar (idioma incorrecto)
            for en_file in en_files:
                print(
                    f"❌ Eliminando (idioma incorrecto): {en_file.relative_to(lang_dir)}"
                )
                en_file.unlink()
                stats["Español"]["removed_en"] += 1

        # Procesar archivos .es.md
        if lang_dir_name == "English":
            # En English/, .es.md NO debería estar (idioma incorrecto)
            for es_file in es_files:
                print(
                    f"❌ Eliminando (idioma incorrecto): {es_file.relative_to(lang_dir)}"
                )
                es_file.unlink()
                stats["English"]["removed_es"] += 1

        elif lang_dir_name == "Español":
            # En Español/, .es.md puede quedarse o consolidarse con .md
            for es_file in es_files:
                base_name = es_file.stem  # Ej: "CONCEPT_WHITE_PAPER"
                md_file = es_file.parent / f"{base_name}.md"

                if md_file.exists():
                    # Ya existe .md, eliminar .es.md (duplicado)
                    print(f"🗑️  Eliminando duplicado: {es_file.relative_to(lang_dir)}")
                    es_file.unlink()
                    stats["Español"]["consolidated"] += 1
                else:
                    # No existe .md, renombrar .es.md → .md
                    print(f"♻️  Consolidando: {es_file.name} → {md_file.name}")
                    es_file.rename(md_file)
                    stats["Español"]["consolidated"] += 1

    # Resumen final
    print("\n" + "=" * 70)
    print("📊 RESUMEN DE LIMPIEZA")
    print("=" * 70)

    for lang, data in stats.items():
        print(f"\n{lang}/:")
        print(
            f"   - Archivos .es.md eliminados (idioma incorrecto): {data['removed_es']}"
        )
        print(
            f"   - Archivos .en.md eliminados (idioma incorrecto): {data['removed_en']}"
        )
        print(f"   - Duplicados consolidados: {data['consolidated']}")

    total_removed = sum(
        d["removed_es"] + d["removed_en"] + d["consolidated"] for d in stats.values()
    )
    print(f"\n✅ Total de archivos procesados: {total_removed}")
    print()

    # Validación final
    print("🔍 Validación final:")
    english_total = len(list((doc_root / "English").rglob("*.md")))
    spanish_total = len(list((doc_root / "Español").rglob("*.md")))

    print(f"   English/: {english_total} archivos .md")
    print(f"   Español/: {spanish_total} archivos .md")

    if english_total == spanish_total:
        print("   ✅ ESPEJO PERFECTO MANTENIDO")
    else:
        diff = abs(english_total - spanish_total)
        print(f"   ⚠️  Diferencia: {diff} archivos")
        print("   (Esto puede ser normal si había archivos solo en un idioma)")


if __name__ == "__main__":
    clean_language_extensions()
