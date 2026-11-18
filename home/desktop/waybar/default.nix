{pkgs, ...}: {
  home.packages = [pkgs.waybar];

  # Files are linked individually (not the whole dir) because matugen writes
  # ~/.config/waybar/colors.css next to them.
  xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;
}
