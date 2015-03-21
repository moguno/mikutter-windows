# -*- coding: utf-8 -*-

# パスを格納した文字列がWindows-31Jになって各種ファイル操作に失敗するのをFix
require File.join(File.absolute_path(File.dirname(__FILE__).encode("UTF-8")), "monky_patch_file_encoding_fix.rb")


class Exception
  alias :backtrace_org :backtrace

  def backtrace
    bt = backtrace_org

    if bt
      bt.map {|_|
        _.encode("UTF-8")
      }
    else
      bt
    end
  end
end
