# syntax=docker/dockerfile:1.7

FROM geniuserp/node-openbao:local AS runner

ARG TRAEFIK_VERSION=3.0.0

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends apache2-utils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/traefik/traefik/releases/download/v${TRAEFIK_VERSION}/traefik_v${TRAEFIK_VERSION}_linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin traefik \
    && chmod +x /usr/local/bin/traefik

RUN mkdir -p /app/scripts /openbao/templates /run/traefik/secrets

COPY proxy/openbao/agent-config.hcl /openbao/agent-config.hcl
COPY proxy/openbao/templates/ /openbao/templates/
COPY proxy/scripts/start-traefik.sh /app/scripts/start-traefik.sh

RUN chmod +x /app/scripts/start-traefik.sh

ENV BAO_AGENT_CONFIG=/openbao/agent-config.hcl \
    TRAEFIK_DATA_DIR=/run/traefik

WORKDIR /app

ENTRYPOINT ["bao", "agent", "-config", "/openbao/agent-config.hcl"]
