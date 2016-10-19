# GdkPixbuf 3.0.9でいくつかのメソッドの名前が変わってるのを修正
module GdkPixbuf
  class Pixbuf
    alias :initialize_new_from_file_at_size :initialize_new_from_file_at_size_utf8
    alias :initialize_new_from_file_at_scale :initialize_new_from_file_at_scale_utf8
    alias :initialize_new_from_file :initialize_new_from_file_utf8
  end
end
