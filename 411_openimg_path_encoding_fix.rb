#coding: utf-8

# Cairo::ImageSurfaceのfrom_pngがパスの解釈に失敗するのを修正

module Cairo
  class ImageSurface
    class << self
      alias :from_png_org :from_png

      def from_png(filename)
        from_png_org(filename.encode("Windows-31J"))
      end
    end
  end
end
