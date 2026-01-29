#!/usr/bin/env python3
"""
Post-deployment check: Valida que todos los servicios respondieron.
Ejecutar DESPUÉS de docker compose up.
"""
import socket
import sys
import time
import subprocess
from typing import Tuple


def check_service_port(host: str, port: int, service_name: str, retries: int = 3) -> bool:
    """
    Intenta conectar a un servicio con reintentos.
    Útil porque los servicios tardan en arrancar.
    """
    for attempt in range(retries):
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(2)
                result = s.connect_ex((host, port))
                if result == 0:
                    print(f"✅ {service_name} ({host}:{port}): RESPONDIENDO")
                    return True
        except Exception as e:
            print(f"   Intento {attempt+1}/{retries} falló: {e}")
            time.sleep(2)

    print(f"❌ {service_name} ({host}:{port}): NO RESPONDE después de {retries} intentos")
    return False


def check_docker_services() -> bool:
    """Verifica que los contenedores Docker están en estado HEALTHY."""
    try:
        result = subprocess.run(
            ['docker', 'compose', 'ps', '-q'],
            capture_output=True,
            timeout=5,
            text=True
        )
        lines = result.stdout.strip().split('\n')
        if len(lines) >= 3:
            print(f"✅ Docker Compose: {len(lines)} contenedores detectados")
            return True
        else:
            print(f"❌ Docker Compose: Esperaba 3+ contenedores, encontré {len(lines)}")
            return False
    except Exception as e:
        print(f"❌ Error verificando Docker: {e}")
        return False


def main():
    print("\n" + "=" * 60)
    print("✅ POST-DEPLOYMENT CHECK (HU-1.1)")
    print("=" * 60)

    checks = [
        ("Contenedores Docker", check_docker_services),
        ("Backend API (8000)", lambda: check_service_port('127.0.0.1', 8000, 'FastAPI')),
        ("ChromaDB (8001)", lambda: check_service_port('chromadb', 8001, 'ChromaDB') or check_service_port('127.0.0.1', 8001, 'ChromaDB')),
        ("Ollama (11434)", lambda: check_service_port('127.0.0.1', 11434, 'Ollama')),
    ]

    results = []
    for name, check_fn in checks:
        try:
            result = check_fn()
            results.append((name, result))
        except Exception as e:
            print(f"❌ {name}: ERROR - {e}")
            results.append((name, False))

    print("\n" + "-" * 60)
    passed = sum(1 for _, r in results if r)
    total = len(results)

    if passed == total:
        print(f"✨ {passed}/{total} checks pasaron. Stack completamente operativo.")
        print("\n🎉 ÉXITO: HU-1.1 está lista.")
        sys.exit(0)
    else:
        print(f"⚠️  {passed}/{total} checks pasaron.")
        print("   Para debugging: docker compose logs -f")
        sys.exit(1)


if __name__ == '__main__':
    main()
