apt update && apt upgrade -y

apt install -y curl wget gnupg apt-transport-https lsb-release ca-certificates

# nodejs
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update && sudo apt-get install nodejs -y

# postgresql
wget -O /usr/share/keyrings/postgresql.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgresql.list

apt update
apt install -y \
  imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core \
  g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf \
  bison build-essential libssl-dev libyaml-dev libreadline6-dev \
  zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
  nginx redis-server redis-tools postgresql postgresql-contrib \
  certbot python3-certbot-nginx libidn11-dev libicu-dev libjemalloc-dev

corepack enable
yarn set version classic

adduser --disabled-login mastodon
su - mastodon << EOF

git clone https://github.com/rbenv/rbenv.git /home/mastodon/.rbenv
cd /home/mastodon/.rbenv && src/configure && make -C src
echo 'export PATH="/home/mastodon/.rbenv/bin:$PATH"' >> /home/mastodon/.bashrc
echo 'eval "$(rbenv init -)"' >> /home/mastodon/.bashrc
exec bash
git clone https://github.com/rbenv/ruby-build.git /home/mastodon/.rbenv/plugins/ruby-build

RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 3.2.2
rbenv global 3.2.2

gem install bundler --no-document

EOF

sudo -u postgres psql << EOF
  CREATE USER mastodon WITH PASSWORD 'ohagi' CREATEDB;
EOF

su - mastodon <<EOF

git clone https://github.com/kmycode/mastodon.git live && cd live
git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)
yarn install --pure-lockfile

EOF

cp /home/mastodon/live/dist/nginx.conf /etc/nginx/sites-available/mastodon
ln -s /etc/nginx/sites-available/mastodon /etc/nginx/sites-enabled/mastodon
cp /home/mastodon/live/dist/mastodon-*.service /etc/systemd/system/
systemctl daemon-reload
