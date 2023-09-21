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

## インストール手順

[Wiki](https://github.com/kmycode/mastodon/wiki/Installation)を参照してください

## アップデート手順

[Wiki](https://github.com/kmycode/mastodon/wiki/Updation)を参照してください
