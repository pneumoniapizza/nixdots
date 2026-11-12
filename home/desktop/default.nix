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
    inputs.nixpkgs-xwayland-satellite-0-8-1.legacyPackages.${pkgs.stdenv.hostPlatform.system}.xwayland-satellite
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
    ./swayimg
    ./mimeapps
    ./wallpaper
  ];

  xdg.configFile."matugen".source = ./matugen;
}
