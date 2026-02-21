#!/usr/bin/env python3
"""
Script para traducir automáticamente términos en inglés a español en doc/Español/
Mantiene formato Markdown, code blocks, y términos técnicos.
"""

from pathlib import Path
from typing import List

# Diccionario de traducciones (inglés → español)
TRANSLATIONS = {
    # Frases completas (DEBEN IR PRIMERO - match más largo primero)
    "New Project": "Nuevo Proyecto",
    "new project": "nuevo proyecto",
    "Create Project": "Crear Proyecto",
    "create project": "crear proyecto",
    "Open Project": "Abrir Proyecto",
    "open project": "abrir proyecto",
    "NEXT PHASE": "PRÓXIMA FASE",
    "Next phase": "Próxima fase",
    "next phase": "próxima fase",
    "SUMMARY BY PHASE": "RESUMEN POR FASE",
    "Summary by phase": "Resumen por fase",
    "summary by phase": "resumen por fase",
    "of the last project": "del último proyecto",
    "last project": "último proyecto",
    "# 🎯 FINAL PROJECT STATUS": "# 🎯 ESTADO FINAL DEL PROYECTO",
    "## 📊 Executive Summary": "## 📊 Resumen Ejecutivo",
    "> **Date:**": "> **Fecha:**",
    "> **Status:**": "> **Estado:**",
    "Reading time:": "Tiempo de lectura:",
    "Level:": "Nivel:",
    "Requirements:": "Requisitos:",
    "What is": "Qué es",
    "what is": "qué es",
    "We will begin": "Comenzaremos",
    "we will begin": "comenzaremos",
    # PHASE headers (PRIORITY: patrones exactos primero)
    "### ✅ PHASE 1:": "### ✅ FASE 1:",
    "### ✅ PHASE 2:": "### ✅ FASE 2:",
    "### ✅ PHASE 3:": "### ✅ FASE 3:",
    "### ✅ PHASE 4:": "### ✅ FASE 4:",
    "### ✅ PHASE 5:": "### ✅ FASE 5:",
    "### 🔴 PHASE 1:": "### 🔴 FASE 1:",
    "### 🔴 PHASE 2:": "### 🔴 FASE 2:",
    "### 🔴 PHASE 3:": "### 🔴 FASE 3:",
    "### 🔴 PHASE 4:": "### 🔴 FASE 4:",
    "### 🔴 PHASE 5:": "### 🔴 FASE 5:",
    "### 🟢 PHASE 1:": "### 🟢 FASE 1:",
    "### 🟢 PHASE 2:": "### 🟢 FASE 2:",
    "### 🟢 PHASE 3:": "### 🟢 FASE 3:",
    "### 🟢 PHASE 4:": "### 🟢 FASE 4:",
    "### 🟢 PHASE 5:": "### 🟢 FASE 5:",
    "PHASE 1:": "FASE 1:",
    "PHASE 2:": "FASE 2:",
    "PHASE 3:": "FASE 3:",
    "PHASE 4:": "FASE 4:",
    "PHASE 5:": "FASE 5:",
    "PHASE 6:": "FASE 6:",
    "PHASE 7:": "FASE 7:",
    "PHASE 8:": "FASE 8:",
    "PHASE 9:": "FASE 9:",
    "PHASE 0:": "FASE 0:",
    "(Phase 1-3)": "(Fase 1-3)",
    "(Phase 1-5)": "(Fase 1-5)",
    # UI strings en comillas Y corchetes
    '"New Project"': '"Nuevo Proyecto"',
    "[New Project]": "[Nuevo Proyecto]",
    '"Create Project"': '"Crear Proyecto"',
    "[Create Project]": "[Crear Proyecto]",
    '"Open Project"': '"Abrir Proyecto"',
    "[Open Project]": "[Abrir Proyecto]",
    '"Select/Create Project"': '"Selecciona/Crea Proyecto"',
    '"Select"': '"Selecciona"',
    # Metadata strings en paréntesis (API endpoints)
    "(Create project)": "(Crear proyecto)",
    "(Get project metadata)": "(Obtener metadatos del proyecto)",
    "(Get project)": "(Obtener proyecto)",
    # Frases con preposiciones
    "with projects": "con proyectos",
    "of the project": "del proyecto",
    "to the project": "al proyecto",
    "in the project": "en el proyecto",
    "for the project": "para el proyecto",
    "about the project": "sobre el proyecto",
    "String path of the last project": "String path del último proyecto",
    "path of the last project": "path del último proyecto",
    # User flow phrases
    "User opens app": "Usuario abre app",
    "User creates Project": "Usuario crea Proyecto",
    "User creates project": "Usuario crea proyecto",
    "Select/Create Project": "Selecciona/Crea Proyecto",
    "Select/Create project": "Selecciona/Crea proyecto",
    "Create project modal": "Modal crear proyecto",
    "Sidebar with projects": "Sidebar con proyectos",
    "IDE Style, Sidebar with projects": "Estilo IDE, Sidebar con proyectos",
    # Headers y títulos comunes
    "# 🎯 FINAL STATUS OF": "# 🎯 ESTADO FINAL DE",
    "## ✅ COMPLETED ACHIEVEMENTS": "## ✅ LOGROS COMPLETADOS",
    "## 📖 Table of Contents": "## 📖 Tabla de Contenidos",
    # Metadatos
    "> **Version:**": "> **Versión:**",
    "> **Reading Time:**": "> **Tiempo de lectura:**",
    # Palabras comunes (case sensitive)
    "Project": "Proyecto",
    "project": "proyecto",
    "Status": "Estado",
    "status": "estado",
    "Phase": "Fase",
    "phase": "fase",
    "Document": "Documento",
    "document": "documento",
    "File": "Archivo",
    "file": "archivo",
    "Folder": "Carpeta",
    "folder": "carpeta",
    "Test": "Prueba",
    "test": "prueba",
    "Implementation": "Implementación",
    "implementation": "implementación",
    "Configuration": "Configuración",
    "configuration": "configuración",
    "Description": "Descripción",
    "description": "descripción",
    "Next": "Siguiente",
    "next": "siguiente",
    "Previous": "Anterior",
    "previous": "anterior",
    "Create": "Crear",
    "create": "crear",
    "Delete": "Eliminar",
    "delete": "eliminar",
    "Run": "Ejecutar",
    "run": "ejecutar",
    "Execute": "Ejecutar",
    "execute": "ejecutar",
    "Analysis": "Análisis",
    "analysis": "análisis",
    "Verification": "Verificación",
    "verification": "verificación",
    "Style": "Estilo",
    "style": "estilo",
    "Modal": "Modal",
    "modal": "modal",
    "Button": "Botón",
    "button": "botón",
    "Ready for": "Preparado para",
    "ready for": "preparado para",
    "Breakdown": "Desglose",
    "breakdown": "desglose",
    "Created": "Creados",
    "created": "creados",
    "Next Steps": "Próximos Pasos",
    "next steps": "próximos pasos",
    # Niveles
    "Beginner": "Principiante",
    "Intermediate": "Intermedio",
    "Advanced": "Avanzado",
    # Resultados
    "Result": "Resultado",
    "Completed": "Completado",
    "Pending": "Pendiente",
    "In progress": "En progreso",
    # Términos técnicos contextuales
    "Planning": "Planificación",
    "Infrastructure": "Infraestructura",
    "Presentation": "Presentación",
    "Integration": "Integración",
    "Pre-Sprint": "Pre-Sprint",
    "Foundation": "Fundación",
    "Core Logic": "Lógica Central",
    "Resilience": "Resiliencia",
    "Testing & Release": "Pruebas y Lanzamiento",
    "state injection in": "inyección de estado en",
    "state injection pattern": "patrón de inyección de estado",
    "propagates the initial state": "propaga el estado inicial",
    "Milestone:": "Hito:",
    "NEXT WEEK:": "SIGUIENTE SEMANA:",
    "proceed to next phase": "avanzar a siguiente fase",
    # Error strings
    "'Error saving document": "'Error al guardar documento",
    "errorMessage: 'Error saving document'": "errorMessage: 'Error al guardar documento'",
    "'✅ Document saved'": "'✅ Documento guardado'",
    "# Expected: <100MB per document": "# Esperado: <100MB por documento",
    "# Verify: <100MB per document": "# Verificar: <100MB por documento",
    "# Verify status": "# Verificar estado",
    # Términos de proceso
    "RED PHASE": "FASE ROJA",
    "GREEN PHASE": "FASE VERDE",
    "PHASE 9 COMPLETE": "FASE 9 COMPLETA",
    "marked as completed": "marcado como completado",
    "completed in": "completado en",
    "Preparation for": "Preparación para",
    "immediate": "inmediata",
    "code)": "código)",
    "Ready for production": "Listo para producción",
    "Documentation of": "Documentación de",
}


def is_code_block(lines: List[str], line_num: int) -> bool:
    """
    Determina si una línea está dentro de un bloque de código.
    """
    code_block_count = 0
    for i in range(line_num):
        if lines[i].strip().startswith("```"):
            code_block_count += 1
    # Si count es impar, estamos dentro de un bloque de código
    return code_block_count % 2 != 0


def translate_file(file_path: Path) -> bool:
    """
    Traduce contenido en inglés a español en un archivo.
    Retorna True si el archivo fue modificado.
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        original_content = content
        lines = content.split("\n")

        # Aplicar traducciones línea por línea (excepto code blocks)
        for line_num, line in enumerate(lines):
            if is_code_block(lines, line_num):
                continue  # Skip code blocks

            # Aplicar todas las traducciones
            for english, spanish in TRANSLATIONS.items():
                if english in lines[line_num]:
                    lines[line_num] = lines[line_num].replace(english, spanish)

        new_content = "\n".join(lines)

        # Solo escribir si hubo cambios
        if new_content != original_content:
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(new_content)
            return True

        return False

    except Exception as e:
        print(f"❌ Error processing {file_path}: {e}")
        return False


def main():
    """
    Función principal: procesa todos los archivos .md en doc/Español/
    """
    base_dir = Path(__file__).parent.parent / "Español"

    if not base_dir.exists():
        print(f"❌ Directory not found: {base_dir}")
        return

    # Encontrar todos los archivos .md
    md_files = list(base_dir.rglob("*.md"))
    print(f"📄 Found {len(md_files)} markdown files in doc/Español/\n")

    translated_count = 0
    unchanged_count = 0

    for md_file in md_files:
        if translate_file(md_file):
            relative_path = md_file.relative_to(base_dir.parent)
            print(f"✅ Translated: {relative_path}")
            translated_count += 1
        else:
            unchanged_count += 1

    print("\n🎉 Translation complete!")
    print(f"   Files translated: {translated_count}/{len(md_files)}")
    print(f"   Files unchanged: {unchanged_count}")


if __name__ == "__main__":
    main()
