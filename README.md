# Ruby Hacking Guide to EPUB

[『Rubyソースコード完全解説』](http://i.loveruby.net/ja/rhg/book/)のHTML版をEPUB3形式に変換します。

以下の点を改善してみました：

* 目次の表示
* 脚注をポップアップ
* コードを等幅フォントで表示
* highlight.jsでコードハイライト
* コードの行番号をコメントアウト
* ソースファイル名をコメントアウト

他にも多少修正してあります。

動作確認は、Mac OS XとiOSのiBooksのみで行なっています。

## 必要なもの

* pandoc
    * HTMLをEPUB3に変換します
* node.js
    * rhg-epub.shスクリプトはnpmを使ってcoffee-scriptとjsdomをローカルにインストールします
    * lib/rhg-highlight.coffeeはコードをハイライトします
* ruby
    * lib/rhg-html.rbはHTMLを修正します
    * lib/rhg-css.rbはCSSを修正します
* curl
    * rhg-epub.shスクリプトはHTML版のアーカイブをダウンロードします
    * rhg-epub.shスクリプトはhighlight.jsとjQueryをダウンロードします
* unzip
    * epubファイルを展開します
* zip
    * epubファイルを圧縮します

## 使い方

```
$ ./rhg-epub.sh
$ open RubyHackingGuide.epub
```

## 感謝

貴重なドキュメントを公開してくださった著者の青木峰郎さんに感謝します。

## 参考

* [Ruby Hacking Guide を Kindle で読めるようにする](http://makimoto.hatenablog.com/entry/2013/10/20/Ruby_Hacking_Guide_%E3%82%92_Kindle_%E3%81%A7%E8%AA%AD%E3%82%81%E3%82%8B%E3%82%88%E3%81%86%E3%81%AB%E3%81%99%E3%82%8B)
* [icm7216/RHG-epub](https://github.com/icm7216/RHG-epub)

