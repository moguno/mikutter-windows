mikutter-windows
================

# これなん？
mikutterをWindowsで使うためのパッチ達です。

# 動作環境
* Windows 7 Pro (64bit)
* RubyInstaller for Windows Ruby 2.0.0-p451 (32bit)
* Windows 8.1でも近々検証します。

# ざっくりとしたインストール手順
1. なんとかしてmikutterどっかに展開する。（c:¥ユーザ¥（ユーザ名）¥が楽ですね）
2. なんとかしてこのmikutter-windowsをmikutterを展開したディレクトリのplugin¥mikutter-windowsフォルダに展開する。
3. RubyInstallerをインストールする。
4. Ruby コマンドプロンプトを開く。
5. gem install bundler gtk2
6. cd (mikutterを展開したディレクトリ）
7. bundle install
8. ruby mikuter.rb

はぶふぁん。
