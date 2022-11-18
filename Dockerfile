FROM ruby:3.1.2-alpine
MAINTAINER LAA Crime Apply Team

RUN apk --no-cache add --virtual build-deps build-base git bash curl \
 && apk --no-cache add tzdata

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

# create some required directories
RUN mkdir -p /usr/src/app && \
    mkdir -p /usr/src/app/log && \
    mkdir -p /usr/src/app/tmp && \
    mkdir -p /usr/src/app/tmp/pids

WORKDIR /usr/src/app

COPY Gemfile* .ruby-version ./

RUN gem install bundler && \
    bundle config set frozen 'true' && \
    bundle config without test:development && \
    bundle install --jobs 2 --retry 3

COPY . .

# tidy up installation
RUN apk del build-deps && rm -rf /tmp/*

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup log tmp

ARG APP_BUILD_DATE
ENV APP_BUILD_DATE ${APP_BUILD_DATE}

ARG APP_BUILD_TAG
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}

ENV APPUID 1000
USER $APPUID

ENV PORT 3000
EXPOSE $PORT

ENTRYPOINT ["./run.sh"]
