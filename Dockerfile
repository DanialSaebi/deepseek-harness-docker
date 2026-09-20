FROM node:24-slim

WORKDIR /app

# 1. Install system dependencies
RUN echo "==> Installing system dependencies..." \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        build-essential \
        nginx \
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
    && pnpm install \
    && echo "==> Dependencies installed."

# 4. Build
RUN echo "==> Building DeepSeek Harness..." \
    && pnpm run build \
    && echo "==> Build completed."

# 5. Configure nginx
COPY nginx.conf /etc/nginx/nginx.conf

# 6. Runtime configuration
ENV DSH_PORT=3080
ENV PORT=3000
ENV TRUSTED_HOST=localhost:3000

EXPOSE 3000

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]