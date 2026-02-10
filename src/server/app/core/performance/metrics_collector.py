"""
Performance metrics collector for streaming operations.

Tracks latency, throughput, and connection stability metrics
using time-series counters.
"""

from __future__ import annotations

import time
from dataclasses import dataclass, field
from typing import Any


@dataclass
class LatencyMetrics:
    """Container for latency measurements."""

    ttfb_samples_ms: list[float] = field(default_factory=list)
    token_latencies_ms: list[float] = field(default_factory=list)
    reconnection_times_ms: list[float] = field(default_factory=list)

    def add_ttfb(self, latency_ms: float) -> None:
        """Record TTFB sample."""
        self.ttfb_samples_ms.append(latency_ms)

    def add_token_latency(self, latency_ms: float) -> None:
        """Record inter-token latency sample."""
        self.token_latencies_ms.append(latency_ms)

    def add_reconnection(self, duration_ms: float) -> None:
        """Record reconnection duration sample."""
        self.reconnection_times_ms.append(duration_ms)

    def get_p95_ttfb(self) -> float:
        """Get 95th percentile TTFB in ms."""
        if not self.ttfb_samples_ms:
            return 0.0
        sorted_samples = sorted(self.ttfb_samples_ms)
        index = min(int(len(sorted_samples) * 0.95), len(sorted_samples) - 1)
        return sorted_samples[index]

    def get_avg_token_latency(self) -> float:
        """Get average inter-token latency in ms."""
        if not self.token_latencies_ms:
            return 0.0
        return sum(self.token_latencies_ms) / len(self.token_latencies_ms)


class MetricsCollector:
    """Singleton metrics collector for streaming performance."""

    _instance: MetricsCollector | None = None

    def __new__(cls) -> MetricsCollector:
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance

    def __init__(self) -> None:
        if self._initialized:
            return

        self.latency = LatencyMetrics()
        self.total_tokens_sent: int = 0
        self.total_connections: int = 0
        self.failed_connections: int = 0
        self._initialized = True

    def measure_ttfb(self) -> _TTFBMeasurement:
        """Create context manager for measuring TTFB."""
        return _TTFBMeasurement(self)

    def record_token_sent(self, latency_ms: float) -> None:
        """Record token transmission with latency."""
        self.total_tokens_sent += 1
        self.latency.add_token_latency(latency_ms)

    def record_connection_success(self) -> None:
        """Record successful connection."""
        self.total_connections += 1

    def record_connection_failure(self) -> None:
        """Record failed connection."""
        self.failed_connections += 1

    def get_summary(self) -> dict[str, Any]:
        """Get performance summary report."""
        total = self.total_connections + self.failed_connections
        success_rate = (self.total_connections / total * 100.0) if total else 0.0
        return {
            "ttfb_p95_ms": round(self.latency.get_p95_ttfb(), 2),
            "avg_token_latency_ms": round(self.latency.get_avg_token_latency(), 2),
            "total_tokens": self.total_tokens_sent,
            "total_connections": self.total_connections,
            "failed_connections": self.failed_connections,
            "success_rate": round(success_rate, 2),
        }


class _TTFBMeasurement:
    """Internal context manager for TTFB measurement."""

    def __init__(self, collector: MetricsCollector) -> None:
        self.collector = collector
        self.start_time: float | None = None

    def __enter__(self) -> _TTFBMeasurement:
        self.start_time = time.perf_counter()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        if self.start_time is not None:
            elapsed_ms = (time.perf_counter() - self.start_time) * 1000
            self.collector.latency.add_ttfb(elapsed_ms)
