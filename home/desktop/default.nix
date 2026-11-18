{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    awww
    playerctl
    brightnessctl
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
    ./waybar
    ./fuzzel
    ./dunst
    # ./hypr
    ./zathura
    # ./qutebrowser
    ./librewolf
    ./swayimg
    ./mimeapps
    ./wallpaper
  ];

  xdg.configFile."matugen".source = ./matugen;
}
