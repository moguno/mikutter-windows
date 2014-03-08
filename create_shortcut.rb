
require "rbconfig"
require "win32ole"

ruby_path = File::join(RbConfig::CONFIG["bindir"], RbConfig::CONFIG["ruby_install_name"]) + "w" + RbConfig::CONFIG["EXEEXT"]
File::expand_path(__FILE__) =~ /^(.+)\/plugin\/mikutter-windows/
mikutter_dir = $1

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

png2ico(File::join(mikutter_dir, "core", "skin", "data", "icon.png"), File::join(mikutter_dir, "plugin", "mikutter-windows", "icon.ico"))

wshell = WIN32OLE.new("WScript.Shell")
shortcut = wshell.CreateShortcut(File.join(wshell.SpecialFolders("Desktop"), "mikutter.lnk"))

shortcut.TargetPath = ruby_path
shortcut.Arguments = "#{mikutter_dir}/mikutter.rb"
shortcut.IconLocation = "#{mikutter_dir}/plugin/mikutter-windows/icon.ico"
shortcut.WorkingDirectory = mikutter_dir
shortcut.Save