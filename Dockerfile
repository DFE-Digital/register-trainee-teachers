FROM ruby:3.4.2-alpine3.20 AS middleman
RUN apk add --no-cache libxml2
RUN apk add --update --no-cache npm git build-base

ENV APP_HOME=/app
ENV DOCS_HOME=/tech_docs

WORKDIR $APP_HOME

COPY app/ $APP_HOME

WORKDIR $DOCS_HOME

COPY tech_docs/Gemfile tech_docs/Gemfile.lock $DOCS_HOME

RUN bundle install --jobs=4

COPY tech_docs/ $DOCS_HOME

RUN rake tech_docs:csv:generate
RUN rake tech_docs:build

###

FROM ruby:3.4.2-alpine3.20

ENV APP_HOME=/app
RUN mkdir $APP_HOME
RUN mkdir /tech_docs
WORKDIR $APP_HOME

RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

RUN addgroup -S appgroup -g 20001 && adduser -S appuser -G appgroup -u 10001

COPY .tool-versions Gemfile Gemfile.lock ./

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

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --ignore-scripts

COPY . .

COPY --from=middleman public/api-docs/ $APP_HOME/public/api-docs/
COPY --from=middleman public/csv-docs/ $APP_HOME/public/csv-docs/

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

RUN echo export PATH=/usr/local/bin:\$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE=DUMMY ./bin/rails assets:precompile

RUN chown -R appuser:appgroup /app /usr/local/bundle/config /tech_docs

ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA

# Use non-root user
USER 10001

CMD ["sh", "-c", "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0"]
