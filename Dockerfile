ARG RUBY_VERSION=3.2.8
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# 1. Dependências de execução (Runtime) comuns a produção
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libpq-dev libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Configurações globais de ambiente
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# --- Estágio de Build ---
FROM base AS build

# 2. Instala ferramentas de compilação e configura repositório oficial do Node 20
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl ca-certificates gnupg build-essential git libyaml-dev pkg-config && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 3. Instala as Gems primeiro (ótimo para aproveitar o cache do Docker se o Gemfile não mudar)
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# 4. Instala os pacotes do Node.js separadamente para aproveitar o cache
COPY package.json package-lock.json* ./
RUN npm install && npm cache clean --force

# 5. COPIA TODO O CÓDIGO FONTE
COPY . .

# 6. Precompila o bootsnap do projeto
RUN bundle exec bootsnap precompile app/ lib/

# 7. Compila os assets do Vite (com a chave dummy para evitar o travamento de inicialização do Rails)
RUN rm -rf public/vite && \
    SECRET_KEY_BASE=dummy_key_for_build RAILS_ENV=production bundle exec vite build

# --- Estágio Final (Imagem leve de produção) ---
FROM base

# Copia as dependências e arquivos gerados no estágio anterior
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Cria o usuário não-root para rodar a aplicação com segurança e ajusta permissões
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp public

USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/thrust", "./bin/rails", "server"]
