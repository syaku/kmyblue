# gitで最新リリースを取得
cd ~/live

# 最新タグを取り込む
if [ "$1" != "newest" ]; then
  git checkout $(git tag -l | grep -E '^kb[0-9]' | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)
fi

# Rubyバージョン管理用のrbenvをインストール、初期設定
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# 続きのシェルスクリプトをgit管理外にコピーし権限を与える
cp /home/mastodon/live/install/setup3.sh /home/mastodon/setup3.sh
chmod +x /home/mastodon/setup3.sh
cp /home/mastodon/live/install/setup4.sh /home/mastodon/setup4.sh
chmod +x /home/mastodon/setup4.sh

# ---------------------------------------------------

cat << EOF

============== [kmyblue setup script 2 completed] ================

Input this command to continue setup:
  exec bash
  exit
  sudo /home/mastodon/setup3.sh

EOF
