# Multi-stage build para minimizar tamaño final
FROM python:3.12-slim AS builder

WORKDIR /app

# Instalar dependencias del sistema necesarias para compilar librerías de IA (C++/ChromaDB)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    g++ \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Instalar dependencias de Python (ahora chroma-hnswlib se podrá compilar)
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage final
FROM python:3.12-slim

WORKDIR /app

# Crear usuario no-root (seguridad)
RUN useradd -m -u 1000 appuser

# Copiar dependencias desde builder
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .

ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
    CMD python -c "import socket; socket.create_connection(('localhost', 8000), timeout=1)"

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
