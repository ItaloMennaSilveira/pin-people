FROM ruby:3.3.6

# Dependências do sistema
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  git \
  curl \
  libvips \
  postgresql-client

WORKDIR /app

COPY Gemfile* ./

RUN gem install bundler && bundle install

COPY . .

RUN bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT ["./bin/docker-entrypoint"]
