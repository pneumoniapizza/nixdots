{
  pkgs,
  inputs,
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
    # xwayland-satellite
    (let pkgs = import inputs.nixpkgs-xwayland-satellite-0-8-1 {system = "x86_64-linux";}; in pkgs.xwayland-satellite)
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
    ./wallpaper
  ];

  xdg.configFile."matugen".source = ./matugen;
}
