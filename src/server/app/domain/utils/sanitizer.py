"""Input sanitization utilities for HU-4.1 Chat security.

Provides defense-in-depth security for user input:
- HTML entity escaping (XSS prevention + code preservation)
- Prompt injection pattern detection (logging, not blocking)
- Developer Tool Trap fix (html.escape vs regex)

CRITICAL: This module enforces the "Developer Tool Trap" fix.
NEVER use regex to strip HTML tags - this destroys code snippets.
ALWAYS use html.escape() to preserve structure while preventing XSS.

Author: ArchitectZero
Created: 2025-01-08
Version: 0.1.0 (Phase 1 - GREEN)
"""

import logging
import re
from html import escape

logger = logging.getLogger(__name__)


class InputSanitizer:
    """Sanitizer for user input with security hardening.

    Security Features:
    - HTML entity escaping (XSS prevention)
    - Code snippet preservation (Developer Tool Trap fix)
    - Prompt injection detection (logging)

    Design Philosophy:
    - Defense in Depth: Multiple layers of validation
    - Non-Blocking: Detection logs warnings but doesn't reject input
    - Transparency: Returns sanitized input with audit trail
    """

    # Prompt injection patterns (regex, case-insensitive)
    PROMPT_INJECTION_PATTERNS = [
        r"ignore\s+(previous|all|above)\s+(instructions|prompts)",
        r"you\s+are\s+now\s+(a\s+different|in|acting\s+as)",
        r"system\s*:",
        r"new\s+(instructions|system\s+prompt|role)",
        r"\/\/\s*(system|admin|root)",
        r"<\|.*?\|>",  # ChatGPT-style system prompt injection
        r"###\s*(instructions|system|prompt)",
    ]

    @staticmethod
    def sanitize_html(text: str) -> str:
        """Escape HTML entities to prevent XSS while preserving code structure.

        CRITICAL: Uses html.escape() to preserve code snippets.
        NEVER use re.sub(r'<[^>]+>', '', text) - destroys "List<String>".

        Examples:
            >>> sanitize_html("<script>alert(1)</script>")
            "&lt;script&gt;alert(1)&lt;/script&gt;"

            >>> sanitize_html("List<String> myList")
            "List&lt;String&gt; myList"

        Args:
            text: Raw user input

        Returns:
            str: HTML-escaped text (preserves code structure)
        """
        return escape(text)

    @staticmethod
    def detect_prompt_injection(text: str) -> str | None:
        """Detect prompt injection patterns in user input.

        Non-blocking: Returns pattern match for logging, doesn't raise exception.

        Args:
            text: User input to analyze

        Returns:
            Optional[str]: Matched pattern (for logging) or None
        """
        for pattern in InputSanitizer.PROMPT_INJECTION_PATTERNS:
            match = re.search(pattern, text, re.IGNORECASE | re.MULTILINE)
            if match:
                logger.warning(
                    f"Prompt injection detected: pattern='{pattern}', "
                    f"matched='{match.group()}', input_length={len(text)}"
                )
                return pattern

        return None

    @staticmethod
    def sanitize_message(text: str) -> str:
        """Full sanitization pipeline for user messages.

        Pipeline:
        1. Strip leading/trailing whitespace
        2. HTML entity escaping (XSS prevention + code preservation)
        3. Prompt injection detection (logging only)

        Args:
            text: Raw user message

        Returns:
            str: Sanitized message (safe for RAG processing)
        """
        # Step 1: Strip whitespace
        text = text.strip()

        # Step 2: HTML entity escaping (CRITICAL: preserves code)
        text = InputSanitizer.sanitize_html(text)

        # Step 3: Prompt injection detection (defense in depth)
        detected_pattern = InputSanitizer.detect_prompt_injection(text)
        if detected_pattern:
            logger.warning(
                f"User input flagged for prompt injection: " f"pattern='{detected_pattern}', length={len(text)}"
            )

        return text


# Version metadata
__version__ = "0.1.0-phase1-green"
__status__ = "Production (Phase 1 GREEN implementation)"
