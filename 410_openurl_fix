# イメージウインドウをクリックしたときにブラウザが開かないバグへの対応
module Gtk
  class << self
    alias :openurl_org :openurl

    def openurl(url)
      if url.frozen?
        openurl_org(url.melt)
      else
        openurl_org(url)
      end
    end
  end
end
