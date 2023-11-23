FROM ruby:2.7.7-slim as Builder

RUN apt-get update \
  && apt-get install -y curl wget \
  make \
  gcc \
  g++ \
  postgresql-all \
  build-essential \
  git \
  tzdata

ENV LC_ALL en_US.UTF-8
ARG LOCAL_TIME=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$LOCAL_TIME \
  /etc/localtime

RUN update-ca-certificates \
  && wget --no-check-certificate -P /usr/local/share/ca-certificates/ https://dl.cacerts.digicert.com/RapidSSLTLSRSACAG1.crt \
  && update-ca-certificates


ARG APP_PATH=/opt/app/
WORKDIR $APP_PATH

# Add the app
COPY . $APP_PATH

ENV NODE_ENV production
ENV RAILS_ENV production

# Install gems
RUN export BUNDLER_VERSION=$(awk '/BUNDLED WITH/ { getline ; print $1 }' Gemfile.lock) \
  && gem install bundler --version $BUNDLER_VERSION \
  && bundle config --global frozen 1 \
  && bundle install -j4 --retry 3 \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete
# Remove unneeded files (cached *.gem, *.o, *.c)
