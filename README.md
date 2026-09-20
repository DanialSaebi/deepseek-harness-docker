# DeepSeek Harness Docker

Docker setup for running [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness).

This repository provides a simple way to build and run DeepSeek Harness in a Docker container without installing Node.js, pnpm, or the project dependencies on the host machine.

## Features

* Based on `node:24-slim`
* Automatically clones the official DeepSeek Harness repository
* Installs dependencies with pnpm
* Builds DeepSeek Harness during the Docker image build
* Runs the DeepSeek Harness web interface
* Configurable host port
* Persistent container restart policy
* Docker log rotation to prevent unlimited log growth

## Requirements

* Docker
* Docker Compose

Check your Docker installation:

```bash
docker --version
docker compose version
```

## Quick Start

Clone this repository:

```bash
git clone https://github.com/YOUR_USERNAME/deepseek-harness-docker.git
cd deepseek-harness-docker
```

Build and start the container:

```bash
docker compose up --build -d
```

The web interface will be available at:

```text
http://localhost:3000
```

## Configure the Port

The host port can be changed using the `PORT` environment variable.

For example, to expose the application on port `8080`:

```bash
PORT=8080 docker compose up --build -d
```

The application will then be available at:

```text
http://localhost:8080
```

You can also create a `.env` file:

```env
PORT=8080
```

Then simply run:

```bash
docker compose up --build -d
```

### Important

`PORT` controls the **host port**.

The application inside the container continues to listen on port `3000`.

For example:

```text
Host                         Container
────────────────────────────────────────
localhost:8080  ──────────>  0.0.0.0:3000
```

This allows you to change the externally accessible port without rebuilding the image.

## Docker Compose Configuration

The default `compose.yaml` looks like this:

```yaml
services:
  deepseek-harness:
    build: .
    container_name: deepseek-harness

    ports:
      - "${PORT:-3000}:3000"

    restart: unless-stopped

    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
```

If `PORT` is not specified, port `3000` is used.

Therefore:

```bash
docker compose up -d
```

is equivalent to:

```bash
PORT=3000 docker compose up -d
```

## Log Rotation

Docker logs are configured with rotation to prevent the container from filling the disk.

The default configuration is:

```yaml
logging:
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"
```

This means:

* Maximum size of each log file: `10 MB`
* Maximum number of log files: `3`
* Old log files are automatically rotated

The maximum retained container logs are therefore approximately `30 MB`.

View logs:

```bash
docker compose logs -f
```

View the last 100 lines:

```bash
docker compose logs --tail=100
```

## Start and Stop

Start the container:

```bash
docker compose up -d
```

Start and rebuild the image:

```bash
docker compose up --build -d
```

Stop the container:

```bash
docker compose down
```

Restart the container:

```bash
docker compose restart
```

Check the container status:

```bash
docker compose ps
```

## Updating DeepSeek Harness

The Dockerfile clones the DeepSeek Harness repository during the image build.

To get the latest version from the upstream repository:

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

Or:

```bash
docker compose up --build -d
```

If Docker reuses cached build layers and you want to force a fresh clone:

```bash
docker compose build --no-cache
docker compose up -d
```

## Building the Image Manually

You can also build the Docker image without Docker Compose:

```bash
docker build -t deepseek-harness .
```

Run it:

```bash
docker run -d \
  --name deepseek-harness \
  -p 3000:3000 \
  --restart unless-stopped \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  deepseek-harness
```

To use another host port:

```bash
docker run -d \
  --name deepseek-harness \
  -p 8080:3000 \
  --restart unless-stopped \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  deepseek-harness
```

The application will then be available at:

```text
http://localhost:8080
```

## Project Structure

```text
deepseek-harness-docker/
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── .gitignore
└── README.md
```

## Docker Image

The image uses:

```dockerfile
FROM node:24-slim
```

Git is installed in the image because the upstream DeepSeek Harness repository is cloned during the build.

The build process performs:

```text
git clone
    ↓
pnpm install
    ↓
pnpm run build
    ↓
pnpm dsh web
```

## Upstream Project

This Docker setup is for:

**DeepSeek Harness**

https://github.com/deepseek-ai/deepseek-harness

Please refer to the upstream project for information about its functionality, configuration, development, and licensing.

## License

This repository contains Docker configuration for running the upstream DeepSeek Harness project.

The DeepSeek Harness project and its source code remain subject to their respective license and terms.

See the upstream repository for the applicable license:

https://github.com/deepseek-ai/deepseek-harness

## Disclaimer

This repository is an independent Docker setup and is not affiliated with or endorsed by DeepSeek unless explicitly stated by the upstream project.
