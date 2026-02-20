from uuid import UUID

from app.services.rag.template_builder_protocol import TemplateBuilderProtocol


class MVPTemplateBuilder(TemplateBuilderProtocol):
    """
    Production-ready template builder.
    System prompt translated to English for higher model reasoning and adherence.
    """

    def select_template(self, project_id: UUID) -> str:
        return "CONTEXT_DRIVEN"

    def build_prompt(
        self,
        query: str,
        context: list[str],
        template_id: str,
        history: list[dict[str, str]] | None = None,
    ) -> str:
        # ✅ 1. SYSTEM INSTRUCTION (ENGLISH RULES, SPANISH EXAMPLE)
        system_instruction = (
            "SYSTEM: YOU ARE SoftArchitect AI, the Senior Software Architect of this project. "
            "Your job is to transform user ideas into enterprise-grade engineering documents.\n\n"
            "🛑 CRITICAL PRIME DIRECTIVES (ANTI-HALLUCINATION):\n"
            "1. STACK FIDELITY: If the user defines a tech stack (e.g., 'Flutter + Firebase'), USE IT. "
            "NEVER invent unsolicited technologies unless explicitly requested.\n"
            "2. TEMPLATE DICTATORSHIP: You MUST use the structure provided in the RAG context templates. "
            "DO NOT invent your own sections. Copy the exact Markdown titles from the template.\n"
            "3. DIRECTORY STRUCTURE: '00-ROOT' phase goes to root (/). Other phases go inside 'context/...'.\n"
            "4. LANGUAGE MIRRORING: You MUST generate content in the EXACT SAME LANGUAGE the user spoke to you.\n\n"
            "🎨 UI CONTRACT & RESPONSE FORMAT (MANDATORY):\n"
            "The frontend relies on an XML parser to render documents. You must split your response into two parts:\n"
            "PART 1 (Chat): A brief text explaining what you generated.\n"
            "PART 2 (Document): The generated document MUST be strictly wrapped inside XML tags: <document> and </document>.\n"
            "⚠️ FATAL ERROR WARNING: NEVER use markdown code blocks (```document) to wrap the document. ONLY use <document> XML tags.\n\n"
            "📝 EXACT EXAMPLE (If user speaks Spanish):\n"
            "Entendido. Aquí tienes el borrador inicial. ¿Lo validamos?\n\n"
            "<document>\n"
            "# 📝 PROJECT_MANIFESTO.md\n"
            "**Ruta:** `context/10-CONTEXT/PROJECT_MANIFESTO.md`\n\n"
            "(...contenido del documento siguiendo estrictamente la plantilla...)\n"
            "</document>\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        )

        # ✅ 2. HISTORY FORMATTING
        history_section = ""
        if history and len(history) > 0:
            history_section = "\n\n📋 RECENT HISTORY:\n"
            for msg in history[-5:]:
                role_raw = msg["role"]
                content = msg["content"]
                role_prefix = "USER:" if role_raw == "user" else "SOFTARCHITECT:"
                history_section += f"{role_prefix} {content}\n"

        # ✅ 3. RAG CONTEXT (THE SOURCE OF TRUTH)
        context_section = ""
        if template_id == "FALLBACK" or not context:
            # ✅ CORRECCIÓN DEL BUG: Antes ponía ```document aquí.
            context_section = (
                "\n\n⚠️ WARNING: No templates found in the knowledge base. "
                "Use your best judgment as an Architect but respect the UI CONTRACT (use <document> tags, NEVER ```)."
            )
        else:
            context_str = "\n\n".join(context)
            context_section = (
                "\n\n📚 CONTEXT AND TEMPLATES (SOURCE OF TRUTH):\n"
                "Use this information to structure your response. "
                "If you see text that is a template (contains {{variables}}), use it as a skeleton.\n"
                "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
                f"{context_str}\n"
                "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            )

        # ✅ 4. USER QUERY
        user_query_section = f"\n\n❓ CURRENT REQUEST:\n{query}"

        # ✅ 5. ASSEMBLE PROMPT
        final_prompt = (
            system_instruction + context_section + history_section + user_query_section
        )

        return final_prompt
