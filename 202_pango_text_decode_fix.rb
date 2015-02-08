# Pangoが「半角 + 全角スペース」を文字化けさせるので、事前にそれっぽいスペースに置き換える
class Pango::Layout
  alias :text_org= :text=

  def text=(text)
    self.text_org = text.gsub("\u{3000}", "\u{2003}")
  end
end
