import logging
from collections.abc import AsyncGenerator
from typing import Any, cast

from groq import AsyncGroq

from app.infrastructure.llm.base import BaseLLMClient

logger = logging.getLogger(__name__)

# MEGA PROMPT: La ley suprema del Arquitecto
ARCHITECT_SYSTEM_PROMPT = """
Actúa como un Arquitecto de Software Principal Senior. Tu única función es transformar ideas en documentación técnica formal siguiendo el Master Workflow.

REGLAS CRÍTICAS:
1. PROHIBIDO saludar, pedir permiso o hacer preguntas aclaratorias. No digas 'Hola' ni '¿Estás de acuerdo?'.
2. Si la idea es vaga, propón la mejor arquitectura estándar (Microservicios, Cloud Native, etc.) basándote en MASTER_WORKFLOW_EXAMPLES.
3. El usuario pulsa el botón 'Refinar' si quiere cambios; tú NO pides feedback.
4. Respuesta obligatoria: [Breve razonamiento técnico de 2 párrafos] seguido de UN bloque <document>.

ESTRUCTURA DE SALIDA OBLIGATORIA:
[Razonamiento]
<document>
**Path:** [Ruta del archivo basado en 01-TEMPLATES]
[Contenido Markdown usando la estructura de la plantilla correspondiente]
</document>
""".strip()


class GroqClient(BaseLLMClient):
    def __init__(self, api_key: str):
        self.api_key = api_key
        # Modelo TOP para demo: 70b es mucho más inteligente para seguir el Workflow
        self.model = "llama-3.3-70b-versatile"
        self.client = AsyncGroq(api_key=self.api_key)
        logger.info(f"🚀 GroqClient (Architect Mode) listo con {self.model}")

    def _prepare_messages(
        self,
        prompt: str,
        history: list[dict[str, str]] | None = None,
    ) -> list[dict[str, str]]:
        """Prepara la lista de mensajes incluyendo el System Prompt y el historial."""
        messages: list[dict[str, str]] = [
            {"role": "system", "content": ARCHITECT_SYSTEM_PROMPT}
        ]
        if history:
            messages.extend(history)
        messages.append({"role": "user", "content": prompt})
        return messages

    async def generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
        **kwargs: Any,
    ) -> str:
        try:
            # Recuperamos el historial de los kwargs para mantener la memoria
            history = kwargs.get("history")
            messages = self._prepare_messages(prompt, history=history)

            response = await self.client.chat.completions.create(
                model=self.model,
                messages=cast(Any, messages),
                temperature=temperature if temperature is not None else 0.2,
                max_tokens=max_tokens if max_tokens is not None else 4096,
                stream=False,
            )
            return response.choices[0].message.content or ""
        except Exception as e:
            logger.error(f"❌ Error en Groq Generate: {str(e)}")
            raise

    async def stream_generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
        **kwargs: Any,
    ) -> AsyncGenerator[str, None]:
        """Streaming optimizado para la demo con soporte de historial."""
        try:
            # Recuperamos el historial de los kwargs para mantener la memoria
            history = kwargs.get("history")
            messages = self._prepare_messages(prompt, history=history)

            stream = await self.client.chat.completions.create(
                model=self.model,
                messages=cast(Any, messages),
                temperature=temperature if temperature is not None else 0.2,
                max_tokens=max_tokens if max_tokens is not None else 8000,
                stream=True,
            )
            async for chunk in stream:
                content = chunk.choices[0].delta.content
                if content:
                    yield content
        except Exception as e:
            logger.error(f"❌ Error en Groq Stream: {str(e)}")
            raise
