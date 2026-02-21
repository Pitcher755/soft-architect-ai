#!/usr/bin/env python3
"""
Enhanced translation script for doc/English/ directory - Phase 2.
Handles Spanish sentences, questions, and complex patterns.
"""

import re
from pathlib import Path
from typing import List, Tuple

# Enhanced translation dictionary (more complex patterns)
SENTENCE_TRANSLATIONS = {
    # Questions
    r"¿Qué es\?": "What is it?",
    r"¿Qué son\?": "What are they?",
    r"¿Cómo funciona\?": "How does it work?",
    r"¿Cómo se usa\?": "How to use it?",
    r"¿Por qué\?": "Why?",
    r"¿Cuál es el objetivo\?": "What is the objective?",
    r"¿Cuándo usar\?": "When to use it?",
    r"¿Dónde encontrar\?": "Where to find it?",
    # Common phrases
    r"Los siguientes": "The following",
    r"El siguiente": "The next",
    r"La siguiente": "The next",
    r"Los usuarios": "The users",
    r"El usuario": "The user",
    r"La aplicación": "The application",
    r"El sistema": "The system",
    r"El servicio": "The service",
    r"La herramienta": "The tool",
    r"Las herramientas": "The tools",
    r"La solución": "The solution",
    r"El problema": "The problem",
    r"Los problemas": "The problems",
    r"La arquitectura": "The architecture",
    r"El código": "The code",
    r"La base de datos": "The database",
    r"El servidor": "The server",
    r"El cliente": "The client",
    r"La interfaz": "The interface",
    r"El componente": "The component",
    r"Los componentes": "The components",
    r"La funcionalidad": "The functionality",
    r"Las funcionalidades": "The functionalities",
    r"El módulo": "The module",
    r"Los módulos": "The modules",
    r"La fase": "The phase",
    r"Las fases": "The phases",
    r"El paso": "The step",
    r"Los pasos": "The steps",
    r"El resultado": "The result",
    r"Los resultados": "The results",
    r"La versión": "The version",
    r"Las versiones": "The versions",
    r"El proceso": "The process",
    r"Los procesos": "The processes",
    r"La implementación": "The implementation",
    r"Las implementaciones": "The implementations",
    r"El desarrollo": "The development",
    r"La ejecución": "The execution",
    r"El análisis": "The analysis",
    r"La validación": "The validation",
    r"Las validaciones": "The validations",
    r"El reporte": "The report",
    r"Los reportes": "The reports",
    r"La guía": "The guide",
    r"Las guías": "The guides",
    r"El manual": "The manual",
    r"Los manuales": "The manuals",
    r"La documentación": "The documentation",
    r"El error": "The error",
    r"Los errores": "The errors",
    r"La corrección": "The fix",
    r"Las correcciones": "The fixes",
    r"El cambio": "The change",
    r"Los cambios": "The changes",
    r"La mejora": "The improvement",
    r"Las mejoras": "The improvements",
    # Verbs and actions
    r"Ejecutar": "Execute",
    r"Ejecuta": "Execute",
    r"Ejecutado": "Executed",
    r"Crear": "Create",
    r"Crea": "Create",
    r"Creado": "Created",
    r"Eliminar": "Delete",
    r"Elimina": "Delete",
    r"Eliminado": "Deleted",
    r"Modificar": "Modify",
    r"Modifica": "Modify",
    r"Modificado": "Modified",
    r"Actualizar": "Update",
    r"Actualiza": "Update",
    r"Actualizado": "Updated",
    r"Instalar": "Install",
    r"Instala": "Install",
    r"Instalado": "Installed",
    r"Configurar": "Configure",
    r"Configura": "Configure",
    r"Configurado": "Configured",
    r"Iniciar": "Start",
    r"Inicia": "Start",
    r"Iniciado": "Started",
    r"Detener": "Stop",
    r"Detenido": "Stopped",
    r"Pausar": "Pause",
    r"Pausado": "Paused",
    r"Continuar": "Continue",
    r"Continuado": "Continued",
    r"Finalizar": "Finish",
    r"Finalizado": "Finished",
    r"Completar": "Complete",
    r"Completa": "Complete",
    r"Completado": "Completed",
    r"Verificar": "Verify",
    r"Verifica": "Verify",
    r"Verificado": "Verified",
    r"Validar": "Validate",
    r"Valida": "Validate",
    r"Validado": "Validated",
    r"Probar": "Test",
    r"Prueba": "Test",
    r"Probado": "Tested",
    r"Implementar": "Implement",
    r"Implementa": "Implement",
    r"Implementado": "Implemented",
    r"Desplegar": "Deploy",
    r"Despliega": "Deploy",
    r"Desplegado": "Deployed",
    r"Desarrollar": "Develop",
    r"Desarrolla": "Develop",
    r"Desarrollado": "Developed",
    r"Analizar": "Analyze",
    r"Analiza": "Analyze",
    r"Analizado": "Analyzed",
    r"Revisar": "Review",
    r"Revisa": "Review",
    r"Revisado": "Reviewed",
    r"Generar": "Generate",
    r"Genera": "Generate",
    r"Generado": "Generated",
    r"Construir": "Build",
    r"Construye": "Build",
    r"Construido": "Built",
    r"Compilar": "Compile",
    r"Compila": "Compile",
    r"Compilado": "Compiled",
    r"Depurar": "Debug",
    r"Depura": "Debug",
    r"Depurado": "Debugged",
    # Time expressions
    r"Ahora": "Now",
    r"Luego": "Then",
    r"Después": "After",
    r"Antes": "Before",
    r"Durante": "During",
    r"Mientras": "While",
    r"Cuando": "When",
    r"Siempre": "Always",
    r"Nunca": "Never",
    r"A veces": "Sometimes",
    r"Frecuentemente": "Frequently",
    r"Raramente": "Rarely",
    # Adjectives
    r"Nuevo": "New",
    r"Nueva": "New",
    r"Nuevos": "New",
    r"Nuevas": "New",
    r"Anterior": "Previous",
    r"Anteriores": "Previous",
    r"Siguiente": "Next",
    r"Siguientes": "Next",
    r"Actual": "Current",
    r"Actuales": "Current",
    r"Futuro": "Future",
    r"Futuros": "Future",
    r"Pasado": "Past",
    r"Pasados": "Past",
    r"Presente": "Present",
    r"Completo": "Complete",
    r"Incompleto": "Incomplete",
    r"Parcial": "Partial",
    r"Total": "Total",
    r"Final": "Final",
    r"Inicial": "Initial",
    r"Principal": "Main",
    r"Principales": "Main",
    r"Secundario": "Secondary",
    r"Secundarios": "Secondary",
    r"Necesario": "Necessary",
    r"Necesarios": "Necessary",
    r"Opcional": "Optional",
    r"Opcionales": "Optional",
    r"Requerido": "Required",
    r"Requeridos": "Required",
    r"Obligatorio": "Mandatory",
    r"Obligatorios": "Mandatory",
    r"Adicional": "Additional",
    r"Adicionales": "Additional",
    r"Extra": "Extra",
    r"Básico": "Basic",
    r"Básica": "Basic",
    r"Básicos": "Basic",
    r"Avanzado": "Advanced",
    r"Avanzada": "Advanced",
    r"Avanzados": "Advanced",
    r"Simple": "Simple",
    r"Simples": "Simple",
    r"Complejo": "Complex",
    r"Compleja": "Complex",
    r"Complejos": "Complex",
    r"Fácil": "Easy",
    r"Fáciles": "Easy",
    r"Difícil": "Difficult",
    r"Difíciles": "Difficult",
    r"Rápido": "Fast",
    r"Rápida": "Fast",
    r"Rápidos": "Fast",
    r"Lento": "Slow",
    r"Lenta": "Slow",
    r"Lentos": "Slow",
    r"Grande": "Large",
    r"Grandes": "Large",
    r"Pequeño": "Small",
    r"Pequeña": "Small",
    r"Pequeños": "Small",
    r"Alto": "High",
    r"Alta": "High",
    r"Altos": "High",
    r"Bajo": "Low",
    r"Baja": "Low",
    r"Bajos": "Low",
    r"Mejor": "Better",
    r"Mejores": "Better",
    r"Peor": "Worse",
    r"Peores": "Worse",
    r"Mayor": "Greater",
    r"Mayores": "Greater",
    r"Menor": "Lesser",
    r"Menores": "Lesser",
    r"Primero": "First",
    r"Primera": "First",
    r"Primeros": "First",
    r"Último": "Last",
    r"Última": "Last",
    r"Últimos": "Last",
    r"Medio": "Middle",
    r"Media": "Middle",
    r"Medios": "Middle",
    # Conjunctions and prepositions
    r" y ": " and ",
    r" o ": " or ",
    r" pero ": " but ",
    r" sino ": " but ",
    r" porque ": " because ",
    r" para ": " for ",
    r" por ": " by ",
    r" con ": " with ",
    r" sin ": " without ",
    r" sobre ": " about ",
    r" según ": " according to ",
    r" desde ": " from ",
    r" hasta ": " until ",
    r" hacia ": " towards ",
    r" entre ": " between ",
    r" bajo ": " under ",
    r" dentro ": " inside ",
    r" fuera ": " outside ",
    r" arriba ": " above ",
    r" abajo ": " below ",
}


def is_code_block(lines: List[str], line_num: int) -> bool:
    """Check if line is within a code block"""
    code_fence_count = 0
    for i in range(line_num):
        if lines[i].strip().startswith("```"):
            code_fence_count += 1
    return code_fence_count % 2 == 1


def translate_file(filepath: Path) -> Tuple[bool, str]:
    """
    Translate a single markdown file with enhanced patterns.
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

            # Apply sentence translations (order matters - specific before general)
            for pattern, replacement in SENTENCE_TRANSLATIONS.items():
                lines[i] = re.sub(pattern, replacement, lines[i])

        new_content = "\n".join(lines)

        if new_content != original_content:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(new_content)
            return True, "Translated (Phase 2)"
        else:
            return False, "No changes needed"

    except Exception as e:
        return False, f"Error: {str(e)}"


def main():
    """Main translation process - Phase 2"""
    doc_english_dir = Path(__file__).parent.parent / "doc" / "English"

    if not doc_english_dir.exists():
        print(f"❌ Directory not found: {doc_english_dir}")
        return

    print("🚀 Phase 2: Enhanced translation patterns")
    print(f"📝 Applying {len(SENTENCE_TRANSLATIONS)} complex patterns\n")

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

    print("\n📊 PHASE 2 TRANSLATION SUMMARY")
    print("=" * 50)
    print(f"✅ Translated:  {translated_count} files")
    print(f"⏭️  Skipped:     {skipped_count} files")
    print(f"❌ Errors:      {error_count} files")
    print(f"📄 Total:       {len(md_files)} files")
    print("=" * 50)


if __name__ == "__main__":
    main()
