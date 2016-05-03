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

    activity(:windows, "mikutter on Windowsのバグ報告はhttps://github.com/moguno/mikutter-windows/issuesまでお願いします")

    if !UserConfig[:windows_initialized_001]
      UserConfig[:activity_show_timeline] = UserConfig[:activity_show_timeline] + ["windows"]
      UserConfig[:sound_server] = :win32

      UserConfig[:mumble_basic_font] = "Meiryo 10"
      UserConfig[:mumble_reply_font] = "Meiryo 8"
      UserConfig[:mumble_basic_left_font] = "Meiryo 10"
      UserConfig[:mumble_basic_right_font] = "Meiryo 10"

      UserConfig[:notify_sound_retweeted] = "{MIKUTTER_DIR}/core/skin/data/sounds/retweeted.wav"
      UserConfig[:notify_sound_favorited] = "{MIKUTTER_DIR}/core/skin/data/sounds/favo.wav"

      Plugin.call(:play_sound, "{MIKUTTER_DIR}/core/skin/data/sounds/mikutter.wav")

      UserConfig[:windows_initialized_001] = true
    end
  }

  # サウンドを鳴らします
  defsound :win32, "Windows" do |filename|
    SND_ASYNC = 0x0001
    playsound = Win32API.new('winmm', 'PlaySound', 'ppl', 'i')
    playsound.call(filename.encode(Encoding.default_external), nil, SND_ASYNC)
  end
}
