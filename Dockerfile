# This template builds 3 images, to optimise caching:
# rails-build: builds gems and node modules
# middleman-build: builds the Middleman static docs site
# rails-app: runs the actual app

# Build rails-build image
FROM ruby:3.4.2-alpine3.20 AS rails-build

ENV BUNDLE_PATH=/usr/local/bundle
ENV APP_HOME=/app

WORKDIR $APP_HOME

# Add the timezone (rails-build image) as it's not configured by default in Alpine
RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

COPY .tool-versions Gemfile Gemfile.lock ./

# Install gems and remove gem cache
RUN apk add --update --no-cache --virtual build-dependencies \
    build-base cmake g++ git icu-dev pkgconf postgresql-dev yaml-dev zlib-dev && \
    apk add --update --no-cache icu-libs libpq shared-mime-info yaml yarn zlib && \
    # Special configuration for charlock_holmes gem - requires explicit ICU library paths
    # due to its native C++ extension that often fails to build in Alpine Linux environments
    bundle config build.charlock_holmes --with-icu-dir=/usr/lib && \
    bundle config build.charlock_holmes --with-opt-include=/usr/include/icu && \
    bundle config build.charlock_holmes --with-cxxflags="-std=c++17" && \
    bundle config build.charlock_holmes --with-ldflags="-licui18n -licuuc" && \
    bundle install --jobs=4 && \
    rm -rf /usr/local/bundle/cache && \
    apk del build-dependencies

# Install corepack and enable yarn
RUN yarn global add corepack
RUN corepack enable && corepack prepare yarn@4.9.1 --activate

# Install node packages defined in package.json
COPY package.json yarn.lock ./
RUN yarn install --immutable

# Copy all files to /app (except what is defined in .dockerignore)
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE=DUMMY ./bin/rails assets:precompile

###

# Build Middleman docs image
FROM ruby:3.4.2-alpine3.20 AS middleman-build

ENV BUNDLE_PATH=/usr/local/bundle
ENV APP_HOME=/app
ENV DOCS_HOME=$APP_HOME/tech_docs

RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

RUN apk add --no-cache libxml2
RUN apk add --update --no-cache npm git build-base postgresql-dev

COPY --from=rails-build /usr/local/bundle /usr/local/bundle

WORKDIR $DOCS_HOME

COPY tech_docs/Gemfile tech_docs/Gemfile.lock $DOCS_HOME

RUN bundle install --jobs=4

WORKDIR $APP_HOME

COPY . .

WORKDIR $DOCS_HOME

RUN bundle exec rake tech_docs:csv:generate
RUN bundle exec rake tech_docs:reference_data:generate
RUN bundle exec rake tech_docs:build

###

# Build final rails-app image
FROM ruby:3.4.2-alpine3.20 AS rails-app
ENV BUNDLE_PATH=/usr/local/bundle
ENV APP_HOME=/app

WORKDIR $APP_HOME

RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

RUN addgroup -S appgroup -g 20001 && adduser -S appuser -G appgroup -u 10001

RUN apk add --update --no-cache icu-data-full icu-libs libpq shared-mime-info yaml yarn zlib

COPY --from=rails-build /usr/local/bundle /usr/local/bundle
COPY --from=rails-build /app/ .

COPY --from=middleman-build /app/public/api-docs/ $APP_HOME/public/api-docs/
COPY --from=middleman-build /app/public/csv-docs/ $APP_HOME/public/csv-docs/
COPY --from=middleman-build /app/public/reference-data/ $APP_HOME/public/reference-data/

RUN echo export PATH=/usr/local/bin:\$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

RUN chown -R appuser:appgroup /app/tmp /app/log

ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA

USER 10001

CMD ["sh", "-c", "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0"]
