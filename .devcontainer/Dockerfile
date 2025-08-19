FROM ruby:3.4.2-alpine3.20

ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# Set timezone
RUN apk add --no-cache tzdata \
  && cp /usr/share/zoneinfo/Europe/London /etc/localtime \
  && echo "Europe/London" > /etc/timezone

# Copy files needed for bundle install
COPY ../.tool-versions ../Gemfile ../Gemfile.lock ./

# Install build deps (temporary) + runtime deps
RUN apk add --no-cache --virtual .build-deps \
      build-base \
      postgresql-dev \
      git \
  && apk add --no-cache \
      libpq \
      yarn \
      shared-mime-info \
      git \
      libc6-compat \
      yaml-dev \
      icu-dev \
      zlib-dev \
      libxml2-dev \
      libxslt-dev \
  && bundle install --jobs=4 \
  && rm -rf /usr/local/bundle/cache \
  && apk del .build-deps

# Install JS deps
COPY ../package.json ../yarn.lock ./
RUN yarn install --frozen-lockfile --ignore-scripts

# Copy app source
COPY . .

# Ensure PATH is set properly in shell
RUN echo 'export PATH=/usr/local/bin:$PATH' > /root/.ashrc
ENV ENV="/root/.ashrc"

# Set commit SHA at build time
ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA
