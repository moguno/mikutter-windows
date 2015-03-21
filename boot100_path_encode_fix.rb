# -*- coding: utf-8 -*-

# パスを格納した文字列がWindows-31Jになって各種ファイル操作に失敗するのをFix
class Dir
  class << self
    alias :pwd_org :pwd

    def pwd
      pwd_org.encode("UTF-8")
    end
  end
end

class File
  class << self
    alias :join_org :join

    def join(*args)
      join_org(*args).encode("UTF-8")
    end

    alias :expand_path_org :expand_path

    def expand_path(*args)
      expand_path_org(*args).encode("UTF-8")
    end
  end
end

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
