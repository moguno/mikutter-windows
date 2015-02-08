# noticeでDOS窓にUTF-8を表示しようとして落ちる「魔の141行目問題」を回避するよ。

class String
  def inspect()
    encode(Encoding.default_external)
  rescue => e
    "(?????)"
  end
end

class Hash
  alias :inspect_org :inspect

  def inspect()
    result = self.inject({}) { |result, (key, item)|
      result[key] = if item.is_a?(String)
        item.inspect
      else
        item
      end

      result
    }

    result.inspect_org
  end
end