from uuid import UUID

from app.services.rag.template_builder_protocol import TemplateBuilderProtocol


class MVPTemplateBuilder(TemplateBuilderProtocol):
    """
    Elite Architect Template Builder.
    Genera documentos de alto impacto visual y técnico siguiendo el estilo 'Senior Architect'.
    """

    def select_template(self, project_id: UUID) -> str:
        return "CONTEXT_DRIVEN"

    def build_prompt(
        self,
        query: str,
        context: list[str],
        template_id: str,
        history: list[dict[str, str]] | None = None,
        user_name: str = "Developer",
    ) -> str:
        system_instruction = (
            "SYSTEM: Eres SoftArchitect, un Arquitecto de Software Senior con una obsesión por la excelencia documental y estética.\n"
            "Tu misión es guiar a {user_name} generando artefactos técnicos que causen un efecto 'WOW' por su claridad, orden y profesionalidad.\n\n"
            "=== ESTILO Y FORMATO OBLIGATORIO (WOW EFFECT) ===\n"
            "- Usa emojis temáticos en todos los títulos para hacer el documento visualmente atractivo (ej: 🚀, 🏗️, 🛡️, 📊).\n"
            "- PROHIBIDOS los párrafos largos. Usa listas de puntos, bloques de cita (>) y, sobre todo, TABLAS comparativas o descriptivas.\n"
            "- Si el ejemplo maestro incluye una tabla, una estructura de árbol o un diagrama Mermaid, TÚ DEBES replicarlo o mejorarlo.\n"
            "- Usa negritas para resaltar términos técnicos y conceptos clave.\n\n"
            "=== REGLAS DE ORO DEL ARQUITECTO ===\n"
            "1. GESTIÓN DE REFINAMIENTO Y RECHAZO:\n"
            "   - Si el usuario quiere REFINAR: Sé un compañero colaborador. Pregunta qué puntos ajustar y sugiere 2 mejoras técnicas avanzadas.\n"
            "   - Si el usuario RECHAZA: Entiende que el enfoque no encaja, sé empático y pide nuevos requisitos para empezar de cero esa propuesta.\n"
            "2. MODO GENERACIÓN DIRECTA (PROACTIVIDAD):\n"
            "   - En propuestas iniciales, no preguntes. Decide basándote en estándares de la industria (ej: React/Node para escalabilidad, Flutter para multiplataforma).\n"
            "3. FIDELIDAD AL EJEMPLO MAESTRO:\n"
            "   - El bloque '=== MASTER TEMPLATE EXAMPLE ===' es tu biblia estructural. No omitas secciones. Si el ejemplo es denso, tu salida debe ser igual de densa y detallada.\n"
            "4. EL CONTRATO DE SALIDA:\n"
            "   - Tu respuesta se divide en: Razonamiento técnico senior amigable (fuera) + Artefacto técnico (dentro de <document>).\n"
            "   - La primera línea dentro de <document> DEBE ser: **Path:** `ruta/del/archivo.md`\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        )

        system_instruction = system_instruction.replace("{user_name}", user_name)

        # Sección de Historial (Memoria del proyecto)
        history_section = ""
        if history:
            history_section = "\n\n📋 MEMORIA DE DECISIONES:\n"
            for msg in history[-6:]:
                role = "USUARIO" if msg["role"] == "user" else "SOFTARCHITECT"
                content = (
                    msg["content"][:400] + "..."
                    if len(msg["content"]) > 400
                    else msg["content"]
                )
                history_section += f"{role}: {content}\n"

        # Sección de RAG (Contexto Maestro)
        context_section = ""
        if not context:
            context_section = "\n\n⚠️ INFO: Base de conocimientos no disponible. Usa estándares senior para un e-commerce artesanal."
        else:
            context_str = "\n\n".join(context)
            context_section = (
                "\n\n📚 GUÍA SAGRADA Y CONTEXTO:\n"
                "⚡ INSTRUCCIÓN CRÍTICA: Debes clonar la estética, el uso de iconos y la profundidad del bloque "
                "'=== MASTER TEMPLATE EXAMPLE ==='. No entregues algo inferior en detalle.\n"
                "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
                f"{context_str}\n"
                "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            )

        final_prompt = (
            system_instruction
            + context_section
            + history_section
            + f"\n\n❓ SOLICITUD ACTUAL DEL CLIENTE: {query}"
            + "\n\nRESULTADO: Razonamiento técnico y propuesta en <document>**Path:** ...</document>"
        )

        return final_prompt
