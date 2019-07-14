FROM ruby:2.6.3-slim
ENV APP_ROOT /app

RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

#RUN apt-get update -qq && apt-get install -y build-essential
ADD simple-sinatra-app/ $APP_ROOT/
RUN gem install bundler
RUN bundle install

EXPOSE 80
CMD ["bundle", "exec", "rackup", "-p", "80", "-o", "0.0.0.0"]