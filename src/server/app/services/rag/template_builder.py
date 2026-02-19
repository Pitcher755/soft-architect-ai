"""
Production-ready template builder for RAG prompts.

This module contains the MVPTemplateBuilder class that constructs
LLM prompts with strict constraints to prevent hallucinations.

Following SOLID principles: Single Responsibility - Only handles prompt building.
"""

from uuid import UUID

from app.services.rag.template_builder_protocol import TemplateBuilderProtocol


class MVPTemplateBuilder(TemplateBuilderProtocol):
    """
    Production-ready template builder for MVP with strict instruction adherence.
    Designed to prevent hallucinations and format responses for the UI.
    """

    def select_template(self, project_id: UUID) -> str:
        """Select template strategy based on project context."""
        return "CONTEXT_DRIVEN"

    def build_prompt(
        self,
        query: str,
        context: list[str],
        template_id: str,
        history: list[dict[str, str]] | None = None,
    ) -> str:
        """
        Build LLM prompt with strict constraints to prevent hallucinations.

        STRATEGY:
        1. Define the Persona (SoftArchitect AI).
        2. Define the Negative Constraints (What NOT to do).
        3. Inject the RAG Context as the "Source of Truth".
        4. Include conversation history for context.
        5. Append the User Query.

        Args:
            query: Current user question/request.
            context: List of relevant documents from RAG retrieval.
            template_id: Template identifier for response formatting.
            history: Optional conversation history (recent messages).

        Returns:
            Fully assembled prompt string ready for LLM inference.
        """

        # ✅ 1. SYSTEM INSTRUCTION (ESTRICTA Y ANTI-ALUCINACIONES)
        system_instruction = (
            "SYSTEM: ERES SoftArchitect AI, el Arquitecto de Software Senior de este proyecto. "
            "Tu trabajo es convertir ideas en documentos de ingeniería, NO chalar ni inventar.\n\n"
            "🛑 REGLAS DE ORO (CRÍTICAS):\n"
            "1. FIDELIDAD TECNOLÓGICA: Si el usuario define un stack (ej: 'Flutter + Firebase'), "
            "ÚSALO. JAMÁS inventes tecnologías no solicitadas (como 'FastAPI' o 'MySQL') salvo que te pregunten explícitamente.\n"
            "2. DICTADURA DEL TEMPLATE: Tu contexto (RAG) contiene plantillas maestras (archivos .template.md). "
            "Cuando generes un documento, DEBES COPIAR SU ESTRUCTURA EXACTA (títulos y apartados). No inventes secciones genéricas.\n"
            "3. MASTER WORKFLOW INMUTABLE: El proyecto SOLO tiene estas fases:\n"
            "   - Fase 1: Gobernanza e Identidad\n"
            "   - Fase 2: Especificación y Seguridad\n"
            "   - Fase 3: Arquitectura Técnica\n"
            "   - Fase 4: Planificación y Calidad\n"
            "   Cualquier otra fase está PROHIBIDA.\n"
            "4. NO CÓDIGO: No generes código fuente hasta la Fase 4.\n\n"
            "🤖 MODO DE RESPUESTA:\n"
            "- Si te piden generar un documento, busca esa plantilla en el contexto y rellénala con los datos del usuario.\n"
            "- Mantén un tono profesional, directivo y conciso.\n"
            "- Termina siempre pidiendo validación: '¿Validamos este documento?'\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        )

        # ✅ 2. HISTORY FORMATTING
        history_section = ""
        if history and len(history) > 0:
            history_section = "\n\n📋 HISTORIAL RECIENTE:\n"
            for msg in history[-5:]:  # Limit history to keep focus strict
                role_raw = msg["role"]
                content = msg["content"]
                role_prefix = "USUARIO:" if role_raw == "user" else "SOFTARCHITECT:"
                history_section += f"{role_prefix} {content}\n"

        # ✅ 3. RAG CONTEXT (THE SOURCE OF TRUTH)
        context_section = ""
        if template_id == "FALLBACK" or not context:
            context_section = (
                "\n\n⚠️ ADVERTENCIA: No se encontraron plantillas en la base de conocimiento. "
                "Usa tu mejor criterio pero respeta las reglas de oro."
            )
        else:
            context_str = "\n\n".join(context)
            context_section = (
                "\n\n📚 CONTEXTO Y PLANTILLAS (FUENTE DE VERDAD):\n"
                "Usa esta información para estructurar tu respuesta. "
                "Si ves un texto que parece una plantilla (ej: contiene {{variables}}), ÚSALO como esqueleto.\n"
                "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
                f"{context_str}\n"
                "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            )

        # ✅ 4. USER QUERY
        user_query_section = f"\n\n❓ PETICIÓN ACTUAL:\n{query}"

        # ✅ 5. ASSEMBLE (System Prompt FIRST implies higher priority)
        final_prompt = (
            system_instruction
            + context_section  # Contexto antes del historial para priorizar reglas sobre charla previa
            + history_section
            + user_query_section
        )

        return final_prompt
