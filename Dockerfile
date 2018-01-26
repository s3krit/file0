FROM ruby:2.4.1
ENV RACK_ENV production

RUN apt-get -y update; apt-get install -y imagemagick

# Copy and set up app
RUN mkdir /code
COPY . /code/

COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install

WORKDIR /code

EXPOSE 9292
CMD rackup
