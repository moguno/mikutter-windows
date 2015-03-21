# -*- coding: utf-8 -*-

require 'rubygems'
require 'Win32API'
require File.join(File.absolute_path(File.dirname(__FILE__)), "common.rb")

# パッチをロードする
apply_patches("")


# プラグイン本体
Plugin.create(:mikutter_windows) {
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
}
