# Node + OpenBao Base Image

`shared/docker/node-openbao.Dockerfile` defines the unified runtime requested in F0.5.13. It extends the official `node:<VERSION>` image, copies the `bao` binary from `openbao/agent`, installs `tini`, and exposes a small entrypoint that launches the OpenBao Process Supervisor.

## Build

```bash
# From repo root
docker build \
  -f shared/docker/node-openbao.Dockerfile \
  -t geniuserp/node-openbao:local .
```

### Build args

| Arg | Default | Purpose |
| --- | --- | --- |
| `NODE_VERSION` | `24-bookworm-slim` | Keeps Node in sync with monorepo toolchain. |
| `OPENBAO_IMAGE` | `openbao/openbao` | Image that contains the `bao` binary (defaults to server image until agent image is published). |
| `OPENBAO_IMAGE_TAG` | `latest` | Tag used for the `OPENBAO_IMAGE`. |

## Runtime behaviour

- The container entrypoint is `/usr/bin/tini -- entrypoint-supervisor.sh`.
- If you run the image with a custom command (`docker run image bash`), the script forwards it untouched.
- With no arguments, it expects `BAO_AGENT_CONFIG` (default `/etc/openbao/agent.hcl`) to exist and then executes:

```bash
bao agent -log-level="$OPENBAO_LOG_LEVEL" -config="$BAO_AGENT_CONFIG"
```

Derived services should copy their Process Supervisor config (and templates) into `/etc/openbao/` or mount them via Compose.

## Example validation

```bash
IMAGE=geniuserp/node-openbao:local

docker run --rm --entrypoint bao "$IMAGE" --version
docker run --rm --entrypoint node "$IMAGE" --version
```

Both commands must succeed before promoting the image to application Dockerfiles.
