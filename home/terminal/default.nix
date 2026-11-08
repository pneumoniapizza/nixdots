{pkgs, ...}: {
  imports = [
    ./fastfetch
    ./tmux
    ./yazi
    ./fish
  ];

  home.packages = with pkgs; [
    unzip
    p7zip
    ripgrep
    foot
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

  xdg.configFile."foot/foot.ini".source = ./foot/foot.ini;
  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
}
