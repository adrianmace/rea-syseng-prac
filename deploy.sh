#!/bin/bash -xe
git submodule update --init --recurse
cd simple-sinatra-app
bundle install
screen -d -m bundle exec rackup
cat << EOF >> /etc/nginx/conf.d/app.conf
server {
  listen 80;
  listen [::]:80;
  location / {
      proxy_pass http://localhost:9292/;
  }
}
EOF
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.disabled
nginx -s reload