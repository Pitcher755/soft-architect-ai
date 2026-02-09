import shutil
from pathlib import Path

from app.core import database


def test_init_chromadb_creates_path(tmp_path, monkeypatch):
    # Run in tmp_path to avoid polluting repo
    monkeypatch.chdir(tmp_path)
    p = database.init_chromadb()
    assert isinstance(p, Path)
    assert p.name == "chromadb"
    # cleanup
    shutil.rmtree(tmp_path / "data")


def test_init_sqlite_returns_sqlite_url(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    url = database.init_sqlite()
    assert url.startswith("sqlite:///")
    # the file path should include data/softarchitect.db
    assert "data/softarchitect.db" in url
    shutil.rmtree(tmp_path / "data")
