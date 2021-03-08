FROM ruby:2.7.2-alpine3.12

RUN uname -r

RUN apk add --update --no-cache tzdata && \
  cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
  echo "Europe/London" > /etc/timezone

RUN apk add --update --no-cache --virtual runtime-dependances \
  postgresql-dev \
  curl \
  git \
  bash \
  vim

ENV PATH "~/.asdf/bin:~/.asdf/shims:$PATH"

RUN echo $PATH
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch master

COPY .tool-versions Gemfile Gemfile.lock ./

SHELL ["/bin/bash", "-c"]
RUN touch ~/.bashrc
RUN echo ". ~/.asdf/asdf.sh" >> ~/.bashrc
RUN echo ". ~/.asdf/completions/asdf.bash" >> ~/.bashrc

RUN source  ~/.bashrc
#RUN /app/.asdf/asdf.sh
RUN asdf plugin-add yarn
RUN asdf plugin-add nodejs
RUN asdf plugin-add vim

RUN apk add gnupg
RUN /bin/bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-previous-release-team-keyring'
RUN /bin/bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'


RUN asdf install
RUN  ["/bin/bash", "-c", "/root/.asdf/installs/nodejs/13.14.0/bin/node --version"]

RUN ls -lah ~/.asdf/shims
RUN apk add --update --no-cache --virtual build-dependances \
  build-base && \
  bundle install --jobs=4 && \
  apk del build-dependances

COPY package.json yarn.lock ./

RUN /bin/sh node --version
RUN asdf install 12.18.3 && yarn install --frozen-lockfile
RUN cat  ~/.bashrc
COPY . .

ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA

RUN cat  ~/.bashrc

RUN echo export PATH=/usr/local/bin:\$PATH > ~/.ashrc
RUN cat ~/.ashrc
ENV ENV="/root/.ashrc"
RUN bundle exec rake assets:precompile
CMD bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0
