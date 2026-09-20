FROM node:24-slim

WORKDIR /app

# Install git and enable pnpm
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/* \
    && corepack enable

# Clone and build DeepSeek Harness
RUN git clone https://github.com/deepseek-ai/deepseek-harness.git . \
    && pnpm install --frozen-lockfile \
    && pnpm run build

ENV HOST=0.0.0.0

EXPOSE 3000

CMD ["pnpm", "dsh", "web"]