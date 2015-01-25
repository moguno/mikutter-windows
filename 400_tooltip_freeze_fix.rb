# ツールチップを出したときにフリーズする事象の回避
# ウィジェットのツールチップってTooltipsクラスが出すんだけど、意識してこいつの参照を保持しないとウィジェットより先にガベージコレクションされてしまう。
# それに伴ってGObjectが破棄されてコケるとするとすべての事象に説明が付くんだけど、再現コードでは問題なし。。。
# あと、ToolTipsはアプリで1インスタンスしか存在しなくても良いがmikutterは都度インスタンスを生成してるので、それがWindowsではギルティなのかもしれない。
# 取りあえずシングルトンっぽく1つのインスタンスを共有する様にしたら落ちなくなったからまぁいいや。今日もいい天気。
module Gtk
  class Tooltips
    class << self
      @@unique_tips = Gtk::Tooltips.new

      alias :new_org new

      def new
        @@unique_tips
      end
    end
  end
end