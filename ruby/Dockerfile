ARG TAG=2.6-slim
FROM ruby:${TAG}

WORKDIR /app

COPY ./ruby/Gemfile* ./
RUN bundle install
