# syntax=docker/dockerfile:1.7

ARG NODE_VERSION=24-bookworm-slim
ARG OPENBAO_IMAGE=openbao/openbao
ARG OPENBAO_IMAGE_TAG=latest

FROM ${OPENBAO_IMAGE}:${OPENBAO_IMAGE_TAG} AS openbao_agent

FROM node:${NODE_VERSION} AS node_openbao
LABEL org.opencontainers.image.source="https://github.com/neacisu/GeniusERP_Suite"
LABEL org.opencontainers.image.description="Node.js base image with OpenBao Agent Process Supervisor tooling"

# Install tini for proper signal forwarding and basic tooling expected by Process Supervisor
RUN apt-get update \
  && apt-get install -y --no-install-recommends tini ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*

# Enable pnpm via Corepack so derived images can build monorepo targets if needed
ENV PNPM_HOME=/pnpm
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Copy the OpenBao CLI/Agent binary from the official agent image
COPY --from=openbao_agent /bin/bao /usr/local/bin/bao

# Copy the supervisor entrypoint helper
COPY shared/docker/scripts/entrypoint-supervisor.sh /usr/local/bin/entrypoint-supervisor.sh
RUN chmod +x /usr/local/bin/entrypoint-supervisor.sh \
  && mkdir -p /etc/openbao /srv/app /var/run/openbao

ENV NODE_ENV=production \
    BAO_AGENT_CONFIG=/etc/openbao/agent.hcl \
    OPENBAO_RUNTIME_DIR=/var/run/openbao \
    OPENBAO_LOG_LEVEL=info

WORKDIR /srv/app

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint-supervisor.sh"]
CMD []
