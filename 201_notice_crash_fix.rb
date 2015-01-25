# noticeでDOS窓にUTF-8を表示しようとして落ちる「魔の141行目問題」を回避するよ。

class Hash
  alias :inspect_org :inspect

  def inspect()
    result = self.inject({}) { |result, (key, item)|
      if item.is_a?(String)
        begin
          result[key] = item.encode(Encoding.default_external)
        rescue => e
          result[key] = "(?????)"
        end
      else
        result[key] = item
      end

      result
    }

    result.inspect_org
  end
end