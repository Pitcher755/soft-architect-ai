from fastapi.testclient import TestClient


def test_health_endpoint():
    from app.main import app

    with TestClient(app) as client:
        resp = client.get("/api/v1/system/health")
        assert resp.status_code == 200
        data = resp.json()
        assert data.get("status") == "OK"
        assert "version" in data
