# -*- coding: utf-8 -*-

require 'rbconfig'
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


class Hash
  alias :inspect_org :inspect

  # 魔の141行目問題を回避するよ。
  def inspect()
    result = self.inject({}) { |result, (key, item)|
      if item.is_a?(String)
        result[key] = item.encode(Encoding.default_external)
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
    playsound = Win32API.new('winmm', 'PlaySound', 'ppl', 'i')
    playsound.call(filename, nil, 0)
  end
end
