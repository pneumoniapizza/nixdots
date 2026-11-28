{config, ...}: let
  niriDir = "${config.home.homeDirectory}/dotfiles/home/desktop/niri";
  files = [
    "config.kdl"
    "colors.kdl"
    "effects.kdl"
  ];
in {
  xdg.configFile = builtins.listToAttrs (map (file: {
      name = "niri/${file}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/${file}";
    })
    files);
}
