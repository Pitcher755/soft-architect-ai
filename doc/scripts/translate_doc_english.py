#!/usr/bin/env python3
"""
Script para traducir automáticamente términos en español a inglés en doc/English/
Mantiene formato Markdown, code blocks, y términos técnicos.
"""

from pathlib import Path
from typing import List

# Diccionario de traducciones (español → inglés)
TRANSLATIONS = {
    # Headers y títulos comunes
    "# 🎯 ESTADO FINAL DEL PROYECTO": "# 🎯 FINAL PROJECT STATUS",
    "# 🎯 ESTADO FINAL DEL": "# 🎯 FINAL STATUS OF",
    "## 📊 Resumen Ejecutivo": "## 📊 Executive Summary",
    "## ✅ LOGROS COMPLETADOS": "## ✅ COMPLETED ACHIEVEMENTS",
    "## 📌 ¿Qué es SoftArchitect AI?": "## 📌 What is SoftArchitect AI?",
    "## ⚡ Instalación": "## ⚡ Installation",
    "## 📖 Tabla de Contenidos": "## 📖 Table of Contents",
    # FASE headers (PRIORITY: exact patterns first)
    "### ✅ FASE 1:": "### ✅ PHASE 1:",
    "### ✅ FASE 2:": "### ✅ PHASE 2:",
    "### ✅ FASE 3:": "### ✅ PHASE 3:",
    "### ✅ FASE 4:": "### ✅ PHASE 4:",
    "### ✅ FASE 5:": "### ✅ PHASE 5:",
    "### 🔴 FASE 1:": "### 🔴 PHASE 1:",
    "### 🔴 FASE 2:": "### 🔴 PHASE 2:",
    "### 🔴 FASE 3:": "### 🔴 PHASE 3:",
    "### 🔴 FASE 4:": "### 🔴 PHASE 4:",
    "### 🔴 FASE 5:": "### 🔴 PHASE 5:",
    "### 🟢 FASE 1:": "### 🟢 PHASE 1:",
    "### 🟢 FASE 2:": "### 🟢 PHASE 2:",
    "### 🟢 FASE 3:": "### 🟢 PHASE 3:",
    "### 🟢 FASE 4:": "### 🟢 PHASE 4:",
    "### 🟢 FASE 5:": "### 🟢 PHASE 5:",
    "FASE 1:": "PHASE 1:",
    "FASE 2:": "PHASE 2:",
    "FASE 3:": "PHASE 3:",
    "FASE 4:": "PHASE 4:",
    "FASE 5:": "PHASE 5:",
    "FASE 6:": "PHASE 6:",
    "FASE 7:": "PHASE 7:",
    "FASE 8:": "PHASE 8:",
    "FASE 9:": "PHASE 9:",
    "FASE 0:": "PHASE 0:",
    "(Fase 1-3)": "(Phase 1-3)",
    "(Fase 1-5)": "(Phase 1-5)",
    # UI strings in quotes AND brackets
    '"Nuevo Proyecto"': '"New Project"',
    '"nuevo proyecto"': '"new project"',
    "[Nuevo Proyecto]": "[New Project]",
    "[nuevo proyecto]": "[new project]",
    '"Crear Proyecto"': '"Create Project"',
    '"crear proyecto"': '"create project"',
    "[Crear Proyecto]": "[Create Project]",
    "[crear proyecto]": "[create project]",
    '"Abrir Proyecto"': '"Open Project"',
    '"abrir proyecto"': '"open project"',
    "[Abrir Proyecto]": "[Open Project]",
    "[abrir proyecto]": "[open project]",
    '"Chat"': '"Chat"',
    '"Selecciona/Crea Proyecto"': '"Select/Create Project"',
    '"Selecciona"': '"Select"',
    '"Crea Proyecto"': '"Create Project"',
    # Metadata strings in parentheses (API endpoints)
    "(Crear proyecto)": "(Create project)",
    "(crear proyecto)": "(create project)",
    "(Get proyecto metadata)": "(Get project metadata)",
    "(Obtener proyecto)": "(Get project)",
    # Phrases with prepositions
    "con proyectos": "with projects",
    "del proyecto": "of the project",
    "al proyecto": "to the project",
    "en el proyecto": "in the project",
    "para el proyecto": "for the project",
    "sobre el proyecto": "about the project",
    "String path del último proyecto": "String path of the last project",
    "path del último proyecto": "path of the last project",
    # User flow phrases
    "Usuario abre app": "User opens app",
    "Usuario crea Proyecto": "User creates Project",
    "Usuario crea proyecto": "User creates project",
    "Selecciona/Crea Proyecto": "Select/Create Project",
    "Selecciona/Crea proyecto": "Select/Create project",
    "Modal crear proyecto": "Create project modal",
    "Sidebar con proyectos": "Sidebar with projects",
    "Estilo IDE, Sidebar con proyectos": "IDE Style, Sidebar with projects",
    # Metadatos
    "> **Fecha:**": "> **Date:**",
    "> **Estado:**": "> **Status:**",
    "> **Versión:**": "> **Version:**",
    "> **Tiempo de lectura:**": "> **Reading Time:**",
    "> **Nivel:**": "> **Level:**",
    "> **Requisitos:**": "> **Requirements:**",
    # Palabras comunes
    "Proyecto": "Project",
    "proyecto": "project",
    "Estado": "Status",
    "estado": "status",
    "Fase": "Phase",
    "fase": "phase",
    "Documento": "Document",
    "documento": "document",
    "Archivo": "File",
    "archivo": "file",
    "Carpeta": "Folder",
    "carpeta": "folder",
    "Prueba": "Test",
    "prueba": "test",
    "Implementación": "Implementation",
    "implementación": "implementation",
    "Configuración": "Configuration",
    "configuración": "configuration",
    "Descripción": "Description",
    "descripción": "description",
    "Siguiente": "Next",
    "siguiente": "next",
    "Ejecutar": "Execute",
    "ejecutar": "execute",
    "Crear": "Create",
    "crear": "create",
    "Eliminar": "Delete",
    "eliminar": "delete",
    # Frases comunes
    "Nada, comenzaremos desde cero": "Nothing, we'll start from scratch",
    "En lugar de:": "Instead of:",
    "Te ayuda a:": "It helps you:",
    "¿Qué stack uso?": "What stack should I use?",
    "Comenzaremos": "We'll start",
    "comenzaremos": "we'll start",
    # Niveles
    "Principiante": "Beginner",
    "Intermedio": "Intermediate",
    "Avanzado": "Advanced",
    # Resultados
    "Resultado": "Result",
    "Completado": "Completed",
    "Pendiente": "Pending",
    "En progreso": "In progress",
    # Frases de proyecto (PRIORITY: longer strings first)
    "Nuevo Proyecto": "New Project",
    "nuevo proyecto": "new project",
    "Crear Proyecto": "Create Project",
    "crear proyecto": "create project",
    "último proyecto": "last project",
    "del último proyecto": "of the last project",
    # Expresiones de fase
    "PRÓXIMA FASE": "NEXT PHASE",
    "Próxima fase": "Next phase",
    "próxima fase": "next phase",
    "RESUMEN POR FASE TDD": "TDD PHASE SUMMARY",
    "RESUMEN POR FASE": "SUMMARY BY PHASE",
    "Resumen por fase": "Summary by phase",
    "resumen por fase": "summary by phase",
    "Desglose de files Createdos": "Breakdown of Created Files",
    "Desglose": "Breakdown",
    "desglose": "breakdown",
    # Términos de interfaz
    "Estilo IDE": "IDE Style",
    "estilo": "style",
    "Estilo": "Style",
    "Sidebar con": "Sidebar with",
    "Modal": "Modal",
    "modal": "modal",
    "Botón": "Button",
    "botón": "button",
    # Términos de preparación/estado
    "Preparado para": "Ready for",
    "preparado para": "ready for",
    "Listos para producción": "Ready for production",
    "Listos para": "Ready for",
    "listos para": "ready for",
    "marcada como completada": "marked as completed",
    # Pasos siguientes
    "Próximos Pasos": "Next Steps",
    "próximos pasos": "next steps",
    "Siguiente paso": "Next step",
    "siguiente paso": "next step",
    "Anterior": "Previous",
    "anterior": "previous",
    # Análisis y verificación
    "Análisis": "Analysis",
    "análisis": "analysis",
    "Verificación": "Verification",
    "verificación": "verification",
    # Headers de tabla
    "ESTADO": "STATUS",
    "| ESTADO |": "| STATUS |",
    "Nombre": "Name",
}


def is_code_block(lines: List[str], line_num: int) -> bool:
    """Check if a line is inside a code block."""
    code_block_count = 0
    for i in range(line_num):
        if lines[i].strip().startswith("```"):
            code_block_count += 1
    return code_block_count % 2 == 1


def translate_file(file_path: Path) -> bool:
    """
    Translate Spanish content to English in a single file.
    Returns True if file was modified.
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        lines = content.split("\n")

        # Apply translations line by line, skipping code blocks
        modified = False
        for line_num, line in enumerate(lines):
            if is_code_block(lines, line_num):
                continue  # Skip lines inside code blocks

            for spanish, english in TRANSLATIONS.items():
                if spanish in line:
                    lines[line_num] = lines[line_num].replace(spanish, english)
                    modified = True

        if modified:
            with open(file_path, "w", encoding="utf-8") as f:
                f.write("\n".join(lines))
            return True

        return False

    except Exception as e:
        print(f"❌ Error processing {file_path}: {e}")
        return False


def main():
    """Main execution."""
    doc_english_path = Path(__file__).parent.parent / "English"

    if not doc_english_path.exists():
        print(f"❌ Directory not found: {doc_english_path}")
        return

    # Find all .md files
    md_files = list(doc_english_path.rglob("*.md"))
    print(f"📄 Found {len(md_files)} markdown files in doc/English/")

    translated_count = 0
    for md_file in md_files:
        if translate_file(md_file):
            translated_count += 1
            print(f"✅ Translated: {md_file.relative_to(doc_english_path)}")

    print("\n🎉 Translation complete!")
    print(f"   Files translated: {translated_count}/{len(md_files)}")
    print(f"   Files unchanged: {len(md_files) - translated_count}")


if __name__ == "__main__":
    main()
