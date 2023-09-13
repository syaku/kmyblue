# kmyblueインストール手順

## 共通の注意事項

### 必須ソフトウェアのバージョン

Ruby、ElasticSearch、ImageMagick、PostgreSQLなど必須ソフトウェアのバージョンは、本家Mastodonに準じます。リリースノートに対応する本家Mastodonバージョンが記載されていますので、本家Mastodonのリリースノートから対応するバージョンを探して調べてください。

### 一般的な注意事項

kmyblueは頻繁にバージョンアップを行います。

- 本家Mastodonの開発中のバージョンを平然と取り込みます
- バグが含まれていることがあります
- 特に最新コミットでは、デバッグ用コードや、`kmy.blue`本番サーバーで動作確認を行うためのコードが含まれている場合があります。ブランチの最新コミットではなく最新タグを取り込むことを強くおすすめします

Mastodonの最新バージョンでは、`dist`フォルダに`mastodon-streaming@.service`が追加されています。これは現在の一般的な手順書には存在しません。各サービスファイルをコピーするとき、`mastodon-streaming@.service`をコピーし忘れないようにしてください。

### ElasticSearchを使用する場合

kmyblueでは、sudachiの使用を前提としています。

下記URLより、ElasticSearchにSudachiプラグインを追加してください。
ただし辞書ファイル（sudachi dictionary archive）は手順書で指示されたパスではなく`/etc/elasticsearch/sudachi`に格納してください。

https://github.com/WorksApplications/elasticsearch-sudachi

Sudachiインストール終了後、追加で`/etc/elasticsearch/sudachi/config.json`に下記を記述して保存してください。`system_full.dic`を使用する場合は適宜`systemDict`プロパティの内容を置き換えてください。

```json
{
  "systemDict": "system_core.dic"
}
```

## 新規インストールの場合

1. 本家Mastodonとセットアップ手順はほとんど一緒です。kmyblueが独自に必須ソフトウェアを追加したわけではありません。ただしkmyblueはMastodonの開発中コードを取り込んでいるので、Rubyなどのバージョンアップ作業が必要になる場合があります。Mastodon公式のセットアップ手順を盲信せず、画面の指示に従ってインストールを進めてください。CloudFlareを組み合わせてセットアップしたとき、サーバーに接続すると400が出るなどのトラブルが出ることがありますが、大抵はMastodon本家由来のトラブルだと思われるので基本サポートはしません
2. ただひとつ差異があります。Gitリポジトリはこのkmyblueに向けてください。`kb_development`ブランチの最新コミットではなく、`kb`で始まる最新のタグを取り込むことを強くおすすめします

## 本家Mastodonからのマイグレーションの場合

kmyblueから本家Mastodonに戻りたい場合もあると思いますので、**必ずデータベースのバックアップをとってください**。

1. kmyblueのリリースノートに、kmyblueバージョンに対応した本家Mastodonのバージョンが記載されています。それを参照して、まず本家Mastodonをそのバージョンまでバージョンアップしてください
2. Gitのリモートにkmyblueを追加して、そのままチェックアウトしてください
3. データベースのマイグレーションなどを行ってください

```
sudo systemctl stop mastodon-*

bundle install
yarn install
RAILS_ENV=production bin/rails db:migrate
RAILS_ENV=production bin/rails assets:clobber
RAILS_ENV=production bin/rails assets:precompile

# ElasticSearchを使用する場合
RAILS_ENV=production bin/tootctl search deploy

RAILS_ENV=production bin/tootctl cache clear
sudo systemctl start mastodon-web mastodon-streaming mastodon-sidekiq
```

## kmyblueのバージョンをアップデートする

リリースノートを参照して、自分に必要な作業を特定してください。面倒な場合は毎回全部実行してしまっても問題ありません。（プリコンパイルが失敗する可能性があるのでご注意ください）

```
# Rubyパッケージアップデート
bundle intall

# JSパッケージアップデート
yarn install

# DBマイグレーション
RAILS_ENV=production bin/rails db:migrate

# プリコンパイル
# うまくいかない場合（エラーは出ないのにWeb表示が崩れる）はclobberしてからprecompile
# それでもうまくいかない場合はsudo systemctl stop mastodon-webしてから試す
# それでもうまくいかない場合はサーバーOSを再起動してから試す
RAILS_ENV=production bin/rails assets:clobber # プリコンパイルがうまくいかない場合
RAILS_ENV=production bin/rails assets:precompile

# サーバー再起動
sudo systemctl restart mastodon-web
sudo systemctl restart mastodon-streaming
sudo systemctl restart mastodon-sidekiq
```
