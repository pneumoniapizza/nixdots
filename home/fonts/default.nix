{pkgs, ...}: {
  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = [
        "JetBrainsMono Nerd Font"
        "Symbols Nerd Font Mono"
      ];

      sansSerif = ["DejaVu Sans"];
      serif = ["DejaVu Serif"];
      emoji = ["Noto Color Emoji"];
    };
  };

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
    material-symbols
  ];
}
