from fastapi.testclient import TestClient


def test_chat_endpoint_not_implemented():
    from app.main import app

    with TestClient(app) as client:
        resp = client.post("/api/v1/chat/message")
        assert resp.status_code == 200
        assert resp.json() == {"message": "Chat endpoint not yet implemented"}


def test_knowledge_endpoint_not_implemented():
    from app.main import app

    with TestClient(app) as client:
        resp = client.get("/api/v1/knowledge/search")
        assert resp.status_code == 200
        assert resp.json() == {"message": "Knowledge search not yet implemented"}
