{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    awww
    playerctl
    brightnessctl
    # dunst
    libnotify
    cliphist
    wl-clipboard
    pavucontrol
    xwayland-satellite
    pywalfox-native
    quickshell
    grim
    wl-screenrec

    opencode # ai agent
  ];

  imports = [
    ./theme.nix

    ./niri
    # ./hypr
    ./island
    ./zathura
    # ./qutebrowser
    ./librewolf
    ./swayimg
    ./mimeapps
    ./wallpaper
  ];

  xdg.configFile."matugen".source = ./matugen;
}
