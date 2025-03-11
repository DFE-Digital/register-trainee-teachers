FROM ruby:3.4.2-alpine3.20

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apk add --update --no-cache tzdata && \
  cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
  echo "Europe/London" > /etc/timezone

COPY ../.tool-versions ../Gemfile ../Gemfile.lock ./

RUN apk add --update --no-cache --virtual build-dependances \
  postgresql-dev build-base git && \
  apk add --update --no-cache libpq yarn shared-mime-info git libc6-compat postgresql-dev && \
  bundle install --jobs=4 && \
  rm -rf /usr/local/bundle/cache && \
  apk del build-dependances

COPY ../package.json ../yarn.lock ./
RUN yarn install --frozen-lockfile --ignore-scripts

COPY . .

RUN echo export PATH=/usr/local/bin:\$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA
