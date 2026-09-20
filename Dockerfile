FROM node:24-slim

WORKDIR /app

# 1. Install system dependencies
RUN echo "==> Installing system dependencies..." \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates \
    && npm install -g pnpm@11.7.0 \
    && echo "==> System dependencies installed."

# 2. Clone DeepSeek Harness
RUN echo "==> Cloning DeepSeek Harness..." \
    && git clone --depth 1 https://github.com/deepseek-ai/deepseek-harness.git . \
    && echo "==> DeepSeek Harness cloned."

# 3. Install dependencies
RUN echo "==> Installing pnpm dependencies..." \
    && which pnpm \
    && pnpm --version \
    && pnpm config set fetch-timeout 600000 \
    && pnpm config set fetch-retries 5 \
    && pnpm config set fetch-retry-factor 2 \
    && pnpm config set fetch-retry-mintimeout 10000 \
    && pnpm config set fetch-retry-maxtimeout 120000 \
    && pnpm install --include=optional \
    && echo "==> Dependencies installed."

# 4. Build
RUN echo "==> Building DeepSeek Harness..." \
    && pnpm run build \
    && echo "==> Build completed."

# Runtime configuration
ENV HOST=0.0.0.0

EXPOSE 3000

# Start DeepSeek Harness web UI
CMD ["pnpm", "dsh", "web"]