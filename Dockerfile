# Version of alpine that is used by the elixir image
ARG ALPINE_VERSION=3.9

# Building step
FROM elixir:1.10.3-alpine AS build

# Installs all the build tools
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    nodejs \
    yarn \
    git \
    build-base && \
  mix local.rebar --force && \
  mix local.hex --force

# Sets build ENV
ENV MIX_ENV=prod

# Prepares build dir
WORKDIR /app

# Installs and compiles dependencies
COPY . .
RUN mix do deps.get, deps.compile

# Builds assets for the Phoenix app
RUN cd apps/diet_web/assets && \
  yarn install && \
  yarn deploy && \
  cd ../../.. && \
  mix phx.digest

# Builds project
COPY apps/diet_web/priv ./apps/diet_web/priv
COPY apps/diet_web/lib ./apps/diet_web/lib
COPY apps/diet/priv ./apps/diet/priv
COPY apps/diet/lib ./apps/diet/lib
RUN mix compile

# Builds release
COPY rel rel
RUN mix release

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION} as application

# Install all tools that are need to run the app
RUN apk update && \
    apk add --no-cache \
      bash \
      openssl-dev \
      curl

# Prepares app dir
WORKDIR /app

# Copies the bin files
COPY --from=build /app/_build/prod/rel/web_app ./
COPY deployment-tasks.sh ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
