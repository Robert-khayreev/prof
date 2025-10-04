# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t prof .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name prof prof

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.2.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages including PostgreSQL client libraries
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libpq5 libvips postgresql-client sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and PostgreSQL
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Create a debug script to check environment variables
RUN echo '#!/bin/bash' > /rails/bin/debug-env && \
    echo 'echo "=== ENVIRONMENT VARIABLES DEBUG ==="' >> /rails/bin/debug-env && \
    echo 'echo "Total env vars: $(env | wc -l)"' >> /rails/bin/debug-env && \
    echo 'echo "RAILWAY_* vars:"' >> /rails/bin/debug-env && \
    echo 'env | grep "^RAILWAY_" | sort || echo "No RAILWAY_* variables found"' >> /rails/bin/debug-env && \
    echo 'echo "DATABASE_URL: ${DATABASE_URL:+[SET]}${DATABASE_URL:-[NOT SET]}"' >> /rails/bin/debug-env && \
    echo 'echo "RAILS_ENV: ${RAILS_ENV:-[NOT SET]}"' >> /rails/bin/debug-env && \
    echo 'echo "PORT: ${PORT:-[NOT SET]}"' >> /rails/bin/debug-env && \
    echo 'echo "RAILS_MASTER_KEY: ${RAILS_MASTER_KEY:+[SET]}${RAILS_MASTER_KEY:-[NOT SET]}"' >> /rails/bin/debug-env && \
    echo 'echo "=== ALL ENV VARS ==="' >> /rails/bin/debug-env && \
    echo 'env | sort' >> /rails/bin/debug-env && \
    chmod +x /rails/bin/debug-env

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile




# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
