import logging
from collections.abc import AsyncGenerator

from groq import AsyncGroq

from app.infrastructure.llm.base import BaseLLMClient

logger = logging.getLogger(__name__)


class GroqClient(BaseLLMClient):
    """Groq cloud LLM client implementation."""

    def __init__(self, api_key: str):
        self.api_key = api_key
        # Usamos el modelo más capaz y rápido por defecto
        self.model = "llama-3.3-70b-versatile"
        # Inicializamos el cliente asíncrono
        self.client = AsyncGroq(api_key=self.api_key)
        logger.info(
            f"🚀 GroqClient inicializado con éxito usando el modelo {self.model}"
        )

    async def generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
    ) -> str:
        """Generación completa (sin streaming)."""
        logger.debug("Generando respuesta síncrona con Groq...")
        try:
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                temperature=temperature if temperature is not None else 0.7,
                max_tokens=max_tokens if max_tokens is not None else 4096,
                stream=False,
            )
            return response.choices[0].message.content or ""
        except Exception as e:
            logger.error(f"❌ Error en GroqClient.generate: {str(e)}")
            raise e

    async def stream_generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
    ) -> AsyncGenerator[str, None]:
        """
        Generación por streaming en tiempo real para FastAPI (SSE).
        """
        logger.debug("Iniciando streaming con Groq...")
        try:
            # Petición a Groq con stream=True
            stream = await self.client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                temperature=(
                    temperature if temperature is not None else 0.5
                ),  # Un poco más bajo para mejor código/formato
                max_tokens=(
                    max_tokens if max_tokens is not None else 8000
                ),  # Necesitamos límite alto para documentos largos
                stream=True,
            )

            # Iteramos asíncronamente sobre los chunks (trocitos) que van llegando
            async for chunk in stream:
                # Extraemos el texto del delta
                content = chunk.choices[0].delta.content
                if content is not None:
                    yield content

        except Exception as e:
            logger.error(f"❌ Error en GroqClient.stream_generate: {str(e)}")
            raise e
