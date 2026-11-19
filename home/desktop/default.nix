{pkgs, ...}: {
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
    libnotify

    opencode # ai agent
  ];

  imports = [
    ./theme.nix

    ./niri
    ./fuzzel
    # ./hypr
    ./zathura
    # ./qutebrowser
    ./quickshell
    ./librewolf
    ./swayimg
    ./mimeapps
    ./wallpaper
  ];

  xdg.configFile."matugen".source = ./matugen;
}
