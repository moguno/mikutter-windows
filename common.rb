# -*- coding: utf-8 -*-

require 'rubygems'

# パッチファイルのリストを得る
def patches(prefix)
  Dir.glob(File.expand_path("*", File.dirname(__FILE__))).select { |file|
    file =~ /\/#{prefix}[0-9]{3}_.+\.rb$/
  }
end

# パッチをロードする
def apply_patches(prefix)
  patches(prefix).each { |patch|
    require patch
  }
end


# mikutterのパスを得る
def mikutter_dir
  File::expand_path(__FILE__) =~ /^(.+)\/plugin\/mikutter-windows/
  $1
end
