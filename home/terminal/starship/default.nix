{...}: {
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableTransience = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };
}
