#!/bin/sh
set -e

echo "==> Starting DeepSeek Harness..."
echo "    Internal address: 127.0.0.1:${DSH_PORT}"
echo "    Trusted host: ${TRUSTED_HOST}"

pnpm dsh web \
    --no-open \
    --port "${DSH_PORT}" \
    --trusted-host "${TRUSTED_HOST}" &

DSH_PID=$!

echo "==> DeepSeek Harness started with PID ${DSH_PID}"

echo "==> Starting nginx on 0.0.0.0:${PORT}..."

nginx -g "daemon off;" &
NGINX_PID=$!

cleanup() {
    echo "==> Stopping services..."
    kill "$DSH_PID" 2>/dev/null || true
    kill "$NGINX_PID" 2>/dev/null || true
}

trap cleanup INT TERM EXIT

wait "$DSH_PID"