mikutter-windows
================

# これなん？
mikutterをWindowsで使うためのパッチ達です。
mikutterへの手パッチが不要になったり、サウンドが鳴る様になったりします。

# 動作環境
* Windows 7 Pro (64bit)
* RubyInstaller for Windows Ruby 2.0.0-p451 (32bit)
* Windows 8.1でも近々検証します。

# ざっくりとしたインストール手順
1. なんとかしてmikutterをどっかに展開する。（c:¥ユーザ¥（ユーザ名）¥mikutterが楽ですね）
2. なんとかしてこのmikutter-windowsを（mikutterを展開したフォルダ）¥plugin¥mikutter-windowsフォルダに展開する。
3. RubyInstallerを使ってRubyをインストールする。（オプションは下二つをON）
4. Ruby コマンドプロンプトを開く。
5. gem install bundler gtk2
6. cd (mikutterを展開したフォルダ）
7. bundle install
8. ruby mikuter.rb

はぶふぁん。

# いろいろ

* ポストボックスへのインライン入力を行うためには、Gtkの設定をいじる必要があります。

>（Rubyのインストールパス）¥lib¥ruby¥gems¥2.0.0¥gems¥gtk2-2.1.0-x86-mingw32¥vendor¥local¥lib¥gtk-2.0¥2.10.0¥immodules.cache

の3行目のパスを、

>（Rubyのインストールパス）¥lib¥ruby¥gems¥2.0.0¥gems¥gtk2-2.1.0-x86-mingw32¥vendor¥local¥lib¥gtk-2.0¥2.10.0¥immodules¥im-ime.dll

にすればOKとのことです。

# 参考資料

Windowsでmikutterを動かしてみる
http://kazblog.hateblo.jp/entry/2014/02/23/054832

超参考になりました。ありがとうございます！
