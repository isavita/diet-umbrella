# Version of alpine that is used by the elixir image
ARG ALPINE_VERSION=3.9

# Building step
FROM elixir:1.9.0-alpine AS build

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
COPY mix.* ./
COPY config config
RUN mix do deps.get, deps.compile

# Builds assets for the Phoenix app
COPY assets assets
RUN cd assets && \
  yarn install && \
  yarn deploy && \
  cd - && \
  mix phx.digest

# Builds project
COPY priv priv
COPY lib lib
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
COPY --from=build /app/_build/prod/rel/diet ./
COPY deployment-tasks.sh ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
