#!/bin/bash
# stop_stack.sh - Clean shutdown

docker compose --env-file .env -f infrastructure/docker-compose.yml down
echo "✅ Stack detenido y contenedores eliminados."
echo "💾 Los volúmenes (data) se mantienen para persistencia."
