FROM rust:1.72.0-bookworm AS rust-builder

WORKDIR /build

RUN apt update && apt install -y git python3 make build-essential clang cmake libsnappy-dev openssl libpq-dev pkg-config libc6 git

# Install vss-rs
# removing this and using submodules instead -- Dread
# RUN git clone -b v0.1.0 https://github.com/MutinyWallet/vss-rs
WORKDIR /build/vss-rs
COPY ./vss-rs .
RUN cargo build --release

WORKDIR /build
# Install ln-websocket-proxy
# removing this and using submodules instead -- Dread
# RUN git clone -b v0.3.1 https://github.com/MutinyWallet/ln-websocket-proxy
WORKDIR /build/ln-websocket-proxy
COPY ./ln-websocket-proxy .
RUN cargo build --release --features="server"

# Use Node.js for building the site
FROM node:20-slim AS web-builder
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

WORKDIR /app

RUN apt update && apt install -y git python3 make build-essential

# removing this and using submodules instead -- Dread
# RUN git clone --b v0.4.21 https://github.com/MutinyWallet/mutiny-web .
COPY ./mutiny-web .

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

# Install dependencies
RUN pnpm install --frozen-lockfile

# IDK why but it gets mad if you don't do this
# RUN git config --global --add safe.directory /app

# Build the static site
# RUN pnpm run build

FROM nginx:bookworm

RUN apt update && apt install -y git python3 make build-essential clang cmake libsnappy-dev openssl libpq-dev pkg-config libc6 postgresql-common postgresql-15

# Copy binaries
COPY --from=rust-builder /build/vss-rs/target/release/vss-rs /app/vss-rs
COPY --from=rust-builder /build/ln-websocket-proxy/target/release/ln_websocket_proxy /app/ln-websocket-proxy

# Copy static assets
# COPY --from=web-builder /app/dist/public /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh

EXPOSE 80

STOPSIGNAL SIGINT

ENV DATABASE_URL="postgres://postgres:docker@localhost/vss"
ENV SELF_HOST="true"
