# flockがロックかかってないのに戻ってこなくなるので、そんなメソッド無かったことにする。
class File
  alias :flock_org :flock

  def flock(ope)
    return 0
  end
end