"""Tests for structured logging configuration."""

import json
import logging
import sys

from app.core.logging_config import StructuredFormatter, setup_logging


def test_structured_formatter_includes_base_fields() -> None:
    formatter = StructuredFormatter()
    record = logging.LogRecord(
        name="test.logger",
        level=logging.INFO,
        pathname=__file__,
        lineno=10,
        msg="hello",
        args=(),
        exc_info=None,
    )

    payload = json.loads(formatter.format(record))

    assert payload["level"] == "INFO"
    assert payload["logger"] == "test.logger"
    assert payload["message"] == "hello"
    assert payload["timestamp"].endswith("Z")


def test_structured_formatter_includes_optional_context_fields() -> None:
    formatter = StructuredFormatter()
    record = logging.LogRecord(
        name="ctx.logger",
        level=logging.ERROR,
        pathname=__file__,
        lineno=20,
        msg="boom",
        args=(),
        exc_info=None,
    )
    record.operation = "validate"
    record.error_code = "ERR_001"
    record.user_id = "u-123"

    payload = json.loads(formatter.format(record))

    assert payload["operation"] == "validate"
    assert payload["error_code"] == "ERR_001"
    assert payload["user_id"] == "u-123"


def test_structured_formatter_includes_exception_info() -> None:
    formatter = StructuredFormatter()

    try:
        raise ValueError("kaboom")
    except ValueError:
        exc_info = sys.exc_info()

    record = logging.LogRecord(
        name="exc.logger",
        level=logging.ERROR,
        pathname=__file__,
        lineno=30,
        msg="failed",
        args=(),
        exc_info=exc_info,
    )

    payload = json.loads(formatter.format(record))

    assert "exception" in payload
    assert "ValueError" in payload["exception"]


def test_setup_logging_configures_root_and_noise_loggers() -> None:
    setup_logging(logging.DEBUG)

    root_logger = logging.getLogger()
    assert root_logger.level == logging.DEBUG
    assert root_logger.handlers
    assert isinstance(root_logger.handlers[0].formatter, StructuredFormatter)

    assert logging.getLogger("httpx").level == logging.WARNING
    assert logging.getLogger("httpcore").level == logging.WARNING
    assert logging.getLogger("chromadb").level == logging.WARNING
