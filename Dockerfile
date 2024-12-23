FROM ruby:3.3.5-alpine3.20

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

COPY .tool-versions Gemfile Gemfile.lock ./

RUN apk add --update --no-cache --virtual build-dependances \
    postgresql-dev build-base git && \
    apk add --update --no-cache libpq yarn shared-mime-info && \
    bundle install --jobs=4 && \
    rm -rf /usr/local/bundle/cache && \
    apk del build-dependances

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --ignore-scripts

COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

RUN echo export PATH=/usr/local/bin:\$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE=DUMMY ./bin/rails assets:precompile

ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA

CMD bundle exec rails db:migrate && \
    bundle exec rails server -b 0.0.0.0
