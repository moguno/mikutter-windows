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

      mikutter_directory = File.expand_path(File.join(File.dirname(__FILE__), '..\\..'))
      UserConfig[:notify_sound_retweeted] = File.join(mikutter_directory, "\\core\\skin\\data\\sounds\\retweeted.wav").gsub(/\//, "\\")
      UserConfig[:notify_sound_favorited] = File.join(mikutter_directory, "\\core\\skin\\data\\sounds\\favo.wav").gsub(/\//, "\\")

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
