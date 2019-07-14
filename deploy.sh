#!/bin/bash -xe
exec > /tmp/install.log 2>&1
git submodule update --init --recursive


sudo amazon-linux-extras install ruby2.4 -y
sudo amazon-linux-extras install nginx1.12 -y
gem install bundler
/usr/local/bin/bundle install
/usr/local/bin/bundle exec rackup &
cat << EOF > /etc/nginx/conf.d/app.conf
server {
  listen 80;
  listen [::]:80;
  location / {
      proxy_pass http://localhost:9292/;
  }
}
EOF
systemctl restart nginx