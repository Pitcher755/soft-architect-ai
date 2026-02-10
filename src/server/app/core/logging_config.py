"""Structured logging configuration for application-wide logging.

This module provides JSON-formatted logging with context for better debugging
and audit trail compliance (OWASP).
"""

import json
import logging
from datetime import datetime
from typing import Any


class StructuredFormatter(logging.Formatter):
    """JSON formatter for structured logging.

    Outputs log records as JSON objects with timestamp, level, message,
    and optional context fields (operation, error_code).
    """

    def format(self, record: logging.LogRecord) -> str:
        """Format log record as JSON.

        Args:
            record: Log record to format

        Returns:
            JSON-formatted log string
        """
        log_data: dict[str, Any] = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }

        # Add optional context fields if present
        operation = getattr(record, "operation", None)
        if operation is not None:
            log_data["operation"] = operation
        error_code = getattr(record, "error_code", None)
        if error_code is not None:
            log_data["error_code"] = error_code
        user_id = getattr(record, "user_id", None)
        if user_id is not None:
            log_data["user_id"] = user_id

        # Add exception info if present (never include in production logs)
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)

        return json.dumps(log_data, ensure_ascii=False)


def setup_logging(level: int = logging.INFO) -> None:
    """Configure application logging with structured formatter.

    Args:
        level: Logging level (default: INFO)

    Example:
        >>> setup_logging(logging.DEBUG)
        >>> logger = logging.getLogger(__name__)
        >>> logger.info("Operation successful", extra={"operation": "validate"})
    """
    handler = logging.StreamHandler()
    handler.setFormatter(StructuredFormatter())

    # Configure root logger
    logging.basicConfig(
        level=level,
        handlers=[handler],
        force=True,  # Override existing configuration
    )

    # Silence noisy third-party loggers
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpcore").setLevel(logging.WARNING)
    logging.getLogger("chromadb").setLevel(logging.WARNING)
