FROM alpine:3.3
MAINTAINER Ross Fairbanks <ross@microscaling.com>

ENV RUBY_PACKAGES ruby ruby-libs ruby-io-console ruby-json ruby-bundler ruby-rake

# Update and install all of the required packages.
# At the end, remove the apk cache
RUN apk update && \
    apk upgrade && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

# Cache installing gems
WORKDIR /tmp
COPY Gemfile* /tmp/

RUN bundle install

# Create working directory.
WORKDIR /app

COPY . ./
COPY marathon/ /apps/marathon/

ENTRYPOINT ["bundle", "exec", "rake"]

# By default start the consumer to read messages from the queue.
CMD ["consumer"]
