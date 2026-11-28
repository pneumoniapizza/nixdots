{pkgs, ...}: {
  imports = [
    ./fastfetch
    ./yazi
    ./fish
    ./starship
    ./foot
    ./tmux
  ];

  home.packages = with pkgs; [
    unzip
    p7zip
    ripgrep
    kitty
    eza
    btop
    cava
    wget
  ];

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
}
