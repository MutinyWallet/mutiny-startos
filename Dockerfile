FROM rust:1.72.0-bookworm AS rust-builder

COPY ./vss-rs ./build/vss-rs
COPY ./ln-websocket-proxy ./build/ln-websocket-proxy

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git python3 make build-essential clang cmake libsnappy-dev openssl libpq-dev pkg-config libc6 && rm -rf /var/lib/apt/lists/*

# Install vss-rs
WORKDIR /build/vss-rs
RUN cargo build --release

# Install ln-websocket-proxy
WORKDIR /build/ln-websocket-proxy
RUN cargo build --release --features="server"

# Use Node.js for building the site
FROM node:20-slim AS web-builder
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

COPY ./mutiny-web /app

WORKDIR /app

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git python3 make build-essential && rm -rf /var/lib/apt/lists/*

# This is the cooler way to run pnpm these days (no need to npm install it)
RUN corepack enable

# Add the ARG directives for build-time environment variables
ARG VITE_NETWORK="bitcoin"
ARG VITE_PROXY="/_services/proxy"
ARG VITE_ESPLORA
ARG VITE_SCORER="https://scorer.mutinywallet.com"
ARG VITE_LSP="https://lsp.voltageapi.com"
ARG VITE_RGS
ARG VITE_AUTH
ARG VITE_STORAGE="/_services/vss/v2"
ARG VITE_SELFHOSTED="true"
ARG VITE_COMMIT_HASH="unknown"

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build the static site
RUN pnpm run build

FROM nginx:bookworm

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git python3 make build-essential clang cmake libsnappy-dev openssl libpq-dev pkg-config libc6 postgresql-common postgresql-15 && rm -rf /var/lib/apt/lists/*

# Copy binaries
COPY --from=rust-builder /build/vss-rs/target/release/vss-rs /app/vss-rs
COPY --from=rust-builder /build/ln-websocket-proxy/target/release/ln_websocket_proxy /app/ln-websocket-proxy

# Copy static assets
COPY --from=web-builder /app/dist/public /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh

ADD ./check-web.sh /usr/local/bin/check-web.sh
RUN chmod +x /usr/local/bin/check-web.sh

EXPOSE 80

STOPSIGNAL SIGINT

ENV DATABASE_URL="postgres://postgres:docker@localhost/vss"
ENV SELF_HOST="true"
