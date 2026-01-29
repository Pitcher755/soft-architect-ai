from pathlib import Path

import pytest


@pytest.mark.asyncio
async def test_startup_event_local(monkeypatch, caplog):
    """Startup should log Ollama URL when provider is local."""
    import app.main as main_mod

    # Monkeypatch database inits to avoid filesystem side-effects
    monkeypatch.setattr(main_mod, "init_chromadb", lambda: Path("/tmp/chromadb"))
    monkeypatch.setattr(main_mod, "init_sqlite", lambda: "sqlite:////tmp/db")

    # Ensure settings reflect local provider
    from app.core import config

    monkeypatch.setattr(config.settings, "LLM_PROVIDER", "local")
    monkeypatch.setattr(config.settings, "OLLAMA_BASE_URL", "http://ollama:11434")

    caplog.clear()
    caplog.set_level("INFO")

    await main_mod.startup_event()

    logs = "\n".join([r.getMessage() for r in caplog.records])
    assert "LLM Provider: local" in logs
    assert "Ollama URL" in logs


@pytest.mark.asyncio
async def test_startup_event_cloud(monkeypatch, caplog):
    """Startup should log Groq Cloud when provider is cloud."""
    import app.main as main_mod

    monkeypatch.setattr(main_mod, "init_chromadb", lambda: Path("/tmp/chromadb"))
    monkeypatch.setattr(main_mod, "init_sqlite", lambda: "sqlite:////tmp/db")

    from app.core import config

    monkeypatch.setattr(config.settings, "LLM_PROVIDER", "cloud")

    caplog.clear()
    caplog.set_level("INFO")

    await main_mod.startup_event()

    logs = "\n".join([r.getMessage() for r in caplog.records])
    assert "LLM Provider: cloud" in logs
    assert "Groq Cloud provider configured" in logs


@pytest.mark.asyncio
async def test_shutdown_event_logs(monkeypatch, caplog):
    import app.main as main_mod
    from app.core import config

    caplog.clear()
    caplog.set_level("INFO")

    await main_mod.shutdown_event()

    logs = "\n".join([r.getMessage() for r in caplog.records])
    assert f"Shutting down {config.settings.APP_NAME}" in logs
