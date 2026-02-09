"""
Sequential document generation orchestrator using RAG + LLM.

Orchestrates the flow of RAG-guided document generation with streaming.
"""

from collections.abc import AsyncGenerator
from typing import Any

from app.core.exceptions import LLMError, RAGError
from app.services.rag.template_loader import TemplateLoader


class SequentialOrchestrator:
    """Orchestrates RAG-guided document generation."""

    def __init__(
        self,
        vector_store: Any,
        llm_client: Any,
        template_loader: TemplateLoader | None = None,
    ):
        """
        Initialize the orchestrator.

        Args:
            vector_store: VectorStoreService instance (ChromaDB)
            llm_client: LLM client (Ollama or Groq)
            template_loader: TemplateLoader instance (or None to create default)
        """
        self.vector_store = vector_store
        self.llm_client = llm_client
        self.template_loader = template_loader or TemplateLoader()

    async def generate(
        self,
        doc_type: str,
        user_input: str,
        context: dict[str, Any],
    ) -> AsyncGenerator[str, None]:
        """
        Generate document content as streaming tokens.

        Args:
            doc_type: Type of document (e.g., "PROJECT_MANIFESTO")
            user_input: User's description/requirements
            context: Additional project context

        Yields:
            Token strings for SSE streaming

        Raises:
            RAGError: If vector store fails
            LLMError: If LLM generation fails
        """
        try:
            # 1. Load template
            template = self.template_loader.load(doc_type)

            # 2. RAG: Query vector store for relevant context
            rag_context = await self._retrieve_context(user_input, doc_type)

            # 3. Build final prompt
            prompt = self._build_prompt(template, user_input, rag_context, context)

            # 4. Stream LLM generation
            token_stream = await self.llm_client.stream_generate(prompt)
            async for token in token_stream:
                yield token

        except ConnectionError as e:
            raise RAGError(
                code="RAG_001",
                message=f"ChromaDB unavailable: {str(e)}",
            ) from e
        except TimeoutError as e:
            raise LLMError(
                code="LLM_001",
                message=f"LLM timeout: {str(e)}",
            ) from e

    async def _retrieve_context(
        self,
        query: str,
        doc_type: str,
    ) -> dict[str, Any]:
        """
        Query vector store for relevant context.

        Args:
            query: Search query
            doc_type: Document type for filtering

        Returns:
            Context dictionary with retrieved documents

        Raises:
            RAGError: If query fails
        """
        try:
            # Query vector store for relevant documents
            results = self.vector_store.query(
                query_texts=[query],
                n_results=5,
                where={"doc_type": doc_type},
            )
            return results
        except ConnectionError as e:
            raise RAGError(
                code="RAG_001",
                message=f"Failed to query vector store: {str(e)}",
            ) from e

    def _build_prompt(
        self,
        template: Any,
        user_input: str,
        rag_context: dict[str, Any],
        context: dict[str, Any],
    ) -> str:
        """
        Build final prompt from template + context.

        Args:
            template: Template object with variables
            user_input: User's input
            rag_context: Context from RAG
            context: Additional context (chat history, etc.)

        Returns:
            Final prompt string ready for LLM
        """
        # Extract documents from RAG context
        documents = ""
        if rag_context and "documents" in rag_context:
            docs_list = rag_context["documents"]
            if docs_list and len(docs_list) > 0:
                # Flatten nested lists
                flat_docs = []
                for doc_group in docs_list:
                    if isinstance(doc_group, list):
                        flat_docs.extend(doc_group)
                    else:
                        flat_docs.append(doc_group)
                documents = "\n".join(flat_docs)

        # Extract chat history from context if present
        chat_history = context.get("chat_history", "")

        # Build final prompt with template
        final_prompt = template.content.format(
            context=documents,
            user_input=user_input,
            chat_history=chat_history,
        )

        return final_prompt
