VERSION=5.0

apt update && apt upgrade -y

apt install -y curl wget gnupg apt-transport-https lsb-release ca-certificates

# Node.js
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update && sudo apt-get install nodejs -y

# PostgreSQL
wget -O /usr/share/keyrings/postgresql.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgresql.list

# 必要なパッケージをまとめてインストール
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

# mastodonユーザーを追加
adduser --disabled-login mastodon

# PostgreSQLにmastodonユーザーを追加
sudo -u postgres psql << EOF
  CREATE USER mastodon WITH PASSWORD 'ohagi' CREATEDB;
EOF

# kmyblueソースコードをダウンロード
# 続きのシェルスクリプトをgit管理外にコピーし権限を与える
su - mastodon <<EOF
git clone https://github.com/kmycode/mastodon.git live
cp /home/mastodon/live/install/$VERSION/setup2.sh /home/mastodon/setup2.sh
cp /home/mastodon/live/install/$VERSION/setup3.sh /home/mastodon/setup3.sh
cp /home/mastodon/live/install/$VERSION/setup4.sh /home/mastodon/setup4.sh
chmod +x /home/mastodon/setup2.sh
chmod +x /home/mastodon/setup3.sh
chmod +x /home/mastodon/setup4.sh
EOF

# ---------------------------------------------------

cat << EOF

============== [kmyblue setup script 1 completed] ================

Input this command to continue setup:
  sudo su - mastodon
  ./setup2.sh

EOF
