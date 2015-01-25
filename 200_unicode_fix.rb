# encode()のオプションを生成する
def add_encode_options(options)
  options[:invalid] = :replace
  options[:undef] = :replace

  options
end

class String
  # 変換出来ない文字は全部"?"にしちゃえ！
  alias :encode_org :encode
  
  def encode(encoding, options = {})
    encode_org(encoding, add_encode_options(options))
  end

  alias :encode_org! :encode!

  def encode!(encoding, options = {})
    encode_org!(encoding, add_encode_options(options))
  end
end