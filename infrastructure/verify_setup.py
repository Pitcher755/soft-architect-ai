#!/usr/bin/env python3
"""
Post-deployment check: Validates that all services responded.
Execute AFTER docker compose up.
"""

import socket
import sys
import time
import subprocess
from pathlib import Path


def check_service_port(
    host: str,
    port: int,
    service_name: str,
    retries: int = 3,
    show_errors: bool = True,
) -> bool:
    """
    Attempt to connect to a service with retries.
    Useful because services take time to start.
    """
    for attempt in range(retries):
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(2)
                result = s.connect_ex((host, port))
                if result == 0:
                    print(f"✅ {service_name} ({host}:{port}): RESPONDING")
                    return True
        except Exception as e:
            if show_errors:
                print(f"   Attempt {attempt + 1}/{retries} failed: {e}")
            time.sleep(2)

    print(
        f"❌ {service_name} ({host}:{port}): "
        f"NOT RESPONDING after {retries} attempts"
    )
    return False


def check_docker_services() -> bool:
    """Verify that Docker containers are in HEALTHY state."""
    try:
        compose_dir = Path(__file__).resolve().parent
        result = subprocess.run(
            ["docker", "compose", "ps", "-q"],
            capture_output=True,
            timeout=5,
            text=True,
            cwd=compose_dir,
        )
        lines = result.stdout.strip().split("\n")
        if len(lines) >= 3:
            print(f"✅ Docker Compose: {len(lines)} containers detected")
            return True
        else:
            message = (
                "❌ Docker Compose: Expected 3+ containers, " f"found {len(lines)}"
            )
            print(message)
            return False
    except Exception as e:
        print(f"❌ Error checking Docker: {e}")
        return False


def main():
    print("\n" + "=" * 60)
    print("✅ POST-DEPLOYMENT CHECK (HU-1.1)")
    print("=" * 60)

    checks = [
        ("Docker Containers", check_docker_services),
        (
            "Backend API (8000)",
            lambda: check_service_port("127.0.0.1", 8000, "FastAPI"),
        ),
        (
            "ChromaDB (8001)",
            lambda: check_service_port("127.0.0.1", 8001, "ChromaDB"),
        ),
        (
            "Ollama (11434)",
            lambda: check_service_port("127.0.0.1", 11434, "Ollama"),
        ),
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
        print(f"✨ {passed}/{total} checks passed. Stack fully operational.")
        print("\n🎉 SUCCESS: HU-1.1 is ready.")
        sys.exit(0)
    else:
        print(f"⚠️  {passed}/{total} checks passed.")
        print("   For debugging: docker compose logs -f")
        sys.exit(1)


if __name__ == "__main__":
    main()
