{config, pkgs, ...}: let
  rose-pine-gtk = import ./rose-pine-gtk.nix {inherit pkgs;};
in {
  gtk = {
    enable = true;
    theme = {
      name = "rose-pine";
      package = rose-pine-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Original-Classic";
      size = 20;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4 = {
      theme = config.gtk.theme;
      extraConfig.gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "rose-pine";
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };
}
