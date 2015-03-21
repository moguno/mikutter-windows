# -*- coding: utf-8 -*-

# File.joinの結果がWindows-31Jになって各種ファイル操作に失敗するのをFix
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
  end
end
