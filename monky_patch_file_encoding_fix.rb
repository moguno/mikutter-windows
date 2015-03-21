# -*- coding: utf-8 -*-

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
