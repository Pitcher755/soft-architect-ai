from fastapi import APIRouter
from fastapi.testclient import TestClient


def test_value_error_handler_triggers():
    """Endpoint that raises ValueError should be handled with 400."""
    from app.main import app

    router = APIRouter()

    @router.get("/raise-value")
    def raise_value():
        raise ValueError("bad input")

    # Referencia explícita para evitar advertencias del analizador estático
    _ = raise_value

    app.include_router(router)

    with TestClient(app, raise_server_exceptions=False) as client:
        resp = client.get("/raise-value")
        assert resp.status_code == 400
        assert resp.json().get("detail") == "bad input"


def test_general_exception_handler_triggers():
    """Endpoint that raises Exception should be handled with 500 and generic message."""
    from app.main import app

    router = APIRouter()

    @router.get("/raise-exc")
    def raise_exc():
        raise RuntimeError("boom")

    # Referencia explícita para evitar advertencias del analizador estático
    _ = raise_exc

    app.include_router(router)

    with TestClient(app, raise_server_exceptions=False) as client:
        resp = client.get("/raise-exc")
        assert resp.status_code == 500
        assert resp.json().get("detail") == "Internal server error"
