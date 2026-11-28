{pkgs, ...}: {
  home.packages = [pkgs.swayimg];

  xdg.configFile."swayimg/init.lua".text = ''
    swayimg.text.size = 16
    swayimg.text.font = "JetBrainsMono Nerd Font"

    -- info overlay
    swayimg.text.color = 0xffe0def4

    -- single image view
    swayimg.viewer.set_window_background(0xff191724)
    swayimg.viewer.mark_color = 0xeec4a7e7

    -- gallery (thumbnail grid)
    swayimg.gallery.window_color = 0xff191724
    swayimg.gallery.unselected_color = 0xff1f1d2e
    swayimg.gallery.selected_color = 0xff26233a
    swayimg.gallery.border_color = 0xffc4a7e7
    swayimg.gallery.mark_color = 0xeec4a7e7
  '';
}
