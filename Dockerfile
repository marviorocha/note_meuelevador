ARG RUBY_VERSION=3.2.8
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Dependências de execução (Runtime)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libpq-dev libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# --- Estágio de Build ---
FROM base AS build

# Instala Node.js 20 e dependências de compilação
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl ca-certificates gnupg build-essential git libyaml-dev pkg-config && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Instala Gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copia o código
COPY . .

# Instala pacotes JS e compila assets
RUN npm install

# Precompila o bootsnap para velocidade
RUN bundle exec bootsnap precompile app/ lib/

# COMPILAÇÃO VITE (Com Secret Key temporária para evitar erro de inicialização)
RUN rm -rf public/vite && \
    SECRET_KEY_BASE=dummy_key_for_build RAILS_ENV=production ./bin/vite build

# --- Estágio Final ---
FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Ajuste de permissões e usuário
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp public

USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/thrust", "./bin/rails", "server"]
