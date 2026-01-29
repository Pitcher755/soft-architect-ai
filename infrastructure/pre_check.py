#!/usr/bin/env python3
"""
Pre-flight checks: Valida que el entorno HOST está listo.
Ejecutar ANTES de docker compose up.
"""
import socket
import subprocess
import sys
import platform
from pathlib import Path


def check_docker_installed():
    """¿Está Docker instalado?"""
    try:
        result = subprocess.run(['docker', '--version'], capture_output=True, timeout=5)
        if result.returncode == 0:
            print(f"✅ Docker: {result.stdout.decode().strip()}")
            return True
    except FileNotFoundError:
        print("❌ Docker NO está instalado. Por favor instala Docker Desktop.")
        return False


def check_docker_running():
    """¿Está Docker daemon corriendo?"""
    try:
        subprocess.run(['docker', 'info'], capture_output=True, timeout=5)
        print("✅ Docker daemon: CORRIENDO")
        return True
    except Exception as e:
        print(f"❌ Docker daemon: NO RESPONDE. Error: {e}")
        print("   Inicia Docker Desktop o el servicio docker.")
        return False


def check_compose_running():
    """¿Están los servicios de Docker Compose activos? (solo informativo)"""
    try:
        result = subprocess.run(
            ['docker', 'ps', '--filter', 'name=sa_', '--format', '{{.Names}}'],
            capture_output=True,
            timeout=5,
        )
        names = result.stdout.decode().strip().splitlines()
        if names:
            print("✅ Docker Compose: servicios activos")
        else:
            print("⚠️  Docker Compose: servicios NO activos (se levantarán en GREEN)")
        return True
    except Exception as e:
        print(f"⚠️  Docker Compose: no se pudo verificar. Error: {e}")
        return True


def check_port_available(port, service_name, allow_in_use=False):
    """¿Está el puerto disponible?"""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(1)
            result = s.connect_ex(('127.0.0.1', port))
            if result != 0:
                print(f"✅ Puerto {port} ({service_name}): DISPONIBLE")
                return True
            if allow_in_use:
                print(f"⚠️  Puerto {port} ({service_name}): EN USO (servicios activos)")
                return True
            print(f"❌ Puerto {port} ({service_name}): YA ESTÁ EN USO")
            print(f"   Ejecuta: sudo lsof -i :{port} (Linux/Mac)")
            return False
    except Exception as e:
        print(f"⚠️  Error verificando puerto {port}: {e}")
        return False


def check_env_file():
    """¿Existe .env? Si no, lo crea desde .env.example"""
    env_path = Path('.env')
    env_example = Path('.env.example')

    if env_path.exists():
        print("✅ .env: EXISTE")
        return True
    elif env_example.exists():
        print("⚠️  .env NO existe, pero .env.example SÍ")
        print("   Crearé .env automáticamente durante docker compose up")
        return True
    else:
        print("❌ Ni .env ni .env.example existen")
        return False


def main():
    print("\n" + "=" * 60)
    print("🔍 PRE-FLIGHT CHECK (HU-1.1)")
    print("=" * 60)

    compose_running = check_compose_running()

    checks = [
        ("Docker instalado", check_docker_installed),
        ("Docker daemon activo", check_docker_running),
        ("Docker Compose activo", lambda: compose_running),
        ("Puerto 8000 (API) disponible", lambda: check_port_available(8000, "FastAPI", allow_in_use=compose_running)),
        ("Puerto 8001 (ChromaDB) disponible", lambda: check_port_available(8001, "ChromaDB", allow_in_use=compose_running)),
        ("Puerto 11434 (Ollama) disponible", lambda: check_port_available(11434, "Ollama", allow_in_use=compose_running)),
        ("Variables de entorno", check_env_file),
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
        print(f"✨ {passed}/{total} checks pasaron. Listo para docker compose up.")
        sys.exit(0)
    else:
        print(f"🛑 {passed}/{total} checks pasaron. Soluciona los errores arriba.")
        sys.exit(1)


if __name__ == '__main__':
    main()
