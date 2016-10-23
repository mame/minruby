# 『Ruby で学ぶ Ruby』用補助ライブラリ

ASCII.jp の Web 連載『[Ruby で学ぶ Ruby](http://ascii.jp/elem/000/001/230/1230449/)』のための補助ライブラリです。

## インストール方法

コンソールで

    gem install minruby

というコマンドを実行してください。
また、あなたのプログラムの最初の行に

    require "minruby"

という行を追加してください。

## 別のインストール方法

`gem` でのインストールがうまく行かない場合は、[ライブラリのファイル](https://raw.githubusercontent.com/mame/minruby/master/lib/minruby.rb)をダウンロードしてあなたのプログラムと同じフォルダに置いてください。それから、あなたのプログラムの最初の行に

    require "./minruby"

という行を追加してください。

## 使い方

連載記事を参照してください。第 4 回以降でこのライブラリを使用しています。

## ライセンス

[MIT License](http://opensource.org/licenses/MIT)

