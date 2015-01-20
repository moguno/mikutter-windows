# -*- coding: utf-8 -*-

require 'rubygems'
require 'Win32API'


# テキストモードでGAZOUファイルを開くと壊れるぞ！
def file_get_contents(fn)
  open(fn, 'rb:utf-8') { |input|
    input.read
  }
end


def file_put_contents(fn, body)
  File.open(fn, 'wb'){ |put|
    put.write body
    body
  }
end


def object_get_contents(fn)
  File.open(fn, 'rb'){ |input|
    Marshal.load input
  }
end


# encode()のオプションを生成する
def add_encode_options(options)
  options[:invalid] = :replace
  options[:undef] = :replace

  options
end


class String
  # 変換出来ない文字は全部"?"にしちゃえ！
  alias :encode_org :encode
  
  def encode(encoding, options = {})
    encode_org(encoding, add_encode_options(options))
  end

  alias :encode_org! :encode!

  def encode!(encoding, options = {})
    encode_org!(encoding, add_encode_options(options))
  end
end


class Hash
  alias :inspect_org :inspect

  # 魔の141行目問題を回避するよ。
  def inspect()
    result = self.inject({}) { |result, (key, item)|
      if item.is_a?(String)
        begin
          result[key] = item.encode(Encoding.default_external)
        rescue => e
          result[key] = "(?????)"
        end
      else
        result[key] = item
      end

      result
    }

    result.inspect_org
  end
end


class File
  alias :flock_org :flock

  # flockがロックかかってないのに戻ってこなくなるので、そんなメソッド無かったことにする。
  def flock(ope)
    return 0
  end
end


module Gtk
  # ツールチップを出したときにフリーズする事象の回避
  # ウィジェットのツールチップってTooltipsクラスが出すんだけど、意識してこいつの参照を保持しないとウィジェットより先にガベージコレクションされてしまう。
  # それに伴ってGObjectが破棄されてコケるとするとすべての事象に説明が付くんだけど、再現コードでは問題なし。。。
  # あと、ToolTipsはアプリで1インスタンスしか存在しなくても良いがmikutterは都度インスタンスを生成してるので、それがWindowsではギルティなのかもしれない。
  # 取りあえずシングルトンっぽく1つのインスタンスを共有する様にしたら落ちなくなったからまぁいいや。今日もいい天気。
  class Tooltips
    class << self
      @@unique_tips = Gtk::Tooltips.new

      alias :new_org new

      def new
        @@unique_tips
      end
    end
  end

  class << self
    alias :openurl_org :openurl

    # イメージウインドウをクリックしたときにブラウザが開かないバグへの対応
    def openurl(url)
      if url.frozen?
        openurl_org(url.melt)
      else
        openurl_org(url)
      end
    end
  end
end


class Plugin::Settings
  alias :about_org :about

  # 「mikutterについて」でrubyw.exe 0.2.2についてなどと表示されるのを修正
  def about(label, options={})
    if options[:name] && !options[:program_name]
      options[:program_name] = options[:name]
    end

    about_org(label, options)
  end
end


# 画像プレビューウインドウに画像が表示できない問題のひっくす
Plugin[:openimg].instance_eval {
  # Gdk::Window由来のCairoContextへの描画にバグがあるようなので、PixMap経由で描画する。
  def redraw(w_wrap, image_surface, repaint: true)
    gdk_window = w_wrap.window
    return unless gdk_window
    ew, eh = gdk_window.geometry[2,2]
    return if(ew == 0 or eh == 0)
    pixmap = Gdk::Pixmap.new(gdk_window, gdk_window.geometry[2], gdk_window.geometry[3], -1)
    context = pixmap.create_cairo_context
    context.save do
      if repaint
        context.set_source_color(Cairo::Color::BLACK)
        context.paint end
      if (ew * image_surface.height) > (eh * image_surface.width)
        rate = eh.to_f / image_surface.height
        context.translate((ew - image_surface.width*rate)/2, 0)
      else
        rate = ew.to_f / image_surface.width
        context.translate(0, (eh - image_surface.height*rate)/2) end
      context.scale(rate, rate)
      context.set_source(Cairo::SurfacePattern.new(image_surface))
      context.paint 

      w_wrap.window.draw_drawable(Gdk::GC.new(pixmap), pixmap, 0, 0, 0, 0, gdk_window.geometry[2], gdk_window.geometry[3])
    end
  rescue => _
    error _
  end
}


Plugin.create(:windows) do

  # Windowsミキサーがmikutterアイコンで埋まる問題の対策
  on_gui_window_change_icon { |i_window, icon|
    window = Plugin[:gtk].widgetof(i_window)
    if window
      window.icon = Gdk::Pixbuf.new(icon, 32, 32)
    end
  }

  on_boot { |service|

    defactivity("windows", "Windowsプラグイン")

    if !UserConfig[:windows_initialized_001]
      UserConfig[:activity_show_timeline] = UserConfig[:activity_show_timeline] + ["windows"]
      UserConfig[:sound_server] = :win32

      UserConfig[:windows_initialized_001] = true
    end

    delay = 10

    [
      "フォントはArial Unicode MSを使うと文字化けが少ないです",
      "設定の「通知」でmikutter/core/skin/data/sounds/のwavファイルを指定すると、mikutterがかわいくしゃべり始めます",
      "このお助けメッセージを非表示にするには、設定の「アクティビティ」で「Windowsプラグイン」のタイムライン表示をOFFにしよう。",
    ].each { |msg|

      Reserver.new(delay) {
        activity(:windows, msg)
      }

      delay += 10
    }
  }

  # サウンドを鳴らします
  defsound :win32, "Windows" do |filename|
    SND_ASYNC = 0x0001
    playsound = Win32API.new('winmm', 'PlaySound', 'ppl', 'i')
    playsound.call(filename.encode(Encoding.default_external), nil, SND_ASYNC)
  end
end
