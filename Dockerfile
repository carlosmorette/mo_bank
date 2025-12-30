FROM elixir:1.16-alpine

# Dependências do sistema
RUN apk add --no-cache build-base git nodejs npm

WORKDIR /app

# Instala hex e rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copia arquivos de dependência
COPY mix.exs mix.lock* ./

# Instala deps
RUN mix deps.get

# Copia o resto do projeto
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY assets ./assets

# Compila assets (opcional, mas recomendado)
RUN mix assets.deploy || true

# Expõe a porta do Phoenix
EXPOSE 4000

# DEV de verdade
CMD ["mix", "phx.server"]
