# -*- coding: utf-8 -*-

require "rubygems"
require "rbconfig"
require "win32ole"
require "find"
require "fileutils"
require "rbconfig"
require File.join(File.absolute_path(File.dirname(__FILE__).encode("UTF-8")), "common.rb")


# Rubyスクリプトを実行する
def exec_rb(rb_file)
  ruby = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])

  system("#{ruby} #{rb_file}")
end


=begin
def modify_immodules_cache!()
  Find::find(Gem.default_dir).select { |a| a =~ /\/immodules.cache$/ }.each { |file|
    dir = File::expand_path(File::dirname(file))

    imime_path = File::join(dir, "immodules", "im-ime.dll")

    if !File::exist?(imime_path)
      next
    end

    file_bak = file + ".bak"

    FileUtils.cp(file, file_bak)

    File.open(file_bak) { |fpr|
      File.open(file, "w") { |fpw|
        fpr.each { |line|
          if line =~ /\/im-ime.dll\"/
            fpw.puts("\"#{imime_path}\"")
          else
            fpw.puts(line)
          end
        }
      }
    }
  }
end
=end


# PNGファイルをWindowsアイコンファイルに変換する
def png2ico(png, ico)
  File.open(ico, "wb") { |ico_fp|
    ico_fp.write([0, 1, 1].pack("s3"))
    ico_fp.write([0, 0, 0, 0, 1, 3, File::size(png), 22].pack("c4s2l2"))

    File.open(png, "rb") { |png_fp|
      data = png_fp.read()
      ico_fp.write(data)
    }
  }
end


# 起動時に余計なDOS窓が出ないようにするWSHを生成する
def create_vbs(vbs)
  vbs_content = %!CreateObject("WScript.Shell").Run "cmd /C #{$ruby_path} ""#{mikutter_dir.encode("Windows-31J")}/plugin/mikutter-windows/boot_mikutter_on_windows.rb""", 0!
  File.open(vbs, "w") { |vbs_fp|
    vbs_fp.write(vbs_content)
  }
end


# デスクトップにショートカットを作る
def create_shortcut!()
  png2ico(File::join(mikutter_dir, "core", "skin", "data", "icon.png"), File::join(mikutter_dir, "plugin", "mikutter-windows", "icon.ico"))

  create_vbs(File::join(mikutter_dir, "plugin", "mikutter-windows", "run_mikutter.vbs"))

  wshell = WIN32OLE.new("WScript.Shell")
  shortcut = wshell.CreateShortcut(File.join(wshell.SpecialFolders("Desktop"), "mikutter.lnk"))

  shortcut.TargetPath = File.join(mikutter_dir, "plugin", "mikutter-windows", "run_mikutter.vbs")
  shortcut.Arguments = ""
  shortcut.IconLocation = File.join(mikutter_dir, "plugin", "mikutter-windows", "icon.ico")
  shortcut.WorkingDirectory = mikutter_dir
  shortcut.Save
end


# gemシステムをアップデートする
def update_gem_system!()
  system("gem update --system --clear-sources --source http://rubygems.org")
end


# gemをインストールする
def install_gem!(gem_name)
  system("gem install #{gem_name}")
end


# bundleを実行する
def bundle!()
  current_dir = Dir.pwd
  Dir.chdir(mikutter_dir)
  system("bundle install")
  Dir.chdir(current_dir)
end


# 飾り枠付きputs
def puts_decorated(msg)
  line = "|　#{msg}　|"
  width = line.each_char.map{ |c| c.ascii_only? ? 1 : 2 }.inject(:+)

  puts "-" * width
  puts line
  puts "-" * width
end


if __FILE__ == $0
  puts_decorated "mikutter on Windowsにようこそ！"
  puts "Windowsでmikutterを動かすために色々準備をしていくよ。覚悟はいい？"
  puts ""

  puts "●SSLエラー回避のために、gemシステムをバージョンアップするよ。"
  update_gem_system!
  puts ""

  puts "●mikutterに必要なgemをインストールするよ。"
  install_gem!("bundler")
  bundle!
  puts ""

=begin
  puts "●日本語入力できるようにするよ。"
  modify_immodules_cache!
  puts ""
=end

  puts "●デスクトップにショートカットを作るよ。"
  create_shortcut!
  puts ""

  puts "●便利なプラグインをインストールしちゃうよ。"
  puts "（この後表示されるwarningは問題ありません）"
  install_gem!("minitar")
  exec_rb("install_cool_plugins.rb")
  puts ""

  puts_decorated "インストール完了！mikutter on Windowsを楽しんでね！"
  puts "[Enter]でこのウインドウを閉じます。"
  gets
end
