"""Test coverage for metrics collector module.

Validates performance metric recording, aggregation, and statistics.

IMPORTANT: MetricsCollector is a Singleton. Tests must clear state or run
in isolation to avoid test interference. Using fixture-scoped cleanup.

Author: ArchitectZero
Created: 2026-02-10
"""

import pytest

from app.core.performance.metrics_collector import MetricsCollector


@pytest.fixture
def metrics_collector() -> MetricsCollector:
    """Create metrics collector instance and reset before each test."""
    collector = MetricsCollector()
    # Reset state before test - note: design allows this for testing
    collector.total_tokens_sent = 0
    collector.total_connections = 0
    collector.failed_connections = 0
    collector.latency.ttfb_samples_ms.clear()
    collector.latency.token_latencies_ms.clear()
    return collector


# === METRIC RECORDING TEST SUITE ===


def test_record_token_sent_increments_counter(
    metrics_collector: MetricsCollector,
) -> None:
    """Should increment token counter when token sent."""
    metrics_collector.record_token_sent(50.0)

    assert metrics_collector.total_tokens_sent == 1


def test_record_multiple_tokens(metrics_collector: MetricsCollector) -> None:
    """Should record multiple token transmissions."""
    metrics_collector.record_token_sent(50.0)
    metrics_collector.record_token_sent(60.0)
    metrics_collector.record_token_sent(55.0)

    assert metrics_collector.total_tokens_sent == 3


def test_record_connection_success(metrics_collector: MetricsCollector) -> None:
    """Should increment successful connection counter."""
    metrics_collector.record_connection_success()

    assert metrics_collector.total_connections == 1


def test_record_connection_failure(metrics_collector: MetricsCollector) -> None:
    """Should increment failed connection counter."""
    metrics_collector.record_connection_failure()

    assert metrics_collector.failed_connections == 1


# === SUMMARY STATISTICS TEST SUITE ===


def test_get_summary_with_no_activity(metrics_collector: MetricsCollector) -> None:
    """Should return zero summary when no activity recorded."""
    summary = metrics_collector.get_summary()

    assert summary["total_tokens"] == 0
    assert summary["total_connections"] == 0
    assert summary["failed_connections"] == 0
    assert summary["success_rate"] == 0.0


def test_get_summary_success_rate_all_success(
    metrics_collector: MetricsCollector,
) -> None:
    """Should calculate 100% success rate when all connections succeed."""
    for _ in range(10):
        metrics_collector.record_connection_success()

    summary = metrics_collector.get_summary()

    assert summary["total_connections"] == 10
    assert summary["failed_connections"] == 0
    assert summary["success_rate"] == 100.0


def test_get_summary_success_rate_mixed(metrics_collector: MetricsCollector) -> None:
    """Should calculate success rate with mixed results."""
    for _ in range(8):
        metrics_collector.record_connection_success()
    for _ in range(2):
        metrics_collector.record_connection_failure()

    summary = metrics_collector.get_summary()

    assert summary["total_connections"] == 8
    assert summary["failed_connections"] == 2
    assert summary["success_rate"] == 80.0


def test_get_summary_all_failed(metrics_collector: MetricsCollector) -> None:
    """Should calculate 0% success rate when all connections fail."""
    for _ in range(5):
        metrics_collector.record_connection_failure()

    summary = metrics_collector.get_summary()

    assert summary["total_connections"] == 0
    assert summary["failed_connections"] == 5
    assert summary["success_rate"] == 0.0


# === TOKEN LATENCY TEST SUITE ===


def test_avg_token_latency_calculation(metrics_collector: MetricsCollector) -> None:
    """Should calculate average token latency correctly."""
    metrics_collector.record_token_sent(10.0)
    metrics_collector.record_token_sent(20.0)
    metrics_collector.record_token_sent(30.0)

    summary = metrics_collector.get_summary()

    # (10 + 20 + 30) / 3 = 20
    assert summary["avg_token_latency_ms"] == 20.0


# === TTFB MEASUREMENT TEST SUITE ===


def test_ttfb_measurement_context_manager(
    metrics_collector: MetricsCollector,
) -> None:
    """Should measure TTFB using context manager."""
    import time

    with metrics_collector.measure_ttfb():
        time.sleep(0.01)  # 10ms

    summary = metrics_collector.get_summary()
    # p95 should be around 10ms or more
    assert summary["ttfb_p95_ms"] > 8.0


def test_summary_format_is_valid_dict(metrics_collector: MetricsCollector) -> None:
    """Should return summary in expected dictionary format."""
    metrics_collector.record_connection_success()
    metrics_collector.record_token_sent(50.0)

    summary = metrics_collector.get_summary()

    assert isinstance(summary, dict)
    assert "ttfb_p95_ms" in summary
    assert "avg_token_latency_ms" in summary
    assert "total_tokens" in summary
    assert "total_connections" in summary
    assert "failed_connections" in summary
    assert "success_rate" in summary
