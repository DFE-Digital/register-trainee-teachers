FROM ruby:2.7.5-alpine3.15

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

COPY .tool-versions Gemfile Gemfile.lock ./

RUN apk add --update --no-cache --virtual build-dependances \
    postgresql-dev build-base && \
    apk add --update --no-cache libpq yarn shared-mime-info && \
    bundle install --jobs=4 && \
    rm -rf /usr/local/bundle/cache && \
    apk del build-dependances

# Remove once base image ruby:2.7.5-alpine3.15 has been updated with latest libretls
RUN apk add --no-cache libretls=3.3.4-r3

COPY package.json yarn.lock ./
RUN  yarn install --frozen-lockfile && \
     yarn cache clean

COPY . .

RUN echo export PATH=/usr/local/bin:\$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

RUN bundle exec rake assets:precompile && \
    rm -rf node_modules tmp

ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA

CMD bundle exec rails db:migrate && \
    bundle exec rails server -b 0.0.0.0
