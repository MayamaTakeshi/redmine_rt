#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

echo "I need the root password for mysql server:"
read -s mysql_pass


username=`whoami`


sudo -E apt-add-repository ppa:brightbox/ruby-ng
sudo -E apt-get update
sudo -E apt-get install -y ruby2.4 ruby2.4-dev

sudo -E apt-get install -y imagemagick
sudo -E apt-get install -y libmagickcore5
sudo -E apt-get install -y libmagickcore-dev
sudo -E apt-get install -y libmagickwand-dev
sudo -E gem install rmagick -v '2.16.0'



rm -f redmine-3.4.3.tar.gz
rm -fr redmine-3.4.3

wget http://www.redmine.org/releases/redmine-3.4.3.tar.gz

tar xvzf redmine-3.4.3.tar.gz

cd redmine-3.4.3
cp config/database.yml.example config/database.yml

sed -i 's/redmine_development/redmine/g' config/database.yml
sed -i "s/username: root/username: $username/g" config/database.yml
sed -i 's/password: ""/password: redmine/g' config/database.yml

mysql -u root --password=$mysql_pass -e "DROP DATABASE IF EXISTS redmine; DROP USER $username@localhost;"
mysql -u root --password=$mysql_pass -e "CREATE DATABASE redmine CHARACTER SET utf8; CREATE USER $username@localhost IDENTIFIED BY 'redmine'; GRANT ALL PRIVILEGES ON redmine.* TO $username@localhost;"

sudo -E gem install bundler
bundle install --without development test

bundle exec rake generate_secret_token

RAILS_ENV=production bundle exec rake db:migrate

RAILS_ENV=production REDMINE_LANG=en bundle exec rake redmine:load_default_data

set +o errexit
useradd redmine -U
set -o errexit

mkdir -p tmp tmp/pdf tmp/pids public/plugin_assets log

cd plugins
git clone https://github.com/jbbarth/redmine_base_deface
git clone https://github.com/MayamaTakeshi/redmine_rt
cd ../
bundle install


echo "Success"
