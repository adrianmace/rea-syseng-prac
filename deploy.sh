#!/bin/bash -xe
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
systemctl restart nginx