{ inputs, ... }:
{
  imports = [ inputs.island.homeManagerModules.default ];
  programs.island = {
    enable = true;
    settings = {
      # check codeberg.org/pneumoniapizza/island for options
      look.shadow = true;
      wallpapers.dir = "~/Pictures/wallpapers";
      launcher.terminal = [ "kitty" ];
      clipboard.watch = true;
    };
  };
}
