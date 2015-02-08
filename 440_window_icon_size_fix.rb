# Windowsミキサーがmikutterアイコンで埋まる問題の対策
Plugin.create(:windows) {
  on_gui_window_change_icon { |i_window, icon|
    window = Plugin[:gtk].widgetof(i_window)
    if window
      window.icon = Gdk::Pixbuf.new(icon, 32, 32)
    end
  }
}