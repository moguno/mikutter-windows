mikutter-windows
================

# ご注意
※Ruby Installer 2.1.5はGemの証明書が古く、setup.rb中にSSL関係のエラーが発生します。
事前に「Rubyコマンドプロンプトを開く」から、下記のコマンドを実行して、gemを最新にしてください。

    (1)gem source --remove https://rubygems.org
    (2)gem source --add http://rubygems.org
    https://rubygems.org is recommended for security over http://rubygems.org

    Do you want to add this insecure source? [yn]  y　←yと答える
    http://rubygems.org added to sources

    (3)gem update --system
    (4)gem source --remove http://rubygems.org
    (5)gem source --add https://rubygems.org

# これなん？
mikutterをWindowsで使うためのパッチ達です。
mikutterへの手パッチが不要になったり、サウンドが鳴る様になったりします。

# 動作環境
* Windows 7 Pro (64bit)
* Windows 8.1 Pro (64bit)
* Windows 8.1 (32bit)
* RubyInstaller for Windows Ruby 2.0.0-p451 (32bit)

# ざっくりとしたインストール手順
1. RubyInstallerをインストールする。
（途中で聞かれる環境変数の設定と.rbへの関連付けは必ずチェックしましょう。）
2. なんとかしてmikutterをどっかに展開する。
（日本語を含むフォルダだと動きません。）
3. なんとかしてこのmikutter-windowsを（mikutterを展開したフォルダ）¥plugin¥mikutter-windowsフォルダに展開する。
（落とし方によって、フォルダ名がmikutter-windows(-余計な文字列)になってる場合があるので注意して下さい。）
4. （mikutterを展開したフォルダ）¥plugin¥mikutter-windowsフォルダのsetup.rbをダブルクリックする。
5. デスクトップにできたmikutterアイコンをダブルクリック！

はぶふぁん。


# 参考資料

Windowsでmikutterを動かしてみる
http://kazblog.hateblo.jp/entry/2014/02/23/054832

超参考になりました。ありがとうございます！
