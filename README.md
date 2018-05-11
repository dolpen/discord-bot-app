
## 導入

```
$ bundle install --path vendor/bundle
```

## ローカルで実行

```
$ export DISCORD_TOKEN="botから取って来たトークン。secretではなく画面下の方から取れるやつ"
$ bundle exec ruby main.rb
```

## デプロイ

環境変数の設定をCLIでやりたくないなら Heroku のコンソールからやっても OK

```
// 環境変数の追加
$ heroku config:add DISCORD_TOKEN="botから取って来たトークン。secretではなく画面下の方から取れるやつ"
// 環境変数の確認
$ heroku config
// buildpack(bundlerとかいろいろいい感じにしてくれるやつ)のアサイン
$ heroku create --buildpack https://github.com/heroku/heroku-buildpack-ruby.git
// 音声系の入れるならここら辺も
$ heroku create --buildpack https://github.com/challengee/heroku-buildpack-libsodium.git
$ heroku create --buildpack https://github.com/xrisk/heroku-opus.git

$ git push heroku master
// 1台でええわこんなん、0にすると止められます
$ heroku ps:scale worker=1
```
