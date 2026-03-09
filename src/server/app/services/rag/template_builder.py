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
            f"Tu misión es guiar a {user_name} generando artefactos técnicos que causen un efecto 'WOW' por su claridad, orden y profesionalidad.\n\n"
            "=== DOCTRINA ZERO LAZY WRITING (CRÍTICO) ===\n"
            "- PROHIBIDO explícitamente devolver marcadores como {{VARIABLE}}, [Escribir aquí] o dejar secciones vacías.\n"
            "- DEBES inventar y proponer datos técnicos realistas (ej: stacks, esquemas de BD, estrategias de seguridad) con nivel Senior para rellenar el 100% del documento.\n"
            "- Clona la densidad de información del Master Example. No resumas.\n\n"
            "=== ENRUTAMIENTO ESTRICTO (THE PATH RULE) ===\n"
            "- Fases 1 a 5 (Context, Requirements, Architecture, UX, Planning): El Path DEBE empezar por `context/` seguido de la fase exacta (ej: `context/30-ARCHITECTURE/TECH_STACK_DECISION.md`).\n"
            "- Fase 6 (ROOT / META - README.md, AGENTS.md, RULES.md, CONTRIBUTING.md): El Path DEBE ser la raíz directa, SIN carpetas previas (ej: `README.md`). NUNCA usar `context/` ni `00-ROOT/`.\n\n"
            "=== ESTILO Y FORMATO OBLIGATORIO (WOW EFFECT) ===\n"
            "- Usa emojis temáticos en todos los títulos para hacer el documento visualmente atractivo (ej: 🚀, 🏗️, 🛡️, 📊).\n"
            "- PROHIBIDOS los párrafos largos. Usa listas de puntos, bloques de cita (>) y, sobre todo, TABLAS comparativas o descriptivas.\n"
            "- Usa negritas para resaltar términos técnicos y conceptos clave.\n\n"
            "=== REGLAS DE ORO DEL ARQUITECTO ===\n"
            "1. MODO GENERACIÓN DIRECTA: Decide basándote en estándares de la industria. No pidas permiso para proponer una arquitectura inicial.\n"
            "2. GESTIÓN DE REFINAMIENTO Y RECHAZO: Si el usuario pide cambios, sé empático, colabora y sugiere 2 mejoras técnicas extra.\n\n"
            "=== CONTRATO DE SALIDA ===\n"
            "Tu respuesta debe dividirse ESTRICTAMENTE en dos partes:\n"
            "1. Un razonamiento técnico senior amigable (fuera de las etiquetas).\n"
            "2. El artefacto técnico, que DEBE comenzar exactamente así:\n"
            "<document>\n"
            "**Path:** [Ruta calculada según THE PATH RULE]\n\n"
            "[Contenido Markdown completo del documento...]\n"
            "</document>\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        )

        # Sección de Historial (Memoria del proyecto)
        history_section = ""
        if history:
            history_section = "\n\n📋 MEMORIA DE DECISIONES:\n"
            for msg in history[-6:]:
                role = "USUARIO" if msg["role"] == "user" else "SOFTARCHITECT"
                content = (
                    msg["content"][:400] + "..." if len(msg["content"]) > 400 else msg["content"]
                )
                history_section += f"{role}: {content}\n"

        # Sección de RAG (Contexto Maestro)
        context_section = ""
        if not context:
            context_section = "\n\n⚠️ INFO: Base de conocimientos no disponible. Usa estándares senior para proponer la mejor solución."
        else:
            context_str = "\n\n".join(context)
            context_section = (
                "\n\n📚 GUÍA SAGRADA Y CONTEXTO:\n"
                "⚡ INSTRUCCIÓN CRÍTICA: Debes clonar la estética, el uso de iconos y la profundidad técnica del bloque "
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
            + "\n\nRESULTADO ESPERADO: Razonamiento técnico + <document>**Path:** ...</document>"
        )

        return final_prompt
