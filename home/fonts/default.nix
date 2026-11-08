{pkgs, ...}: {
  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = [
        "Monaspace Neon"
        "Symbols Nerd Font Mono"
      ];

      sansSerif = ["DejaVu Sans"];
      serif = ["DejaVu Serif"];
      emoji = ["Noto Color Emoji"];
    };
  };

  home.packages = with pkgs; [
    nerd-fonts.monaspace # Neon, Argon, Xenon, Radon, Krypton
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
    material-symbols
  ];
}
