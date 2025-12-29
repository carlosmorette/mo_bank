FROM elixir:1.16-alpine AS build

# Install build dependencies
RUN apk add --no-cache build-base git

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock* ./

# Install dependencies
RUN mix deps.get

# Copy config files
COPY config ./config

# Copy the rest of the application
COPY lib ./lib
COPY rel ./rel

# Build release
RUN mix release

# Start a new build stage for the final image
FROM alpine:3.18 AS app

# Install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

# Copy the release from the build stage
COPY --from=build /app/_build/dev/rel/mo_bank ./

# Set environment variables
ENV HOME=/app

# Expose port
EXPOSE 4000

# Set the entrypoint
ENTRYPOINT ["/app/bin/mo_bank"]
CMD ["start"]
