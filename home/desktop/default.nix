{pkgs, ...}: {
  home.packages = with pkgs; [
    awww
    playerctl
    brightnessctl
    cliphist
    wl-clipboard
    pavucontrol
    xwayland-satellite
    grim
    wl-screenrec
    libnotify

    waybar
    swayosd
    swaylock
    swayidle
    batsignal

    opencode # ai agent
  ];

  imports = [
    ./gtk

    ./niri
    ./fuzzel
    ./dunst
    ./discord
    ./waybar
    ./osd
    ./lock
    ./zathura
    # ./qutebrowser
    ./librewolf
    ./swayimg
    ./mimeapps
    ./wallpaper
  ];
}
