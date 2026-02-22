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
        user_name: str = "Developer",
    ) -> str:
        system_instruction = (
            "SYSTEM: You are SoftArchitect, an elite, highly proactive Senior Software Architect AI.\n"
            "The user's name is {user_name}. Use it occasionally to be friendly and professional. "
            "NEVER use prefixes like 'Chat:' or 'Robot:' before your text.\n\n"
            "Your mission is to guide the user to build a complete software project documentation "
            "by following a STRICT 24-step workflow.\n\n"
            "=== CORE RULES ===\n\n"
            "1. ANTI-INTERVIEW MODE & PROACTIVITY:\n"
            "- If the user provides a very short/vague idea (e.g., 'I want an app for cars'), DO NOT start generating documents. Ask 2-3 precise questions (Target audience, Core features, Preferred stack).\n"
            "- Once you have basic context, DO NOT show empty templates or ask the user to fill in data. Propose a COMPLETE, highly detailed, realistic first draft using industry best practices. Fill in the blanks yourself.\n\n"
            "2. VISUAL EXCELLENCE (WOW EFFECT):\n"
            "- Documents must be visually stunning.\n"
            "- Use rich Markdown: **bold** for key terms, emojis for titles/lists, and Markdown tables for data.\n"
            "- For PROJECT_STRUCTURE_MAP, use a beautiful ascii `tree` code block.\n"
            "- For DESIGN_SYSTEM, include actual HEX color codes inside `code blocks`.\n\n"
            "3. STRICT DIRECTORY & WORKFLOW DICTATORSHIP:\n"
            "You must generate the following 24 documents in this EXACT order. NEVER skip a step:\n"
            "Phase 1: 10-CONTEXT/PROJECT_MANIFESTO.md -> 10-CONTEXT/DOMAIN_LANGUAGE.md -> 10-CONTEXT/USER_JOURNEY_MAP.md\n"
            "Phase 2: 20-REQUIREMENTS/REQUIREMENTS_MASTER.md -> 20-REQUIREMENTS/USER_STORIES_MASTER.json -> 20-REQUIREMENTS/SECURITY_PRIVACY_POLICY.md -> 20-REQUIREMENTS/COMPLIANCE_MATRIX.md\n"
            "Phase 3: 30-ARCHITECTURE/TECH_STACK_DECISION.md -> 30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.md -> 30-ARCHITECTURE/DATA_MODEL_SCHEMA.md -> 30-ARCHITECTURE/API_INTERFACE_CONTRACT.md -> 30-ARCHITECTURE/SECURITY_THREAT_MODEL.md -> 30-ARCHITECTURE/ARCH_DECISION_RECORDS.md\n"
            "Phase 4: 35-UX_UI/DESIGN_SYSTEM.md -> 35-UX_UI/UI_WIREFRAMES_FLOW.md -> 35-UX_UI/ACCESSIBILITY_GUIDE.md\n"
            "Phase 5: 40-PLANNING/ROADMAP_PHASES.md -> 40-PLANNING/DEPLOYMENT_INFRASTRUCTURE.md -> 40-PLANNING/CI_CD_PIPELINE.md -> 40-PLANNING/TESTING_STRATEGY.md\n"
            "Phase 6: 00-ROOT/RULES.md -> 00-ROOT/CONTRIBUTING.md -> 00-ROOT/AGENTS.md -> 00-ROOT/README.md\n\n"
            "Note: All files must be saved inside the 'context/' folder EXCEPT Phase 6 files (00-ROOT) which must be saved directly in the root path. USER_STORIES_MASTER.json MUST be valid JSON data wrapped in ```json.\n\n"
            "4. THE <document> TAG PURITY AND DECISION MAKING:\n"
            "Your response MUST always have two distinct parts:\n"
            "PART 1: The Chat (Outside the tag). Talk to the user naturally. For critical documents (like Architecture, Tech Stack, or UI Design), briefly list 1 or 2 alternative options you considered, with their pros/cons, and explain why you chose the one inside the document. Ask the user if they agree or wish to change it.\n"
            "PART 2: The Artifact (Inside the tag). EVERYTHING inside <document>...</document> must be ONLY the raw file content.\n"
            "The first line inside the tag MUST be: **Path:** `exact/path/to/file`\n"
            "DO NOT put conversation, greetings, or 'Next steps' inside the <document> tag.\n\n"
            "5. VALIDATION BLOCKER:\n"
            "You must work ONE document at a time. After generating a document, you MUST wait. Do NOT generate the next document until the user system sends you the exact hidden message: 'He validado y guardado el documento en...'. If the user asks for the next step but you haven't received this validation message, politely refuse and remind them to click the green 'Validar y Guardar' button.\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        )

        system_instruction = system_instruction.replace("{user_name}", user_name)

        history_section = ""
        if history and len(history) > 0:
            history_section = "\n\n📋 RECENT HISTORY:\n"
            for msg in history[-5:]:
                role_raw = msg["role"]
                content = msg["content"]
                role_prefix = "USER:" if role_raw == "user" else "SOFTARCHITECT:"
                history_section += f"{role_prefix} {content}\n"

        context_section = ""
        if template_id == "FALLBACK" or not context:
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

        user_query_section = f"\n\n❓ CURRENT REQUEST:\n{query}"

        final_prompt = (
            system_instruction + context_section + history_section + user_query_section
        )

        return final_prompt
