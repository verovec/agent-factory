# DOCKERFILE-AGENT: {{ORG_NAME}}

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
VERSION: 1.0.0
AGENT_TYPE: platform
CATEGORY: platform
SCOPE: Dockerfile patterns, container image builds, and security hardening for {{ORG_NAME}}
PARENT: {{PARENT_PATH}}
```

## Linear Card Policy

Before creating or updating any Linear card, you MUST read the roadmap agent first. The roadmap owns all card rules (structure, formatting, tone, defaults, MCP usage, confidentiality). Defer to: `{{ROADMAP_PATH}}` > "Linear Card Rules".

## CRITICAL WARNING

```
THIS DOCUMENT MUST BE UPDATED WHEN:
- A new Dockerfile is added or an existing one is restructured
- Base image version changes (Python, Node, Go, etc.)
- Dependency installation strategy changes (uv, pip, npm, etc.)
- Build stage structure changes (new stages, removed stages)
- File permission or ownership patterns change
- User/group configuration changes
- Entrypoint or CMD changes
- Security hardening rules change (read-only, non-root, etc.)
- CI/CD build-push steps change
- New container registry or tagging strategy adopted
```

---

## 1. Reference Dockerfile Pattern

All Dockerfiles in this project MUST follow this structure. It is the canonical pattern derived from production Dockerfiles and security review feedback.

### 1.1 Multi-stage build

```dockerfile
FROM <base-image> AS base
# System-level setup: apt packages, env vars

FROM base AS build-python
# (or build-node, build-go, etc.)
# Dependency manager setup (uv, pip, npm, cargo, etc.)
# Copy lockfiles ONLY, install dependencies
# --frozen / --lockfile-only to ensure reproducibility

FROM base
# Final stage: no build tools, no package managers
```

### 1.2 Non-root user

Create a dedicated user and group before copying application files. Never run the application as root.

```dockerfile
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} <username> \
    && useradd -u ${USER_ID} -g ${GROUP_ID} --create-home <username>
```

### 1.3 Bind-mount copy with read-only permissions

Use `RUN --mount=type=bind` to copy dependencies and source files in a single layer. This avoids intermediate writable layers and ensures files are never editable in the final image.

```dockerfile
RUN mkdir /app && \
    chown -R ${USER_ID}:${GROUP_ID} /app && \
    chmod -R ug+rw /app

USER <username>
WORKDIR /app

RUN --mount=type=bind,from=<build-stage>,source=/app,target=/tmp/deps \
    --mount=type=bind,source=<src-context>,target=/tmp/src \
    cp -rp /tmp/deps/. /app/ && \
    cp -rp /tmp/src/. /app/ && \
    chmod -R a-w /app
```

Key rules:
- Drop to `USER` before the bind-mount RUN so the copy runs as the non-root user (the user owns `/app/`)
- `cp -rp` preserves permissions from the build stage
- `chmod -R a-w /app` removes write permission for all users in the same layer
- Files are never writable in any layer of the final image

### 1.4 PATH for virtualenv or toolchain binaries

If using a Python virtualenv, Go binary, or Node modules with bin scripts:

```dockerfile
ENV PATH="/app/.venv/bin:$PATH"
```

This ensures dependency-installed binaries (gunicorn, celery, awslambdaric, etc.) are available without absolute paths. Never copy only `site-packages` to a system path -- copy the full virtualenv so `bin/` scripts are included.

### 1.5 Entrypoint and CMD

Separate ENTRYPOINT (the runtime) from CMD (the default command). This allows overriding CMD without changing the runtime.

```dockerfile
ENTRYPOINT ["python", "-m", "awslambdaric"]
CMD ["handler.handler"]
```

Or for web services:

```dockerfile
CMD ["gunicorn", "-c", "python:config.gunicorn_conf", "app.wsgi:application"]
```

---

## 2. Security Hardening Checklist

Every Dockerfile MUST satisfy all of the following:

| Rule | How |
|------|-----|
| Non-root user | `USER <username>` before any application RUN/ENTRYPOINT |
| Read-only application files | `chmod -R a-w /app` in the same layer as the copy |
| No build tools in final image | Multi-stage build; final stage is `FROM base` without uv/pip/npm/cargo |
| No secrets in image | Never COPY `.env`, credentials, or key files; inject at runtime via env vars or secrets manager |
| Minimal apt packages | `--no-install-recommends`, clean apt cache in the same RUN |
| Pinned base image | Use specific tags (e.g. `python:3.13-slim-bookworm`), not `latest` |
| Single-layer copy | Use `RUN --mount=type=bind` instead of multiple `COPY` instructions for app files |
| No writable intermediate layers | The bind-mount pattern ensures files go from build stage to read-only in one step |

---

## 3. Dependency Installation Patterns

### 3.1 Python (uv)

```dockerfile
FROM base AS build-python
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/app/.venv

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

COPY pyproject.toml uv.lock /_lock/app/
RUN cd /_lock/app && \
    uv sync \
        --frozen \
        --no-dev \
        --no-editable \
        --no-install-project
```

- `UV_LINK_MODE=copy`: copies files instead of symlinking (required for multi-stage)
- `UV_COMPILE_BYTECODE=1`: pre-compiles .pyc for faster cold starts
- `UV_PYTHON_DOWNLOADS=never`: uses the base image Python, no extra downloads
- `--frozen`: fails if lockfile is out of date
- `--no-editable`: installs packages as regular (not editable/development) installs
- `--no-install-project`: installs dependencies only, not the project itself

### 3.2 Python (pip)

```dockerfile
FROM base AS build-python
RUN python -m venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"

COPY requirements.txt /_lock/
RUN pip install --no-cache-dir -r /_lock/requirements.txt
```

### 3.3 Node.js (npm/pnpm)

```dockerfile
FROM base AS build-node
COPY package.json package-lock.json /_lock/app/
RUN cd /_lock/app && npm ci --production
```

### 3.4 Go

```dockerfile
FROM golang:<version> AS build-go
COPY go.mod go.sum /_lock/app/
RUN cd /_lock/app && go mod download

COPY . /build/
RUN cd /build && CGO_ENABLED=0 go build -o /app/server .
```

---

## 4. Image Variants

### 4.1 Web service (long-running)

```dockerfile
CMD ["gunicorn", "-c", "python:config.gunicorn_conf", "app.wsgi:application"]
```

- Health check endpoint required
- Graceful shutdown via SIGTERM
- `stop_timeout_sec` in YAML descriptor controls ECS/K8s grace period

### 4.2 Worker (queue consumer)

```dockerfile
CMD ["celery", "-A", "app", "worker", "--loglevel=info"]
```

- Shutdown strategy: `drain-queue` for workers processing tasks that should not be interrupted
- The orchestration layer (e.g. worker-lifecycle Lambda, K8s preStop hook) manages the drain duration
- `stop_timeout_sec` is the container-level SIGTERM grace period, not the drain duration

### 4.3 Beat / scheduler

```dockerfile
CMD ["celery", "-A", "app", "beat", "--loglevel=info"]
```

- Single instance only (no horizontal scaling)
- Shutdown strategy: `rolling` (stateless, safe to kill and restart)

### 4.4 Lambda / serverless function

```dockerfile
ENTRYPOINT ["python", "-m", "awslambdaric"]
CMD ["handler.handler"]
```

- Full virtualenv copied (not just site-packages) so dependency bin scripts are available
- Same read-only + non-root pattern as long-running services
- `platforms: linux/amd64` and `provenance: false` in CI build step for Lambda compatibility

---

## 5. CI/CD Build Integration

### 5.1 GitHub Actions build-push pattern

```yaml
- name: Build and push image
  uses: docker/build-push-action@<pinned-sha> # v6
  with:
    context: <build-context-path>
    file: <path-to-Dockerfile>
    push: true
    tags: |
      <registry>/<repo>:<variant>-${{ steps.meta.outputs.tag }}
      <registry>/<repo>:<variant>-latest
    cache-from: type=gha,scope=<cache-scope>
    cache-to: type=gha,scope=<cache-scope>,mode=max
```

- Pin action SHAs, not version tags
- Use GHA cache for layer reuse across builds
- Tag with both commit SHA prefix and `latest`
- For Lambda images: add `platforms: linux/amd64` and `provenance: false`

### 5.2 Tagging convention

| Variant | Tag pattern |
|---------|-------------|
| API / web | `api-<sha8>`, `api-latest` |
| Worker | `worker-<sha8>`, `worker-latest` |
| Beat | `beat-<sha8>`, `beat-latest` |
| Lambda | `<function-name>-<sha8>`, `<function-name>-latest` |

---

## 6. Dockerfile Inventory

{{DOCKERFILE_INVENTORY}}

For each Dockerfile, document:
- Path relative to repo root
- Image variant (web, worker, beat, lambda)
- Base image and version
- Build context path
- CI workflow that builds it
- Deployed to (ECS service name, Lambda function name, K8s deployment, etc.)

---

## Cross-References

```yaml
parent: {{PARENT_PATH}}
platform_agent: {{PLATFORM_AGENT_PATH}}
application_agent: {{APPLICATION_AGENT_PATH}}
roadmap: {{ROADMAP_PATH}}
```

## Workflow

When working on Dockerfile changes:

1. Read this agent for the canonical pattern and security checklist
2. Read the **platform agent** for deployment topology and CI/CD pipeline context
3. Read the **application agent** if the change affects dependency installation or entrypoints
4. Apply the pattern from Section 1, verify against the checklist in Section 2
5. Update the Dockerfile inventory in Section 6 if a new Dockerfile was added

## Document Maintenance

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
DOCUMENT_OWNER: {{ORG_NAME}} Team
AUTHORS: [TO BE FILLED]

UPDATE_TRIGGERS:
- New Dockerfile added or existing one restructured
- Base image version changes
- Dependency installation strategy changes
- Build stage structure changes
- Security hardening rules change
- CI/CD build-push steps change
- Container registry or tagging strategy changes
- File permission or ownership patterns change
```

END_OF_DOCUMENT
