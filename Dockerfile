FROM ruby:2.6.3-slim@sha256:3bfe39071381aba5fd69949acf0e521828f435dfad5fb85e156248edd398ae44
ENV APP_ROOT /app

RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT
ADD simple-sinatra-app/ $APP_ROOT/
RUN gem install bundler && bundle install

EXPOSE 80
CMD ["bundle", "exec", "rackup", "-p", "80", "-o", "0.0.0.0"]