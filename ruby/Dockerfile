ARG TAG=2.6-slim
FROM ruby:${TAG}

WORKDIR /app

COPY Gemfile* ./
RUN bundle install
