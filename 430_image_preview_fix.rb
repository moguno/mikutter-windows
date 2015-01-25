# 画像プレビューウインドウに画像が表示できない問題のひっくす
Plugin[:openimg].instance_eval {
  # Gdk::Window由来のCairoContextへの描画にバグがあるようなので、PixMap経由で描画する。
  def redraw(w_wrap, image_surface, repaint: true)
    gdk_window = w_wrap.window
    return unless gdk_window
    ew, eh = gdk_window.geometry[2,2]
    return if(ew == 0 or eh == 0)
    pixmap = Gdk::Pixmap.new(gdk_window, gdk_window.geometry[2], gdk_window.geometry[3], -1)
    context = pixmap.create_cairo_context
    context.save do
      if repaint
        context.set_source_color(Cairo::Color::BLACK)
        context.paint end
      if (ew * image_surface.height) > (eh * image_surface.width)
        rate = eh.to_f / image_surface.height
        context.translate((ew - image_surface.width*rate)/2, 0)
      else
        rate = ew.to_f / image_surface.width
        context.translate(0, (eh - image_surface.height*rate)/2) end
      context.scale(rate, rate)
      context.set_source(Cairo::SurfacePattern.new(image_surface))
      context.paint 

      w_wrap.window.draw_drawable(Gdk::GC.new(pixmap), pixmap, 0, 0, 0, 0, gdk_window.geometry[2], gdk_window.geometry[3])
    end
  rescue => _
    error _
  end
}