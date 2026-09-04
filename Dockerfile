# This template builds 2 images, to optimise caching:
# rails-build: builds gems and node modules
# rails-app: runs the actual app

# Build rails-build image
FROM ruby:4.0.6-alpine3.23 AS rails-build

ENV APP_HOME=/app
ENV DOCS_HOME=$APP_HOME/tech_docs

WORKDIR $APP_HOME

# Add the timezone as it's not configured by default in Alpine
RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

COPY .tool-versions Gemfile Gemfile.lock ./

# Install gems
RUN apk add --update --no-cache --virtual build-dependencies \
      build-base \
      cmake \
      g++ \
      git \
      icu-dev \
      libc6-compat \
      libxml2-dev \
      libxslt-dev \
      linux-headers \
      npm \
      pkgconf \
      postgresql-dev \
      yaml-dev \
      zlib-dev=1.3.2-r0 && \
    apk add --update --no-cache \
      icu-libs \
      libpq \
      shared-mime-info \
      'sqlite-libs>=3.53.4-r0' \
      yaml \
      yarn \
      zlib=1.3.2-r0 && \
    # Special configuration for charlock_holmes gem - requires explicit ICU library paths
    # due to its native C++ extension that often fails to build in Alpine Linux environments
    bundle config set build.charlock_holmes --with-icu-dir=/usr/lib && \
    bundle config set build.charlock_holmes --with-opt-include=/usr/include/icu && \
    bundle config set build.charlock_holmes --with-cxxflags="-std=c++17" && \
    bundle config set build.charlock_holmes --with-ldflags="-licui18n -licuuc" && \
    bundle install --jobs=4

# Install corepack and enable yarn
RUN yarn global add corepack@0.34.0
RUN corepack enable && corepack prepare yarn@4.9.1 --activate

# Install node packages defined in package.json
COPY package.json yarn.lock ./
RUN yarn install --immutable

# Copy all files to /app (except what is defined in .dockerignore)
COPY . .

# Set up documentation gems
WORKDIR $DOCS_HOME
COPY tech_docs/Gemfile tech_docs/Gemfile.lock $DOCS_HOME
RUN bundle install --jobs=4

# Build documentation pages
RUN bundle exec rake tech_docs:csv:generate
RUN bundle exec rake tech_docs:reference_data:generate
RUN bundle exec rake tech_docs:build

# Remove build dependencies
RUN rm -rf /usr/local/bundle/cache \
  && apk del build-dependencies

WORKDIR $APP_HOME

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE=DUMMY ./bin/rails assets:precompile

###

# Build final rails-app image
FROM ruby:4.0.6-alpine3.23 AS rails-app
ENV BUNDLE_PATH=/usr/local/bundle
ENV APP_HOME=/app

WORKDIR $APP_HOME

RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

RUN addgroup -S appgroup -g 20001 && adduser -S appuser -G appgroup -u 10001

RUN apk add --update --no-cache icu-data-full icu-libs libpq shared-mime-info \
    'sqlite-libs>=3.53.4-r0' yaml yarn zlib=1.3.2-r0

COPY --from=rails-build /usr/local/bundle /usr/local/bundle
COPY --from=rails-build /app/ .

RUN echo export PATH=/usr/local/bin:\$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

RUN chown -R appuser:appgroup /app/tmp /app/log

ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA

USER 10001

CMD ["sh", "-c", "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0"]
