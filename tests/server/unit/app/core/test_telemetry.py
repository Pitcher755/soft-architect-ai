"""
Unit tests for OpenTelemetry instrumentation module (app.core.telemetry).

Tests cover:
- No-op behavior when OTEL_ENABLED=False (default)
- TracerProvider + FastAPIInstrumentor wiring when enabled
- get_tracer() returns MagicMock when disabled
- Graceful shutdown behavior
- ImportError / generic exception resilience
"""

from unittest.mock import MagicMock, patch

SETTINGS_PATH = "app.core.config.settings"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _settings_mock(otel_enabled: bool = False) -> MagicMock:
    """Return a Settings mock with OTEL_* fields."""
    s = MagicMock()
    s.OTEL_ENABLED = otel_enabled
    s.OTEL_SERVICE_NAME = "test-service"
    s.OTEL_EXPORTER_ENDPOINT = "localhost:4317"
    return s


# ---------------------------------------------------------------------------
# setup_telemetry
# ---------------------------------------------------------------------------


class TestSetupTelemetry:
    """Tests for setup_telemetry()."""

    def test_setup_disabled_is_noop(self) -> None:
        """When OTEL_ENABLED=False, setup_telemetry does nothing."""
        from app.core.telemetry import setup_telemetry

        with patch(SETTINGS_PATH, _settings_mock(False)):
            app = MagicMock()
            setup_telemetry(app)

    def test_setup_enabled_configures_provider(self) -> None:
        """When OTEL_ENABLED=True, TracerProvider and instrumentor are wired."""
        mock_trace = MagicMock()
        mock_provider_cls = MagicMock()
        mock_provider_instance = MagicMock()
        mock_provider_cls.return_value = mock_provider_instance
        mock_exporter_cls = MagicMock()
        mock_processor_cls = MagicMock()
        mock_resource_cls = MagicMock()
        mock_service_name = "SERVICE_NAME"
        mock_instrumentor = MagicMock()

        modules = {
            "opentelemetry": MagicMock(trace=mock_trace),
            "opentelemetry.trace": mock_trace,
            "opentelemetry.sdk.trace": MagicMock(TracerProvider=mock_provider_cls),
            "opentelemetry.sdk.trace.export": MagicMock(
                BatchSpanProcessor=mock_processor_cls
            ),
            "opentelemetry.sdk.resources": MagicMock(
                SERVICE_NAME=mock_service_name, Resource=mock_resource_cls
            ),
            "opentelemetry.exporter.otlp.proto.grpc.trace_exporter": MagicMock(
                OTLPSpanExporter=mock_exporter_cls
            ),
            "opentelemetry.instrumentation.fastapi": MagicMock(
                FastAPIInstrumentor=mock_instrumentor
            ),
        }

        with (
            patch(SETTINGS_PATH, _settings_mock(True)),
            patch.dict("sys.modules", modules),
        ):
            from app.core.telemetry import setup_telemetry

            app = MagicMock()
            setup_telemetry(app)

            mock_resource_cls.assert_called_once()
            mock_provider_cls.assert_called_once()
            mock_exporter_cls.assert_called_once_with(
                endpoint="localhost:4317", insecure=True
            )
            mock_trace.set_tracer_provider.assert_called_once_with(
                mock_provider_instance
            )
            mock_instrumentor.instrument_app.assert_called_once_with(app)

    def test_setup_handles_import_error(self) -> None:
        """ImportError is caught gracefully when OTel packages are missing."""
        from app.core.telemetry import setup_telemetry

        with (
            patch(SETTINGS_PATH, _settings_mock(True)),
            patch.dict("sys.modules", {"opentelemetry": None}),
        ):
            app = MagicMock()
            # Should NOT raise — caught internally
            setup_telemetry(app)


# ---------------------------------------------------------------------------
# get_tracer
# ---------------------------------------------------------------------------


class TestGetTracer:
    """Tests for get_tracer()."""

    def test_get_tracer_disabled_returns_mock(self) -> None:
        """When disabled, get_tracer returns a MagicMock no-op."""
        from app.core.telemetry import get_tracer

        with patch(SETTINGS_PATH, _settings_mock(False)):
            tracer = get_tracer("my_module")
            assert isinstance(tracer, MagicMock)

    def test_get_tracer_enabled_returns_real_tracer(self) -> None:
        """When enabled, get_tracer delegates to opentelemetry.trace.get_tracer."""
        mock_trace = MagicMock()
        expected_tracer = MagicMock()
        mock_trace.get_tracer.return_value = expected_tracer

        with (
            patch(SETTINGS_PATH, _settings_mock(True)),
            patch.dict(
                "sys.modules",
                {
                    "opentelemetry": MagicMock(trace=mock_trace),
                    "opentelemetry.trace": mock_trace,
                },
            ),
        ):
            from app.core.telemetry import get_tracer

            tracer = get_tracer("my_module")
            mock_trace.get_tracer.assert_called_once_with("my_module")
            assert tracer is expected_tracer


# ---------------------------------------------------------------------------
# shutdown_telemetry
# ---------------------------------------------------------------------------


class TestShutdownTelemetry:
    """Tests for shutdown_telemetry()."""

    def test_shutdown_disabled_is_noop(self) -> None:
        """When disabled, shutdown does nothing."""
        from app.core.telemetry import shutdown_telemetry

        with patch(SETTINGS_PATH, _settings_mock(False)):
            shutdown_telemetry()

    def test_shutdown_enabled_calls_provider_shutdown(self) -> None:
        """When enabled, shutdown calls provider.shutdown()."""
        mock_trace = MagicMock()
        mock_provider = MagicMock()
        mock_provider.shutdown = MagicMock()
        mock_trace.get_tracer_provider.return_value = mock_provider

        with (
            patch(SETTINGS_PATH, _settings_mock(True)),
            patch.dict(
                "sys.modules",
                {
                    "opentelemetry": MagicMock(trace=mock_trace),
                    "opentelemetry.trace": mock_trace,
                    "opentelemetry.sdk": MagicMock(),
                    "opentelemetry.sdk.trace": MagicMock(TracerProvider=MagicMock),
                },
            ),
        ):
            from app.core.telemetry import shutdown_telemetry

            shutdown_telemetry()
            mock_provider.shutdown.assert_called_once()

    def test_shutdown_handles_exception(self) -> None:
        """Exception during shutdown is caught gracefully."""
        mock_trace = MagicMock()
        mock_trace.get_tracer_provider.side_effect = RuntimeError("boom")

        with (
            patch(SETTINGS_PATH, _settings_mock(True)),
            patch.dict(
                "sys.modules",
                {
                    "opentelemetry": MagicMock(trace=mock_trace),
                    "opentelemetry.trace": mock_trace,
                },
            ),
        ):
            from app.core.telemetry import shutdown_telemetry

            # Should NOT raise
            shutdown_telemetry()
