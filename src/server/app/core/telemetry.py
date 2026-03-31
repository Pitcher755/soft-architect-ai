"""
OpenTelemetry instrumentation for SoftArchitect AI backend.

Provides distributed tracing via TracerProvider, automatic FastAPI span
generation, and conditional activation via OTEL_ENABLED environment variable.

Usage:
    Called once during application startup in main.py lifespan handler.
    When OTEL_ENABLED=false (default), this module is a no-op.

Configuration (.env):
    OTEL_ENABLED: bool — Enable/disable telemetry (default: false)
    OTEL_SERVICE_NAME: str — Service name for spans (default: "softarchitect-ai")
    OTEL_EXPORTER_ENDPOINT: str — OTLP gRPC endpoint (default: "localhost:4317")
"""

import logging
from typing import Any

logger = logging.getLogger(__name__)


def setup_telemetry(app: Any) -> None:
    """Configure and start OpenTelemetry instrumentation.

    Sets up TracerProvider with OTLPSpanExporter and instruments
    the FastAPI application for automatic span generation per request.

    This function is a no-op when OTEL_ENABLED is False.

    Args:
        app: The FastAPI application instance to instrument.
    """
    from app.core.config import settings

    if not settings.OTEL_ENABLED:
        logger.info("OpenTelemetry disabled (OTEL_ENABLED=false)")
        return

    try:
        from opentelemetry import trace
        from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import (
            OTLPSpanExporter,
        )
        from opentelemetry.instrumentation.fastapi import (  # type: ignore[import-untyped]
            FastAPIInstrumentor,
        )
        from opentelemetry.sdk.resources import SERVICE_NAME, Resource
        from opentelemetry.sdk.trace import TracerProvider
        from opentelemetry.sdk.trace.export import BatchSpanProcessor

        resource = Resource(attributes={SERVICE_NAME: settings.OTEL_SERVICE_NAME})

        provider = TracerProvider(resource=resource)
        exporter = OTLPSpanExporter(
            endpoint=settings.OTEL_EXPORTER_ENDPOINT,
            insecure=True,  # Local collector, no TLS needed
        )
        provider.add_span_processor(BatchSpanProcessor(exporter))
        trace.set_tracer_provider(provider)

        FastAPIInstrumentor.instrument_app(app)

        logger.info(
            "OpenTelemetry enabled: service=%s, endpoint=%s",
            settings.OTEL_SERVICE_NAME,
            settings.OTEL_EXPORTER_ENDPOINT,
        )
    except ImportError as e:
        logger.warning("OpenTelemetry packages not available: %s", e)
    except Exception as e:
        logger.error("Failed to initialize OpenTelemetry: %s", e)


def get_tracer(name: str) -> Any:
    """Get a tracer instance for creating custom spans.

    Args:
        name: Tracer name, typically the module name.

    Returns:
        A tracer from the global TracerProvider, or a no-op tracer
        if OpenTelemetry is not enabled.
    """
    from app.core.config import settings

    if not settings.OTEL_ENABLED:
        from unittest.mock import MagicMock

        return MagicMock()

    from opentelemetry import trace

    return trace.get_tracer(name)


def shutdown_telemetry() -> None:
    """Flush and shut down the TracerProvider gracefully."""
    from app.core.config import settings

    if not settings.OTEL_ENABLED:
        return

    try:
        from opentelemetry import trace
        from opentelemetry.sdk.trace import TracerProvider as SdkTracerProvider

        provider = trace.get_tracer_provider()
        if isinstance(provider, SdkTracerProvider):
            provider.shutdown()  # type: ignore[no-untyped-call]
            logger.info("OpenTelemetry shut down gracefully")
    except Exception as e:
        logger.warning("Error shutting down OpenTelemetry: %s", e)
