RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 3.2.2
rbenv global 3.2.2

gem install bundler --no-document

bundle config deployment 'true'
bundle config without 'development test'
bundle install -j$(getconf _NPROCESSORS_ONLN)

unlink /home/mastodon/setup2

echo << EOF

============== [kmyblue setup script 2 completed] ================

Input this command to finish setup:
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
