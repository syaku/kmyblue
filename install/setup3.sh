git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 3.2.2
rbenv global 3.2.2

gem install bundler --no-document

cd live

yarn install --pure-lockfile

bundle config deployment 'true'
bundle config without 'development test'
bundle install -j$(getconf _NPROCESSORS_ONLN)

cat << EOF

============== [kmyblue setup script 2 completed] ================

PostgreSQL and Redis are now available on localhost.

* PostgreSQL
    host     : /var/run/postgresql
    user     : mastodon
    database : mastodon_production
    password : ohagi

* Redis
    host     : localhost

[IMPORTANT] Check PostgreSQL password before setup!

Input this command to finish setup:
  cd live
  RAILS_ENV=production bundle exec rake mastodon:setup

If you update kmyblue version, use following:
  /home/mastodon/update

EOF


# パスワード変更
# sudo -u postgres psql << EOF
#   ALTER USER mastodon WITH PASSWORD 'ohagi';
# EOF

# サーバー設定変更
# sudo vi /etc/nginx/sites-available/mastodon

# サーバー起動・OS起動時自動起動設定
# systemctl enable --now mastodon-web mastodon-sidekiq mastodon-streaming
