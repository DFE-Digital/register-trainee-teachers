FROM ruby:3.4.2-alpine3.20 AS rails-build

ENV BUNDLE_PATH=/usr/local/bundle
ENV APP_HOME=/app

WORKDIR $APP_HOME

RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

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

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE=DUMMY ./bin/rails assets:precompile

###

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

FROM ruby:3.4.2-alpine3.20
ENV BUNDLE_PATH=/usr/local/bundle
ENV APP_HOME=/app

WORKDIR $APP_HOME

RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

RUN apk add --update --no-cache icu-libs libpq shared-mime-info yaml yarn zlib

COPY --from=rails-build /usr/local/bundle /usr/local/bundle
COPY --from=rails-build /app/ .

COPY --from=middleman-build /app/public/api-docs/ $APP_HOME/public/api-docs/
COPY --from=middleman-build /app/public/csv-docs/ $APP_HOME/public/csv-docs/
COPY --from=middleman-build /app/public/reference-data/ $APP_HOME/public/reference-data/

RUN echo export PATH=/usr/local/bin:\$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA

CMD ["sh", "-c", "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0"]
