# プロフィールタブのフォロワー・フォロイーウインドウの中身が「error」になる件の修正
# monetaのFileAdapterでデータベース（バイナリ）をFile::read()で読んでるけど、その関数テキストファイル用なのよ。
# いやお前らマジでテキストモードとバイナリモード区別しろやコラ。
module Moneta
  module Adapters
    class File
      def load(key, options = {})
        ::File.open(store_path(key), "rb") { |fp|
          fp.read
        }
      rescue Errno::ENOENT
      end
    end
  end
end
