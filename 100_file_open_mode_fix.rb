# バイナリファイルをテキストモードで開いている箇所を修正
def file_get_contents(fn)
  open(fn, 'rb:utf-8') { |input|
    input.read
  }
end

def file_put_contents(fn, body)
  File.open(fn, 'wb'){ |put|
    put.write body
    body
  }
end

def object_get_contents(fn)
  File.open(fn, 'rb'){ |input|
    Marshal.load input
  }
end